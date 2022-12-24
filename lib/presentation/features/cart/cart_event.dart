import 'package:appp_sale_29092022/common/bases/base_event.dart';

class FetchCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class UpdateCart extends BaseEvent {
  String idProduct;
  int Quantity;

  UpdateCart({required this.idProduct, required this.Quantity});

  @override
  List<Object?> get props => [];
}

class ConfirmCart extends BaseEvent {
  bool status = false;

  ConfirmCart({required this.status});

  @override
  List<Object?> get props => [];
}

class HistoryCart extends BaseEvent {
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
