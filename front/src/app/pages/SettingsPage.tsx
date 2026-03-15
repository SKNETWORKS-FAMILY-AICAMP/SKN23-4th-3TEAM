import DefaultProfile from "@/assets/profile.png"
import { uploadImage } from "@/app/api/uploadApi";
import { Input } from "@/app/components/ui/input";
import { Button } from "@/app/components/ui/button";
import { useState, useEffect, useRef } from "react";
import { Loading } from "@/app/components/ui/loading";
import { motion, AnimatePresence } from "motion/react";
import { User, Link2, MessageCircleQuestion, Check, ChevronRight, Loader2, Plus, X } from "lucide-react";
import { fetchCurrentUser, updateCurrentUser, fetchKeywords, fetchSocialLinks, KeywordItem } from "@/app/api/userApi";


// 밖에 고정되있어 관리자일때 고객 문의 버튼을 문의 목록으로 바꿀수없기에 삭제 요망 260314 jsw
// const sections = [
//     { id: "profile", label: "프로필", icon: User },
//     { id: "social", label: "소셜 연동", icon: Link2 },
//     { id: "qna", label: "고객 문의", icon: MessageCircleQuestion },
// ];

/** API 응답이 없을 때 사용할 피부 타입 폴백 목록 -> 필요한가..? */
const FALLBACK_SKIN_TYPES: KeywordItem[] = [
    { keyword_id: -1, type: "skin_type", keyword: "dry",       label: "건성",  description: null },
    { keyword_id: -2, type: "skin_type", keyword: "oily",      label: "지성",  description: null },
    { keyword_id: -3, type: "skin_type", keyword: "combo",     label: "복합성", description: null },
    { keyword_id: -4, type: "skin_type", keyword: "normal",    label: "중성",  description: null },
    { keyword_id: -5, type: "skin_type", keyword: "sensitive", label: "민감성", description: null },
];
const DEFAULT_CONCERNS = ["각질", "건조", "모공", "미백", "민감", "블랙헤드", "아토피", "유분", "장벽", "주름", "트러블", "피지", "흉터"];

/** back gender 값 → 화면 표시 레이블 */
const GENDER_LABEL: Record<string, string> = {
    male   : "남성",
    female : "여성",
};

export function SettingsPage() {
    const [activeSection, setActiveSection] = useState("profile");

    // 사용자 기본 정보 (read-only, API에서 로드)
    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [profileImageUrl, setProfileImageUrl] = useState<string | null>(null);
    const [isLoadingUser, setIsLoadingUser] = useState(true);
    const [fetchError, setFetchError] = useState<string | null>(null);

    // 관리자 구분을 위해 isadmin 상태를 받음 260314 jsw
    const [isAdmin, setIsAdmin] = useState(false);
    const effectiveIsAdmin = true;
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 10;

    // Profile (editable)
    const [nickname, setNickname] = useState("");
    const [age, setAge] = useState("");
    const [gender, setGender] = useState("");
    const [skinType, setSkinType] = useState("");           // 선택된 label 문자열
    const [skinTypeKeywords, setSkinTypeKeywords] = useState<KeywordItem[]>(FALLBACK_SKIN_TYPES);
    const [selectedConcerns, setSelectedConcerns] = useState<string[]>([]);
    const [customConcerns, setCustomConcerns] = useState<string[]>([]);
    const [showAddConcern, setShowAddConcern] = useState(false);
    const [newConcernInput, setNewConcernInput] = useState("");
    const [isSaving, setIsSaving] = useState(false);
    const [saved, setSaved] = useState(false);
    const [saveError, setSaveError] = useState<string | null>(null);
    const [isUploadingPhoto, setIsUploadingPhoto] = useState(false);
    const profileInputRef = useRef<HTMLInputElement>(null);
    const [fieldErrors, setFieldErrors] = useState<{ gender?: string; age?: string; skinType?: string }>({});

    // 상단에 고정되 있던 section을 settingpage안으로 넣음 jsw 260314
    const sections = [
        { id: "profile", label: "프로필", icon: User },
        { id: "social", label: "소셜 연동", icon: Link2 },
        { id: "qna", label: effectiveIsAdmin ? "문의 목록" : "고객 문의", icon: MessageCircleQuestion },
    ];

    const [openInquiryId, setOpenInquiryId] = useState<number | null>(null);

    const toggleInquiry = (id: number) => {
        setOpenInquiryId(prev => prev === id ? null : id);
    };
    // ─── 사용자 정보 + skin_type 키워드 목록 동시 조회 ───
    useEffect(() => {
        setIsLoadingUser(true);

        Promise.all([fetchCurrentUser(), fetchKeywords("skin_type")])
            .then(([user, keywords]) => {
                // keywords 목록 설정 (빈 배열이면 폴백 유지)
                if (keywords.length > 0) setSkinTypeKeywords(keywords);
                setIsAdmin((user as { is_admin?: number }).is_admin === 1);
                setName(user.name);
                setEmail(user.email);
                setProfileImageUrl(user.profile_image_url ?? null);
                setNickname(user.nickname);
                setAge(user.age?.toString() ?? "");
                setGender(user.gender ? (GENDER_LABEL[user.gender] ?? "") : "");

                // skin_type (keyword_id) → label 변환
                const matched = keywords.find((k) => k.keyword_id === user.skin_type);

                setSkinType(matched?.label ?? "");

                if (user.skin_concern) {
                    const concerns = user.skin_concern.split(",").map((s) => s.trim()).filter(Boolean);
                    const customs = concerns.filter((c) => !DEFAULT_CONCERNS.includes(c));

                    setCustomConcerns(customs);
                    setSelectedConcerns(concerns);
                }
            })
            .catch((err: Error) => setFetchError(err.message))
            .finally(() => setIsLoadingUser(false));
    }, []);

    // 소셜 탭 진입 시 1회 조회
    useEffect(() => {
        if (activeSection !== "social" || socialFetchedRef.current) return;

        socialFetchedRef.current = true;
        
        setIsLoadingSocials(true);
        fetchSocialLinks()
            .then((data) => setConnectedProviders(data.providers))
            .catch((err: Error) => console.error("소셜 연동 조회 실패:", err))
            .finally(() => setIsLoadingSocials(false));
    }, [activeSection]);


    useEffect(() => {
        if (activeSection !== "qna") return;

        setIsLoadingInquiries(true);

        // 임시 목데이터
        const mockData: InquiryItem[] = [
            {
                inquiry_id: 1,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
            {
                inquiry_id: 2,
                user_id: 999,
                title: "로그인이 자꾸 풀립니다",
                category: "계정 문의",
                author_name: "김민수",
                created_at: "2026-03-13",
                content: "크롬에서 새로고침하면 로그아웃 상태가 됩니다.",
                answer: "현재 세션 유지 로직 점검 중입니다.",
                manager_id: 1,
            },
            {
                inquiry_id: 3,
                user_id: 999, // 현재 로그인한 사용자라고 가정
                title: "문의 테스트",
                category: "오류 제보",
                author_name: name || "내 이름",
                created_at: "2026-03-14",
                content: "일반 사용자 본인 문의 예시입니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 4,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 5,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 6,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 7,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 8,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 9,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 10,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 11,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
                        {
                inquiry_id: 12,
                user_id: 999,
                title: "피부 분석 결과가 저장되지 않아요",
                category: "서비스 문의",
                author_name: "홍길동",
                created_at: "2026-03-14",
                content: "분석을 완료했는데 마이페이지에서 조회가 안 됩니다.",
                answer: null,
                manager_id: null,
            },
        ];

        setTimeout(() => {
            if (effectiveIsAdmin) {
                // 관리자: 전체 문의 목록 조회
                setInquiries(mockData);
            } else {
                // 일반 사용자: 본인 문의만 조회
                // 실제 구현 시 user_id === 현재 로그인 유저 id 로 필터
                setInquiries(mockData.filter(item => item.user_id === 999));
            }

            setCurrentPage(1); // 탭 진입 시 페이지 초기화
            setIsLoadingInquiries(false);
        }, 300);
    }, [activeSection, effectiveIsAdmin, name]);

    // Security
    const [currentPw, setCurrentPw]           = useState("");
    const [newPw, setNewPw]                   = useState("");
    const [confirmPw, setConfirmPw]           = useState("");

    const pwMatch = confirmPw.length > 0 && newPw === confirmPw;

    // Social
    const [connectedProviders, setConnectedProviders] = useState<string[]>([]);
    const [isLoadingSocials, setIsLoadingSocials] = useState(false);
    const socialFetchedRef = useRef(false);

    // qna관련 item 260314  jsw
    type InquiryItem = {
        inquiry_id: number;
        user_id: number;                 // 문의 작성자 구분용
        title: string;
        category: string;
        author_name: string;
        created_at: string;
        content?: string;
        answer?: string | null;
        manager_id?: number | null;      // 관리자 답변 여부 판단용
    };
    const [showInquiryForm, setShowInquiryForm] = useState(false); // 일반 사용자 "문의하기" 클릭 시 작성 폼 표시용

    const [answerDrafts, setAnswerDrafts] = useState<Record<number, string>>({});// 문의별 답변 입력값 관리용

    // 일반 사용자용
    const [inquiryType, setInquiryType] = useState("");
    const [inquiryTitle, setInquiryTitle] = useState("");
    const [inquiryContent, setInquiryContent] = useState("");
    const [isSubmittingInquiry, setIsSubmittingInquiry] = useState(false);
    const [inquirySaved, setInquirySaved] = useState(false);

    // 관리자용
    const [inquiries, setInquiries] = useState<InquiryItem[]>([]);
    const [isLoadingInquiries, setIsLoadingInquiries] = useState(false);
    const [isSubmittingAnswer, setIsSubmittingAnswer] = useState(false);

    const allConcerns = [...DEFAULT_CONCERNS, ...customConcerns];

        const totalPages = Math.ceil(inquiries.length / itemsPerPage);

    const paginatedInquiries = inquiries.slice(
        (currentPage - 1) * itemsPerPage,
        currentPage * itemsPerPage
    );
    const toggleConcern = (c: string) => {
        setSelectedConcerns((prev) =>
            prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]
        );
    };

    const addCustomConcern = () => {
        const trimmed = newConcernInput.trim();
        if (trimmed && !allConcerns.includes(trimmed)) {
            setCustomConcerns((prev) => [...prev, trimmed]);
            setSelectedConcerns((prev) => [...prev, trimmed]);
        }
        setNewConcernInput("");
        setShowAddConcern(false);
    };

    const removeConcern = (c: string) => {
        setCustomConcerns((prev) => prev.filter((x) => x !== c));
        setSelectedConcerns((prev) => prev.filter((x) => x !== c));
    };

    const GENDER_TO_API: Record<string, "male" | "female"> = {
        "여성": "female",
        "남성": "male",
    };

    const handlePhotoChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];

        if (!file) return;

        setIsUploadingPhoto(true);

        try {
            const url = await uploadImage(file, "profile");
            // S3에 고정 파일명(profile.ext)으로 덮어쓰므로 URL이 동일함
            // 타임스탬프 쿼리스트링을 붙여 브라우저 캐시를 무효화
            setProfileImageUrl(`${url}?t=${Date.now()}`);
        } catch (err) {
            console.error("프로필 사진 업로드 실패:", err);
        } finally {
            setIsUploadingPhoto(false);
            // 같은 파일 재선택 허용
            if (profileInputRef.current) profileInputRef.current.value = "";
        }
    };

    const handleSave = async () => {
        // 필수 필드 검증
        const errors: { gender?: string; age?: string; skinType?: string } = {};

        if (!gender) errors.gender = "성별을 선택해 주세요.";
        if (!age)                             errors.age     = "나이를 입력해 주세요.";
        if (!skinType)                        errors.skinType = "피부 타입을 선택해 주세요.";
        if (Object.keys(errors).length > 0) {
            setFieldErrors(errors);

            return;
        }

        setFieldErrors({});
        setIsSaving(true);
        setSaveError(null);

        try {
            const skinKeywordId = skinTypeKeywords.find((k) => k.label === skinType)?.keyword_id ?? null;

            await updateCurrentUser({
                nickname,
                age              : age ? Number(age) : null,
                gender           : GENDER_TO_API[gender],
                skin_type        : skinKeywordId,
                skin_concern     : selectedConcerns.length > 0 ? selectedConcerns.join(",") : null,
                profile_image_url: profileImageUrl,
            });

            // 사이드바 프로필 이미지 갱신 알림
            window.dispatchEvent(new CustomEvent("profileUpdated"));

            setSaved(true);
            setTimeout(() => setSaved(false), 3000);
        } catch (err) {
            setSaveError(err instanceof Error ? err.message : "저장에 실패했습니다.");
        } finally {
            setIsSaving(false);
        }
    };

    // 문의 등록 관련 함수 260314 jsw
    const getInquiryStatus = (item: InquiryItem) => {
        return item.manager_id ? "답변완료" : "미답변";
    };

    // 페이지 번호 목록 생성
    const getPageNumbers = () => {
        const pages: (number | string)[] = [];

        if (totalPages <= 9) {
            for (let i = 1; i <= totalPages; i++) pages.push(i);
        } else {
            if (currentPage <= 5) {
                pages.push(1, 2, 3, 4, 5, "...", totalPages - 1, totalPages);
            } else if (currentPage >= totalPages - 4) {
                pages.push(1, 2, "...", totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages);
            } else {
                pages.push(1, "...", currentPage - 1, currentPage, currentPage + 1, "...", totalPages);
            }
        }

        return pages;
    };
    const handleInquirySubmit = async () => {
        if (!inquiryType || !inquiryTitle.trim() || !inquiryContent.trim()) return;

        try {
            setIsSubmittingInquiry(true);
            
            // TODO: 실제 API 연결
            const newInquiry: InquiryItem = {
                inquiry_id: Date.now(), // 임시 id
                user_id: 999,           // 실제로는 현재 로그인 유저 id
                title: inquiryTitle.trim(),
                category: inquiryType,
                author_name: name || "사용자",
                created_at: new Date().toISOString().slice(0, 10),
                content: inquiryContent.trim(),
                answer: null,
                manager_id: null,
            };

            setInquiries(prev => [newInquiry, ...prev]); // 등록 즉시 목록 반영
            setInquirySaved(true);
            setInquiryType("");
            setInquiryTitle("");
            setInquiryContent("");
            setShowInquiryForm(false); // 등록 후 폼 닫기
            setCurrentPage(1); // 새 문의 등록 후 첫 페이지로 이동
            setTimeout(() => setInquirySaved(false), 3000);
        } finally {
            setIsSubmittingInquiry(false);
        }
    };
    const handleSubmitAnswer = async (item: InquiryItem) => {
        const answerText = answerDrafts[item.inquiry_id]?.trim();

        if (!answerText) return;

        try {
            setIsSubmittingAnswer(true);

            console.log("답변 등록", {
                inquiry_id: item.inquiry_id,
                answer: answerText,
            });

            setInquiries(prev =>
                prev.map(i =>
                    i.inquiry_id === item.inquiry_id
                        ? {
                            ...i,
                            answer: answerText,
                            manager_id: 1, // 임시 관리자 id
                        }
                        : i
                )
            );

            setAnswerDrafts(prev => ({
                ...prev,
                [item.inquiry_id]: "",
            }));
        } finally {
            setIsSubmittingAnswer(false);
        }
    };
    return (
        <div className="h-full overflow-y-auto bg-[#F8FBF3]">
            <div className="max-w-5xl mx-auto px-4 py-6">
                {/* Header */}
                <div className="mb-6">
                    <h1 className="text-gray-900 font-bold">설정 · 마이페이지</h1>
                    <p className="text-sm text-gray-500 mt-0.5">계정 정보와 환경 설정을 관리하세요</p>
                </div>

                <div className="flex flex-col md:flex-row gap-5">
                    {/* Side Menu */}
                    <div className="md:w-52 flex-shrink-0">
                        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                            {sections.map((s, i) => {
                                const Icon = s.icon;
                                const isActive = activeSection === s.id;
                                const isDisabled = s.id === "security";

                                return (
                                    <button
                                        key={s.id}
                                        onClick={() => !isDisabled && setActiveSection(s.id)}
                                        disabled={isDisabled}
                                        className={`w-full flex items-center gap-3 px-4 py-3.5 text-sm font-medium transition-all duration-200 ${
                                            i < sections.length - 1 ? "border-b border-gray-50" : ""
                                        } ${isDisabled ? "opacity-35 cursor-not-allowed" : "cursor-pointer"} ${
                                            isActive ? "bg-[#E8F5D0] text-[#4A7A1E]" : "text-gray-600 hover:bg-gray-50"
                                        }`}
                                    >
                                        <Icon className="w-4 h-4 flex-shrink-0" />
                                        {s.label}
                                        {isActive && <ChevronRight className="w-3.5 h-3.5 ml-auto text-onyou" />}
                                    </button>
                                );
                            })}
                        </div>
                    </div>

                    <div className="flex-1 min-w-0">
                        {isLoadingUser ? (
                            <Loading />
                        ) : fetchError ? (
                            <div className="py-4 text-center text-sm text-red-500">{fetchError}</div>
                        ) : (
                            <AnimatePresence mode="wait">
                                {/* ── Profile ── */}
                                {activeSection === "profile" && (
                                    <motion.div
                                        key="profile"
                                        initial={{ opacity: 0, x: 10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -10 }}
                                        className="space-y-5 pb-24"
                                    >
                                        {/* Photo + read-only info */}
                                        <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                                            <h3 className="font-semibold text-gray-800 mb-4 text-sm">프로필</h3>
                                            <div className="flex items-start gap-1 mb-5">
                                                <div className="flex flex-col gap-1.5 items-center relative text-center">
                                                    {isUploadingPhoto ? (
                                                        <div className="w-16 h-16 rounded-2xl border-2 border-onyou flex items-center justify-center bg-gray-50">
                                                            <Loader2 className="w-5 h-5 animate-spin text-onyou" />
                                                        </div>
                                                    ) : (
                                                        <img
                                                            src={profileImageUrl ?? DefaultProfile}
                                                            alt="Profile"
                                                            className="w-20 h-20 rounded-2xl object-cover border-2 border-onyou"
                                                        />
                                                    )}
                                                    <input ref={profileInputRef} type="file" accept="image/*" className="hidden" onChange={handlePhotoChange} />
                                                    <button
                                                        onClick={() => profileInputRef.current?.click()}
                                                        disabled={isUploadingPhoto}
                                                        className="text-xs font-medium text-onyou cursor-pointer hover:underline disabled:opacity-50 block"
                                                    >
                                                        사진 변경
                                                    </button>
                                                </div>
                                                
                                                {/* Read-only */}
                                                <div className="flex flex-col gap-2.5 mt-3">
                                                    <div className="grid grid-cols-3 gap-3">
                                                        <label className="text-sm font-medium text-gray-500 text-right block">이름</label>
                                                        <p className="col-span-2 text-sm font-medium text-gray-600">{name}</p>
                                                    </div>
                                                    <div className="grid grid-cols-3 gap-3">
                                                        <label className="text-sm font-medium text-gray-500 text-right block">이메일</label>
                                                        <p className="col-span-2 text-sm font-medium text-gray-600">{email}</p>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Editable */}
                                            <div className="space-y-4">
                                                {/* Divider */}
                                                <div className="flex items-center gap-3 py-1">
                                                    <div className="flex-1 h-px bg-gray-100" />
                                                    <span className="text-xs text-gray-400 font-medium">기본 정보</span>
                                                    <div className="flex-1 h-px bg-gray-100" />
                                                </div>

                                                {/* nickname */}
                                                <Input
                                                    label="닉네임"
                                                    value={nickname}
                                                    onChange={(e) => setNickname(e.target.value)}
                                                    maxLength={12}
                                                    placeholder="닉네임 입력"
                                                />

                                                {/* Gender + Age */}
                                                <div className="grid grid-cols-2 gap-4">
                                                    <div>
                                                        <label className="text-xs font-medium text-gray-500 block mb-1.5">성별 <span className="text-red-400">*</span></label>
                                                        <select
                                                            value={gender}
                                                            onChange={(e) => { setGender(e.target.value); setFieldErrors((p) => ({ ...p, gender: undefined })); }}
                                                            className={`w-full px-4 py-3 bg-white border rounded-xl text-sm text-gray-800 cursor-pointer focus:outline-none transition-all appearance-none ${fieldErrors.gender ? "border-red-400 focus:border-red-400" : "border-gray-200 focus:border-onyou"}`}
                                                        >
                                                            <option value="" disabled>성별 선택</option>
                                                            <option>여성</option>
                                                            <option>남성</option>
                                                        </select>
                                                        {fieldErrors.gender && <p className="text-xs text-red-500 mt-1">{fieldErrors.gender}</p>}
                                                    </div>
                                                    <Input
                                                        label="나이"
                                                        required
                                                        type="number"
                                                        value={age}
                                                        onChange={(e) => {
                                                            const v = e.target.value;
                                                            if (v === "" || (Number(v) >= 1 && Number(v) <= 120)) setAge(v);
                                                            setFieldErrors((p) => ({ ...p, age: undefined }));
                                                        }}
                                                        min={1}
                                                        max={120}
                                                        placeholder="나이 입력"
                                                        error={fieldErrors.age}
                                                    />
                                                </div>

                                                {/* Divider */}
                                                <div className="flex items-center gap-3 mt-7 py-1">
                                                    <div className="flex-1 h-px bg-gray-100" />
                                                    <span className="text-xs text-gray-400 font-medium">피부 정보</span>
                                                    <div className="flex-1 h-px bg-gray-100" />
                                                </div>

                                                {/* Skin Type */}
                                                <div>
                                                    <label className={`text-xs font-medium block mb-2 ${fieldErrors.skinType ? "text-red-500" : "text-gray-500"}`}>
                                                        피부 타입 <span className="text-red-400">*</span>{fieldErrors.skinType && <span className="font-normal"> — {fieldErrors.skinType}</span>}
                                                    </label>
                                                    <div className="flex flex-wrap gap-2">
                                                        {skinTypeKeywords.map((k) => {
                                                            const label = k.label ?? k.keyword;

                                                            return (
                                                                <button
                                                                    key={k.keyword_id}
                                                                    onClick={() => { setSkinType(label); setFieldErrors((p) => ({ ...p, skinType: undefined })); }}
                                                                    className={`px-3 py-2 rounded-xl text-xs font-medium border-2 transition-all cursor-pointer ${
                                                                        skinType === label
                                                                            ? "text-white border-transparent bg-onyou"
                                                                            : fieldErrors.skinType
                                                                                ? "border-red-200 text-gray-600 hover:border-red-400"
                                                                                : "border-gray-200 text-gray-600 hover:border-onyou"
                                                                    }`}
                                                                >
                                                                    {label}
                                                                </button>
                                                            );
                                                        })}
                                                    </div>
                                                </div>

                                                {/* Skin Concerns */}
                                                <div>
                                                    <label className="text-xs font-medium text-gray-500 block mb-2">피부 고민</label>
                                                    <div className="flex flex-wrap gap-2">
                                                        {allConcerns.map((c) => {
                                                            const selected = selectedConcerns.includes(c);
                                                            const isCustom = customConcerns.includes(c);

                                                            return (
                                                                <button
                                                                    key={c}
                                                                    onClick={() => toggleConcern(c)}
                                                                    className={`px-3 py-1.5 rounded-xl text-xs font-medium border-2 transition-all flex items-center gap-1.5 cursor-pointer ${
                                                                        selected
                                                                            ? "border-transparent text-white bg-onyou"
                                                                            : "border-gray-200 text-gray-600 hover:border-onyou"
                                                                    }`}
                                                                >
                                                                    {selected && <Check className="w-3 h-3 flex-shrink-0" />}
                                                                    {c}
                                                                    {isCustom && (
                                                                        <span className="ml-0.5" onClick={(e) => { e.stopPropagation(); removeConcern(c); }}>
                                                                            <X className="w-3 h-3" />
                                                                        </span>
                                                                    )}
                                                                </button>
                                                            );
                                                        })}

                                                        {/* '+' button */}
                                                        {!showAddConcern && (
                                                            <button
                                                                onClick={() => setShowAddConcern(true)}
                                                                className="px-3 py-1.5 rounded-xl text-xs font-medium border-2 border-dashed border-gray-300 text-gray-400 cursor-pointer hover:border-onyou hover:text-onyou transition-all flex items-center gap-1"
                                                            >
                                                                <Plus className="w-3.5 h-3.5" />
                                                                추가
                                                            </button>
                                                        )}
                                                    </div>

                                                    {/* Custom concern input */}
                                                    <AnimatePresence>
                                                        {showAddConcern && (
                                                            <motion.div
                                                                initial={{ opacity: 0, height: 0 }}
                                                                animate={{ opacity: 1, height: "auto" }}
                                                                exit={{ opacity: 0, height: 0 }}
                                                                className="mt-2 flex gap-2"
                                                            >
                                                                <input
                                                                    autoFocus
                                                                    value={newConcernInput}
                                                                    onChange={(e) => setNewConcernInput(e.target.value)}
                                                                    onKeyDown={(e) => {
                                                                        if (e.key === "Enter") addCustomConcern();
                                                                        if (e.key === "Escape") { setShowAddConcern(false); setNewConcernInput(""); }
                                                                    }}
                                                                    placeholder="피부 고민 직접 입력"
                                                                    maxLength={12}
                                                                    className="flex-1 px-3 py-2 bg-white border border-gray-200 rounded-xl text-xs text-gray-800 placeholder-gray-400 focus:outline-none focus:border-onyou transition-all"
                                                                />
                                                                <button
                                                                    onClick={addCustomConcern}
                                                                    disabled={!newConcernInput.trim()}
                                                                    className="px-3 py-2 rounded-xl text-xs font-semibold text-white disabled:opacity-50 transition-all bg-onyou"
                                                                >
                                                                    추가
                                                                </button>
                                                                <button
                                                                    onClick={() => { setShowAddConcern(false); setNewConcernInput(""); }}
                                                                    className="px-3 py-2 rounded-xl text-xs font-medium bg-gray-100 text-gray-500 hover:bg-gray-200 transition-all"
                                                                >
                                                                    취소
                                                                </button>
                                                            </motion.div>
                                                        )}
                                                    </AnimatePresence>
                                                </div>
                                            </div>
                                        </div>

                                        {/* Save Button - fixed bottom */}
                                        <div className="fixed bottom-0 left-0 right-0 lg:left-[260px] bg-white border-t border-gray-100 px-4 py-4 z-20">
                                            <div className="max-w-4xl mx-auto space-y-2">
                                                {saveError && (
                                                    <p className="text-xs text-red-500 text-center">{saveError}</p>
                                                )}
                                                <Button
                                                    onClick={handleSave}
                                                    disabled={isUploadingPhoto}
                                                    isLoading={isSaving}
                                                    loadingText="저장 중..."
                                                    className="rounded-2xl"
                                                >
                                                    {saved ? <><Check className="w-4 h-4" />저장되었습니다!</> : "변경사항 저장"}
                                                </Button>
                                            </div>
                                        </div>
                                    </motion.div>
                                )}

                                {/* ── Security ── */}
                                {activeSection === "security" && (
                                    <motion.div
                                        key="security"
                                        initial={{ opacity: 0, x: 10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -10 }}
                                    >
                                        <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                                            <h3 className="font-semibold text-gray-800 mb-4 text-sm">비밀번호 변경</h3>
                                            <div className="space-y-3">
                                                <Input
                                                    label="현재 비밀번호"
                                                    type="password"
                                                    value={currentPw}
                                                    onChange={(e) => setCurrentPw(e.target.value)}
                                                    placeholder="현재 비밀번호"
                                                />
                                                <Input
                                                    label="새 비밀번호"
                                                    type="password"
                                                    value={newPw}
                                                    onChange={(e) => setNewPw(e.target.value)}
                                                    placeholder="새 비밀번호 (8자 이상, 영문+숫자)"
                                                />
                                                <Input
                                                    label="비밀번호 확인"
                                                    type="password"
                                                    value={confirmPw}
                                                    onChange={(e) => setConfirmPw(e.target.value)}
                                                    placeholder="새 비밀번호를 다시 입력하세요"
                                                    error={confirmPw.length > 0 && !pwMatch ? "비밀번호가 일치하지 않습니다" : undefined}
                                                />
                                            </div>
                                            <Button disabled={!currentPw || !newPw || !pwMatch} className="mt-4">
                                                비밀번호 변경
                                            </Button>
                                        </div>
                                    </motion.div>
                                )}

                                {/* ── Social ── */}
                                {activeSection === "social" && (
                                    <motion.div
                                        key="social"
                                        initial={{ opacity: 0, x: 10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        exit={{ opacity: 0, x: -10 }}
                                    >
                                        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                                            <div className="px-5 py-4 border-b border-gray-50">
                                                <h3 className="font-semibold text-gray-800 text-sm">소셜 계정 연동</h3>
                                                <p className="text-xs text-gray-400 mt-0.5">연결된 소셜 계정으로 간편 로그인이 가능합니다</p>
                                            </div>
                                            {isLoadingSocials ? (
                                                <div className="flex items-center justify-center py-10">
                                                    <Loader2 className="w-5 h-5 animate-spin text-onyou" />
                                                </div>
                                            ) : (
                                                [
                                                    {
                                                        id: "google", name: "Google",
                                                        icon: (
                                                            <svg className="w-5 h-5" viewBox="0 0 24 24">
                                                                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                                                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                                                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                                                                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                                                            </svg>
                                                        ),
                                                        bg: "#F3F4F6",
                                                    },
                                                    // {
                                                    //   id: "kakao", name: "카카오",
                                                    //   icon: <svg className="w-5 h-5" viewBox="0 0 24 24" fill="#3C1E1E"><path d="M12 3C7.03 3 3 6.32 3 10.4c0 2.62 1.74 4.92 4.35 6.23l-.9 3.37 3.91-2.57C11.07 17.49 11.53 17.5 12 17.5c4.97 0 9-3.32 9-7.4S16.97 3 12 3z"/></svg>,
                                                    //   bg: "#FEE500",
                                                    // },
                                                    {
                                                        id: "naver", name: "네이버",
                                                        icon: <span className="text-white font-black text-base">N</span>,
                                                        bg: "#03C75A",
                                                    },
                                                ].map((social) => {
                                                    const connected = connectedProviders.includes(social.id);
                                                    return (
                                                        <div key={social.id} className="flex items-center px-5 py-4 border-b border-gray-50 last:border-0">
                                                            <div className="flex items-center gap-3">
                                                                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: social.bg }}>
                                                                    {social.icon}
                                                                </div>
                                                                <div>
                                                                    <p className="text-sm font-medium text-gray-800">{social.name}</p>
                                                                    <p className={`text-xs font-medium mt-0.5 ${connected ? "text-onyou" : "text-gray-400"}`}>
                                                                        {connected ? "연결됨" : "연결되지 않음"}
                                                                    </p>
                                                                </div>
                                                            </div>
                                                            {connected && (
                                                                <Check className="w-4 h-4 ml-auto text-onyou" />
                                                            )}
                                                        </div>
                                                    );
                                                })
                                            )}
                                        </div>
                                    </motion.div>
                                )}

                            {/* ── QnA ── */}
                            {activeSection === "qna" && (
                                <motion.div
                                    key="qna"
                                    initial={{ opacity: 0, x: 10 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -10 }}
                                    className="space-y-5"
                                >
                                    {/* 문의 목록 */}
                                    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                                        <div className="px-5 py-4 border-b border-gray-50 flex items-start justify-between gap-3">
                                            <div>
                                                <h3 className="font-semibold text-gray-800 text-sm">문의 목록</h3>
                                                <p className="text-xs text-gray-400 mt-0.5">
                                                    제목을 클릭하면 문의 내용을 확인할 수 있습니다
                                                </p>
                                            </div>

                                            {!effectiveIsAdmin && (
                                                <button
                                                    type="button"
                                                    onClick={() => setShowInquiryForm(true)}
                                                    className="px-4 h-9 text-sm rounded-lg whitespace-nowrap bg-onyou text-white hover:opacity-90 transition"
                                                >
                                                    문의하기
                                                </button>
                                            )}
                                        </div>

                                        {isLoadingInquiries ? (
                                            <div className="flex items-center justify-center py-12">
                                                <Loader2 className="w-5 h-5 animate-spin text-onyou" />
                                            </div>
                                        ) : inquiries.length === 0 ? (
                                            <div className="py-12 text-center text-sm text-gray-400">
                                                등록된 문의가 없습니다.
                                            </div>
                                        ) : (
                                            <div className="p-4 space-y-3">
                                                {paginatedInquiries.map((item, index) => {
                                                    const isOpen = openInquiryId === item.inquiry_id;
                                                    const statusText = getInquiryStatus(item);

                                                    return (
                                                        <div key={item.inquiry_id} className="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
                                                            {/* 목록 row */}
                                                            <button
                                                                onClick={() => toggleInquiry(item.inquiry_id)}
                                                                className="w-full px-4 py-4 hover:bg-[#FAFCF7] transition-colors"
                                                            >
                                                                <div className="flex items-center gap-3 text-left">
                                                                    <span className="w-8 text-sm text-gray-400 flex-shrink-0">
                                                                        {(currentPage - 1) * itemsPerPage + index + 1}
                                                                    </span>

                                                                    <div className="flex-1 min-w-0">
                                                                        <div className="flex items-center gap-2 mb-1">
                                                                            <span className="truncate text-sm font-semibold text-gray-800">
                                                                                {item.title}
                                                                            </span>

                                                                            <span
                                                                                className={`inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-medium flex-shrink-0 ${
                                                                                    item.manager_id
                                                                                        ? "bg-green-50 text-green-600"
                                                                                        : "bg-yellow-50 text-yellow-600"
                                                                                }`}
                                                                            >
                                                                                {statusText}
                                                                            </span>
                                                                        </div>

                                                                        <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-gray-400">
                                                                            <span>{item.category}</span>
                                                                            <span>{item.author_name}</span>
                                                                            <span>{item.created_at}</span>
                                                                        </div>
                                                                    </div>

                                                                    <ChevronRight
                                                                        className={`w-4 h-4 text-gray-400 transition-transform flex-shrink-0 ${
                                                                            isOpen ? "rotate-90" : ""
                                                                        }`}
                                                                    />
                                                                </div>
                                                            </button>

                                                            {/* 아코디언 상세 */}
                                                            <AnimatePresence initial={false}>
                                                                {isOpen && (
                                                                    <motion.div
                                                                        initial={{ height: 0, opacity: 0 }}
                                                                        animate={{ height: "auto", opacity: 1 }}
                                                                        exit={{ height: 0, opacity: 0 }}
                                                                        transition={{ duration: 0.2 }}
                                                                        className="overflow-hidden bg-[#FAFCF7]"
                                                                    >
                                                                        <div className="px-5 pb-5">
                                                                            <div className="grid gap-4 pt-1">
                                                                                {/* 문의 내용 카드 */}
                                                                                <div className="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
                                                                                    <div className="flex items-center justify-between mb-2">
                                                                                        <p className="text-xs font-semibold text-gray-500">문의 내용</p>
                                                                                        <span className="text-[11px] text-gray-400">
                                                                                            {item.created_at}
                                                                                        </span>
                                                                                    </div>
                                                                                    <div className="text-sm leading-6 text-gray-700 whitespace-pre-wrap">
                                                                                        {item.content || "문의 내용이 없습니다."}
                                                                                    </div>
                                                                                </div>

                                                                                {/* 답변 카드 */}
                                                                                <div className="rounded-2xl border border-gray-100 bg-white p-4 shadow-sm">
                                                                                    <div className="flex items-center justify-between mb-2">
                                                                                        <p className="text-xs font-semibold text-gray-500">답변</p>
                                                                                        <span
                                                                                            className={`inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-medium ${
                                                                                                item.manager_id
                                                                                                    ? "bg-green-50 text-green-600"
                                                                                                    : "bg-gray-100 text-gray-500"
                                                                                            }`}
                                                                                        >
                                                                                            {item.manager_id ? "답변완료" : "답변대기"}
                                                                                        </span>
                                                                                    </div>

                                                                                    {item.answer ? (
                                                                                        <div className="rounded-xl border border-green-100 bg-green-50 px-4 py-3 text-sm leading-6 text-gray-700 whitespace-pre-wrap">
                                                                                            {item.answer}
                                                                                        </div>
                                                                                    ) : (
                                                                                        <div className="rounded-xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm text-gray-500">
                                                                                            아직 답변이 등록되지 않았습니다.
                                                                                        </div>
                                                                                    )}
                                                                                </div>

                                                                                {/* 관리자 답변 작성 */}
                                                                                {effectiveIsAdmin && !item.manager_id && (
                                                                                    <div className="rounded-2xl border border-onyou/20 bg-white p-4 shadow-sm">
                                                                                        <p className="text-xs font-semibold text-gray-500 mb-3">관리자 답변 작성</p>

                                                                                        <textarea
                                                                                            value={answerDrafts[item.inquiry_id] ?? ""}
                                                                                            onChange={(e) =>
                                                                                                setAnswerDrafts(prev => ({
                                                                                                    ...prev,
                                                                                                    [item.inquiry_id]: e.target.value,
                                                                                                }))
                                                                                            }
                                                                                            rows={5}
                                                                                            placeholder="문의에 대한 답변을 입력하세요"
                                                                                            className="w-full px-4 py-3 border border-gray-200 rounded-2xl text-sm text-gray-700 placeholder-gray-400 focus:outline-none focus:border-onyou resize-none"
                                                                                        />

                                                                                        <div className="mt-3 flex justify-end">
                                                                                            <Button
                                                                                                onClick={() => handleSubmitAnswer(item)}
                                                                                                disabled={!((answerDrafts[item.inquiry_id] ?? "").trim())}
                                                                                                isLoading={isSubmittingAnswer}
                                                                                                loadingText="등록 중..."
                                                                                                className="rounded-xl"
                                                                                            >
                                                                                                답변 등록
                                                                                            </Button>
                                                                                        </div>
                                                                                    </div>
                                                                                )}
                                                                            </div>
                                                                        </div>
                                                                    </motion.div>
                                                                )}
                                                            </AnimatePresence>
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                        )}
                                    </div>

                                   {/* 페이지네이션 */}
                                    {totalPages > 1 && (
                                        <div className="flex justify-center items-center gap-1.5 pt-1 flex-wrap">
                                            <button
                                                type="button"
                                                disabled={currentPage === 1}
                                                onClick={() => setCurrentPage(prev => prev - 1)}
                                                className="w-9 h-9 rounded-lg border border-gray-200 bg-white text-gray-500 flex items-center justify-center disabled:opacity-40 disabled:cursor-not-allowed hover:border-onyou hover:text-onyou transition-colors"
                                            >
                                                {"<"}
                                            </button>

                                            {getPageNumbers().map((page, idx) =>
                                                page === "..." ? (
                                                    <span
                                                        key={`ellipsis-${idx}`}
                                                        className="w-9 h-9 flex items-center justify-center text-sm text-gray-400"
                                                    >
                                                        ...
                                                    </span>
                                                ) : (
                                                    <button
                                                        key={page}
                                                        type="button"
                                                        onClick={() => setCurrentPage(Number(page))}
                                                        className={`w-9 h-9 rounded-lg text-sm font-medium flex items-center justify-center transition-colors ${
                                                            currentPage === page
                                                                ? "bg-onyou text-white"
                                                                : "bg-white border border-gray-200 text-gray-600 hover:border-onyou hover:text-onyou"
                                                        }`}
                                                    >
                                                        {page}
                                                    </button>
                                                )
                                            )}

                                            <button
                                                type="button"
                                                disabled={currentPage === totalPages}
                                                onClick={() => setCurrentPage(prev => prev + 1)}
                                                className="w-9 h-9 rounded-lg border border-gray-200 bg-white text-gray-500 flex items-center justify-center disabled:opacity-40 disabled:cursor-not-allowed hover:border-onyou hover:text-onyou transition-colors"
                                            >
                                                {">"}
                                            </button>
                                        </div>
                                    )}

                                    {/* 일반 사용자 문의 작성 */}
                                    {!effectiveIsAdmin && showInquiryForm && (
                                        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
                                            <div className="w-full max-w-2xl rounded-2xl bg-white shadow-xl border border-gray-100 overflow-hidden">
                                                {/* 모달 헤더 */}
                                                <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
                                                    <div>
                                                        <h3 className="font-semibold text-gray-800 text-base">문의 작성</h3>
                                                        <p className="text-xs text-gray-400 mt-1">
                                                            궁금한 내용을 남겨주시면 확인 후 답변드릴게요
                                                        </p>
                                                    </div>

                                                    <button
                                                        type="button"
                                                        onClick={() => setShowInquiryForm(false)}
                                                        className="w-9 h-9 rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition"
                                                    >
                                                        ✕
                                                    </button>
                                                </div>

                                                {/* 모달 본문 */}
                                                <div className="p-5 space-y-4">
                                                    <select
                                                        value={inquiryType}
                                                        onChange={(e) => setInquiryType(e.target.value)}
                                                        className="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-onyou"
                                                    >
                                                        <option value="">문의 분류 선택</option>
                                                        <option value="계정 문의">계정 문의</option>
                                                        <option value="결제 문의">결제 문의</option>
                                                        <option value="오류 제보">오류 제보</option>
                                                        <option value="서비스 문의">서비스 문의</option>
                                                        <option value="기타">기타</option>
                                                    </select>

                                                    <Input
                                                        label="문의 제목"
                                                        value={inquiryTitle}
                                                        onChange={(e) => setInquiryTitle(e.target.value)}
                                                        placeholder="문의 제목을 입력하세요"
                                                    />

                                                    <textarea
                                                        value={inquiryContent}
                                                        onChange={(e) => setInquiryContent(e.target.value)}
                                                        rows={7}
                                                        placeholder="문의 내용을 입력하세요"
                                                        className="w-full px-4 py-3 border border-gray-200 rounded-2xl text-sm text-gray-700 placeholder-gray-400 focus:outline-none focus:border-onyou resize-none"
                                                    />

                                                    {inquirySaved && (
                                                        <p className="text-sm text-green-600">문의가 등록되었습니다.</p>
                                                    )}
                                                </div>

                                                {/* 모달 하단 버튼 */}
                                                <div className="flex justify-end gap-2 px-5 py-4 border-t border-gray-100 bg-gray-50">
                                                    <button
                                                        type="button"
                                                        onClick={() => setShowInquiryForm(false)}
                                                        className="px-4 h-10 rounded-xl bg-gray-100 text-gray-600 border border-gray-300 hover:bg-gray-200 hover:text-gray-700 transition"
                                                    >
                                                        취소
                                                    </button>

                                                    <button
                                                        type="button"
                                                        onClick={handleInquirySubmit}
                                                        disabled={!inquiryType || !inquiryTitle.trim() || !inquiryContent.trim() || isSubmittingInquiry}
                                                        className="px-4 h-10 rounded-xl bg-onyou text-white hover:opacity-90 transition disabled:opacity-50 disabled:cursor-not-allowed"
                                                    >
                                                        {isSubmittingInquiry ? "등록 중..." : "문의 등록"}
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    )}
                                </motion.div>
                            )}
                            </AnimatePresence>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
