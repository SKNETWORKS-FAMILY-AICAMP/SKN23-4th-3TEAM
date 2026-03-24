"""
cleanup_scheduler.py
─────────────────────────────────────────────────────────────
역할  : 탈퇴 후 10일이 지난 사용자를 매일 자정에 하드 삭제
─────────────────────────────────────────────────────────────
"""

import logging
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
from db.db_manager import execute_query
from services import user_service

logger     = logging.getLogger(__name__)
_scheduler: BackgroundScheduler | None = None

DELETION_GRACE_PERIOD = timedelta(days=10)


def _run_hard_delete():
    """
    deleted_at이 10일(정확히 240시간) 이상 지난 사용자 하드 삭제.
    매일 자정(00:00 KST) 실행.
    """
    cutoff = datetime.now() - DELETION_GRACE_PERIOD

    rows = execute_query(
        "SELECT user_id FROM users WHERE deleted_at IS NOT NULL AND deleted_at <= %s",
        (cutoff,)
    )

    if not rows:
        logger.info("[cleanup] 하드 삭제 대상 없음")
        return

    logger.info(f"[cleanup] 하드 삭제 대상 {len(rows)}명")

    for row in rows:
        try:
            user_service.hard_delete_user(row["user_id"])
            logger.info(f"[cleanup] user_id={row['user_id']} 하드 삭제 완료")
        except Exception as e:
            logger.error(f"[cleanup] user_id={row['user_id']} 삭제 실패: {e}")


def start_scheduler():
    """앱 시작 시 스케줄러 등록 (main.py lifespan에서 호출)."""
    global _scheduler
    _scheduler = BackgroundScheduler(timezone="Asia/Seoul")
    _scheduler.add_job(_run_hard_delete, "cron", hour=0, minute=0)
    _scheduler.start()
    logger.info("[cleanup] 스케줄러 시작 (매일 00:00 KST 실행)")


def stop_scheduler():
    """앱 종료 시 스케줄러 정지."""
    if _scheduler and _scheduler.is_running:
        _scheduler.shutdown()
        logger.info("[cleanup] 스케줄러 종료")