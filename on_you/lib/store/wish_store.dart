import 'package:flutter/foundation.dart';

import '../models/wish_item.dart';
import '../services/api_service.dart';

class WishStore extends ChangeNotifier {
  WishStore._();

  static final WishStore instance = WishStore._();

  final List<WishItem> _items = [];
  bool _isLoading = false;

  List<WishItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _setLoading(true);

    try {
      final rawList = await ApiService.getWishlist();

      final mapped = rawList
          .map((item) => _mapWishItem(item))
          .whereType<WishItem>()
          .toList();

      _items
        ..clear()
        ..addAll(mapped);

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  WishItem? _mapWishItem(dynamic raw) {
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);

    final wishId = _toInt(map['wish_id'] ?? map['id']);
    final productName =
    (map['product_name'] ?? map['title'] ?? '').toString().trim();

    if (wishId == null || productName.isEmpty) {
      return null;
    }

    final addedAt =
        _parseDateTime(map['added_at'] ?? map['created_at']) ?? DateTime.now();

    return WishItem(
      id: wishId.toString(),
      title: productName,
      url: (map['product_url'] ?? map['url'] ?? '').toString(),
      source: 'chatbot',
      createdAt: addedAt,
    );
  }

  Future<int?> _resolveCurrentUserId() async {
    final me = await ApiService.getMe();
    return _toInt(me['user_id'] ?? me['id']);
  }

  bool containsUrl(String url) {
    if (url.trim().isEmpty) return false;
    return _items.any((item) => item.url == url);
  }

  Future<void> addFromChat({
    required int messageId,
    required String productName,
    String? productVectorId,
    String? productUrl,
    String? productDescription,
  }) async {
    _setLoading(true);

    try {
      final userId = await _resolveCurrentUserId();

      if (userId == null) {
        throw Exception('로그인 정보를 확인하지 못했어요.');
      }

      if (productVectorId == null || productVectorId.trim().isEmpty) {
        throw Exception(
          'product_vector_id가 없어서 위시리스트에 저장할 수 없어요.\n'
              '추천 상품 응답에 product_vector_id를 포함해주세요.',
        );
      }

      final saved = await ApiService.addWishlist(
        userId: userId,
        productVectorId: productVectorId.trim(),
        productName: productName,
        messageId: messageId,
        productDescription: productDescription,
      );

      final merged = <String, dynamic>{
        ...Map<String, dynamic>.from(saved),
        if (productUrl != null) 'product_url': productUrl,
      };

      final wishItem = _mapWishItem(merged);
      if (wishItem == null) {
        throw Exception('위시리스트 응답 형식이 올바르지 않아요.');
      }

      _items.removeWhere((item) => item.id == wishItem.id);
      _items.insert(0, wishItem);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> remove(String id) async {
    _setLoading(true);

    try {
      final wishId = int.tryParse(id);

      if (wishId == null) {
        _items.removeWhere((item) => item.id == id);
        notifyListeners();
        return;
      }

      await ApiService.removeWishlist(wishId);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}