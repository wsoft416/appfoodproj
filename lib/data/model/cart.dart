import 'Product.dart';

class Cart {
  String id = "";
  List<dynamic> products = [];
  String idUser = "";
  int price = 0;
  String dateCreated = "";

  Cart(this.id, this.products, this.idUser, this.price, this.dateCreated);

  void updateCart(String? id, List<dynamic>? products, String? idUser,
      int? price, String? datacreated) {
    this.id = id ?? "";
    this.products = products ?? [];
    this.idUser = idUser ?? "";
    this.price = price ?? 0;
    this.dateCreated = datacreated ?? "";
  }

  @override
  String toString() {
    return 'Cart{id: $id, date_created: $dateCreated, id_user: $idUser, price: $price, products: $products }';
  }

  void clear() {
    this.products.clear();
    this.price = 0;
    this.dateCreated = "";
  }
}
