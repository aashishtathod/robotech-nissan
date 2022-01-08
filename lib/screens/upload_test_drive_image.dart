import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:robotech/components/profile_widget.dart';
import 'package:robotech/res/constants.dart';

String name = "";

class UploadTestDriveImagesPage extends StatefulWidget {
  late String? groupCode,
      dealerCode,
      dealerName,
      vin,
      image1,
      image2,
      image3,
      image4,
      image5,
      image6,
      image7;

  UploadTestDriveImagesPage(
      {Key? key,
      this.groupCode,
      this.dealerCode,
      this.dealerName,
      this.vin,
      this.image1,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.image7})
      : super(key: key);

  @override
  _UploadTestDriveImagesPageState createState() =>
      _UploadTestDriveImagesPageState();
}

class _UploadTestDriveImagesPageState extends State<UploadTestDriveImagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: GoogleFonts.roboto(fontSize: 20.0)),
      ),
      body: ProfileViewPage(
          groupCode: widget.groupCode,
          dealerCode: widget.dealerCode,
          dealerName: widget.dealerName,
          vin: widget.vin,
          image1: widget.image1,
          image2: widget.image2,
          image3: widget.image3,
          image4: widget.image4,
          image5: widget.image5,
          image6: widget.image6,
          image7: widget.image7),
    );
  }
}

class ProfileViewPage extends StatefulWidget {
  late String? groupCode,
      dealerCode,
      dealerName,
      vin,
      image1,
      image2,
      image3,
      image4,
      image5,
      image6,
      image7;

  ProfileViewPage(
      {Key? key,
      this.groupCode,
      this.dealerCode,
      this.dealerName,
      this.vin,
      this.image1,
      this.image2,
      this.image3,
      this.image4,
      this.image5,
      this.image6,
      this.image7})
      : super(key: key);

  @override
  ProfileViewPageState createState() => ProfileViewPageState();
}

class ProfileViewPageState extends State<ProfileViewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late PickedFile _imageFile;
  late File _selectedFile;
  dynamic _pickImageError;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _userView(context);
  }

  Form _userView(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ProfileWidget(
                      imagePath: (widget.image1 == "")
                          ? imageUrl + "/front.png"
                          : picUrl + "/" + widget.image1!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image1', widget.vin, widget.dealerCode);
                      },
                      text: "Front"),
                  ProfileWidget(
                      imagePath: (widget.image2 == "")
                          ? imageUrl + "/back.png"
                          : picUrl + "/" + widget.image2!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image2', widget.vin, widget.dealerCode);
                      },
                      text: "Back"),
                  ProfileWidget(
                      imagePath: (widget.image3 == "")
                          ? imageUrl + "/left.png"
                          : picUrl + "/" + widget.image3!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image3', widget.vin, widget.dealerCode);
                      },
                      text: "Left"),
                ]),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ProfileWidget(
                      imagePath: (widget.image4 == "")
                          ? imageUrl + "/right.png"
                          : picUrl + "/" + widget.image4!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image4', widget.vin, widget.dealerCode);
                      },
                      text: "Right"),
                  ProfileWidget(
                      imagePath: (widget.image5 == "")
                          ? imageUrl + "/interior.png"
                          : picUrl + "/" + widget.image5!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image5', widget.vin, widget.dealerCode);
                      },
                      text: "Interior"),
                  ProfileWidget(
                      imagePath: (widget.image6 == "")
                          ? imageUrl + "/odometer.png"
                          : picUrl + "/" + widget.image1!,
                      isEdit: true,
                      onClicked: () async {
                        getImageCamera('image6', widget.vin, widget.dealerCode);
                      },
                      text: "Odometer"),
                ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ProfileWidget(
                  imagePath: (widget.image7 == "")
                      ? imageUrl + "/car.png"
                      : picUrl + "/" + widget.image7!,
                  isEdit: true,
                  onClicked: () async {
                    getImageCamera('image7', widget.vin, widget.dealerCode);
                  },
                  text: "Misc"),
            ]),
            const SizedBox(height: 24),
          ],
        ));
  }

  Future getImageCamera(String type, String? vin, String? dealerCode) async {
    try {
      _imageFile = (await _picker.getImage(source: ImageSource.camera))!;
      _selectedFile = File(_imageFile.path);

      var data = {'vin': vin, 'type': type, 'dealerCode': dealerCode};
      final response = await http.post(
        Uri.parse(saveTestDriveImage).replace(queryParameters: data),
        body: {
          // ignore: unnecessary_null_comparison
          'photo': _imageFile != null
              ? 'data:image/png;base64,' +
                  base64Encode(_selectedFile.readAsBytesSync())
              : '',
        },
      );
      setState(() {
        if (type == 'image1') {
          widget.image1 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image2') {
          widget.image2 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image3') {
          widget.image3 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image4') {
          widget.image4 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image5') {
          widget.image5 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image6') {
          widget.image6 = widget.vin! + "_" + type + ".png";
        } else if (type == 'image7') {
          widget.image7 = widget.vin! + "_" + type + ".png";
        }
      });
      if (response.statusCode == 200) {
      } else {
        log(response);
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }
}
