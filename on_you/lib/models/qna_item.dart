class QnaItem {
  final int? qnaId;
  final int? userId;
  final int? managerId;
  final String category;
  final String questionTitle;
  final String question;
  final String? answer;
  final String? nickname;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QnaItem({
    this.qnaId,
    this.userId,
    this.managerId,
    required this.category,
    required this.questionTitle,
    required this.question,
    this.answer,
    this.nickname,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAnswered => (answer ?? '').trim().isNotEmpty;

  factory QnaItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return text;
    }

    return QnaItem(
      qnaId: parseInt(json['qna_id']),
      userId: parseInt(json['user_id']),
      managerId: parseInt(json['manager_id']),
      category: parseString(json['category']) ?? '',
      questionTitle: parseString(json['question_title']) ?? '',
      question: parseString(json['question']) ?? '',
      answer: parseString(json['answer']),
      nickname: parseString(json['nickname']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}