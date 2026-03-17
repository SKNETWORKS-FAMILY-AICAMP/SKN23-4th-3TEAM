"""
nodes/context.py
유저 프로필을 로드하고 맥락 부족 여부를 확인합니다.
기존 pipeline.py의 Step 3 + Step 3-1에 해당합니다.

[비로그인 사용자 추가 처리]
1. 일반 질의에서도 피부타입 미수집 시 역질문
2. 답변 말미에 회원가입 유도 문구 삽입 (state에 플래그 저장)
"""
import time
from ai.orchestrator.state import GraphState
from ai.orchestrator.context_builder import build_context
from ai.orchestrator.router import (
    _has_context, _CONTEXT_KW, _PRODUCT_CATEGORY_KW,
    _normalize_category, _has_any,
    RouteDecision, _INTENT_FLAGS,
)

# 역질문 없이 바로 답변해도 되는 intent
_NO_ASK_INTENTS = {
    "greeting", "out_of_domain", "login_required",
    "ask_for_context", "medical_advice",
    "skin_analysis_fast", "skin_analysis_deep", "ingredient_analysis",
}

# 답변 말미에 회원가입 유도 문구를 붙일 intent
_UPSELL_INTENTS = {
    "general_advice", "routine_advice", "ingredient_question",
    "product_recommend", "routine_and_product",
}


# 피부타입 없어도 답할 수 있는 일반 지식성 질문 키워드
_GENERAL_KNOWLEDGE_KW = [
    # 이유/원리 질문
    "왜", "이유", "원인", "어떻게", "무엇", "뭐야", "뭔지", "설명",
    # 음식/생활습관
    "음식", "먹으면", "먹어야", "식단", "생활", "습관",
    "운동", "수면", "스트레스", "호르몬",
    # 환경/계절
    "계절", "겨울", "여름", "환절기", "날씨", "온도", "습도",
    "실내", "자외선", "환경", "컴퓨터", "핸드폰",
    # 성분/효능 설명
    "효능", "효과", "성분이", "작용", "차이", "비교",
    # 일반 지식 요청
    "알려줘", "궁금해", "뭐가 좋아", "좋다는데",
]


def _needs_skin_type_for_answer(user_text: str, intent: str) -> bool:
    text = (user_text or "").lower()

    # 제품 추천/루틴은 항상 개인화 필요
    if intent in ("product_recommend", "routine_and_product", "routine_advice"):
        return True

    # general_advice지만 개인화가 필요한 키워드가 있는 경우
    _PERSONALIZED_ADVICE_KW = [
        "관리법", "관리", "케어", "루틴", "어떻게 해야",
        "뭐 바르", "뭐 써", "어떤 게 좋", "맞는",
    ]
    if intent == "general_advice" and any(kw in text for kw in _PERSONALIZED_ADVICE_KW):
        # 단, 일반 지식 질문("왜", "이유", "음식" 등)과 겹치면 역질문 불필요
        _PURE_KNOWLEDGE_KW = [
            "왜", "이유", "원인", "무엇", "뭐야", "뭔지", "설명",
            "음식", "먹으면", "식단", "운동", "수면", "스트레스",
            "효능", "효과", "성분이", "작용", "차이", "비교",
        ]
        if not any(kw in text for kw in _PURE_KNOWLEDGE_KW):
            return True

    # 일반 지식성 질문이면 역질문 불필요
    if _has_any(text, _GENERAL_KNOWLEDGE_KW):
        return False

    # 카테고리 키워드 있으면 개인화 필요 (세럼 등 제품 언급)
    normalized = _normalize_category(text)
    if any(kw in normalized for kw in _PRODUCT_CATEGORY_KW):
        return True

    # general_advice는 기본적으로 역질문 불필요
    return False


def _has_temp_skin_context(user_profile: dict | None, user_text: str = "") -> bool:
    """
    임시 프로필 또는 현재 입력 텍스트에 피부타입/고민 정보가 있는지 확인.

    chat_history가 비어있어도 현재 입력("지성이야", "지성 피부요" 등)에서
    피부타입을 감지하면 바로 답변으로 진행합니다.
    """
    # 임시 프로필에서 확인
    if user_profile and (
        user_profile.get("skin_type_label") or
        user_profile.get("skin_concern")
    ):
        return True

    # 현재 입력 텍스트에서도 확인 (chat_history 미전달 케이스 대응)
    if user_text and any(kw in user_text for kw in _CONTEXT_KW):
        return True

    return False


def context_node(state: GraphState) -> GraphState:
    """
    [context_node]
    입력: user_id, chat_history, route
    출력: user_profile, instant_response(맥락 부족이면), guest_upsell(비로그인 유도 플래그)
    """
    t0 = time.perf_counter()

    user_id = state.get("user_id")
    chat_history = state.get("chat_history", [])
    route = state["route"]
    is_guest = not user_id

    user_profile = build_context(
        user_id=user_id,
        chat_history=chat_history,
    )

    print(f"[TIMER] context_node: {time.perf_counter()-t0:.3f}s", flush=True)

    updates: GraphState = {
        "user_profile": user_profile,
        "guest_upsell": False,  # 기본값
    }

    # 0. 회원 ask_for_context/ask_for_category 보정
    # route_node 시점에는 user_profile=None이라 LLM이 프로필을 인식 못하는 경우가 있음
    # context_node에서 DB 프로필을 로드한 후, 회원 프로필에 피부 정보가 있으면 route를 보정
    if not is_guest and route.intent in ("ask_for_context", "ask_for_category"):
        profile_has_skin = bool(
            user_profile
            and (user_profile.get("skin_type_label") or user_profile.get("skin_concern"))
        )
        if profile_has_skin:
            # 현재 입력에서 카테고리 키워드 확인
            user_text_lower = (state.get("user_text") or "").lower()
            normalized_text = _normalize_category(user_text_lower)
            has_category = any(kw in normalized_text for kw in _PRODUCT_CATEGORY_KW)

            if route.intent == "ask_for_context" and has_category:
                # 피부 정보 있고 + 카테고리 있음 → 바로 제품 검색
                new_intent = "product_recommend"
                flags = _INTENT_FLAGS[new_intent]
                route = RouteDecision(
                    intent=new_intent,
                    needs_vision=flags["needs_vision"],
                    needs_rag=flags["needs_rag"],
                    needs_product=flags["needs_product"],
                    needs_context_check=False,  # 프로필에 피부 정보 있으므로 체크 불필요
                    reason=f"[CONTEXT 보정] 프로필에 피부 정보 있음 + 카테고리 있음 → {new_intent}",
                )
                updates["route"] = route
                print(f"[CONTEXT] 회원 프로필 보정: ask_for_context → {new_intent}", flush=True)

            elif route.intent == "ask_for_context" and not has_category:
                # 피부 정보 있고 + 카테고리 없음 → 카테고리만 역질문
                new_intent = "ask_for_category"
                route = RouteDecision(
                    intent=new_intent,
                    needs_vision=False, needs_rag=False,
                    needs_product=False, needs_context_check=False,
                    reason="[CONTEXT 보정] 프로필에 피부 정보 있음 → 카테고리만 역질문",
                )
                updates["route"] = route
                print(f"[CONTEXT] 회원 프로필 보정: ask_for_context → {new_intent}", flush=True)
                # 카테고리 역질문 반환
                result = {
                    "chat_answer": (
                        "어떤 종류의 제품을 찾고 계신가요? 😊\n\n"
                        "예를 들어:\n"
                        "- 수분크림\n- 세럼\n- 폼클렌징\n- 토너/스킨\n- 선크림\n- 로션\n\n"
                        "원하시는 제품 종류를 알려주시면 올리브영에서 딱 맞는 제품을 찾아드릴게요!"
                    ),
                    "summary": "", "observations": [], "recommendations": [],
                    "products": [], "warnings": [], "citations": [],
                    "intent": "ask_for_category", "room_title": None,
                }
                if state.get("is_first_message"):
                    text = (state.get("user_text") or "").strip()
                    result["room_title"] = text[:18] + "…" if len(text) > 20 else text
                updates["instant_response"] = result
                return updates

            # ask_for_category인데 프로필에 피부 정보 있음 → product_recommend로 보정
            # (LLM이 product_recommend로 판단했으나 카테고리 미특정으로 ask_for_category가 됨
            #  하지만 프로필 피부 정보가 있으면 카테고리 없이도 검색 가능 - 브랜드 검색, 피부타입 폴백 등)
            if route.intent == "ask_for_category":
                new_intent = "product_recommend"
                flags = _INTENT_FLAGS[new_intent]
                route = RouteDecision(
                    intent=new_intent,
                    needs_vision=flags["needs_vision"],
                    needs_rag=flags["needs_rag"],
                    needs_product=flags["needs_product"],
                    needs_context_check=False,
                    reason="[CONTEXT 보정] 프로필 피부 정보 있음 + ask_for_category → product_recommend",
                )
                updates["route"] = route
                print(f"[CONTEXT] 회원 프로필 보정: ask_for_category → {new_intent}", flush=True)

        else:
            # 회원이지만 프로필에 피부 정보 없음 → 역질문 반환
            print("[CONTEXT] 회원이지만 프로필에 피부 정보 없음 → 역질문 반환", flush=True)
            if route.intent == "ask_for_context":
                result = {
                    "chat_answer": (
                        "어떤 피부 타입이나 고민에 맞는 제품을 찾고 계신가요? 😊\n\n"
                        "예를 들어:\n"
                        "- **건성 피부**에 맞는 수분크림 추천해줘\n"
                        "- **여드름** 고민인데 세럼 추천해줘\n"
                        "- **지성 피부**에 맞는 선크림 알려줘\n\n"
                        "피부 타입이나 고민을 알려주시면 딱 맞는 제품을 찾아드릴게요!"
                    ),
                    "summary": "", "observations": [], "recommendations": [],
                    "products": [], "warnings": [], "citations": [],
                    "intent": "ask_for_context", "room_title": None,
                }
            else:  # ask_for_category
                result = {
                    "chat_answer": (
                        "어떤 종류의 제품을 찾고 계신가요? 😊\n\n"
                        "예를 들어:\n"
                        "- 수분크림\n- 세럼\n- 폼클렌징\n- 토너/스킨\n- 선크림\n- 로션\n\n"
                        "원하시는 제품 종류를 알려주시면 올리브영에서 딱 맞는 제품을 찾아드릴게요!"
                    ),
                    "summary": "", "observations": [], "recommendations": [],
                    "products": [], "warnings": [], "citations": [],
                    "intent": "ask_for_category", "room_title": None,
                }
            if state.get("is_first_message"):
                text = (state.get("user_text") or "").strip()
                result["room_title"] = text[:18] + "…" if len(text) > 20 else text
            updates["instant_response"] = result
            return updates

    # 1. 기존: 제품 추천 맥락 부족 역질문
    if route.needs_context_check:
        # 회원 DB 프로필에 피부타입이 있으면 역질문 스킵
        profile_has_skin = bool(
            user_profile
            and (user_profile.get("skin_type_label") or user_profile.get("skin_concern"))
        )
        if profile_has_skin:
            print("[CONTEXT] 회원 프로필에 피부 정보 있음 → 역질문 스킵", flush=True)
        elif not _has_context(state["user_text"], user_profile, chat_history):
            print("[CONTEXT] 피부 맥락 부족 → 역질문 반환", flush=True)
            result = {
                "chat_answer": (
                    "어떤 피부 타입이나 고민에 맞는 제품을 찾고 계신가요? 😊\n\n"
                    "예를 들어:\n"
                    "- **건성 피부**에 맞는 수분크림 추천해줘\n"
                    "- **여드름** 고민인데 세럼 추천해줘\n"
                    "- **지성 피부**에 맞는 선크림 알려줘\n\n"
                    "피부 타입이나 고민을 알려주시면 딱 맞는 제품을 찾아드릴게요!"
                ),
                "summary": "", "observations": [], "recommendations": [],
                "products": [], "warnings": [], "citations": [],
                "intent": "ask_for_context", "room_title": None,
            }
            if state.get("is_first_message"):
                text = (state["user_text"] or "").strip()
                result["room_title"] = text[:18] + "…" if len(text) > 20 else text
            updates["instant_response"] = result
            return updates

    # 1-1. 비회원 ask_for_context/ask_for_category → 역질문 반환
    # graph.py에서 ask_for_context가 즉시 종료되지 않으므로 여기서 처리
    if is_guest and route.intent in ("ask_for_context", "ask_for_category"):
        print(f"[CONTEXT] 비회원 {route.intent} → 역질문 반환", flush=True)
        if route.intent == "ask_for_context":
            result = {
                "chat_answer": (
                    "어떤 피부 타입이나 고민에 맞는 제품을 찾고 계신가요? 😊\n\n"
                    "예를 들어:\n"
                    "- **건성 피부**에 맞는 수분크림 추천해줘\n"
                    "- **여드름** 고민인데 세럼 추천해줘\n"
                    "- **지성 피부**에 맞는 선크림 알려줘\n\n"
                    "피부 타입이나 고민을 알려주시면 딱 맞는 제품을 찾아드릴게요!"
                ),
                "summary": "", "observations": [], "recommendations": [],
                "products": [], "warnings": [], "citations": [],
                "intent": "ask_for_context", "room_title": None,
            }
        else:
            result = {
                "chat_answer": (
                    "어떤 종류의 제품을 찾고 계신가요? 😊\n\n"
                    "예를 들어:\n"
                    "- 수분크림\n- 세럼\n- 폼클렌징\n- 토너/스킨\n- 선크림\n- 로션\n\n"
                    "원하시는 제품 종류를 알려주시면 올리브영에서 딱 맞는 제품을 찾아드릴게요!"
                ),
                "summary": "", "observations": [], "recommendations": [],
                "products": [], "warnings": [], "citations": [],
                "intent": "ask_for_category", "room_title": None,
            }
        if state.get("is_first_message"):
            text = (state.get("user_text") or "").strip()
            result["room_title"] = text[:18] + "…" if len(text) > 20 else text
        updates["instant_response"] = result
        return updates

    # 2. 비로그인 전용 처리
    if is_guest and route.intent not in _NO_ASK_INTENTS:

        # 2-1. 피부타입 미수집 시 역질문
        # 단, 음식/원리/이유 같은 일반 지식 질문은 피부타입 없어도 바로 답변
        needs_type = _needs_skin_type_for_answer(state.get('user_text', ''), route.intent)
        if needs_type and not _has_temp_skin_context(user_profile, state.get('user_text', '')):
            print("[CONTEXT] 비로그인 피부 맥락 없음 → 피부타입 역질문", flush=True)

            # 첫 메시지면 질문 내용도 기억해서 답변에 포함
            user_text = (state["user_text"] or "").strip()
            topic_hint = f'"{user_text}"에 대해 ' if user_text else ""

            result = {
                "chat_answer": (
                    f"{topic_hint}답변드리기 전에 먼저 피부 타입을 알려주시면 "
                    f"더 정확한 정보를 드릴 수 있어요 😊\n\n"
                    "**피부 타입이 어떻게 되시나요?**\n"
                    "- 건성 (당기고 건조한 편)\n"
                    "- 지성 (번들거리고 피지가 많은 편)\n"
                    "- 복합성 (T존은 지성, 볼은 건성)\n"
                    "- 중성 (크게 건조하거나 번들거리지 않음)\n"
                    "- 민감성 (자극에 쉽게 반응하는 편)\n\n"
                    "추가로 주요 피부 고민(여드름/홍조/모공/주름 등)도 알려주시면 더욱 도움이 돼요!"
                ),
                "summary": "", "observations": [], "recommendations": [],
                "products": [], "warnings": [], "citations": [],
                "intent": "ask_for_context", "room_title": None,
            }
            if state.get("is_first_message"):
                result["room_title"] = user_text[:18] + "…" if len(user_text) > 20 else user_text
            updates["instant_response"] = result
            return updates

        # 2-2. 피부타입 수집됨 → 답변 후 회원가입 유도 플래그 설정
        if route.intent in _UPSELL_INTENTS:
            print("[CONTEXT] 비로그인 답변 → 회원가입 유도 플래그 설정", flush=True)
            updates["guest_upsell"] = True

    return updates