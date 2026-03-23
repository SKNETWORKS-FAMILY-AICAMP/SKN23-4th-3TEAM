// const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000";
const API_BASE = import.meta.env.VITE_API_BASE_URL ?? "/api";

function getToken(): string {
    const token = localStorage.getItem("access_token");

    if (!token) throw new Error("로그인이 필요합니다.");

    return token;
}

export interface QnaItem {
    qna_id: number;
    user_id: number;
    manager_id: number | null;
    category: string | null;
    question_title: string | null;
    question: string;
    answer: string | null;
    nickname: string | null;
    created_at: string;
    updated_at: string;
}

export interface CreateQnaBody {
    category?: string;
    question_title?: string;
    question: string;
}

export interface UpdateQnaAnswerBody {
    answer: string;
}

export interface UpdateQnaBody {
    category?: string;
    question_title?: string;
    question: string;
}

/**
 * 문의 목록 조회
 * 관리자면 전체, 일반 사용자면 본인 문의만 백엔드에서 자동 분기
 */
export async function fetchQnaList(): Promise<QnaItem[]> {
    const res = await fetch(`${API_BASE}/qna`, {
        headers: {
            Authorization: `Bearer ${getToken()}`,
        },
    });

    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }

    return res.json() as Promise<QnaItem[]>;
}

/**
 * 문의 등록
 */
export async function createQna(body: CreateQnaBody): Promise<QnaItem> {
    const res = await fetch(`${API_BASE}/qna`, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${getToken()}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }

    return res.json() as Promise<QnaItem>;
}

/**
 * 관리자 답변 등록/수정
 */
export async function updateQnaAnswer(
    qnaId: number,
    body: UpdateQnaAnswerBody,
): Promise<QnaItem> {
    const res = await fetch(`${API_BASE}/qna/${qnaId}`, {
        method: "PATCH",
        headers: {
            Authorization: `Bearer ${getToken()}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }

    return res.json() as Promise<QnaItem>;
}

/**
 * 문의 삭제
 */
export async function deleteQna(qnaId: number): Promise<void> {
    const res = await fetch(`${API_BASE}/qna/${qnaId}`, {
        method: "DELETE",
        headers: {
            Authorization: `Bearer ${getToken()}`,
        },
    });

    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }
}

export async function updateQna(
    qnaId: number,
    body: UpdateQnaBody,
): Promise<QnaItem> {
    const res = await fetch(`${API_BASE}/qna/${qnaId}/question`, {
        method: "PATCH",
        headers: {
            Authorization: `Bearer ${getToken()}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data as { detail?: string }).detail ?? `서버 오류 (${res.status})`);
    }

    return res.json() as Promise<QnaItem>;
}