import { useEffect } from "react";
import { useNavigate } from "react-router";
import { Loading } from "@/app/components/ui/loading";
import { fetchCurrentUser } from "@/app/api/userApi";

function clearGuestData(): void {
    localStorage.removeItem("guest_chats");
    localStorage.removeItem("guest_chat_count");
}

/**
  * OAuthCallbackPage
  * ─────────────────────────────────────────────────────────────
  * 경로: /oauth/callback
  *
  * 소셜 로그인(Google / Kakao) 완료 후 백엔드가 리디렉션하는 페이지.
  * URL 파라미터:
  *   ?token=<jwt>           성공 시 JWT 토큰
  *   ?error=<message>       실패 시 에러 메시지
  *   ?provider=google|kakao 어떤 provider로 로그인했는지 (선택)
  * ─────────────────────────────────────────────────────────────
  */
export function OAuthCallbackPage() {
    const navigate = useNavigate();

    useEffect(() => {
        const run = async () => {
            const params    = new URLSearchParams(window.location.search);
            const token     = params.get("token");
            const errorMsg  = params.get("error");
            const isNew     = params.get("is_new") === "true";

            if (!token) {
                const msg = errorMsg ?? "소셜 로그인에 실패했습니다.";
                navigate(`/login?error=${encodeURIComponent(msg)}`, { replace: true });
                return;
            }

            try {
                localStorage.setItem("access_token", token);

                const me = await fetchCurrentUser();
                if (me?.user_id != null) {
                    localStorage.setItem("user_id", String(me.user_id));
                }

                clearGuestData();

            // 신규 가입 유저는 온보딩, 기존 유저는 채팅으로 이동
                navigate(isNew ? "/onboarding" : "/chat", { replace: true });
            } catch {
                localStorage.removeItem("access_token");
                localStorage.removeItem("user_id");

                navigate(`/login?error=${encodeURIComponent("소셜 로그인 사용자 정보를 불러오지 못했습니다.")}`, {
                    replace: true,
                });
            }
        };

        run();
    }, [navigate]);

    return <Loading />;
}