import { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router";
import { ScanFace } from "lucide-react";
import { Loading } from "@/app/components/ui/loading";
import { Icon } from "../components/ui/icon";
import {
    RadarChart,
    Radar,
    PolarGrid,
    PolarAngleAxis,
    ResponsiveContainer,
    Legend,
} from "recharts";
import {
    fetchSharedAnalysisResult,
    fetchFactorials,
    type AnalysisResult,
    type KeywordResponse,
} from "@/app/api/analysisApi";

/**
 * SharedAnalysisPage
 * ─────────────────────────────────────────────────────────────
 * 공유 토큰으로 공개된 피부 분석 결과를 조회하는 페이지.
 *
 * 경로:
 *   /shared/analysis/:token
 * ─────────────────────────────────────────────────────────────
 */

const SKIN_METRICS = [
    { key: "moisture", label: "수분", icon: "moisture" as const, color: "#4e76ba" },
    { key: "elasticity", label: "탄력", icon: "elasticity" as const, color: "#6cb78e" },
    { key: "wrinkle", label: "주름", icon: "wrinkle" as const, color: "#f6b483" },
    { key: "pore", label: "모공", icon: "pore" as const, color: "#8959a2" },
    { key: "pigmentation", label: "색소침착", icon: "pigmentation" as const, color: "#cc528e" },
];

const factorialImages = import.meta.glob<string>(
    "../../assets/factorial/*.svg",
    { eager: true, query: "?url", import: "default" },
);

function extractNum(raw: unknown, fallback = 0): number {
    if (typeof raw === "number") return raw;

    if (raw && typeof raw === "object" && "score" in raw) {
        const score = Number((raw as { score?: unknown }).score);
        return Number.isFinite(score) ? score : fallback;
    }

    return fallback;
}

function extractStr(raw: unknown, fallback = ""): string {
    if (typeof raw === "string") return raw;

    if (raw && typeof raw === "object" && "label" in raw) {
        return String((raw as { label?: unknown }).label ?? fallback);
    }

    return fallback;
}

function fmtDate(iso?: string): string {
    if (!iso) return "";
    const d = new Date(iso);

    if (Number.isNaN(d.getTime())) return iso;

    return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, "0")}.${String(
        d.getDate(),
    ).padStart(2, "0")}`;
}

function ScoreRing({ score }: { score: number }) {
    const safe = Math.max(0, Math.min(100, score));
    const circumference = 2 * Math.PI * 54;
    const offset = circumference - (safe / 100) * circumference;

    return (
        <div className="relative w-40 h-40 shrink-0">
            <svg className="w-full h-full -rotate-90" viewBox="-6 -6 132 132">
                <circle cx="60" cy="60" r="54" fill="none" stroke="#E5E7EB" strokeWidth="12" />
                <circle
                    cx="60"
                    cy="60"
                    r="54"
                    fill="none"
                    stroke="#84C13D"
                    strokeWidth="12"
                    strokeLinecap="round"
                    strokeDasharray={circumference}
                    strokeDashoffset={offset}
                />
            </svg>

            <div className="absolute inset-0 flex flex-col items-center justify-center">
                <div className="text-4xl font-bold text-onyou">{safe}</div>
                <div className="text-xs text-gray-400">전체 점수</div>
            </div>
        </div>
    );
}

function MetricBar({ value, color }: { value: number; color: string }) {
    const safe = Math.max(0, Math.min(100, value));

    return (
        <div className="w-full bg-gray-100 rounded-full h-2 overflow-hidden">
            <div
                className="h-full rounded-full"
                style={{
                    width: `${safe}%`,
                    background: color,
                }}
            />
        </div>
    );
}

export function SharedAnalysisPage() {
    const { token } = useParams();
    const [result, setResult] = useState<AnalysisResult | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [factorialList, setFactorialList] = useState<KeywordResponse[]>([]);

    useEffect(() => {
        fetchFactorials()
            .then(setFactorialList)
            .catch((err: Error) => console.error("팩토리얼 키워드 목록 조회 실패:", err));
    }, []);

    useEffect(() => {
        async function loadSharedAnalysis() {
            if (!token) {
                setError("공유 토큰이 없습니다.");
                setLoading(false);
                return;
            }

            try {
                const data = await fetchSharedAnalysisResult(token);
                setResult(data);
            } catch (e) {
                console.error("[SharedAnalysisPage] load error =", e);
                setError("공유된 피부 분석 결과를 불러올 수 없습니다.");
            } finally {
                setLoading(false);
            }
        }

        loadSharedAnalysis();
    }, [token]);

    const overallScore = useMemo(() => {
        if (!result) return 0;
        return extractNum(result.skin_score, extractNum(result.analysis_data?.overall_score, 0));
    }, [result]);

    const skinType = extractStr(result?.analysis_data?.skin_type, "분석 결과");
    const skinTypeDetail = extractStr(
        result?.analysis_data?.skin_type_detail,
        "피부 타입 설명이 없습니다.",
    );
    const imageUrl = result?.image_url?.[0] ?? "";
    const factorial = result?.factorial ?? [];
    const metricsRaw = (result?.analysis_data?.metrics ?? {}) as Record<string, unknown>;

    const metricItems = SKIN_METRICS.map((metric) => {
        const raw = metricsRaw[metric.key];

        return {
            ...metric,
            value: extractNum(raw, 0),
            desc: extractStr(raw, "정보 없음"),
        };
    });

    const getVal = (key: string) => metricItems.find((item) => item.key === key)?.value ?? 0;

    const radarData = [
        { subject: "수분", A: getVal("moisture") },
        { subject: "탄력", A: getVal("elasticity") },
        { subject: "주름", A: getVal("wrinkle") },
        { subject: "모공", A: getVal("pore") },
        { subject: "색소침착", A: getVal("pigmentation") },
    ];

    if (loading) return <Loading />;

    if (error) {
        return (
            <div className="min-h-screen bg-[#FAFAF7] px-4 py-10">
                <div className="max-w-5xl mx-auto">
                    <div className="bg-white rounded-3xl border border-red-100 shadow-sm p-8 text-center">
                        <div className="w-14 h-14 mx-auto rounded-2xl bg-red-50 flex items-center justify-center mb-4">
                            <ScanFace className="w-7 h-7 text-red-400" />
                        </div>
                        <h1 className="text-lg font-bold text-gray-800 mb-2">결과를 불러올 수 없어요</h1>
                        <p className="text-sm text-gray-500">{error}</p>
                    </div>
                </div>
            </div>
        );
    }

    if (!result) {
        return (
            <div className="min-h-screen bg-[#FAFAF7] px-4 py-10">
                <div className="max-w-5xl mx-auto">
                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-8 text-center">
                        <div className="w-14 h-14 mx-auto rounded-2xl bg-gray-100 flex items-center justify-center mb-4">
                            <ScanFace className="w-7 h-7 text-gray-400" />
                        </div>
                        <h1 className="text-lg font-bold text-gray-800 mb-2">공유 결과가 없습니다</h1>
                        <p className="text-sm text-gray-500">유효한 공유 링크인지 확인해 주세요.</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-[#FAFAF7] px-4 py-8 md:py-10">
            <div className="max-w-6xl mx-auto">
                <div className="mb-6">
                    <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#F0FAE4] text-onyou text-xs font-semibold mb-3">
                        공개 공유 결과
                    </div>

                    <h1 className="text-2xl md:text-3xl font-bold text-gray-900">피부 분석 결과</h1>

                    <p className="text-sm text-gray-500 mt-2">
                        분석일 {fmtDate(result.created_at)}
                    </p>
                </div>

                <div className="grid grid-cols-1 xl:grid-cols-[2fr_0.8fr] gap-5 mb-5">
                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
                        <div className="flex flex-col md:flex-row items-start md:items-center gap-6">
                            <ScoreRing score={overallScore} />

                            <div className="flex-1 min-w-0">
                                <div className="inline-flex items-center px-3 py-1 rounded-xl bg-onyou text-white text-sm font-semibold mb-3">
                                    {skinType}
                                </div>

                                <p className="text-gray-600 leading-relaxed break-keep">
                                    {skinTypeDetail}
                                </p>

                                <div className="mt-5">
                                    <div className="flex items-center gap-2 mb-3">
                                        <span className="px-2.5 py-1 rounded-lg text-xs font-semibold text-white bg-onyou">
                                            추천 관리법
                                        </span>
                                    </div>

                                    {factorial.length > 0 ? (
                                        <div className="flex items-start gap-3 flex-wrap">
                                            {factorial.map((label) => {
                                                const item = factorialList.find((f) => f.label === label);
                                                const imgSrc = item
                                                    ? factorialImages[
                                                          `../../assets/factorial/${item.keyword}.svg`
                                                      ]
                                                    : undefined;

                                                return (
                                                    <div
                                                        key={label}
                                                        className="flex flex-col items-center gap-1"
                                                    >
                                                        {imgSrc ? (
                                                            <img
                                                                src={imgSrc}
                                                                alt={item?.label ?? label}
                                                                className="w-18 h-18 object-contain"
                                                            />
                                                        ) : (
                                                            <div className="w-18 h-18 rounded-2xl bg-[#F5F7F2] border border-gray-100 flex items-center justify-center">
                                                                <span className="text-[11px] text-gray-400">
                                                                    준비중
                                                                </span>
                                                            </div>
                                                        )}

                                                        <span className="w-18 text-[13px] text-gray-500 text-center font-medium leading-tight break-keep">
                                                            {item?.label ?? label}
                                                        </span>
                                                    </div>
                                                );
                                            })}
                                        </div>
                                    ) : (
                                        <p className="text-sm text-gray-400">
                                            추천 관리 정보가 없습니다.
                                        </p>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden min-h-[320px]">
                        {imageUrl ? (
                            <img
                                src={imageUrl}
                                alt="피부 분석 이미지"
                                className="w-full h-full object-cover min-h-[320px]"
                            />
                        ) : (
                            <div className="h-full min-h-[320px] flex flex-col items-center justify-center text-center p-6">
                                <div className="w-14 h-14 rounded-2xl bg-gray-100 flex items-center justify-center mb-4">
                                    <ScanFace className="w-7 h-7 text-gray-400" />
                                </div>
                                <p className="text-sm font-semibold text-gray-700 mb-1">
                                    분석 이미지가 없습니다
                                </p>
                                <p className="text-xs text-gray-400">
                                    업로드된 이미지가 없거나 표시할 수 없습니다.
                                </p>
                            </div>
                        )}
                    </div>
                </div>

                <div className="space-y-5">
                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-1">피부 지표 상세</h2>
                        <p className="text-xs text-gray-400 mb-5">각 항목별 현재 피부 상태</p>

                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                            {metricItems.map((metric) => (
                                <div
                                    key={metric.key}
                                    className="flex items-start gap-3 p-3 rounded-xl bg-gray-50"
                                >
                                    <div
                                        className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
                                        style={{ background: `${metric.color}20` }}
                                    >
                                        <Icon name={metric.icon} size={20} />
                                    </div>

                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center justify-between mb-1">
                                            <span className="text-sm font-medium text-gray-700">
                                                {metric.label}
                                            </span>
                                            <span
                                                className="text-sm font-bold"
                                                style={{ color: metric.color }}
                                            >
                                                {metric.value}
                                            </span>
                                        </div>

                                        <MetricBar value={metric.value} color={metric.color} />

                                        <p className="text-[11px] text-gray-400 mt-1 break-keep">
                                            {metric.desc}
                                        </p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
                        <h2 className="text-lg font-bold text-gray-900 mb-1">피부 레이더 차트</h2>
                        <p className="text-xs text-gray-400 mb-4">현재 피부 상태 종합</p>

                        <ResponsiveContainer width="100%" height={280}>
                            <RadarChart
                                data={radarData}
                                margin={{ top: 10, right: 30, bottom: 10, left: 30 }}
                            >
                                <PolarGrid stroke="#E5E7EB" />
                                <PolarAngleAxis
                                    dataKey="subject"
                                    tick={{ fontSize: 12, fill: "#6B7280" }}
                                />
                                <Radar
                                    name="현재"
                                    dataKey="A"
                                    stroke="#84C13D"
                                    fill="#84C13D"
                                    fillOpacity={0.3}
                                />
                                <Legend
                                    formatter={(value) => (
                                        <span className="text-xs text-gray-600">{value}</span>
                                    )}
                                />
                            </RadarChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>
        </div>
    );
}