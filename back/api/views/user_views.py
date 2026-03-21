"""
api/views/user_views.py
기존 back/routers/user_router.py → Django view 변환
"""
import os
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

from api.middleware import require_auth, create_permanent_token, parse_json_body
from services import user_service, auth_service, email_service
from db.schemas import UserCreate, UserUpdate


@csrf_exempt
@require_http_methods(["POST"])
def signup(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    secret = os.getenv("EMAIL_OTP_SECRET", "")
    if not email_service.verify_otp(body.get("email", ""), body.get("verification_code", ""), secret):
        return JsonResponse({"detail": "이메일 인증 코드가 유효하지 않거나 만료되었습니다."}, status=400)

    try:
        nickname = body.get("nickname") or user_service.generate_random_nickname()
        user_data = UserCreate(
            email=body["email"],
            nickname=nickname,
            terms_agreed=body.get("terms_agreed", False),
            privacy_agreed=body.get("privacy_agreed", False),
        )
        user = user_service.create_user(user_data)
        auth_service.register_local_auth(user.user_id, user.email, body["password"])
        return JsonResponse(_to_response(user), status=201)
    except (ValueError, KeyError) as e:
        return JsonResponse({"detail": str(e)}, status=400)


@csrf_exempt
@require_http_methods(["POST"])
def login(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    try:
        result = auth_service.login_local(body["email"], body["password"])
        return JsonResponse({"access_token": result["access_token"], "token_type": "bearer"})
    except (ValueError, KeyError) as e:
        return JsonResponse({"detail": str(e)}, status=401)


@csrf_exempt
@require_auth
def me(request, user_id):
    if request.method == "GET":
        user = user_service.get_user_by_id(user_id)
        if not user:
            return JsonResponse({"detail": "사용자를 찾을 수 없습니다."}, status=404)
        return JsonResponse(_to_response(user))

    elif request.method == "PATCH":
        body = parse_json_body(request)
        if not body:
            return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)
        try:
            data = UserUpdate(**body)
            user = user_service.update_user(user_id, data)
            return JsonResponse(_to_response(user))
        except (ValueError, TypeError) as e:
            return JsonResponse({"detail": str(e)}, status=400)

    elif request.method == "DELETE":
        success = user_service.delete_user(user_id)
        if not success:
            return JsonResponse({"detail": "사용자를 찾을 수 없습니다."}, status=404)
        return JsonResponse({}, status=204)

    return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)


@csrf_exempt
@require_auth
def social_links(request, user_id):
    providers = auth_service.get_linked_social_providers(user_id)
    return JsonResponse({"is_social": len(providers) > 0, "providers": providers})


def check_email(request):
    email = request.GET.get("email", "")
    return JsonResponse({"available": not user_service.is_email_taken(email)})


def check_nickname(request):
    nickname = request.GET.get("nickname", "")
    return JsonResponse({"available": not user_service.is_nickname_taken(nickname)})


@csrf_exempt
@require_http_methods(["POST"])
def send_email_code(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    secret = os.getenv("EMAIL_OTP_SECRET", "")
    otp = email_service.generate_otp(body["email"], secret)
    try:
        email_service.send_verification_email(body["email"], otp)
    except RuntimeError as e:
        return JsonResponse({"detail": str(e)}, status=500)
    return JsonResponse({"message": "인증 코드가 발송되었습니다."})


@csrf_exempt
@require_http_methods(["POST"])
def verify_email_code(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    secret = os.getenv("EMAIL_OTP_SECRET", "")
    valid = email_service.verify_otp(body["email"], body["code"], secret)
    return JsonResponse({"valid": valid})


@csrf_exempt
@require_http_methods(["POST"])
def reset_password(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    secret = os.getenv("EMAIL_OTP_SECRET", "")
    if not email_service.verify_otp(body["email"], body["code"], secret):
        return JsonResponse({"detail": "이메일 인증 코드가 유효하지 않거나 만료되었습니다."}, status=400)

    try:
        auth_service.reset_password(body["email"], body["new_password"])
    except ValueError as e:
        return JsonResponse({"detail": str(e)}, status=400)
    return JsonResponse({"message": "비밀번호가 변경되었습니다."})


@csrf_exempt
@require_http_methods(["POST"])
def admin_token(request):
    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    user = user_service.get_user_by_email(body["email"])
    if not user:
        return JsonResponse({"detail": "사용자를 찾을 수 없습니다."}, status=404)
    if not user.is_admin:
        return JsonResponse({"detail": "관리자 권한이 없는 계정입니다."}, status=403)

    token = create_permanent_token(user.user_id)
    return JsonResponse({"access_token": token, "token_type": "bearer"})


def _to_response(user) -> dict:
    return {
        "user_id": user.user_id,
        "is_admin": user.is_admin,
        "email": user.email,
        "nickname": user.nickname,
        "age": user.age,
        "gender": user.gender,
        "skin_type": user.skin_type,
        "skin_concern": user.skin_concern,
        "created_at": user.created_at.isoformat() if user.created_at else None,
        "profile_image_url": user.profile_image_url,
    }
