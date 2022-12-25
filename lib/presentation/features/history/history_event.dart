import 'package:appp_sale_29092022/common/bases/base_event.dart';

class FetchHistoryOrderEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class ShowDetailProductOrderEvent extends BaseEvent {
  final String idcart;

  ShowDetailProductOrderEvent({required this.idcart});

  @override
  List<Object?> get props => [];
}
