import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'quick_capture_review_screen.dart';
import 'package:flutter/services.dart';

const double _guideCenterX = 0.5;
const double _guideCenterY = 0.40;
const double _guideRadius = 0.40;

class QuickFaceCaptureScreen extends StatefulWidget {
  final bool isPersonalColorMode;

  const QuickFaceCaptureScreen({
    super.key,
    this.isPersonalColorMode = false,
  });

  @override
  State<QuickFaceCaptureScreen> createState() => _QuickFaceCaptureScreenState();
}

class _QuickFaceCaptureScreenState extends State<QuickFaceCaptureScreen> {
  CameraController? _controller;
  late final FaceDetector _faceDetector;

  bool _isInitializing = true;
  bool _isStreamProcessing = false;
  bool _isTakingPicture = false;
  String? _initError;

  bool _canCapture = false;
  String _guideMessage = '가이드 원 안에 얼굴을 맞춰주세요';
  Color _guideColor = const Color(0xFFFF5A5F);

  Offset? _lastFaceCenterNormalized;
  int _stableFrameCount = 0;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  String get _screenTitle =>
      widget.isPersonalColorMode ? '퍼스널컬러 촬영' : '빠른 진단 촬영';

  String get _screenStepTitle => '1/1 정면 촬영';

  String get _screenStepSubtitle => widget.isPersonalColorMode
      ? '정면 얼굴이 잘 보이도록 맞춰주세요'
      : '가이드 원 안에 얼굴을 맞춰주세요';

  String get _bottomTitle =>
      widget.isPersonalColorMode ? '정면을 바라봐주세요' : '정면을 바라봐주세요';

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableContours: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.15,
      ),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('사용 가능한 카메라가 없어요.');
      }

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
        Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      _controller = controller;
      await _startImageStream();

      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _initError = '카메라를 열 수 없어요.\n$e';
      });
    }
  }

  Future<void> _startImageStream() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isStreamingImages) return;

    await controller.startImageStream(_processCameraImage);
  }

  Future<void> _stopImageStream() async {
    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isStreamingImages) return;

    try {
      await controller.stopImageStream();
    } catch (_) {}
  }

  Future<void> _restartImageStream() async {
    try {
      await _startImageStream();
    } catch (_) {}
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isStreamProcessing || _isTakingPicture) return;

    final controller = _controller;
    if (controller == null || !mounted) return;

    _isStreamProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(cameraImage);

      if (inputImage == null) {
        _setGuideState(
          isValid: false,
          message: '카메라 프레임을 준비 중이에요',
          color: const Color(0xFFFF5A5F),
          resetStability: true,
        );
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isEmpty) {
        _setGuideState(
          isValid: false,
          message: '얼굴이 화면 안에 보이도록 맞춰주세요',
          color: const Color(0xFFFF5A5F),
          resetStability: true,
        );
        return;
      }

      if (faces.length > 1) {
        _setGuideState(
          isValid: false,
          message: '한 사람만 화면에 나오게 해주세요',
          color: const Color(0xFFFF5A5F),
          resetStability: true,
        );
        return;
      }

      final face = faces.first;
      final result = _evaluateLiveGuide(face, cameraImage);

      _setGuideState(
        isValid: result.isValid,
        message: result.message,
        color: result.color,
        resetStability: result.resetStability,
      );
    } catch (_) {
      if (!mounted) return;
      _setGuideState(
        isValid: false,
        message: '얼굴 인식 중입니다',
        color: const Color(0xFFFF5A5F),
        resetStability: true,
      );
    } finally {
      _isStreamProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;

    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }

      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.length != 1) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  _GuideResult _evaluateLiveGuide(Face face, CameraImage image) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final box = face.boundingBox;

    if (box.width <= 0 || box.height <= 0) {
      return _GuideResult.invalid('얼굴 위치를 다시 맞춰주세요');
    }

    final center = Offset(
      box.center.dx / imageWidth,
      box.center.dy / imageHeight,
    );

    final isInsideGuide = _isPointInsideCircle(
      point: center,
      circleCenter: const Offset(_guideCenterX, _guideCenterY),
      radius: _guideRadius,
    );

    if (!isInsideGuide) {
      return _GuideResult.invalid('가이드 원 안으로 얼굴을 맞춰주세요');
    }

    final widthRatio = box.width / imageWidth;
    final heightRatio = box.height / imageHeight;

    if (widthRatio < 0.11 || heightRatio < 0.15) {
      return _GuideResult.invalid('카메라에 조금 더 가까이 와주세요');
    }

    if (widthRatio > 0.95 || heightRatio > 0.98) {
      return _GuideResult.invalid('얼굴이 너무 가까워요. 조금만 뒤로 가주세요');
    }

    final roll = (face.headEulerAngleZ ?? 0).abs();
    if (roll > 22) {
      return _GuideResult.invalid('고개를 너무 기울이지 말아주세요');
    }

    final brightness = _estimateFaceBrightness(image, box);
    if (brightness < 40) {
      return _GuideResult.invalid('조금 더 밝은 곳에서 촬영해주세요');
    }

    final shadowDiff = _estimateFaceShadowDifference(image, box);
    if (shadowDiff > 70) {
      return _GuideResult.invalid('얼굴 그림자가 너무 강해요');
    }

    final yaw = (face.headEulerAngleY ?? 0).abs();
    if (yaw > 16) {
      return _GuideResult.invalid('정면을 바라봐주세요');
    }

    final stable = _updateStability(center);
    if (!stable) {
      return _GuideResult.invalid(
        '잠시만 가만히 있어주세요',
        resetStability: false,
      );
    }

    return _GuideResult.valid('좋아요. 촬영할 수 있어요');
  }

  bool _isPointInsideCircle({
    required Offset point,
    required Offset circleCenter,
    required double radius,
  }) {
    final dx = point.dx - circleCenter.dx;
    final dy = point.dy - circleCenter.dy;
    return (dx * dx + dy * dy) <= (radius * radius);
  }

  bool _updateStability(Offset center) {
    if (_lastFaceCenterNormalized == null) {
      _lastFaceCenterNormalized = center;
      _stableFrameCount = 1;
      return false;
    }

    final movement = (center - _lastFaceCenterNormalized!).distance;
    _lastFaceCenterNormalized = center;

    if (movement < 0.035) {
      _stableFrameCount += 1;
    } else {
      _stableFrameCount = 0;
    }

    return _stableFrameCount >= 2;
  }

  void _resetStability() {
    _lastFaceCenterNormalized = null;
    _stableFrameCount = 0;
  }

  void _setGuideState({
    required bool isValid,
    required String message,
    required Color color,
    required bool resetStability,
  }) {
    if (resetStability) {
      _resetStability();
    }

    if (!mounted) return;
    setState(() {
      _canCapture = isValid;
      _guideMessage = message;
      _guideColor = color;
    });
  }

  double _estimateFaceBrightness(CameraImage image, Rect faceBox) {
    final rect = _expandRect(
      faceBox,
      image.width.toDouble(),
      image.height.toDouble(),
      0.10,
    );
    return _sampleAverageLuma(image, rect);
  }

  double _estimateFaceShadowDifference(CameraImage image, Rect faceBox) {
    final rect = _expandRect(
      faceBox,
      image.width.toDouble(),
      image.height.toDouble(),
      0.04,
    );

    final leftRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.center.dx,
      rect.bottom,
    );

    final rightRect = Rect.fromLTRB(
      rect.center.dx,
      rect.top,
      rect.right,
      rect.bottom,
    );

    final leftAvg = _sampleAverageLuma(image, leftRect);
    final rightAvg = _sampleAverageLuma(image, rightRect);

    return (leftAvg - rightAvg).abs();
  }

  Rect _expandRect(
      Rect rect,
      double maxWidth,
      double maxHeight,
      double ratio,
      ) {
    final dx = rect.width * ratio;
    final dy = rect.height * ratio;

    return Rect.fromLTRB(
      (rect.left - dx).clamp(0.0, maxWidth - 1),
      (rect.top - dy).clamp(0.0, maxHeight - 1),
      (rect.right + dx).clamp(0.0, maxWidth - 1),
      (rect.bottom + dy).clamp(0.0, maxHeight - 1),
    );
  }

  double _sampleAverageLuma(CameraImage image, Rect rect) {
    final plane = image.planes.first;

    final left = rect.left.clamp(0.0, image.width - 1.0).toInt();
    final top = rect.top.clamp(0.0, image.height - 1.0).toInt();
    final right = rect.right.clamp(0.0, image.width - 1.0).toInt();
    final bottom = rect.bottom.clamp(0.0, image.height - 1.0).toInt();

    if (right <= left || bottom <= top) return 0;

    final sampleStepX = math.max(4, ((right - left) / 14).round());
    final sampleStepY = math.max(4, ((bottom - top) / 14).round());

    double sum = 0;
    int count = 0;

    for (int y = top; y <= bottom; y += sampleStepY) {
      for (int x = left; x <= right; x += sampleStepX) {
        sum += _lumaAt(
          image: image,
          plane: plane,
          x: x,
          y: y,
        );
        count++;
      }
    }

    if (count == 0) return 0;
    return sum / count;
  }

  double _lumaAt({
    required CameraImage image,
    required Plane plane,
    required int x,
    required int y,
  }) {
    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;

    if (Platform.isAndroid) {
      final index = y * bytesPerRow + x;
      if (index < 0 || index >= bytes.length) return 0;
      return bytes[index].toDouble();
    }

    final index = y * bytesPerRow + (x * 4);
    if (index < 0 || index + 2 >= bytes.length) return 0;

    final b = bytes[index].toDouble();
    final g = bytes[index + 1].toDouble();
    final r = bytes[index + 2].toDouble();

    return 0.114 * b + 0.587 * g + 0.299 * r;
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null) return;
    if (_isTakingPicture || !_canCapture) return;

    setState(() {
      _isTakingPicture = true;
      _canCapture = false;
      _guideMessage = '사진을 확인 중이에요';
    });

    try {
      await _stopImageStream();

      final file = await controller.takePicture();
      final check = await _validateCapturedPhoto(path: file.path);

      if (!check.isValid) {
        _showSnackBar(check.message);
        _resetStability();
        await _restartImageStream();

        if (!mounted) return;
        setState(() {
          _isTakingPicture = false;
          _guideMessage = check.message;
          _guideColor = const Color(0xFFFF5A5F);
          _canCapture = false;
        });
        return;
      }

      final normalizedPath = await _normalizeCapturedImage(file.path);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuickCaptureReviewScreen(
            imagePath: normalizedPath,
            isPersonalColorMode: widget.isPersonalColorMode,
          ),
        ),
      );
    } catch (_) {
      _showSnackBar('촬영에 실패했어요. 다시 시도해주세요');
      _resetStability();
      await _restartImageStream();

      if (!mounted) return;
      setState(() {
        _isTakingPicture = false;
        _guideMessage = '촬영에 실패했어요. 다시 시도해주세요';
        _guideColor = const Color(0xFFFF5A5F);
        _canCapture = false;
      });
    }
  }

  Future<_PhotoCheckResult> _validateCapturedPhoto({
    required String path,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return const _PhotoCheckResult.invalid('얼굴이 제대로 보이지 않아요. 다시 찍어주세요');
      }

      if (faces.length > 1) {
        return const _PhotoCheckResult.invalid('한 사람만 나오게 다시 찍어주세요');
      }

      final face = faces.first;
      final yaw = (face.headEulerAngleY ?? 0).abs();

      if (yaw > 16) {
        return const _PhotoCheckResult.invalid('정면 사진이 아니에요. 다시 찍어주세요');
      }

      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        return const _PhotoCheckResult.invalid('사진을 읽을 수 없어요. 다시 찍어주세요');
      }

      final resized =
      decoded.width > 720 ? img.copyResize(decoded, width: 720) : decoded;

      final avgBrightness = _estimateStillBrightness(resized);
      if (avgBrightness < 30) {
        return const _PhotoCheckResult.invalid('촬영된 사진이 조금 어두워요. 다시 찍어주세요');
      }

      final blurScore = _estimateSharpnessScore(resized);
      if (blurScore < 12) {
        return const _PhotoCheckResult.invalid('사진이 너무 흐려요. 다시 찍어주세요');
      }

      return const _PhotoCheckResult.valid();
    } catch (_) {
      return const _PhotoCheckResult.invalid('사진 검증 중 오류가 발생했어요. 다시 찍어주세요');
    }
  }

  Future<String> _normalizeCapturedImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return path;

      img.Image baked = img.bakeOrientation(decoded);

      if ((_controller?.description.lensDirection ?? CameraLensDirection.front) ==
          CameraLensDirection.front) {
        baked = img.flipHorizontal(baked);
      }

      final jpg = img.encodeJpg(baked, quality: 92);
      final normalizedPath = path.replaceFirst(RegExp(r'\.\w+$'), '_fixed.jpg');

      await File(normalizedPath).writeAsBytes(jpg, flush: true);
      return normalizedPath;
    } catch (_) {
      return path;
    }
  }

  double _estimateStillBrightness(img.Image image) {
    double sum = 0;
    int count = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final luma = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
        sum += luma;
        count++;
      }
    }

    if (count == 0) return 0;
    return sum / count;
  }

  double _estimateSharpnessScore(img.Image image) {
    final gray = img.grayscale(image);

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < gray.height - 1; y += 2) {
      for (int x = 1; x < gray.width - 1; x += 2) {
        final c = gray.getPixel(x, y).r.toDouble();
        final l = gray.getPixel(x - 1, y).r.toDouble();
        final r = gray.getPixel(x + 1, y).r.toDouble();
        final t = gray.getPixel(x, y - 1).r.toDouble();
        final b = gray.getPixel(x, y + 1).r.toDouble();

        final lap = (4 * c - l - r - t - b).abs();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 0;

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);
    return variance;
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller!;
    final size = MediaQuery.of(context).size;

    double scale = controller.value.aspectRatio * size.aspectRatio;
    if (scale < 1) {
      scale = 1 / scale;
    }

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildStepChip() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '정면',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final isEnabled = _canCapture && !_isTakingPicture;

    return GestureDetector(
      onTap: isEnabled ? _capture : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled ? Colors.white : const Color(0xFFE5E7EB),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isTakingPicture
              ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
              : Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? const Color(0xFFF4F4F5)
                  : const Color(0xFFD1D5DB),
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      controller.stopImageStream().catchError((_) {});
    }
    controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _initError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraPreview()),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: FaceGuideOverlayPainter(
                  guideColor: _guideColor,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isTakingPicture
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        child: Opacity(
                          opacity: _isTakingPicture ? 0.5 : 1,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF111827),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _screenStepTitle,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _screenTitle,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _screenStepSubtitle,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepChip(),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _bottomTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _guideMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _buildCaptureButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceGuideOverlayPainter extends CustomPainter {
  const FaceGuideOverlayPainter({
    required this.guideColor,
  });

  final Color guideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.white;

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final circleRect = Rect.fromCircle(
      center: Offset(size.width * _guideCenterX, size.height * _guideCenterY),
      radius: size.width * _guideRadius,
    );

    final holePath = Path()..addOval(circleRect);

    final path = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = guideColor;

    canvas.drawOval(circleRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant FaceGuideOverlayPainter oldDelegate) {
    return oldDelegate.guideColor != guideColor;
  }
}

class _GuideResult {
  final bool isValid;
  final String message;
  final Color color;
  final bool resetStability;

  const _GuideResult({
    required this.isValid,
    required this.message,
    required this.color,
    required this.resetStability,
  });

  factory _GuideResult.valid(String message) {
    return _GuideResult(
      isValid: true,
      message: message,
      color: const Color(0xFF32D583),
      resetStability: false,
    );
  }

  factory _GuideResult.invalid(
      String message, {
        bool resetStability = true,
      }) {
    return _GuideResult(
      isValid: false,
      message: message,
      color: const Color(0xFFFF5A5F),
      resetStability: resetStability,
    );
  }
}

class _PhotoCheckResult {
  final bool isValid;
  final String message;

  const _PhotoCheckResult({
    required this.isValid,
    required this.message,
  });

  const _PhotoCheckResult.valid()
      : isValid = true,
        message = '';

  const _PhotoCheckResult.invalid(this.message) : isValid = false;
}