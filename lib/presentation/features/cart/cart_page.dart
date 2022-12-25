import 'package:appp_sale_29092022/common/bases/base_widget.dart';
import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:appp_sale_29092022/common/utils/extension.dart';
import 'package:appp_sale_29092022/common/widgets/loading_widget.dart';
import 'package:appp_sale_29092022/data/datasources/remote/api_request.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/model/cart.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_bloc.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_event.dart';
import 'package:appp_sale_29092022/common/widgets/progress_listener_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
        ProxyProvider<ProductRepository, CartBloc>(
          create: (context) => CartBloc(),
          update: (context, repository, bloc) {
            bloc?.updateProductRepo(repository);
            return bloc!;
          },
        )
      ],
      child: CartContainer(),
    );
  }
}

class CartContainer extends StatefulWidget {
  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  late CartBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
    bloc.eventSink.add(FetchCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder<List<Product>>(
          initialData: [],
          stream: bloc.products,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Data is error");
            } else if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data?.length == 0) {
              return Center(child: _showEmpty());
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                      flex: 12,
                      child: ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return _showCartInfo(snapshot.data?[index]);
                          })),
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: _summaryCart()))),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: () {
                                    bloc.eventSink
                                        .add(ConfirmCart(status: false));
                                  },
                                  child: Text("Tạo đơn hàng",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                              )))),
                ],
              );
            } else {
              return Center(child: _showEmpty());
            }
          }),
      LoadingWidget(child: Container(), bloc: bloc),
      ProgressListenerWidget<CartBloc>(
        child: Container(),
        callback: (event) {
          String msg = "";
          bool callHomePage = false;
          switch (event.runtimeType) {
            case ConfirmSuccessEvent:
              msg = "Tạo đơn hàng thành công";
              callHomePage = true;
              break;
            case UpdateSuccessEvent:
              msg = "Đã cập nhật số lượng sản phẩm";
              break;
            case FailEvent:
              msg = (event as FailEvent).message;
              break;
          }
          showSnackBar(context, msg);
          Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        },
      )
    ]);
  }

  Widget _showEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Chi tiết đơn hàng",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                "Giỏ hàng của bạn không có sản phẩm",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        ),
        Flexible(
            flex: 4,
            child: Image.asset(
              "assets/images/noproduct.png",
              width: 200,
            ))
      ],
    );
  }

  Widget _buildQuanlityCart(String id, int soluong) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: TextButton(
            onPressed: () {
              bloc.eventSink
                  .add(UpdateCart(idProduct: id, quantity: soluong - 1));
            },
            child: Text(
              "-",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Text(
          soluong.toString(),
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        SizedBox(
          width: 30,
          height: 30,
          child: TextButton(
            onPressed: () {
              bloc.eventSink
                  .add(UpdateCart(idProduct: id, quantity: soluong + 1));
            },
            child: Text(
              "+",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _showCartInfo(Product? product) {
    if (product == null) return Container();

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
                child: Image.network(ApiConstant.BASE_URL + product.img,
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
                        child: Text(product.name.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text("Giá : ${formatPrice(product.price)} đ",
                          style: TextStyle(fontSize: 12)),
                      _buildQuanlityCart(product.id, product.quantity)
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

  Widget _summaryCart() {
    int value = 0;
    return Container(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tổng tiền :",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text("${formatPrice(bloc.getTotalMoney())} đ",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
      ],
    ));
    // );
  }
}
