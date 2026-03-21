import { useLocation, useNavigate } from "react-router";
import { motion } from "motion/react";
import {
    ArrowLeft,
    RotateCcw,
    Sparkles,
    Target,
    HeartHandshake,
    Sun,
    Moon,
    Lightbulb,
    AlertTriangle,
    MessageCircle,
} from "lucide-react";
import type { SkinMbtiResultData } from "@/app/api/skinMbtiApi";

const skinMbtiImages = import.meta.glob("@/assets/skin_mbti/*", {
    eager: true,
    import: "default",
}) as Record<string, string>;

function colorFromFlutterHex(value?: string, fallback = "#F8FBF3") {
    if (!value || !value.startsWith("0x") || value.length !== 10) {
        return fallback;
    }

    return `#${value.slice(4)}`;
}

function resolveSkinMbtiImage(imageAsset?: string) {
    if (!imageAsset) return null;

    const fileName = imageAsset.split("/").pop();
    if (!fileName) return null;

    const matchedEntry = Object.entries(skinMbtiImages).find(([path]) =>
        path.endsWith(`/${fileName}`)
    );

    return matchedEntry?.[1] ?? null;
}

function InfoCard({
    icon,
    title,
    children,
    bgColor,
}: {
    icon: React.ReactNode;
    title: string;
    children: React.ReactNode;
    bgColor: string;
}) {
    return (
        <section
            className="rounded-3xl border border-[#ECE7DC] shadow-sm p-6"
            style={{ backgroundColor: bgColor }}
        >
            <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 rounded-full bg-[#FFF7E8] flex items-center justify-center text-[#D9A441]">
                    {icon}
                </div>
                <h2 className="text-xl font-bold text-gray-900">{title}</h2>
            </div>
            <div className="text-[15px] leading-7 text-gray-700">{children}</div>
        </section>
    );
}

export function SkinMbtiResultPage() {
    const navigate = useNavigate();
    const location = useLocation();
    const resultData = location.state as SkinMbtiResultData | undefined;

    if (!resultData) {
        return (
            <div className="min-h-screen bg-[#F8F7F2] px-6 py-8">
                <div className="max-w-6xl mx-auto">
                    <div className="bg-white rounded-3xl border border-[#ECE7DC] shadow-sm p-10 text-center">
                        <h1 className="text-2xl font-bold text-gray-900 mb-3">결과 정보가 없어요</h1>
                        <p className="text-gray-500 mb-6">테스트를 먼저 진행한 뒤 결과를 확인해주세요.</p>
                        <button
                            type="button"
                            onClick={() => navigate("/skin-mbti")}
                            className="px-5 py-3 rounded-2xl bg-onyou text-white font-semibold cursor-pointer"
                        >
                            테스트 하러 가기
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    const { mbti_code, result } = resultData;

    const bgColor = colorFromFlutterHex(result.background_color, "#F4E6D4");
    const accentColor = colorFromFlutterHex(result.accent_color, "#9B7B52");
    const imageSrc = resolveSkinMbtiImage(result.image_asset);
    const pageBgColor = mixColor(bgColor, "#FFFFFF", 0.88);
    const cardBgColor = mixColor(bgColor, "#FFFFFF", 0.94);
    const softPanelColor = mixColor(bgColor, "#FFFFFF", 0.78);

    return (
        <div className="min-h-screen" style={{ backgroundColor: pageBgColor }}>
            <div className="max-w-6xl mx-auto px-6 py-8">
                <motion.section
                    initial={{ opacity: 0, y: 18 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.3 }}
                    className="relative rounded-[36px] border border-[#ECE7DC] shadow-sm overflow-hidden"
                    style={{ backgroundColor: bgColor }}
                >
                    <button
                        type="button"
                        onClick={() =>
                            navigate("/skin-mbti", {
                                state: { forceRetest: true },
                            })
                        }
                        className="absolute top-6 right-6 z-10 inline-flex items-center gap-2 px-4 py-2.5 rounded-2xl border border-gray-200 bg-white/95 text-sm font-semibold text-gray-700 hover:bg-white cursor-pointer shadow-sm"
                    >
                        <RotateCcw className="w-4 h-4" />
                        다시 검사하기
                    </button>

                    <div className="grid grid-cols-1 lg:grid-cols-[420px_minmax(0,1fr)] gap-0">
                        <div className="p-8 lg:p-10 flex flex-col items-center justify-center border-b lg:border-b-0 lg:border-r border-white/30">
                            <div className="w-full max-w-[290px] aspect-square rounded-[32px] bg-white/45 flex items-center justify-center overflow-hidden">
                                {imageSrc ? (
                                    <img
                                        src={imageSrc}
                                        alt={result.title}
                                        className="w-[82%] h-[82%] object-contain"
                                    />
                                ) : (
                                    <div className="text-sm text-gray-400">이미지 없음</div>
                                )}
                            </div>

                            <div
                                className="mt-5 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/75 text-sm font-bold"
                                style={{ color: accentColor }}
                            >
                                <Sparkles className="w-4 h-4" />
                                {result.subtitle}
                            </div>
                        </div>

                        <div className="p-8 pt-20 lg:p-10 lg:pt-10 flex flex-col justify-center">
                            <p className="text-sm font-bold mb-3" style={{ color: accentColor }}>
                                {mbti_code}
                            </p>

                            <h1 className="text-4xl lg:text-5xl font-bold text-gray-900 tracking-[-0.03em] leading-tight mb-4">
                                {result.title}
                            </h1>

                            <p className="text-lg leading-8 text-gray-700 mb-6">
                                {result.description}
                            </p>

                            <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
                                <div
                                    className="rounded-3xl p-5"
                                    style={{ backgroundColor: softPanelColor }}
                                >
                                    <div className="flex items-center gap-2 mb-3">
                                        <Sparkles className="w-4 h-4" style={{ color: accentColor }} />
                                        <h3 className="font-bold text-gray-900">한눈에 보는 내 타입</h3>
                                    </div>
                                    <p className="text-[15px] leading-7 text-gray-700">
                                        {result.shortSummary ?? result.description}
                                    </p>
                                </div>

                                <div
                                    className="rounded-3xl p-5"
                                    style={{ backgroundColor: softPanelColor }}
                                >
                                    <div className="flex items-center gap-2 mb-3">
                                        <Target className="w-4 h-4" style={{ color: accentColor }} />
                                        <h3 className="font-bold text-gray-900">피부 목표</h3>
                                    </div>
                                    <p className="text-[15px] leading-7 text-gray-700">
                                        {result.skinGoal ?? "내 피부에 맞는 안정적인 루틴을 유지하는 것이 중요해요."}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </motion.section>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-5 mt-6">
                    <InfoCard icon={<HeartHandshake className="w-4 h-4" />} title="이런 습관이 많아요" bgColor={cardBgColor}>
                        <p>{result.habits}</p>
                    </InfoCard>

                    <InfoCard icon={<MessageCircle className="w-4 h-4" />} title="추천 챗봇 대화" bgColor={cardBgColor}>
                        <p
                            onClick={() => navigate("/chat", { state: { mbtiMessage: `내 피부 MBTI ${mbti_code}(${result.title})에 맞는 ${result.chatbot_suggestion} 알려줘` } })}
                            className="cursor-pointer text-[#4A7A1E] font-semibold hover:text-[#3A6A0E] hover:underline transition-colors"
                        >
                            💬 {result.chatbot_suggestion}
                        </p>
                    </InfoCard>

                    <InfoCard icon={<Sun className="w-4 h-4" />} title="아침 루틴" bgColor={cardBgColor}>
                        <ul className="space-y-2">
                            {result.morning_routine.map((item) => (
                                <li key={item} className="flex gap-3">
                                    <span className="mt-[10px] block w-1.5 h-1.5 rounded-full bg-[#FF8FB1] flex-shrink-0" />
                                    <span>{item}</span>
                                </li>
                            ))}
                        </ul>
                    </InfoCard>

                    <InfoCard icon={<Moon className="w-4 h-4" />} title="저녁 루틴" bgColor={cardBgColor}>
                        <ul className="space-y-2">
                            {result.night_routine.map((item) => (
                                <li key={item} className="flex gap-3">
                                    <span className="mt-[10px] block w-1.5 h-1.5 rounded-full bg-[#FF8FB1] flex-shrink-0" />
                                    <span>{item}</span>
                                </li>
                            ))}
                        </ul>
                    </InfoCard>

                    <InfoCard icon={<Lightbulb className="w-4 h-4" />} title="케어 팁" bgColor={cardBgColor}>
                        <ul className="space-y-2">
                            {result.care_tips.map((item) => (
                                <li key={item} className="flex gap-3">
                                    <span className="mt-[10px] block w-1.5 h-1.5 rounded-full bg-[#FF8FB1] flex-shrink-0" />
                                    <span>{item}</span>
                                </li>
                            ))}
                        </ul>
                    </InfoCard>

                    <InfoCard icon={<AlertTriangle className="w-4 h-4" />} title="피하면 좋은 습관" bgColor={cardBgColor}>
                        <ul className="space-y-2">
                            {result.avoid_habits.map((item) => (
                                <li key={item} className="flex gap-3">
                                    <span className="mt-[10px] block w-1.5 h-1.5 rounded-full bg-[#FF8FB1] flex-shrink-0" />
                                    <span>{item}</span>
                                </li>
                            ))}
                        </ul>
                    </InfoCard>
                </div>
            </div>
        </div>
    );
}
function hexToRgb(hex: string) {
    const normalized = hex.replace("#", "");
    const bigint = parseInt(normalized, 16);

    return {
        r: (bigint >> 16) & 255,
        g: (bigint >> 8) & 255,
        b: bigint & 255,
    };
}

function mixColor(hex: string, target = "#FFFFFF", ratio = 0.85) {
    const base = hexToRgb(hex);
    const mix = hexToRgb(target);

    const r = Math.round(base.r * (1 - ratio) + mix.r * ratio);
    const g = Math.round(base.g * (1 - ratio) + mix.g * ratio);
    const b = Math.round(base.b * (1 - ratio) + mix.b * ratio);

    return `rgb(${r}, ${g}, ${b})`;
}