import 'package:appp_sale_29092022/common/bases/base_event.dart';

class FetchCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class UpdateCart extends BaseEvent {
  final String idProduct;
  final int quantity;

  UpdateCart({required this.idProduct, required this.quantity});

  @override
  List<Object?> get props => [];
}

class ConfirmCart extends BaseEvent {
  final bool status;

  ConfirmCart({required this.status});

  @override
  List<Object?> get props => [];
}

class ConfirmSuccessEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class UpdateSuccessEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class FailEvent extends BaseEvent {
  final String message;

  FailEvent({required this.message});

  @override
  List<Object?> get props => [];
}
