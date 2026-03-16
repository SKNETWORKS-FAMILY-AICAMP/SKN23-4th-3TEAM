
import json
import random

from pathlib import Path
from db.models import User
from typing import Optional
from datetime import datetime
from db.schemas import UserCreate, UserUpdate
from db.db_manager import execute_one, execute_write

# ─────────────────────────────────────────────
# 프로필 이미지 헬퍼 (images + entity_images)
# ─────────────────────────────────────────────

def _get_profile_image_url(user_id: int) -> Optional[str]:
    """
    user_id에 연결된 프로필 이미지 URL 조회.
    entity_type='profile' 기준으로 가장 최근 1개 반환.
    """
    row = execute_one(
        """
        SELECT i.image_url
        FROM images i
        JOIN entity_images ei ON i.image_id = ei.image_id
        WHERE ei.entity_type = 'profile' AND ei.entity_id = %s
        ORDER BY ei.entity_image_id DESC
        LIMIT 1
        """,
        (user_id,)
    )
    return row["image_url"] if row else None

def _upsert_profile_image(user_id: int, image_url: str) -> None:
    """
    프로필 이미지를 저장하거나 교체.
    - images 테이블에 URL 중복 저장 방지 (기존 URL이면 재사용)
    - entity_images에서 해당 user의 기존 매핑은 삭제 후 새 매핑 삽입 (1:1 유지)
    """
    # 1. images 테이블에서 URL 조회 또는 신규 삽입
    existing = execute_one(
        "SELECT image_id FROM images WHERE image_url = %s LIMIT 1",
        (image_url,)
    )
    image_id = existing["image_id"] if existing else execute_write(
        "INSERT INTO images (image_url) VALUES (%s)",
        (image_url,)
    )

    # 2. 기존 프로필 매핑 삭제 (user당 프로필 이미지 1개 유지)
    execute_write(
        "DELETE FROM entity_images WHERE entity_type = 'profile' AND entity_id = %s",
        (user_id,)
    )

    # 3. 새 매핑 삽입
    execute_write(
        "INSERT INTO entity_images (image_id, entity_type, entity_id) VALUES (%s, 'profile', %s)",
        (image_id, user_id)
    )

_nicknames: list[str] = []

def _load_nicknames() -> list[str]:
    global _nicknames
    if not _nicknames:
        path = Path(__file__).parent.parent / "assets" / "nicknames.json"
        _nicknames = json.loads(path.read_text(encoding="utf-8"))
    return _nicknames

def generate_random_nickname() -> str:
    """
    중복되지 않는 랜덤 닉네임 생성.
    - assets/nicknames.json의 이름 뒤에 4자리 랜덤 숫자를 붙임
    - 중복 시 숫자를 바꿔 최대 10회 재시도
    """
    names = _load_nicknames()
    for _ in range(10):
        nickname = f"{random.choice(names)}_{random.randint(1000, 9999)}"
        if not is_nickname_taken(nickname):
            return nickname
    raise ValueError("사용 가능한 닉네임을 생성하지 못했습니다. 잠시 후 다시 시도해주세요.")

"""
user_service.py
─────────────────────────────────────────────────────────────
목적  : 사용자 데이터 관리 비즈니스 로직 담당
역할  :
    1. 회원 생성
    2. 사용자 조회 (user_id / email)
    3. 프로필 수정 (닉네임, 피부정보, S3 이미지 URL 등)
    4. 회원 탈퇴 (soft delete)
    5. 이메일 / 닉네임 중복 확인

인증/로그인 관련 로직은 auth_service.py에서 담당
─────────────────────────────────────────────────────────────
"""

# ─────────────────────────────────────────────
# 1. 중복 확인
# ─────────────────────────────────────────────

def is_email_taken(email: str) -> bool:
    """
    이메일 중복 확인.
    이미 존재하면 True 반환.

    사용 예시:
        if is_email_taken("test@test.com"):
            raise HTTPException(400, "이미 사용 중인 이메일입니다.")
    """
    row = execute_one(
        "SELECT user_id FROM users WHERE email = %s AND deleted_at IS NULL",
        (email,)
    )

    return row is not None


def is_nickname_taken(nickname: str) -> bool:
    """
    닉네임 중복 확인.
    이미 존재하면 True 반환.

    사용 예시:
        if is_nickname_taken("홍길동"):
            raise HTTPException(400, "이미 사용 중인 닉네임입니다.")
    """
    row = execute_one(
        "SELECT user_id FROM users WHERE nickname = %s AND deleted_at IS NULL",
        (nickname,)
    )

    return row is not None


# ─────────────────────────────────────────────
# 2. 회원 생성
# ─────────────────────────────────────────────

def create_user(data: UserCreate) -> User:
    """
    신규 회원 생성.
    - 이메일/닉네임 중복 시 예외 발생
    - users 테이블에 INSERT 후 생성된 User 반환
    - 로그인 수단 등록은 auth_service.register_local_auth() 에서 처리

    사용 예시:
        user = create_user(UserCreate(
            email          = "test@test.com",
            nickname       = "길동이",
            terms_agreed   = True,
            privacy_agreed = True,
        ))
    """
    if is_email_taken(data.email):
        raise ValueError("이미 사용 중인 이메일입니다.")

    user_id = execute_write(
        """
        INSERT INTO users (email, nickname, terms_agreed, privacy_agreed)
        VALUES (%s, %s, %s, %s)
        """,
        (data.email, data.nickname, data.terms_agreed, data.privacy_agreed)
    )

    user = get_user_by_id(user_id) or get_user_by_email(data.email)

    if not user:
        raise RuntimeError("회원 생성 후 사용자 조회에 실패했습니다.")

    return user


# ─────────────────────────────────────────────
# 3. 사용자 조회
# ─────────────────────────────────────────────

def get_user_by_id(user_id: int) -> Optional[User]:
    """
    user_id로 사용자 조회.
    탈퇴한 사용자는 반환하지 않음 (soft delete 고려).

    사용 예시:
        user = get_user_by_id(1)
    """
    row = execute_one(
        "SELECT * FROM users WHERE user_id = %s AND deleted_at IS NULL",
        (user_id,)
    )

    if not row:
        return None

    user = User.from_dict(row)
    user.profile_image_url = _get_profile_image_url(user_id)

    return user


def get_user_by_email(email: str) -> Optional[User]:
    """
    이메일로 사용자 조회.
    탈퇴한 사용자는 반환하지 않음.

    사용 예시:
        user = get_user_by_email("test@test.com")
    """
    row = execute_one(
        "SELECT * FROM users WHERE email = %s AND deleted_at IS NULL",
        (email,)
    )

    if not row:
        return None

    user = User.from_dict(row)
    user.profile_image_url = _get_profile_image_url(user.user_id)

    return user


# ─────────────────────────────────────────────
# 4. 프로필 수정
# ─────────────────────────────────────────────

def update_user(user_id: int, data: UserUpdate) -> User:
    """
    사용자 프로필 수정.
    - 변경할 필드만 골라서 UPDATE (None인 필드는 건너뜀)
    - 닉네임 변경 시 중복 확인 포함
    - profile_image_url은 users 테이블이 아닌 images + entity_images에 저장

    사용 예시:
        updated = update_user(1, UserUpdate(nickname="새닉네임", age=25))
        updated = update_user(1, UserUpdate(profile_image_url="https://s3.../profile.jpg"))
    """
    raw = data.model_dump()

    # profile_image_url은 users 테이블 컬럼이 아니므로 분리해서 처리
    profile_image_url = raw.pop("profile_image_url", None)

    fields = {k: v for k, v in raw.items() if v is not None}

    if not fields and profile_image_url is None:
        raise ValueError("수정할 내용이 없습니다.")

    # users 테이블 업데이트
    if fields:
        set_clause = ", ".join([f"{key} = %s" for key in fields])
        values = tuple(fields.values()) + (user_id,)

        execute_write(
            f"UPDATE users SET {set_clause} WHERE user_id = %s AND deleted_at IS NULL",
            values
        )

    # 프로필 이미지 저장 (images + entity_images)
    if profile_image_url:
        _upsert_profile_image(user_id, profile_image_url)

    return get_user_by_id(user_id)


# ─────────────────────────────────────────────
# 5. 회원 탈퇴
# ─────────────────────────────────────────────

def delete_user(user_id: int) -> bool:
    """
    회원 탈퇴 처리 (soft delete).
    - deleted_at에 현재 시각 기록
    - 실제 데이터는 삭제하지 않음 (복구 가능)
    - auth_providers는 hard delete (재가입 시 충돌 방지)

    사용 예시:
        success = delete_user(1)
    """
    affected = execute_write(
        """
        UPDATE users
        SET deleted_at = %s,
            email    = CONCAT('deleted_', user_id, '_', email),
            nickname = CONCAT('deleted_', user_id, '_', nickname)
        WHERE user_id = %s AND deleted_at IS NULL
        """,
        (datetime.now(), user_id)
    )

    if affected > 0:
        execute_write(
            "DELETE FROM auth_providers WHERE user_id = %s",
            (user_id,)
        )

    return affected > 0