export function TermsPage() {
    return (
        <div className="min-h-screen bg-[#F8FBF3] px-4 py-10">
            <div className="mx-auto max-w-4xl rounded-2xl bg-white p-6 shadow-sm md:p-8">
                <h1 className="text-2xl font-bold text-gray-900 md:text-3xl">
                    서비스 이용약관
                </h1>
                <p className="mt-2 text-sm text-gray-500">
                    시행일: 2026.03.18.
                </p>

                <div className="mt-8 space-y-8 text-sm leading-7 text-gray-700 md:text-base">
                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제1조(목적)</h2>
                        <p>
                            이 약관은 온유(On_You) 운영팀(이하 &quot;운영팀&quot;)이 제공하는 AI 기반
                            피부 분석, 퍼스널컬러 분석, 화장품 성분 분석, 챗봇 상담, 제품 추천,
                            피부 이력 저장 및 비교, 위시리스트 등 관련 서비스의 이용과 관련하여
                            운영팀과 이용자 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제2조(정의)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>
                                &quot;서비스&quot;란 운영팀이 웹사이트를 통해 제공하는 AI 피부 분석,
                                퍼스널컬러 분석, 성분 분석, 챗봇 상담, 제품 추천, 위시리스트,
                                분석 이력 저장 및 비교 등 제반 기능을 의미합니다.
                            </li>
                            <li>
                                &quot;이용자&quot;란 본 약관에 따라 운영팀이 제공하는 서비스를 이용하는
                                회원 및 비회원을 말합니다.
                            </li>
                            <li>
                                &quot;회원&quot;이란 운영팀에 개인정보를 제공하여 회원등록을 한 사람으로,
                                지속적으로 서비스를 이용할 수 있는 자를 의미합니다.
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제3조(약관의 게시와 개정)</h2>
                        <p>
                            운영팀은 본 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 초기 화면
                            또는 연결 화면에 게시합니다. 운영팀은 관련 법령을 위반하지 않는 범위에서
                            본 약관을 개정할 수 있으며, 개정 시 시행일과 개정 사유를 함께 공지합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제4조(회원가입 및 이용계약의 성립)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>이용계약은 이용자의 회원가입 신청과 운영팀의 승낙으로 성립합니다.</li>
                            <li>
                                이용자는 회원가입 시 사실에 근거한 정보를 입력해야 하며, 허위 정보 또는
                                타인 정보를 이용한 가입은 제한될 수 있습니다.
                            </li>
                            <li>
                                운영팀은 기술상 또는 운영상 문제가 있는 경우 승낙을 유보하거나 거절할 수 있습니다.
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제5조(회원정보의 변경)</h2>
                        <p>
                            회원은 회원정보에 변경이 있는 경우 지체 없이 이를 수정해야 하며,
                            변경사항을 수정하지 않아 발생하는 불이익에 대한 책임은 회원 본인에게 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제6조(계정 및 비밀번호 관리)</h2>
                        <p>
                            계정과 비밀번호 관리 책임은 회원 본인에게 있습니다. 이를 제3자에게 양도,
                            대여하거나 부정하게 사용해서는 안 되며, 관리 소홀로 인해 발생한 손해에 대한
                            책임은 회원에게 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제7조(서비스의 제공)</h2>
                        <p className="mb-3">
                            운영팀이 제공하는 서비스의 주요 내용은 다음과 같습니다.
                        </p>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>AI 기반 피부 상태 분석 서비스(빠른 분석 / 정밀 분석)</li>
                            <li>AI 기반 퍼스널컬러 분석 서비스</li>
                            <li>화장품 전성분 OCR 추출 및 성분 분석 서비스</li>
                            <li>AI 챗봇 기반 피부 상담 서비스</li>
                            <li>올리브영 실상품 기반 제품 추천 서비스</li>
                            <li>피부 분석 이력 저장 및 비교 서비스</li>
                            <li>위시리스트(관심 제품 저장) 서비스</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제8조(서비스 이용시간 및 변경)</h2>
                        <p>
                            서비스는 특별한 사정이 없는 한 연중무휴, 1일 24시간 제공을 원칙으로 합니다.
                            다만 시스템 점검, 유지보수, 장애 대응, 외부 연동 서비스 이슈 등으로 인해
                            서비스의 전부 또는 일부가 일시 중단될 수 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제9조(AI 분석 서비스의 한계 및 의료 면책)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>
                                본 서비스의 피부 분석, 퍼스널컬러 분석, 성분 분석, 제품 추천 결과는
                                참고용 정보이며 의료행위에 해당하지 않습니다.
                            </li>
                            <li>
                                분석 결과는 딥러닝 모델 또는 대규모 언어 모델에 의해 자동 산출되며,
                                정확성·완전성·신뢰성을 보장하지 않습니다.
                            </li>
                            <li>
                                촬영 환경(조명, 각도, 해상도 등)에 따라 결과가 달라질 수 있습니다.
                            </li>
                            <li>
                                이용자는 분석 결과만을 근거로 의료적 판단을 내려서는 안 되며,
                                피부 질환이 의심되는 경우 반드시 전문의와 상담해야 합니다.
                            </li>
                            <li>
                                운영팀은 분석 결과 또는 추천 정보에 따라 이용자가 행한 선택으로 인해
                                발생한 피부 트러블, 알레르기, 기타 손해에 대해 책임을 부담하지 않습니다.
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제10조(얼굴 사진 및 이미지 업로드 관련 특칙)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>
                                이용자는 본인 또는 적법한 권한을 가진 이미지에 한해 업로드해야 합니다.
                            </li>
                            <li>
                                타인의 얼굴 사진, 저작권 또는 초상권을 침해할 수 있는 이미지를 무단 업로드해서는 안 됩니다.
                            </li>
                            <li>
                                운영팀은 서비스 제공을 위해 업로드된 이미지를 분석 처리할 수 있습니다.
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제11조(이용자의 의무)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>허위 정보 입력, 타인 정보 도용, 부정 사용을 해서는 안 됩니다.</li>
                            <li>관련 법령, 본 약관, 운영정책, 공지사항을 준수해야 합니다.</li>
                            <li>서비스를 비정상적으로 이용하거나 운영을 방해하는 행위를 해서는 안 됩니다.</li>
                            <li>계정 보안 및 회원정보 최신성 유지 의무는 이용자에게 있습니다.</li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제12조(서비스 이용의 제한)</h2>
                        <p>
                            운영팀은 이용자가 본 약관 또는 관련 법령을 위반하는 경우, 사안의 경중에 따라
                            서비스 이용 제한, 게시물 삭제, 계정 이용 정지 또는 계약 해지 조치를 취할 수 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제13조(개인정보보호)</h2>
                        <p>
                            운영팀은 관련 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력하며,
                            개인정보의 수집·이용·보관·파기 등에 관한 사항은 별도의 개인정보처리방침에 따릅니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제14조(자동화된 결정에 대한 안내)</h2>
                        <p>
                            본 서비스의 일부 결과는 자동화된 시스템에 의해 생성될 수 있습니다. 이용자는
                            이러한 자동화된 결과에 대해 설명을 요구하거나 문의할 수 있습니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제15조(면책사항)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>천재지변 또는 이에 준하는 불가항력으로 인한 서비스 장애</li>
                            <li>이용자의 귀책사유로 인한 서비스 이용 장애</li>
                            <li>이용자가 서비스를 통해 얻은 자료의 활용으로 인한 손해</li>
                            <li>
                                AI 피부 분석 및 퍼스널컬러 분석 결과의 오류, 부정확, 불완전으로 인해
                                발생한 손해
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제16조(권리의 귀속)</h2>
                        <ul className="list-disc space-y-2 pl-6">
                            <li>
                                운영팀이 제공하는 서비스 및 관련 저작물에 대한 지식재산권은 운영팀에 귀속됩니다.
                            </li>
                            <li>
                                이용자가 직접 작성하거나 업로드한 콘텐츠 및 이미지의 권리는 해당 이용자에게 귀속됩니다.
                            </li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제17조(계약 해지 및 탈퇴)</h2>
                        <p>
                            이용자는 언제든지 서비스 내 회원탈퇴 기능을 통해 이용계약 해지를 요청할 수 있습니다.
                            운영팀은 관련 법령 및 개인정보처리방침에 따라 필요한 정보를 보관한 뒤 파기합니다.
                        </p>
                    </section>

                    <section>
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">제18조(준거법 및 관할법원)</h2>
                        <p>
                            본 약관은 대한민국 법령에 따라 해석되며, 서비스와 관련하여 분쟁이 발생하는 경우
                            민사소송법상 관할법원을 전속적 합의관할로 합니다.
                        </p>
                    </section>

                    <section className="border-t border-gray-200 pt-6">
                        <h2 className="mb-3 text-lg font-semibold text-gray-900">부칙</h2>
                        <p>본 약관은 2026년 3월 18일부터 시행됩니다.</p>
                    </section>
                </div>
            </div>
        </div>
    );
}