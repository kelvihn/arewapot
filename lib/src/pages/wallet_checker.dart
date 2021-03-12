import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:food_delivery_app/src/repository/wallet_repository.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:uuid/uuid.dart' as uuid;

class Walletchecker extends StatefulWidget {
  @override
  _WalletcheckerState createState() => _WalletcheckerState();
}

class _WalletcheckerState extends State<Walletchecker> {
  GlobalKey<ScaffoldState> scaffoldKey;
  TextEditingController amountController = TextEditingController();
  var publicKey = "pk_live_3dd10192d580daf45b90285fc20f0e1fb0f670c5";
  var uid = uuid.Uuid();
  GlobalKey<FormState> _paymentSettingsFormKey = new GlobalKey<FormState>();

  Future<WalletModel> walletFuture;
  @override
  void initState() {
    if (currentUser.value.id == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      });
    } else {
      walletFuture = getWalletBalance();
      PaystackPlugin.initialize(publicKey: publicKey);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: FutureBuilder<WalletModel>(
            future: walletFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.balance);
                if (int.parse(snapshot.data.balance) <= 5) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return WillPopScope(
                              onWillPop: () => SystemNavigator.pop(),
                              child: SimpleDialog(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 20),
                                titlePadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                                title: Row(
                                  children: <Widget>[
                                    Icon(Icons.credit_card),
                                    SizedBox(width: 10),
                                    Text(
                                      'Low Wallet Balance',
                                      style: Theme.of(context).textTheme.body2,
                                    )
                                  ],
                                ),
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text(
                                          'Add some money into your wallet to continue',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          )),
                                      SizedBox(height: 5),
                                      new TextFormField(
                                          controller: amountController,
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor),
                                          keyboardType: TextInputType.number,
                                          decoration: getInputDecoration(
                                              hintText: '2000',
                                              labelText: 'Amount')),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          /*
                                          scaffoldKey.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Card usage is unavailable for now. Contact the help centre to make a mobile transfer'),
                                          ));
                                          */
                                          _chargeCard(context);
                                        },
                                        child: Text(
                                          'Deposit',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.end,
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ));
                        });
                  });
                } else {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context)
                        .pushReplacementNamed('/Pages', arguments: 2);
                  });
                }
              } else if (snapshot.hasError) {
                print(snapshot.error);
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.body1.merge(
            TextStyle(color: Theme.of(context).focusColor),
          ),
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor)),
      hasFloatingPlaceholder: true,
      labelStyle: Theme.of(context).textTheme.body1.merge(
            TextStyle(color: Theme.of(context).hintColor),
          ),
    );
  }

  void _chargeCard(BuildContext context) async {
    var referenceId = uid.v1();
    int amount = int.parse(amountController.text);
    double userCharge = amount * (1.5 / 100);
    int totalAmt = userCharge.toInt() + amount;
    Charge charge = Charge()
      ..amount = totalAmt.abs() * 100
      ..email = '${currentUser.value.email}'
      ..reference = referenceId;
    try {
      CheckoutResponse response = await PaystackPlugin.checkout(context,
          method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
          charge: charge,
          logo: Image.asset('assets/img/logo.png', height: 30));
      if (response.message == 'Success') {
        updateBalance(amountController.text).whenComplete(() {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
        });
      } else {
        print('Response = $response');
      }
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'An error occured. Please try again. If error persists, kindly call our help lines'),
      ));
      print(e);
    }
  }
}
