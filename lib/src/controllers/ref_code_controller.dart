import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/ref_code.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../repository/user_repository.dart';

class RefCodeController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;

  RefCodeController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> getRefs() async {
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}get-referrals';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'user_id': currentUser.value.id}),
    );
    var success = json.decode(response.body)['success'];
    var message = json.decode(response.body)['message'];
    if (success == false && message == 'no code') {
      throw 'You do not have any code';
    } else if (success == false && message == 'no refers') {
      throw 'You do not have any referrals';
    } else {
      return RefCodeModel.fromJSON(json.decode(response.body));
    }
  }
}
