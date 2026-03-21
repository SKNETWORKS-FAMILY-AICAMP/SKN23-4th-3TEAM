"""
config/urls.py
─────────────────────────────────────────────
최상위 URL 라우팅.
기존 FastAPI의 app.include_router() 매핑을 대체.
"""
from django.urls import path, include

urlpatterns = [
    # api/ 앱의 URL을 루트에 바로 매핑 (prefix 없음)
    # 각 view의 prefix는 api/urls.py에서 설정
    path("", include("api.urls")),
]
