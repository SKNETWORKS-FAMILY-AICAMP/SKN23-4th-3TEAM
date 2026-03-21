"""
api/middleware.py
─────────────────────────────────────────────
JWT 인증 데코레이터.
기존 FastAPI deps.py의 get_current_user_id를 대체.

사용법:
    from api.middleware import require_auth

    @require_auth
    def my_view(request, user_id):
        ...
"""

import os
import json
import functools
from jose import JWTError, jwt
from datetime import datetime, timedelta, timezone
from django.http import JsonResponse
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "changeme_in_production")
ALGORITHM = "HS256"


def require_auth(view_func):
    """
    JWT 인증 데코레이터.
    Authorization: Bearer <token> 헤더에서 user_id를 추출하여
    view 함수의 첫 번째 인자(request) 다음에 user_id를 전달.
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        auth_header = request.META.get("HTTP_AUTHORIZATION", "")

        if not auth_header.startswith("Bearer "):
            return JsonResponse(
                {"detail": "인증 정보가 필요합니다."},
                status=401,
            )

        token = auth_header[7:]  # "Bearer " 제거

        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id = payload.get("sub")

            if user_id is None:
                return JsonResponse(
                    {"detail": "인증 정보가 유효하지 않습니다."},
                    status=401,
                )

            kwargs["user_id"] = int(user_id)
            return view_func(request, *args, **kwargs)

        except (JWTError, ValueError):
            return JsonResponse(
                {"detail": "인증 정보가 유효하지 않습니다."},
                status=401,
            )

    return wrapper


def create_access_token(user_id: int) -> str:
    """JWT access_token 생성 (24시간 유효)"""
    expire = datetime.now(timezone.utc) + timedelta(hours=24)
    payload = {"sub": str(user_id), "exp": expire}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def create_permanent_token(user_id: int) -> str:
    """만료 없는 관리자용 JWT 생성"""
    payload = {"sub": str(user_id), "admin": True}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def parse_json_body(request):
    """request.body를 JSON으로 파싱하는 헬퍼"""
    try:
        return json.loads(request.body)
    except (json.JSONDecodeError, ValueError):
        return None
