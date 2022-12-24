import 'package:appp_sale_29092022/common/bases/base_widget.dart';
import 'package:appp_sale_29092022/common/constants/api_constant.dart';
import 'package:appp_sale_29092022/common/utils/extension.dart';
import 'package:appp_sale_29092022/common/widgets/loading_widget.dart';
import 'package:appp_sale_29092022/data/datasources/remote/api_request.dart';
import 'package:appp_sale_29092022/data/model/product.dart';
import 'package:appp_sale_29092022/data/repositories/product_repository.dart';
import 'package:appp_sale_29092022/presentation/features/home/home_bloc.dart';
import 'package:appp_sale_29092022/presentation/features/home/home_event.dart';
import 'package:appp_sale_29092022/common/widgets/progress_listener_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        ProxyProvider<ProductRepository, HomeBloc>(
          create: (context) => HomeBloc(),
          update: (context, repository, bloc) {
            bloc?.updateProductRepo(repository);
            return bloc!;
          },
        )
      ],
      child: HomeContainer(),
    );
  }
}

class HomeContainer extends StatefulWidget {
  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read();
    bloc.eventSink.add(FetchProductEvent());
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
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(flex: 2, child: _buildCart()),
                  Expanded(
                      flex: 12,
                      child: ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return _buildItemFood(snapshot.data?[index]);
                          }))
                ],
              );
            } else {
              return Container();
            }
          }),
      LoadingWidget(child: Container(), bloc: bloc),
      ProgressListenerWidget<HomeBloc>(
        child: Container(),
        callback: (event) {
          switch (event.runtimeType) {
            case SuccessEvent:
              showSnackBar(context, "Đã thêm vào giỏ hàng");
              break;
            case FailEvent:
              showSnackBar(context, (event as FailEvent).message);
              break;
          }
        },
      )
    ]);
  }

  Widget _buildCart() {
    return Container(
        margin: const EdgeInsets.fromLTRB(5, 40, 5, 5),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text("Food",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: _buildHistory(function: () {
                  showMessage(context, "Message", "Input is not empty", [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("ok"))
                  ]);

                  //bloc.eventSink.add(SignInEvent(email: email, password: password));
                })),
            Expanded(
                flex: 1,
                child: _buildShopCart(function: () {
                  Navigator.pushNamed(context, "cart")
                      .then((value) {})
                      .catchError((error) {
                    print(error);
                  });
                }))
          ],
        ));
  }

  Widget _buildHistory({Function()? function}) {
    return Container(
        margin: EdgeInsets.only(left: 200),
        padding: EdgeInsets.all(5),
        child: InkWell(
            onTap: function, child: Image.asset("assets/images/star48.png")));
  }

  Widget _buildShopCart({Function()? function}) {
    return Container(
        margin: EdgeInsets.only(right: 5),
        padding: EdgeInsets.all(10),
        child: InkWell(
            onTap: function, child: Image.asset("assets/images/cart48.png")));
  }

  Widget _buildItemFood(Product? product) {
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
                      ElevatedButton(
                        onPressed: () {
                          bloc.eventSink
                              .add(AddToCart(idProduct: product.id.toString()));
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
                        child:
                            Text("Add To Cart", style: TextStyle(fontSize: 14)),
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
