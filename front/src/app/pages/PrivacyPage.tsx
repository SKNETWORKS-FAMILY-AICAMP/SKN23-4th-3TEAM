export function PrivacyPage() {
    return (
        <div className="min-h-screen bg-[#F8FBF3] px-4 py-10">
            <div className="mx-auto max-w-4xl rounded-2xl bg-white p-6 shadow-sm md:p-8">
                <h1 className="text-2xl font-bold text-gray-900 md:text-3xl">
                    개인정보처리방침
                </h1>
                <p className="mt-2 text-sm text-gray-500">
                    시행일: 2026.03.18.
                </p>

                <div className="mt-8 space-y-8 text-sm leading-7 text-gray-700 md:text-base">
                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제1조(목적)</h2>
                        <p>
                            온유(On_You) 운영팀(이하 &quot;운영팀&quot;)은 이용자의 개인정보를 보호하고
                            관련 법령을 준수하기 위하여 본 개인정보처리방침을 수립합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제2조(수집하는 개인정보 항목)</h2>
                        <p className="mb-3">운영팀은 다음과 같은 개인정보를 수집할 수 있습니다.</p>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>회원가입 정보: 이메일, 비밀번호, 닉네임</li>
                            <li>소셜로그인 연동 정보: Google, Kakao, Naver OAuth 식별 정보</li>
                            <li>서비스 이용 중 생성 정보: 피부 분석 결과, 퍼스널컬러 결과, 채팅 내용, 위시리스트</li>
                            <li>업로드 정보: 얼굴 사진, 피부 사진, 화장품 성분표 이미지, OCR 추출 텍스트</li>
                            <li>접속 및 이용기록: 접속 로그, 쿠키, 이용 이력 등</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제3조(개인정보 수집 방법)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>회원가입 및 로그인 과정</li>
                            <li>소셜로그인 연동 과정</li>
                            <li>이미지 업로드 및 분석 기능 이용 과정</li>
                            <li>챗봇, 위시리스트, 분석 저장 기능 이용 과정</li>
                            <li>쿠키 및 로그 분석 도구를 통한 자동 수집</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제4조(개인정보의 이용 목적)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>회원 식별 및 로그인 서비스 제공</li>
                            <li>피부 분석, 퍼스널컬러 분석, 성분 분석 결과 제공</li>
                            <li>챗봇 상담, 추천, 위시리스트, 분석 이력 저장 및 비교 기능 제공</li>
                            <li>서비스 개선, 오류 대응, 고객 문의 처리</li>
                            <li>보안, 부정 이용 방지, 통계 분석</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제5조(개인정보의 보유 및 이용기간)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>회원정보: 회원 탈퇴 시까지</li>
                            <li>분석 결과 및 위시리스트: 회원 탈퇴 시까지 또는 서비스 목적 달성 시까지</li>
                            <li>관련 법령에 따라 보존이 필요한 경우 해당 기간 동안 별도 보관</li>
                        </ul>
                        <p className="mt-3">
                            단, 관계 법령에 따라 일정 기간 보관이 필요한 경우에는 해당 법령에 따릅니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제6조(개인정보의 제3자 제공)</h2>
                        <p>
                            운영팀은 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 다만,
                            이용자의 동의가 있거나 법령에 특별한 규정이 있는 경우에는 예외로 합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제7조(개인정보 처리의 위탁)</h2>
                        <p className="mb-3">
                            운영팀은 원활한 서비스 제공을 위해 다음과 같이 개인정보 처리 업무의 일부를 위탁하거나
                            외부 서비스를 이용할 수 있습니다.
                        </p>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>AWS: 이미지 저장, 서버 및 인프라 운영</li>
                            <li>OpenAI: 일부 AI 분석 및 자연어 처리 기능 제공</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제8조(개인정보의 국외 이전)</h2>
                        <p>
                            운영팀은 AI 기능 제공을 위해 일부 데이터를 국외 서버를 통해 처리할 수 있습니다.
                            이 경우 관련 법령이 요구하는 보호조치를 이행합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제9조(개인정보의 파기)</h2>
                        <p className="mb-3">
                            개인정보 보유기간의 경과, 처리 목적 달성 등 개인정보가 불필요하게 되었을 때에는
                            지체 없이 해당 개인정보를 파기합니다.
                        </p>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>전자적 파일: 복구 불가능한 방식으로 삭제</li>
                            <li>S3 저장 이미지: 객체 삭제</li>
                            <li>DB 저장 정보: 해당 레코드 삭제</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제10조(이용자의 권리와 행사 방법)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>이용자는 자신의 개인정보 조회, 수정, 삭제를 요청할 수 있습니다.</li>
                            <li>개인정보 수집 및 이용 동의를 철회할 수 있습니다.</li>
                            <li>회원탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.</li>
                            <li>정정 또는 삭제 요청 시 운영팀은 지체 없이 필요한 조치를 합니다.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제11조(아동의 개인정보보호)</h2>
                        <p>
                            운영팀은 만 14세 미만 아동의 개인정보 보호를 위해 만 14세 이상의 이용자에 한하여
                            회원가입을 허용합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제12조(개인정보의 안전성 확보조치)</h2>
                        <p>
                            운영팀은 개인정보의 분실, 도난, 유출, 변조 또는 훼손을 방지하기 위해
                            기술적·관리적 보호조치를 시행합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제13조(개인정보 자동 수집 장치의 설치·운영 및 거부)</h2>
                        <p className="mb-3">
                            운영팀은 맞춤형 서비스 제공을 위해 쿠키를 사용할 수 있습니다.
                            이용자는 웹브라우저 설정을 통해 쿠키 저장을 거부할 수 있습니다.
                        </p>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>Edge: 설정 &gt; 쿠키 및 사이트 권한</li>
                            <li>Chrome: 설정 &gt; 개인정보 및 보안 &gt; 쿠키 및 기타 사이트 데이터</li>
                            <li>Whale: 설정 &gt; 개인정보 보호 &gt; 쿠키 및 기타 사이트 데이터</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제14조(자동화된 결정에 대한 안내)</h2>
                        <p>
                            본 서비스는 AI를 활용하여 피부 상태, 퍼스널컬러, 성분 분석 및 추천 정보를 자동 생성할 수 있습니다.
                            이용자는 자동화된 결과에 대해 설명을 요구하거나 문의할 수 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제15조(개인정보 보호책임자)</h2>
                        <div className="rounded-xl bg-gray-50 p-4">
                            <p>성명: 강승원</p>
                            <p>직책: 프로젝트 팀장 (개인정보 보호책임자)</p>
                            <p>전화번호: 010-4782-4452</p>
                            <p>이메일: seungwon987@gmail.com</p>
                        </div>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제16조(권익침해 구제방법)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>개인정보분쟁조정위원회: 1833-6972</li>
                            <li>개인정보침해신고센터: 118</li>
                            <li>대검찰청: 1301</li>
                            <li>경찰청: 182</li>
                        </ul>
                    </section>

                    <section className="border-t border-gray-200 pt-6">
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">부칙</h2>
                        <p>본 방침은 2026년 3월 18일부터 시행됩니다.</p>
                    </section>
                </div>
            </div>
        </div>
    );
}