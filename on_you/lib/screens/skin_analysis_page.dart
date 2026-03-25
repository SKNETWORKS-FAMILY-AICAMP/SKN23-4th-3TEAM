import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/skin_analysis_result.dart';
import '../services/api_service.dart';

enum _AnalysisTab {
  current,
  compare,
}



class SkinAnalysisPage extends StatefulWidget {
  final String? frontPath;
  final String? leftPath;
  final String? rightPath;
  final Map<String, dynamic>? analysisResult;

  const SkinAnalysisPage({
    super.key,
    this.frontPath,
    this.leftPath,
    this.rightPath,
    this.analysisResult,
  });

  @override
  State<SkinAnalysisPage> createState() => _SkinAnalysisPageState();
}

class _SkinAnalysisPageState extends State<SkinAnalysisPage> {
  _AnalysisTab _selectedTab = _AnalysisTab.current;

  bool _isLoading = true;
  String? _errorMessage;
  List<SkinAnalysisResult> _history = [];
  int _selectedHistoryIndex = 0;

  SkinAnalysisResult? get _selectedResult {
    if (_history.isEmpty) return null;
    if (_selectedHistoryIndex < 0 || _selectedHistoryIndex >= _history.length) {
      return null;
    }
    return _history[_selectedHistoryIndex];
  }

  SkinAnalysisResult? get _previousSelectedResult {
    final nextIndex = _selectedHistoryIndex + 1;
    if (nextIndex < 0 || nextIndex >= _history.length) {
      return null;
    }
    return _history[nextIndex];
  }

  List<String> get _historyDates {
    return _history.map((e) => _formatDate(e.analyzedAt)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final me = await ApiService.getMe();
      final userId = _toInt(me['user_id'] ?? me['id']);

      if (userId == null) {
        throw Exception('사용자 정보를 확인하지 못했어요.');
      }

      final history = await ApiService.fetchSkinAnalysisHistory(userId);

      if (!mounted) return;

      setState(() {
        _history = history;
        _selectedHistoryIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '-';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final y = parsed.year.toString();
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  List<_UiMetric> _currentMetrics(SkinAnalysisResult result) {
    return result.metrics
        .map(
          (e) => _UiMetric(
        title: e.title,
        score: e.score,
        status: e.status,
        color: e.color,
        icon: e.icon,
      ),
    )
        .toList();
  }

  String _scoreStatus(int score) {
    if (score >= 85) return '매우 좋음';
    if (score >= 70) return '양호';
    if (score >= 55) return '보통';
    if (score >= 40) return '약간';
    return '약함';
  }

  Color _colorForMetricTitle(String title) {
    switch (title) {
      case '수분':
        return const Color(0xFF5B84D7);
      case '탄력':
        return const Color(0xFF6EC39A);
      case '주름':
        return const Color(0xFFF0A86B);
      case '모공':
        return const Color(0xFF9C6BC8);
      case '색소침착':
        return const Color(0xFFE06AA1);
      default:
        return const Color(0xFF8CC63F);
    }
  }

  IconData _iconForMetricTitle(String title) {
    switch (title) {
      case '수분':
        return Icons.water_drop_outlined;
      case '탄력':
        return Icons.spa_outlined;
      case '주름':
        return Icons.waves_outlined;
      case '모공':
        return Icons.adjust_outlined;
      case '색소침착':
        return Icons.brightness_5_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  List<_UiMetric> _metricsFromResult(SkinAnalysisResult result) {
    return result.metrics
        .map(
          (e) => _UiMetric(
        title: e.title,
        score: e.score,
        status: e.status.isNotEmpty ? e.status : _scoreStatus(e.score),
        color: e.color ?? _colorForMetricTitle(e.title),
        icon: e.icon ?? _iconForMetricTitle(e.title),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedResult = _selectedResult;
    final previousSelectedResult = _previousSelectedResult;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '피부 분석 결과',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8CC63F),
          ),
        )
            : _errorMessage != null
            ? _ErrorView(
          message: _errorMessage!,
          onRetry: _loadAnalysis,
        )
            : selectedResult == null
            ? _EmptyAnalysisView(onRetry: _loadAnalysis)
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _SegmentTabs(
                      selectedTab: _selectedTab,
                      onChanged: (tab) {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AnalysisDateDropdown(
                    dates: _historyDates,
                    selectedIndex: _selectedHistoryIndex,
                    onChanged: (index) {
                      if (index == null) return;
                      setState(() {
                        _selectedHistoryIndex = index;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedTab == _AnalysisTab.current)
                _CurrentAnalysisView(
                  result: selectedResult,
                  metrics: _currentMetrics(selectedResult),
                  analyzedDate:
                  _formatDate(selectedResult.analyzedAt),
                )
              else
                _CompareAnalysisView(
                  currentResult: selectedResult,
                  previousResult: previousSelectedResult,
                  currentMetrics: _currentMetrics(selectedResult),
                  previousMetrics: previousSelectedResult == null
                      ? []
                      : _metricsFromResult(previousSelectedResult),
                  currentDate:
                  _formatDate(selectedResult.analyzedAt),
                  previousDate: previousSelectedResult == null
                      ? '-'
                      : _formatDate(
                    previousSelectedResult.analyzedAt,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UiMetric {
  final String title;
  final int score;
  final String status;
  final Color color;
  final IconData icon;

  const _UiMetric({
    required this.title,
    required this.score,
    required this.status,
    required this.color,
    required this.icon,
  });
}

class _SegmentTabs extends StatelessWidget {
  final _AnalysisTab selectedTab;
  final ValueChanged<_AnalysisTab> onChanged;

  const _SegmentTabs({
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTab({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF8CC63F) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF7B8190),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          buildTab(
            label: '종합 분석',
            selected: selectedTab == _AnalysisTab.current,
            onTap: () => onChanged(_AnalysisTab.current),
          ),
          const SizedBox(width: 6),
          buildTab(
            label: '비교 분석',
            selected: selectedTab == _AnalysisTab.compare,
            onTap: () => onChanged(_AnalysisTab.compare),
          ),
        ],
      ),
    );
  }
}

class _CurrentAnalysisView extends StatelessWidget {
  final SkinAnalysisResult result;
  final List<_UiMetric> metrics;
  final String analyzedDate;

  const _CurrentAnalysisView({
    required this.result,
    required this.metrics,
    required this.analyzedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScoreSummaryCard(
          score: result.overallScore,
          skinType: result.skinType,
          summary: result.summary,
        ),
        const SizedBox(height: 14),
        _AnalysisImageCard(
          imageUrl: result.analysisImageUrl,
          dateText: analyzedDate,
        ),
        const SizedBox(height: 14),
        _MetricSectionCard(metrics: metrics),
        const SizedBox(height: 14),
        _RadarSectionCard(metrics: metrics),
      ],
    );
  }
}

class _CompareAnalysisView extends StatelessWidget {
  final SkinAnalysisResult currentResult;
  final SkinAnalysisResult? previousResult;
  final List<_UiMetric> currentMetrics;
  final List<_UiMetric> previousMetrics;
  final String previousDate;
  final String currentDate;

  const _CompareAnalysisView({
    required this.currentResult,
    required this.previousResult,
    required this.currentMetrics,
    required this.previousMetrics,
    required this.previousDate,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final prev = previousResult;

    if (prev == null || previousMetrics.isEmpty) {
      return const _EmptyCompareCard();
    }

    final comparedMetrics = currentMetrics.map((current) {
      final prevMetric = previousMetrics.firstWhere(
            (e) => e.title == current.title,
        orElse: () => _UiMetric(
          title: current.title,
          score: 0,
          status: '-',
          color: current.color,
          icon: current.icon,
        ),
      );

      return _ComparedMetric(
        title: current.title,
        icon: current.icon,
        color: current.color,
        previousScore: prevMetric.score,
        currentScore: current.score,
      );
    }).toList();

    return Column(
      children: [
        _CompareScoreCard(
          previousScore: prev.overallScore,
          currentScore: currentResult.overallScore,
          previousDate: previousDate,
          currentDate: currentDate,
        ),
        const SizedBox(height: 14),
        _MetricCompareSectionCard(metrics: comparedMetrics),
        const SizedBox(height: 14),
        _RadarCompareSectionCard(
          currentMetrics: currentMetrics,
          previousMetrics: previousMetrics,
          previousDate: previousDate,
          currentDate: currentDate,
        ),
      ],
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  final int score;
  final String skinType;
  final String summary;

  const _ScoreSummaryCard({
    required this.score,
    required this.skinType,
    required this.summary,
  });

  List<_CareTip> _buildCareTips() {
    final tips = <_CareTip>[];

    if (summary.contains('건조') || summary.contains('수분')) {
      tips.add(
        const _CareTip(
          icon: Icons.shield_moon_outlined,
          label: '보습 강화',
        ),
      );
    }
    if (summary.contains('탄력')) {
      tips.add(
        const _CareTip(
          icon: Icons.health_and_safety_outlined,
          label: '탄력 강화',
        ),
      );
    }
    if (summary.contains('자외선') || summary.contains('색소')) {
      tips.add(
        const _CareTip(
          icon: Icons.wb_sunny_outlined,
          label: '자외선 차단',
        ),
      );
    }
    if (summary.contains('모공')) {
      tips.add(
        const _CareTip(
          icon: Icons.sanitizer_outlined,
          label: '모공 타이트닝',
        ),
      );
    }

    if (tips.isEmpty) {
      return const [
        _CareTip(icon: Icons.shield_moon_outlined, label: '보습 강화'),
        _CareTip(icon: Icons.health_and_safety_outlined, label: '탄력 강화'),
      ];
    }

    return tips.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tips = _buildCareTips();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9ECE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '종합 피부 점수',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _ScoreCircle(score: score)),
                    const SizedBox(height: 16),
                    _SummaryText(
                      skinType: skinType.isEmpty ? '분석 결과' : skinType,
                      summary: summary,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScoreCircle(score: score),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _SummaryText(
                      skinType: skinType.isEmpty ? '분석 결과' : skinType,
                      summary: summary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF0F1EC),
          ),
          const SizedBox(height: 16),
          const Text(
            '추천 관리법',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: tips
                    .map(
                      (item) => SizedBox(
                    width: itemWidth,
                    child: _CareItem(
                      icon: item.icon,
                      label: item.label,
                    ),
                  ),
                )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CareTip {
  final IconData icon;
  final String label;

  const _CareTip({
    required this.icon,
    required this.label,
  });
}

class _ScoreCircle extends StatelessWidget {
  final int score;

  const _ScoreCircle({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = score.clamp(0, 100) / 100;

    return SizedBox(
      width: 118,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: CircularProgressIndicator(
              value: normalized.toDouble(),
              strokeWidth: 10,
              backgroundColor: const Color(0xFFE6E8E3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8CC63F),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF78B929),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '전체 피부 상태',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9AA1AC),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryText extends StatelessWidget {
  final String skinType;
  final String summary;

  const _SummaryText({
    required this.skinType,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8CC63F),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            skinType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          summary.trim().isEmpty ? '분석 요약 데이터가 아직 없어요.' : summary,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF5B6473),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CareItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CareItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF8CC63F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EED8)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF7DF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: green,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Color(0xFF4C5563),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisImageCard extends StatefulWidget {
  final String? imageUrl;
  final String dateText;

  const _AnalysisImageCard({
    required this.imageUrl,
    required this.dateText,
  });

  @override
  State<_AnalysisImageCard> createState() => _AnalysisImageCardState();
}

class _AnalysisImageCardState extends State<_AnalysisImageCard> {
  bool _isExpanded = false;

  bool get _hasImage =>
      widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9ECE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분석 이미지',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasImage
                ? '확인하기 버튼을 누르면 최근 분석 이미지를 볼 수 있어요.'
                : '현재 표시할 분석 이미지가 없어요.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8B93A1),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF253041),
                side: const BorderSide(color: Color(0xFFDDE3D3)),
                backgroundColor: const Color(0xFFF9FAF7),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _isExpanded ? '닫기' : '확인하기',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_hasImage)
                        Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _emptyImageBox();
                          },
                        )
                      else
                        _emptyImageBox(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(_hasImage ? 0.62 : 0.10),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasImage ? '최근 분석 이미지' : '분석 이미지 없음',
                                style: TextStyle(
                                  color: _hasImage
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.dateText,
                                style: TextStyle(
                                  color: _hasImage
                                      ? Colors.white70
                                      : const Color(0xFF9AA1AC),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            crossFadeState:
            _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _emptyImageBox() {
    return Container(
      color: const Color(0xFFF4F6F1),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 42,
            color: Color(0xFFB0B8A5),
          ),
          SizedBox(height: 12),
          Text(
            '저장된 분석 이미지가 없어요',
            style: TextStyle(
              color: Color(0xFF8B93A1),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSectionCard extends StatelessWidget {
  final List<_UiMetric> metrics;

  const _MetricSectionCard({
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '피부 지표 상세',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 14),
          if (metrics.isEmpty)
            const Text(
              '지표 데이터가 없어요.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8B93A1),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...List.generate(metrics.length, (index) {
              final metric = metrics[index];
              return Padding(
                padding:
                EdgeInsets.only(bottom: index == metrics.length - 1 ? 0 : 10),
                child: _MetricListTile(metric: metric),
              );
            }),
        ],
      ),
    );
  }
}

class _MetricListTile extends StatelessWidget {
  final _UiMetric metric;

  const _MetricListTile({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              metric.icon,
              size: 20,
              color: metric.color,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Text(
              metric.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3A4352),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${metric.score}점',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: metric.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      metric.status,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B93A1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (metric.score.clamp(0, 100)) / 100,
                    backgroundColor: const Color(0xFFE9ECF0),
                    valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparedMetric {
  final String title;
  final IconData icon;
  final Color color;
  final int previousScore;
  final int currentScore;

  const _ComparedMetric({
    required this.title,
    required this.icon,
    required this.color,
    required this.previousScore,
    required this.currentScore,
  });

  int get diff => currentScore - previousScore;
}

class _CompareScoreCard extends StatelessWidget {
  final int previousScore;
  final int currentScore;
  final String previousDate;
  final String currentDate;

  const _CompareScoreCard({
    required this.previousScore,
    required this.currentScore,
    required this.previousDate,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final diff = currentScore - previousScore;
    final isDown = diff < 0;
    final diffText = isDown ? '$diff' : '+$diff';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '피부 점수 변화',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CompareScoreBox(
                  date: previousDate,
                  score: previousScore,
                  label: '이전',
                  scoreColor: const Color(0xFF8B93A1),
                  backgroundColor: const Color(0xFFF5F6F8),
                ),
              ),
              SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDown
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: isDown
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF2BB673),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diffText,
                      style: TextStyle(
                        color: isDown
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF2BB673),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CompareScoreBox(
                  date: currentDate,
                  score: currentScore,
                  label: '현재',
                  scoreColor: const Color(0xFF78B929),
                  backgroundColor: const Color(0xFFF2F8E9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompareScoreBox extends StatelessWidget {
  final String date;
  final int score;
  final String label;
  final Color scoreColor;
  final Color backgroundColor;

  const _CompareScoreBox({
    required this.date,
    required this.score,
    required this.label,
    required this.scoreColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AA1AC),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              color: scoreColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8B93A1),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCompareSectionCard extends StatelessWidget {
  final List<_ComparedMetric> metrics;

  const _MetricCompareSectionCard({
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지표별 변화',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(metrics.length, (index) {
            return Padding(
              padding:
              EdgeInsets.only(bottom: index == metrics.length - 1 ? 0 : 10),
              child: _MetricCompareRow(metric: metrics[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _MetricCompareRow extends StatelessWidget {
  final _ComparedMetric metric;

  const _MetricCompareRow({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final diff = metric.diff;
    final isDown = diff < 0;
    final diffText = isDown ? '$diff' : '+$diff';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              metric.icon,
              size: 18,
              color: metric.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              metric.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3A4352),
              ),
            ),
          ),
          Text(
            '${metric.previousScore}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8B93A1),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '›',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFB0B7C2),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${metric.currentScore}',
            style: TextStyle(
              fontSize: 13,
              color: metric.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              Icon(
                isDown
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                size: 14,
                color: isDown
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF2BB673),
              ),
              const SizedBox(width: 2),
              Text(
                diffText,
                style: TextStyle(
                  fontSize: 12,
                  color: isDown
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF2BB673),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarSectionCard extends StatelessWidget {
  final List<_UiMetric> metrics;

  const _RadarSectionCard({
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '피부 레이더 차트',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '현재 피부 상태 종합',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9AA1AC),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (metrics.isEmpty)
            const SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  '차트 데이터가 없어요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B93A1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 290,
              width: double.infinity,
              child: CustomPaint(
                painter: _SingleRadarChartPainter(metrics: metrics),
              ),
            ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.square,
                size: 13,
                color: Color(0xFF8CC63F),
              ),
              SizedBox(width: 4),
              Text(
                '현재',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7B8190),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarCompareSectionCard extends StatelessWidget {
  final List<_UiMetric> currentMetrics;
  final List<_UiMetric> previousMetrics;
  final String previousDate;
  final String currentDate;

  const _RadarCompareSectionCard({
    required this.currentMetrics,
    required this.previousMetrics,
    required this.previousDate,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '피부 레이더 비교',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '현재($currentDate) vs 이전($previousDate) 피부 상태 비교',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9AA1AC),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: CustomPaint(
              painter: _CompareRadarChartPainter(
                currentMetrics: currentMetrics,
                previousMetrics: previousMetrics,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFFB9C0CC), label: '이전'),
              SizedBox(width: 14),
              _LegendDot(color: Color(0xFF8CC63F), label: '현재'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.square, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7B8190),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyCompareCard extends StatelessWidget {
  const _EmptyCompareCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECE3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: Color(0xFF8CC63F),
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            '이전 분석 데이터가 아직 없어요.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '한 번 더 피부 분석을 진행하면\n비교 분석 탭에서 변화 추이를 볼 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAnalysisView extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyAnalysisView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_search_outlined,
              size: 54,
              color: Color(0xFF8CC63F),
            ),
            const SizedBox(height: 14),
            const Text(
              '아직 분석 결과가 없어요.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF253041),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '챗봇에서 빠른 분석이나 정밀 분석을 먼저 진행해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CC63F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('다시 불러오기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: Color(0xFFE57373),
            ),
            const SizedBox(height: 14),
            const Text(
              '피부 분석 결과를 불러오지 못했어요.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF253041),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CC63F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleRadarChartPainter extends CustomPainter {
  final List<_UiMetric> metrics;

  _SingleRadarChartPainter({
    required this.metrics,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRadarBase(canvas, size, metrics.map((e) => e.title).toList());
    _drawRadarShape(
      canvas: canvas,
      size: size,
      scores: metrics.map((e) => e.score.toDouble()).toList(),
      strokeColor: const Color(0xFF8CC63F),
      fillColor: const Color(0xFF8CC63F).withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _SingleRadarChartPainter oldDelegate) {
    return oldDelegate.metrics != metrics;
  }
}

class _CompareRadarChartPainter extends CustomPainter {
  final List<_UiMetric> currentMetrics;
  final List<_UiMetric> previousMetrics;

  _CompareRadarChartPainter({
    required this.currentMetrics,
    required this.previousMetrics,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRadarBase(canvas, size, currentMetrics.map((e) => e.title).toList());

    _drawRadarShape(
      canvas: canvas,
      size: size,
      scores: previousMetrics.map((e) => e.score.toDouble()).toList(),
      strokeColor: const Color(0xFFB9C0CC),
      fillColor: const Color(0xFFB9C0CC).withOpacity(0.15),
    );

    _drawRadarShape(
      canvas: canvas,
      size: size,
      scores: currentMetrics.map((e) => e.score.toDouble()).toList(),
      strokeColor: const Color(0xFF8CC63F),
      fillColor: const Color(0xFF8CC63F).withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _CompareRadarChartPainter oldDelegate) {
    return oldDelegate.currentMetrics != currentMetrics ||
        oldDelegate.previousMetrics != previousMetrics;
  }
}

void _drawRadarBase(Canvas canvas, Size size, List<String> labels) {
  final center = Offset(size.width / 2, size.height / 2 + 8);
  final radius = math.min(size.width, size.height) * 0.28;
  const levels = 5;

  final gridPaint = Paint()
    ..color = const Color(0xFFDDE2D8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final axisPaint = Paint()
    ..color = const Color(0xFFE3E7DE)
    ..strokeWidth = 1;

  final angleStep = (2 * math.pi) / labels.length;
  final startAngle = -math.pi / 2;

  for (int level = 1; level <= levels; level++) {
    final currentRadius = radius * (level / levels);
    final path = Path();

    for (int i = 0; i < labels.length; i++) {
      final angle = startAngle + angleStep * i;
      final point = Offset(
        center.dx + currentRadius * math.cos(angle),
        center.dy + currentRadius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, gridPaint);
  }

  for (int i = 0; i < labels.length; i++) {
    final angle = startAngle + angleStep * i;
    final end = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawLine(center, end, axisPaint);
  }

  for (int i = 0; i < labels.length; i++) {
    final angle = startAngle + angleStep * i;
    final labelRadius = radius + 28;
    final labelPoint = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF868E9C),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      labelPoint.dx - textPainter.width / 2,
      labelPoint.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }
}

void _drawRadarShape({
  required Canvas canvas,
  required Size size,
  required List<double> scores,
  required Color strokeColor,
  required Color fillColor,
}) {
  if (scores.isEmpty) return;

  final center = Offset(size.width / 2, size.height / 2 + 8);
  final radius = math.min(size.width, size.height) * 0.28;
  final angleStep = (2 * math.pi) / scores.length;
  final startAngle = -math.pi / 2;

  final fillPaint = Paint()
    ..color = fillColor
    ..style = PaintingStyle.fill;

  final strokePaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final dotPaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.fill;

  final path = Path();

  for (int i = 0; i < scores.length; i++) {
    final valueRadius = radius * ((scores[i].clamp(0, 100)) / 100);
    final angle = startAngle + angleStep * i;
    final point = Offset(
      center.dx + valueRadius * math.cos(angle),
      center.dy + valueRadius * math.sin(angle),
    );

    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }

  path.close();
  canvas.drawPath(path, fillPaint);
  canvas.drawPath(path, strokePaint);

  for (int i = 0; i < scores.length; i++) {
    final valueRadius = radius * ((scores[i].clamp(0, 100)) / 100);
    final angle = startAngle + angleStep * i;
    final point = Offset(
      center.dx + valueRadius * math.cos(angle),
      center.dy + valueRadius * math.sin(angle),
    );
    canvas.drawCircle(point, 3.4, dotPaint);
  }
}


class _AnalysisDateDropdown extends StatelessWidget {
  final List<String> dates;
  final int selectedIndex;
  final ValueChanged<int?> onChanged;

  const _AnalysisDateDropdown({
    required this.dates,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DECE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF98A08D),
          ),
          style: const TextStyle(
            color: Color(0xFF3A4352),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          items: List.generate(dates.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF8CC63F),
                  ),
                  const SizedBox(width: 8),
                  Text(dates[index]),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

