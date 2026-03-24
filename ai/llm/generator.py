"""
generator.py
intent에 맞는 프롬프트를 선택하고 OpenAI를 호출합니다.
"""
import json
import re
from openai import OpenAI

from ai.config.settings import OPENAI_API_KEY, OPENAI_MODEL, OPENAI_TEMPERATURE
from ai.llm.prompts.skin_analysis import FAST_ANALYSIS_PROMPT, DEEP_ANALYSIS_PROMPT
from ai.llm.prompts.personal_color import ANSWER_PROMPT as PERSONAL_COLOR_PROMPT
from ai.llm.prompts import (
    BASE_SYSTEM,
    GENERAL_CHAT_PROMPT,
    PRODUCT_RECOMMEND_PROMPT,
    INGREDIENT_CHAT_PROMPT,
    ROUTINE_AND_PRODUCT_PROMPT,
)

client = OpenAI(api_key=OPENAI_API_KEY)

# 피부 분석 intent - LLM 프롬프트에서 skin_type/concern 제거 대상
_ANALYSIS_INTENTS = {"skin_analysis_fast", "skin_analysis_deep", "personal_color"}

# intent → 프롬프트 매핑
_PROMPT_MAP = {
    "general_advice":        GENERAL_CHAT_PROMPT,
    "routine_advice":        GENERAL_CHAT_PROMPT,
    "medical_advice":        GENERAL_CHAT_PROMPT,
    "ingredient_question":   GENERAL_CHAT_PROMPT,
    "skin_analysis_fast":    FAST_ANALYSIS_PROMPT,
    "skin_analysis_deep":    DEEP_ANALYSIS_PROMPT,
    "product_recommend":     PRODUCT_RECOMMEND_PROMPT,
    "routine_and_product":   ROUTINE_AND_PRODUCT_PROMPT,
    "ingredient_analysis":   INGREDIENT_CHAT_PROMPT,
    "personal_color":        PERSONAL_COLOR_PROMPT,
    "history_compare":       DEEP_ANALYSIS_PROMPT,
}


def _safe_json_loads(text: str) -> dict:
    """LLM 응답에서 JSON만 안전하게 파싱합니다."""
    if not text:
        raise ValueError("Empty LLM response")

    # 코드펜스 제거
    text = re.sub(r"^```(?:json)?\s*", "", text.strip(), flags=re.IGNORECASE)
    text = re.sub(r"\s*```$", "", text.strip())

    # { } 범위만 추출
    if not text.lstrip().startswith("{"):
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1 and end > start:
            text = text[start:end + 1]

    return json.loads(text)


def _build_user_profile_text(user_profile: dict | None) -> str:
    """user_profile dict → 프롬프트용 텍스트 변환"""
    if not user_profile:
        return "비회원 (프로필 없음) — 대화에서 수집된 임시 정보만 활용"

    parts = []
    if user_profile.get("skin_type_label"):
        parts.append(f"피부타입: {user_profile['skin_type_label']}")
    if user_profile.get("skin_concern"):
        parts.append(f"피부고민: {user_profile['skin_concern']}")
    if user_profile.get("age"):
        parts.append(f"나이: {user_profile['age']}세")
    if user_profile.get("gender"):
        g = "여성" if user_profile["gender"] == "female" else "남성"
        parts.append(f"성별: {g}")
    if user_profile.get("recent_analysis_summary"):
        parts.append(f"최근 분석 요약: {user_profile['recent_analysis_summary']}")

    return "\n".join(parts) if parts else "프로필 정보 없음"




def _build_analysis_profile_text(user_profile: dict | None) -> str:
    """
    분석 intent용 프로필 텍스트 - skin_type/skin_concern 제외.
    모델 수치가 유일한 판단 근거가 되도록 피부 타입 정보를 차단합니다.
    """
    if not user_profile:
        return "프로필 없음"

    parts = []
    if user_profile.get("age"):
        parts.append(f"나이: {user_profile['age']}세")
    if user_profile.get("gender"):
        g = "여성" if user_profile["gender"] == "female" else "남성"
        parts.append(f"성별: {g}")

    return "\n".join(parts) if parts else "나이/성별 정보 없음"

def _build_history_summary(user_profile: dict | None) -> str:
    """이전 분석 이력 요약 텍스트"""
    if not user_profile:
        return "이전 분석 없음"
    return user_profile.get("recent_analysis_summary") or "이전 분석 없음"


def _trim_passages(passages: list, max_len: int = 300) -> list:
    """RAG passage snippet을 max_len자로 잘라 토큰 절약"""
    result = []
    for p in passages:
        tp = dict(p)
        if tp.get("snippet") and len(tp["snippet"]) > max_len:
            tp["snippet"] = tp["snippet"][:max_len] + "…"
        result.append(tp)
    return result


def generate_report(
    intent: str,
    user_text: str,
    user_profile: dict | None,
    vision_result: dict | None,
    rag_passages: list,
    web_passages: list,
    chat_history: list,
    ingredients: list | None = None,
    analysis_mode: str = "",
    verified_products: list | None = None,  # 올리브영 검증 완료 제품 (pipeline에서 전달)
) -> dict:
    """
    intent에 맞는 프롬프트를 선택하고 OpenAI를 호출합니다.

    verified_products: 올리브영 게이트를 통과한 제품 목록.
                       None이면 LLM이 RAG 기반으로 자유롭게 추천.
                       리스트면 이 제품들만 추천하도록 프롬프트에 주입.
    Returns:
        dict: LLM이 반환한 JSON (FinalReport 구조)
    """
    # 프롬프트 선택
    task_prompt_template = _PROMPT_MAP.get(intent, GENERAL_CHAT_PROMPT)

    # 프로필 텍스트 변환 (분석 intent일 때 skin_type/concern 제거)
    if intent in _ANALYSIS_INTENTS:
        user_profile_text = _build_analysis_profile_text(user_profile)
    else:
        user_profile_text = _build_user_profile_text(user_profile)
    history_summary = _build_history_summary(user_profile)
    analysis_mode_text = (
        "빠른 분석 (이미지 1장)" if analysis_mode == "fast"
        else "정밀 분석 (이미지 최대 3장)" if analysis_mode == "deep"
        else ""
    )

    # 프롬프트 변수 치환
    import json as _json

    # 분석 intent에서 얼굴/이미지 검증 실패 시 통일된 안내 메시지 반환
    _VISION_ERROR_INTENTS = {"personal_color", "skin_analysis_fast", "skin_analysis_deep", "ingredient_analysis"}
    if intent in _VISION_ERROR_INTENTS and vision_result and vision_result.get("mode") == "error":
        error_reason = vision_result.get("error", "")
        if intent == "personal_color":
            return {
                "chat_answer": (
                    "퍼스널컬러 분석을 위해서는 **실제 사람의 정면 얼굴 사진**이 필요해요.\n\n"
                    "🧴 **사진 가이드**\n"
                    "• 메이크업을 제거한 맨 얼굴 사진을 사용해주세요\n"
                    "• 정면을 바라보는 사진이어야 해요\n"
                    "• 만화, 캐릭터, 동물 사진은 분석이 어려워요\n"
                    "• 밝은 조명에서 촬영된 선명한 사진을 권장해요\n\n"
                    "🔍 **왜 정확한 사진이 필요한가요?**\n"
                    "퍼스널컬러 진단은 피부톤, 눈동자 색, 입술 색감을 종합적으로 분석하기 때문에 "
                    "실제 얼굴의 자연스러운 색감이 잘 드러나는 사진이 필수예요.\n\n"
                    "💡 **촬영 팁**\n"
                    "• 자연광 또는 밝은 실내 조명에서 촬영해주세요\n"
                    "• 그림자가 지지 않는 환경이 좋아요\n"
                    "• 필터나 보정 없는 원본 사진을 사용해주세요\n\n"
                    "조건에 맞는 사진으로 다시 업로드해주시면 정확한 퍼스널컬러를 알려드릴게요! 📸"
                ),
                "intent": "personal_color",
                "products": [],
            }
        elif intent in ("skin_analysis_fast", "skin_analysis_deep"):
            mode_name = "빠른 분석" if intent == "skin_analysis_fast" else "정밀 분석"
            photo_guide = "정면 얼굴 사진 1장" if intent == "skin_analysis_fast" else "정면·좌측·우측 얼굴 사진 3장"
            return {
                "chat_answer": (
                    f"피부 분석을 위해서는 **실제 사람의 얼굴 사진**이 필요해요.\n\n"
                    f"🧴 **{mode_name} 사진 가이드**\n"
                    f"• {photo_guide}을 준비해주세요\n"
                    f"• 메이크업을 제거하고 세안 후 물기가 없는 상태에서 촬영해주세요\n"
                    f"• 만화, 캐릭터, 동물, 풍경 사진은 분석이 어려워요\n"
                    f"• 얼굴 전체가 화면에 나오도록 촬영해주세요\n\n"
                    f"🔍 **왜 정확한 사진이 필요한가요?**\n"
                    f"피부 분석은 수분, 탄력, 주름, 모공, 색소침착 등의 피부 지표를 정량 측정하기 때문에 "
                    f"실제 피부 상태가 잘 드러나는 사진이 필수예요.\n\n"
                    f"💡 **촬영 팁**\n"
                    f"• 밝은 조명에서 그림자 없이 촬영해주세요\n"
                    f"• 흔들림 없이 선명하게 촬영해주세요\n"
                    f"• 머리카락이 얼굴을 가리지 않도록 정리해주세요\n\n"
                    f"조건에 맞는 사진으로 다시 업로드해주시면 정확한 피부 분석 결과를 알려드릴게요! 📸"
                ),
                "intent": intent,
                "products": [],
            }
        elif intent == "ingredient_analysis":
            return {
                "chat_answer": (
                    "성분 분석을 위해서는 **화장품 전성분표 사진**이 필요해요.\n\n"
                    "🧴 **사진 가이드**\n"
                    "• 화장품 뒷면의 전성분표가 보이는 사진을 올려주세요\n"
                    "• 글자가 선명하게 보이도록 가까이에서 촬영해주세요\n"
                    "• 얼굴, 풍경, 제품 앞면 사진은 성분 추출이 어려워요\n"
                    "• 전성분 영역이 잘리지 않도록 전체가 보이게 촬영해주세요\n\n"
                    "🔍 **왜 전성분표 사진이 필요한가요?**\n"
                    "OCR로 성분을 추출한 뒤 회원님의 피부타입과 고민에 맞는 성분인지, "
                    "주의해야 할 성분이 포함되어 있는지 분석해드려요.\n\n"
                    "💡 **촬영 팁**\n"
                    "• 수평을 맞춰서 촬영해주세요\n"
                    "• 그림자가 지지 않는 환경이 좋아요\n"
                    "• 흔들림 없이 또렷하게 촬영해주세요\n\n"
                    "조건에 맞는 사진으로 다시 업로드해주시면 성분을 분석해드릴게요! 📸"
                ),
                "intent": "ingredient_analysis",
                "products": [],
            }

    # 퍼스널컬러 정상 판정 (type_result 있음)
    if intent == "personal_color" and vision_result and vision_result.get("type_result"):
        tr = vision_result["type_result"]
        task_prompt = task_prompt_template.format(
            name=tr.get("name", ""),
            keywords=tr.get("keywords", ""),
            description=tr.get("description", ""),
            mood=tr.get("mood", ""),
            recommended_colors=tr.get("recommended_colors", ""),
            scores=_json.dumps(tr.get("scores", {}), ensure_ascii=False),
        )
    else:
        task_prompt = task_prompt_template.format(
            user_profile_text=user_profile_text,
            analysis_mode=analysis_mode_text,
            history_summary=history_summary,
            ingredients_text=", ".join(ingredients) if ingredients else "없음",
            vision_result=_json.dumps(vision_result, ensure_ascii=False) if vision_result else "없음",
        )

    # 히스토리 최근 N턴만
    # 분석 intent는 수치 기반 판단 → chat_history 불필요 → 토큰 절약
    from ai.config.settings import CHAT_HISTORY_TURNS
    _ANALYSIS_INTENTS_NO_HISTORY = {"skin_analysis_fast", "skin_analysis_deep", "ingredient_analysis", "personal_color"}
    if intent in _ANALYSIS_INTENTS_NO_HISTORY:
        recent_history = []
    else:
        recent_history = (chat_history or [])[-CHAT_HISTORY_TURNS * 2:]

    # RAG/웹 passage snippet 트리밍 (토큰 절약)
    rag_passages = _trim_passages(rag_passages, max_len=300)
    web_passages = _trim_passages(web_passages, max_len=200)

    # LLM에 넘길 user payload
    payload = {
        "task_instruction": task_prompt,
        "chat_history": recent_history,
        "user_text": user_text,
        "vision_result": vision_result,
        "rag_passages": rag_passages,
        "web_passages": web_passages,
        "intent": intent,
    }

    # 올리브영 검증 완료 제품이 있으면 명시적으로 전달
    # LLM은 이 제품들 중에서만 추천해야 함
    if verified_products is not None:
        if verified_products:
            payload["verified_oliveyoung_products"] = verified_products
            payload["task_instruction"] += (
                "\n\n[중요] 아래 verified_oliveyoung_products 목록에 있는 제품만 추천할 것. "
                "목록에 없는 제품은 절대 추천하지 않는다. "
                f"검증된 제품 {len(verified_products)}개: "
                + ", ".join(p.get("name","") for p in verified_products)
            )
        else:
            payload["verified_oliveyoung_products"] = []
            payload["task_instruction"] += (
                "\n\n[중요] 올리브영에서 재고가 확인된 제품이 없다. "
                "제품 추천 대신 피부타입/고민에 맞는 성분 키워드와 루틴 조언만 제공할 것. "
                "products 필드는 반드시 빈 리스트로 반환할 것."
            )

    # 제품 추천 intent일 때 LLM이 링크를 직접 생성하지 않도록 금지
    # pipeline이 올리브영 링크 섹션을 단독으로 추가하므로 중복 방지
    if verified_products is not None:
        payload["task_instruction"] += (
            "\n\n[중요] chat_answer에 URL, 링크, 구매 링크 텍스트를 절대 포함하지 말 것. "
            "구매 링크는 시스템이 자동으로 추가한다."
        )

    # 퍼스널컬러 맥락에서 제품 추천 시: 피부타입이 아닌 컬러 매칭 관점으로 설명
    if intent == "product_recommend" and chat_history:
        _PC_CHECK = ["추천 립 컬러", "추천 블러셔", "한 줄 무드", "이미지 키워드"]
        pc_answer = None
        for msg in reversed(chat_history):
            if msg.get("role") == "assistant" and any(m in (msg.get("content") or "") for m in _PC_CHECK):
                pc_answer = msg.get("content", "")
                break
        if pc_answer:
            # 퍼스널컬러 타입명 추출
            pc_type_name = ""
            for line in pc_answer.split("\n"):
                if "🎨" in line and "**" in line:
                    pc_type_name = line.replace("🎨", "").replace("**", "").strip()
                    break
            payload["task_instruction"] += (
                f"\n\n[퍼스널컬러 맥락 추천]"
                f"\n이 사용자의 퍼스널컬러는 '{pc_type_name}'입니다."
                f"\n제품 설명 시 피부타입(지성, 건성 등)이나 피부 고민(모공, 여드름 등) 관점이 아니라, "
                f"퍼스널컬러 관점에서 설명해야 합니다."
                f"\n- 이 컬러가 사용자의 퍼스널컬러에 왜 어울리는지"
                f"\n- 이 제품의 색감/발색이 어떤 분위기를 연출하는지"
                f"\n- 어떤 상황/룩에 활용하면 좋은지"
                f"\n피부타입이나 피지, 모공 등의 단어는 사용하지 않는다."
            )

    # 피부 MBTI 맥락: 사용자 메시지에 "피부 MBTI"가 포함되고, 프로필에 MBTI 데이터가 있을 때
    if "피부 MBTI" in user_text and user_profile and user_profile.get("skin_mbti"):
        mbti = user_profile["skin_mbti"]
        mbti_context = (
            f"\n\n[피부 MBTI 맥락]"
            f"\n사용자의 피부 MBTI: {mbti.get('code', '')} ({mbti.get('title', '')})"
            f"\n타입 설명: {mbti.get('description', '')}"
            f"\n스킨케어 습관: {mbti.get('habits', '')}"
            f"\n추천 아침 루틴: {', '.join(mbti.get('morning_routine', []))}"
            f"\n추천 저녁 루틴: {', '.join(mbti.get('night_routine', []))}"
            f"\n케어팁: {', '.join(mbti.get('care_tips', []))}"
            f"\n피해야 할 습관: {', '.join(mbti.get('avoid_habits', []))}"
            f"\n\n[MBTI 답변 규칙]"
            f"\n1. 반드시 답변 서두에 '{mbti.get('code', '')}({mbti.get('title', '')}) 타입에 맞는 ...'으로 시작하세요."
            f"\n2. 위 MBTI 추천 루틴, 케어팁, 피해야 할 습관을 답변의 핵심 근거로 사용하세요."
            f"\n3. 일반적인 피부타입(지성/건성) 설명보다 MBTI 성향 기반 설명을 우선하세요."
            f"\n4. 사용자의 피부타입/고민도 참고하되, MBTI 맞춤 루틴이 답변의 중심이 되어야 합니다."
        )
        payload["task_instruction"] += mbti_context

    # 퍼스널컬러는 답변이 길어서 max_tokens 제한으로 생성 시간 단축
    create_kwargs = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": BASE_SYSTEM},
            {"role": "user", "content": json.dumps(payload, ensure_ascii=False)},
        ],
        "temperature": OPENAI_TEMPERATURE,
        "response_format": {"type": "json_object"},
    }
    if intent == "personal_color":
        create_kwargs["max_tokens"] = 2000

    resp = client.chat.completions.create(**create_kwargs)

    text = resp.choices[0].message.content
    result = _safe_json_loads(text)

    # 퍼스널컬러 답변에 프론트 렌더링용 메타데이터 주입
    if intent == "personal_color" and vision_result and vision_result.get("type_result"):
        tr = vision_result["type_result"]
        result["personal_color_meta"] = {
            "type_name": tr.get("name", ""),
            "keywords": tr.get("keywords", ""),
            "catchphrase": tr.get("catchphrase", ""),
            "color_hex": tr.get("color_hex", []),
            "illustration": tr.get("illustration", ""),
            "scores": tr.get("scores", {}),
        }

    return result