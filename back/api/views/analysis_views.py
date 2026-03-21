"""
api/views/analysis_views.py
기존 back/routers/analysis_router.py → Django view 변환
"""
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from api.middleware import require_auth, parse_json_body
from services import analysis_service
from db.schemas import AnalysisCreate


def _to_response(result) -> dict:
    return {
        "analysis_id": result.analysis_id,
        "user_id": result.user_id,
        "model_type": result.model_type,
        "skin_score": result.skin_score,
        "image_url": result.image_urls or [],
        "factorial": result.factorial or [],
        "analysis_data": result.analysis_data,
        "created_at": result.created_at.isoformat() if result.created_at else None,
    }


@csrf_exempt
@require_auth
def analysis_list(request, user_id):
    if request.method == "POST":
        body = parse_json_body(request)
        if not body:
            return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)
        if body.get("user_id") != user_id:
            return JsonResponse({"detail": "접근 권한이 없습니다."}, status=403)
        try:
            data = AnalysisCreate(**body)
            result = analysis_service.save_analysis(data)
            return JsonResponse(_to_response(result), status=201)
        except Exception as e:
            return JsonResponse({"detail": str(e)}, status=400)

    elif request.method == "GET":
        results = analysis_service.get_analysis_history(user_id)
        return JsonResponse([_to_response(r) for r in results], safe=False)

    return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)


@require_auth
def latest_analysis(request, user_id):
    result = analysis_service.get_latest_analysis(user_id)
    if not result:
        return JsonResponse({"detail": "분석 결과가 없습니다."}, status=404)
    return JsonResponse(_to_response(result))


@require_auth
def check_today(request, user_id):
    return JsonResponse({"available": not analysis_service.has_today_detailed_analysis(user_id)})


@require_auth
def detailed_dates(request, user_id):
    dates = analysis_service.get_detailed_dates(user_id)
    return JsonResponse({"dates": dates})


@require_auth
def by_date(request, user_id):
    dates = request.GET.getlist("dates")
    response = []
    for d in sorted(dates):
        result = analysis_service.get_detailed_by_date(user_id, str(d))
        response.append({
            "date": str(d),
            "result": _to_response(result) if result else None,
        })
    return JsonResponse(response, safe=False)


@require_auth
def by_model_type(request, model_type, user_id):
    results = analysis_service.get_analysis_by_model_type(user_id, model_type)
    return JsonResponse([_to_response(r) for r in results], safe=False)


@csrf_exempt
@require_auth
def analysis_detail(request, analysis_id, user_id):
    result = analysis_service.get_analysis_by_id(analysis_id)
    if not result:
        return JsonResponse({"detail": "분석 결과를 찾을 수 없습니다."}, status=404)
    if result.user_id != user_id:
        return JsonResponse({"detail": "접근 권한이 없습니다."}, status=403)

    if request.method == "GET":
        return JsonResponse(_to_response(result))
    elif request.method == "DELETE":
        analysis_service.delete_analysis(analysis_id)
        return JsonResponse({}, status=204)

    return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)
