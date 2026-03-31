import 'dart:io';

import 'package:flutter/material.dart';

import 'face_capture_screen.dart';
import 'main_shell.dart';

class CaptureReviewScreen extends StatelessWidget {
  final String frontPath;
  final String leftPath;
  final String rightPath;

  const CaptureReviewScreen({
    super.key,
    required this.frontPath,
    required this.leftPath,
    required this.rightPath,
  });

  void _goToMainShellChat(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShell(
          initialIndex: 2,
          autoStartDetailedAnalysis: true,
          autoFrontPath: frontPath,
          autoLeftPath: leftPath,
          autoRightPath: rightPath,
        ),
      ),
          (route) => false,
    );
  }

  void _retakePhotos(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const FaceCaptureScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final previewSize = ((screenWidth - 56) / 3).clamp(88.0, 112.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F3),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '촬영 사진 확인',
          style: TextStyle(
            color: Color(0xFF1F2A37),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A37)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 8),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '촬영한 사진으로 정밀 분석을 진행할까요?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF253041),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '사진이 마음에 들지 않으면 다시 촬영하고,\n괜찮으면 바로 정밀 분석을 시작할 수 있어요.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PreviewCard(
                              title: '정면',
                              imagePath: frontPath,
                              size: previewSize,
                            ),
                            const SizedBox(width: 10),
                            _PreviewCard(
                              title: '왼쪽',
                              imagePath: leftPath,
                              size: previewSize,
                            ),
                            const SizedBox(width: 10),
                            _PreviewCard(
                              title: '오른쪽',
                              imagePath: rightPath,
                              size: previewSize,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _retakePhotos(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFD1D5DB)),
                                foregroundColor: const Color(0xFF374151),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '다시 찍기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _goToMainShellChat(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8CC63F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '바로 정밀 분석',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final double size;

  const _PreviewCard({
    required this.title,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF253041),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}