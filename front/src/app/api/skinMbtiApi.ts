const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000";

function getToken(): string {
    const token = localStorage.getItem("access_token");

    if (!token) throw new Error("로그인이 필요합니다.");

    return token;
}

function getUserId(): number {
    const raw =
        localStorage.getItem("user_id") ??
        localStorage.getItem("current_user_id") ??
        localStorage.getItem("id");

    const userId = Number(raw);

    if (!userId) {
        throw new Error("사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.");
    }

    return userId;
}

async function handleResponse<T>(res: Response): Promise<T> {
    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }

    return res.json() as Promise<T>;
}

export type SkinMbtiOption = "A" | "B" | "C" | "D";

export interface SkinMbtiScore {
    S: number;
    L: number;
    B: number;
    T: number;
    C: number;
    F: number;
}

export interface SkinMbtiResultDetail {
    code: string;
    title: string;
    subtitle: string;
    description: string;
    shortSummary?: string;
    skinGoal?: string;
    habits: string;
    morning_routine: string[];
    night_routine: string[];
    care_tips: string[];
    avoid_habits: string[];
    chatbot_suggestion: string;
    image_asset: string;
    background_color: string;
    accent_color: string;
}

export interface SkinMbtiResultData {
    mbti_code: string;
    result: SkinMbtiResultDetail;
    score: SkinMbtiScore;
}

interface SkinMbtiApiResponse {
    success: boolean;
    data: SkinMbtiResultData;
    error: string | null;
}

export async function submitSkinMbti(answers: SkinMbtiOption[]): Promise<SkinMbtiResultData> {
    if (answers.length !== 12) {
        throw new Error("답변은 12개여야 합니다.");
    }

    const res = await fetch(`${API_BASE}/skin-mbti`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${getToken()}`,
        },
        body: JSON.stringify({
            user_id: getUserId(),
            answers,
        }),
    });

    const data = await handleResponse<SkinMbtiApiResponse>(res);

    if (!data.success) {
        throw new Error(data.error ?? "피부 MBTI 결과 조회에 실패했습니다.");
    }

    return data.data;
}

export async function fetchSavedSkinMbti(): Promise<SkinMbtiResultData | null> {
    const userId = await getUserId();

    const res = await fetch(`${API_BASE}/skin-mbti/${userId}`, {
        headers: {
            Authorization: `Bearer ${getToken()}`,
        },
    });

    const data = await handleResponse<SkinMbtiApiResponse & { data: SkinMbtiResultData | null }>(res);

    if (!data.success) {
        throw new Error(data.error ?? "피부 MBTI 결과 조회에 실패했습니다.");
    }

    return data.data;
}