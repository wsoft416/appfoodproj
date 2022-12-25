import 'dart:async';
import 'dart:ffi';

import 'package:appp_sale_29092022/common/bases/base_bloc.dart';
import 'package:appp_sale_29092022/common/bases/base_event.dart';
import 'package:appp_sale_29092022/common/constants/variable_constant.dart';
import 'package:appp_sale_29092022/data/datasources/local/cache/app_cache.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/product_dto.dart';
import 'package:appp_sale_29092022/data/model/cart.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_event.dart';

class CartBloc extends BaseBloc {
  StreamController<List<Product>> _listCartController = StreamController();
  Stream<List<Product>> get products => _listCartController.stream;

  late ProductRepository _productRepository;
  late int iTotalMoney = 0;

  int getTotalMoney() => iTotalMoney;

  void updateProductRepo(ProductRepository productRepository) {
    _productRepository = productRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch (event.runtimeType) {
      case FetchCartEvent:
        _executeGetCart(event as FetchCartEvent);
        break;
      case UpdateCart:
        _executeUpdateCart(event as UpdateCart);
        break;
      case ConfirmCart:
        _executeConfirmCart(event as ConfirmCart);
        break;
    }
  }

  void _executeGetCart(FetchCartEvent event) async {
    loadingSink.add(true);
    try {
      AppResource<CartDTO> resCarttDTO = await _productRepository.getCart();
      if (resCarttDTO.data == null) return;

      CartDTO cartDTO = resCarttDTO.data!;
      //set cache
      AppCache.setString(
          key: VariableConstant.CART_ID, value: cartDTO.id.toString());

      iTotalMoney = cartDTO.price!;

      List<ProductDTO> listProductDTO =
          ProductDTO.parserListProducts(cartDTO.products!);
      List<Product> listProduct = listProductDTO.map((e) {
        return Product(
            e.id, e.name, e.address, e.price, e.img, e.quantity, e.gallery);
      }).toList();
      _listCartController.sink.add(listProduct);
      loadingSink.add(false);
    } catch (e) {
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  void _executeUpdateCart(UpdateCart event) async {
    loadingSink.add(true);
    try {
      AppResource<CartDTO> resourceCartDTO =
          await _productRepository.updateCart(event.idProduct, event.quantity);
      if (resourceCartDTO.data == null) return;
      progressSink.add(UpdateSuccessEvent());
      loadingSink.add(false);
    } catch (e) {
      progressSink.add(FailEvent(message: e.toString()));
      loadingSink.add(false);
    }
  }

  void _executeConfirmCart(ConfirmCart event) {
    loadingSink.add(true);
    try {
      _productRepository.confirmCart(event.status);
      progressSink.add(ConfirmSuccessEvent());
      loadingSink.add(false);
    } catch (e) {
      progressSink.add(FailEvent(message: e.toString()));
      loadingSink.add(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _listCartController.close();
  }
}
