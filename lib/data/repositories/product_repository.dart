import 'dart:async';

import 'package:appp_sale_29092022/data/datasources/remote/api_request.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/product_dto.dart';
import 'package:dio/dio.dart';

class ProductRepository {
  late ApiRequest _apiRequest;

  void updateApiRequest(ApiRequest apiRequest) {
    _apiRequest = apiRequest;
  }

  Future<AppResource<List<ProductDTO>>> getProducts() async {
    Completer<AppResource<List<ProductDTO>>> completer = Completer();
    try {
      Response<dynamic> response = await _apiRequest.getProducts();
      AppResource<List<ProductDTO>> resourceProductDTO =
          AppResource.fromJson(response.data, (listData) {
        return (listData as List).map((e) => ProductDTO.fromJson(e)).toList();
      });
      completer.complete(resourceProductDTO);
    } on DioError catch (dioError) {
      completer.completeError(dioError.response?.data["message"]);
    } catch (e) {
      completer.completeError(e.toString());
    }
    return completer.future;
  }

  Future<AppResource<CartDTO>> getCart() async {
    Completer<AppResource<CartDTO>> completer = Completer();
    try {
      Response<dynamic> response = await _apiRequest.getCart();
      AppResource<CartDTO> resourceCartDTO =
          AppResource.fromJson(response.data, CartDTO.parsetoCart);
      completer.complete(resourceCartDTO);
    } on DioError catch (dioError) {
      completer.completeError(dioError.response?.data["message"]);
    } catch (e) {
      completer.completeError(e.toString());
    }
    return completer.future;
  }

  Future<AppResource<CartDTO>> addToCart(String idProduct) async {
    Completer<AppResource<CartDTO>> completer = Completer();
    try {
      Response<dynamic> response = await _apiRequest.addToCart(idProduct);
      AppResource<CartDTO> resourceCartDTO =
          AppResource.fromJson(response.data, CartDTO.fromJson);
      completer.complete(resourceCartDTO);
    } on DioError catch (dioError) {
      completer.completeError(dioError.response?.data["message"]);
    } catch (e) {
      completer.completeError(e.toString());
    }
    return completer.future;
  }
}
