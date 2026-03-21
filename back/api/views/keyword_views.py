"""
api/views/keyword_views.py
기존 back/routers/keyword_router.py → Django view 변환
"""
from django.http import JsonResponse
from db import db_manager
from services import keyword_service


def get_keywords(request):
    kw_type = request.GET.get("type")
    if kw_type:
        rows = db_manager.execute_query("SELECT * FROM keywords WHERE type = %s ORDER BY keyword_id", (kw_type,))
    else:
        rows = db_manager.execute_query("SELECT * FROM keywords ORDER BY keyword_id")
    return JsonResponse(rows, safe=False)


def get_factorials(request):
    routines = keyword_service.get_skin_care_routines()
    return JsonResponse(routines, safe=False)
