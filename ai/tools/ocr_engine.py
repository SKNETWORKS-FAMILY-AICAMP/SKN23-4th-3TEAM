"""
ocr_engine.py
─────────────────────────────────────────────
GPT-4o-mini Vision 기반 화장품 전성분 OCR 엔진

역할:
  1) 이미지를 GPT-4o-mini에 전송
  2) 전성분 영역만 추출하도록 프롬프트로 지시
  3) 성분 리스트를 정제하여 반환

입력: 이미지 bytes
출력: {
    "mode": "ingredient",
    "product_name": str,
    "brand": str,
    "ingredients": list[str],
    "ingredient_count": int,
    "raw_text": str,
    "source": "gpt_vision",
}
"""

import json
import base64
from openai import OpenAI

from ai.config.settings import OPENAI_API_KEY

_CLIENT = None

def _get_client() -> OpenAI:
    global _CLIENT
    if _CLIENT is None:
        _CLIENT = OpenAI(api_key=OPENAI_API_KEY)
    return _CLIENT


OCR_PROMPT = """\
너는 화장품 전성분 추출 전문가이다.

사용자가 보낸 화장품 사진에서 아래 정보를 추출해라.

[추출 규칙]
1. "전성분", "[전성분]", "Ingredients", "성분" 등의 키워드를 찾아서 그 뒤에 나오는 성분 목록만 추출한다.
2. "주의사항", "사용방법", "보관방법", "제조번호" 등이 나오면 성분 목록이 끝난 것이다.
3. 성분명은 한국어 기준으로 추출한다. 영문 성분명이 있으면 한국어로 변환한다.
4. 성분명 사이의 쉼표, 슬래시, 중점 등 구분자를 기준으로 개별 성분으로 분리한다.
5. 제품명과 브랜드명도 가능하면 추출한다.
6. 사진이 흐리거나 왜곡되어 있어도 최대한 읽어낸다.
7. 전성분을 찾을 수 없으면 ingredients를 빈 리스트로 반환한다.
8. 각 성분명에서 앞뒤 공백을 제거하고, 깨끗한 성분명만 남긴다.

[출력 형식 - 반드시 JSON만 출력]
{
  "product_name": "제품명 (못 찾으면 빈 문자열)",
  "brand": "브랜드명 (못 찾으면 빈 문자열)",
  "ingredients": ["성분1", "성분2", "성분3", ...],
  "raw_text": "전성분 영역의 원본 텍스트"
}
"""


def run_ocr(image_bytes: bytes) -> dict:
    """
    화장품 이미지에서 전성분을 추출하는 메인 함수.

    Args:
        image_bytes: 이미지 파일의 바이트 데이터

    Returns:
        {
            "mode": "ingredient",
            "product_name": str,
            "brand": str,
            "ingredients": list[str],
            "ingredient_count": int,
            "raw_text": str,
            "source": "gpt_vision",
        }
    """
    print("[OCR] GPT-4o-mini Vision 분석 시작", flush=True)

    client = _get_client()
    b64 = base64.b64encode(image_bytes).decode("utf-8")

    try:
        resp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{
                "role": "user",
                "content": [
                    {"type": "text", "text": OCR_PROMPT},
                    {"type": "image_url", "image_url": {
                        "url": f"data:image/jpeg;base64,{b64}",
                        "detail": "high",
                    }},
                ],
            }],
            max_tokens=2000,
            temperature=0.1,
            response_format={"type": "json_object"},
        )

        raw_content = resp.choices[0].message.content
        print(f"[OCR] GPT 응답 수신 ({len(raw_content)}자)", flush=True)

        result = json.loads(raw_content)

        ingredients = result.get("ingredients", [])
        # 정제: 빈 문자열, 너무 짧은 것, 숫자만 있는 것 제외
        ingredients = [
            ing.strip() for ing in ingredients
            if ing and len(ing.strip()) >= 2
        ]

        product_name = result.get("product_name", "").strip()
        brand = result.get("brand", "").strip()
        raw_text = result.get("raw_text", "")

        print(f"[OCR] 추출 완료: 성분 {len(ingredients)}개 | 제품명='{product_name}' | 브랜드='{brand}'", flush=True)
        if ingredients:
            print(f"[OCR] 성분 목록: {', '.join(ingredients[:10])}{'...' if len(ingredients) > 10 else ''}", flush=True)

        return {
            "mode": "ingredient",
            "product_name": product_name,
            "brand": brand,
            "ingredients": ingredients,
            "ingredient_count": len(ingredients),
            "raw_text": raw_text,
            "source": "gpt_vision",
        }

    except json.JSONDecodeError as e:
        print(f"[OCR] JSON 파싱 실패: {repr(e)}", flush=True)
        return {
            "mode": "ingredient",
            "product_name": "",
            "brand": "",
            "ingredients": [],
            "ingredient_count": 0,
            "raw_text": "",
            "source": "gpt_vision",
            "error": "성분 정보를 추출하지 못했어요. 전성분이 잘 보이도록 다시 촬영해주세요.",
        }
    except Exception as e:
        print(f"[OCR] GPT Vision 호출 실패: {repr(e)}", flush=True)
        return {
            "mode": "ingredient",
            "product_name": "",
            "brand": "",
            "ingredients": [],
            "ingredient_count": 0,
            "raw_text": "",
            "source": "gpt_vision",
            "error": "성분 분석 중 오류가 발생했어요. 다시 시도해주세요.",
        }