import 'package:flutter/material.dart';

class SkinAnalysisResult {
  final int analysisId;
  final String analyzedAt;
  final int overallScore;
  final String skinType;
  final String summary;
  final String? analysisImageUrl;
  final List<SkinMetricModel> metrics;
  final PreviousAnalysisModel? previousAnalysis;

  SkinAnalysisResult({
    required this.analysisId,
    required this.analyzedAt,
    required this.overallScore,
    required this.skinType,
    required this.summary,
    required this.analysisImageUrl,
    required this.metrics,
    required this.previousAnalysis,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      analysisId: json['analysis_id'] ?? 0,
      analyzedAt: json['analyzed_at'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      skinType: json['skin_type'] ?? '',
      summary: json['summary'] ?? '',
      analysisImageUrl: json['analysis_image_url'],
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((e) => SkinMetricModel.fromJson(e))
          .toList(),
      previousAnalysis: json['previous_analysis'] != null
          ? PreviousAnalysisModel.fromJson(json['previous_analysis'])
          : null,
    );
  }
}

class SkinMetricModel {
  final String title;
  final int score;
  final String status;
  final String colorHex;
  final String iconKey;

  SkinMetricModel({
    required this.title,
    required this.score,
    required this.status,
    required this.colorHex,
    required this.iconKey,
  });

  factory SkinMetricModel.fromJson(Map<String, dynamic> json) {
    return SkinMetricModel(
      title: json['title'] ?? '',
      score: json['score'] ?? 0,
      status: json['status'] ?? '',
      colorHex: json['color'] ?? '#8CC63F',
      iconKey: json['icon'] ?? '',
    );
  }

  Color get color => _hexToColor(colorHex);

  IconData get icon {
    switch (iconKey) {
      case 'water':
        return Icons.water_drop_outlined;
      case 'elasticity':
        return Icons.spa_outlined;
      case 'wrinkle':
        return Icons.waves_outlined;
      case 'pore':
        return Icons.adjust_outlined;
      case 'pigment':
        return Icons.brightness_5_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  static Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final buffer = StringBuffer();
    if (cleaned.length == 6) buffer.write('ff');
    buffer.write(cleaned);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class PreviousAnalysisModel {
  final String analyzedAt;
  final int overallScore;
  final List<PreviousMetricModel> metrics;

  PreviousAnalysisModel({
    required this.analyzedAt,
    required this.overallScore,
    required this.metrics,
  });

  factory PreviousAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PreviousAnalysisModel(
      analyzedAt: json['analyzed_at'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map((e) => PreviousMetricModel.fromJson(e))
          .toList(),
    );
  }
}

class PreviousMetricModel {
  final String title;
  final int score;

  PreviousMetricModel({
    required this.title,
    required this.score,
  });

  factory PreviousMetricModel.fromJson(Map<String, dynamic> json) {
    return PreviousMetricModel(
      title: json['title'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}