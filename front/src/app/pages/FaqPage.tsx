import { useState } from "react";
import { ChevronDown } from "lucide-react";

type FaqItem = {
    id: number;
    category: string;
    question: string;
    answer: string;
};

const faqData: FaqItem[] = [
    {
        id: 1,
        category: "서비스 소개",
        question: "이 서비스는 어떤 기능을 제공하나요?",
        answer:
            "이 서비스는 피부 사진 분석, 화장품 전성분 이미지 인식(OCR), 피부 고민 상담, 개인화된 스킨케어 가이드, 제품 추천, 위시리스트 저장 기능을 제공하는 AI 기반 스킨케어 서비스입니다.",
    },
    {
        id: 2,
        category: "이용 안내",
        question: "어떻게 이용하나요?",
        answer:
            "사용자는 피부 고민을 텍스트로 입력하거나, 피부 사진 또는 화장품 전성분 표 이미지를 업로드해 피부 분석 결과와 성분 체크 및 제품 추천 내용을 확인할 수 있습니다.",
    },
    {
        id: 3,
        category: "회원/계정",
        question: "회원가입을 필수로 해야 하나요?",
        answer:
            "비로그인으로도 간단한 챗봇 대화가 가능합니다. 회원가입 후 로그인을 하시면 보다 더 많은 기능을 이용하실 수 있습니다.",
    },
    {
        id: 4,
        category: "회원/계정",
        question: "회원가입을 하면 어떤 점이 좋은가요?",
        answer:
            "로그인한 사용자의 채팅 내역 저장 및 이전 채팅 이력을 확인 가능하며, 추천 제품을 위시리스트에 보관하는 등 개인화 기능을 더 편리하게 이용할 수 있습니다. 또한 피부 분석, 화장품 전성분 체크, 개인 피부 분석 이력 저장 등 다양한 기능을 이용하실 수 있습니다.",
    },
    {
        id: 5,
        category: "피부 분석",
        question: "피부 분석은 어떻게 진행되나요?",
        answer:
            "피부 분석은 빠른 분석과 정밀 분석 두 가지 방식으로 제공됩니다. 빠른 분석은 정면 얼굴 사진 1장을 기준으로 피부 상태를 분석하며, 정밀 분석은 정면, 좌측, 우측 얼굴 사진 3장을 바탕으로 보다 상세하게 피부 상태를 분석합니다.",
    },
    {
        id: 6,
        category: "성능 및 품질",
        question: "얼굴이 여러 명 나오는 사진도 사용할 수 있나요?",
        answer:
            "여러 명이 함께 있는 사진은 분석 정확도에 영향을 줄 수 있기 때문에 원활한 분석을 위해서 한 명의 얼굴이 명확하게 보이는 사진을 사용 부탁드립니다.",
    },
    {
        id: 7,
        category: "이용 안내",
        question: "사진은 어떻게 촬영하면 좋나요?",
        answer:
            "얼굴이 선명하게 보이도록 밝은 곳에서 촬영해 주세요. 흔들림이 적고 얼굴 윤곽과 피부 상태가 잘 보이는 이미지일수록 분석에 도움이 됩니다. 자세한 사항은 사진 업로드 시 기재되어있는 설명을 참고 부탁드립니다.",
    },
    {
        id: 8,
        category: "서비스 소개",
        question: "피부 분석을 하면 어떤 항목을 확인할 수 있나요?",
        answer:
            "현재 분석에서는 종합 피부 점수, 추천 관리법, 피부 지표 상세 (수분, 탄력, 주름, 모공, 색소침착), 피부 레이더 차트를 확인할 수 있으며 비교 분석에서는 피부 점수 변화, 지표별 변화, 피부 레이더 비교를 확인하실 수 있습니다.",
    },
    {
        id: 9,
        category: "성능 및 품질",
        question: "화장한 상태의 사진도 분석할 수 있나요?",
        answer:
            "화장된 상태에서는 피부 분석이 어렵기 때문에 메이크업을 모두 제거한 뒤 깨끗이 세안 후 물기가 남아있지 않은 상태에서 촬영해주세요.",
    },
    {
        id: 10,
        category: "운영문의",
        question: "분석 결과는 의료 진단인가요?",
        answer:
            "아닙니다. 본 서비스는 스킨케어 정보 제공 목적의 서비스이며, 의료 진단이나 치료를 대신하지 않습니다. 피부 질환이 의심되거나 증상이 지속되면 전문 의료진 상담이 필요합니다.",
    },
    {
        id: 11,
        category: "성분 분석",
        question: "화장품 성분 분석은 어떻게 이용하나요?",
        answer:
            "화장품 전성분표가 보이는 이미지를 업로드하면 OCR로 성분을 인식해 추출합니다. 추출된 성분을 바탕으로 내 피부 타입이나 고민에 맞는 성분인지, 주의해야 할 성분이 포함되어 있는지 안내받을 수 있습니다.",
    },
    {
        id: 12,
        category: "성능 및 품질",
        question: "전성분표 이미지가 잘 인식되지 않으면 어떻게 하나요?",
        answer:
            "글자가 흐리거나 흔들렸을 경우, 일부가 잘린 경우에는 인식 정확도가 낮아질 수 있으므로, 전성분 영역이 또렷하게 보이도록 수평을 맞춰 다시 촬영한 뒤 업로드해 주세요.",
    },
    {
        id: 13,
        category: "추천 서비스",
        question: "추천 제품은 어떤 기준으로 제공되나요?",
        answer:
            "추천은 피부 분석 결과, 성분 분석 결과, 피부 고민 및 프로필 정보 등을 종합해 개인에게 적합한 방향으로 제공됩니다.",
    },
    {
        id: 14,
        category: "추천 서비스",
        question: "추천 제품은 실제 구매 가능한 상품인가요?",
        answer:
            "서비스 운영 방식에 따라 실제 판매 중인 상품 정보를 기반으로 추천이 제공될 수 있으며, 연동된 판매처 정보가 함께 안내될 수 있습니다.",
    },
    {
        id: 15,
        category: "추천 서비스",
        question: "추천 결과를 저장할 수 있나요?",
        answer:
            "네. 관심 있는 추천 제품은 위시리스트에 저장해 나중에 다시 확인할 수 있습니다.",
    },
    {
        id: 16,
        category: "회원/계정",
        question: "이전 분석 결과를 다시 볼 수 있나요?",
        answer:
            "로그인한 경우 이전 분석 결과와 이용 이력을 다시 확인할 수 있습니다.",
    },
    {
        id: 17,
        category: "피부 상담",
        question: "피부 고민 상담도 가능한가요?",
        answer:
            "가능합니다. 피부 고민, 스킨케어 루틴, 성분 관련 질문 등에 대해 AI 챗봇 상담 형태로 안내를 받을 수 있습니다.",
    },
    {
        id: 18,
        category: "서비스 소개",
        question: "추천이나 상담은 어떤 정보를 참고하나요?",
        answer:
            "서비스는 공공 데이터, 성분 정보, 피부과학 관련 공개 자료, 가이드라인 등을 참고해 상담 및 추천 근거를 보강할 수 있습니다.",
    },
    {
        id: 19,
        category: "개인정보/정책",
        question: "내 정보와 분석 데이터는 어떻게 활용되나요?",
        answer:
            "입력한 정보와 분석 데이터는 개인화된 상담·추천 제공, 이력 관리, 서비스 품질 개선 등을 위해 활용될 수 있습니다. 자세한 내용은 개인정보처리방침에서 확인할 수 있습니다.",
    },
    {
        id: 20,
        category: "성능 및 품질",
        question: "피부 분석이 매번 다른 결과로 나올 수 있나요?",
        answer:
            "사진의 각도, 조명, 해상도, 피부 상태 표현 정도에 따라 결과가 달라질 수 있습니다. 결과는 참고용으로 활용해 주세요.",
    },
];

export function FaqPage() {
    const [openId, setOpenId] = useState<number | null>(1);

    const handleToggle = (id: number) => {
        setOpenId((prev) => (prev === id ? null : id));
    };

    return (
        <div className="h-full overflow-y-auto bg-[#F8FBF3]">
            <div className="mx-auto max-w-5xl px-4 py-8">
                <div className="mb-8">
                    <h1 className="text-2xl font-bold text-gray-900">FAQ</h1>
                    <p className="mt-2 text-sm text-gray-600">
                        자주 묻는 질문을 모아두었어요!
                    </p>
                </div>

                <div className="space-y-3">
                    {faqData.map((item) => {
                        const isOpen = openId === item.id;

                        return (
                            <div
                                key={item.id}
                                className="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm"
                            >
                                <button
                                    type="button"
                                    onClick={() => handleToggle(item.id)}
                                    className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
                                >
                                    <div className="min-w-0">
                                        <p className="mb-1 text-xs font-semibold text-[#7BA05B]">
                                            [{item.category}]
                                        </p>
                                        <p className="text-sm font-semibold text-gray-900 sm:text-base">
                                            Q{item.id}. {item.question}
                                        </p>
                                    </div>

                                    <ChevronDown
                                        className={`h-5 w-5 shrink-0 text-gray-500 transition-transform duration-200 ${
                                            isOpen ? "rotate-180" : ""
                                        }`}
                                    />
                                </button>

                                {isOpen && (
                                    <div className="border-t border-gray-100 bg-gray-50 px-5 py-4">
                                        <p className="text-sm leading-7 text-gray-700">
                                            A. {item.answer}
                                        </p>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            </div>
        </div>
    );
}