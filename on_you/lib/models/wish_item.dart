class WishItem {
  final String id;
  final String title;
  final String url;
  final String source;
  final DateTime createdAt;

  const WishItem({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.createdAt,
  });

  factory WishItem.fromJson(Map<String, dynamic> json) {
    return WishItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? 'chatbot',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}