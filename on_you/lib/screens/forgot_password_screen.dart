import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const double _fontScale = 1.1;

  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  double fs(double size) => size * _fontScale;

  InputDecoration _inputDecoration({
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: const Color(0xFFB6BCC6),
        fontSize: fs(13),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F6F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7ED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF8BC53F),
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _sendResetMail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가입한 이메일을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증 코드를 전송했어요.')),
    );
  }

  Widget _buildMascot() {
    return SizedBox(
      width: 98,
      height: 110,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 6,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 76,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BC53F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(36),
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _EyeDot(),
                      SizedBox(width: 8),
                      _EyeDot(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 39,
            child: Container(
              width: 5,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC53F),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 34,
            child: Container(
              width: 5,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC53F),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildMascot(),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE8ECEF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 22,
                                  color: Color(0xFF7B8492),
                                ),
                              ),
                            ),
                            Text(
                              '비밀번호 찾기',
                              style: TextStyle(
                                fontSize: fs(20),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF222222),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '가입한 이메일을 입력하시면 인증 코드를 보내드립니다.',
                          style: TextStyle(
                            fontSize: fs(13),
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7E8795),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          '이메일',
                          style: TextStyle(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5F6672),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  fontSize: fs(14),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF222222),
                                ),
                                decoration: _inputDecoration(
                                  hintText: '가입한 이메일 주소',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 78,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendResetMail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB9D98A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  '발송',
                                  style: TextStyle(
                                    fontSize: fs(12),
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
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '← 로그인으로 돌아가기',
                      style: TextStyle(
                        fontSize: fs(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF98A1AE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EyeDot extends StatelessWidget {
  const _EyeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}