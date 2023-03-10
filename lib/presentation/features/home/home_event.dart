import 'package:appp_sale_29092022/common/bases/base_event.dart';

class FetchProductEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class AddToCart extends BaseEvent {
  final String idProduct;

  AddToCart({required this.idProduct});

  @override
  List<Object?> get props => [];
}

class SuccessEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class FailEvent extends BaseEvent {
  final String message;

  FailEvent({required this.message});

  @override
  List<Object?> get props => [];
}
