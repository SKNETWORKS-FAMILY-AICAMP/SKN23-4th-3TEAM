"""
config/settings.py
─────────────────────────────────────────────
Django 설정 파일.
기존 FastAPI main.py의 CORS, lifespan 등을 대체.
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# ─────────────────────────────────────────────
# 경로 설정
# ─────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent

# back/ 상위(프로젝트 루트)를 sys.path에 추가 → ai/ 패키지 import 가능
PROJECT_ROOT = BASE_DIR.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "django-insecure-changeme-in-production")

DEBUG = os.getenv("DEBUG", "True").lower() in ("true", "1", "yes")

ALLOWED_HOSTS = ["*"]

# ─────────────────────────────────────────────
# 앱 등록
# ─────────────────────────────────────────────
INSTALLED_APPS = [
    "corsheaders",
    "api",
]

# ─────────────────────────────────────────────
# 미들웨어
# ─────────────────────────────────────────────
MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
]

# ─────────────────────────────────────────────
# CORS 설정 (기존 main.py와 동일)
# ─────────────────────────────────────────────
CORS_ALLOWED_ORIGINS = os.getenv(
    "CORS_ORIGINS",
    "http://localhost:5173,http://localhost:3000"
).split(",")

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOW_METHODS = ["*"]
CORS_ALLOW_HEADERS = ["*"]

# ─────────────────────────────────────────────
# URL / WSGI
# ─────────────────────────────────────────────
ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"

# ─────────────────────────────────────────────
# DB 초기화 (기존 lifespan 대체)
# Django는 AppConfig.ready()에서 처리
# ─────────────────────────────────────────────
# Django ORM 미사용 → DATABASES 설정 불필요
DATABASES = {}

# ─────────────────────────────────────────────
# 기타
# ─────────────────────────────────────────────
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
LANGUAGE_CODE = "ko-kr"
TIME_ZONE = "Asia/Seoul"
USE_TZ = True

# 정적 파일 (Django admin 미사용이므로 최소 설정)
STATIC_URL = "static/"

# Django 템플릿 미사용
TEMPLATES = []
