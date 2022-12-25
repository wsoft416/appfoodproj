import 'dart:async';

import 'package:appp_sale_29092022/common/bases/base_bloc.dart';
import 'package:appp_sale_29092022/common/bases/base_event.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/product_dto.dart';
import 'package:appp_sale_29092022/data/model/cart.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/history/history_event.dart';

class HistoryBloc extends BaseBloc {
  StreamController<List<Cart>> _listCartsController = StreamController();
  Stream<List<Cart>> get cart => _listCartsController.stream;

  late ProductRepository _productRepository;

  void updateProductRepo(ProductRepository productRepository) {
    _productRepository = productRepository;
  }

  @override
  void dispatch(BaseEvent event) {
    switch (event.runtimeType) {
      case FetchHistoryOrderEvent:
        _getHistoryCart(event as FetchHistoryOrderEvent);
        break;
    }
  }

  void _getHistoryCart(FetchHistoryOrderEvent event) async {
    loadingSink.add(true);
    try {
      AppResource<CartDTO> resourceDTO = await _productRepository.historyCart();
      if (resourceDTO.data == null) return;

      CartDTO listCartDTO = resourceDTO.data!;
      List<Cart> listCart = [];
      listCart.add(Cart(
          listCartDTO.id.toString(),
          listCartDTO.products ?? List.empty(),
          listCartDTO.idUser.toString(),
          (listCartDTO.price ?? 0).toInt(),
          listCartDTO.dateCreated.toString()));

      _listCartsController.sink.add(listCart);
      loadingSink.add(false);
    } catch (e) {
      messageSink.add(e.toString());
      loadingSink.add(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _listCartsController.close();
  }
}
