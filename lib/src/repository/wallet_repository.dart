import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import '../repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<WalletModel> getWalletBalance() async {
  print(currentUser.value.id);
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}get-wallet-balance';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({'user_id': currentUser.value.id}),
  );

  return WalletModel.fromJson(json.decode(response.body));
}

Future updateBalance(amount) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}update-wallet';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({'user_id': currentUser.value.id, 'amount': amount}),
  );
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    print(response.body);
  }

  //return json.decode(response.body);
}

Future<bool> deduct(amount) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}deduct-pay';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({'user_id': currentUser.value.id, 'amount': amount}),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(response.body);
    return false;
  }
}
