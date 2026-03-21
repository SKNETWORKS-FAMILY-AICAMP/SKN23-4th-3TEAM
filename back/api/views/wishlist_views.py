"""
api/views/wishlist_views.py
기존 back/routers/wishlist_router.py → Django view 변환
"""
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from api.middleware import require_auth, parse_json_body
from services import analysis_service
from db.schemas import WishlistAdd


def _to_response(wish) -> dict:
    return {
        "wish_id": wish.wish_id,
        "user_id": wish.user_id,
        "product_name": wish.product_name,
        "product_url": wish.product_url,
        "message_id": wish.message_id,
        "added_at": wish.added_at.isoformat() if wish.added_at else None,
    }


@csrf_exempt
@require_auth
def wishlist(request, user_id):
    if request.method == "GET":
        items = analysis_service.get_wishlist_by_user(user_id)
        return JsonResponse([_to_response(w) for w in items], safe=False)

    elif request.method == "POST":
        body = parse_json_body(request)
        if not body:
            return JsonResponse({"detail": "잘못된 요청입니다."}, status=400)
        if body.get("user_id") != user_id:
            return JsonResponse({"detail": "접근 권한이 없습니다."}, status=403)
        try:
            data = WishlistAdd(**body)
            wish = analysis_service.add_to_wishlist(data)
            return JsonResponse(_to_response(wish), status=201)
        except ValueError as e:
            return JsonResponse({"detail": str(e)}, status=400)

    return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)


@csrf_exempt
@require_auth
def wishlist_detail(request, wish_id, user_id):
    if request.method == "DELETE":
        success = analysis_service.remove_from_wishlist(wish_id, user_id)
        if not success:
            return JsonResponse({"detail": "위시리스트 항목을 찾을 수 없습니다."}, status=404)
        return JsonResponse({}, status=204)

    return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)
