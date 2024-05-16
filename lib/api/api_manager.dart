import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:dio/io.dart";
import "package:muslim/api/common/custom_log_interceptor.dart";
import "package:muslim/api/interceptor/authorize_interceptor.dart";
import "package:muslim/constant.dart";

class ApiManager {
  static bool PRIMARY = true;

  static Future<Dio> getDio({
    bool plain = false,
  }) async {
    String baseUrl;

    if (PRIMARY) {
      baseUrl = ApiUrl.MAIN_BASE;
    } else {
      baseUrl = ApiUrl.SECONDARY_BASE;
    }

    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseDecoder: (responseBytes, options, responseBody) {
          if (plain) {
            options.responseType = ResponseType.plain;
          }

          return utf8.decode(responseBytes, allowMalformed: true);
        },
      ),
    );

    dio.interceptors.add(AuthorizationInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.interceptors.add(CustomLogInterceptor());

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient httpClient = HttpClient();

      httpClient.badCertificateCallback = (cert, host, port) => true;

      return httpClient;
    };

    return dio;
  }

  Future<Uint8List> download({
    required String url,
  }) async {
    Response response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));

    return response.data;
  }

  final dio = Dio();

  Future<Map<String, dynamic>> getPrayerTimes() async {
    final String baseUrl = "https://api.myquran.com";
    final String version = "v2";
    final String kota = "1204";
    final String date = DateTime.now()
        .toIso8601String()
        .split('T')
        .first; 
    final String url = "$baseUrl/$version/sholat/jadwal/$kota/$date";

    try {
      final Dio dio = await getDio();
      final Response response = await dio.get(url);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Gagal load data jadwal sholat');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }
}
