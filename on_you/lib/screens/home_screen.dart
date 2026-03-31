import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import 'skin_mbti_test_screen.dart';
import 'skin_analysis_page.dart';
import '../store/wish_store.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onOpenQuickAnalysis;
  final VoidCallback? onOpenIngredientAnalysis;
  final VoidCallback? onOpenSkinResult;

  const HomeScreen({
    super.key,
    this.onTabSelected,
    this.onOpenQuickAnalysis,
    this.onOpenIngredientAnalysis,
    this.onOpenSkinResult,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: IgnorePointer(
            child: Container(
              color: const Color(0xFFF4F6F0),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeTopBar(),
                const SizedBox(height: 20),
                HeroBanner(
                  onTabSelected: onTabSelected,
                  onOpenQuickAnalysis: onOpenQuickAnalysis,
                  onOpenIngredientAnalysis: onOpenIngredientAnalysis,
                ),
                const SizedBox(height: 18),
                QuickMenuSection(
                  onTabSelected: onTabSelected,
                  onOpenIngredientAnalysis: onOpenIngredientAnalysis,
                  onOpenSkinResult: onOpenSkinResult,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/wish.png',
                      width: 45,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '나의 위시리스트',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ProductHorizontalList(
                  onMoreTap: () {
                    onTabSelected?.call(3);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/balloon_logo.png',
              height: 52,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class HeroBanner extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onOpenQuickAnalysis;
  final VoidCallback? onOpenIngredientAnalysis;

  const HeroBanner({
    super.key,
    this.onTabSelected,
    this.onOpenQuickAnalysis,
    this.onOpenIngredientAnalysis,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentPage = 0;
  bool _ready = false;

  final List<BannerItem> _banners = const [
    BannerItem(
      videoPath: 'assets/videos/skin_banner.mp4',
      buttonText: 'AI 피부 진단하기',
    ),
    BannerItem(
      videoPath: 'assets/videos/skin_banner2.mp4',
      buttonText: '챗봇 대화하기',
    ),
    BannerItem(
      videoPath: 'assets/videos/skin_banner3.mp4',
      buttonText: '스킨 MBTI 테스트',
    ),
    BannerItem(
      videoPath: 'assets/videos/skin_banner4.mp4',
      buttonText: '성분 분석하기',
    ),
  ];

  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initVideos();
  }

  Future<void> _initVideos() async {
    final controllers = _banners
        .map((banner) => VideoPlayerController.asset(banner.videoPath))
        .toList();

    for (final controller in controllers) {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
    }

    if (!mounted) {
      for (final controller in controllers) {
        controller.dispose();
      }
      return;
    }

    _controllers.addAll(controllers);
    await _controllers[_currentPage].play();

    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  void _changePage(int nextPage) {
    if (!_ready || _controllers.isEmpty) return;

    for (int i = 0; i < _controllers.length; i++) {
      if (i == nextPage) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }

    setState(() {
      _currentPage = nextPage;
    });
  }

  void _goPrev() {
    final nextPage = (_currentPage - 1 + _banners.length) % _banners.length;
    _changePage(nextPage);
  }

  void _goNext() {
    final nextPage = (_currentPage + 1) % _banners.length;
    _changePage(nextPage);
  }

  void _onBannerButtonTap(int index) {
    if (index == 0) {
      widget.onOpenQuickAnalysis?.call();
      return;
    }

    if (index == 1) {
      widget.onTabSelected?.call(2);
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SkinMbtiTestScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      widget.onOpenIngredientAnalysis?.call();
    }
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Container(
              color: const Color(0xFFE7DFCF),
            ),
            if (_ready)
              ...List.generate(_controllers.length, (index) {
                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: index != _currentPage,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOut,
                      opacity: index == _currentPage ? 1 : 0,
                      child: BannerCard(
                        controller: _controllers[index],
                        buttonText: _banners[index].buttonText,
                        onButtonTap: () => _onBannerButtonTap(index),
                        videoScale: index == 2
                            ? 1
                            : index == 3
                            ? 1.3
                            : 1.0,
                      ),
                    ),
                  ),
                );
              }),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _arrowButton(
                    icon: Icons.chevron_left,
                    onTap: _goPrev,
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(
                      _banners.length,
                          (index) => _buildDot(index == _currentPage),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _arrowButton(
                    icon: Icons.chevron_right,
                    onTap: _goNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerItem {
  final String videoPath;
  final String buttonText;

  const BannerItem({
    required this.videoPath,
    required this.buttonText,
  });
}

class BannerCard extends StatelessWidget {
  final VideoPlayerController controller;
  final String buttonText;
  final VoidCallback onButtonTap;
  final double videoScale;

  const BannerCard({
    super.key,
    required this.controller,
    required this.buttonText,
    required this.onButtonTap,
    this.videoScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BannerVideo(
            controller: controller,
            scale: videoScale,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.02),
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.20),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 66,
          child: Center(
            child: GestureDetector(
              onTap: onButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BannerVideo extends StatelessWidget {
  final VideoPlayerController controller;
  final double scale;

  const BannerVideo({
    super.key,
    required this.controller,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
        color: const Color(0xFFE7DFCF),
      );
    }

    return SizedBox.expand(
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickMenuSection extends StatelessWidget {
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onOpenIngredientAnalysis;
  final VoidCallback? onOpenSkinResult;

  const QuickMenuSection({
    super.key,
    this.onTabSelected,
    this.onOpenIngredientAnalysis,
    this.onOpenSkinResult,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> quickMenus = [
      {
        'image': 'assets/images/home/skin_analysis.png',
        'label': '피부 결과',
      },
      {
        'image': 'assets/images/home/ingredient_check.png',
        'label': '성분 분석',
      },
      {
        'image': 'assets/images/home/skin_mbti.png',
        'label': '피부 MBTI',
      },
      {
        'image': 'assets/images/home/wish.png',
        'label': '위시리스트',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickMenus.asMap().entries.map((entry) {
        final index = entry.key;
        final menu = entry.value;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  onOpenSkinResult?.call();
                } else if (index == 1) {
                  onOpenIngredientAnalysis?.call();
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkinMbtiTestScreen(),
                    ),
                  );
                } else if (index == 3) {
                  onTabSelected?.call(3);
                }
              },
              child: Column(
                children: [
                  Container(
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEF4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Image.asset(
                        menu['image'] as String,
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    menu['label'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class QuickMenuItem extends StatelessWidget {
  final String title;
  final String emoji;

  const QuickMenuItem({
    super.key,
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EEF4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 38),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title.zip  📁',
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        color: Color(0xFF111111),
      ),
    );
  }
}

class ProductHorizontalList extends StatelessWidget {
  final VoidCallback onMoreTap;

  const ProductHorizontalList({
    super.key,
    required this.onMoreTap,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('링크를 열 수 없습니다: $url');
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

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishStore.instance,
      builder: (context, _) {
        final items = WishStore.instance.items.take(5).toList();

        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
            child: Column(
              children: [
                const Text(
                  '저장된 위시리스트가 없어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onMoreTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E8E2E),
                    side: const BorderSide(color: Color(0xFFB9D989)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '위시리스트 보러가기',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...items.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAEC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFB9D989),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F3D3),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _labelForSource(item.source),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6E8E2E),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8F8F8F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _openUrl(item.url),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onMoreTap,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6E8E2E),
                  side: const BorderSide(color: Color(0xFFB9D989)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '더 보러가기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProductCardData {
  final String name;
  final String brand;
  final Color color;
  final IconData icon;

  const ProductCardData({
    required this.name,
    required this.brand,
    required this.color,
    required this.icon,
  });
}

class ProductCard extends StatelessWidget {
  final ProductCardData data;

  const ProductCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 86,
                height: 116,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  data.icon,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.brand,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8D8D8D),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}