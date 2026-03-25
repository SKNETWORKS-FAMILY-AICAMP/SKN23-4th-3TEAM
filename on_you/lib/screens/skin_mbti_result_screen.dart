import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/skin_mbti_result_data.dart';
import 'main_shell.dart';
import 'skin_mbti_test_screen.dart';

class SkinMbtiResultScreen extends StatefulWidget {
  final String resultCode;

  const SkinMbtiResultScreen({
    super.key,
    required this.resultCode,
  });

  @override
  State<SkinMbtiResultScreen> createState() => _SkinMbtiResultScreenState();
}

class _SkinMbtiResultScreenState extends State<SkinMbtiResultScreen> {
  static const Color _pageBg = Color(0xFFF6F7F1);
  static const Color _textPrimary = Color(0xFF132238);
  static const Color _textSecondary = Color(0xFF4E5B6B);
  static const Color _cardBorder = Color(0xFFE3E8DA);

  bool _showAnalysisMenu = false;

  void _openShell(int index, {String? prompt}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(
          initialIndex: index,
          chatbotInitialPrompt: prompt,
        ),
      ),
          (route) => false,
    );
  }

  void _openQuick() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const QuickAnalysisIntroScreen(),
      ),
    );
  }

  void _openDetailed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DetailedAnalysisIntroScreen(),
      ),
    );
  }

  void _openIngredient() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const IngredientAnalysisIntroScreen(),
      ),
    );
  }

  void _openPersonalColor() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PersonalColorIntroScreen(),
      ),
    );
  }

  Future<void> _shareResult(SkinMbtiResult result) async {
    final shareText = '''
[피부 MBTI 결과]
${result.code} - ${result.title}

${result.description.replaceAll('<br>', ' ')}

추천 챗봇 질문:
${result.chatbotSuggestion}
''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final result = skinMbtiResults[widget.resultCode];

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('검사 결과')),
        body: const Center(
          child: Text('결과를 불러오지 못했어요.'),
        ),
      );
    }

    return AppShellFrame(
      selectedIndex: null,
      showAnalysisMenu: _showAnalysisMenu,
      onDismissAnalysisMenu: () {
        setState(() {
          _showAnalysisMenu = false;
        });
      },
      onHomeTap: () => _openShell(0),
      onAnalysisTap: () {
        setState(() {
          _showAnalysisMenu = !_showAnalysisMenu;
        });
      },
      onChatTap: () => _openShell(2),
      onWishTap: () => _openShell(3),
      onSettingsTap: () => _openShell(4),
      onQuickTap: _openQuick,
      onDetailedTap: _openDetailed,
      onIngredientTap: _openIngredient,
      onPersonalColorTap: _openPersonalColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: _pageBg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _textPrimary,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '피부 MBTI 결과',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 6),
                _buildHeroCard(result),
                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '이런 습관이 많아요',
                  icon: Icons.favorite_outline_rounded,
                  iconColor: const Color(0xFFD9A951),
                  child: Text(
                    result.habits,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: _textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildSectionCard(
                  title: '추천 챗봇 대화',
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFFD9A951),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openShell(
                      2,
                      prompt: result.chatbotSuggestion,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: result.accentColor.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '💬',
                            style: TextStyle(fontSize: 17),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              result.chatbotSuggestion,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: result.accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: result.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (result.morningRoutine.isNotEmpty) ...[
                  _buildSectionCard(
                    title: '아침 루틴',
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFD9A951),
                    child: Column(
                      children: result.morningRoutine
                          .map((item) => _buildDotItem(item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                if (result.nightRoutine.isNotEmpty) ...[
                  _buildSectionCard(
                    title: '저녁 루틴',
                    icon: Icons.nights_stay_outlined,
                    iconColor: const Color(0xFFD9A951),
                    child: Column(
                      children: result.nightRoutine
                          .map((item) => _buildDotItem(item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                _buildSectionCard(
                  title: '케어 팁',
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFFD9A951),
                  child: Column(
                    children: result.careTips
                        .map((item) => _buildDotItem(item))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),

                _buildSectionCard(
                  title: '피하면 좋은 습관',
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFD9A951),
                  child: Column(
                    children: result.avoidHabits
                        .map((item) => _buildWarningItem(item))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(SkinMbtiResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: result.backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              _TopActionButton(
                label: '카카오톡 공유',
                backgroundColor: const Color(0xFFF8DF00),
                foregroundColor: const Color(0xFF2A2418),
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => _shareResult(result),
              ),
              _TopActionButton(
                label: '다시 검사하기',
                backgroundColor: Colors.white,
                foregroundColor: _textPrimary,
                icon: Icons.refresh_rounded,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkinMbtiTestScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.30),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      result.imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: result.accentColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '이미지 준비 중',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: result.accentColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: result.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.description.replaceAll('<br>', '\n'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth > 520;
                    final cardWidth = twoColumns
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _buildMiniInfoCard(
                            title: '한눈에 보는 내 타입',
                            body: result.description.replaceAll('<br>', '\n'),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildMiniInfoCard(
                            title: '피부 목표',
                            body: result.careTips.isNotEmpty
                                ? result.careTips.first
                                : result.subtitle,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoCard({
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFFFF4DD),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDotItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF28FB0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.75,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF28FB0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.75,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final VoidCallback onTap;

  const _TopActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}