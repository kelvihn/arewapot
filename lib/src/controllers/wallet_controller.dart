import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/wallet_repository.dart';

class WalletController extends ControllerMVC {
  String walletBalance;
  GlobalKey<ScaffoldState> scaffoldKey;

  WalletController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForBalance() async {
    /*
    final Stream stream = await getWalletBalance();
    stream.listen((_balance) {
      setState(() => walletBalance = _balance);
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text('Balance fetched'),
      ));
    });
    */
  }
}
