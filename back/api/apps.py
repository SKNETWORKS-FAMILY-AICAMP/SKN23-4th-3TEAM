from django.apps import AppConfig


class ApiConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "api"

    def ready(self):
        """앱 시작 시 DB 초기화 (기존 FastAPI lifespan 대체)"""
        import os
        if os.environ.get("RUN_MAIN") == "true":  # runserver 중복 실행 방지
            try:
                from db.db_manager import init_db
                init_db()
            except Exception as e:
                print(f"[Django] DB 초기화 실패: {e}", flush=True)
