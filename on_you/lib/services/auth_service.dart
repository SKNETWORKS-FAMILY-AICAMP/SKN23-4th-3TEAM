import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';

  static String get googleLoginUrl => '${ApiConfig.baseUrl}/auth/google/login';
  static String get kakaoLoginUrl => '${ApiConfig.baseUrl}/auth/kakao/login';
  static String get naverLoginUrl => '${ApiConfig.baseUrl}/auth/naver/login';

  static Future<void> saveToken(
      String token, {
        String tokenType = 'bearer',
      }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요해요.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> loginWithGoogle() async {
    final uri = Uri.parse(googleLoginUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok) {
      throw Exception('구글 로그인 페이지를 열 수 없어요.');
    }
  }

  static Future<void> loginWithKakao() async {
    final uri = Uri.parse(kakaoLoginUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok) {
      throw Exception('카카오 로그인 페이지를 열 수 없어요.');
    }
  }

  static Future<void> loginWithNaver() async {
    final uri = Uri.parse(naverLoginUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok) {
      throw Exception('네이버 로그인 페이지를 열 수 없어요.');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String nickname,
    required String password,
    required bool termsAgreed,
    required bool privacyAgreed,
  }) async {
    // 여기만 실제 회원가입 Swagger 경로로 바꿔야 함
    final uri = ApiConfig.uri('/users/register');

    print('REGISTER URI: $uri');

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'nickname': nickname,
        'password': password,
        'terms_agreed': termsAgreed,
        'privacy_agreed': privacyAgreed,
      }),
    );

    print('REGISTER STATUS: ${response.statusCode}');
    print('REGISTER BODY: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes))
      as Map<String, dynamic>;
    }

    throw Exception(
      '회원가입 실패\n'
          '상태코드: ${response.statusCode}\n'
          '응답: ${utf8.decode(response.bodyBytes)}',
    );
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = ApiConfig.uri('/users/login');

    print('LOGIN URI: $uri');

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes))
      as Map<String, dynamic>;

      final accessToken = data['access_token']?.toString();
      final tokenType = data['token_type']?.toString() ?? 'bearer';

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('응답에 access_token이 없어요.');
      }

      await saveToken(
        accessToken,
        tokenType: tokenType,
      );

      return data;
    }

    throw Exception(
      '로그인 실패\n'
          '상태코드: ${response.statusCode}\n'
          '응답: ${utf8.decode(response.bodyBytes)}',
    );
  }
}