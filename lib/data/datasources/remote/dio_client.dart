import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:dio/dio.dart';

class DioClient {
  Dio? _dio;
  static final BaseOptions _options = BaseOptions(
    baseUrl: ApiConstant.BASE_URL,
    connectTimeout: 30000, //30s
    receiveTimeout: 30000, //30s
  );

  static final DioClient instance = DioClient._internal();

  DioClient._internal() {
    if (_dio == null) {
      _dio = Dio(_options);
      _dio?.interceptors.add(LogInterceptor(requestBody: true));
    }
  }

  Dio get dio => _dio!;
}
