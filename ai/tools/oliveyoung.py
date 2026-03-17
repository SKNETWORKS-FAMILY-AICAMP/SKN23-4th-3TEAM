"""
oliveyoung.py - Tavily로 올리브영을 직접 검색합니다.

[핵심 변경사항]
기존: 벡터DB 제품 → 올리브영 존재 여부 검증 (느리고 미스매치 많음)
변경: 사용자 피부 맥락 → 올리브영 직접 검색 → 실제 판매 제품 반환

핵심 함수:
- search_products_for_context(): 피부타입/고민 기반으로 올리브영 직접 검색
- check_product(): 특정 제품명이 올리브영에 있는지 확인 (기존 게이트용, 하위호환)
"""
import re
import html
import requests
import time as _time
from functools import lru_cache
from typing import Optional

from ai.config.settings import TAVILY_API_KEY


# 공통 유틸

def _tavily_search(query: str, max_results: int = 5) -> list[dict]:
    """Tavily API 호출"""
    if not TAVILY_API_KEY:
        print("[oliveyoung] TAVILY_API_KEY 없음 → 검색 스킵", flush=True)
        return []
    try:
        print(f"[oliveyoung] Tavily 검색: {query}", flush=True)
        r = requests.post(
            "https://api.tavily.com/search",
            json={
                "api_key": TAVILY_API_KEY,
                "query": query,
                "max_results": max_results,
                "include_domains": ["oliveyoung.co.kr"],
            },
            timeout=10,
        )
        r.raise_for_status()
        results = r.json().get("results", [])
        print(f"[oliveyoung] 검색 결과 {len(results)}개", flush=True)
        return results
    except Exception as e:
        print(f"[oliveyoung] Tavily 검색 실패: {e}", flush=True)
        return []


def _is_product_url(url: str) -> bool:
    """올리브영 제품 상세 페이지 URL인지 확인"""
    return bool(
        url
        and "oliveyoung.co.kr" in url
        and ("goods" in url or "product" in url or "/G.do" in url)
    )


def _clean_url(url: str) -> str:
    """URL 정리 - HTML 엔티티 디코딩 + 트래킹 파라미터 제거"""
    url = html.unescape(url)
    match = re.search(r'goodsNo=([A-Za-z0-9]+)', url)
    if match:
        return f"https://www.oliveyoung.co.kr/store/goods/getGoodsDetail.do?goodsNo={match.group(1)}"
    return url


def _extract_display_name(result: dict) -> str:
    """Tavily 결과 title에서 올리브영 제품명 추출"""
    title = result.get("title", "")
    for sep in [" | ", " - ", " :: ", " : "]:
        if sep in title:
            parts = title.split(sep)
            clean = [p for p in parts if "올리브영" not in p and "oliveyoung" not in p.lower()]
            if clean:
                title = clean[0].strip()
                break
    # 앞에 붙는 [태그] 제거: "[모공탄력세럼] 바이오힐 보..." → "바이오힐 보..."
    title = re.sub(r'^\[.*?\]\s*', '', title).strip()
    # 말줄임표(...) 이후 잘린 경우 제거
    title = re.sub(r'\s*\.\.\.$', '', title).strip()
    return title


# 스킨케어 무관 카테고리 키워드 필터
# 올리브영에서 "민감성 진정 크림" 검색 시 제모크림 등이 걸릴 수 있음
_NON_SKINCARE_KW = [
    "제모", "바디워시", "바디로션", "바디크림", "바디오일", "바디스크럽",
    "헤어", "샴푸", "린스", "트리트먼트", "헤어팩",
    "립밤", "립글로스", "립스틱", "파운데이션", "쿠션", "비비크림",
    "블러셔", "하이라이터", "마스카라", "아이라이너", "아이섀도",
    "네일", "향수", "탈취제", "구강",
]


def _is_skincare_product(display_name: str) -> bool:
    """스킨케어(얼굴 관리) 제품인지 확인. 바디/헤어/메이크업 등은 False."""
    name_lower = display_name.lower()
    return not any(kw in name_lower for kw in _NON_SKINCARE_KW)





def _result_to_product(item: dict) -> dict | None:
    """Tavily 결과 하나를 product dict로 변환"""
    url = item.get("url", "")
    if not _is_product_url(url):
        return None
    display_name = _extract_display_name(item)
    if not display_name:
        return None
    return {
        "name": display_name,
        "display_name": display_name,
        "why": "",            # LLM이 채워줌
        "oliveyoung_url": _clean_url(url),
        "evidence_source_id": "",
    }


# 핵심 함수 1: 피부 맥락 기반 올리브영 직접 검색

# 고민 → 올리브영 검색 키워드 (짧고 직접적인 상품명 스타일)
_CONCERN_QUERY = {
    "여드름": "여드름 세럼",
    "트러블": "트러블 케어",
    "홍조": "홍조 진정 크림",
    "모공": "모공 케어",
    "각질": "각질 케어",
    "주름": "주름 개선 크림",
    "미백": "미백 세럼",
    "잡티": "잡티 세럼",
    "기미": "기미 미백 크림",
    "탄력": "탄력 크림",
    "수분": "수분 크림",
    "건조": "보습 크림",
    "번들": "피지 오일 컨트롤",
    "피지": "피지 오일 컨트롤",
    "블랙헤드": "블랙헤드 모공",
    "붉은기": "홍조 진정 크림",
    "붉어": "홍조 진정 크림",
}

# 제품 카테고리 → 검색 키워드
# ⚠️ 순서 중요: 구체적 키워드(선크림, 수분크림)가 일반 키워드(크림)보다 앞에 와야 함
#    "크림" in "선크림" → True 이므로, "선크림"을 먼저 매칭해야 함
_PRODUCT_TYPE_QUERY = {
    "수분크림": "수분 크림",
    "보습크림": "보습 크림",
    "선크림": "선크림",
    "아이크림": "아이크림",
    "젤크림": "젤크림",
    "클렌징오일": "클렌징 오일",
    "클렌징 오일": "클렌징 오일",
    "클렌징밤": "클렌징 밤",
    "폼클렌징": "폼 클렌저",
    "폼 클렌징": "폼 클렌저",
    "폼클렌저": "폼 클렌저",
    "크림": "크림",
    "세럼": "세럼",
    "에센스": "에센스",
    "토너": "토너 스킨",
    "클렌저": "폼 클렌저",
    "클렌징": "폼 클렌저",
    "세안": "폼 클렌저",
    "세안제": "폼 클렌저",
    "마스크": "마스크팩",
    "로션": "로션",
    "앰플": "앰플",
    "미스트": "미스트",
    "필링": "필링 패드",
    "패드": "패드",
    "오일": "클렌징 오일",
    "밤": "클렌징 밤",
}

# 피부타입 → 검색 키워드 (단독으로는 잘 안 씀, 고민 없을 때 폴백용)
_SKIN_TYPE_QUERY = {
    "건성": "건성 보습 크림",
    "지성": "지성 수분 세럼",
    "복합성": "복합성 수분 크림",
    "복합": "복합성 수분 크림",
    "민감성": "민감성 진정 크림",
    "민감": "민감성 진정 크림",
    "중성": "수분 크림",
}


def _build_oliveyoung_query(
    user_text: str,
    user_profile: dict | None,
    product_type_hint: str = "",
    chat_history: list | None = None,
    detected_keywords: dict | None = None,
) -> str:
    """
    피부 맥락 + 유저 질문에서 올리브영 검색 쿼리를 만듭니다.

    전략:
    0. LLM 라우터가 추출한 detected_keywords가 있으면 우선 사용
    1. 제품 카테고리 먼저 추출 (폼클렌징, 세럼, 크림 등)
    2. 피부타입 / 고민 키워드 추출
    3. "피부타입/고민 + 카테고리" 조합으로 쿼리 생성
       예: "지성 피부 폼 클렌저", "홍조 진정 크림"
    """
    # LLM 키워드 우선 사용 (브랜드는 단독 검색, 그 외는 피부 맥락 조합)
    if detected_keywords:
        brand = detected_keywords.get("brand", "")
        ingredient = detected_keywords.get("ingredient", "")
        category = detected_keywords.get("category", "")

        # 브랜드가 있으면 브랜드 중심 검색 (피부타입 불필요)
        if brand:
            parts = ["올리브영", brand]
            if category:
                parts.append(category)
            direct_query = " ".join(parts)
            print(f"[oliveyoung] LLM 키워드 검색 (브랜드): '{direct_query}'", flush=True)
            return direct_query

        # 브랜드 없이 성분/카테고리만 있으면 피부 맥락을 조합
        if ingredient or category:
            parts = []
            # 피부 맥락: user_text 피부타입 > 프로필 고민(_CONCERN_QUERY 매핑) > 프로필 피부타입
            text_lower = (user_text or "").lower()
            text_skin_type = ""
            for st in ("건성", "지성", "복합성", "민감성", "중성"):
                if st in text_lower:
                    text_skin_type = st
                    break

            if text_skin_type:
                parts.append(text_skin_type)
            elif user_profile:
                concern = user_profile.get("skin_concern") or ""
                skin_type = user_profile.get("skin_type_label") or ""
                if concern:
                    # 기존 로직과 동일하게 _CONCERN_QUERY 매핑 적용
                    first_concern = concern.split(",")[0].strip()
                    concern_mapped = _CONCERN_QUERY.get(first_concern, first_concern)
                    parts.append(concern_mapped)
                elif skin_type:
                    parts.append(skin_type)
            if ingredient:
                parts.append(ingredient)
            if category:
                parts.append(category)
            direct_query = " ".join(parts)
            print(f"[oliveyoung] LLM 키워드 검색: '{direct_query}'", flush=True)
            return direct_query
    # LLM 키워드 없으면 기존 하드코딩 로직 (폴백)

    # 0. 채팅 히스토리에서 성분/브랜드/카테고리 맥락 추출 (팔로우업 대화 지원)
    _HISTORY_INGREDIENT_KW = [
        "히알루론산", "나이아신아마이드", "레티놀", "비타민c", "비타민C",
        "세라마이드", "판테놀", "살리실산", "글리콜산", "아젤라산",
        "티트리", "센텔라", "마데카소사이드", "알부틴", "트라넥삼산",
        "스쿠알란", "콜라겐", "펩타이드", "아스코르빈산",
        "bha", "aha", "pha", "cica", "시카",
    ]
    _HISTORY_BRAND_KW = [
        "토리든", "닥터지", "라로슈포제", "이니스프리", "아로마티카",
        "코스알엑스", "스킨1004", "셀퓨전씨", "라운드랩", "넘버즈",
        "에스트라", "비플레인", "메디힐", "아누아", "달바",
        "바이오힐보", "CNP", "cnp", "VT", "vt",
    ]
    history_ingredient = None
    history_brand = None
    history_category = None
    if chat_history:
        # 최근 6개 메시지에서 사용자 발화만 확인
        recent_user_msgs = [
            (m.get("content") or "").lower()
            for m in chat_history[-6:]
            if m.get("role") == "user"
        ]
        recent_user_texts = " ".join(recent_user_msgs)
        history_ingredient = next(
            (kw for kw in _HISTORY_INGREDIENT_KW if kw.lower() in recent_user_texts), None
        )
        history_brand = next(
            (kw for kw in _HISTORY_BRAND_KW if kw.lower() in recent_user_texts), None
        )
        # 히스토리에서 카테고리 추출: 가장 최근 메시지부터 역순으로 탐색
        # "선크림 추천해줘" → "세럼도 추천해줘" 순서면 "세럼"이 최신
        for msg_text in reversed(recent_user_msgs):
            for key, val in _PRODUCT_TYPE_QUERY.items():
                if key in msg_text:
                    history_category = val
                    break
            if history_category:
                break
        if history_ingredient:
            print(f"[oliveyoung] 대화 맥락에서 성분 감지: '{history_ingredient}'", flush=True)
        if history_brand:
            print(f"[oliveyoung] 대화 맥락에서 브랜드 감지: '{history_brand}'", flush=True)
        if history_category:
            print(f"[oliveyoung] 대화 맥락에서 카테고리 감지: '{history_category}'", flush=True)

    # 0-1. 현재 입력에서 성분/브랜드 감지
    text_lower = (user_text or "").lower()
    current_ingredient = next(
        (kw for kw in _HISTORY_INGREDIENT_KW if kw.lower() in text_lower), None
    )
    current_brand = next(
        (kw for kw in _HISTORY_BRAND_KW if kw.lower() in text_lower), None
    )

    # 리스트에 없는 브랜드도 감지: "XX 제품 추천해줘", "XX 추천해줘" 패턴
    if not current_brand and not current_ingredient:
        import re as _re
        _BRAND_PATTERN = _re.compile(
            r'^([\w가-힣]+)\s*(?:제품|추천|좋은거|뭐가|어떤)', flags=_re.UNICODE
        )
        m = _BRAND_PATTERN.match((user_text or "").strip())
        if m:
            candidate = m.group(1).strip()
            # 피부타입/고민 키워드가 아닌 경우에만 브랜드로 인식
            _NON_BRAND = {"건성", "지성", "복합성", "민감성", "중성", "여드름", "홍조",
                          "모공", "각질", "주름", "탄력", "수분", "보습", "미백", "트러블"}
            if candidate and candidate not in _NON_BRAND and len(candidate) >= 2:
                current_brand = candidate
                print(f"[oliveyoung] 패턴 기반 브랜드 감지: '{current_brand}'", flush=True)

    # 현재 입력에서 카테고리 감지
    current_category = None
    for key, val in _PRODUCT_TYPE_QUERY.items():
        if key in user_text:
            current_category = val
            break

    # 0-2. 성분/브랜드 직접 검색 쿼리 생성
    # 규칙: 현재 입력에 브랜드가 있으면 브랜드 중심 검색 (히스토리 성분/브랜드 무시)
    #        현재 입력에 성분만 있으면 성분 + 카테고리
    #        현재 입력에 둘 다 없으면 히스토리에서 보조
    if current_brand or current_ingredient:
        parts = []
        if current_brand:
            parts.append(current_brand)
            # 브랜드 직접 지정 시 현재 입력의 성분만 포함 (히스토리 성분 무시)
            if current_ingredient:
                parts.append(current_ingredient)
        else:
            # 성분만 있는 경우
            parts.append(current_ingredient)
        # 카테고리: 현재 입력 우선, 없으면 히스토리
        cat = current_category or history_category
        if cat:
            parts.append(cat)
        direct_query = " ".join(parts).strip()
        print(f"[oliveyoung] 성분/브랜드 직접 검색: '{direct_query}'", flush=True)
        return direct_query

    # 히스토리에만 성분/브랜드가 있는 경우 (현재 입력에는 아무 키워드도 없음)
    if history_ingredient or history_brand:
        parts = []
        if history_brand:
            parts.append(history_brand)
        if history_ingredient:
            parts.append(history_ingredient)
        cat = current_category or history_category
        if cat:
            parts.append(cat)
        direct_query = " ".join(parts).strip()
        print(f"[oliveyoung] 대화 맥락 기반 검색: '{direct_query}'", flush=True)
        return direct_query
    # 1. 제품 카테고리 추출
    category_query = product_type_hint
    if not category_query:
        for key, val in _PRODUCT_TYPE_QUERY.items():
            if key in user_text:
                category_query = val
                break

    # 2. 고민 키워드 추출 (질문 + 프로필)
    concern_text = user_text
    if user_profile:
        concern_text += " " + (user_profile.get("skin_concern") or "")

    concern_query = ""
    for key, val in _CONCERN_QUERY.items():
        if key in concern_text:
            concern_query = val
            break

    # 3. 피부타입 추출 (질문 우선, 없으면 프로필)
    skin_type = ""
    for key in _SKIN_TYPE_QUERY:
        if key in user_text:
            skin_type = key
            break
    if not skin_type and user_profile:
        skin_type = user_profile.get("skin_type_label") or ""

    # 4. 쿼리 조합
    # 우선순위: 고민+카테고리 > 피부타입+카테고리 > 고민만 > 카테고리만 > 피부타입 폴백
    if concern_query and category_query:
        # 중복 단어 방지
        if category_query.split()[0] in concern_query:
            return concern_query
        return f"{concern_query} {category_query}".strip()

    if skin_type and category_query:
        # "지성 폼 클렌저", "건성 수분 크림" 등
        skin_label = skin_type if skin_type in ("건성", "지성", "복합성", "민감성", "중성") else skin_type
        return f"{skin_label} {category_query}".strip()

    if concern_query:
        return concern_query

    if category_query:
        return category_query

    # 5. 폴백: 피부타입 기본 쿼리
    if skin_type and skin_type in _SKIN_TYPE_QUERY:
        return _SKIN_TYPE_QUERY[skin_type]
    if skin_type:
        return skin_type

    return "수분 보습 크림"


import time as _time

# TTL 기반 캐시 (lru_cache 대체)
# lru_cache는 프로세스 재시작 전까지 영구 유지 → 올리브영 재고 변화 미반영
# TTL 1시간으로 설정: 같은 쿼리를 1시간 내 재요청 시 캐시 사용
_TAVILY_CACHE: dict[str, tuple] = {}   # query → (timestamp, results_tuple)
_TAVILY_CACHE_TTL = 3600  # 1시간 (초)


def _cached_tavily_search(query: str, max_results: int = 10) -> tuple:
    """쿼리별 Tavily 검색 결과 캐싱 (TTL 1시간)
    max_results가 기존 캐시보다 크면 재검색해서 후보 풀 확장.
    """
    now = _time.time()
    cache_key = query  # 캐시 키는 쿼리만 (max_results 무관)
    cached = _TAVILY_CACHE.get(cache_key)
    if cached:
        ts, results = cached
        if now - ts < _TAVILY_CACHE_TTL:
            # 캐시된 결과가 충분하면 그대로 사용
            if len(results) >= max_results:
                print(f"[oliveyoung] 캐시 사용: '{query}' ({len(results)}개, 남은 TTL: {int(_TAVILY_CACHE_TTL - (now - ts))}초)", flush=True)
                return results
        else:
            print(f"[oliveyoung] 캐시 만료: '{query}'", flush=True)

    results = _tavily_search(query, max_results=max_results)
    results_tuple = tuple(
        (r.get("url", ""), r.get("title", ""), r.get("content", ""))
        for r in results
    )
    _TAVILY_CACHE[cache_key] = (now, results_tuple)
    return results_tuple


# 고민별 제품 관련성 검증 키워드
# Tavily 결과 title에 이 키워드 중 하나라도 있어야 해당 고민에 맞는 제품으로 간주
# 없으면 "홍조 쿼리에 리프팅 크림" 같은 무관 제품이 섞임
_CONCERN_RELEVANCE_KW = {
    "홍조":   ["홍조", "붉", "진정", "시카", "카밍", "수딩", "센텔라", "녹색", "그린", "코렉팅", "redness", "calming", "soothing"],
    "붉은기": ["홍조", "붉", "진정", "시카", "카밍", "수딩", "코렉팅", "그린"],
    "여드름": ["여드름", "트러블", "acne", "bha", "살리실산", "클리어", "포어", "진정", "티트리"],
    "트러블": ["트러블", "여드름", "진정", "클리어", "티트리", "bha"],
    "모공":   ["모공", "포어", "pore", "수렴", "피지", "세정", "클렌"],
    "각질":   ["각질", "aha", "필링", "exfo", "부드", "스무"],
    "주름":   ["주름", "탄력", "안티에이징", "레티놀", "리프팅", "콜라겐", "wrinkle", "firming"],
    "탄력":   ["탄력", "리프팅", "콜라겐", "firming", "주름", "안티에이징"],
    "미백":   ["미백", "브라이트닝", "brightening", "비타민c", "나이아신", "잡티", "기미", "화이트"],
    "잡티":   ["미백", "브라이트닝", "잡티", "기미", "비타민c", "화이트"],
    "기미":   ["미백", "기미", "잡티", "브라이트닝", "비타민c"],
    "수분":   ["수분", "보습", "하이드라", "히알루론", "moisturizing", "촉촉"],
    "건조":   ["보습", "수분", "하이드라", "히알루론", "moisturizing", "촉촉", "크림"],
    "번들":   ["피지", "오일", "수렴", "oil control", "모공", "sebum"],
    "피지":   ["피지", "오일", "수렴", "sebum", "oil control", "모공"],
}


def _is_relevant_to_concern(display_name: str, concern_query: str) -> bool:
    """
    제품명이 검색한 고민 키워드와 관련 있는지 확인합니다.

    예) 고민=홍조, 제품명="바이오힐보 3D 리프팅 크림" → False (리프팅은 홍조 무관)
        고민=홍조, 제품명="세타필 시카 카밍 크림" → True (카밍 = 진정)
    """
    # 어떤 고민에 해당하는 검색인지 역추적
    matched_concern = None
    for concern, query in _CONCERN_QUERY.items():
        if query == concern_query:
            matched_concern = concern
            break

    if not matched_concern:
        return True  # 매핑 못 찾으면 통과 (보수적)

    relevance_kws = _CONCERN_RELEVANCE_KW.get(matched_concern)
    if not relevance_kws:
        return True  # 관련성 KW 없으면 통과

    name_lower = display_name.lower()
    return any(kw in name_lower for kw in relevance_kws)


def search_products_for_context(
    user_text: str,
    user_profile: dict | None,
    max_products: int = 3,
    chat_history: list | None = None,
    detected_keywords: dict | None = None,
) -> list[dict]:
    """
    [핵심 함수] 피부 맥락 기반으로 올리브영 제품을 직접 검색합니다.

    기존 방식(벡터DB → 올리브영 매칭)과 달리:
    - 올리브영에 실제 판매 중인 제품만 반환
    - 제품명/URL 미스매치 없음
    - 속도: ~5초 (기존 30-40초 대비)

    다양성 전략:
    - Tavily에서 최대 10개 결과를 가져온 뒤
    - 유효한 제품 후보를 모두 수집하고
    - 그 중 max_products개를 랜덤 샘플링해서 반환
    - 같은 쿼리라도 매번 다른 제품 조합이 나옴

    Args:
        user_text: 사용자 질문
        user_profile: 로그인 유저 프로필 (skin_type_label, skin_concern 등)
        max_products: 최대 반환 제품 수
        chat_history: 채팅 히스토리 (이전 대화에서 성분/브랜드 맥락 추출용)
        detected_keywords: LLM 라우터가 추출한 키워드 {"brand": ..., "ingredient": ..., "category": ...}

    Returns:
        [{"name": "...", "display_name": "...", "oliveyoung_url": "...", "why": ""}, ...]
    """
    import random
    query = _build_oliveyoung_query(user_text, user_profile, chat_history=chat_history, detected_keywords=detected_keywords)
    print(f"[oliveyoung] 올리브영 직접 검색: '{query}'", flush=True)

    # TTL 캐시에서 가져오되 max_results=10으로 후보 풀을 크게 확보
    raw = _cached_tavily_search(query, max_results=10)
    candidates = []
    seen_urls = set()

    for url, title, content in raw:
        if not _is_product_url(url):
            continue
        clean_url = _clean_url(url)
        if clean_url in seen_urls:
            continue
        display_name = _extract_display_name({"title": title, "url": url, "content": content})
        if not display_name:
            continue
        # 제품명이 너무 짧거나 잘린 것으로 판단되면 제외
        if len(display_name) < 10:
            print(f"[oliveyoung]  제품명 너무 짧음 제외: {display_name}", flush=True)
            continue
        # 제품명이 한글 중간에서 잘린 경우 감지 (ml, g, 매 등 단위로 끝나지 않으면 잘린 것)
        import re as _re
        _VALID_ENDINGS = _re.compile(r'(ml|g|매|개|팩|종|정|입|분|세트|기획|\)|\+|택1|단품)$', _re.IGNORECASE)
        if not _VALID_ENDINGS.search(display_name) and len(display_name) < 30:
            # 짧은데 단위로 안 끝나면 잘린 가능성 높음
            last_char = display_name[-1] if display_name else ""
            # 한글 받침이 없는 글자로 끝나거나 '루', '크' 등 중간 음절로 끝나면 잘림
            if last_char and '\uac00' <= last_char <= '\ud7a3':
                # 한글 종성(받침) 체크: (코드 - 0xAC00) % 28 == 0 이면 받침 없음
                if (ord(last_char) - 0xAC00) % 28 == 0:
                    print(f"[oliveyoung]  제품명 잘림 감지(받침없음): {display_name}", flush=True)
                    continue
        # 스킨케어 무관 제품 필터링 (제모크림, 바디로션, 헤어제품 등 제외)
        if not _is_skincare_product(display_name):
            print(f"[oliveyoung]  스킨케어 무관 제외: {display_name}", flush=True)
            continue
        # 고민 관련성 필터링 (홍조 쿼리에 리프팅 크림 등 무관 제품 제외)
        if not _is_relevant_to_concern(display_name, query):
            print(f"[oliveyoung]  고민 무관 제외: {display_name}", flush=True)
            continue
        seen_urls.add(clean_url)
        candidates.append({
            "name": display_name,
            "display_name": display_name,
            "why": "",
            "oliveyoung_url": clean_url,
            "evidence_source_id": "",
        })

    # 카테고리 필터링: 사용자가 "로션", "세럼" 등 카테고리를 명시했으면
    # 해당 카테고리 제품만 우선 선별 (결과가 너무 적으면 필터 해제)
    _CATEGORY_FILTER_KW = {
        "크림": ["크림", "cream"],
        "로션": ["로션", "lotion"],
        "세럼": ["세럼", "serum"],
        "토너": ["토너", "토닉", "스킨", "toner"],
        "에센스": ["에센스", "essence"],
        "선크림": ["선크림", "선스크린", "sun", "spf", "자외선"],
        "앰플": ["앰플", "ampoule"],
        "미스트": ["미스트", "mist"],
        "마스크팩": ["마스크", "팩", "mask"],
        "패드": ["패드", "pad"],
        "클렌저": ["클렌저", "클렌징", "폼", "cleanser", "세안"],
        "오일": ["오일", "oil"],
    }
    user_text_lower = (user_text or "").lower()
    requested_category = None
    for cat_key, cat_kws in _CATEGORY_FILTER_KW.items():
        if any(kw in user_text_lower for kw in [cat_key] + cat_kws):
            requested_category = cat_key
            break

    if requested_category:
        filter_kws = _CATEGORY_FILTER_KW[requested_category]
        filtered = [
            c for c in candidates
            if any(kw in c["display_name"].lower() for kw in filter_kws)
        ]
        if len(filtered) >= 1:
            print(f"[oliveyoung] 카테고리 필터 적용: '{requested_category}' → {len(filtered)}개/{len(candidates)}개", flush=True)
            candidates = filtered
        else:
            print(f"[oliveyoung] 카테고리 필터 '{requested_category}' 결과 없음 → 필터 해제", flush=True)

    # 후보 중 랜덤 샘플링 → 매번 다른 제품 조합
    if len(candidates) > max_products:
        products = random.sample(candidates, max_products)
    else:
        products = candidates

    print(f"[oliveyoung] 제품 {len(products)}개 확보 (후보 {len(candidates)}개 중 샘플링)", flush=True)
    for p in products:
        print(f"  → {p['display_name']} | {p['oliveyoung_url']}", flush=True)

    return products


# 핵심 함수 2: 복합 intent용 병렬 검색

def search_products_parallel(
    user_text: str,
    user_profile: dict | None,
    max_products: int = 3,
    chat_history: list | None = None,
) -> list[dict]:
    """
    routine_and_product intent용 - search_products_for_context와 동일하나
    병렬 처리를 위해 별도 함수로 분리합니다.
    (pipeline에서 concurrent.futures로 RAG와 동시 실행)
    """
    return search_products_for_context(user_text, user_profile, max_products, chat_history=chat_history)


# 하위호환: 기존 gate_products (제거 예정)

def _name_matches(search_name: str, result_title: str) -> bool:
    """기존 gate_products에서 사용하던 이름 매칭 함수"""
    if not search_name or not result_title:
        return False
    clean_title = result_title.lower()
    for sep in [" | ", " - ", " :: ", " : "]:
        if sep in clean_title:
            clean_title = clean_title.split(sep)[0]
    search_lower = search_name.lower().replace(" ", "")
    title_lower = clean_title.replace(" ", "")
    stop_words = {"피부의", "도움을", "준다", "효능효과", "(주)", "주식회사", "코스메틱"}
    words = [w for w in search_name.split() if len(w) >= 2 and w not in stop_words]
    if search_lower in title_lower:
        return True
    if not words:
        return False
    matched = sum(1 for w in words if w.lower() in title_lower)
    return matched >= max(1, len(words) // 2)


@lru_cache(maxsize=256)
def check_product(product_name: str, brand: str = "") -> Optional[dict]:
    """하위호환용 - 특정 제품명이 올리브영에 있는지 확인"""
    query = f"{brand} {product_name} site:oliveyoung.co.kr".strip()
    results = _tavily_search(query, max_results=3)
    for item in results:
        url = item.get("url", "")
        title = item.get("title", "")
        if _is_product_url(url) and _name_matches(product_name, title):
            return {"url": _clean_url(url), "display_name": _extract_display_name(item) or product_name}
    if brand:
        results2 = _tavily_search(f"{product_name} oliveyoung", max_results=3)
        for item in results2:
            url = item.get("url", "")
            title = item.get("title", "")
            if _is_product_url(url) and _name_matches(product_name, title):
                return {"url": _clean_url(url), "display_name": _extract_display_name(item) or product_name}
    return None


def gate_products(products: list[dict]) -> list[dict]:
    """하위호환용 - 더 이상 product_recommend에서는 사용 안 함"""
    passed = []
    for p in products:
        if not isinstance(p, dict):
            continue
        name = (p.get("name") or "").strip()
        brand = (p.get("brand") or "").strip()
        if not name:
            continue
        result = check_product(name, brand)
        if result:
            p["oliveyoung_url"] = result["url"]
            p["display_name"] = result["display_name"]
            passed.append(p)
            print(f"[oliveyoung]  {result['display_name']} → {result['url']}", flush=True)
        else:
            print(f"[oliveyoung]  미확인: {brand} {name}", flush=True)
    return passed