# back/services/skin_mbti_service.py

import json
from typing import List, Dict

from db.db_manager import execute_write, execute_one


# ────────────────────────────────────────────
# 결과 데이터 (Flutter SkinMbtiResult 구조 완전 일치)
# ────────────────────────────────────────────
MBTI_RESULT_MAP = {
    "SBC": {
        "code": "SBC",
        "title": "포근포근 보송가나디",
        "subtitle": "기본 보습형",
        "description": "복잡한 루틴보다 순하고 편한 기본템을 꾸준히 쓰는 타입이에요.",
        "habits": "스킨케어를 많이 하기보다 피부가 편안한 상태를 오래 유지하는 걸 더 중요하게 생각해요. 새로운 제품을 자주 바꾸기보다 익숙하고 무난한 제품을 오래 쓰는 편이에요.",
        "morning_routine": [
            "약산성 클렌저 또는 물세안",
            "가벼운 수분 로션 또는 수분크림",
            "데일리 선크림 고정",
        ],
        "night_routine": [
            "순한 세안",
            "보습 토너 또는 미스트 1회",
            "장벽 크림으로 마무리",
        ],
        "care_tips": [
            "세안-보습-선크림 3단계 기본 루틴을 안정적으로 유지해보세요.",
            "건조한 날에는 토너를 여러 번 덧바르기보다 크림 양을 조금 늘리는 편이 더 잘 맞아요.",
            "피부가 많이 흔들리지 않는다면 기능성 제품은 하나만 천천히 추가해보세요.",
        ],
        "avoid_habits": [
            "너무 무난한 제품만 고집해서 필요한 고민 케어를 미루는 것",
            "선크림을 '오늘은 괜찮겠지' 하고 자주 빼먹는 것",
            "건조한데도 루틴을 너무 가볍게 유지하는 것",
        ],
        "chatbot_suggestion": "기본 보습 루틴 추천받기",
        "image_asset": "assets/images/skin_mbti/cozy_soft_dog.png",
        "background_color": "0xFFF4E6D4",
        "accent_color": "0xFF9B7B52",
    },
    "SBF": {
        "code": "SBF",
        "title": "진정해라냥",
        "subtitle": "응급 진정형",
        "description": "평소엔 심플하지만 피부가 흔들리면 바로 진정 루틴으로 전환하는 타입이에요.",
        "habits": "평소에는 루틴이 단순하지만 트러블, 붉어짐, 예민함이 생기면 진정템을 열심히 찾는 편이에요. 평소 관리보다 문제 생겼을 때 회복 모드가 더 강한 타입이에요.",
        "morning_routine": [
            "물세안 또는 아주 순한 세안",
            "진정 세럼 1개",
            "저자극 수분크림 + 순한 선크림",
        ],
        "night_routine": [
            "자극 적은 클렌징",
            "진정 앰플 또는 시카 세럼 1개",
            "장벽 크림 도톰하게 마무리",
        ],
        "care_tips": [
            "평소 기본 루틴과 응급 진정 루틴을 따로 나눠두면 훨씬 안정적이에요.",
            "피부가 뒤집혔을 때는 제품을 더하는 것보다 자극을 줄이는 게 먼저예요.",
            "진정템은 1~2개만 고정해서 써야 피부가 덜 피곤해져요.",
        ],
        "avoid_habits": [
            "피부가 예민한 날 팩, 앰플, 진정크림을 한꺼번에 늘리는 것",
            "평소엔 방치하다가 상태가 안 좋아지면 과하게 케어하는 것",
            "각질 제거를 멈추지 않는 것",
        ],
        "chatbot_suggestion": "피부 뒤집힘 응급 루틴 보기",
        "image_asset": "assets/images/skin_mbti/calm_down_cat.png",
        "background_color": "0xFFE8F4D8",
        "accent_color": "0xFF7FA35A",
    },
    "STC": {
        "code": "STC",
        "title": "세럼 촉촉 토끼",
        "subtitle": "미니 기능성형",
        "description": "많이 바르진 않아도 효과 있는 세럼 하나는 꼭 챙기고 싶은 실속형이에요.",
        "habits": "루틴은 길지 않지만 세럼 하나, 앰플 하나는 꼭 챙기고 싶어 해요. 여러 단계를 쌓는 건 귀찮지만 효과가 느껴지는 핵심 아이템은 놓치고 싶지 않은 타입이에요.",
        "morning_routine": [
            "가벼운 수분 토너 또는 세럼",
            "저농도 기능성 세럼 1개",
            "보습제 + 선크림",
        ],
        "night_routine": [
            "순한 세안",
            "고민별 세럼 1개만 사용",
            "크림으로 마무리",
        ],
        "care_tips": [
            "기능성 세럼 1개 + 기본 보습템 1개 조합이 가장 잘 맞아요.",
            "아침엔 수분/진정, 저녁엔 고민 케어처럼 역할을 나눠보세요.",
            "미백, 트러블, 결 개선 중 우선순위를 하나 정해서 가는 게 좋아요.",
        ],
        "avoid_habits": [
            "세럼 하나로 모든 걸 해결하려고 하는 것",
            "효과를 빨리 보고 싶어 너무 센 농도의 세럼만 찾는 것",
            "효과가 늦다고 너무 빨리 갈아타는 것",
        ],
        "chatbot_suggestion": "내 고민별 세럼 찾기",
        "image_asset": "assets/images/skin_mbti/dewy_serum_bunny.png",
        "background_color": "0xFFFFF0B8",
        "accent_color": "0xFFB08A1B",
    },
    "STF": {
        "code": "STF",
        "title": "번쩍 케어 여우",
        "subtitle": "즉시 솔루션형",
        "description": "피부 고민이 보이면 빠르게 해결하고 싶은 문제 해결형이에요.",
        "habits": "트러블, 각질, 칙칙함, 푸석함 같은 고민이 보이면 바로 해결하고 싶어 해요. 피부를 천천히 키운다기보다 빨리 정상화하고 싶은 성향이 강한 편이에요.",
        "morning_routine": [
            "가벼운 세안",
            "수분 진정 베이스 간단히",
            "문제 부위에 맞는 기능성 1개 + 선크림",
        ],
        "night_routine": [
            "충분한 세안",
            "고민별 집중템 1개만 선택",
            "장벽 크림으로 마무리",
        ],
        "care_tips": [
            "문제 하나당 해결템 하나 원칙으로 접근해보세요.",
            "각질, 트러블, 미백 케어를 한 번에 시작하지 말고 순서를 나눠주세요.",
            "기능성 제품을 쓸수록 보습크림은 더 단순하고 든든하게 가는 게 좋아요.",
        ],
        "avoid_habits": [
            "효과를 빨리 보고 싶어서 여러 기능성 제품을 동시에 쓰는 것",
            "좋아질 것 같은 조합을 한꺼번에 시도하는 것",
            "피부가 예민한데도 강한 케어를 멈추지 않는 것",
        ],
        "chatbot_suggestion": "문제별 집중 케어 추천",
        "image_asset": "assets/images/skin_mbti/quick_fix_fox.png",
        "background_color": "0xFFFFD4AD",
        "accent_color": "0xFFC46F2B",
    },
    "LBC": {
        "code": "LBC",
        "title": "든든 수호곰",
        "subtitle": "장벽 루틴형",
        "description": "토너-세럼-크림을 안정적으로 쌓으며 피부 장벽을 지키는 타입이에요.",
        "habits": "토너, 세럼, 크림을 성실하게 챙기되 중심은 늘 보습과 진정에 있어요. 새 유행보다 내 피부가 편안한지가 더 중요하고, 피부가 무너지지 않게 지키는 데 강한 타입이에요.",
        "morning_routine": [
            "수분 토너",
            "진정 세럼",
            "장벽 보습제 + 선크림",
        ],
        "night_routine": [
            "순한 세안",
            "수분 레이어링",
            "장벽 크림 충분히",
        ],
        "care_tips": [
            "수분 토너 → 진정 세럼 → 장벽 크림 흐름으로 정리하면 잘 맞아요.",
            "환절기와 겨울엔 크림 비중을 높이고, 여름엔 제형만 가볍게 조절해보세요.",
            "레이어링의 목적은 효과 추가보다 보호와 회복에 두는 게 좋아요.",
        ],
        "avoid_habits": [
            "좋은 보습템, 진정템을 이것저것 겹쳐 루틴이 너무 무거워지는 것",
            "장벽만 지키다 기능성 케어 시작 타이밍을 놓치는 것",
            "답답한 제형을 과하게 겹치는 것",
        ],
        "chatbot_suggestion": "장벽 강화 루틴 보기",
        "image_asset": "assets/images/skin_mbti/barrier_guard_bear.png",
        "background_color": "0xFFBFE5DC",
        "accent_color": "0xFF2E8D7A",
    },
    "LBF": {
        "code": "LBF",
        "title": "성분탐험 다람쥐",
        "subtitle": "탐색 진정형",
        "description": "순한 제품을 좋아하면서도 성분과 궁합을 꼼꼼히 따지는 탐색형이에요.",
        "habits": "자극 없는 제품을 선호하지만 그냥 아무거나 쓰지는 않아요. 성분표, 후기, 피부타입 궁합을 꼼꼼히 보고, 순한 것 중에서도 더 잘 맞는 제품을 찾고 싶어 하는 타입이에요.",
        "morning_routine": [
            "순한 토너 또는 미스트",
            "진정 세럼 1개",
            "가벼운 보습제 + 선크림",
        ],
        "night_routine": [
            "순한 세안",
            "장벽/진정 앰플",
            "수분크림 또는 장벽 크림",
        ],
        "care_tips": [
            "새 제품은 기존 루틴에 하나씩만 추가하는 방식이 좋아요.",
            "잘 맞는 성분 / 안 맞는 성분을 기록해두면 훨씬 정교해져요.",
            "비교는 충분히 하되, 사용 제품 수는 줄이는 게 좋아요.",
        ],
        "avoid_habits": [
            "순한 제품이라고 여러 개를 한꺼번에 겹쳐 쓰는 것",
            "정보가 많아질수록 루틴이 길어지는 것",
            "성분 비교만 하고 정착이 늦어지는 것",
        ],
        "chatbot_suggestion": "성분 궁합 분석하기",
        "image_asset": "assets/images/skin_mbti/ingredient_explorer_squirrel.png",
        "background_color": "0xFFE1D0AC",
        "accent_color": "0xFF8B6B3C",
    },
    "LTC": {
        "code": "LTC",
        "title": "루틴 백조",
        "subtitle": "정교한 기능성형",
        "description": "아침/저녁 루틴을 계획적으로 나누는 체계형 기능성 케어 타입이에요.",
        "habits": "기능성 제품을 무턱대고 쓰기보다 아침/저녁, 요일별, 피부 고민별로 구분해 관리하는 편이에요. 정리된 루틴을 좋아하고 질서 있게 굴러갈 때 만족도가 커요.",
        "morning_routine": [
            "가벼운 세안",
            "항산화/진정 위주 세럼",
            "보습제 + 선크림",
        ],
        "night_routine": [
            "꼼꼼한 세안",
            "기능성 세럼 또는 레티놀 계열",
            "보습·회복 크림으로 마무리",
        ],
        "care_tips": [
            "비타민C는 아침, 레티놀은 밤처럼 시간대별로 분리해보세요.",
            "기본 보습이 받쳐준 상태에서 기능성 제품을 올리면 훨씬 안정적이에요.",
            "주간 루틴표를 만들어두면 루틴 관리가 쉬워져요.",
        ],
        "avoid_habits": [
            "계획이 잘 짜여 있을수록 피부가 힘들다는 신호를 늦게 알아차리는 것",
            "기능성 루틴을 너무 빡빡하게 고정하는 것",
            "피부가 예민한 날에도 계획대로 밀어붙이는 것",
        ],
        "chatbot_suggestion": "아침/저녁 루틴 설계하기",
        "image_asset": "assets/images/skin_mbti/routine_swan.png",
        "background_color": "0xFFF2DDE4",
        "accent_color": "0xFFAF6F86",
    },
    "LTF": {
        "code": "LTF",
        "title": "열쩡햄쮜",
        "subtitle": "과몰입 케어형",
        "description": "스킨케어에 진심이고 실행력도 높지만 과관리로 흐르기 쉬운 타입이에요.",
        "habits": "스킨케어 관심도도 높고 신제품도 잘 찾아보며, 좋다 하면 바로 써보고 싶어 해요. 실행력이 높은 만큼 제품도 많아지고 루틴도 무거워지기 쉬운 타입이에요.",
        "morning_routine": [
            "세안 후 진정/보습 위주로 최대한 단순하게",
            "기능성은 꼭 필요한 1개만",
            "선크림으로 마무리",
        ],
        "night_routine": [
            "충분한 세안",
            "기능성 제품 1개만 선택",
            "회복 크림으로 마무리",
        ],
        "care_tips": [
            "루틴을 더 추가하기보다 루틴 다이어트부터 시작해보세요.",
            "세럼 3개보다 세럼 1개, 기능성 4개보다 핵심 기능성 1개가 더 잘 맞을 수 있어요.",
            "한 주 단위로 유지할 제품과 쉬어갈 제품을 나눠보세요.",
        ],
        "avoid_habits": [
            "좋은 성분을 다 넣으면 더 좋을 거라고 생각하는 것",
            "과한 각질 케어, 기능성 중복, 잦은 제품 교체",
            "피부가 예민한데도 루틴을 줄이지 않는 것",
        ],
        "chatbot_suggestion": "내 루틴 과한지 체크하기",
        "image_asset": "assets/images/skin_mbti/passionate_hamster.png",
        "background_color": "0xFFFFA6C9",
        "accent_color": "0xFFD94F8A",
    },
}

# ────────────────────────────────────────────
# MBTI 저장 결과 가져오는 함수
# ────────────────────────────────────────────
def get_saved_mbti_result(user_id: int):
    sql = """
        SELECT result_json
        FROM user_test_results
        WHERE user_id = %s
          AND test_type = %s
        LIMIT 1
    """
    row = execute_one(sql, (user_id, "skin_mbti"))

    if not row:
        return None

    raw = row.get("result_json")

    if raw is None:
        return None

    if isinstance(raw, dict):
        return raw

    if isinstance(raw, str):
        try:
            return json.loads(raw)
        except Exception as e:
            print("[skin_mbti] json.loads failed:", e)
            raise RuntimeError(f"result_json 파싱 실패: {raw}") from e

    return raw

# 축별 문항 인덱스 (0-based: Q1=0, Q2=1, ...)
SL_INDICES = [0, 3, 6, 9]   # Q1, Q4, Q7, Q10
BT_INDICES = [1, 4, 7, 10]  # Q2, Q5, Q8, Q11
CF_INDICES = [2, 5, 8, 11]  # Q3, Q6, Q9, Q12


# ────────────────────────────────────────────
# 동점 처리: 핵심 문항(해당 축 앞 2개) 재판정
# ────────────────────────────────────────────
def _resolve_tie(answers: List[str], indices: List[int]) -> bool:
    """동점 시 해당 축의 앞 2개 문항에서 A/B가 1개 이상이면 True(긍정 축 우세)"""
    return sum(1 for i in indices[:2] if answers[i] in ("A", "B")) >= 1


# ────────────────────────────────────────────
# 메인 계산 함수
# ────────────────────────────────────────────
def calculate_mbti(answers: List[str], user_id: int) -> Dict:
    answers = [a.upper() for a in answers]

    s = l = b = t = c = f = 0

    for idx, ans in enumerate(answers):
        if idx in SL_INDICES:
            if ans in ("A", "B"):
                s += 1
            else:
                l += 1
        elif idx in BT_INDICES:
            if ans in ("A", "B"):
                b += 1
            else:
                t += 1
        elif idx in CF_INDICES:
            if ans in ("A", "B"):
                c += 1
            else:
                f += 1

    # 동점이면 핵심 문항 재판정, 그래도 동점이면 S/B/C 우선
    if s != l:
        first = "S" if s > l else "L"
    else:
        first = "S" if _resolve_tie(answers, SL_INDICES) else "L"

    if b != t:
        second = "B" if b > t else "T"
    else:
        second = "B" if _resolve_tie(answers, BT_INDICES) else "T"

    if c != f:
        third = "C" if c > f else "F"
    else:
        third = "C" if _resolve_tie(answers, CF_INDICES) else "F"

    mbti_code = first + second + third
    result = MBTI_RESULT_MAP[mbti_code]

    # DB 저장용 JSON (Flutter 표시용 데이터 전체)
    result_json = {
        "mbti_code": mbti_code,
        "result": result,
        "score": {"S": s, "L": l, "B": b, "T": t, "C": c, "F": f},
    }

    # 재검사 시 덮어쓰기 (ON DUPLICATE KEY UPDATE)
    # user_test_results에 (user_id, test_type) UNIQUE 제약이 있을 경우 자동 갱신
    sql = """
        INSERT INTO user_test_results
            (user_id, test_type, result_code, result_json)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            result_code = VALUES(result_code),
            result_json = VALUES(result_json),
            updated_at  = CURRENT_TIMESTAMP
    """
    execute_write(sql, (
        user_id,
        "skin_mbti",
        mbti_code,
        json.dumps(result_json, ensure_ascii=False),
    ))

    return result_json