import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/wish_item.dart';
import '../store/wish_store.dart';

class WishScreen extends StatefulWidget {
  final bool isActive;

  const WishScreen({
    super.key,
    this.isActive = false,
  });

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> {
  final WishStore wishStore = WishStore.instance;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didUpdateWidget(covariant WishScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _loadWishlist();
    }
  }

  Future<void> _loadWishlist() async {
    try {
      await wishStore.load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('위시리스트를 불러오지 못했어요.\n$e')),
      );
    }
  }

  Future<void> _removeItem(WishItem item) async {
    try {
      await wishStore.remove(item.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위시리스트에서 삭제했어요.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제하지 못했어요.\n$e')),
      );
    }
  }

  Future<void> _confirmRemove(WishItem item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제할까요?'),
          content: Text('${item.title}\n상품을 위시리스트에서 삭제할까요?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8BC53F),
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _removeItem(item);
    }
  }

  Future<void> _openUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연결된 링크가 없어요.')),
      );
      return;
    }

    final uri = Uri.tryParse(trimmed);

    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크 형식이 올바르지 않아요.')),
      );
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없어요.')),
      );
    }
  }

  String _labelForSource(String source) {
    switch (source.toLowerCase()) {
      case 'chatbot':
        return '위시리스트';
      case 'manual':
        return '직접 저장';
      case 'sample':
        return '위시리스트';
      default:
        return '위시리스트';
    }
  }

  String _formatDateTime(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$year. $month. $day. $period $displayHour:$minute';
  }

  Widget _buildHeader(int count, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/wish.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '위시리스트',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '저장한 제품 목록',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6F7785),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF8BC53F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              '$count개 저장됨',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 34,
              color: Color(0xFF9AA18F),
            ),
            SizedBox(height: 10),
            Text(
              '저장된 상품이 없어요.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '챗봇 추천 상품이나 원하는 상품을 저장해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLinkRow(WishItem item) {
    return InkWell(
      onTap: () => _openUrl(item.url),
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              '제품 링크 보기',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6E8E2E),
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Color(0xFF6E8E2E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishCard(WishItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _openUrl(item.url),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8EBE2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3D3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _labelForSource(item.source),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6E8E2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2430),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '추가일: ${_formatDateTime(item.createdAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildProductLinkRow(item),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _confirmRemove(item),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD7D9D4),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Color(0xFF8C9097),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F2),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: wishStore,
          builder: (context, _) {
            final items = wishStore.items;
            final isLoading = wishStore.isLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(items.length, isLoading),
                Expanded(
                  child: isLoading && items.isEmpty
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : items.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                    onRefresh: _loadWishlist,
                    child: ListView.separated(
                      padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildWishCard(item);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}