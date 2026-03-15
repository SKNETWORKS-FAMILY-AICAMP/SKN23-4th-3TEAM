from typing import List
from datetime import date
from .deps import get_current_user_id
from services import analysis_service
from fastapi import APIRouter, HTTPException, Depends, Query
from db.schemas import AnalysisCreate, AnalysisResponse

"""
analysis_router.py
─────────────────────────────────────────────────────────────
엔드포인트 목록:
    POST   /analysis                       피부 분석 결과 저장
    GET    /analysis                       내 분석 히스토리 조회
    GET    /analysis/latest                가장 최근 분석 결과 조회
    GET    /analysis/check/today           오늘 정밀 분석 여부 확인
    GET    /analysis/dates                 정밀 분석 날짜 목록 조회
    GET    /analysis/by-date               날짜별 정밀 분석 결과 조회 (1~2개 날짜)
    GET    /analysis/{analysis_id}         분석 결과 단건 조회
    DELETE /analysis/{analysis_id}         분석 결과 삭제 (soft delete)
─────────────────────────────────────────────────────────────
"""

router = APIRouter(prefix="/analysis", tags=["Analysis"])

# ─────────────────────────────────────────────
# 내부 헬퍼
# ─────────────────────────────────────────────

def _analysis_to_response(result) -> AnalysisResponse:
    return AnalysisResponse(
        analysis_id   = result.analysis_id,
        user_id       = result.user_id,
        model_type    = result.model_type,
        analysis_data = result.analysis_data,
        skin_score    = result.skin_score,
        created_at    = result.created_at,
    )

# ─────────────────────────────────────────────
# 피부 분석 결과
# ─────────────────────────────────────────────

@router.post("", response_model=AnalysisResponse, status_code=201)
def save_analysis(
    body    : AnalysisCreate,
    user_id : int = Depends(get_current_user_id),
):
    """
    피부 분석 결과 저장.
    image_url과 analysis_data를 받아 DB에 저장.

    프론트 요청 예시:
        POST /analysis
        {
            "user_id": 1,
            "model_type": "simple",
            "analysis_data": { "moisture": 72, "oil": 45, "pore": 30 },
            "skin_score": 85
        }
    응답:
        { "analysis_id": 1, "user_id": 1, "model_type": "simple", ... }
    """
    if body.user_id != user_id:
        raise HTTPException(status_code=403, detail="접근 권한이 없습니다.")

    result = analysis_service.save_analysis(body)

    return _analysis_to_response(result)

@router.get("", response_model=list[AnalysisResponse])
def get_analysis_history(user_id: int = Depends(get_current_user_id)):
    """
    내 피부 분석 히스토리 전체 조회 (최신순).   (미사용-삭제 예정)

    프론트 요청 예시:
        GET /analysis
    응답:
        [ { "analysis_id": 3, ... }, { "analysis_id": 1, ... } ]
    """
    results = analysis_service.get_analysis_history(user_id)

    return [_analysis_to_response(r) for r in results]

@router.get("/latest", response_model=AnalysisResponse)
def get_latest_analysis(user_id: int = Depends(get_current_user_id)):
    """
    가장 최근 피부 분석 결과 단건 조회.         (미사용-삭제 예정)
    AI 파이프라인에서 사용자 피부 상태 컨텍스트 로드 시 활용.

    프론트 요청 예시:
        GET /analysis/latest
    응답:
        { "analysis_id": 5, "model_type": "detailed", ... }
    """
    result = analysis_service.get_latest_analysis(user_id)

    if not result:
        raise HTTPException(status_code=404, detail="분석 결과가 없습니다.")

    return _analysis_to_response(result)

@router.get("/check/today")
def check_today_detailed(user_id: int = Depends(get_current_user_id)):
    """
    오늘 정밀 분석(detailed) 수행 여부 확인.

    프론트 요청 예시:
        GET /analysis/check/today
    응답:
        { "available": true }   # 아직 분석 안 함 → 분석 가능
        { "available": false }  # 오늘 이미 분석함 → 분석 불가
    """
    return {"available": not analysis_service.has_today_detailed_analysis(user_id)}

@router.get("/dates")
def get_detailed_dates(user_id: int = Depends(get_current_user_id)):
    """
    사용자의 정밀 분석(detailed) 날짜 목록 조회 (최신순, YYYY-MM-DD).

    프론트 요청 예시:
        GET /analysis/dates
    응답:
        { "dates": ["2026-03-14", "2026-03-01", ...] }
    """
    return {"dates": analysis_service.get_detailed_dates(user_id)}

@router.get("/by-date")
def get_analysis_by_date(
    dates   : List[date] = Query(..., alias="dates", min_length=1, max_length=2, description="조회할 날짜 (1~2개, YYYY-MM-DD)"),
    user_id : int        = Depends(get_current_user_id),
):
    """
    날짜별 정밀 분석(detailed) 결과 조회.
    - 날짜 1개: 현재 분석 (단일 날짜 결과 반환)
    - 날짜 2개: 비교 분석 (두 날짜 결과 나란히 반환)
    - 해당 날짜에 결과가 없으면 null로 반환

    프론트 요청 예시:
        GET /analysis/by-date?date=2026-03-05
        GET /analysis/by-date?date=2026-03-05&date=2026-03-02
    응답:
        [
            { "date": "2026-03-05", "result": { ... } },
            { "date": "2026-03-02", "result": { ... } }
        ]
    """
    response = []

    for d in sorted(dates):
        result = analysis_service.get_detailed_by_date(user_id, str(d))
        response.append({
            "date"  : str(d),
            "result": _analysis_to_response(result) if result else None,
        })

    return response

@router.get("/model/{model_type}", response_model=list[AnalysisResponse])
def get_analysis_by_model_type(
    model_type : str,
    user_id    : int = Depends(get_current_user_id),
):
    """
    모델 타입별 분석 히스토리 조회 (최신순).

    model_type: simple / detailed

    프론트 요청 예시:
        GET /analysis/model/simple
        GET /analysis/model/detailed
    응답:
        [ { "analysis_id": 3, "model_type": "detailed", ... }, ... ]
    """
    results = analysis_service.get_analysis_by_model_type(user_id, model_type)

    return [_analysis_to_response(r) for r in results]

@router.get("/{analysis_id}", response_model=AnalysisResponse)
def get_analysis(
    analysis_id : int,
    user_id     : int = Depends(get_current_user_id),
):
    """
    분석 결과 단건 조회.    (front 작업 후 삭제 예정)

    프론트 요청 예시:
        GET /analysis/1
    """
    result = analysis_service.get_analysis_by_id(analysis_id)

    if not result:
        raise HTTPException(status_code=404, detail="분석 결과를 찾을 수 없습니다.")

    if result.user_id != user_id:
        raise HTTPException(status_code=403, detail="접근 권한이 없습니다.")

    return _analysis_to_response(result)

@router.delete("/{analysis_id}", status_code=204)
def delete_analysis(
    analysis_id : int,
    user_id     : int = Depends(get_current_user_id),
):
    """
    분석 결과 삭제 (soft delete).

    프론트 요청 예시:
        DELETE /analysis/1
    """
    result = analysis_service.get_analysis_by_id(analysis_id)

    if not result:
        raise HTTPException(status_code=404, detail="분석 결과를 찾을 수 없습니다.")

    if result.user_id != user_id:
        raise HTTPException(status_code=403, detail="접근 권한이 없습니다.")

    analysis_service.delete_analysis(analysis_id)