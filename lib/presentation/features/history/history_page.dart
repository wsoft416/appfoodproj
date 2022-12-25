import 'package:appp_sale_29092022/common/bases/base_widget.dart';
import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:appp_sale_29092022/common/utils/extension.dart';
import 'package:appp_sale_29092022/common/widgets/loading_widget.dart';
import 'package:appp_sale_29092022/data/datasources/remote/api_request.dart';
import 'package:appp_sale_29092022/data/datasources/remote/dto/cart_dto.dart';
import 'package:appp_sale_29092022/data/model/cart.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/cart/cart_event.dart';
import 'package:appp_sale_29092022/presentation/features/history/history_bloc.dart';
import 'package:appp_sale_29092022/presentation/features/history/history_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
      child: HistoryContainer(),
    );
  }
}

class HistoryContainer extends StatefulWidget {
  const HistoryContainer({super.key});

  @override
  State<HistoryContainer> createState() => _HistoryContainerState();
}

class _HistoryContainerState extends State<HistoryContainer> {
  late HistoryBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
    bloc.eventSink.add(FetchHistoryOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder<List<Cart>>(
          initialData: [],
          stream: bloc.cart,
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
                  Expanded(flex: 2, child: _buildCart()),
                  Expanded(
                      flex: 12,
                      child: ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return _buildItem(snapshot.data?[index]);
                          }))
                ],
              );
            } else {
              return Container();
            }
          }),
      LoadingWidget(child: Container(), bloc: bloc),
    ]);
  }

  Widget _buildCart() {
    return Container(
        margin: const EdgeInsets.fromLTRB(5, 40, 5, 5),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text("Lịch sử đơn hàng",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.bold))),
            Expanded(
              flex: 1,
              child: Text(""),
            )
          ],
        ));
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
                "Đơn hàng hiện tại đang trống",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        Flexible(
            flex: 4,
            child: Image.asset(
              "assets/images/cart48.png",
              width: 200,
            ))
      ],
    );
  }

  Widget _buildItem(Cart? cart) {
    if (cart == null) return Container();
    return Container(
      height: 135,
      child: Card(
        elevation: 5,
        shadowColor: Colors.blueGrey,
        child: Container(
          padding: EdgeInsets.only(top: 2, bottom: 5),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset("assets/images/cart48.png"),
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(cart.dateCreated,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text("Tổng tiền : ${formatPrice(cart.price)} đ",
                          style: TextStyle(fontSize: 12)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "history-detail",
                              arguments: {"cart": cart});
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Color.fromARGB(200, 240, 102, 61);
                              } else {
                                return Color.fromARGB(230, 240, 102, 61);
                              }
                            }),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10))))),
                        child: Text("Xem chi tiết",
                            style: TextStyle(fontSize: 14)),
                      ),
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
