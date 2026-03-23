import { motion } from "motion/react";
import { useEffect, useMemo, useState } from "react";
import { Loading } from "@/app/components/ui/loading";
import { Heart, ExternalLink, Trash2, ChevronLeft, ChevronRight } from "lucide-react";
import { fetchWishlist, removeFromWishlist, WishlistItem } from "@/app/api/wishlistApi";

const PAGE_SIZE = 5;

function getPageNumbers(current: number, total: number): (number | "...")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: (number | "...")[] = [1];

  if (current > 3) pages.push("...");

  for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
    pages.push(i);
  }

  if (current < total - 2) pages.push("...");

  pages.push(total);

  return pages;
}

export function WishlistPage() {
  const [wishlist, setWishlist] = useState<WishlistItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [removingId, setRemovingId] = useState<number | null>(null);
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    async function loadWishlist() {
      try {
        const data = await fetchWishlist();
        setWishlist(data);
      } catch (err) {
        console.error("위시리스트 조회 실패:", err);
      } finally {
        setLoading(false);
      }
    }

    loadWishlist();
  }, []);

  const sortedWishlist = useMemo(() => {
    return [...wishlist].sort(
      (a, b) => new Date(b.added_at).getTime() - new Date(a.added_at).getTime()
    );
  }, [wishlist]);

  const totalPages = Math.ceil(sortedWishlist.length / PAGE_SIZE);

  const pageItems = useMemo(() => {
    const start = (currentPage - 1) * PAGE_SIZE;
    const end = start + PAGE_SIZE;
    return sortedWishlist.slice(start, end);
  }, [sortedWishlist, currentPage]);

  useEffect(() => {
    if (totalPages === 0) {
      setCurrentPage(1);
      return;
    }

    if (currentPage > totalPages) {
      setCurrentPage(totalPages);
    }
  }, [currentPage, totalPages]);

  const goToPage = (page: number) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleRemove = async (wishId: number) => {
    try {
      setRemovingId(wishId);
      await removeFromWishlist(wishId);
      setWishlist((prev) => prev.filter((item) => item.wish_id !== wishId));
    } catch (err) {
      console.error("위시리스트 삭제 실패:", err);
      alert("위시리스트 삭제에 실패했습니다.");
    } finally {
      setRemovingId(null);
    }
  };
  if (loading) {
    return <Loading />;
  }
  return (
    <div className="h-full overflow-y-auto bg-[#F8FBF3]">
      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-gray-900 font-bold text-xl">위시리스트</h1>
            <p className="text-sm text-gray-500 mt-0.5">저장한 제품 목록</p>
          </div>

          <span
            className="px-3 py-1.5 rounded-xl text-sm font-semibold text-white"
            style={{ background: "#85C13D" }}
          >
            {wishlist.length}개 저장됨
          </span>
        </div>

        {loading ? (
          <Loading />
        ) : sortedWishlist.length === 0 ? (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-8 text-center">
            <Heart className="w-10 h-10 mx-auto text-gray-300 mb-3" />
            <p className="text-gray-700 font-medium">저장된 제품이 없습니다.</p>
            <p className="text-sm text-gray-400 mt-1">추천 제품을 위시리스트에 추가해보세요.</p>
          </div>
        ) : (
          <>
            <div className="space-y-4">
              {pageItems.map((item, idx) => (
                <motion.div
                  key={item.wish_id}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: idx * 0.05 }}
                  className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5"
                >
                  <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <span
                          className="text-[11px] px-2 py-1 rounded-lg font-semibold"
                          style={{ background: "#E8F5D0", color: "#4A7A1E" }}
                        >
                          위시리스트
                        </span>
                      </div>

                      <h2 className="text-base font-semibold text-gray-900 break-words">
                        {item.product_name}
                      </h2>

                      <div className="mt-2 text-sm text-gray-500 space-y-1">
                        <p>
                          추가일:{" "}
                          {new Date(item.added_at).toLocaleString("ko-KR", {
                            timeZone: "Asia/Seoul",
                          })}
                        </p>
                      </div>

                      {item.product_url && (
                        <a
                          href={item.product_url}
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-1 mt-3 text-sm font-medium text-[#6BA32E] hover:underline"
                        >
                          제품 링크 보기
                          <ExternalLink className="w-4 h-4" />
                        </a>
                      )}
                    </div>

                    <button
                      onClick={() => handleRemove(item.wish_id)}
                      disabled={removingId === item.wish_id}
                      className="flex-shrink-0 inline-flex items-center justify-center w-10 h-10 rounded-xl border border-gray-200 bg-white text-gray-500 hover:bg-gray-50 hover:text-red-500 transition-colors disabled:opacity-50"
                      aria-label="위시리스트 삭제"
                      title="위시리스트 삭제"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>

            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-1 mt-6">
                <button
                  onClick={() => goToPage(currentPage - 1)}
                  disabled={currentPage === 1}
                  className="w-8 h-8 flex items-center justify-center rounded-lg text-gray-400 hover:text-[#6BA32E] hover:bg-[#E8F5D0] disabled:opacity-30 disabled:cursor-not-allowed transition-all"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>

                {getPageNumbers(currentPage, totalPages).map((p, i) =>
                  p === "..." ? (
                    <span
                      key={`ellipsis-${i}`}
                      className="w-8 h-8 flex items-center justify-center text-xs text-gray-400"
                    >
                      ···
                    </span>
                  ) : (
                    <button
                      key={p}
                      onClick={() => goToPage(p)}
                      className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-medium transition-all ${
                        currentPage === p
                          ? "bg-[#85C13D] text-white"
                          : "text-gray-500 hover:text-[#6BA32E] hover:bg-[#E8F5D0]"
                      }`}
                    >
                      {p}
                    </button>
                  )
                )}

                <button
                  onClick={() => goToPage(currentPage + 1)}
                  disabled={currentPage === totalPages}
                  className="w-8 h-8 flex items-center justify-center rounded-lg text-gray-400 hover:text-[#6BA32E] hover:bg-[#E8F5D0] disabled:opacity-30 disabled:cursor-not-allowed transition-all"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}