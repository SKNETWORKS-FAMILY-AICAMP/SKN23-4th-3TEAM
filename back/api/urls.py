"""
api/urls.py
─────────────────────────────────────────────
기존 FastAPI 라우터의 prefix + endpoint를 Django URL 패턴으로 매핑.
"""
from django.urls import path
from api.views import (
    auth_views,
    chat_views,
    user_views,
    upload_views,
    keyword_views,
    analysis_views,
    wishlist_views,
    skin_mbti_views,
)

urlpatterns = [
    # ── Auth (/auth/...) ──
    path("auth/google/login",       auth_views.google_login),
    path("auth/google/callback",    auth_views.google_callback_handler),
    path("auth/kakao/login",        auth_views.kakao_login),
    path("auth/kakao/callback",     auth_views.kakao_callback_handler),
    path("auth/naver/login",        auth_views.naver_login),
    path("auth/naver/callback",     auth_views.naver_callback_handler),

    # ── Users (/users/...) ──
    path("users/signup",            user_views.signup),
    path("users/login",             user_views.login),
    path("users/me",                user_views.me),
    path("users/me/social-links",   user_views.social_links),
    path("users/check/email",       user_views.check_email),
    path("users/check/nickname",    user_views.check_nickname),
    path("users/email/send-code",   user_views.send_email_code),
    path("users/email/verify-code", user_views.verify_email_code),
    path("users/password/reset",    user_views.reset_password),
    path("users/admin/token",       user_views.admin_token),

    # ── Chats (/chats/...) ──
    path("chats",                              chat_views.chat_rooms),
    path("chats/guest/message",                chat_views.guest_message),
    path("chats/<int:chat_room_id>",           chat_views.chat_room_detail),
    path("chats/<int:chat_room_id>/messages",  chat_views.chat_messages),

    # ── Upload (/upload) ──
    path("upload",                  upload_views.upload_image),

    # ── Keywords (/keywords/...) ──
    path("keywords",                keyword_views.get_keywords),
    path("keywords/factorials",     keyword_views.get_factorials),

    # ── Analysis (/analysis/...) ──
    path("analysis",                            analysis_views.analysis_list),
    path("analysis/latest",                     analysis_views.latest_analysis),
    path("analysis/check/today",                analysis_views.check_today),
    path("analysis/dates",                      analysis_views.detailed_dates),
    path("analysis/by-date",                    analysis_views.by_date),
    path("analysis/model/<str:model_type>",     analysis_views.by_model_type),
    path("analysis/<int:analysis_id>",          analysis_views.analysis_detail),

    # ── Wishlist (/wishlist/...) ──
    path("wishlist",                            wishlist_views.wishlist),
    path("wishlist/<int:wish_id>",              wishlist_views.wishlist_detail),

    # ── Skin MBTI (/skin-mbti/...) ──
    path("skin-mbti",                           skin_mbti_views.skin_mbti),
    path("skin-mbti/<int:user_id>",             skin_mbti_views.skin_mbti_result),
]
