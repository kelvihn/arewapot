import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      info?.updateAvailable == true
          ? InAppUpdate.performImmediateUpdate()
              .catchError((e) => _showError(e))
          : Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }).catchError((e) => _showError(e));
  }

  void _showError(dynamic exception) {
    _con.scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    //loadData();
  }

  void loadData() {
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logo.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
