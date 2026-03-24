declare global {
  interface Window {
    Kakao: any;
  }
}

export function initKakao() {
  if (typeof window === "undefined") return false;
  if (!window.Kakao) {
    console.error("Kakao SDK가 로드되지 않았습니다.");
    return false;
  }

  const jsKey = import.meta.env.VITE_KAKAO_JAVASCRIPT_KEY;
  if (!jsKey) {
    console.error("VITE_KAKAO_JAVASCRIPT_KEY가 없습니다.");
    return false;
  }

  if (!window.Kakao.isInitialized()) {
    window.Kakao.init(jsKey);
  }

  return true;
}

type ShareSkinAnalysisParams = {
  resultUrl: string;
  imageUrl?: string;
  title?: string;
  description?: string;
};

export function shareSkinAnalysisToKakao({
  resultUrl,
  imageUrl = "https://via.placeholder.com/300x200.png?text=Skin+Analysis",
  title = "내 피부 분석 결과",
  description = "AI가 분석한 내 피부 상태를 확인해보세요.",
}: ShareSkinAnalysisParams) {
  const initialized = initKakao();

  if (!initialized) {
    alert("카카오 공유를 초기화하지 못했습니다. SDK 또는 환경변수를 확인해주세요.");
    return;
  }

  if (!window.Kakao.Share) {
    alert("카카오 공유 모듈을 불러오지 못했습니다.");
    return;
  }

  window.Kakao.Share.sendDefault({
    objectType: "feed",
    content: {
      title,
      description,
      imageUrl,
      link: {
        mobileWebUrl: resultUrl,
        webUrl: resultUrl,
      },
    },
    buttons: [
      {
        title: "결과 보러가기",
        link: {
          mobileWebUrl: resultUrl,
          webUrl: resultUrl,
        },
      },
    ],
  });
}