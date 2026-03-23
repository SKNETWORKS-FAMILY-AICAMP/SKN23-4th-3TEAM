# back/routers/skin_mbti_router.py
import os
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, field_validator
from typing import List
from .deps import get_current_user_id

from services.skin_mbti_service import calculate_mbti, get_saved_mbti_result, create_skin_mbti_share_link, get_shared_skin_mbti_result


router = APIRouter(
    prefix="/skin-mbti",
    tags=["Skin MBTI"],
)

FRONT_BASE_URL = os.getenv("FRONT_BASE_URL", "http://localhost:5173")

# ────────────────────────────────────────────
# Request 스키마
# ────────────────────────────────────────────
class SkinMbtiRequest(BaseModel):
    user_id: int
    answers: List[str]  # 12개, 각 값은 A/B/C/D

    @field_validator("answers")
    @classmethod
    def validate_answers(cls, v):
        if len(v) != 12:
            raise ValueError("answers는 반드시 12개여야 합니다.")
        valid = {"A", "B", "C", "D"}
        for i, ans in enumerate(v):
            if ans.upper() not in valid:
                raise ValueError(
                    f"Q{i + 1}의 답변은 A, B, C, D 중 하나여야 합니다. (받은 값: {ans})"
                )
        return [a.upper() for a in v]


# ────────────────────────────────────────────
# 엔드포인트
# ────────────────────────────────────────────
@router.post("")
def get_skin_mbti(req: SkinMbtiRequest):
    """
    피부 MBTI 결과 계산 + DB 저장

    [Request]
    {
        "user_id": 1,
        "answers": ["A","C","B","A","D","C","B","A","C","A","B","D"]
    }

    [Response]
    {
        "success": true,
        "data": {
            "mbti_code": "SBC",
            "result": {
                "code": "SBC",
                "title": "포근포근 보송가나디",
                "subtitle": "기본 보습형",
                "description": "...",
                "habits": "...",
                "morning_routine": [...],
                "night_routine": [...],
                "care_tips": [...],
                "avoid_habits": [...],
                "chatbot_suggestion": "...",
                "image_asset": "assets/images/skin_mbti/cozy_soft_dog.png",
                "background_color": "0xFFF4E6D4",
                "accent_color": "0xFF9B7B52"
            },
            "score": {"S": 3, "L": 1, "B": 4, "T": 0, "C": 2, "F": 2}
        },
        "error": null
    }
    """
    try:
        result = calculate_mbti(req.answers, req.user_id)
        return {"success": True, "data": result, "error": None}
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
# ────────────────────────────────────────────
# MBTI 저장 결과 읽기
# ────────────────────────────────────────────
@router.get("/{user_id}")
def read_skin_mbti(user_id: int):
    try:
        result = get_saved_mbti_result(user_id)
        # print("[skin_mbti] GET result =", result)

        return {
            "success": True,
            "data": result,
            "error": None,
        }
    except Exception as e:
        print("[skin_mbti] GET error =", repr(e))
        raise HTTPException(status_code=500, detail=str(e))

# ────────────────────────────────────────────
# MBTI 공유 링크 생성
# ────────────────────────────────────────────
@router.post("/share/{result_id}")
def share_skin_mbti(
    result_id: int,
    user_id: int = Depends(get_current_user_id),
):
    try:
        result = create_skin_mbti_share_link(
            result_id=result_id,
            user_id=user_id,
            front_base_url=FRONT_BASE_URL,
        )

        if not result:
            raise HTTPException(status_code=404, detail="MBTI 결과를 찾을 수 없습니다.")

        return {
            "success": True,
            "data": result,
            "error": None,
        }
    except HTTPException:
        raise
    except Exception as e:
        print("[skin_mbti] SHARE error =", repr(e))
        raise HTTPException(status_code=500, detail=str(e))


# ────────────────────────────────────────────
# 공유된 MBTI 결과 읽기
# ────────────────────────────────────────────
@router.get("/shared/{share_token}")
def read_shared_skin_mbti(share_token: str):
    try:
        result = get_shared_skin_mbti_result(share_token)

        if not result:
            raise HTTPException(status_code=404, detail="공유된 MBTI 결과를 찾을 수 없습니다.")

        return {
            "success": True,
            "data": result,
            "error": None,
        }
    except HTTPException:
        raise
    except Exception as e:
        print("[skin_mbti] SHARED GET error =", repr(e))
        raise HTTPException(status_code=500, detail=str(e))   