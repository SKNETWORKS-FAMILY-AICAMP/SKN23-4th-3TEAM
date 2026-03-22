from typing import Optional
from db.models import Qna
from db.schemas import QnaCreate, QnaUpdate, QnaAnswerUpdate
from db.db_manager import execute_query, execute_one, execute_write

"""
qna_service.py
─────────────────────────────────────────────────────────────
목적  : QnA 문의 비즈니스 로직 담당
역할  :
    1. 문의 목록 조회 (관리자: 전체 / 사용자: 본인 것만)
    2. 문의 단건 조회
    3. 문의 등록 (사용자)
    4. 답변 등록 / 수정 (관리자)
    5. 문의 삭제 (사용자 / 관리자)
─────────────────────────────────────────────────────────────
"""

# ─────────────────────────────────────────────
# 1. 문의 목록 조회
# ─────────────────────────────────────────────

def get_qna_list(user_id: int, is_admin: bool) -> list[Qna]:
    """
    문의 목록 조회.
    - 관리자: 전체 문의 목록 반환 (최신순)
    - 일반 사용자: 본인 문의 목록만 반환

    사용 예시:
        items = get_qna_list(user_id=1, is_admin=False)
    """
    if is_admin:
        rows = execute_query(
            """
            SELECT
                q.qna_id,
                q.user_id,
                q.manager_id,
                q.category,
                q.question_title,
                q.question,
                q.answer,
                q.created_at,
                q.updated_at,
                u.nickname AS nickname
            FROM qna q
            JOIN users u ON q.user_id = u.user_id
            ORDER BY q.created_at DESC
            """,
            ()
        )
    else:
        rows = execute_query(
            """
            SELECT
                q.qna_id,
                q.user_id,
                q.manager_id,
                q.category,
                q.question_title,
                q.question,
                q.answer,
                q.created_at,
                q.updated_at,
                u.nickname
            FROM qna q
            JOIN users u ON q.user_id = u.user_id
            WHERE q.user_id = %s
            ORDER BY q.created_at DESC
            """,
            (user_id,)
        )

    return [Qna.from_dict(row) for row in rows]


# ─────────────────────────────────────────────
# 2. 문의 단건 조회
# ─────────────────────────────────────────────

def get_qna_by_id(qna_id: int) -> Optional[Qna]:
    """
    qna_id로 문의 단건 조회.
    존재하지 않으면 None 반환.

    사용 예시:
        qna = get_qna_by_id(3)
    """
    row = execute_one(
        """
        SELECT
            q.qna_id,
            q.user_id,
            q.manager_id,
            q.category,
            q.question_title,
            q.question,
            q.answer,
            q.created_at,
            q.updated_at,
            u.nickname
        FROM qna q
        JOIN users u ON q.user_id = u.user_id
        WHERE q.qna_id = %s
        """,
        (qna_id,)
    )

    if not row:
        return None

    return Qna.from_dict(row)


# ─────────────────────────────────────────────
# 3. 문의 등록 (사용자)
# ─────────────────────────────────────────────

def create_qna(user_id: int, data: QnaCreate) -> Qna:
    """
    새 문의 등록.
    - 사용자 본인의 user_id로 등록
    - category, question_title, question 저장
    """
    qna_id = execute_write(
        """
        INSERT INTO qna (user_id, category, question_title, question)
        VALUES (%s, %s, %s, %s)
        """,
        (user_id, data.category, data.question_title, data.question)
    )
    qna = get_qna_by_id(qna_id)

    if not qna:
        raise RuntimeError("문의 등록 후 조회에 실패했습니다.")

    return qna

def update_qna(qna_id: int, user_id: int, is_admin: bool, data: QnaUpdate) -> Qna:
    qna = get_qna_by_id(qna_id)

    if not qna:
        raise ValueError("해당 문의를 찾을 수 없습니다.")

    if not is_admin and qna.user_id != user_id:
        raise ValueError("본인 문의만 수정할 수 있습니다.")

    if qna.answer:
        raise ValueError("답변이 등록된 문의는 수정할 수 없습니다.")

    affected = execute_write(
        """
        UPDATE qna
        SET category = %s,
            question_title = %s,
            question = %s
        WHERE qna_id = %s
        """,
        (data.category, data.question_title, data.question, qna_id)
    )

    if not affected:
        raise RuntimeError("문의 수정에 실패했습니다.")

    updated = get_qna_by_id(qna_id)

    if not updated:
        raise RuntimeError("문의 수정 후 조회에 실패했습니다.")

    return updated

# ─────────────────────────────────────────────
# 4. 답변 등록 / 수정 (관리자)
# ─────────────────────────────────────────────

def answer_qna(qna_id: int, manager_id: int, data: QnaAnswerUpdate) -> Qna:
    """
    관리자가 문의에 답변 등록 또는 수정.
    - manager_id: 답변한 관리자 user_id
    - answer: 답변 내용

    사용 예시:
        qna = answer_qna(qna_id=3, manager_id=2, data=QnaAnswerUpdate(answer="답변입니다."))
    """
    affected = execute_write(
        """
        UPDATE qna
        SET manager_id = %s, answer = %s
        WHERE qna_id = %s
        """,
        (manager_id, data.answer, qna_id)
    )

    if not affected:
        raise ValueError("해당 문의를 찾을 수 없습니다.")

    qna = get_qna_by_id(qna_id)

    if not qna:
        raise RuntimeError("답변 등록 후 조회에 실패했습니다.")

    return qna

# ─────────────────────────────────────────────
# 5. 문의 삭제 (사용자 / 관리자)
# ─────────────────────────────────────────────

def delete_qna(qna_id: int, user_id: int, is_admin: bool) -> bool:
    """
    문의 삭제.
    - 관리자: 모든 문의 삭제 가능
    - 일반 사용자: 본인 문의만 삭제 가능
    - 삭제 성공 시 True, 대상 없으면 False 반환

    사용 예시:
        success = delete_qna(qna_id=3, user_id=1, is_admin=False)
    """
    if is_admin:
        affected = execute_write(
            "DELETE FROM qna WHERE qna_id = %s",
            (qna_id,)
        )
    else:
        affected = execute_write(
            "DELETE FROM qna WHERE qna_id = %s AND user_id = %s",
            (qna_id, user_id)
        )

    return affected > 0