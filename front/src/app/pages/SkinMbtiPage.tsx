import { motion } from "motion/react";
import { useMemo, useState, useEffect } from "react";
import { Loading } from "@/app/components/ui/loading";
import { useNavigate, useLocation } from "react-router";
import { ChevronLeft, ChevronRight, Sparkles } from "lucide-react";
import { submitSkinMbti, fetchSavedSkinMbti, type SkinMbtiOption,type SkinMbtiResultData,} from "@/app/api/skinMbtiApi";

interface SkinMbtiQuestion {
    id: number;
    question: string;
    options: string[];
}

const QUESTIONS: SkinMbtiQuestion[] = [
    {
        id: 1,
        question: "아침 세안 후 가장 가까운 내 루틴은?",
        options: [
            "토너나 크림 정도만 바르면 충분하다",
            "바빠도 핵심 2~3개만 바른다",
            "토너-세럼-크림 순서가 있어야 안심된다",
            "피부 상태 따라 한두 단계를 더 얹는다",
        ],
    },
    {
        id: 2,
        question: "기초 제품을 고를 때 가장 먼저 보는 건?",
        options: [
            "피부가 편안하고 순한지",
            "보습·진정·장벽 관리에 좋은지",
            "내 고민을 바로 겨냥하는 기능이 있는지",
            "효과가 확실한 성분이 들어있는지",
        ],
    },
    {
        id: 3,
        question: "루틴을 바꾸는 주기는?",
        options: [
            "한 번 맞으면 오래 유지한다",
            "계절 바뀌거나 다 쓰기 전엔 거의 안 바꾼다",
            "피부 상태 따라 바로 조정하는 편이다",
            "추천이나 후기 보고 빠르게 바꿔본다",
        ],
    },
    {
        id: 4,
        question: "저녁에 너무 피곤한 날 나는?",
        options: [
            "세안 후 보습만 하고 끝낸다",
            "최소 루틴만 지키고 잔다",
            "그래도 단계는 웬만하면 챙긴다",
            "컨디션 따라 레이어링 양을 조절한다",
        ],
    },
    {
        id: 5,
        question: "피부가 예민해졌을 때 첫 반응은?",
        options: [
            "원래 쓰던 순한 기본템만 남긴다",
            "진정·장벽 회복 루틴으로 며칠 정리한다",
            "트러블/각질/탄력 등 원인별 해결템을 찾는다",
            "빨리 좋아질 만한 기능성 제품을 추가한다",
        ],
    },
    {
        id: 6,
        question: "새 제품을 들일 때 나는?",
        options: [
            "다 쓰고 나서 천천히 교체한다",
            "기존 루틴이 안정될 때만 하나씩 넣는다",
            "괜찮아 보이면 바로 루틴에 넣어본다",
            "여러 제품을 비교하면서 바꿔본다",
        ],
    },
    {
        id: 7,
        question: "여행이나 외출 때 챙기는 기초는?",
        options: [
            "클렌저, 크림, 선크림 정도면 충분하다",
            "꼭 필요한 기본템만 소분해서 챙긴다",
            "평소 루틴대로 대부분 챙긴다",
            "건조용, 진정용, 집중케어용까지 나눠 챙긴다",
        ],
    },
    {
        id: 8,
        question: "가장 돈을 아끼지 않게 되는 기초 제품은?",
        options: [
            "수분크림, 로션 같은 기본 보습템",
            "진정크림, 장벽앰플 같은 회복템",
            "기능성 세럼 1개",
            "모공, 탄력, 트러블 등 고민별 집중템",
        ],
    },
    {
        id: 9,
        question: "스킨케어 정보 볼 때 나는?",
        options: [
            "복잡한 정보보다 익숙한 제품이 편하다",
            "내 루틴이랑 잘 맞는지 천천히 따져본다",
            "요즘 잘 맞는 조합이 보이면 시도해본다",
            "성분표, 후기, 비교 콘텐츠를 자주 찾아본다",
        ],
    },
    {
        id: 10,
        question: "선크림 바르기 전까지의 스킨케어는?",
        options: [
            "많이 바르면 답답해서 최소로 한다",
            "가볍게 흡수되는 정도면 충분하다",
            "수분층이 어느 정도 쌓여야 안정적이다",
            "제형을 겹쳐 피부 컨디션을 맞춘다",
        ],
    },
    {
        id: 11,
        question: "기능성 성분에 대한 내 생각은?",
        options: [
            "효과보다 덜 예민한 게 더 중요하다",
            "무난하고 오래 쓰기 편한 제품이 좋다",
            "고민 하나쯤은 확실히 잡아주는 게 좋다",
            "기능성 성분이 들어가야 만족스럽다",
        ],
    },
    {
        id: 12,
        question: "2주 정도 써도 효과가 애매하면?",
        options: [
            "조금 더 꾸준히 써본다",
            "기본 보습은 유지하고 좀 더 지켜본다",
            "루틴 일부를 바로 바꿔본다",
            "다른 성분이나 제품 조합을 찾아본다",
        ],
    },
];

const OPTION_KEYS: SkinMbtiOption[] = ["A", "B", "C", "D"];

export function SkinMbtiPage() {
    const navigate = useNavigate();
    const location = useLocation();

    const [currentIndex, setCurrentIndex] = useState(0);
    const [answers, setAnswers] = useState<(SkinMbtiOption | null)[]>(Array(12).fill(null));
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isCheckingSavedResult, setIsCheckingSavedResult] = useState(true);

    const forceRetest = Boolean((location.state as { forceRetest?: boolean } | null)?.forceRetest);
    useEffect(() => {
        if (forceRetest) {
            setIsCheckingSavedResult(false);
            return;
        }

        let mounted = true;

        async function checkSavedResult() {
            try {
                const saved = await fetchSavedSkinMbti();

                if (mounted && saved) {
                    navigate("/skin-mbti/result", {
                        state: saved,
                        replace: true,
                    });
                    return;
                }
            } catch (error) {
                console.error("저장된 피부 MBTI 결과 조회 실패:", error);
            } finally {
                if (mounted) setIsCheckingSavedResult(false);
            }
        }

        checkSavedResult();

        return () => {
            mounted = false;
        };
    }, [navigate, forceRetest]);

    const currentQuestion = QUESTIONS[currentIndex];
    const currentAnswer = answers[currentIndex];
    const progress = useMemo(() => ((currentIndex + 1) / QUESTIONS.length) * 100, [currentIndex]);

    const handleSelectOption = (option: SkinMbtiOption) => {
        const next = [...answers];
        next[currentIndex] = option;
        setAnswers(next);
    };

    const handlePrev = () => {
        if (currentIndex === 0) return;
        setCurrentIndex((prev) => prev - 1);
    };

    const handleNext = async () => {
        if (!currentAnswer) return;

        if (currentIndex < QUESTIONS.length - 1) {
            setCurrentIndex((prev) => prev + 1);
            return;
        }

        const finalAnswers = answers.filter(Boolean) as SkinMbtiOption[];

        if (finalAnswers.length !== 12) {
            alert("모든 문항을 선택해주세요.");
            return;
        }

        try {
            setIsSubmitting(true);

            const result: SkinMbtiResultData = await submitSkinMbti(finalAnswers);

            navigate("/skin-mbti/result", {
                state: result,
            });
        } catch (error) {
            alert(error instanceof Error ? error.message : "피부 MBTI 결과 조회 중 오류가 발생했습니다.");
        } finally {
            setIsSubmitting(false);
        }
    };

    if (isCheckingSavedResult) {
        return <Loading />;
    }

    return (
        <div className="h-full overflow-y-auto bg-[#F8FBF3]">
            <div className="max-w-3xl mx-auto px-4 py-6">
                <div className="mb-6">
                    <div className="flex items-center gap-2 mb-2">
                        <div className="w-10 h-10 rounded-2xl bg-[#E8F5D0] flex items-center justify-center">
                            <Sparkles className="w-5 h-5 text-onyou" />
                        </div>
                        <div>
                            <h1 className="text-gray-900 font-bold text-xl">피부 MBTI 테스트</h1>
                            <p className="text-sm text-gray-500">12문항으로 내 스킨케어 성향을 확인해보세요</p>
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 mb-5">
                    <div className="flex items-center justify-between mb-3">
                        <span className="text-sm font-semibold text-gray-800">진행률</span>
                        <span className="text-sm text-gray-500">
                            {currentIndex + 1} / {QUESTIONS.length}
                        </span>
                    </div>

                    <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                        <motion.div
                            className="h-full bg-onyou rounded-full"
                            initial={{ width: 0 }}
                            animate={{ width: `${progress}%` }}
                            transition={{ duration: 0.3 }}
                        />
                    </div>
                </div>

                <motion.div
                    key={currentQuestion.id}
                    initial={{ opacity: 0, y: 16 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.25 }}
                    className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
                >
                    <div className="mb-6">
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5D0] text-onyou mb-3">
                            Q{currentQuestion.id}
                        </span>
                        <h2 className="text-lg font-bold text-gray-900 leading-relaxed">
                            {currentQuestion.question}
                        </h2>
                    </div>

                    <div className="space-y-3">
                        {currentQuestion.options.map((option, index) => {
                            const optionKey = OPTION_KEYS[index];
                            const isSelected = currentAnswer === optionKey;

                            return (
                                <button
                                    key={optionKey}
                                    type="button"
                                    onClick={() => handleSelectOption(optionKey)}
                                    className={`w-full text-left rounded-2xl border px-4 py-4 transition-all cursor-pointer ${
                                        isSelected
                                            ? "border-onyou bg-[#F6FBEF] shadow-sm"
                                            : "border-gray-200 hover:border-[#CFE7A9] hover:bg-[#FCFEF8]"
                                    }`}
                                >
                                    <div className="flex items-start gap-3">
                                        <div
                                            className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0 ${
                                                isSelected ? "bg-onyou text-white" : "bg-gray-100 text-gray-500"
                                            }`}
                                        >
                                            {optionKey}
                                        </div>
                                        <p className="text-sm md:text-[15px] text-gray-700 leading-relaxed pt-1">
                                            {option}
                                        </p>
                                    </div>
                                </button>
                            );
                        })}
                    </div>

                    <div className="mt-8 flex items-center justify-between">
                        <button
                            type="button"
                            onClick={handlePrev}
                            disabled={currentIndex === 0 || isSubmitting}
                            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 text-sm font-semibold text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                        >
                            <ChevronLeft className="w-4 h-4" />
                            이전
                        </button>

                        <button
                            type="button"
                            onClick={handleNext}
                            disabled={!currentAnswer || isSubmitting}
                            className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-onyou text-white text-sm font-semibold shadow-sm hover:brightness-95 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                        >
                            {currentIndex === QUESTIONS.length - 1
                                ? (isSubmitting ? "결과 계산 중..." : "결과 보기")
                                : "다음"}
                            {!isSubmitting && <ChevronRight className="w-4 h-4" />}
                        </button>
                    </div>
                </motion.div>
            </div>
        </div>
    );
}