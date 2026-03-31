import 'package:flutter/material.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const double _fontScale = 1.1;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController =
  TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordCheck = true;
  bool _isSubmitting = false;
  bool _isSendingEmailAuth = false;

  double fs(double size) => size * _fontScale;

  bool get _canSignup {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _passwordCheckController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty &&
        !_isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _passwordCheckController.addListener(_refresh);
    _nameController.addListener(_refresh);
    _nicknameController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
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
      suffixIcon: suffixIcon,
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: fs(12),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5F6672),
              ),
            ),
            if (required)
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: fs(12),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF08A8A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'On_You',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8BC53F),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '나만의 AI 피부 분석 서비스',
          style: TextStyle(
            fontSize: fs(12),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8F98A6),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8BC53F).withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmailAuth() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 먼저 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSendingEmailAuth = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isSendingEmailAuth = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증 메일을 발송했어요.')),
    );
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordCheck = _passwordCheckController.text.trim();
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        passwordCheck.isEmpty ||
        name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')),
      );
      return;
    }

    if (password != passwordCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않아요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    final appliedNickname = nickname.isEmpty ? name : nickname;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('회원가입이 완료되었어요. 닉네임: $appliedNickname'),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_refresh);
    _passwordController.removeListener(_refresh);
    _passwordCheckController.removeListener(_refresh);
    _nameController.removeListener(_refresh);
    _nicknameController.removeListener(_refresh);

    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupButtonColor =
    _canSignup ? const Color(0xFF8BC53F) : const Color(0xFFD7DBE1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '계정 정보 입력',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fs(20),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _label('이메일', required: true),
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
                                  hintText: '이메일 주소',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 104,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                _isSendingEmailAuth ? null : _sendEmailAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB9D98A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isSendingEmailAuth
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  '인증발송',
                                  style: TextStyle(
                                    fontSize: fs(12),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _label('비밀번호', required: true),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                          decoration: _inputDecoration(
                            hintText: '비밀번호',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: const Color(0xFF9AA1AD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('비밀번호 확인', required: true),
                        TextField(
                          controller: _passwordCheckController,
                          obscureText: _obscurePasswordCheck,
                          style: TextStyle(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                          decoration: _inputDecoration(
                            hintText: '비밀번호 재입력',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePasswordCheck =
                                  !_obscurePasswordCheck;
                                });
                              },
                              icon: Icon(
                                _obscurePasswordCheck
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: const Color(0xFF9AA1AD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('이름', required: true),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                          decoration: _inputDecoration(
                            hintText: '실명 입력',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('닉네임'),
                        TextField(
                          controller: _nicknameController,
                          style: TextStyle(
                            fontSize: fs(14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                          decoration: _inputDecoration(
                            hintText: '닉네임 (선택, 미입력 시 이름으로 설정)',
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _canSignup ? _signup : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: signupButtonColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor:
                              const Color(0xFFD7DBE1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              '가입하기',
                              style: TextStyle(
                                fontSize: fs(15),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '이미 계정이 있으신가요?',
                        style: TextStyle(
                          fontSize: fs(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9AA1AD),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: fs(12),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF8BC53F),
                          ),
                        ),
                      ),
                    ],
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