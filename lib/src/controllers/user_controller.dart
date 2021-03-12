import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    });
  }

  _loader() {
    print('Loader called');
    return showDialog(
        barrierDismissible: false,
        context: scaffoldKey.currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ));
        });
  }

  Future<void> login() async {
    _loader();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      repository.login(user).then((value) {
        //print(value.apiToken);
        if (value != null && value.apiToken != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.welcome + value.name),
          ));
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          Navigator.pop(scaffoldKey.currentContext);
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.wrong_email_or_password),
          ));
        }
      });
    }
  }

  Future<void> register(number, refCode) async {
    _loader();
    user.phone = number;
    user.refCode = refCode;
    //print(user);
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      repository.register(user).then((value) {
        if (value != null || value.id != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Registration successful!'),
          ));
          Timer(Duration(seconds: 3), () {
            Navigator.of(scaffoldKey.currentContext)
                .pushReplacementNamed('/Login');
          });

          // return 'error';
        } else {
          Navigator.pop(scaffoldKey.currentContext);
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('An error occured. Please try again'),
          ));
        }
      });
    }
  }

  void resetPassword() {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content:
                Text(S.current.your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.current.login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(S.current.error_verify_email_settings),
          ));
        }
      });
    }
  }
}
