from services import qna_service
from services import user_service
from db.schemas import QnaCreate, QnaAnswerUpdate, QnaResponse
from .deps import get_current_user_id
from fastapi import APIRouter, HTTPException, Depends

"""
qna_router.py
─────────────────────────────────────────────────────────────
엔드포인트 목록:
    GET    /qna                문의 목록 조회
                                - 관리자: 전체 문의 목록
                                - 사용자: 본인 문의 목록
    POST   /qna                문의 등록 (사용자)
    PATCH  /qna/{qna_id}       답변 등록 / 수정 (관리자 전용)
    DELETE /qna/{qna_id}       문의 삭제
                                - 관리자: 모든 문의 삭제 가능
                                - 사용자: 본인 문의만 삭제 가능
─────────────────────────────────────────────────────────────
"""

router = APIRouter(prefix="/qna", tags=["QnA"])

# ─────────────────────────────────────────────
# 내부 헬퍼
# ─────────────────────────────────────────────

def _to_response(qna) -> QnaResponse:
    return QnaResponse(
        qna_id     = qna.qna_id,
        user_id    = qna.user_id,
        manager_id = qna.manager_id,
        category   = qna.category,
        question   = qna.question,
        answer     = qna.answer,
        created_at = qna.created_at,
        updated_at = qna.updated_at,
    )

# ─────────────────────────────────────────────
# 문의 목록 조회
# ─────────────────────────────────────────────

@router.get("", response_model=list[QnaResponse])
def get_qna_list(user_id: int = Depends(get_current_user_id)):
    """
    문의 목록 조회.
    - 관리자(is_admin=True): 전체 문의 목록 반환
    - 일반 사용자: 본인 문의 목록만 반환

    프론트 요청 예시:
        GET /qna
        Headers: { Authorization: "Bearer <token>" }

    응답 예시 (사용자):
        [ { "qna_id": 1, "question": "...", "answer": null, ... }, ... ]
    응답 예시 (관리자):
        [ { "qna_id": 1, "user_id": 3, "question": "...", "answer": "...", ... }, ... ]
    """
    user = user_service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    items = qna_service.get_qna_list(user_id, is_admin=user.is_admin)

    return [_to_response(q) for q in items]


# ─────────────────────────────────────────────
# 문의 등록 (사용자)
# ─────────────────────────────────────────────

@router.post("", response_model=QnaResponse, status_code=201)
def create_qna(
    body    : QnaCreate,
    user_id : int = Depends(get_current_user_id),
):
    """
    문의 등록 (사용자 전용).

    프론트 요청 예시:
        POST /qna
        Headers: { Authorization: "Bearer <token>" }
        {
            "category": "서비스 이용",
            "question": "피부 분석 결과가 저장되지 않아요."
        }
    응답:
        { "qna_id": 5, "user_id": 1, "category": "서비스 이용", "question": "...", "answer": null, ... }
    """
    try:
        qna = qna_service.create_qna(user_id, body)
    except (ValueError, RuntimeError) as e:
        raise HTTPException(status_code=400, detail=str(e))

    return _to_response(qna)


# ─────────────────────────────────────────────
# 답변 등록 / 수정 (관리자 전용)
# ─────────────────────────────────────────────

@router.patch("/{qna_id}", response_model=QnaResponse)
def answer_qna(
    qna_id  : int,
    body    : QnaAnswerUpdate,
    user_id : int = Depends(get_current_user_id),
):
    """
    문의 답변 등록 또는 수정 (관리자 전용).
    - is_admin=False인 사용자가 호출하면 403 반환

    프론트 요청 예시:
        PATCH /qna/5
        Headers: { Authorization: "Bearer <token>" }
        { "answer": "확인 후 조치하겠습니다." }
    응답:
        { "qna_id": 5, "answer": "확인 후 조치하겠습니다.", ... }
    """
    user = user_service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    if not user.is_admin:
        raise HTTPException(status_code=403, detail="관리자만 답변을 등록할 수 있습니다.")

    try:
        qna = qna_service.answer_qna(qna_id, manager_id=user_id, data=body)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return _to_response(qna)

# ─────────────────────────────────────────────
# 문의 삭제 (사용자 본인 / 관리자)
# ─────────────────────────────────────────────

@router.delete("/{qna_id}", status_code=204)
def delete_qna(
    qna_id  : int,
    user_id : int = Depends(get_current_user_id),
):
    """
    문의 삭제.
    - 일반 사용자: 본인 문의만 삭제 가능
    - 관리자: 모든 문의 삭제 가능
    - 삭제 실패 시 404 반환

    프론트 요청 예시:
        DELETE /qna/5
        Headers: { Authorization: "Bearer <token>" }
    """
    user = user_service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")

    success = qna_service.delete_qna(qna_id, user_id, is_admin=user.is_admin)

    if not success:
        raise HTTPException(status_code=404, detail="문의를 찾을 수 없습니다.")