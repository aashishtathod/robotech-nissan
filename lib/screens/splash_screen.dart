import 'package:robotech/components/background.dart';
import 'package:robotech/res/constants.dart';
import 'package:robotech/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:async';

bool? loggedIn = false;
String? role = "", state = "", name = "";

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs;

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool("loggedIn");
    role = prefs.getString("role");
    state = prefs.getString("state");
    name = prefs.getString("name");
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();

    _mockCheckForSession().then((status) {
      if (status) {
        if (loggedIn != null && loggedIn == true) {
          loggedIn != null &&
                  loggedIn == true &&
                  role != null &&
                  role!.isNotEmpty
              ? state == 'Location'
                  ? _navigateToLocation()
                  : state == 'Product'
                      ? _navigateToProduct()
                      : state == 'Profile'
                          ? _navigateToProfile()
                          : _navigateToDashboard()
              : _navigateToLogin();
        } else {
          loggedIn != null && loggedIn == true && role!.isNotEmpty
              ? state == 'Location'
                  ? _navigateToLocation()
                  : state == 'Product'
                      ? _navigateToProduct()
                      : state == 'Profile'
                          ? _navigateToProfile()
                          : _navigateToDashboard()
              : _navigateToLogin();
        }
      }
    });
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    return true;
  }

  void _navigateToLocation() {
    /*Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            SelectLocationPage(role: role, sourcePage: 'Main')));*/
  }

  void _navigateToProduct() {
    /*Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            ProductListPage1(sourcePage: 'Main')));*/
  }

  void _navigateToProfile() {
    /*Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            EditProfilePage(sourcePage: 'Main', role: role)));*/
  }

  void _navigateToDashboard() {
    /*Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            DashboardPage1(role: role, name: name)));*/
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Background(
          child: Center(
              child: Column(
            children: <Widget>[
              Image.network(
                imageUrl + '/' + 'splash_page.png',
                height: MediaQuery.of(context).size.height * 1,
              ),
            ],
          )),
        ));
  }
}
