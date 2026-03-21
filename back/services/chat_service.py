from typing import Optional
from datetime import datetime

from db.db_manager import execute_one, execute_write, execute_query
from db.models import ChatRoom, ChatMessage
from db.schemas import ChatRoomCreate, MessageCreate

# ─────────────────────────────────────────────
# 이미지 헬퍼 (images + entity_images)
# ─────────────────────────────────────────────

def _save_image_and_map(image_url: str, entity_type: str, entity_id: int) -> None:
    """
    이미지 URL을 images 테이블에 저장하고 entity_images에 매핑.
    - 동일 URL이 이미 images 테이블에 존재하면 재사용 (중복 저장 방지)
    - entity_images에는 entity_type별로 별도 행 추가
    """
    existing = execute_one(
        "SELECT image_id FROM images WHERE image_url = %s LIMIT 1",
        (image_url,)
    )
    image_id = existing["image_id"] if existing else execute_write(
        "INSERT INTO images (image_url) VALUES (%s)",
        (image_url,)
    )

    execute_write(
        "INSERT INTO entity_images (image_id, entity_type, entity_id) VALUES (%s, %s, %s)",
        (image_id, entity_type, entity_id)
    )


def _get_image_urls(entity_type: str, entity_id: int) -> list[str]:
    """
    entity_type + entity_id 로 연결된 이미지 URL 목록 조회.
    """
    rows = execute_query(
        """
        SELECT i.image_url
        FROM images i
        JOIN entity_images ei ON i.image_id = ei.image_id
        WHERE ei.entity_type = %s AND ei.entity_id = %s
        ORDER BY ei.entity_image_id
        """,
        (entity_type, entity_id)
    )

    return [row["image_url"] for row in rows]


def _get_image_urls_batch(entity_type: str, entity_ids: list[int]) -> dict[int, list[str]]:
    """
    여러 entity_id에 대한 이미지 URL을 한 번의 쿼리로 일괄 조회.
    반환: { entity_id: [url, ...], ... }
    """
    if not entity_ids:
        return {}

    placeholders = ",".join(["%s"] * len(entity_ids))
    rows = execute_query(
        f"""
        SELECT ei.entity_id, i.image_url
        FROM images i
        JOIN entity_images ei ON i.image_id = ei.image_id
        WHERE ei.entity_type = %s AND ei.entity_id IN ({placeholders})
        ORDER BY ei.entity_image_id
        """,
        (entity_type, *entity_ids)
    )

    result: dict[int, list[str]] = {}
    
    for row in rows:
        eid = row["entity_id"]
        result.setdefault(eid, []).append(row["image_url"])

    return result

"""
chat_service.py
─────────────────────────────────────────────────────────────
목적  : 채팅방 및 메시지 관련 비즈니스 로직 담당
역할  :
    1. 채팅방 생성 / 조회 / 삭제 (soft delete)
    2. 메시지 저장 / 조회
    3. 채팅방 제목 업데이트 (첫 메시지 요약)
    4. 채팅방별 전체 메시지 히스토리 조회

흐름:
    FastAPI 라우터 → chat_service 함수 호출
                    → db_manager 헬퍼로 DB 접근
                    → models.ChatRoom / ChatMessage 로 변환 후 반환
─────────────────────────────────────────────────────────────
"""

# ─────────────────────────────────────────────
# 1. 채팅방
# ─────────────────────────────────────────────

def create_chat_room(data: ChatRoomCreate) -> ChatRoom:
    """
    새 채팅방 생성.
    - title은 생략 가능 (첫 메시지 저장 후 update_chat_room_title()로 설정)

    사용 예시:
        room = create_chat_room(ChatRoomCreate(user_id=1))
    """
    chat_room_id = execute_write(
        """
        INSERT INTO chat_rooms (user_id, title)
        VALUES (%s, %s)
        """,
        (data.user_id, data.title)
    )

    return get_chat_room_by_id(chat_room_id)


def get_chat_room_by_id(chat_room_id: int) -> Optional[ChatRoom]:
    """
    chat_room_id로 채팅방 단건 조회.
    삭제된 채팅방은 반환하지 않음 (soft delete 고려).

    사용 예시:
        room = get_chat_room_by_id(1)
    """
    row = execute_one(
        "SELECT * FROM chat_rooms WHERE chat_room_id = %s AND deleted_at IS NULL",
        (chat_room_id,)
    )

    return ChatRoom.from_dict(row) if row else None


def get_chat_rooms_by_user(user_id: int) -> list[ChatRoom]:
    """
    user_id로 사용자의 전체 채팅방 목록 조회.
    최신 순(created_at DESC)으로 반환.

    사용 예시:
        rooms = get_chat_rooms_by_user(1)
    """
    rows = execute_query(
        """
        SELECT * FROM chat_rooms
        WHERE user_id = %s AND deleted_at IS NULL
        ORDER BY created_at DESC
        """,
        (user_id,)
    )

    return [ChatRoom.from_dict(row) for row in rows]


def update_chat_room_title(chat_room_id: int, title: str) -> bool:
    """
    채팅방 제목 업데이트.
    - 첫 메시지 저장 후 LLM 요약 제목을 설정할 때 사용

    사용 예시:
        update_chat_room_title(1, "건성 피부에 맞는 수분크림 추천")
    """
    affected = execute_write(
        """
        UPDATE chat_rooms SET title = %s
        WHERE chat_room_id = %s AND deleted_at IS NULL
        """,
        (title, chat_room_id)
    )

    return affected > 0


def delete_chat_room(chat_room_id: int) -> bool:
    """
    채팅방 삭제 (soft delete).
    - deleted_at에 현재 시각 기록
    - 채팅방 삭제 시 하위 메시지는 CASCADE로 자동 삭제됨 (DB 설정)

    사용 예시:
        success = delete_chat_room(1)
    """
    affected = execute_write(
        """
        UPDATE chat_rooms
        SET deleted_at = %s
        WHERE chat_room_id = %s AND deleted_at IS NULL
        """,
        (datetime.now(), chat_room_id)
    )

    return affected > 0


# ─────────────────────────────────────────────
# 2. 메시지
# ─────────────────────────────────────────────

def save_message(data: MessageCreate) -> ChatMessage:
    """
    메시지 저장.
    - role: user / assistant / system
    - model_type: simple / detailed
    - image_urls가 있으면 images + entity_images 테이블에 저장

    사용 예시:
        # 텍스트 메시지
        msg = save_message(MessageCreate(
            chat_room_id=1,
            role="user",
            model_type="simple",
            content="건성 피부에 맞는 수분크림 추천해줘"
        ))

        # 이미지 메시지
        msg = save_message(MessageCreate(
            chat_room_id=1,
            role="user",
            model_type="detailed",
            image_url=["https://s3.../image1.jpg"]
        ))
    """
    # 채팅방 존재 여부 확인
    room = get_chat_room_by_id(data.chat_room_id)

    if not room:
        raise ValueError(f"존재하지 않는 채팅방입니다. (chat_room_id: {data.chat_room_id})")

    message_id = execute_write(
        """
        INSERT INTO chat_messages (chat_room_id, role, content, model_type)
        VALUES (%s, %s, %s, %s)
        """,
        (data.chat_room_id, data.role, data.content, data.model_type)
    )

    # 이미지 URL → images + entity_images 저장
    for url in (data.image_url or []):
        _save_image_and_map(url, "message", message_id)

    return get_message_by_id(message_id)


def get_message_by_id(message_id: int) -> Optional[ChatMessage]:
    """
    message_id로 메시지 단건 조회.

    사용 예시:
        msg = get_message_by_id(1)
    """
    row = execute_one(
        "SELECT * FROM chat_messages WHERE message_id = %s",
        (message_id,)
    )

    if not row:
        return None

    msg = ChatMessage.from_dict(row)
    msg.image_urls = _get_image_urls("message", message_id)

    return msg


def get_messages_by_room(chat_room_id: int) -> list[ChatMessage]:
    """
    채팅방의 전체 메시지 히스토리 조회.
    - 시간 순(created_at ASC)으로 반환
    - LLM에 대화 히스토리 전달 시 사용

    사용 예시:
        messages = get_messages_by_room(1)
        # LLM 히스토리 변환
        history = [{"role": m.role, "content": m.content} for m in messages]
    """
    rows = execute_query(
        """
        SELECT * FROM chat_messages
        WHERE chat_room_id = %s
        ORDER BY created_at ASC
        """,
        (chat_room_id,)
    )

    messages = [ChatMessage.from_dict(row) for row in rows]

    # 이미지 URL 일괄 조회 (N+1 방지)
    message_ids = [m.message_id for m in messages]
    images_map  = _get_image_urls_batch("message", message_ids)

    for m in messages:
        m.image_urls = images_map.get(m.message_id, [])

    return messages


def get_latest_message_by_room(chat_room_id: int) -> Optional[ChatMessage]:
    """
    채팅방의 가장 최근 메시지 조회.
    - 채팅방 목록에서 마지막 메시지 미리보기 표시 시 사용

    사용 예시:
        latest = get_latest_message_by_room(1)
    """
    row = execute_one(
        """
        SELECT * FROM chat_messages
        WHERE chat_room_id = %s
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (chat_room_id,)
    )

    if not row:
        return None

    msg = ChatMessage.from_dict(row)
    msg.image_urls = _get_image_urls("message", msg.message_id)

    return msg


def get_messages_by_role(chat_room_id: int, role: str) -> list[ChatMessage]:
    """
    채팅방에서 특정 role의 메시지만 조회.
    - role: user / assistant / system

    사용 예시:
        # assistant 답변만 조회
        answers = get_messages_by_role(1, "assistant")
    """
    rows = execute_query(
        """
        SELECT * FROM chat_messages
        WHERE chat_room_id = %s AND role = %s
        ORDER BY created_at ASC
        """,
        (chat_room_id, role)
    )

    messages = [ChatMessage.from_dict(row) for row in rows]

    message_ids = [m.message_id for m in messages]
    images_map  = _get_image_urls_batch("message", message_ids)

    for m in messages:
        m.image_urls = images_map.get(m.message_id, [])

    return messages