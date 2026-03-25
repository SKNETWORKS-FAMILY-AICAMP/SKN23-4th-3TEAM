import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../store/profile_image_store.dart';
import 'skin_analysis_page.dart';
import 'skin_mbti_test_screen.dart';

import 'faq_screen.dart';
import 'inquiry_screen.dart';
import 'withdraw_screen.dart';

const Map<int, String> _skinTypeCodeToLabel = {
  16: '건성',
  17: '지성',
  18: '민감성',
  19: '복합성',
  20: '중성',
};

const Map<String, int> _skinTypeLabelToApiValue = {
  '건성': 16,
  '지성': 17,
  '민감성': 18,
  '복합성': 19,
  '중성': 20,
};

const Map<int, String> _concernCodeToBackendLabel = {
  21: '아토피',
  22: '안티에이징',
  23: '미백',
  24: '보습',
  25: '여드름',
  26: '민감',
  27: '피부장벽',
  28: '모공',
  29: '탈모',
  30: '감염',
  31: '가려움',
  32: '홍조',
  33: '자극',
  34: '건조',
  35: '유분',
  36: '각질',
  37: '붓기',
  38: '피부톤',
  39: '주사',
  40: '블랙헤드',
  41: '화이트헤드',
  42: '피지',
};

const Map<String, String> _concernBackendToDisplayLabel = {
  '여드름': '트러블',
  '피부장벽': '장벽',
  '안티에이징': '주름',
  '유분': '피지',
};

const Map<String, String> _concernDisplayToBackendLabel = {
  '트러블': '여드름',
  '장벽': '피부장벽',
  '주름': '안티에이징',
  '피지': '유분',
};

String _stringOf(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;

  final text = value.toString().trim();
  if (text.isEmpty ||
      text.toLowerCase() == 'null' ||
      text.toLowerCase() == 'string' ||
      text.toLowerCase() == 'none') {
    return fallback;
  }

  return text;
}

bool _isValidRemoteImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;

  final parsed = Uri.tryParse(url.trim());
  if (parsed == null) return false;

  return (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.host.isNotEmpty;
}

String _genderLabelFromApi(dynamic value) {
  final raw = _stringOf(value).toLowerCase();

  switch (raw) {
    case 'male':
    case 'm':
    case 'man':
    case '남':
    case '남성':
      return '남성';
    case 'female':
    case 'f':
    case 'woman':
    case '여':
    case '여성':
    default:
      return '여성';
  }
}

String _genderApiValue(String label) {
  switch (label) {
    case '남성':
      return 'male';
    case '여성':
    default:
      return 'female';
  }
}

String _skinTypeLabelFromApi(dynamic value) {
  if (value == null) return '미설정';

  if (value is int) {
    return _skinTypeCodeToLabel[value] ?? '미설정';
  }

  final text = _stringOf(value);
  if (text.isEmpty) return '미설정';

  final parsed = int.tryParse(text);
  if (parsed != null) {
    return _skinTypeCodeToLabel[parsed] ?? '미설정';
  }

  if (_skinTypeLabelToApiValue.containsKey(text)) {
    return text;
  }

  return '미설정';
}

String _displayConcernLabelFromApi(dynamic value) {
  if (value == null) return '';

  if (value is int) {
    final backendLabel = _concernCodeToBackendLabel[value];
    if (backendLabel == null) return '';
    return _concernBackendToDisplayLabel[backendLabel] ?? backendLabel;
  }

  final text = _stringOf(value);
  if (text.isEmpty) return '';

  final parsed = int.tryParse(text);
  if (parsed != null) {
    final backendLabel = _concernCodeToBackendLabel[parsed];
    if (backendLabel == null) return '';
    return _concernBackendToDisplayLabel[backendLabel] ?? backendLabel;
  }

  return _concernBackendToDisplayLabel[text] ?? text;
}

String _backendConcernLabelFromDisplay(String label) {
  return _concernDisplayToBackendLabel[label] ?? label;
}

List<String> _concernsFromApi(dynamic value) {
  final result = <String>{};

  void addOne(dynamic item) {
    final mapped = _displayConcernLabelFromApi(item);
    if (mapped.isNotEmpty) {
      result.add(mapped);
    }
  }

  if (value == null) return <String>[];

  if (value is List) {
    for (final item in value) {
      addOne(item);
    }
    return result.toList();
  }

  final text = value.toString().trim();
  if (text.isEmpty) return <String>[];

  final parts = text.split(RegExp(r'[,/\n]'));
  for (final part in parts) {
    addOne(part.trim());
  }

  return result.toList();
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _defaultProfileAsset = 'assets/images/profile.png';

  bool _pushNotification = true;
  bool _marketingNotification = false;
  bool _isLoadingProfile = true;

  String _nickname = '';
  String _name = '';
  String _email = '';
  String _gender = '여성';
  String _age = '';
  String _skinType = '미설정';
  dynamic _skinTypeRawValue;
  List<String> _skinConcerns = [];

  Uint8List? _profileImageBytes;
  String? _profileImageUrl;

  Set<String> _linkedProviders = <String>{};

  final List<_SocialProvider> _providers = const [
    _SocialProvider(
      id: 'kakao',
      label: '카카오',
      badgeColor: Color(0xFFFEE500),
      textColor: Color(0xFF3C1E1E),
      assetPath: 'assets/social/kakao.png',
    ),
    _SocialProvider(
      id: 'google',
      label: '구글',
      badgeColor: Colors.white,
      textColor: Color(0xFF4285F4),
      assetPath: 'assets/social/google.png',
    ),
    _SocialProvider(
      id: 'naver',
      label: '네이버',
      badgeColor: Color(0xFF03C75A),
      textColor: Colors.white,
      assetPath: 'assets/social/naver.png',
    ),
  ];

  static const String _dummyTermsText = '''
제1조 (목적)
본 약관은 서비스 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (서비스 내용)
회사는 피부 분석, 피부 MBTI 검사, 제품 추천 등 다양한 뷰티 관련 서비스를 제공합니다.

제3조 (이용자의 의무)
이용자는 관련 법령과 본 약관을 준수해야 하며, 서비스의 정상 운영을 방해하는 행위를 해서는 안 됩니다.

제4조 (서비스 이용 제한)
회사는 시스템 점검, 장애, 기타 운영상 필요에 따라 서비스 제공을 일시적으로 제한할 수 있습니다.

제5조 (면책)
회사는 천재지변, 불가항력, 이용자 귀책 사유로 인한 손해에 대해 책임을 지지 않습니다.
''';

  static const String _dummyPrivacyText = '''
1. 수집하는 개인정보 항목
회사는 회원가입, 서비스 제공, 고객 문의 대응을 위해 닉네임, 이메일, 프로필 이미지 등의 정보를 수집할 수 있습니다.

2. 개인정보의 이용 목적
수집한 개인정보는 회원 식별, 맞춤형 서비스 제공, 고객 지원, 서비스 개선을 위해 사용됩니다.

3. 개인정보의 보관 및 파기
회사는 수집 목적이 달성된 후 관련 법령에 따라 필요한 기간 동안 정보를 보관한 뒤 안전하게 파기합니다.

4. 개인정보의 제3자 제공
회사는 이용자의 동의 없이 개인정보를 외부에 제공하지 않습니다. 단, 법령에 따른 경우는 예외로 합니다.

5. 이용자의 권리
이용자는 언제든지 자신의 개인정보를 조회, 수정, 삭제 요청할 수 있습니다.
''';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Set<String> _linkedProvidersFromApi(Map<String, dynamic> me) {
    final result = <String>{};

    void addProvider(dynamic raw) {
      final value = _stringOf(raw).toLowerCase();
      if (value.contains('kakao')) result.add('kakao');
      if (value.contains('google')) result.add('google');
      if (value.contains('naver')) result.add('naver');
    }

    final linkedProviders = me['linked_providers'];
    if (linkedProviders is List) {
      for (final item in linkedProviders) {
        addProvider(item);
      }
    }

    addProvider(me['provider']);
    addProvider(me['social_provider']);
    addProvider(me['provider_type']);
    addProvider(me['login_type']);

    return result;
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoadingProfile = true;
      });

      final me = await ApiService.getMe();

      final nickname = _stringOf(me['nickname'], fallback: '사용자');
      final email = _stringOf(me['email']);
      final name = _stringOf(me['name'], fallback: nickname);
      final gender = _genderLabelFromApi(me['gender']);
      final age = _stringOf(me['age']);
      final skinTypeRaw = me['skin_type'];
      final skinType = _skinTypeLabelFromApi(skinTypeRaw);
      final concerns = _concernsFromApi(
        me['skin_concern'] ?? me['skin_concerns'],
      );
      final profileImageUrl = _stringOf(me['profile_image_url']);
      final linkedProviders = _linkedProvidersFromApi(me);

      print('GET /users/me raw: $me');
      print('GET /users/me profile_image_url: $profileImageUrl');

      if (!mounted) return;

      setState(() {
        _nickname = nickname;
        _name = name;
        _email = email;
        _gender = gender;
        _age = age;
        _skinTypeRawValue = skinTypeRaw;
        _skinType = skinType;
        _skinConcerns = concerns;
        _profileImageUrl = profileImageUrl.isEmpty ? null : profileImageUrl;
        _linkedProviders = linkedProviders;
        _isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('설정 정보 불러오기 실패: $e')),
      );
    }
  }

  Future<void> _openProfileDetail() async {
    final result = await Navigator.push<ProfileEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailScreen(
          nickname: _nickname,
          name: _name,
          email: _email,
          gender: _gender,
          age: _age,
          skinType: _skinType,
          skinTypeRawValue: _skinTypeRawValue,
          skinConcerns: _skinConcerns,
          profileImageBytes: _profileImageBytes,
          profileImageUrl: _profileImageUrl,
          defaultProfileAsset: _defaultProfileAsset,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _nickname = result.nickname;
      _gender = result.gender;
      _age = result.age;
      _skinType = result.skinType;
      _skinTypeRawValue = result.skinTypeRawValue;
      _skinConcerns = result.skinConcerns;
      _profileImageBytes = result.profileImageBytes;
      _profileImageUrl = result.profileImageUrl;
    });

    ProfileImageStore.imageBytes.value = result.profileImageBytes;
  }

  void _openSocialLinkSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D7D7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '소셜 연동',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _linkedProviders.isEmpty
                        ? '현재 API 응답에 연동 정보가 없어서 미연동으로 표시되고 있어요.'
                        : '현재 소셜 계정 연동 상태를 확인할 수 있어요.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ..._providers.map(
                      (provider) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSocialConnectTile(provider),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPolicyPage({
    required String title,
    required String content,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PolicyDetailScreen(
          title: title,
          content: content,
        ),
      ),
    );
  }

  Widget _buildMbtiLogo() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'MBTI',
          style: TextStyle(
            fontSize: 9.4,
            fontWeight: FontWeight.w900,
            color: Color(0xFF222222),
            letterSpacing: -0.2,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteProfileImage({
    required String imageUrl,
    required double width,
    required double height,
    required Widget fallback,
  }) {
    final encodedUrl = Uri.encodeFull(imageUrl);

    return Image.network(
      encodedUrl,
      key: ValueKey(encodedUrl),
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF4F4F4),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF8BC53F),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('프로필 이미지 로드 실패: $error');
        print('실패 URL: $encodedUrl');
        return fallback;
      },
    );
  }

  Widget _buildSocialConnectTile(_SocialProvider provider) {
    final isLinked = _linkedProviders.contains(provider.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLinked
              ? const Color(0xFFD9EDBC)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _SocialLogo(provider: provider, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLinked ? '계정이 연동되어 있어요' : '아직 연동되지 않았어요',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLinked
                  ? const Color(0xFFEAF6D9)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLinked
                      ? Icons.check_circle_rounded
                      : Icons.remove_circle_outline_rounded,
                  size: 16,
                  color: isLinked
                      ? const Color(0xFF78B52A)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  isLinked ? '연동됨' : '미연동',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLinked
                        ? const Color(0xFF5E8E1C)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(double size, Border border) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _defaultProfileAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFFF4F4F4),
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              size: size * 0.5,
              color: const Color(0xFFAAAAAA),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(double size) {
    final border = Border.all(
      color: const Color(0xFFE7E7E7),
      width: 1,
    );

    final fallback = _buildDefaultAvatar(size, border);

    if (_profileImageBytes != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          _profileImageBytes!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_isValidRemoteImageUrl(_profileImageUrl)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildRemoteProfileImage(
          imageUrl: _profileImageUrl!,
          width: size,
          height: size,
          fallback: fallback,
        ),
      );
    }

    return fallback;
  }

  Widget _buildCompactSocialLogos() {
    final linked = _providers
        .where((provider) => _linkedProviders.contains(provider.id))
        .toList();

    if (linked.isEmpty) {
      return const Text(
        '없음',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF999999),
        ),
      );
    }

    return SizedBox(
      width: linked.length * 30.0 + 8,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(linked.length, (index) {
          final provider = linked[index];
          return Positioned(
            left: index * 24.0,
            child: _SocialLogo(
              provider: provider,
              size: 30,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
                height: 1.0,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.95,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8BC53F),
              activeTrackColor: const Color(0xFFCBE69A),
              inactiveThumbColor: const Color(0xFF7D7D6E),
              inactiveTrackColor: const Color(0xFFE6E3D8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile({
    IconData? icon,
    Widget? leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: leading ??
                      Icon(
                        icon,
                        size: 22,
                        color: const Color(0xFF444444),
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFAAAAAA),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    IconData? icon,
    Widget? leading,
    required String title,
    required String value,
  }) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: leading ??
                  Icon(
                    icon,
                    size: 22,
                    color: const Color(0xFF444444),
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
                height: 1.0,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F3F3),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8BC53F),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF8BC53F),
          onRefresh: _loadSettings,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    size: 22,
                    color: Color(0xFF8CC63F),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openProfileDetail,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileAvatar(58),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '프로필',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8A8A8A),
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _nickname,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF222222),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFAAAAAA),
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openSocialLinkSheet,
                child: Container(
                  height: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(
                          child: Icon(
                            Icons.link_rounded,
                            size: 22,
                            color: Color(0xFF444444),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          '소셜 연동',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                            height: 1.0,
                          ),
                        ),
                      ),
                      _buildCompactSocialLogos(),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFAAAAAA),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                '앱 설정',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                icon: Icons.notifications_none_rounded,
                title: ' 이벤트/마케팅알림',
                value: _pushNotification,
                onChanged: (value) {
                  setState(() => _pushNotification = value);
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                leading: _buildMbtiLogo(),
                title: '피부 MBTI',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkinMbtiTestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                icon: Icons.analytics_outlined,
                title: '피부 분석 결과',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SkinAnalysisPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),
              const Text(
                '고객 지원',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              _buildArrowTile(
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FaqScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: '고객 문의',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InquiryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                icon: Icons.person_remove_alt_1_outlined,
                title: '회원 탈퇴',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WithdrawScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () {
                  _openPolicyPage(
                    title: '이용약관',
                    content: _dummyTermsText,
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildArrowTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () {
                  _openPolicyPage(
                    title: '개인정보처리방침',
                    content: _dummyPrivacyText,
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                title: '버전 정보',
                value: '1.0',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileEditResult {
  final String nickname;
  final String gender;
  final String age;
  final String skinType;
  final dynamic skinTypeRawValue;
  final List<String> skinConcerns;
  final Uint8List? profileImageBytes;
  final String? profileImageUrl;

  const ProfileEditResult({
    required this.nickname,
    required this.gender,
    required this.age,
    required this.skinType,
    required this.skinTypeRawValue,
    required this.skinConcerns,
    required this.profileImageBytes,
    required this.profileImageUrl,
  });
}

class ProfileDetailScreen extends StatefulWidget {
  final String nickname;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String skinType;
  final dynamic skinTypeRawValue;
  final List<String> skinConcerns;
  final Uint8List? profileImageBytes;
  final String? profileImageUrl;
  final String defaultProfileAsset;

  const ProfileDetailScreen({
    super.key,
    required this.nickname,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.skinType,
    required this.skinTypeRawValue,
    required this.skinConcerns,
    required this.profileImageBytes,
    required this.profileImageUrl,
    required this.defaultProfileAsset,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nicknameController;
  late final TextEditingController _ageController;

  late String _gender;
  late String _skinType;
  late List<String> _selectedConcerns;

  Uint8List? _profileImageBytes;
  String? _profileImageUrl;

  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable;
  String? _nicknameCheckMessage;
  bool _isSaving = false;

  final List<String> _genderOptions = ['여성', '남성'];

  final List<String> _skinTypeOptions = const [
    '건성',
    '지성',
    '민감성',
    '복합성',
    '중성',
  ];

  final List<String> _baseConcernOptions = const [
    '각질',
    '건조',
    '모공',
    '미백',
    '민감',
    '블랙헤드',
    '화이트헤드',
    '아토피',
    '피지',
    '장벽',
    '주름',
    '트러블',
    '보습',
    '홍조',
    '자극',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.nickname);
    _ageController = TextEditingController(text: widget.age);
    _gender = widget.gender;
    _skinType = widget.skinType;
    _selectedConcerns = List<String>.from(widget.skinConcerns);
    _profileImageBytes = widget.profileImageBytes;
    _profileImageUrl = widget.profileImageUrl;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }

  int? _skinTypeApiValueForSave() {
    if (_skinType == widget.skinType) {
      return _tryParseInt(widget.skinTypeRawValue);
    }
    return _skinTypeLabelToApiValue[_skinType];
  }

  Future<void> _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _isNicknameAvailable = false;
        _nicknameCheckMessage = '닉네임을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isCheckingNickname = true;
      _nicknameCheckMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    const duplicatedNicknames = ['관리자', 'admin', 'test'];

    final isAvailable =
        nickname == widget.nickname || !duplicatedNicknames.contains(nickname);

    setState(() {
      _isCheckingNickname = false;
      _isNicknameAvailable = isAvailable;
      _nicknameCheckMessage =
      isAvailable ? '사용 가능한 닉네임입니다.' : '이미 사용 중인 닉네임입니다.';
    });
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _profileImageBytes = bytes;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('사진은 현재 앱 화면에 먼저 반영돼요. 서버 업로드 API가 있으면 영구 저장도 연결할 수 있어요.'),
      ),
    );
  }

  Future<void> _patchProfile() async {
    final nickname = _nicknameController.text.trim().isEmpty
        ? widget.nickname
        : _nicknameController.text.trim();

    final ageValue = int.tryParse(_ageController.text.trim());
    final skinTypeValue = _skinTypeApiValueForSave();

    final headers = await AuthService.authHeaders();
    final uri = ApiConfig.uri('/users/me');

    final body = <String, dynamic>{
      'nickname': nickname,
      'gender': _genderApiValue(_gender),
      'skin_concern':
      _selectedConcerns.map(_backendConcernLabelFromDisplay).join(','),
      if (ageValue != null) 'age': ageValue,
      if (skinTypeValue != null) 'skin_type': skinTypeValue,
      if (_isValidRemoteImageUrl(_profileImageUrl))
        'profile_image_url': _profileImageUrl,
    };

    final response = await http.patch(
      uri,
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        '내 정보 수정 실패\n'
            '상태코드: ${response.statusCode}\n'
            '응답: ${response.body}',
      );
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim().isEmpty
        ? widget.nickname
        : _nicknameController.text.trim();

    if (_isNicknameAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용 가능한 닉네임으로 변경해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await _patchProfile();

      ProfileImageStore.imageBytes.value = _profileImageBytes;

      if (!mounted) return;

      Navigator.pop(
        context,
        ProfileEditResult(
          nickname: nickname,
          gender: _gender,
          age: _ageController.text.trim().isEmpty
              ? widget.age
              : _ageController.text.trim(),
          skinType: _skinType,
          skinTypeRawValue: _skinTypeApiValueForSave(),
          skinConcerns: _selectedConcerns,
          profileImageBytes: _profileImageBytes,
          profileImageUrl: _profileImageUrl,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D7D7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPickerOption(
                  icon: Icons.photo_library_outlined,
                  title: '갤러리에서 선택',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickProfileImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                _buildPickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: '카메라로 촬영',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickProfileImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGenderSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D7D7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '성별 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._genderOptions.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _gender = item;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _gender == item
                              ? const Color(0xFFF2F8E8)
                              : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _gender == item
                                ? const Color(0xFF8BC53F)
                                : const Color(0xFFE2E2E2),
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _gender == item
                                ? const Color(0xFF6EA62C)
                                : const Color(0xFF222222),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddConcernDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ConcernInputDialog(),
    );

    if (!mounted || result == null) return;

    final items = result
        .split(RegExp(r'[,/\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (items.isEmpty) return;

    setState(() {
      for (final item in items) {
        if (!_selectedConcerns.contains(item)) {
          _selectedConcerns.add(item);
        }
      }
    });
  }

  void _toggleConcern(String concern) {
    setState(() {
      if (_selectedConcerns.contains(concern)) {
        _selectedConcerns.remove(concern);
      } else {
        _selectedConcerns.add(concern);
      }
    });
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF444444)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProfileBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        widget.defaultProfileAsset,
        width: 86,
        height: 86,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 86,
            height: 86,
            color: const Color(0xFFF4F4F4),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              size: 34,
              color: Color(0xFFAAAAAA),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePreview() {
    if (_profileImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          _profileImageBytes!,
          width: 86,
          height: 86,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_isValidRemoteImageUrl(_profileImageUrl)) {
      final encodedUrl = Uri.encodeFull(_profileImageUrl!);

      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          encodedUrl,
          key: ValueKey(encodedUrl),
          width: 86,
          height: 86,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 86,
              height: 86,
              color: const Color(0xFFF4F4F4),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8BC53F),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('상세 화면 프로필 이미지 로드 실패: $error');
            print('상세 화면 실패 URL: $encodedUrl');
            return _buildDefaultProfileBox();
          },
        ),
      );
    }

    return _buildDefaultProfileBox();
  }

  Widget _buildProfileInfoLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF22324A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF4B5563),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8DDE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8BC53F)),
        ),
      ),
    );
  }

  Widget _buildSelectField({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD8DDE5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF122033),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerTitle(String title) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool showCheck = false,
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8BC53F) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF8BC53F)
                : const Color(0xFFD6DCE3),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheck && selected) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
            ],
            if (isAdd) ...[
              Icon(
                Icons.add_rounded,
                size: 16,
                color: selected ? Colors.white : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (isAdd
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF445163)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customConcerns = _selectedConcerns
        .where((item) => !_baseConcernOptions.contains(item))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          '내 정보',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '프로필',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8BC53F),
                                width: 1.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildProfilePreview(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: const Text(
                            '사진 변경',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8BC53F),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileInfoLine(
                              '닉네임',
                              _nicknameController.text.trim().isEmpty
                                  ? widget.nickname
                                  : _nicknameController.text.trim(),
                            ),
                            const SizedBox(height: 14),
                            _buildProfileInfoLine('이메일', widget.email),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _buildDividerTitle('기본 정보'),
                const SizedBox(height: 20),
                _buildFieldLabel('닉네임 *'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nicknameController,
                        hintText: '닉네임을 입력하세요',
                        onChanged: (_) {
                          setState(() {
                            _isNicknameAvailable = null;
                            _nicknameCheckMessage = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                        _isCheckingNickname ? null : _checkNicknameDuplicate,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF8BC53F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: Text(
                          _isCheckingNickname ? '확인중' : '중복 확인',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_nicknameCheckMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _nicknameCheckMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isNicknameAvailable == true
                          ? const Color(0xFF5E8E1C)
                          : const Color(0xFFE53935),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('성별 *'),
                          const SizedBox(height: 8),
                          _buildSelectField(
                            value: _gender,
                            onTap: _showGenderSheet,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('나이 *'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _ageController,
                            hintText: '나이',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _buildDividerTitle('피부 정보'),
                const SizedBox(height: 22),
                _buildFieldLabel('피부 타입'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _skinTypeOptions.map((item) {
                    return _buildSkinChip(
                      label: item,
                      selected: _skinType == item,
                      onTap: () {
                        setState(() {
                          _skinType = item;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _buildFieldLabel('피부 고민'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._baseConcernOptions.map((item) {
                      return _buildSkinChip(
                        label: item,
                        selected: _selectedConcerns.contains(item),
                        showCheck: true,
                        onTap: () => _toggleConcern(item),
                      );
                    }),
                    ...customConcerns.map((item) {
                      return _buildSkinChip(
                        label: item,
                        selected: true,
                        showCheck: true,
                        onTap: () => _toggleConcern(item),
                      );
                    }),
                    _buildSkinChip(
                      label: '+ 추가',
                      selected: false,
                      isAdd: true,
                      onTap: _showAddConcernDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF8BC53F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _isSaving ? '저장 중...' : '변경사항 저장',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

class PolicyDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConcernInputDialog extends StatefulWidget {
  const _ConcernInputDialog();

  @override
  State<_ConcernInputDialog> createState() => _ConcernInputDialogState();
}

class _ConcernInputDialogState extends State<_ConcernInputDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _close([String? value]) async {
    _focusNode.unfocus();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(value);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        '피부 고민 추가',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF222222),
        ),
      ),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: false,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF222222),
        ),
        decoration: InputDecoration(
          hintText: '예: 홍조, 탄력 저하',
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) {
          final value = _controller.text.trim();
          if (value.isEmpty) return;
          _close(value);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => _close(),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Color(0xFF888888),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isEmpty) return;
            _close(value);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8BC53F),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '추가',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialProvider {
  final String id;
  final String label;
  final Color badgeColor;
  final Color textColor;
  final String assetPath;

  const _SocialProvider({
    required this.id,
    required this.label,
    required this.badgeColor,
    required this.textColor,
    required this.assetPath,
  });
}

class _SocialLogo extends StatelessWidget {
  final _SocialProvider provider;
  final double size;

  const _SocialLogo({
    required this.provider,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter =
    provider.label.isNotEmpty ? provider.label.substring(0, 1) : '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: provider.badgeColor,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.18),
        child: Image.asset(
          provider.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Text(
              firstLetter,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w800,
                color: provider.textColor,
              ),
            );
          },
        ),
      ),
    );
  }
}