import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:robotech/model/model_getCdrData.dart';
import 'package:robotech/res/cdr_widgets.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/res/custom_colors.dart';
import 'package:robotech/screens/cdr_doc_edit_upload_screen.dart';

class CDRScreen extends StatefulWidget {
  late String dealerCode, password;
  String? groupCode;

  CDRScreen(
      {Key? key,
      this.groupCode,
      required this.dealerCode,
      required this.password})
      : super(key: key);

  @override
  _CDRScreenState createState() => _CDRScreenState();
}

class _CDRScreenState extends State<CDRScreen> {
  bool isLoading = false;
  late AsyncMemoizer<List<Datum>> _memoizer;

  @override
  void initState() {
    _memoizer = AsyncMemoizer<List<Datum>>();
    super.initState();
  }

  Future<List<Datum>> _fetchCdrData(String dealerCode, String password) async {
    return _memoizer.runOnce(() async {
      // This below code will call only ones. This will return the same data directly without performing any Future task.
      await Future.delayed(const Duration(seconds: 1));
      var data = {'username': dealerCode, 'password': password};

      final response =
          await http.get(Uri.parse(getCdrDAta).replace(queryParameters: data));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        GetCdrData data = GetCdrData.fromJson(jsonResponse);
        //print(data.data);
        return data.data;
      } else {
        log('Failed to load Data from CDR API');
        List<Datum> emptyList = [];
        return emptyList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          leading: const BackButton(),
          title: Text('CDR List - ' + widget.dealerCode,
              style: GoogleFonts.roboto(fontSize: 20.0)),
        ),
        body: FutureBuilder<List<Datum>>(
            future: _fetchCdrData(widget.dealerCode, widget.password),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10, top: 10, right: 15, left: 15),
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CdrItemStatus(
                                      id: snapshot.data![index].id,
                                      vin: snapshot.data![index].vin,
                                      customerBookingForm: snapshot
                                          .data![index].customerBookingForm,
                                      dmsRetailInv:
                                          snapshot.data![index].dmsRetailInv,
                                      dmsGatePass:
                                          snapshot.data![index].dmsGatePass,
                                      paymentProf:
                                          snapshot.data![index].paymentProf,
                                      registrationDocument: snapshot
                                          .data![index].registrationDocument,
                                      dealerCode: widget.dealerCode,
                                      password: widget.password,
                                    );
                                  },
                                ),
                              );
                            },
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
                                            top: 15,
                                            left: 10,
                                            right: 10,
                                            bottom: 10),
                                        child: Column(
                                          children: const <Widget>[
                                            Center(
                                              child: InkWell(
                                                  child: CircleAvatar(
                                                backgroundImage:
                                                    AssetImage("document.png"),
                                                radius: 30,
                                              )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            snapshot.data![index].vin,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            snapshot.data![index].mmodel,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            snapshot.data![index].make,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            snapshot.data![index].variant,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ])),
                      );
                    });
              } else if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              } else if (snapshot.data?.length == 0) {
                return Center(child: Text("No Data"));
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}

class CdrItemStatus extends StatefulWidget {
  late int id;
  late String vin,
      customerBookingForm,
      dmsRetailInv,
      dmsGatePass,
      paymentProf,
      registrationDocument,
      dealerCode,
      password;

  CdrItemStatus({
    Key? key,
    required this.id,
    required this.vin,
    required this.customerBookingForm,
    required this.dmsRetailInv,
    required this.dmsGatePass,
    required this.paymentProf,
    required this.registrationDocument,
    required this.dealerCode,
    required this.password,
  }) : super(key: key);

  @override
  _CdrItemStatusState createState() => _CdrItemStatusState();
}

class _CdrItemStatusState extends State<CdrItemStatus> {
  Future _getData() async {
    AsyncMemoizer _memoizer = AsyncMemoizer();
    try {
      _memoizer.runOnce(() async {
        await Future.delayed(const Duration(seconds: 1));
        var data = {'username': widget.dealerCode, 'password': widget.password};

        final response = await http
            .get(Uri.parse(getCdrDAta).replace(queryParameters: data));

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
              msg: "Generating stock sign off report!!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              // also possible "TOP" and "CENTER"
              backgroundColor: Colors.black,
              textColor: Colors.white);

          var jsonResponse = json.decode(response.body);
          GetCdrData data = GetCdrData.fromJson(jsonResponse);
          //print(data.data);
          data.data;
        } else {}
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3.0,
                      blurRadius: 5.0)
                ],
                color: Colors.white),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: CircleAvatar(
                      backgroundImage: AssetImage("document.png"),
                      radius: MediaQuery.of(context).size.height * 0.055,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  widget.vin,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText1("Documents"),
                    createText1("Current Status"),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText2("Customer Booking\nForm"),
                    createText3(widget.customerBookingForm)
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText2("DMS Retial\nInvoice"),
                    createText3(widget.dmsRetailInv)
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText2("DMS Gate\nPass"),
                    createText3(widget.dmsGatePass)
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText2("Proof Of Payment\nby Customer"),
                    createText3(widget.paymentProf)
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    createText2("Registration\nDocument"),
                    createText3(widget.registrationDocument)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CdrDocEditScreen(
                  vin: widget.vin,
                  id: widget.id,
                  dealerCode: widget.dealerCode,
                  password: widget.password,
                );
              },
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.edit,
        ),
      ),
    );
  }
}
