import 'package:appp_sale_29092022/common/bases/base_widget.dart';
import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:appp_sale_29092022/common/utils/extension.dart';
import 'package:appp_sale_29092022/common/widgets/loading_widget.dart';
import 'package:appp_sale_29092022/data/datasources/remote/api_request.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/app_resource.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/product_dto.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/model/cart.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_bloc.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_event.dart';
import 'package:appp_sale_29092022/common/widgets/progress_listener_widget.dart';
import 'package:appp_sale_29092022/presentation/features/history/history_bloc.dart';
import 'package:appp_sale_29092022/presentation/features/history/history_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryDtlPage extends StatefulWidget {
  const HistoryDtlPage({Key? key}) : super(key: key);

  @override
  State<HistoryDtlPage> createState() => _HistoryDtlPageState();
}

class _HistoryDtlPageState extends State<HistoryDtlPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          create: (context) => ProductRepository(),
          update: (context, request, repository) {
            repository?.updateApiRequest(request);
            return repository!;
          },
        ),
        ProxyProvider<ProductRepository, HistoryBloc>(
          create: (context) => HistoryBloc(),
          update: (context, repository, bloc) {
            bloc?.updateProductRepo(repository);
            return bloc!;
          },
        )
      ],
      child: HistoryDtlContainer(),
    );
  }
}

class HistoryDtlContainer extends StatefulWidget {
  @override
  State<HistoryDtlContainer> createState() => _HistoryDtlContainerState();
}

class _HistoryDtlContainerState extends State<HistoryDtlContainer> {
  late HistoryBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
    //bloc.eventSink.add(ShowDetailProductOrderEvent(idcart: idcart));
  }

  @override
  Widget build(BuildContext context) {
    //lấy giá trị parameter
    final Map<String, dynamic> cartPage =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Cart cartInfo = cartPage["cart"] as Cart;
    //print("${Map<String, dynamic>.from(cartInfo.products[0])}");
    return Column(
      children: [
        Expanded(
            flex: 12,
            child: ListView.builder(
                itemCount: cartInfo.products.length ?? 0,
                itemBuilder: (context, index) {
                  ProductDTO productdto =
                      ProductDTO.fromJson(cartInfo.products[index]);

                  String namepro = productdto.name.toString();
                  String img = productdto.img.toString();
                  int price = productdto.price ?? 0;
                  int quantity = productdto.quantity ?? 0;

                  return _showCartInfo(namepro, img, price, quantity);
                })),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Tổng tiền của đơn hàng",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                Text("${formatPrice(cartInfo.price)} đ",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold))
              ],
            ),
            flex: 2)
      ],
    );
  }

  Widget _buildQuanlityCart(int soluong) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Số lượng : ${soluong.toString()}",
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    ));
  }

  Widget _showCartInfo(String namepro, String img, int price, int quantity) {
    return Container(
      height: 135,
      child: Card(
        elevation: 5,
        shadowColor: Colors.blueGrey,
        child: Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(ApiConstant.BASE_URL + img,
                    width: 150, height: 120, fit: BoxFit.fill),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(namepro.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text("Giá : ${formatPrice(price)} đ",
                          style: TextStyle(fontSize: 12)),
                      _buildQuanlityCart(quantity)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
