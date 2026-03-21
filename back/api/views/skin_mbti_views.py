"""
api/views/skin_mbti_views.py
기존 back/routers/skin_mbti_router.py → Django view 변환
"""
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from api.middleware import parse_json_body
from services.skin_mbti_service import calculate_mbti, get_saved_mbti_result


@csrf_exempt
def skin_mbti(request):
    """POST: 피부 MBTI 결과 계산 + DB 저장"""
    if request.method != "POST":
        return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)

    body = parse_json_body(request)
    if not body:
        return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)

    answers = body.get("answers", [])
    user_id = body.get("user_id")

    if not user_id:
        return JsonResponse({"detail": "user_id가 필요합니다."}, status=400)

    if len(answers) != 12:
        return JsonResponse({"detail": "answers는 반드시 12개여야 합니다."}, status=422)

    valid = {"A", "B", "C", "D"}
    for i, ans in enumerate(answers):
        if ans.upper() not in valid:
            return JsonResponse({"detail": f"Q{i+1}의 답변은 A, B, C, D 중 하나여야 합니다."}, status=422)

    answers = [a.upper() for a in answers]

    try:
        result = calculate_mbti(answers, user_id)
        return JsonResponse({"success": True, "data": result, "error": None})
    except ValueError as e:
        return JsonResponse({"detail": str(e)}, status=422)
    except Exception as e:
        return JsonResponse({"detail": str(e)}, status=500)


def skin_mbti_result(request, user_id):
    """GET: 저장된 MBTI 결과 조회"""
    try:
        result = get_saved_mbti_result(user_id)
        return JsonResponse({"success": True, "data": result, "error": None})
    except Exception as e:
        return JsonResponse({"detail": str(e)}, status=500)
