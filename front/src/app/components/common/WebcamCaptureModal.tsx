import { useEffect, useRef, useState } from "react";
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

    useEffect(() => {
        if (!open) return;

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
            setIsCameraReady(false);
        };
    }, [open]);

    const handleCapture = () => {
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
    };

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

                            <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                                <div className="w-[220px] h-[280px] rounded-[999px] border-2 border-white/80 shadow-[0_0_0_9999px_rgba(0,0,0,0.28)]" />
                            </div>
                        </div>

                        <p className="mt-3 text-center text-xs text-gray-500">
                            얼굴을 중앙 가이드 안에 맞춘 뒤 촬영해주세요.
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
                                촬영
                            </button>
                        </div>

                        <canvas ref={canvasRef} className="hidden" />
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}