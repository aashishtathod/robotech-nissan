import 'dart:convert';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:robotech/model/model_inventory.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/res/custom_colors.dart';
import 'package:robotech/screens/test_drive_scan_screen.dart';
import 'package:robotech/screens/upload_test_drive_image.dart';

class TestDriveScreen extends StatefulWidget {
  late String groupCode, dealerCode, dealerName;

  TestDriveScreen(
      {Key? key,
      required this.groupCode,
      required this.dealerCode,
      required this.dealerName})
      : super(key: key);

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<TestDriveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          leading: const BackButton(),
          title: Text('Test Drive List - ' + widget.dealerCode,
              style: GoogleFonts.roboto(fontSize: 20.0)),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            ProductsPage(
                groupCode: widget.groupCode,
                dealerCode: widget.dealerCode,
                dealerName: widget.dealerName)
          ],
        )));
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage(
      {Key? key,
      required this.groupCode,
      required this.dealerCode,
      required this.dealerName})
      : super(key: key);
  final String groupCode, dealerCode, dealerName;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        SizedBox(
            height: size.height, // constrain height
            child: ListView(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(right: 20.0, left: 20),
                    width: MediaQuery.of(context).size.width - 30.0,
                    height: MediaQuery.of(context).size.height - 50.0,
                    child: ProductsListView(
                        dealerCode: dealerCode,
                        groupCode: groupCode,
                        dealerName: dealerName)),
                const SizedBox(height: 15.0)
              ],
            ))
      ],
    );
  }
}

class ProductsListView extends StatefulWidget {
  final String dealerCode, groupCode, dealerName;

  const ProductsListView(
      {Key? key,
      required this.dealerCode,
      required this.groupCode,
      required this.dealerName})
      : super(key: key);

  @override
  _ProductsListViewState createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView>
    with TickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController animationController;
  final List<Color> colors = [
    const Color(0xffDFECF8),
    const Color(0xffF4DEF8),
    const Color(0xffFFF2C5),
    const Color(0xffDFECF8)
  ];
  List<Inventory> inventoryList = [];
  late AsyncMemoizer<List<Inventory>> _memoizer;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _memoizer = AsyncMemoizer<List<Inventory>>();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<List<Inventory>> _fetchInventory(dealerCode) async {
    return _memoizer.runOnce(() async {
      // This below code will call only ones. This will return the same data directly without performing any Future task.
      await Future.delayed(const Duration(seconds: 1));
      var data = {'type': 'Test Drive', 'dealerCode': dealerCode};

      final response = await http.get(
          Uri.parse(fetchData).replace(queryParameters: data),
          headers: {"Content-Type": "application/json"});
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((job) => Inventory.fromJson(job)).toList();
      } else {
        log('Failed to load inventory from API');
        List<Inventory> emptyList = [];
        return emptyList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inventory>>(
      future: _fetchInventory(widget.dealerCode),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              final int count = snapshot.data!.length;
              final Animation<double> animation =
                  Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: Interval((1 / count) * index, 1.0,
                      curve: Curves.fastOutSlowIn),
                ),
              );
              animationController.forward();
              return InventoryView(
                  color: colors[index % colors.length],
                  inventory: snapshot.data![index],
                  animation: animation,
                  animationController: animationController,
                  groupCode: widget.groupCode,
                  dealerCode: widget.dealerCode,
                  dealerName: widget.dealerName);
            },
          );
          //_productListView(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class InventoryView extends StatefulWidget {
  final Color color;
  final Inventory inventory;
  late AnimationController? animationController;
  final Animation<double> animation;
  final String groupCode, dealerCode, dealerName;
  late String? status;

  InventoryView(
      {Key? key,
      required this.color,
      required this.inventory,
      this.animationController,
      required this.animation,
      required this.groupCode,
      required this.dealerCode,
      required this.dealerName})
      : super(key: key);

  @override
  _InventoryViewState createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  @override
  Widget build(BuildContext context) {
    widget.status = widget.inventory.otherStatus;
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, -20 * (1.0 - widget.animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: InkWell(
                  onTap: () {},
                  child: Stack(children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 3.0,
                                  blurRadius: 5.0)
                            ],
                            color: Colors.white),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: Column(
                                children: <Widget>[
                                  Center(
                                    child: InkWell(
                                        onTap: () async {
                                          final String result =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return TestDriveScanScreen(
                                                    groupCode: widget.groupCode,
                                                    dealerCode:
                                                        widget.dealerCode,
                                                    dealerName:
                                                        widget.dealerName,
                                                    vin: widget.inventory.vin);
                                              },
                                            ),
                                          );
                                          // ignore: unnecessary_null_comparison
                                          if (result == null) return;

                                          setState(() => {
                                                widget.inventory.otherStatus =
                                                    result
                                              });
                                        },
                                        child: Container(
                                          height: 75.0,
                                          width: 75.0,
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image:
                                                      AssetImage('qr_code.png'),
                                                  fit: BoxFit.contain)),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UploadTestDriveImagesPage(
                                          groupCode: widget.groupCode,
                                          dealerCode: widget.dealerCode,
                                          dealerName: widget.dealerName,
                                          vin: widget.inventory.vin,
                                          image1: widget.inventory.image1,
                                          image2: widget.inventory.image2,
                                          image3: widget.inventory.image3,
                                          image4: widget.inventory.image4,
                                          image5: widget.inventory.image5,
                                          image6: widget.inventory.image6,
                                          image7: widget.inventory.image7,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.inventory.vin,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.inventory.model!,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.inventory.variant!,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Status : ' +
                                          widget.inventory.otherStatus,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: widget.inventory.otherStatus ==
                                                  'Found'
                                              ? Colors.green
                                              : Colors.red),
                                    )
                                  ],
                                )),
                          ],
                        )),
                  ])),
            ),
          ),
        );
      },
    );
  }
}
