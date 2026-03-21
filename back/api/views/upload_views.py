"""
api/views/upload_views.py
기존 back/routers/upload_router.py → Django view 변환
"""
import os
import uuid
import boto3
from botocore.exceptions import ClientError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from api.middleware import require_auth

S3_BUCKET = os.getenv("S3_BUCKET_NAME")
S3_REGION = os.getenv("AWS_REGION", "ap-northeast-2")
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png"}
MAX_FILE_SIZE = 10 * 1024 * 1024
FOLDER_MAP = {
    "simple": "skin-analysis",
    "detailed": "skin-analysis",
    "ingredient": "ingredient-analysis",
    "personal": "personal-analysis",
    "profile": "profile",
}


def _get_s3_client():
    return boto3.client("s3", region_name=S3_REGION)


@csrf_exempt
@require_auth
def upload_image(request, user_id):
    if request.method != "POST":
        return JsonResponse({"detail": "허용되지 않는 메서드입니다."}, status=405)

    if not S3_BUCKET:
        return JsonResponse({"detail": "S3_BUCKET_NAME 환경변수가 설정되지 않았습니다."}, status=500)

    file = request.FILES.get("file")
    if not file:
        return JsonResponse({"detail": "파일이 필요합니다."}, status=400)

    if file.content_type not in ALLOWED_CONTENT_TYPES:
        return JsonResponse({"detail": f"지원하지 않는 파일 형식입니다."}, status=400)

    if file.size > MAX_FILE_SIZE:
        return JsonResponse({"detail": "파일 크기는 10MB 이하여야 합니다."}, status=400)

    analysis_type = request.GET.get("analysis_type", "quick")
    folder = FOLDER_MAP.get(analysis_type, "other")
    ext = file.name.rsplit(".", 1)[-1].lower() if "." in file.name else "jpg"
    filename = "profile" if analysis_type == "profile" else str(uuid.uuid4())
    s3_key = f"{user_id}/{folder}/{filename}.{ext}"

    try:
        s3 = _get_s3_client()
        s3.upload_fileobj(file, S3_BUCKET, s3_key, ExtraArgs={"ContentType": file.content_type})
    except ClientError as e:
        return JsonResponse({"detail": f"S3 업로드 실패: {e.response['Error']['Message']}"}, status=500)

    s3_url = f"https://{S3_BUCKET}.s3.{S3_REGION}.amazonaws.com/{s3_key}"
    return JsonResponse({"url": s3_url})
