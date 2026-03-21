"""
config/wsgi.py
WSGI 진입점. 배포 시 gunicorn 등에서 사용.
"""
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
application = get_wsgi_application()
