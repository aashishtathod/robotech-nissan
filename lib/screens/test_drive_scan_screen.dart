import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:robotech/components/background.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:robotech/res/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:robotech/res/custom_colors.dart';

class TestDriveScanScreen extends StatefulWidget {
  late String? groupCode, dealerCode, dealerName, vin;
  TestDriveScanScreen(
      {Key? key, this.groupCode, this.dealerCode, this.dealerName, this.vin})
      : super(key: key);

  @override
  _TestDriveScanScreenState createState() => _TestDriveScanScreenState();
}

class _TestDriveScanScreenState extends State<TestDriveScanScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scanVin = "";
  String? groupCode, dealerCode, dealerName, vin;
  bool isLoading = false,
      statusButtonVisible = false,
      submitButtonVisible = false;
  @override
  void initState() {
    super.initState();
    groupCode = widget.groupCode;
    dealerCode = widget.dealerCode;
    dealerName = widget.dealerName;
    vin = widget.vin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimaryColor,
        leading: const BackButton(),
        title: Text('Vin - ' + vin!, style: GoogleFonts.roboto(fontSize: 20.0)),
      ),
      body: Background(
          child: Column(children: <Widget>[
        Expanded(flex: 4, child: _buildQrView(context)),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null)
                  Text(
                      'Vin: ${result!.code!.contains("#") ? result!.code!.substring(result!.code!.indexOf("#") + 1, result!.code!.indexOf("#") + 18) : result!.code}')
                else
                  const Text('Scan a code'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 120, // <-- Your width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: !statusButtonVisible
                                  ? Colors.grey
                                  : kPrimaryColor,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                            ),
                            onPressed: !statusButtonVisible
                                ? null
                                : () async {
                                    checkStatus(scanVin, dealerCode);
                                  },
                            child: const Text('Check Status',
                                style: TextStyle(fontSize: 12)),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 120, // <-- Your width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: !submitButtonVisible
                                  ? Colors.grey
                                  : kPrimaryColor,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                            ),
                            onPressed: !submitButtonVisible
                                ? null
                                : () async {
                                    updateStatus(scanVin, groupCode, dealerCode,
                                        dealerName);
                                  },
                            child: const Text('Submit',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        )
      ])),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          scanVin = (result!.code!.contains("#")
              ? result!.code!.substring(result!.code!.indexOf("#") + 1,
                  result!.code!.indexOf("#") + 18)
              : result!.code)!;
          if (scanVin == vin) {
            statusButtonVisible = true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Vin not matching with selected row!!!')),
            );
          }
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  checkStatus(vin, dealerCode) async {
    var data = {'type': 'Test Drive', 'vin': vin, 'dealerCode': dealerCode};

    final response = await http.get(
        Uri.parse(checkStockStatus).replace(queryParameters: data),
        headers: {"Content-Type": "application/json"});
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      submitButtonVisible = true;
      Map<String, dynamic> json = jsonDecode(response.body);
      Fluttertoast.showToast(
          msg: "${json['status']}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
  }

  updateStatus(vin, groupCode, dealerCode, dealerName) async {
    Position position = await _getGeoLocationPosition();

    String address = await getAddressFromLatLong(position);
    var data = {
      'type': 'Test Drive',
      'vin': vin,
      'groupCode': groupCode,
      'dealerCode': dealerCode,
      'dealerName': dealerName,
      'location': address,
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString()
    };

    final response = await http.post(
        Uri.parse(updateStockStatus).replace(queryParameters: data),
        headers: {"Content-Type": "application/json"});
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        submitButtonVisible = false;
        statusButtonVisible = false;
      });
      Fluttertoast.showToast(
          msg: "Stock updated!!!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
          backgroundColor: Colors.black,
          textColor: Colors.white);
      Navigator.pop(context, json['status']);
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    var address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    return address;
  }
}
