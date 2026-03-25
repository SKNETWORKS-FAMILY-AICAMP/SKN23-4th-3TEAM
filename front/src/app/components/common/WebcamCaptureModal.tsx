import { useEffect, useRef, useState, useCallback } from "react";
import { X, Camera } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

interface WebcamCaptureModalProps {
    open: boolean;
    onClose: () => void;
    onCapture: (file: File) => void;
}

export function WebcamCaptureModal({
    open,
    onClose,
    onCapture,
}: WebcamCaptureModalProps) {
    const videoRef = useRef<HTMLVideoElement | null>(null);
    const canvasRef = useRef<HTMLCanvasElement | null>(null);
    const streamRef = useRef<MediaStream | null>(null);

    const [isCameraReady, setIsCameraReady] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // 얼굴 감지 관련 state
    const [faceDetected, setFaceDetected] = useState(false);
    const [countdown, setCountdown] = useState<number | null>(null);
    const [isModelLoading, setIsModelLoading] = useState(true);
    const detectorRef = useRef<any>(null);
    const animFrameRef = useRef<number | null>(null);
    const countdownTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);
    const capturedRef = useRef(false);  // 중복 촬영 방지

    // 카메라 시작
    useEffect(() => {
        if (!open) return;

        capturedRef.current = false;

        const startCamera = async () => {
            try {
                setError(null);
                setIsCameraReady(false);

                const stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: "user" },
                    audio: false,
                });

                streamRef.current = stream;

                if (videoRef.current) {
                    videoRef.current.srcObject = stream;
                    videoRef.current.onloadedmetadata = () => {
                        videoRef.current?.play();
                        setIsCameraReady(true);
                    };
                }
            } catch (err) {
                console.error(err);
                setError("카메라를 실행할 수 없습니다. 브라우저 권한을 확인해주세요.");
            }
        };

        startCamera();

        return () => {
            if (streamRef.current) {
                streamRef.current.getTracks().forEach((track) => track.stop());
                streamRef.current = null;
            }
            if (animFrameRef.current) {
                cancelAnimationFrame(animFrameRef.current);
                animFrameRef.current = null;
            }
            if (countdownTimerRef.current) {
                clearInterval(countdownTimerRef.current);
                countdownTimerRef.current = null;
            }
            setIsCameraReady(false);
            setFaceDetected(false);
            setCountdown(null);
            setIsModelLoading(true);
        };
    }, [open]);

    // TensorFlow.js 얼굴 감지 모델 로드 + 실시간 감지 루프
    useEffect(() => {
        if (!open || !isCameraReady) return;

        let cancelled = false;

        const loadAndDetect = async () => {
            try {
                const faceDetection = await import("@tensorflow-models/face-detection");

                const detector = await faceDetection.createDetector(
                    faceDetection.SupportedModels.MediaPipeFaceDetector,
                    {
                        runtime: "mediapipe",
                        maxFaces: 1,
                        solutionPath: "https://cdn.jsdelivr.net/npm/@mediapipe/face_detection",
                    }
                );

                detectorRef.current = detector;
                if (!cancelled) setIsModelLoading(false);

                // 실시간 감지 루프
                const detectLoop = async () => {
                    if (cancelled || !videoRef.current || capturedRef.current) return;

                    try {
                        const faces = await detector.estimateFaces(videoRef.current);
                        if (!cancelled) {
                            const video = videoRef.current!;
                            const vw = video.videoWidth;
                            const vh = video.videoHeight;

                            // 가이드 영역 (화면 중앙 기준)
                            const guideCx = vw / 2;
                            const guideCy = vh / 2;
                            const guideW = vw * 0.45;
                            const guideH = vh * 0.7;

                            const isValidFace = faces.some((face: any) => {
                                // 1. keypoints 유효성 체크 (좌표가 전부 0이면 오탐)
                                const kps = face.keypoints || [];
                                const hasValidKeypoints = kps.some((kp: any) => kp.x > 0 && kp.y > 0);
                                if (!hasValidKeypoints) return false;

                                // 2. 얼굴 크기 체크 (화면의 20% 이상이어야 진짜 얼굴)
                                const box = face.box;
                                const faceW = box.width;
                                const faceH = box.height;
                                const minFaceSize = Math.min(vw, vh) * 0.2;
                                if (faceW < minFaceSize || faceH < minFaceSize) return false;

                                // 3. 가이드 영역 안에 얼굴 전체가 있는지 체크
                                const guideLeft = guideCx - guideW / 2;
                                const guideRight = guideCx + guideW / 2;
                                const guideTop = guideCy - guideH / 2;
                                const guideBottom = guideCy + guideH / 2;

                                if (box.xMin < guideLeft || box.xMax > guideRight ||
                                    box.yMin < guideTop || box.yMax > guideBottom) return false;

                                return true;
                            });

                            setFaceDetected(isValidFace);
                        }
                    } catch {
                        // 감지 실패 시 무시
                    }

                    // 약 5fps로 감지 (성능 최적화)
                    if (!cancelled) {
                        animFrameRef.current = window.setTimeout(() => {
                            requestAnimationFrame(detectLoop);
                        }, 200) as unknown as number;
                    }
                };

                detectLoop();
            } catch (err) {
                console.error("얼굴 감지 모델 로드 실패:", err);
                if (!cancelled) {
                    setIsModelLoading(false);
                    // 모델 로드 실패해도 수동 촬영은 가능하도록
                }
            }
        };

        loadAndDetect();

        return () => {
            cancelled = true;
        };
    }, [open, isCameraReady]);

    // 얼굴 감지 상태에 따라 카운트다운 시작/리셋
    useEffect(() => {
        if (capturedRef.current) return;

        if (faceDetected && countdown === null) {
            // 얼굴 감지됨 → 카운트다운 시작
            setCountdown(3);
        } else if (!faceDetected && countdown !== null) {
            // 얼굴 사라짐 → 카운트다운 리셋
            if (countdownTimerRef.current) {
                clearInterval(countdownTimerRef.current);
                countdownTimerRef.current = null;
            }
            setCountdown(null);
        }
    }, [faceDetected]);

    // 카운트다운 타이머
    useEffect(() => {
        if (countdown === null || capturedRef.current) return;

        if (countdown === 0) {
            // 카운트다운 종료 → 최종 얼굴 확인 후 촬영
            if (faceDetected) {
                capturedRef.current = true;
                handleCapture();
            } else {
                // 촬영 직전 얼굴 사라짐 → 리셋
                setCountdown(null);
            }
            return;
        }

        countdownTimerRef.current = setInterval(() => {
            setCountdown((prev) => {
                if (prev === null || prev <= 1) {
                    if (countdownTimerRef.current) {
                        clearInterval(countdownTimerRef.current);
                        countdownTimerRef.current = null;
                    }
                    return prev === null ? null : prev - 1;
                }
                return prev - 1;
            });
        }, 1000);

        return () => {
            if (countdownTimerRef.current) {
                clearInterval(countdownTimerRef.current);
                countdownTimerRef.current = null;
            }
        };
    }, [countdown]);

    const handleCapture = useCallback(() => {
        if (!videoRef.current || !canvasRef.current) return;

        const video = videoRef.current;
        const canvas = canvasRef.current;
        const ctx = canvas.getContext("2d");

        if (!ctx) return;

        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

        canvas.toBlob((blob) => {
            if (!blob) return;

            const file = new File([blob], "webcam-capture.jpg", {
                type: "image/jpeg",
            });

            onCapture(file);
        }, "image/jpeg", 0.95);
    }, [onCapture]);

    // 가이드 테두리 색상
    const guideColor = faceDetected
        ? countdown !== null && countdown > 0
            ? "border-yellow-400"   // 카운트다운 중
            : "border-green-400"    // 얼굴 감지됨
        : "border-white/80";        // 대기 중

    // 상태 텍스트
    const statusText = isModelLoading
        ? "얼굴 감지 모델 로딩 중..."
        : capturedRef.current
            ? "촬영 완료!"
            : faceDetected
                ? countdown !== null && countdown > 0
                    ? `${countdown}초 후 자동 촬영`
                    : "얼굴 감지됨! 카운트다운 시작..."
                : "얼굴을 중앙 가이드 안에 맞춰주세요";

    return (
        <AnimatePresence>
            {open && (
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className="fixed inset-0 z-[60] flex items-center justify-center bg-black/70 px-4"
                    onClick={onClose}
                >
                    <motion.div
                        initial={{ scale: 0.96, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0.96, opacity: 0 }}
                        transition={{ duration: 0.2 }}
                        className="w-full max-w-lg rounded-3xl bg-white p-4 shadow-2xl"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="mb-3 flex items-center justify-between">
                            <h3 className="text-sm font-semibold text-gray-800">웹캠 촬영</h3>
                            <button
                                type="button"
                                onClick={onClose}
                                className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-gray-100 cursor-pointer"
                            >
                                <X className="w-4 h-4 text-gray-500" />
                            </button>
                        </div>

                        <div className="relative overflow-hidden rounded-2xl bg-black">
                            <video
                                ref={videoRef}
                                autoPlay
                                playsInline
                                muted
                                className="w-full h-[360px] object-cover"
                            />

                            {/* 얼굴 가이드 오버레이 */}
                            <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                                <div className={`w-[220px] h-[280px] rounded-[999px] border-2 ${guideColor} shadow-[0_0_0_9999px_rgba(0,0,0,0.28)] transition-colors duration-300`} />
                            </div>

                            {/* 카운트다운 숫자 */}
                            <AnimatePresence>
                                {countdown !== null && countdown > 0 && (
                                    <motion.div
                                        key={countdown}
                                        initial={{ scale: 2, opacity: 0 }}
                                        animate={{ scale: 1, opacity: 1 }}
                                        exit={{ scale: 0.5, opacity: 0 }}
                                        transition={{ duration: 0.4, ease: "easeOut" }}
                                        className="pointer-events-none absolute inset-0 flex items-center justify-center"
                                    >
                                        <span className="text-7xl font-bold text-white drop-shadow-lg">
                                            {countdown}
                                        </span>
                                    </motion.div>
                                )}
                            </AnimatePresence>

                            {/* 모델 로딩 표시 */}
                            {isModelLoading && isCameraReady && (
                                <div className="absolute bottom-3 left-1/2 -translate-x-1/2 rounded-full bg-black/60 px-3 py-1">
                                    <p className="text-xs text-white animate-pulse">얼굴 감지 준비 중...</p>
                                </div>
                            )}
                        </div>

                        <p className="mt-3 text-center text-xs text-gray-500">
                            {statusText}
                        </p>

                        {error && (
                            <p className="mt-2 text-center text-xs text-red-500">{error}</p>
                        )}

                        <div className="mt-4 flex justify-end gap-2">
                            <button
                                type="button"
                                onClick={onClose}
                                className="rounded-xl border border-gray-200 px-4 py-2 text-xs font-medium text-gray-600 hover:bg-gray-50 cursor-pointer"
                            >
                                취소
                            </button>
                            <button
                                type="button"
                                onClick={handleCapture}
                                disabled={!isCameraReady}
                                className="flex items-center gap-1 rounded-xl bg-onyou px-4 py-2 text-xs font-medium text-white disabled:opacity-50 cursor-pointer"
                            >
                                <Camera className="w-3.5 h-3.5" />
                                수동 촬영
                            </button>
                        </div>

                        <canvas ref={canvasRef} className="hidden" />
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}
