import 'dart:async';

import 'package:coingecko_coinlist/src/ui/home/dado_detail_page.dart';
import 'package:coingecko_coinlist/src/widgets/coin_list_shimmer_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var dataLists;
  var _listData = [];
  // final formatter = intl.NumberFormat.decimalPattern();
  final formatter = intl.NumberFormat("#,##0.0######"); // for price change
  final percentageFormat = intl.NumberFormat("##0.0#"); // for price change
  Timer? _timer;
  int _itemPerPage = 1, _currentMax = 9;
  bool _isLoading = true;

  ScrollController _scrollController = ScrollController();

  void refreshWithTimer(_startTime, runTimer) {
    // isTimerRun = true;
    const oneMin = const Duration(minutes: 1);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (runTimer == false) {
        timer.cancel();
        print('Timer turned off');
      } else {
        if (_startTime == 0) {
          getCoinList();
          // refreshWithTimer(30, true);
        } else {
          // setState(() {
          setState(() {
            _startTime--;

            print("Timer $_startTime");
          });
        }
      }
    });
  }

  getCoinList() async {
    Dio _dio = new Dio();
    Response _response;
    try {
      print('1');
      _response = await _dio.get(
          "http://192.168.0.18:3000/dados?page=$_itemPerPage", options: Options(sendTimeout: 3000, receiveTimeout: 3000));
      print("Response data : ${_response.data}");
      // _listCoin = _response.data;
      if (_listData.isEmpty) {
        _listData = List.generate(_response.data['data'].length, (i) => _response.data['data'][i]);
      } else {
        int j = 0;
        for (int i = _currentMax; i < _currentMax + 9; i++) {
          _listData.add(_response.data['data'][j]);
          j++;
        }
      }
      print("Success");
      _isLoading = false;

      setState(() {});
    } on DioError catch (e) {
      print("teste");
      print(e.message);
      switch (e.type) {
        case DioErrorType.connectTimeout:
          break;
        case DioErrorType.sendTimeout:
          break;
        case DioErrorType.receiveTimeout:
          break;
        case DioErrorType.response:
          break;
        case DioErrorType.cancel:
          break;
        case DioErrorType.other:
          break;
      }
      _isLoading = false;
      setState(() {});
    }
  }

  _getMoreData() {
    print("Load more data");
    _itemPerPage = _itemPerPage + 1;
    _currentMax = _currentMax + 10;
    getCoinList();
  }

  @override
  void initState() {
    super.initState();
    // refreshWithTimer(10, true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    getCoinList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFAA6EF),
                    const Color(0xFFCECECE),
                  ],
                  begin: const FractionalOffset(0.0, 1.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 40),
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        // color: Colors.red,
                        height: 50,
                        child: Center(
                            child: Text(
                          "Violência Doméstica",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        )),
                      ),
                      LiquidPullToRefresh(
                        color: Colors.transparent,
                        backgroundColor: Colors.black54,
                        springAnimationDurationInMilliseconds: 500,
                        showChildOpacityTransition: false,
                        onRefresh: () async {
                          setState(() {
                            _isLoading = true;
                            _itemPerPage = 1;
                            _currentMax = 10;
                            _listData.clear();
                          });
                          await getCoinList();
                        },
                        child: (_isLoading == true)
                            ? CoinListShimmerWidget()
                            : Container(
                                // color: Colors.red,
                                height: 600,
                                child: Container(
                                  // color: Colors.amber,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      controller: _scrollController,
                                      itemCount: _listData.length + 1,
                                      itemBuilder: (context, i) {
                                        if (i == _listData.length) {
                                          return CupertinoActivityIndicator();
                                        }
                                        return Bounceable(
                                          onTap: () {
                                            //print("${_listCoin[i]}");
                                            // ScaffoldMessenger.of(context)
                                            //     .showSnackBar(SnackBar(
                                            //         content: Text(
                                            //             "${_listCoin[i]['id']} is tapped")));
                                            //Navigator.of(context).push(
                                                //MaterialPageRoute(
                                                    //builder: (context) =>
                                                        //CoinDetailPage(
                                                            //coinId: _listCoin[i]
                                                                //['id'])));
                                          },
                                          child: Container(
                                            // color: Colors.blue,
                                            height: 75,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 30,
                                                  color: Colors.black38,
                                                  child: Center(
                                                    child: Text(
                                                      "${i + 1}",
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    // height: 50,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    // margin: EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white24),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(width: 5),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            true
                                                                ? Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        // ,
                                                                        'LOCAL : ${_listData[i]['municipio_do_fato']} - ',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green,
                                                                            fontSize: 11),
                                                                      ),
                                                                      Text(
                                                                        _listData[i]['regiao_geografica'],
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 11),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .arrow_drop_down_sharp,
                                                                          color:
                                                                              Colors.red),
                                                                      Text(
                                                                        // "${_listCoin[i]['price_change_24h']}",
                                                                       'teste3',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 10.5),
                                                                      ),
                                                                      Text(
                                                                        "teste4",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: 11),
                                                                      ),
                                                                    ],
                                                                  ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          width: 80,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  '${_listData[i]['data_do_fato']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13.5),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 3),
                                                              Row(
                                                                children: [
                                                                  Text("Nª Envolvidos",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              8)),
                                                                  Spacer(),
                                                                  Text(
                                                                    _listData[i]['total_de_envolvidos'],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        color: Colors
                                                                            .green),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text("Vítima - ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              8)),
                                                                  SizedBox(width: 5,),
                                                                  Expanded(
                                                                    child: Text(
                                                                      _listData[i]['sexo'] == 'FEMININO' ? 'MULHER' : 'HOMEM',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              9,
                                                                          color: Colors
                                                                              .red),overflow: TextOverflow.ellipsis, maxLines: 1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                      ),
                    ]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
