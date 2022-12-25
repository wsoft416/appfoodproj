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

  Future getProducts() {
    return _dio.get(ApiConstant.PRODUCTS);
  }

  Future getCart() {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    return _dio.get(ApiConstant.GET_CART,
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }

  Future addToCart(String idProduct) {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    return _dio.post(ApiConstant.ADD_CART,
        data: {"id_product": idProduct},
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }

  Future updateCart(String idProduct, int quantity) {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    String sIDCart = AppCache.getString(VariableConstant.CART_ID);
    return _dio.post(ApiConstant.UPDATE_CART,
        data: {
          "id_product": idProduct,
          "id_cart": sIDCart,
          "quantity": quantity
        },
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }

  Future confirmCart(bool status) {
    String sToken = AppCache.getString(VariableConstant.TOKEN);
    String sIDCart = AppCache.getString(VariableConstant.CART_ID);
    return _dio.post(ApiConstant.CONFIRM_CART,
        data: {"id_cart": sIDCart, "status": status},
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }

  Future getHistoryCart() {
    String sToken = AppCache.getString(VariableConstant.TOKEN);

    return _dio.get(ApiConstant.HISTORY_CART,
        options: Options(headers: {"Authorization": "Bearer $sToken"}));
  }
}
