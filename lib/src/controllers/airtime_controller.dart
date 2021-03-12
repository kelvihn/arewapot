import 'dart:io';
import '../repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
//import 'dart:math' show Random;
import 'dart:convert';

const PUBLIC_KEY = '3fe8346605ba60c88fac561ca3c284c5';
const PRIVATE_KEY =
    'f1147a31aa4ca6c25c621c2b1954d5cd65c269265a93410a1e3e783bbd2afb2b113d1eed6591060b511961e4c04bce6bbc5f0fcf0649bac944fe338fa9e3c638';
const VENDOR_CODE = '2005D60D35';

class AirtimeController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;

  AirtimeController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<dynamic> recharge({number, amount, carrier}) async {
    final referenceId = randomNumeric(12);
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}recharge';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        'email': currentUser.value.email,
        'number': number,
        'amount': amount,
        'carrier': carrier,
        'reference_id': referenceId,
        'public_key': PUBLIC_KEY,
        'private_key': PRIVATE_KEY,
        'vendor_code': VENDOR_CODE,
        'user_id': currentUser.value.id
      }),
    );
    if (response.statusCode == 200) {
      var message = json.decode(response.body);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('$message'),
      ));
    } else {
      print(response.body);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('An error occured. Please try again'),
      ));
    }
  }
}
