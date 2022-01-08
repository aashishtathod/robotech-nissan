import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget createText1(String curText) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Text(
      curText,
      style: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.grey),
    ),
  );
}

Widget createText2(String curText) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Text(
      curText,
      style: TextStyle(
          fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black),
    ),
  );
}

Widget createText3(String curText) {
  return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Text(
        curText,
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: (curText == "NO")
                ? Colors.red
                : (curText == "no")
                    ? Colors.red
                    : (curText == "No"
                        ? Colors.red
                        : (curText == "nO")
                            ? Colors.red
                            : Colors.green)),
      ));
}
/*  try {
        var yesNoData = {
          "customer_booking_form": (one) ? "Yes" : "No",
          "DMS_retail_inv": (two) ? "Yes" : "No",
          "DMS_gate_pass": (three) ? "Yes" : "No",
          "payment_prof": (four) ? "Yes" : "No",
          "registration_document": (five) ? "Yes" : "No",
          "username": widget.dealerCode.toString(),
          "password": widget.password.toString(),
          "id": widget.id.toString(),
          "remark": _textEditingController.text.toString(),


        };

        var imageData = {
          "username": widget.dealerCode.toString(),
          "password": widget.password.toString(),
          "id": widget.id.toString(),
          "customer_booking_image": _imageFile1 != null
              ? 'data:image/png;base64,' +
              base64Encode(_selectedFile1!.readAsBytesSync())
              : '',
          "dms_retail_image": _imageFile2 != null
              ? 'data:image/png;base64,' +
              base64Encode(_selectedFile2!.readAsBytesSync())
              : '',
          "dms_gate_pass_image": _imageFile3 != null
              ? 'data:image/png;base64,' +
              base64Encode(_selectedFile3!.readAsBytesSync())
              : '',
          "proof_payment_image": _imageFile4 != null
              ? 'data:image/png;base64,' +
              base64Encode(_selectedFile4!.readAsBytesSync())
              : '',
          "registration_document_image": _imageFile5 != null
              ? 'data:image/png;base64,' +
              base64Encode(_selectedFile5!.readAsBytesSync())
              : '',
        };

        var response1 = await http.post(
            Uri.parse(postCdrData), body: imageData);

        print(response1.body);
        if (response1.statusCode == 200) {
          print(response1);
        try  {
            var response2 = await http.post(
                Uri.parse(postCdrData), body: yesNoData);
            if (response2.statusCode == 200) {
              showAlertDialog(
                  context, "Success", "Data uploaded successfully.");
            } else {
              createSnackBar("Failed to upload data.");
            }
          }catch (e) {
          print(e);
          createSnackBar("Failed to upload data.");
        }
        } else {
          createSnackBar("Failed to upload data.");
        }
      } catch (e) {
        print(e);
        createSnackBar("Failed to upload data.");
      }*/