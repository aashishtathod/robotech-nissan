import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:robotech/components/background.dart';
import 'package:robotech/model/model_inventory.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/res/custom_colors.dart';
import 'package:robotech/screens/cdr_screen.dart';
import 'package:robotech/screens/cdr_sign_off.dart';
import 'package:robotech/screens/stock_screen.dart';
import 'package:robotech/screens/test_drive_screen.dart';
import 'package:robotech/util/save_file_mobile.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class MainScreen extends StatefulWidget {
  late String? groupCode, dealerCode, dealerName , password;

  MainScreen({Key? key, this.groupCode, this.dealerCode, this.dealerName , this.password})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLoading = false;
 // String? email, password;
  String? groupCode, dealerCode, dealerName;

  @override
  void initState() {
    super.initState();
    groupCode = widget.groupCode;
    dealerCode = widget.dealerCode;
    dealerName = widget.dealerName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
          child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 120.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: <Widget>[
                     /* Image.network(
                        imageUrl + '/' + 'logo.png',
                        height: MediaQuery.of(context).size.height * .05,
                      ),*/
                      SizedBox(height: 40.w),
                      Text(
                          dealerCode == groupCode
                              ? 'Double tap on each section for sign off report'
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            color: Colors.black,
                          )),
                      SizedBox(height: 20.w),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return StockScreen(
                                      groupCode: widget.groupCode,
                                      dealerCode: widget.dealerCode,
                                      dealerName: widget.dealerName);
                                },
                              ),
                            );
                          },
                          onDoubleTap: () {
                            if (dealerCode == groupCode) {
                              generateStockSignOff(groupCode, dealerName!);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Sign off not allowed for child dealer!!!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  // also possible "TOP" and "CENTER"
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            shadowColor: Colors.blueAccent,
                            elevation: 15,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.red,
                                            width: groupCode == dealerCode
                                                ? 10
                                                : 0)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(20.0),
                                  alignment: Alignment.center,
                                  child: const Text('Stock',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Roboto',
                                        color: kPrimaryColor,
                                      ))),
                            ),
                          )),
                      SizedBox(height: 20.h),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TestDriveScreen(
                                      groupCode: widget.groupCode!,
                                      dealerCode: widget.dealerCode!,
                                      dealerName: widget.dealerName!);
                                },
                              ),
                            );
                          },
                          onDoubleTap: () {
                            if (dealerCode == groupCode) {
                              generateTestDriveSignOff(groupCode, dealerName!);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Sign off not allowed for child dealer!!!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  // also possible "TOP" and "CENTER"
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            shadowColor: Colors.blueAccent,
                            elevation: 15,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.red,
                                            width: groupCode == dealerCode
                                                ? 10
                                                : 0)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(20.0),
                                  alignment: Alignment.center,
                                  child: const Text('Test Drive',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Roboto',
                                        color: kPrimaryColor,
                                      ))),
                            ),
                          )),
                      SizedBox(height: 20.h),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return CDRScreen(
                                    groupCode: widget.groupCode!,
                                    dealerCode: widget.dealerCode!,
                                    password: widget.password!);
                              },
                            ),
                          );
                        },
                        onDoubleTap:() {
                          if (dealerCode == groupCode) {
                            generateCdrSignOff(widget.dealerCode!, widget
                                .password!, widget.dealerName!, widget.groupCode!);
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                "Sign off not allowed for child dealer!!!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                // also possible "TOP" and "CENTER"
                                backgroundColor: Colors.black,
                                textColor: Colors.white);
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          shadowColor: Colors.blueAccent,
                          elevation: 15,
                          child: ClipPath(
                            clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Colors.red,
                                          width: groupCode == dealerCode
                                              ? 10
                                              : 0)),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(20.0),
                                alignment: Alignment.center,
                                child: const Text('CDR',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Roboto',
                                      color: kPrimaryColor,
                                    ))),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ))),
    );
  }

  Future<void> generateStockSignOff(groupCode, final String dealerName) async {
    var data = {'type': 'Stock', 'groupCode': groupCode};

    final response = await http.get(
        Uri.parse(generateReport).replace(queryParameters: data),
        headers: {"Content-Type": "application/json"});
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      Fluttertoast.showToast(
          msg: "Generating stock sign off report!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // also possible "TOP" and "CENTER"
          backgroundColor: Colors.black,
          textColor: Colors.white);
      //Create a PDF document.
      final PdfDocument document = PdfDocument();
      //Add page to the PDF
      final PdfPage page = document.pages.add();
      //Get page client size
      final Size pageSize = page.getClientSize();
      //Draw rectangle
      page.graphics.drawRectangle(
          bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
          pen: PdfPen(PdfColor(142, 170, 219, 255)));
      //Generate PDF grid.
      final PdfGrid grid = getGridStock(
          json['count'],
          json['found'],
          json['notFound'],
          json['preReported'],
          json['excess'],
          json['transit'],
          json['total']);
      //Draw the header section by creating text element
      final PdfLayoutResult result =
          drawHeaderStock(page, pageSize, grid, dealerName, groupCode);
      //Get second grid
      dynamic jsonObject = json['stock'];
      final convertedJsonObject = jsonObject.cast<Map<String, dynamic>>();
      List<Inventory> inventoryList = convertedJsonObject
          .map<Inventory>((json) => Inventory.fromJson(json))
          .toList();
      final PdfGrid grid2 = getGrid2Stock(
          json['count'],
          json['found'],
          json['notFound'],
          json['preReported'],
          json['excess'],
          json['transit'],
          json['total'],
          inventoryList);

      //Draw grid
      drawGridStock(page, grid, grid2, result);
      //Save the PDF document
      final List<int> bytes = document.save();
      //Dispose the document.
      document.dispose();
      //Save and launch the file.
      await saveAndLaunchFile(bytes, groupCode + '_Stock_report.pdf');
    }
  }

  //Draws the invoice header
  PdfLayoutResult drawHeaderStock(PdfPage page, Size pageSize, PdfGrid grid,
      final String dealerName, final String groupCode) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width, 40));
    //Draw string
    page.graphics.drawString(
        'Stock Signoff Report', PdfStandardFont(PdfFontFamily.helvetica, 15),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width, 40),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    //Create data foramt and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    final String invoiceNumber = 'Invoice Number: 2058557939\r\n\r\nDate: ' +
        format.format(DateTime.now());
    final Size contentSize = contentFont.measureString(invoiceNumber);
    // ignore: leading_newlines_in_multiline_strings
    String address = "Dealer Name : " +
        dealerName +
        "\r\nGroup Code : " +
        groupCode +
        "\r\nVerification Date : \r\nVerified by : \r\nName of dealer representative : \r\nSignature & Stamp : \r\nDate :";

    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(27, 50, pageSize.width - (contentSize.width + 30),
            pageSize.height - 120))!;
  }

  //Draws the grid
  void drawGridStock(
      PdfPage page, PdfGrid grid, PdfGrid grid2, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;

    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };

    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

    //Invoke the beginCellLayout event.
    grid2.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid2.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
  }

  //Create PDF grid and return
  PdfGrid getGridStock(int count, int found, int notFound, int preReported,
      int excess, int transit, int total) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 6);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Stock mapped with NMIPL';
    //headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    //headerRow.cells[0].style
    headerRow.cells[1].value = 'Excess Stocks';
    headerRow.cells[2].value = 'Stock not available';
    headerRow.cells[3].value = 'Transit Vehicle Received';
    headerRow.cells[4].value = 'Pre-Reported';
    headerRow.cells[5].value = 'Total';
    //Add rows
    addRowStock(found, excess, notFound, transit, preReported, total, grid);
    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);

    //Set gird columns width
    //grid.columns[0].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  PdfGrid getGrid2Stock(int count, int found, int notFound, int preReported,
      int excess, int transit, int total, List<Inventory> inventoryList) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 11);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Dealer Code';
    //headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    //headerRow.cells[0].style
    headerRow.cells[1].value = 'Source Data';
    headerRow.cells[2].value = 'VIN';
    headerRow.cells[3].value = 'Model';
    headerRow.cells[4].value = 'Variant';
    headerRow.cells[5].value = 'Found';
    headerRow.cells[6].value = 'Not Found';
    headerRow.cells[7].value = 'Pre-Reported';
    headerRow.cells[8].value = 'Transit Vehicle Received';
    headerRow.cells[9].value = 'Excess Stocks';
    headerRow.cells[10].value = 'Total';
    //Add rows
    for (var inventory in inventoryList) {
      String otherStatus = "Not Found";
      if (inventory.status == 'Stock' && inventory.otherStatus == 'Found') {
        otherStatus = "Found";
      } else if (inventory.status == 'Retail' &&
          inventory.otherStatus == 'Pre-Reported') {
        otherStatus = "Pre-Reported";
      } else if (inventory.status == 'Stock Excess' &&
          inventory.otherStatus == 'Excess') {
        otherStatus = "Excess";
      } else if (inventory.status == 'Transit') {
        otherStatus = "Transit";
      } else if (inventory.status == 'Not Found') {
        otherStatus = "Not Found";
      }
      addRow2Stock(inventory.dealerCode, inventory.vin, inventory.status,
          inventory.model, inventory.variant, otherStatus, grid);
    }

    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Grand Total';
    row.cells[5].value = found.toString();
    row.cells[6].value = notFound.toString();
    row.cells[7].value = preReported.toString();
    row.cells[8].value = transit.toString();
    row.cells[9].value = excess.toString();
    row.cells[10].value = total.toString();

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    //grid.columns[0].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void addRowStock(int found, int excess, int notFound, int transit,
      int preReported, int total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = found.toString();
    row.cells[1].value = excess.toString();
    row.cells[2].value = notFound.toString();
    row.cells[3].value = transit.toString();
    row.cells[4].value = preReported.toString();
    row.cells[5].value = total.toString();
  }

  void addRow2Stock(String dealerCode, String vin, String status, String? model,
      String? variant, String otherStatus, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = dealerCode;
    row.cells[1].value = status;
    row.cells[2].value = vin;
    row.cells[3].value = model ?? "";
    row.cells[4].value = variant ?? "";
    if (otherStatus == 'Found') {
      row.cells[5].value = "1";
    } else if (otherStatus == 'Pre-Reported') {
      row.cells[7].value = "1";
    } else if (otherStatus == 'Excess') {
      row.cells[9].value = "1";
    } else if (otherStatus == 'Transit') {
      row.cells[8].value = "1";
    } else if (otherStatus == 'Not Found') {
      row.cells[6].value = "1";
    }
  }

  // Test Drive Start
  Future<void> generateTestDriveSignOff(
      groupCode, final String dealerName) async {
    var data = {'type': 'Test Drive', 'groupCode': groupCode};

    final response = await http.get(
        Uri.parse(generateReport).replace(queryParameters: data),
        headers: {"Content-Type": "application/json"});
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      Fluttertoast.showToast(
          msg: "Generating test drive sign off report!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          // also possible "TOP" and "CENTER"
          backgroundColor: Colors.black,
          textColor: Colors.white);
      //Create a PDF document.
      final PdfDocument document = PdfDocument();
      //Add page to the PDF
      final PdfPage page = document.pages.add();
      //Get page client size
      final Size pageSize = page.getClientSize();
      //Draw rectangle
      page.graphics.drawRectangle(
          bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
          pen: PdfPen(PdfColor(142, 170, 219, 255)));
      //Generate PDF grid.
      dynamic jsonObject = json['stock'];
      final convertedJsonObject = jsonObject.cast<Map<String, dynamic>>();
      List<Inventory> inventoryList = convertedJsonObject
          .map<Inventory>((json) => Inventory.fromJson(json))
          .toList();
      final PdfGrid grid = getGridTestDrive(
          json['found'], json['notFound'], json['total'], inventoryList);
      //Draw the header section by creating text element
      final PdfLayoutResult result =
          drawHeaderTestDrive(page, pageSize, grid, dealerName, groupCode);

      //Draw grid
      drawGridTestDrive(page, grid, result);
      //Save the PDF document
      final List<int> bytes = document.save();
      //Dispose the document.
      document.dispose();
      //Save and launch the file.
      await saveAndLaunchFile(bytes, groupCode + '_TD_report.pdf');
    }
  }

  //Draws the invoice header
  PdfLayoutResult drawHeaderTestDrive(PdfPage page, Size pageSize, PdfGrid grid,
      final String dealerName, final String groupCode) {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width, 40));
    //Draw string
    page.graphics.drawString('Test Drive Signoff Report',
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width, 40),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

    //Create data foramt and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    final String invoiceNumber = 'Invoice Number: 2058557939\r\n\r\nDate: ' +
        format.format(DateTime.now());
    final Size contentSize = contentFont.measureString(invoiceNumber);
    // ignore: leading_newlines_in_multiline_strings
    String address = "Dealer Name : " +
        dealerName +
        "\r\nGroup Code : " +
        groupCode +
        "\r\nVerification Date : \r\nVerified by : \r\nName of dealer representative : \r\nSignature & Stamp : \r\nDate :";

    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(27, 50, pageSize.width - (contentSize.width + 30),
            pageSize.height - 120))!;
  }

  //Draws the grid
  void drawGridTestDrive(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;

    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };

    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
  }

  PdfGrid getGridTestDrive(
      int found, int notFound, int total, List<Inventory> inventoryList) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 9);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Dealer Code';
    //headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    //headerRow.cells[0].style
    headerRow.cells[1].value = 'Source Data';
    headerRow.cells[2].value = 'VIN';
    headerRow.cells[3].value = 'Model';
    headerRow.cells[4].value = 'Variant';
    headerRow.cells[5].value = 'Color';
    headerRow.cells[6].value = 'Found';
    headerRow.cells[7].value = 'Not Found';
    headerRow.cells[8].value = 'Total';
    //Add rows
    for (var inventory in inventoryList) {
      String otherStatus = "Not Found";
      if (inventory.otherStatus == 'Found') {
        otherStatus = "Found";
      } else if (inventory.status == 'Not Found') {
        otherStatus = "Not Found";
      }
      addRow2TestDrive(
          inventory.dealerCode,
          inventory.vin,
          inventory.status,
          inventory.model,
          inventory.variant,
          inventory.color,
          otherStatus,
          grid);
    }

    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Grand Total';
    row.cells[6].value = found.toString();
    row.cells[7].value = notFound.toString();
    row.cells[8].value = total.toString();

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    //grid.columns[0].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  void addRow2TestDrive(
      String dealerCode,
      String vin,
      String status,
      String? model,
      String? variant,
      String? color,
      String otherStatus,
      PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = dealerCode;
    row.cells[1].value = status;
    row.cells[2].value = vin;
    row.cells[3].value = model ?? "";
    row.cells[4].value = variant ?? "";
    row.cells[5].value = color ?? "";
    if (otherStatus == 'Found') {
      row.cells[6].value = "1";
    } else if (otherStatus == 'Not Found') {
      row.cells[7].value = "1";
    }
  }


}
