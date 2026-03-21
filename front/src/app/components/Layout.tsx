import { useState } from "react";
import { Menu } from "lucide-react";
import { Sidebar } from "./Sidebar";
import { Outlet, Link } from "react-router";

export function Layout() {
    const [sidebarOpen, setSidebarOpen] = useState(false);

    return (
        <div className="flex h-screen bg-[#F8FBF3] overflow-hidden">
            <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

            <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
                <header className="lg:hidden flex items-center justify-between px-4 py-3 bg-white border-b border-gray-100 flex-shrink-0">
                    <button
                        onClick={() => setSidebarOpen(true)}
                        className="p-2 rounded-lg hover:bg-gray-100 transition-colors cursor-pointer"
                        aria-label="메뉴 열기"
                    >
                        <Menu className="w-5 h-5 text-gray-600" />
                    </button>
                    <div className="w-9" />
                </header>

                <div className="flex-1 flex flex-col min-h-0">
                    <main className="flex-1 overflow-auto">
                        <Outlet />
                    </main>

                    <footer className="bg-white border-t border-gray-200 px-4 py-1 text-xxs text-gray-500">
                        <div className="flex flex-wrap items-center justify-center gap-2">
                            <Link to="/terms" className="hover:text-gray-700">
                                이용약관
                            </Link>
                            <span>|</span>
                            <Link to="/privacy" className="hover:text-gray-700">
                                개인정보 처리방침
                            </Link>
                            <span>|</span>
                            <Link to="/faq" className="hover:text-gray-700">
                                FAQ
                            </Link>
                            <span>|</span>
                            <span>© 2026 ONYOU. All rights reserved.</span>
                        </div>
                    </footer>
                </div>
            </div>
        </div>
    );
}