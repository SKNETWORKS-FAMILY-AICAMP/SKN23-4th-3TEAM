import { motion } from "motion/react";
import { useState, useEffect, useMemo, useRef } from "react";
import { Icon } from "../components/ui/icon";
import { Button } from "@/app/components/ui/button";
import { Loading } from "@/app/components/ui/loading";
import { Calendar, ScanFace, TrendingUp, TrendingDown, Minus, ChevronDown } from "lucide-react";
import { RadarChart, Radar, PolarGrid, PolarAngleAxis, ResponsiveContainer, Legend } from "recharts";
import { fetchDetailAnalysis, fetchFactorials, fetchDetailedAnalysisDates, fetchAnalysisByDate, type AnalysisResult, type KeywordResponse} from "@/app/api/analysisApi";

const factorialImages = import.meta.glob<string>(
    '../../assets/factorial/*.svg',
    { eager: true, query: '?url', import: 'default' },
);

// UI 전용 설정
const SKIN_METRICS = [
    { key: "moisture",     label: "수분",     icon: "moisture" as const,      color: "#4e76ba" },
    { key: "elasticity",   label: "탄력",     icon: "elasticity" as const,    color: "#6cb78e" },
    { key: "wrinkle",      label: "주름",     icon: "wrinkle" as const,       color: "#f6b483" },
    { key: "pore",         label: "모공",     icon: "pore" as const,          color: "#8959a2" },
    { key: "pigmentation", label: "색소침착", icon: "pigmentation" as const,  color: "#cc528e" },
];

function MetricBar({ value, color }: { value: number; color: string }) {
    return (
        <div className="w-full bg-gray-100 rounded-full h-2 overflow-hidden">
            <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${value}%` }}
                transition={{ duration: 1, ease: "easeOut", delay: 0.3 }}
                className="h-full rounded-full"
                style={{ background: color }}
            />
        </div>
    );
}

function ScoreGauge({ score }: { score: number }) {
    const circumference = 2 * Math.PI * 54;
    const offset = circumference - (score / 100) * circumference;

    return (
        <div className="relative w-100 h-auto">
            <svg className="w-full h-full -rotate-90" viewBox="-7 -7 134 134">
                <circle cx="60" cy="60" r="54" fill="none" stroke="#E5E7EB" strokeWidth="13" />
                <motion.circle
                    cx="60" cy="60" r="54"
                    fill="none"
                    stroke="url(#scoreGradient)"
                    strokeWidth="13"
                    strokeLinecap="round"
                    strokeDasharray={circumference}
                    initial={{ strokeDashoffset: circumference }}
                    animate={{ strokeDashoffset: offset }}
                    transition={{ duration: 1.5, ease: "easeOut" }}
                />
                <defs>
                    <linearGradient id="scoreGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#84C13D" />
                        <stop offset="100%" stopColor="#A8D870" />
                    </linearGradient>
                </defs>
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
                <motion.span
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ delay: 0.8 }}
                    className="text-4xl font-bold text-onyou"
                >
                    {score}
                </motion.span>
                <span className="text-xs text-gray-400 font-medium">전체 점수</span>
            </div>
        </div>
    );
}

/** ISO 날짜 문자열 → "YYYY.MM.DD" */
function fmtDate(iso: string): string {
    const d = new Date(iso);
    return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, "0")}.${String(d.getDate()).padStart(2, "0")}`;
}

// 날짜 선택 함수
function DateSelect({
    value,
    options,
    onChange,
}: {
    value: string;
    options: string[];
    onChange: (value: string) => void;
}) {
    const [open, setOpen] = useState(false);
    const wrapperRef = useRef<HTMLDivElement | null>(null);

    useEffect(() => {
        function handleClickOutside(e: MouseEvent) {
            if (!wrapperRef.current) return;
            if (!wrapperRef.current.contains(e.target as Node)) {
                setOpen(false);
            }
        }

        document.addEventListener("mousedown", handleClickOutside);

        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);

    if (!options.length) return null;

    const selectedLabel = value ? fmtDate(value) : "날짜 선택";

    return (
        <div ref={wrapperRef} className="relative">
            <button
                type="button"
                onClick={() => setOpen((prev) => !prev)}
                className={`flex h-11 min-w-[160px] items-center gap-2 rounded-2xl border px-3 pr-10 text-sm font-medium shadow-sm transition-all ${
                    open
                        ? "border-[#B7D88F] bg-white ring-2 ring-[#E8F5D0]"
                        : "border-gray-200 bg-white hover:border-[#CFE5AA]"
                }`}
            >
                <Calendar className="w-4 h-4 text-onyou shrink-0" />
                <span className="text-gray-700">{selectedLabel}</span>
                <ChevronDown
                    className={`absolute right-3 w-4 h-4 text-gray-400 transition-transform ${
                        open ? "rotate-180" : ""
                    }`}
                />
            </button>

            {open && (
                <div className="absolute right-0 z-50 mt-2 w-full overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-lg">
                    <ul className="max-h-60 overflow-y-auto py-1">
                        {options.map((date) => {
                            const isSelected = value === date;

                            return (
                                <li key={date}>
                                    <button
                                        type="button"
                                        onClick={() => {
                                            onChange(date);
                                            setOpen(false);
                                        }}
                                        className={`flex w-full items-center px-4 py-2.5 text-left text-sm transition-colors ${
                                            isSelected
                                                ? "bg-[#F0FAE4] text-onyou font-semibold"
                                                : "text-gray-700 hover:bg-gray-50"
                                        }`}
                                    >
                                        {fmtDate(date)}
                                    </button>
                                </li>
                            );
                        })}
                    </ul>
                </div>
            )}
        </div>
    );
}

export function AnalysisPage() {
    const [activeTab, setActiveTab]                             = useState<"current" | "compare">("current");
    const [analysisHistory, setAnalysisHistory]                 = useState<AnalysisResult[]>([]);
    const [availableDates, setAvailableDates]                   = useState<string[]>([]);
    const [currentAnalysis, setCurrentAnalysis]                 = useState<AnalysisResult | null>(null);
    const [comparePreviousAnalysis, setComparePreviousAnalysis] = useState<AnalysisResult | null>(null);
    const [selectedCurrentDate, setSelectedCurrentDate]         = useState("");
    const [selectedCompareDate, setSelectedCompareDate]         = useState("");
    const [isLoading, setIsLoading]                             = useState(true);
    const [hasNoData, setHasNoData]                             = useState(false);
    const [factorialList, setFactorialList]                     = useState<KeywordResponse[]>([]);
    // 초기 로딩에서 이미 받아온 최신 분석을
    // selectedCurrentDate effect가 다시 조회하지 않도록 막는 플래그
    const skipFirstCurrentFetchRef = useRef(false);
    
    useEffect(() => {
        fetchFactorials()
            .then(setFactorialList)
            .catch((err: Error) => console.error("팩토리얼 키워드 목록 조회 실패:", err));
    }, []);

    useEffect(() => {
        async function init() {
            try {
                const [history, dates] = await Promise.all([
                    fetchDetailAnalysis(),
                    fetchDetailedAnalysisDates(),
                ]);

                if (!history.length || !dates.length) {
                    setHasNoData(true);
                    return;
                }

                setAnalysisHistory(history);
                setAvailableDates(dates);

                const latest = history[0];
                const latestDate = latest.created_at.slice(0, 10);

                // 초기 진입 시에는 이미 최신 분석 결과(latest)를 갖고 있으므로
                // 바로 아래 selectedCurrentDate 세팅으로 인해
                // current 조회 effect가 다시 호출되지 않도록 1회 스킵 플래그를 켠다.
                skipFirstCurrentFetchRef.current = true;

                setCurrentAnalysis(latest);
                setSelectedCurrentDate(latestDate);

                // 비교 날짜는 "최신 날짜 제외" 목록 중 첫 번째 값만 기본 선택
                const compareCandidates = dates.filter((d) => d !== latestDate);
                setSelectedCompareDate(compareCandidates[0] ?? "");
            } catch (error) {
                console.error("분석 페이지 초기화 실패:", error);
                setHasNoData(true);
            } finally {
                setIsLoading(false);
            }
        }

        init();
    }, []);

    useEffect(() => {
        // 초기 진입 시에는 init()에서 이미 최신 분석 데이터를 넣었기 때문에
        // 같은 날짜로 /analysis/by-date를 다시 호출하지 않도록 1회 건너뜀
        if (skipFirstCurrentFetchRef.current) {
            skipFirstCurrentFetchRef.current = false;
            return;
        }

        async function loadCurrentAnalysis() {
            if (!selectedCurrentDate) return;

            try {
                const res = await fetchAnalysisByDate([selectedCurrentDate]);
                setCurrentAnalysis(res[0]?.result ?? null);
            } catch (error) {
                console.error("현재 분석 조회 실패:", error);
                setCurrentAnalysis(null);
            }
        }

        loadCurrentAnalysis();
    }, [selectedCurrentDate]);

    const latestAnalysis = analysisHistory[0] ?? null;
    const latestDate = latestAnalysis?.created_at.slice(0, 10) ?? "";

    useEffect(() => {
        // 비교 탭을 실제로 열었을 때만 비교 분석 API를 호출
        // 현재 탭에서 굳이 미리 불러오지 않아도 되므로 불필요한 요청 감소
        if (activeTab !== "compare") return;

        async function loadCompareAnalysis() {
            if (!latestDate || !selectedCompareDate) return;

            if (latestDate === selectedCompareDate) {
                setComparePreviousAnalysis(null);
                return;
            }

            try {
                const res = await fetchAnalysisByDate([latestDate, selectedCompareDate]);
                const previous =
                    res.find((item) => item.date === selectedCompareDate)?.result ?? null;

                setComparePreviousAnalysis(previous);
            } catch (error) {
                console.error("비교 분석 조회 실패:", error);
                setComparePreviousAnalysis(null);
            }
        }

        loadCompareAnalysis();
    }, [activeTab, latestDate, selectedCompareDate]);

    const compareDateOptions = useMemo(() => {
        return availableDates.filter((d) => d !== latestDate);
    }, [availableDates, latestDate]);

    const extractNum = (raw: unknown, fallback: number): number => {
        if (typeof raw === "number") return raw;

        if (raw && typeof raw === "object" && "score" in raw) 
            return Number((raw as { score: unknown }).score) || fallback;

        return fallback;
    };
    const extractStr = (raw: unknown, fallback: string): string => {
        if (typeof raw === "string") return raw;

        if (raw && typeof raw === "object" && "label" in raw)
            return String((raw as { label: unknown }).label) || fallback;

        return fallback;
    };

// ── 현재 분석 지표 ─────────────────────────────────────────────
    const activeCurrent     = currentAnalysis;
    const currentDateLabel  = activeCurrent ? fmtDate(activeCurrent.created_at) : "";

    const ad                = activeCurrent?.analysis_data ?? {};
    const apiM              = (ad.metrics ?? {}) as Record<string, unknown>;
    
    const overallScore      = extractNum(activeCurrent?.skin_score, extractNum(ad.overall_score, 0));
    const skinType          = extractStr(ad.skin_type, "");
    const skinTypeDesc      = extractStr(ad.skin_type_detail, "");
    const factorial         = activeCurrent?.factorial ?? [];
    const analysisImage     = activeCurrent?.image_url?.[0] ?? "";

    const skinMetrics = SKIN_METRICS.map((m) => {
        const raw = apiM[m.key];

        return { ...m, value: extractNum(raw, 0), desc: extractStr(raw, "") };
    });

    const prevAd = comparePreviousAnalysis?.analysis_data ?? {};
    const prevApiM = (prevAd.metrics ?? {}) as Record<string, unknown>;
    const prevOverallScore = extractNum(comparePreviousAnalysis?.skin_score, extractNum(prevAd.overall_score, 0));
    const previousDate = comparePreviousAnalysis ? fmtDate(comparePreviousAnalysis.created_at) : "";

    const prevSkinMetrics = SKIN_METRICS.map((m) => {
        const raw = prevApiM[m.key];

        return { ...m, value: extractNum(raw, 0), desc: extractStr(raw, "") };
    });

    // ── 레이더 차트 데이터 ─────────────────────────────────────────
    const getVal = (list: typeof skinMetrics, key: string) =>
        list.find((m) => m.key === key)?.value ?? 0;

    const radarData = [
        { subject: "수분",     A: getVal(skinMetrics, "moisture")     },
        { subject: "탄력",     A: getVal(skinMetrics, "elasticity")   },
        { subject: "주름",     A: getVal(skinMetrics, "wrinkle")      },
        { subject: "모공",     A: getVal(skinMetrics, "pore")         },
        { subject: "색소침착", A: getVal(skinMetrics, "pigmentation") },
    ];

    const compareRadarData = [
        { subject: "수분",     A: getVal(skinMetrics, "moisture"),     B: getVal(prevSkinMetrics, "moisture")     },
        { subject: "탄력",     A: getVal(skinMetrics, "elasticity"),   B: getVal(prevSkinMetrics, "elasticity")   },
        { subject: "주름",     A: getVal(skinMetrics, "wrinkle"),      B: getVal(prevSkinMetrics, "wrinkle")      },
        { subject: "모공",     A: getVal(skinMetrics, "pore"),         B: getVal(prevSkinMetrics, "pore")         },
        { subject: "색소침착", A: getVal(skinMetrics, "pigmentation"), B: getVal(prevSkinMetrics, "pigmentation") },
    ];

    // ── 로딩 / 빈 상태 ────────────────────────────────────────────
    if (isLoading) return <Loading />;

    if (hasNoData) {
        return (
            <div className="flex flex-col items-center justify-center h-full bg-[#F8FBF3] px-6 text-center">
                <div className="w-20 h-20 rounded-full flex items-center justify-center mb-4 bg-[#E8F5D0]">
                    <ScanFace className="w-10 h-10 text-onyou" />
                </div>
                <h1 className="font-bold text-gray-800 mb-2">아직 피부 분석 결과가 없어요</h1>
                <p className="text-sm text-gray-500 leading-relaxed mb-6">채팅에서 피부 이미지를 업로드하면<br />AI가 분석 결과를 저장해 드려요.</p>
                <Button to="/chat" fullWidth={false} className="px-6 py-2.5">
                    채팅으로 분석 시작하기
                </Button>
            </div>
        );
    }

    const scoreDelta = overallScore - prevOverallScore;

    return (
        <div className="h-full overflow-y-auto bg-[#F8FBF3]">
            <div className="max-w-5xl mx-auto px-4 py-6">

                {/* ── 헤더 ─────────────────────────────────────────────── */}
                <div className="flex items-center justify-between mb-6">
                    <div>
                        <h1 className="text-gray-900 font-bold">피부 분석 결과</h1>
                        <p className="text-sm text-gray-500 mt-0.5">AI가 분석한 나의 피부 상태</p>
                    </div>
                </div>

                {/* ── 탭 ──────────────────────────────────────────────── */}
                <div className="flex items-center justify-between gap-4 mb-6">
                    <div className="inline-flex gap-1 rounded-2xl border border-gray-200 bg-white p-1 shadow-sm">
                        {[{ id: "current", label: "현재 분석" }, { id: "compare", label: "비교 분석" }].map((tab) => (
                            <button
                                key={tab.id}
                                onClick={() => setActiveTab(tab.id as "current" | "compare")}
                                className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-200 cursor-pointer ${
                                    activeTab === tab.id
                                        ? "bg-onyou text-white shadow-sm"
                                        : "text-gray-500 hover:text-gray-700 hover:bg-gray-50"
                                }`}
                            >
                                {tab.label}
                            </button>
                        ))}
                    </div>

                    {activeTab === "current" ? (
                        availableDates.length > 0 ? (
                            <DateSelect
                                value={selectedCurrentDate}
                                options={availableDates}
                                onChange={setSelectedCurrentDate}
                            />
                        ) : null
                    ) : (
                        compareDateOptions.length > 0 ? (
                            <DateSelect
                                value={selectedCompareDate}
                                options={compareDateOptions}
                                onChange={setSelectedCompareDate}
                            />
                        ) : null
                    )}
                </div>

                {/*
                ════════════════════════════════════════════════════════
                        현재 분석 탭
                ════════════════════════════════════════════════════════
                */}
                {activeTab === "current" ? (
                    <div className="space-y-5">

                        {/* 점수 + 피부 타입 */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4 }}
                                className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm aspect-square overflow-auto"
                            >
                                <h3 className="font-semibold text-gray-800 mb-4">종합 피부 점수</h3>
                                <div className="flex items-center gap-6 mb-6">
                                    <ScoreGauge score={overallScore} />
                                    <div>
                                        <div className="flex items-center gap-2 mb-2">
                                            <span className="px-2.5 py-1 rounded-lg text-xs font-semibold text-white bg-onyou">{skinType}</span>
                                        </div>
                                        <p className="text-sm text-gray-600 leading-relaxed">{skinTypeDesc}</p>
                                    </div>
                                </div>
                                <>
                                <div className="flex items-center gap-2 mb-3">
                                        <span className="px-2.5 py-1 rounded-lg text-xs font-semibold text-white bg-onyou">추천 관리법</span>
                                </div>
                                <div className="flex items-start gap-3">
                                        {factorial?.map((keyword) => {
                                            const item   = factorialList.find((f) => f.label === keyword);
                                        const imgSrc = factorialImages[`../../assets/factorial/${item?.keyword}.svg`];

                                        return (
                                            <div key={keyword} className="flex flex-col items-center gap-1">
                                                {imgSrc && (
                                                        <img src={imgSrc} alt={item?.label ?? keyword} className="w-18 h-18 object-contain" />
                                                )}
                                                <span className="w-18 text-[13px] text-gray-500 text-center font-medium leading-tight break-keep">
                                                    {item?.label ?? keyword}
                                                </span>
                                            </div>
                                        );
                                    })}
                                </div>
                                </>
                            </motion.div>

                            {/* 분석 이미지 */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4, delay: 0.1 }}
                                className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden aspect-square"
                            >
                                <div className="relative h-full">
                                    {analysisImage ? (
                                        <img src={analysisImage} alt="Skin analysis" className="w-full h-full object-cover" />
                                    ) : (
                                        <div className="w-full h-full bg-gray-100 flex items-center justify-center">
                                            <ScanFace className="w-12 h-12 text-gray-300" />
                                        </div>
                                    )}
                                    <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
                                    <div className="absolute bottom-4 left-4 right-4">
                                        <p className="text-white text-sm font-medium">분석 이미지</p>
                                        <p className="text-white/70 text-xs">{currentDateLabel} 분석</p>
                                    </div>
                                </div>
                            </motion.div>
                        </div>

                        {/* 피부 지표 상세 */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4, delay: 0.2 }}
                            className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm"
                        >
                            <h3 className="font-semibold text-gray-800 mb-5">피부 지표 상세</h3>
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                                {skinMetrics.map((metric, idx) => (
                                    <motion.div
                                        key={metric.key}
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        transition={{ delay: 0.3 + idx * 0.08 }}
                                        className="flex items-start gap-3 p-3 rounded-xl bg-gray-50"
                                    >
                                        <div
                                            className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
                                            style={{ background: metric.color + "20" }}
                                        >
                                            <Icon name={metric.icon} size={20} />
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <div className="flex items-center justify-between mb-1">
                                                <span className="text-sm font-medium text-gray-700">{metric.label}</span>
                                                <span className="text-sm font-bold" style={{ color: metric.color }}>
                                                    {metric.value}
                                                </span>
                                            </div>
                                            <MetricBar value={metric.value} color={metric.color} />
                                            <p className="text-[11px] text-gray-400 mt-1">{metric.desc}</p>
                                        </div>
                                    </motion.div>
                                ))}
                            </div>
                        </motion.div>

                        {/* 레이더 차트 */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4, delay: 0.3 }}
                            className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm"
                        >
                            <h3 className="font-semibold text-gray-800 mb-1">피부 레이더 차트</h3>
                            <p className="text-xs text-gray-400 mb-4">현재 피부 상태 종합</p>
                            <ResponsiveContainer width="100%" height={280}>
                                <RadarChart data={radarData} margin={{ top: 10, right: 30, bottom: 10, left: 30 }}>
                                    <PolarGrid stroke="#E5E7EB" />
                                    <PolarAngleAxis dataKey="subject" tick={{ fontSize: 12, fill: "#6B7280" }} />
                                    <Radar name="현재" dataKey="A" stroke="#84C13D" fill="#84C13D" fillOpacity={0.3} />
                                    <Legend formatter={(value) => <span className="text-xs text-gray-600">{value}</span>} />
                                </RadarChart>
                            </ResponsiveContainer>
                        </motion.div>

                    </div>
                            /* 
                ════════════════════════════════════════════════════════
                        비교 분석 탭
                ════════════════════════════════════════════════════════
                */    
            ) : analysisHistory.length < 2 || !comparePreviousAnalysis ? (
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="flex flex-col items-center justify-center py-20 text-center"
                    >
                        <div className="w-14 h-14 rounded-2xl flex items-center justify-center mb-4 bg-[#E8F5D0]">
                            <Calendar className="w-7 h-7 text-onyou" />
                        </div>
                        <h3 className="text-sm font-bold text-gray-700 mb-1">비교 분석 준비 중</h3>
                        <p className="text-xs text-gray-400 leading-relaxed">
                                분석 기록이 2회 이상 쌓이면<br />변화 추이를 비교할 수 있어요
                        </p>
                    </motion.div>

                ) : (
                        /* 기록이 2개 이상일 때 */
                    <div className="space-y-5">

                            {/* 피부 점수 변화 */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4 }}
                            className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm"
                        >
                            <h3 className="font-semibold text-gray-800 mb-5">피부 점수 변화</h3>
                            <div className="flex items-center gap-4">

                                    {/* 이전 점수 */}
                                    <div className="flex-1 text-center py-5 rounded-2xl bg-gray-50">
                                        <p className="text-xs text-gray-400 mb-2">{previousDate}</p>
                                        <p className="text-5xl font-bold text-gray-400">{prevOverallScore}</p>
                                        <p className="text-xs text-gray-400 mt-2 font-medium">이전</p>
                                    </div>

                                    {/* 변화량 */}
                                    <div className="flex flex-col items-center gap-1.5 px-2">
                                        {scoreDelta > 0 ? (
                                            <TrendingUp className="w-6 h-6 text-green-500" />
                                        ) : scoreDelta < 0 ? (
                                            <TrendingDown className="w-6 h-6 text-red-400" />
                                        ) : (
                                            <Minus className="w-6 h-6 text-gray-400" />
                                        )}
                                        <span
                                            className={`text-base font-bold ${
                                                scoreDelta > 0 ? "text-green-500" : scoreDelta < 0 ? "text-red-400" : "text-gray-400"
                                            }`}
                                        >
                                            {scoreDelta > 0 ? `+${scoreDelta}` : scoreDelta}
                                        </span>
                                    </div>

                                    {/* 현재 점수 */}
                                <div className="flex-1 text-center py-5 rounded-2xl bg-[#F0FAE4]">
                                    <p className="text-xs text-gray-400 mb-2">{latestAnalysis ? fmtDate(latestAnalysis.created_at) : ""}</p>
                                    <p className="text-5xl font-bold text-onyou">{extractNum(latestAnalysis?.skin_score, 0)}</p>
                                    <p className="text-xs text-gray-400 mt-2 font-medium">현재</p>
                                </div>

                            </div>
                            </motion.div>

                            {/* 지표별 변화 */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4, delay: 0.1 }}
                                className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm"
                            >
                                <h3 className="font-semibold text-gray-800 mb-4">지표별 변화</h3>
                                <div className="space-y-3">
                                    {skinMetrics.map((metric, idx) => {
                                        const prevVal = prevSkinMetrics.find((m) => m.key === metric.key)?.value ?? 0;
                                        const delta   = metric.value - prevVal;
                                        return (
                                            <motion.div
                                                key={metric.key}
                                                initial={{ opacity: 0, x: -10 }}
                                                animate={{ opacity: 1, x: 0 }}
                                                transition={{ delay: 0.15 + idx * 0.06 }}
                                                className="flex items-center gap-3 p-3 rounded-xl bg-gray-50"
                                            >
                                                <div
                                                    className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
                                                    style={{ background: metric.color + "20" }}
                                                >
                                                    <Icon name={metric.icon} size={16} />
                                                </div>
                                                <span className="flex-1 text-sm font-medium text-gray-700">{metric.label}</span>
                                                {/* 이전 → 현재 값 */}
                                                <div className="flex items-center gap-2 text-sm">
                                                    <span className="text-gray-400 font-medium">{prevVal}</span>
                                                    <span className="text-gray-300 text-xs">→</span>
                                                        <span className="font-semibold" style={{ color: metric.color }}>{metric.value}</span>
                                                </div>
                                                {/* 변화량 */}
                                                <div
                                                    className={`flex items-center gap-0.5 text-xs font-bold w-12 justify-end ${
                                                        delta > 0 ? "text-green-500" : delta < 0 ? "text-red-400" : "text-gray-400"
                                                    }`}
                                                >
                                                    {delta > 0 ? (
                                                        <TrendingUp className="w-3 h-3" />
                                                    ) : delta < 0 ? (
                                                        <TrendingDown className="w-3 h-3" />
                                                    ) : (
                                                        <Minus className="w-3 h-3" />
                                                    )}
                                                    <span className="ml-0.5">{delta > 0 ? `+${delta}` : delta}</span>
                                                </div>
                                            </motion.div>
                                        );
                                    })}
                                </div>
                            </motion.div>

                            {/* 레이더 차트 오버레이 */}
                            <motion.div
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ duration: 0.4, delay: 0.2 }}
                                className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm"
                            >
                                <h3 className="font-semibold text-gray-800 mb-1">피부 레이더 비교</h3>
                                <p className="text-xs text-gray-400 mb-4">
                                    현재({latestAnalysis ? fmtDate(latestAnalysis.created_at) : ""}) vs 이전({previousDate}) 피부 상태 비교
                                </p>
                                <ResponsiveContainer width="100%" height={280}>
                                    <RadarChart data={compareRadarData} margin={{ top: 10, right: 30, bottom: 10, left: 30 }}>
                                        <PolarGrid stroke="#E5E7EB" />
                                        <PolarAngleAxis dataKey="subject" tick={{ fontSize: 12, fill: "#6B7280" }} />
                                        <Radar
                                            name="이전"
                                            dataKey="B"
                                            stroke="#9CA3AF"
                                            fill="#9CA3AF"
                                            fillOpacity={0.15}
                                            strokeDasharray="5 3"
                                        />
                                        <Radar
                                            name="현재"
                                            dataKey="A"
                                            stroke="#84C13D"
                                            fill="#84C13D"
                                            fillOpacity={0.35}
                                        />
                                        <Legend formatter={(value) => <span className="text-xs text-gray-600">{value}</span>} />
                                    </RadarChart>
                                </ResponsiveContainer>
                            </motion.div>
                        </div>
                )}
            </div>
        </div>
    );
}
