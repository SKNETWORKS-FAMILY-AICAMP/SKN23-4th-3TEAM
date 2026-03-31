class RecommendedProduct {
  final String productVectorId;
  final String title;
  final String url;
  final String? description;

  const RecommendedProduct({
    required this.productVectorId,
    required this.title,
    required this.url,
    this.description,
  });
}