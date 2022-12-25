import 'package:appp_sale_29092022/data/datasources/remote/dto/product_dto.dart';

class CartDTO {
  String? id;
  List<dynamic>? products;
  String? idUser;
  int? price;
  String? dateCreated;

  CartDTO({this.id, this.products, this.idUser, this.price, this.dateCreated});

  CartDTO.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    products = json['products'];
    idUser = json['id_user'];
    price = json['price'];
    dateCreated = json['date_created'];
  }

  static CartDTO parsetoCart(Map<String, dynamic> json) {
    return CartDTO.fromJson(json);
  }

  static List<CartDTO> getListCartDTO(List<dynamic> json) {
    return (json as List).map((e) => CartDTO.fromJson(e)).toList();
  }
}
