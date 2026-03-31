import 'package:flutter/material.dart';

import 'package:on_you/screens/chatbot_screen.dart';
import 'package:on_you/screens/face_capture_screen.dart';
import 'package:on_you/screens/home_screen.dart';
import 'package:on_you/screens/ingredient_capture_screen.dart';
import 'package:on_you/screens/quick_face_capture_screen.dart';
import 'package:on_you/screens/settings_screen.dart';
import 'package:on_you/screens/wish_screen.dart';
import 'package:on_you/screens/skin_analysis_page.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  final bool autoStartQuickAnalysis;
  final String? autoQuickImagePath;

  final bool autoStartDetailedAnalysis;
  final String? autoFrontPath;
  final String? autoLeftPath;
  final String? autoRightPath;

  final bool autoStartIngredientAnalysis;
  final String? autoIngredientImagePath;

  final bool autoStartPersonalColorAnalysis;
  final String? autoPersonalColorImagePath;

  final String? chatbotInitialPrompt;

  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.autoStartQuickAnalysis = false,
    this.autoQuickImagePath,
    this.autoStartDetailedAnalysis = false,
    this.autoFrontPath,
    this.autoLeftPath,
    this.autoRightPath,
    this.autoStartIngredientAnalysis = false,
    this.autoIngredientImagePath,
    this.autoStartPersonalColorAnalysis = false,
    this.autoPersonalColorImagePath,
    this.chatbotInitialPrompt,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;
  bool _showAnalysisMenu = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _changeTab(int index) {
    if (index == 1) {
      setState(() {
        _showAnalysisMenu = !_showAnalysisMenu;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
      _showAnalysisMenu = false;
    });
  }

  List<Widget> get _pages => [
    HomeScreen(
      onTabSelected: _changeTab,
      onOpenQuickAnalysis: _openQuickAnalysisPage,
      onOpenIngredientAnalysis: _openIngredientAnalysisPage,
      onOpenSkinResult: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SkinAnalysisPage(),
          ),
        );
      },
    ),
    const SizedBox.shrink(),
    ChatBotScreen(
      initialPrompt: widget.chatbotInitialPrompt,
      autoStartQuickAnalysis: widget.autoStartQuickAnalysis,
      autoQuickImagePath: widget.autoQuickImagePath,
      autoStartDetailedAnalysis: widget.autoStartDetailedAnalysis,
      autoFrontPath: widget.autoFrontPath,
      autoLeftPath: widget.autoLeftPath,
      autoRightPath: widget.autoRightPath,
      autoStartIngredientAnalysis: widget.autoStartIngredientAnalysis,
      autoIngredientImagePath: widget.autoIngredientImagePath,
      autoStartPersonalColorAnalysis:
      widget.autoStartPersonalColorAnalysis,
      autoPersonalColorImagePath: widget.autoPersonalColorImagePath,
    ),
    WishScreen(isActive: _selectedIndex == 3),
    const SettingsScreen(),
  ];

  void _openQuickAnalysisPage() {
    setState(() {
      _showAnalysisMenu = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuickAnalysisIntroScreen(),
      ),
    );
  }

  void _openDetailedAnalysisPage() {
    setState(() {
      _showAnalysisMenu = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DetailedAnalysisIntroScreen(),
      ),
    );
  }

  void _openIngredientAnalysisPage() {
    setState(() {
      _showAnalysisMenu = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IngredientAnalysisIntroScreen(),
      ),
    );
  }

  void _openPersonalColorPage() {
    setState(() {
      _showAnalysisMenu = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PersonalColorIntroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellFrame(
      selectedIndex: _selectedIndex,
      showAnalysisMenu: _showAnalysisMenu,
      onDismissAnalysisMenu: () {
        setState(() {
          _showAnalysisMenu = false;
        });
      },
      onHomeTap: () => _changeTab(0),
      onAnalysisTap: () => _changeTab(1),
      onChatTap: () => _changeTab(2),
      onWishTap: () => _changeTab(3),
      onSettingsTap: () => _changeTab(4),
      onQuickTap: _openQuickAnalysisPage,
      onDetailedTap: _openDetailedAnalysisPage,
      onIngredientTap: _openIngredientAnalysisPage,
      onPersonalColorTap: _openPersonalColorPage,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}

class AppShellFrame extends StatelessWidget {
  final Widget body;
  final int? selectedIndex;
  final bool showAnalysisMenu;

  final VoidCallback onDismissAnalysisMenu;
  final VoidCallback onHomeTap;
  final VoidCallback onAnalysisTap;
  final VoidCallback onChatTap;
  final VoidCallback onWishTap;
  final VoidCallback onSettingsTap;

  final VoidCallback onQuickTap;
  final VoidCallback onDetailedTap;
  final VoidCallback onIngredientTap;
  final VoidCallback onPersonalColorTap;

  const AppShellFrame({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.showAnalysisMenu,
    required this.onDismissAnalysisMenu,
    required this.onHomeTap,
    required this.onAnalysisTap,
    required this.onChatTap,
    required this.onWishTap,
    required this.onSettingsTap,
    required this.onQuickTap,
    required this.onDetailedTap,
    required this.onIngredientTap,
    required this.onPersonalColorTap,
  });

  @override
  Widget build(BuildContext context) {
    const double centerGap = 108;
    const double menuWidth = 184;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - centerGap) / 4;
    final analysisCenterX = itemWidth * 1.5;
    final menuLeft =
    (analysisCenterX - (menuWidth / 2)).clamp(
      12.0,
      screenWidth - menuWidth - 12.0,
    ).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          body,
          if (showAnalysisMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: onDismissAnalysisMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            left: menuLeft,
            bottom: showAnalysisMenu ? 112 : 52,
            child: IgnorePointer(
              ignoring: !showAnalysisMenu,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: showAnalysisMenu ? 1 : 0,
                child: _AnalysisFloatingMenu(
                  width: menuWidth,
                  onQuickTap: onQuickTap,
                  onDetailedTap: onDetailedTap,
                  onIngredientTap: onIngredientTap,
                  onPersonalColorTap: onPersonalColorTap,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterChatButton(
        selected: selectedIndex == 2,
        onTap: onChatTap,
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: selectedIndex,
        analysisMenuOpen: showAnalysisMenu,
        onHomeTap: onHomeTap,
        onAnalysisTap: onAnalysisTap,
        onWishTap: onWishTap,
        onSettingsTap: onSettingsTap,
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  final int? selectedIndex;
  final bool analysisMenuOpen;
  final VoidCallback onHomeTap;
  final VoidCallback onAnalysisTap;
  final VoidCallback onWishTap;
  final VoidCallback onSettingsTap;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.analysisMenuOpen,
    required this.onHomeTap,
    required this.onAnalysisTap,
    required this.onWishTap,
    required this.onSettingsTap,
  });

  Color _activeColor(bool selected) {
    return selected ? const Color(0xFF85C13D) : const Color(0xFF1F1F1F);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 96,
        child: Row(
          children: [
            Expanded(
              child: NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '홈',
                color: _activeColor(selectedIndex == 0),
                selected: selectedIndex == 0,
                onTap: onHomeTap,
              ),
            ),
            Expanded(
              child: NavItem(
                icon: Icons.face_outlined,
                activeIcon: Icons.face_rounded,
                label: '분석',
                color: _activeColor(analysisMenuOpen),
                selected: analysisMenuOpen,
                onTap: onAnalysisTap,
              ),
            ),
            const SizedBox(width: 108),
            Expanded(
              child: NavItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: '위시',
                color: _activeColor(selectedIndex == 3),
                selected: selectedIndex == 3,
                onTap: onWishTap,
              ),
            ),
            Expanded(
              child: NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: '설정',
                color: _activeColor(selectedIndex == 4),
                selected: selectedIndex == 4,
                onTap: onSettingsTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 11,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterChatButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CenterChatButton({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 25),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 76,
          height: 76,
          child: Image.asset(
            'assets/images/center_logo2.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _AnalysisFloatingMenu extends StatelessWidget {
  final double width;
  final VoidCallback onQuickTap;
  final VoidCallback onDetailedTap;
  final VoidCallback onIngredientTap;
  final VoidCallback onPersonalColorTap;

  const _AnalysisFloatingMenu({
    required this.width,
    required this.onQuickTap,
    required this.onDetailedTap,
    required this.onIngredientTap,
    required this.onPersonalColorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFF0F2EC),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MiniAnalysisButton(
                    title: '빠른 분석',
                    backgroundColor: const Color(0xFFF2F8E8),
                    borderColor: const Color(0xFFE3EFD0),
                    textColor: const Color(0xFF5F7F2A),
                    onTap: onQuickTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniAnalysisButton(
                    title: '정밀 분석',
                    backgroundColor: const Color(0xFFEFF5FF),
                    borderColor: const Color(0xFFDDE8FA),
                    textColor: const Color(0xFF506C9A),
                    onTap: onDetailedTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MiniAnalysisButton(
                    title: '성분 분석',
                    backgroundColor: const Color(0xFFFFF5EB),
                    borderColor: const Color(0xFFF8E6CF),
                    textColor: const Color(0xFF9A6C39),
                    onTap: onIngredientTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniAnalysisButton(
                    title: '퍼스널 컬러',
                    backgroundColor: const Color(0xFFF8EEFA),
                    borderColor: const Color(0xFFEBDCF0),
                    textColor: const Color(0xFF8A5D97),
                    onTap: onPersonalColorTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAnalysisButton extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _MiniAnalysisButton({
    required this.title,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickAnalysisIntroScreen extends StatefulWidget {
  const QuickAnalysisIntroScreen({super.key});

  @override
  State<QuickAnalysisIntroScreen> createState() =>
      _QuickAnalysisIntroScreenState();
}

class _QuickAnalysisIntroScreenState extends State<QuickAnalysisIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideSlideData> _slides = const [
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_1.png',
      title: '정면을 바라보고 촬영해주세요',
      subtitle: '얼굴이 정면으로 잘 보이도록 가이드에 맞춰 촬영해주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_2.png',
      title: '얼굴 전체가 화면 안에 들어오게 해주세요',
      subtitle: '이마부터 턱까지 얼굴 전체가 잘리지 않게 맞춰주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_3.png',
      title: '조명과 각도를 안정적으로 맞춰주세요',
      subtitle: '너무 어둡거나 흔들리지 않도록 한 뒤 촬영을 시작해주세요.',
    ),
  ];

  void _goToPreviousSlide() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToNextSlide() {
    if (_currentPage >= _slides.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8CC63F) : const Color(0xFFD7E5BF),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        title: const Text(
          '빠른 분석',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _slides[index];
                              return _GuideImageSlide(
                                item: item,
                                showPrev: index > 0,
                                showNext: index < _slides.length - 1,
                                onPrev: _goToPreviousSlide,
                                onNext: _goToNextSlide,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF253041),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAEC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '빠른 분석도 촬영 전에 안내 3장을 확인한 뒤, 정면 사진 1장을 촬영해서 분석해요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF5F6B57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => _buildDot(index == _currentPage),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuickFaceCaptureScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CC63F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    '빠른 분석하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailedAnalysisIntroScreen extends StatefulWidget {
  const DetailedAnalysisIntroScreen({super.key});

  @override
  State<DetailedAnalysisIntroScreen> createState() =>
      _DetailedAnalysisIntroScreenState();
}

class _DetailedAnalysisIntroScreenState
    extends State<DetailedAnalysisIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideSlideData> _slides = const [
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_1.png',
      title: '정면 사진이 필요해요',
      subtitle: '얼굴을 정면으로 바라본 사진 1장을 먼저 촬영해주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_2.png',
      title: '왼쪽 사진이 필요해요',
      subtitle: '얼굴을 왼쪽 방향으로 돌린 사진을 촬영해주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_3.png',
      title: '오른쪽 사진이 필요해요',
      subtitle: '얼굴을 오른쪽 방향으로 돌린 사진을 촬영해주세요.',
    ),
  ];

  void _goToPreviousSlide() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToNextSlide() {
    if (_currentPage >= _slides.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8CC63F) : const Color(0xFFD7E5BF),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        title: const Text(
          '정밀 분석',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _slides[index];
                              return _GuideImageSlide(
                                item: item,
                                showPrev: index > 0,
                                showNext: index < _slides.length - 1,
                                onPrev: _goToPreviousSlide,
                                onNext: _goToNextSlide,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF253041),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => _buildDot(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAEC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '정면 · 왼쪽 · 오른쪽 사진 총 3장을 순서대로 촬영해서 분석해요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF5F6B57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FaceCaptureScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CC63F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    '정밀 분석하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientAnalysisIntroScreen extends StatefulWidget {
  const IngredientAnalysisIntroScreen({super.key});

  @override
  State<IngredientAnalysisIntroScreen> createState() =>
      _IngredientAnalysisIntroScreenState();
}

class _IngredientAnalysisIntroScreenState
    extends State<IngredientAnalysisIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideSlideData> _slides = const [
    _GuideSlideData(
      imagePath: 'assets/images/ingredient_guide_1.png',
      title: '수평을 맞춰 선명하게 찍어주세요',
      subtitle: '성분표가 또렷하게 보여야해요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/ingredient_guide_2.png',
      title: '큰 네모 가이드 안에 맞춰주세요',
      subtitle: '빛반사가 있으면 분석이 어려워요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/ingredient_guide_3.png',
      title: '전성분 항목이 꼭 포함되도록 찍어주세요',
      subtitle: '성분표 전체가 잘리지 않도록 촬영해주세요.',
    ),
  ];

  void _goToPreviousSlide() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToNextSlide() {
    if (_currentPage >= _slides.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8CC63F) : const Color(0xFFD7E5BF),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        title: const Text(
          '성분 분석',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _slides[index];
                              return _GuideImageSlide(
                                item: item,
                                showPrev: index > 0,
                                showNext: index < _slides.length - 1,
                                onPrev: _goToPreviousSlide,
                                onNext: _goToNextSlide,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF253041),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '화장품 성분표 1장을 촬영하면 챗봇이 분석해줘요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF7B664A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => _buildDot(index == _currentPage),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IngredientCaptureScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CC63F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    '성분 분석하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalColorIntroScreen extends StatefulWidget {
  const PersonalColorIntroScreen({super.key});

  @override
  State<PersonalColorIntroScreen> createState() =>
      _PersonalColorIntroScreenState();
}

class _PersonalColorIntroScreenState extends State<PersonalColorIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideSlideData> _slides = const [
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_1.png',
      title: '정면을 바라보고 촬영해주세요',
      subtitle: '얼굴이 정면으로 잘 보이도록 가이드에 맞춰 촬영해주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_2.png',
      title: '얼굴 전체가 화면 안에 들어오게 해주세요',
      subtitle: '이마부터 턱까지 얼굴 전체가 잘리지 않게 맞춰주세요.',
    ),
    _GuideSlideData(
      imagePath: 'assets/images/photo_guide_3.png',
      title: '조명과 각도를 안정적으로 맞춰주세요',
      subtitle: '너무 어둡거나 흔들리지 않도록 한 뒤 촬영을 시작해주세요.',
    ),
  ];

  void _goToPreviousSlide() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToNextSlide() {
    if (_currentPage >= _slides.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8CC63F) : const Color(0xFFD7E5BF),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        title: const Text(
          '퍼스널컬러',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _slides[index];
                              return _GuideImageSlide(
                                item: item,
                                showPrev: index > 0,
                                showNext: index < _slides.length - 1,
                                onPrev: _goToPreviousSlide,
                                onNext: _goToNextSlide,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF253041),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAEC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '퍼스널컬러 진단도 촬영 전에 안내 3장을 확인한 뒤, 정면 사진 1장을 촬영해서 분석해요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF5F6B57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => _buildDot(index == _currentPage),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuickFaceCaptureScreen(
                          isPersonalColorMode: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CC63F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    '퍼컬 진단하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideSlideData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _GuideSlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class _GuideImageSlide extends StatelessWidget {
  final _GuideSlideData item;
  final bool showPrev;
  final bool showNext;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _GuideImageSlide({
    required this.item,
    this.showPrev = false,
    this.showNext = false,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7FAF1),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F7E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 54,
                        color: Color(0xFF8CC63F),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (showPrev)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GuideArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: onPrev,
                ),
              ),
            ),
          if (showNext)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GuideArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: onNext,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GuideArrowButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: const Color(0xFFB8B8B8),
          ),
        ),
      ),
    );
  }
}