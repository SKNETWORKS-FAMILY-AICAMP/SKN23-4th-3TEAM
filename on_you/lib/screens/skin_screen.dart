import 'package:flutter/material.dart';
import 'face_capture_screen.dart';

class SkinScreen extends StatelessWidget {
  const SkinScreen({super.key});

  void _startSkinAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FaceCaptureScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EFCB),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8CC63F).withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Icon(
                        Icons.center_focus_weak_rounded,
                        size: 36,
                        color: Color(0xFF7DBB2F),
                      ),
                      Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        size: 18,
                        color: Color(0xFF7DBB2F),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  '아직 피부 분석 결과가 없어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '앱 안에서 정면, 왼쪽, 오른쪽 얼굴을 촬영하면\nAI가 피부 상태를 분석해드려요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    children: const [
                      _GuideRow(
                        icon: Icons.looks_one_rounded,
                        text: '정면 얼굴 촬영',
                      ),
                      SizedBox(height: 12),
                      _GuideRow(
                        icon: Icons.looks_two_rounded,
                        text: '왼쪽 얼굴 촬영',
                      ),
                      SizedBox(height: 12),
                      _GuideRow(
                        icon: Icons.looks_3_rounded,
                        text: '오른쪽 얼굴 촬영',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 240,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _startSkinAnalysis(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8CC63F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      '카메라로 피부 분석 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '얼굴 위치와 밝기가 맞으면 초록색으로 안내돼요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuideRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF8CC63F),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}