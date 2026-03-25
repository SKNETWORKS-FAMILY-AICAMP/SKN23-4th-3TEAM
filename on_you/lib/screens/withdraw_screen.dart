import 'package:flutter/material.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _controller = TextEditingController();

  bool get _canSubmit => _controller.text.trim() == '회원탈퇴';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmWithdraw() async {
    if (!_canSubmit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '회원 탈퇴',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '정말 회원 탈퇴를 진행하시겠어요?\n\n현재 코드는 UI만 연결되어 있고,\n실제 탈퇴 API 연동은 따로 붙여야 합니다.',
            style: TextStyle(height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF08C92),
              ),
              child: const Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('회원탈퇴 UI까지 연결되었고, 실제 탈퇴 API는 추가 연동이 필요합니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF4CFCF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원 탈퇴',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '회원 탈퇴를 진행하면 계정이 탈퇴 상태로 전환되며, 탈퇴 후 10일이 지나면 관련 데이터가 완전히 삭제됩니다.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF5D1D1)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '탈퇴 전 확인해 주세요',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• 탈퇴 후 10일 이내에는 다시 로그인하면 계정이 복구될 수 있습니다.\n'
                            '• 탈퇴 후 10일이 지나면 계정과 관련 이미지 및 데이터가 완전히 삭제됩니다.\n'
                            '• 완전 삭제 이후에는 계정을 복구할 수 없습니다.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.8,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '확인을 위해 회원탈퇴를 입력해 주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '회원탈퇴',
                    hintStyle: const TextStyle(
                      color: Color(0xFFB7BFCC),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFD9DEE7)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFF08C92)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _confirmWithdraw : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF08C92),
                        disabledBackgroundColor: const Color(0xFFF5C9CC),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                      child: const Text(
                        '회원 탈퇴',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
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
    );
  }
}