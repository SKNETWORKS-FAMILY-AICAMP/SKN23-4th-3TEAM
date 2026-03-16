import json

from typing import Optional
from datetime import datetime

from db.models import SkinAnalysisResult, Wishlist
from db.schemas import AnalysisCreate, WishlistAdd
from db.db_manager import execute_one, execute_write, execute_query

# ─────────────────────────────────────────────
# 이미지 헬퍼 (images + entity_images)
# ─────────────────────────────────────────────

def _get_image_urls(entity_type: str, entity_id: int) -> list[str]:
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
analysis_service.py
─────────────────────────────────────────────────────────────
목적  : 피부 분석 결과 관련 비즈니스 로직 담당
역할  :
    1. 피부 분석 결과 저장
    2. 분석 결과 단건 조회
    3. 사용자의 분석 히스토리 전체 조회
    4. 가장 최근 분석 결과 조회
    5. 분석 결과 삭제 (soft delete)
    6. 위시리스트 추가 / 조회 / 삭제

흐름:
    FastAPI 라우터 → analysis_service 함수 호출
                    → db_manager 헬퍼로 DB 접근
                    → models.SkinAnalysisResult / Wishlist 로 변환 후 반환
─────────────────────────────────────────────────────────────
"""

# ─────────────────────────────────────────────
# 1. 피부 분석 결과 저장
# ─────────────────────────────────────────────

def save_analysis(data: AnalysisCreate) -> SkinAnalysisResult:
    """
    피부 분석 결과 저장.
    - analysis_data (dict) → JSON 문자열 변환 후 저장
    - image_urls가 있으면 images + entity_images 테이블에 저장

    사용 예시:
        result = save_analysis(AnalysisCreate(
            user_id       = 1,
            model_type    = "simple",
            analysis_data = {"moisture": 72, "oil": 45, "pore": 30},
            skin_score    = 85,
            image_urls    = ["https://s3.../image1.jpg"],
        ))
    """
    analysis_data_json = json.dumps(data.analysis_data, ensure_ascii=False)

    analysis_id = execute_write(
        """
        INSERT INTO skin_analysis_results (user_id, model_type, analysis_data, skin_score)
        VALUES (%s, %s, %s, %s)
        """,
        (data.user_id, data.model_type, analysis_data_json, data.skin_score)
    )

    # 이미지 URL → images + entity_images 저장
    # 동일 URL이 이미 images 테이블에 존재하면 재사용 (중복 저장 방지)
    for url in (data.image_url or []):
        existing = execute_one(
            "SELECT image_id FROM images WHERE image_url = %s LIMIT 1",
            (url,)
        )
        image_id = existing["image_id"] if existing else execute_write(
            "INSERT INTO images (image_url) VALUES (%s)",
            (url,)
        )

        execute_write(
            "INSERT INTO entity_images (image_id, entity_type, entity_id) VALUES (%s, %s, %s)",
            (image_id, "analysis", analysis_id)
        )

    return get_analysis_by_id(analysis_id)

# ─────────────────────────────────────────────
# 2. 피부 분석 결과 조회
# ─────────────────────────────────────────────

def get_analysis_by_id(analysis_id: int) -> Optional[SkinAnalysisResult]:
    """
    analysis_id로 분석 결과 단건 조회
    삭제된 결과는 반환하지 않음 (soft delete 고려).

    사용 예시:
        result = get_analysis_by_id(1)
    """
    row = execute_one(
        """
        SELECT * FROM skin_analysis_results
        WHERE analysis_id = %s AND deleted_at IS NULL
        """,
        (analysis_id,)
    )

    if not row:
        return None

    result = SkinAnalysisResult.from_dict(row)
    result.image_urls = _get_image_urls("analysis", analysis_id)

    return result

def get_analysis_history(user_id: int) -> list[SkinAnalysisResult]:
    """
    사용자의 전체 피부 분석 히스토리 조회
    최신 순(created_at DESC)으로 반환.

    사용 예시:
        history = get_analysis_history(1)
    """
    rows = execute_query(
        """
        SELECT * FROM skin_analysis_results
        WHERE user_id = %s AND deleted_at IS NULL
        ORDER BY created_at DESC
        """,
        (user_id,)
    )

    results    = [SkinAnalysisResult.from_dict(row) for row in rows]
    ids        = [r.analysis_id for r in results]
    images_map = _get_image_urls_batch("analysis", ids)

    for r in results:
        r.image_urls = images_map.get(r.analysis_id, [])

    return results

def get_latest_analysis(user_id: int) -> Optional[SkinAnalysisResult]:
    """
    사용자의 가장 최근 피부 분석 결과 조회.
    - LLM에 최근 피부 상태 컨텍스트 전달 시 사용
    - 분석 결과가 없으면 None 반환

    사용 예시:
        latest = get_latest_analysis(1)
        if latest:
            skin_context = latest.analysis_data
    """
    row = execute_one(
        """
        SELECT * FROM skin_analysis_results
        WHERE user_id = %s AND deleted_at IS NULL
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (user_id,)
    )
    if not row:
        return None

    result = SkinAnalysisResult.from_dict(row)
    result.image_urls = _get_image_urls("analysis", result.analysis_id)

    return result

def get_detailed_dates(user_id: int) -> list[str]:
    """
    사용자의 정밀 분석(detailed) 결과가 존재하는 날짜 목록 조회.
    최신순으로 반환하며, YYYY-MM-DD 형식 문자열 리스트.

    사용 예시:
        dates = get_detailed_dates(1)
        # ["2026-03-14", "2026-03-01", ...]
    """
    rows = execute_query(
        """
        SELECT DISTINCT DATE_FORMAT(created_at, '%%Y-%%m-%%d') AS date
        FROM skin_analysis_results
        WHERE user_id = %s
          AND model_type = 'detailed'
          AND deleted_at IS NULL
        ORDER BY date DESC
        """,
        (user_id,)
    )

    return [row["date"] for row in rows]


def get_detailed_by_date(user_id: int, date: str) -> Optional[SkinAnalysisResult]:
    """
    특정 날짜의 정밀 분석(detailed) 결과 조회.

    사용 예시:
        result = get_detailed_by_date(1, "2026-03-05")
    """
    row = execute_one(
        """
        SELECT * FROM skin_analysis_results
        WHERE user_id = %s
          AND model_type = 'detailed'
          AND DATE(created_at) = %s
          AND deleted_at IS NULL
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (user_id, date)
    )

    if not row:
        return None

    result = SkinAnalysisResult.from_dict(row)
    result.image_urls = _get_image_urls("analysis", result.analysis_id)

    return result


def has_today_detailed_analysis(user_id: int) -> bool:
    """
    오늘 날짜에 정밀 분석(detailed) 결과가 있는지 확인.

    사용 예시:
        done = has_today_detailed_analysis(1)
        if done:
            raise HTTPException(400, "오늘 이미 정밀 분석을 진행했습니다.")
    """
    row = execute_one(
        """
        SELECT analysis_id FROM skin_analysis_results
        WHERE user_id = %s
          AND model_type = 'detailed'
          AND DATE(created_at) = CURDATE()
          AND deleted_at IS NULL
        LIMIT 1
        """,
        (user_id,)
    )

    return row is not None

def get_analysis_by_model_type(
    user_id: int,
    model_type: str
) -> list[SkinAnalysisResult]:
    """
    모델 타입별 분석 히스토리 조회.
    - model_type: simple / detailed

    사용 예시:
        detailed_results = get_analysis_by_model_type(1, "detailed")
    """
    rows = execute_query(
        """
        SELECT * FROM skin_analysis_results
        WHERE user_id = %s AND model_type = %s AND deleted_at IS NULL
        ORDER BY created_at DESC
        """,
        (user_id, model_type)
    )

    results    = [SkinAnalysisResult.from_dict(row) for row in rows]
    ids        = [r.analysis_id for r in results]
    images_map = _get_image_urls_batch("analysis", ids)

    for r in results:
        r.image_urls = images_map.get(r.analysis_id, [])

    return results

# ─────────────────────────────────────────────
# 3. 피부 분석 결과 삭제
# ─────────────────────────────────────────────

def delete_analysis(analysis_id: int) -> bool:
    """
    피부 분석 결과 삭제 (soft delete).
    - deleted_at에 현재 시각 기록

    사용 예시:
        success = delete_analysis(1)
    """
    affected = execute_write(
        """
        UPDATE skin_analysis_results
        SET deleted_at = %s
        WHERE analysis_id = %s AND deleted_at IS NULL
        """,
        (datetime.now(), analysis_id)
    )

    return affected > 0

# ─────────────────────────────────────────────
# 4. 위시리스트
# ─────────────────────────────────────────────

def add_to_wishlist(data: WishlistAdd) -> Wishlist:
    """
    위시리스트에 제품 추가.

    사용 예시:
        wish = add_to_wishlist(WishlistAdd(
            user_id      = 1,
            product_name = "라로슈포제 시카플라스트 밤 B5",
            message_id   = 10,
            product_url  = "https://..."
        ))
    """
    wish_id = execute_write(
        """
        INSERT INTO wishlist
            (user_id, message_id, product_name, product_url)
        VALUES (%s, %s, %s, %s)
        """,
        (
            data.user_id,
            data.message_id,
            data.product_name,
            data.product_url,
        )
    )

    return get_wishlist_item_by_id(wish_id)

def get_wishlist_item_by_id(wish_id: int) -> Optional[Wishlist]:
    """
    wish_id로 위시리스트 단건 조회.

    사용 예시:
        item = get_wishlist_item_by_id(1)
    """
    row = execute_one(
        "SELECT * FROM wishlist WHERE wish_id = %s",
        (wish_id,)
    )

    return Wishlist.from_dict(row) if row else None

def get_wishlist_by_user(user_id: int) -> list[Wishlist]:
    """
    사용자의 전체 위시리스트 조회.
    최신 순(added_at DESC)으로 반환.

    사용 예시:
        items = get_wishlist_by_user(1)
    """
    rows = execute_query(
        """
        SELECT * FROM wishlist
        WHERE user_id = %s
        ORDER BY wish_id DESC
        """,
        (user_id,)
    )

    return [Wishlist.from_dict(row) for row in rows]

def remove_from_wishlist(wish_id: int, user_id: int) -> bool:
    """
    위시리스트에서 제품 삭제 (hard delete).
    - user_id 검증으로 본인 항목만 삭제 가능

    사용 예시:
        success = remove_from_wishlist(wish_id=1, user_id=1)
    """
    affected = execute_write(
        """
        DELETE FROM wishlist
        WHERE wish_id = %s AND user_id = %s
        """,
        (wish_id, user_id)
    )

    return affected > 0

def remove_all_wishlist(user_id: int) -> bool:
    """
    사용자의 위시리스트 전체 삭제.

    사용 예시:
        success = remove_all_wishlist(user_id=1)
    """
    affected = execute_write(
        "DELETE FROM wishlist WHERE user_id = %s",
        (user_id,)
    )

    return affected > 0
