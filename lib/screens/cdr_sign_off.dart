import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:robotech/model/model_getCdrData.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/util/save_file_mobile.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

generateCdrSignOff(String dealerCode, String password, String dealerName,
    String groupCode) async {
  AsyncMemoizer _memoizer = AsyncMemoizer();
  try {
    _memoizer.runOnce(() async {
      await Future.delayed(const Duration(seconds: 1));
      var data = {'username': dealerCode, 'password': password};

      final response =
          await http.get(Uri.parse(getCdrDAta).replace(queryParameters: data));

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

        final PdfDocument document = PdfDocument();
        //Add page to the PDF
        final PdfPage page = document.pages.add();
        //Get page client size
        final Size pageSize = page.getClientSize();
        //Draw rectangle
        page.graphics.drawRectangle(
            bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
            pen: PdfPen(PdfColor(142, 170, 219, 255)));

        final PdfGrid grid = getGridCdr(data.data);

        //Draw the header section by creating text element
        final PdfLayoutResult result =
            drawHeaderCdr(page, pageSize, grid, dealerName, groupCode);

        //Draw grid
        drawGridCdr(page, grid, result);

        final List<int> bytes = document.save();
        //Dispose the document.
        document.dispose();
        //Save and launch the file.
        await saveAndLaunchFile(bytes, dealerCode + '_CDR_report.pdf');
      } else {
        createPdfErrorToast();
      }
    });
  } catch (e) {
    createPdfErrorToast();
  }
}

PdfGrid getGridCdr(List<Datum> datumList) {
  //Create a PDF grid
  final PdfGrid grid = PdfGrid();
  //Secify the columns count to the grid.
  grid.columns.add(count: 10);
  //Create the header row of the grid.
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  //Set style
  headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
  headerRow.style.textBrush = PdfBrushes.white;
  headerRow.cells[0].value = 'Vin';
  //headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
  //headerRow.cells[0].style
  headerRow.cells[1].value = 'Make';
  headerRow.cells[2].value = 'Model';
  headerRow.cells[3].value = 'Variant';
  headerRow.cells[4].value = 'Customer\nBooking\nForm';
  headerRow.cells[5].value = 'Retail\nInvoice';
  headerRow.cells[6].value = 'DMS Gate\nPass';
  headerRow.cells[7].value = 'Proof of\nPayment';
  headerRow.cells[8].value = 'Registration\nDocument';
  headerRow.cells[9].value = 'Remark';
  //Add rows
  for (var datum in datumList) {
    addRow2CdrPdf(datum, grid);
  }

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

void addRow2CdrPdf(Datum datum, PdfGrid grid) {
  final PdfGridRow row = grid.rows.add();
  row.cells[0].value = datum.vin;
  row.cells[1].value = datum.make;
  row.cells[2].value = datum.mmodel;
  row.cells[3].value = datum.variant ?? "";
  row.cells[4].value =
      datum.customerBookingForm ?? "";
  row.cells[5].value = datum.dmsRetailInv ?? "";
  row.cells[6].value = datum.dmsGatePass ?? "";
  row.cells[7].value = datum.paymentProf ?? "";
  row.cells[8].value =
      datum.registrationDocument ?? "";
  row.cells[9].value = datum.remark ?? "";
}

//Draws the invoice header
PdfLayoutResult drawHeaderCdr(PdfPage page, Size pageSize, PdfGrid grid,
    final String dealerName, final String groupCode) {
  //Draw rectangle
  page.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
      bounds: Rect.fromLTWH(0, 0, pageSize.width, 40));
  //Draw string
  page.graphics.drawString(
      'CDR Signoff Report', PdfStandardFont(PdfFontFamily.helvetica, 15),
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
void drawGridCdr(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
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

createPdfErrorToast() {
  return Fluttertoast.showToast(
      msg: "Error occurred while generating pdf",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      // also possible "TOP" and "CENTER"
      backgroundColor: Colors.black,
      textColor: Colors.white);
}
