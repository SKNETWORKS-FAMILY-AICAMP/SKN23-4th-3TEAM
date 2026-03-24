import { useState, useEffect, useMemo, useRef, useCallback } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, ChevronLeft, ChevronRight, Lightbulb } from "lucide-react";
import triviaData from "@/assets/skinTrivia.json";

interface SkinTriviaModalProps {
    open: boolean;
    onClose: () => void;
}

function shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

export function SkinTriviaModal({ open, onClose }: SkinTriviaModalProps) {
    const [currentIndex, setCurrentIndex] = useState(0);
    const [direction, setDirection] = useState(0);
    const autoNextTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
    const clearAutoNextTimer = useCallback(() => {
        if (autoNextTimerRef.current) {
            clearTimeout(autoNextTimerRef.current);
            autoNextTimerRef.current = null;
        }
    }, []);
    // 모달 열릴 때마다 랜덤 5개 선택 + 인덱스 리셋
    const items = useMemo(() => {
        if (!open) return [];
        return shuffleArray(triviaData.trivia).slice(0, 20);
    }, [open]);

    useEffect(() => {
        if (open) setCurrentIndex(0);
    }, [open]);

    useEffect(() => {
        if (!open || items.length === 0) {
            clearAutoNextTimer();
            return;
        }

        if (currentIndex >= items.length - 1) {
            clearAutoNextTimer();
            return;
        }

        autoNextTimerRef.current = setTimeout(() => {
            setDirection(1);
            setCurrentIndex((prev) => {
                if (prev >= items.length - 1) return prev;
                return prev + 1;
            });
        }, 5000);

        return () => {
            clearAutoNextTimer();
        };
    }, [open, items.length, currentIndex, clearAutoNextTimer]);

    const handlePrev = useCallback(() => {
        clearAutoNextTimer();

        setCurrentIndex((prev) => {
            if (prev <= 0) return prev;
            setDirection(-1);
            return prev - 1;
        });
    }, [clearAutoNextTimer]);

    const handleNext = useCallback(() => {
        clearAutoNextTimer();

        setCurrentIndex((prev) => {
            if (prev >= items.length - 1) return prev;
            setDirection(1);
            return prev + 1;
        });
    }, [clearAutoNextTimer, items.length]);
    
    const handleClose = () => {
        clearAutoNextTimer();
        onClose();
    };
    if (!open || items.length === 0) return null;

    const current = items[currentIndex];

    return (
        <AnimatePresence>
            {open && (
                <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.2 }}
                    className="fixed inset-0 z-[55] flex items-center justify-center px-4"
                    style={{ pointerEvents: "auto" }}
                >
                    {/* 배경 딤 — 클릭 시 닫기 */}
                    <div
                        className="absolute inset-0 bg-black/30 backdrop-blur-[2px]"
                        onClick={handleClose}
                    />

                    {/* 모달 카드 */}
                    <motion.div
                        initial={{ scale: 0.92, opacity: 0, y: 20 }}
                        animate={{ scale: 1, opacity: 1, y: 0 }}
                        exit={{ scale: 0.92, opacity: 0, y: 20 }}
                        transition={{ duration: 0.25, ease: "easeOut" }}
                        className="relative w-full max-w-[600px] rounded-3xl bg-white shadow-xl overflow-hidden"
                        onClick={(e) => e.stopPropagation()}
                    >
                        {/* 상단 헤더 */}
                        <div className="flex items-center justify-between px-7 pt-6 pb-3">
                            <div className="flex items-center gap-2">
                                <div className="w-8 h-8 rounded-xl bg-[#E8F5D0] flex items-center justify-center">
                                    <Lightbulb className="w-4 h-4 text-[#4A7A1E]" />
                                </div>
                                <div>
                                    <p className="text-lg font-bold text-gray-800">오늘의 피부 상식</p>
                                    <p className="text-sm text-gray-400">답변을 기다리는 동안 알아보세요</p>
                                </div>
                            </div>
                            <button
                                type="button"
                                onClick={handleClose}
                                className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-gray-100 transition-colors cursor-pointer"
                            >
                                <X className="w-4 h-4 text-gray-400" />
                            </button>
                        </div>

                        {/* 콘텐츠 영역 */}
                        <div className="px-8 py-7 min-h-[260px] flex items-center">
                            <AnimatePresence mode="wait" initial={false}>
                                <motion.div
                                    key={currentIndex}
                                    initial={{ opacity: 0, x: direction >= 0 ? 40 : -40 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: direction >= 0 ? -40 : 40 }}
                                    transition={{ duration: 0.25, ease: "easeInOut" }}
                                    className="w-full"
                                >
                                    <div className="text-center">
                                        <span className="text-5xl mb-3 block">{current.emoji}</span>
                                        <h3 className="text-2xl font-bold text-gray-900 mb-3">
                                            {current.title}
                                        </h3>
                                        <p className="text-lg text-gray-600 leading-8">
                                            {current.content}
                                        </p>
                                    </div>
                                </motion.div>
                            </AnimatePresence>
                        </div>

                        {/* 하단 네비게이션 */}
                        <div className="flex items-center justify-between px-7 pb-6 pt-3">
                            <button
                                type="button"
                                onClick={handlePrev}
                                disabled={currentIndex === 0}
                                className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-base font-medium text-gray-600 hover:bg-gray-50 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer transition-all"
                            >
                                <ChevronLeft className="w-5 h-5" />
                                이전
                            </button>

                            {/* 인디케이터 */}
                            <div className="flex items-center gap-1.5">
                                {items.map((_, idx) => (
                                    <div
                                        key={idx}
                                        className={`h-1.5 rounded-full transition-all duration-300 ${
                                            idx === currentIndex
                                                ? "w-5 bg-[#85C13D]"
                                                : "w-1.5 bg-gray-200"
                                        }`}
                                    />
                                ))}
                            </div>

                            <button
                                type="button"
                                onClick={handleNext}
                                disabled={currentIndex === items.length - 1}
                                className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-base font-medium text-gray-600 hover:bg-gray-50 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer transition-all"
                            >
                                다음
                                <ChevronRight className="w-5 h-5" />
                            </button>
                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}
