"""
api/views/auth_views.py
기존 back/routers/auth_router.py → Django view 변환
"""
import os
from urllib.parse import urlencode
from django.http import JsonResponse, HttpResponseRedirect
from django.views.decorators.csrf import csrf_exempt
from services.auth_service import (
    get_google_login_url, google_callback,
    get_kakao_login_url, kakao_callback,
    get_naver_login_url, naver_callback,
)

FRONTEND_BASE_URL = os.getenv("FRONTEND_BASE_URL", "http://localhost:5173")


def google_login(request):
    url = get_google_login_url()
    return HttpResponseRedirect(url)


async def google_callback_handler(request):
    code = request.GET.get("code", "")
    try:
        result = await google_callback(code)
        token = result["access_token"]
        is_new = result.get("is_new", False)
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'token': token, 'provider': 'google', 'is_new': str(is_new).lower()})}"
        )
    except Exception as e:
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'error': str(e)})}"
        )


def kakao_login(request):
    url = get_kakao_login_url()
    return HttpResponseRedirect(url)


async def kakao_callback_handler(request):
    code = request.GET.get("code", "")
    try:
        result = await kakao_callback(code)
        token = result["access_token"]
        is_new = result.get("is_new", False)
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'token': token, 'provider': 'kakao', 'is_new': str(is_new).lower()})}"
        )
    except Exception as e:
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'error': str(e)})}"
        )


def naver_login(request):
    url = get_naver_login_url()
    return HttpResponseRedirect(url)


async def naver_callback_handler(request):
    code = request.GET.get("code", "")
    state = request.GET.get("state", "")
    try:
        result = await naver_callback(code, state)
        token = result["access_token"]
        is_new = result.get("is_new", False)
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'token': token, 'provider': 'naver', 'is_new': str(is_new).lower()})}"
        )
    except Exception as e:
        return HttpResponseRedirect(
            f"{FRONTEND_BASE_URL}/oauth/callback?{urlencode({'error': str(e)})}"
        )
