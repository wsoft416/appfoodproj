import 'dart:isolate';

import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:appp_sale_29092022/common/constants/variable_constant.dart';
import 'package:appp_sale_29092022/data/datasources/local/cache/app_cache.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dio_client.dart';
import 'package:dio/dio.dart';

class ApiRequest {
  late Dio _dio;

  ApiRequest() {
    _dio = DioClient.instance.dio;
  }

  Future signInRequest(String email, String password) {
    return _dio.post(ApiConstant.SIGN_IN,
        data: {"email": email, "password": password});
  }

  Future signUpRequest(String name, String email, String phone, String password,
      String address) {
    return _dio.post(ApiConstant.SIGN_UP, data: {
      "name": name,
      "phone": phone,
      "address": address,
      "email": email,
      "password": password
    });
  }

  Future getProducts() async {
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn((SendPort sendPort) {
      _dio
          .get(ApiConstant.PRODUCTS)
          .then((value) => sendPort.send(value))
          .catchError((error) => sendPort.send(error));
    }, receivePort.sendPort);

    return receivePort.first;
  }

  Future getCart() async {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn((SendPort sendPort) {
      _dio
          .get(ApiConstant.GET_CART,
              options: Options(headers: {"Authorization": "Bearer $sToken"}))
          .then((value) => sendPort.send(value))
          .catchError((error) => sendPort.send(error));
    }, receivePort.sendPort);

    return receivePort.first;
  }

  Future addToCart(String idProduct) {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    return _dio.post(ApiConstant.ADD_CART,
        data: {"id_product": idProduct},
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }
}
