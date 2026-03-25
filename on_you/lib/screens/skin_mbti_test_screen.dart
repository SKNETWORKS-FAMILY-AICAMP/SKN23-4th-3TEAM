import 'package:flutter/material.dart';

import '../data/skin_mbti_data.dart';
import 'main_shell.dart';
import 'skin_mbti_result_screen.dart';

class SkinMbtiTestScreen extends StatefulWidget {
  const SkinMbtiTestScreen({super.key});

  @override
  State<SkinMbtiTestScreen> createState() => _SkinMbtiTestScreenState();
}

class _SkinMbtiTestScreenState extends State<SkinMbtiTestScreen> {
  final PageController _pageController = PageController();

  static const Color _pageBg = Color(0xFFF5F7EF);
  static const Color _green = Color(0xFF8CC63F);
  static const Color _greenSoft = Color(0xFFEAF5D9);
  static const Color _textPrimary = Color(0xFF132238);
  static const Color _textSecondary = Color(0xFF5C6978);
  static const Color _border = Color(0xFFE2E7D8);

  int _currentIndex = 0;
  bool _showAnalysisMenu = false;
  final List<int?> _answers = List<int?>.filled(skinMbtiQuestions.length, null);

  void _selectAnswer(int optionIndex) {
    setState(() {
      _answers[_currentIndex] = optionIndex;
    });
  }

  void _goNext() {
    if (_answers[_currentIndex] == null) return;

    if (_currentIndex == skinMbtiQuestions.length - 1) {
      final resultCode = _calculateMbtiResult();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SkinMbtiResultScreen(resultCode: resultCode),
        ),
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  void _goPrev() {
    if (_currentIndex == 0) {
      Navigator.pop(context);
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
    );
  }

  String _calculateMbtiResult() {
    int s = 0, l = 0;
    int b = 0, t = 0;
    int c = 0, f = 0;

    for (int i = 0; i < _answers.length; i++) {
      final answer = _answers[i];
      if (answer == null) continue;

      if (i == 0 || i == 3 || i == 6 || i == 9) {
        if (answer == 0 || answer == 1) {
          s++;
        } else {
          l++;
        }
      }

      if (i == 1 || i == 4 || i == 7 || i == 10) {
        if (answer == 0 || answer == 1) {
          b++;
        } else {
          t++;
        }
      }

      if (i == 2 || i == 5 || i == 8 || i == 11) {
        if (answer == 0 || answer == 1) {
          c++;
        } else {
          f++;
        }
      }
    }

    final first = s >= l ? 'S' : 'L';
    final second = b >= t ? 'B' : 'T';
    final third = c >= f ? 'C' : 'F';

    return '$first$second$third';
  }

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

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / skinMbtiQuestions.length;

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goPrev,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _textPrimary,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '피부 MBTI 테스트',
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            '진행률',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentIndex + 1} / ${skinMbtiQuestions.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE9ECE1),
                          valueColor: const AlwaysStoppedAnimation(_green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: skinMbtiQuestions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final question = skinMbtiQuestions[index];
                    final selected = _answers[index];

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: _border),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _greenSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: _textPrimary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: ListView.separated(
                                itemCount: question.options.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                                itemBuilder: (context, optionIndex) {
                                  final isSelected = selected == optionIndex;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => _selectAnswer(optionIndex),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _greenSoft
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected ? _green : _border,
                                          width: isSelected ? 1.8 : 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? _green
                                                  : const Color(0xFFF1F3ED),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              ['A', 'B', 'C', 'D'][optionIndex],
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : _textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              question.options[optionIndex],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                height: 1.45,
                                                color: _textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: _goPrev,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: _border),
                                        backgroundColor:
                                        const Color(0xFFF7F8F4),
                                        foregroundColor:
                                        const Color(0xFF9AA3AD),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chevron_left_rounded),
                                          SizedBox(width: 2),
                                          Text(
                                            '이전',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _answers[_currentIndex] == null
                                          ? null
                                          : _goNext,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _green,
                                        disabledBackgroundColor:
                                        const Color(0xFFD6DDC8),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _currentIndex ==
                                                skinMbtiQuestions.length - 1
                                                ? '결과 보기'
                                                : '다음',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}