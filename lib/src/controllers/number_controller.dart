import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class NumberController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;

  NumberController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> insertNumber({number, id}) async {
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}insert-number';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'number': number, 'user_id': id}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
}
