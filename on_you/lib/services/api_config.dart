class ApiConfig {
  static const String baseUrl = 'http://192.168.0.143:8000';
  // 안드로이드 에뮬레이터: static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = '222.112.208.72:8000';


  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalized = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$baseUrl$normalized').replace(
      queryParameters: queryParameters?.map(
            (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}