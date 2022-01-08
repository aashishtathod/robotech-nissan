import 'dart:convert';

import 'package:robotech/components/background.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? email, password;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
          child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 120.h,
          ),
          child: Column(
            //mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Image.network(
                  imageUrl + '/' + 'splash_page.png',
                  height: MediaQuery.of(context).size.height * 1,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: size.width * 0.8,
                child: TextFormField(
                  maxLength: 4,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: kPrimaryColor,
                    ),
                    border: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide.none,
                    ),
                    counterText: "",
                    errorStyle: TextStyle(color: Colors.red),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor: kPrimaryLightColor,
                    hintText: "Username",
                  ),
                  controller: _usernameController,
                  onChanged: (value) {
                    _usernameController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: _usernameController.selection);
                  },
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (val) {
                    email = val;
                  },
                ),
              ),
              SizedBox(
                width: size.width * 0.8,
                child: TextFormField(
                  obscureText: _isHidden,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: kPrimaryColor,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: InkWell(
                        onTap: _togglePasswordView,
                        child: Icon(
                          _isHidden ? Icons.visibility : Icons.visibility_off,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.red),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(90.0)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor: kPrimaryLightColor,
                    hintText: 'Password',
                  ),
                  controller: _passwordController,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    email = val;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                    primary: kPrimaryColor,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29.0),
                    ),
                  ),
                  onPressed: () {
                    if (isLoading) {
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                     // print("${_usernameController.text} ${_passwordController.text}" );
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                      login(_usernameController.text, _passwordController.text);
                      setState(() {
                        isLoading = true;
                      });
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      )),
    );
  }

  login(username, password) async {

    var data = {'username': username, 'password': password};
    final response = await http.get(
        Uri.parse(validateUser).replace(queryParameters: data),
        headers: {"Content-Type": "application/json"});
    setState(() {
      isLoading = false;
    });
   // print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      print(response.body);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MainScreen(
                groupCode: json['group_code'],
                dealerCode: json['dealer_code'],
                dealerName: json['dealer_name'],
            password: password,);
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Mobile or Password")));
    }
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
