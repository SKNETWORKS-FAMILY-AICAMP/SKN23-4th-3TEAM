import { useState } from "react";

const TIP_STEPS = [
  {
    title: "피부 분석부터 시작해보세요!",
    description: "피부 사진을 올리면 현재 피부 상태를 빠르게 확인할 수 있어요.",
  },
  {
    title: "성분표 이미지를 올려보세요!",
    description: "화장품 전성분 이미지를 통해 성분 분석과 주의 포인트를 볼 수 있어요.",
  },
  {
    title: "챗봇에게 피부 고민을 물어보세요!",
    description: "트러블, 건조, 루틴 고민을 자연스럽게 상담할 수 있어요.",
  },
  {
    title: "퍼스널컬러도 확인 가능해요!",
    description:
      "사진을 업로드하면 나에게 어울리는 퍼스널컬러를 확인할 수 있어요.",
  },
   {
    title: "피부 분석 결과를 다시 볼 수 있어요!",
    description:
      "메뉴의 피부 분석 페이지에서 이전 분석 결과를 다시 확인할 수 있어요.",
  },
  {
    title: "피부 MBTI를 재미로 해보세요!",
    description:
      "피부 MBTI 메뉴에서 내 피부 성향을 가볍게 테스트해볼 수 있어요.",
  },
  {
    title: "추천 제품은 위시리스트에 저장해보세요!",
    description:
      "추천받은 제품을 찜해두고, 제품 링크로 바로 이동할 수도 있어요.",
  },
];

interface TipGuideModalProps {
  onClose: () => void;
}

export function TipGuideModal({ onClose }: TipGuideModalProps) {
  const [step, setStep] = useState(0);
  const isLast = step === TIP_STEPS.length - 1;

  const handleNext = () => {
    if (isLast) {
      onClose();
      return;
    }
    setStep((prev) => prev + 1);
  };

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/50 px-4">
      <div className="w-full max-w-md rounded-3xl bg-white p-6 shadow-xl">
        <div className="mb-6 flex justify-center gap-2">
          {TIP_STEPS.map((_, index) => (
            <div
              key={index}
              className={`h-2.5 rounded-full transition-all ${
                index === step ? "w-6 bg-onyou" : "w-2.5 bg-gray-300"
              }`}
            />
          ))}
        </div>

        <div className="mb-8 text-center">
          <h2 className="mb-3 text-xl font-bold text-gray-900">
            {TIP_STEPS[step].title}
          </h2>
          <p className="text-sm leading-6 text-gray-600">
            {TIP_STEPS[step].description}
          </p>
        </div>

        <div className="flex gap-3">
          <button
            type="button"
            onClick={onClose}
            className="flex-1 rounded-xl border border-gray-200 px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            건너뛰기
          </button>

          <button
            type="button"
            onClick={handleNext}
            className="flex-1 rounded-xl bg-onyou px-4 py-3 text-sm font-semibold text-white hover:brightness-95"
          >
            {isLast ? "시작하기" : "다음"}
          </button>
        </div>
      </div>
    </div>
  );
}