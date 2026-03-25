import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_shell.dart';
import 'quick_face_capture_screen.dart';

class QuickCaptureReviewScreen extends StatefulWidget {
  final String imagePath;
  final bool isPersonalColorMode;

  const QuickCaptureReviewScreen({
    super.key,
    required this.imagePath,
    this.isPersonalColorMode = false,
  });

  @override
  State<QuickCaptureReviewScreen> createState() =>
      _QuickCaptureReviewScreenState();
}

class _QuickCaptureReviewScreenState extends State<QuickCaptureReviewScreen> {
  bool _isSubmitting = false;

  String get _screenTitle =>
      widget.isPersonalColorMode ? '퍼스널컬러 사진 확인' : '빠른 분석 사진 확인';

  String get _descriptionText => widget.isPersonalColorMode
      ? '촬영한 사진을 확인한 뒤\n다시 찍거나 바로 퍼스널컬러 진단을 시작할 수 있어요'
      : '촬영한 사진을 확인한 뒤\n다시 찍거나 바로 분석을 시작할 수 있어요';

  String get _guideText => widget.isPersonalColorMode
      ? '정면 얼굴이 잘 보이면 바로 진단하기를 눌러주세요'
      : '정면 얼굴이 잘 보이면 바로 분석하기를 눌러주세요';

  String get _startButtonText =>
      widget.isPersonalColorMode ? '이 사진으로 진단하기' : '이 사진으로 분석하기';

  String get _moveErrorText => widget.isPersonalColorMode
      ? '퍼스널컬러 진단 화면으로 이동하지 못했어요.'
      : '빠른 분석 화면으로 이동하지 못했어요.';

  Future<void> _goToRetake() async {
    if (_isSubmitting) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuickFaceCaptureScreen(
          isPersonalColorMode: widget.isPersonalColorMode,
        ),
      ),
    );
  }

  Future<void> _startAnalysis() async {
    if (_isSubmitting) return;

    final imageFile = File(widget.imagePath);
    final hasImage = imageFile.existsSync();

    if (!hasImage) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사진을 불러올 수 없어요. 다시 촬영해주세요.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => widget.isPersonalColorMode
              ? MainShell(
            initialIndex: 2,
            autoStartPersonalColorAnalysis: true,
            autoPersonalColorImagePath: widget.imagePath,
          )
              : MainShell(
            initialIndex: 2,
            autoStartQuickAnalysis: true,
            autoQuickImagePath: widget.imagePath,
          ),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_moveErrorText\n$e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(widget.imagePath);
    final hasImage = imageFile.existsSync();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F3),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 360 ? 272.0 : 290.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 14, 0),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: _isSubmitting
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF1F2A37),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _screenTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F2A37),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _descriptionText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: cardWidth,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(22),
                                          child: hasImage
                                              ? Image.file(
                                            imageFile,
                                            fit: BoxFit.cover,
                                          )
                                              : Container(
                                            color:
                                            const Color(0xFFF1F5F9),
                                            alignment: Alignment.center,
                                            child: const Column(
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .broken_image_outlined,
                                                  size: 38,
                                                  color:
                                                  Color(0xFF94A3B8),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '사진을 불러올 수 없어요',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w700,
                                                    color: Color(
                                                        0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                              EdgeInsets.only(top: 1),
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                size: 18,
                                                color: Color(0xFF8BC53F),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _guideText,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF4B5563),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _isSubmitting ? null : _goToRetake,
                                      child: Opacity(
                                        opacity: _isSubmitting ? 0.6 : 1,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(18),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '다시 찍기',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: (!_isSubmitting && hasImage)
                                          ? _startAnalysis
                                          : null,
                                      child: Opacity(
                                        opacity:
                                        (!_isSubmitting && hasImage) ? 1 : 0.55,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8BC53F),
                                            borderRadius:
                                            BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF8BC53F)
                                                    .withOpacity(0.28),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: _isSubmitting
                                              ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white,
                                            ),
                                          )
                                              : Text(
                                            _startButtonText,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isSubmitting)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}