import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/wallet_controller.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/PermissionDeniedWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import '../repository/wallet_repository.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:uuid/uuid.dart' as uuid;

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends StateMVC<Wallet> {
  WalletController _con;

  _WalletState() : super(WalletController()) {
    _con = controller;
  }

  var publicKey = "pk_live_3dd10192d580daf45b90285fc20f0e1fb0f670c5";
  var uid = uuid.Uuid();
  Future<WalletModel> walletFuture;
  TextEditingController cardController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    walletFuture = getWalletBalance();
    PaystackPlugin.initialize(publicKey: publicKey);
    super.initState();
  }


  void _chargeCard(BuildContext context) async {
    var referenceId = uid.v1();
    var amount = int.parse(amountController.text);
    Charge charge = Charge()
      ..amount = amount.abs() * 100
      ..email = '${currentUser.value.email}'
      ..reference = referenceId;
    try {
      CheckoutResponse response = await PaystackPlugin.checkout(context,
          method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
          charge: charge,
          logo: Image.asset('assets/img/logo.png', height: 30));
      if (response.message == 'Success') {
        updateBalance(amount.abs());
      } else {
        print('Response = $response');
      }
    } catch (e) {
      _con.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'An error occured. Please try again. If error persists, kindly call our help lines'),
      ));
      print(e);
    }
  }
  

  GlobalKey<FormState> _paymentSettingsFormKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          leading: new IconButton(
            icon:
                new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: ValueListenableBuilder(
            valueListenable: settingsRepo.setting,
            builder: (context, value, child) {
              return Text(
                'Wallet',
                style: Theme.of(context)
                    .textTheme
                    .title
                    .merge(TextStyle(letterSpacing: 1.3)),
              );
            },
          ),
          actions: <Widget>[
            new ShoppingCartButtonWidget(
                iconColor: Theme.of(context).hintColor,
                labelColor: Theme.of(context).accentColor),
          ],
        ),
        drawer: DrawerWidget(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: currentUser.value.apiToken == null
            ? PermissionDeniedWidget()
            : SingleChildScrollView(
                child: FutureBuilder<WalletModel>(
                future: walletFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        walletCard(snapshot.data.balance),
                        SizedBox(height: 8),
                        Divider(),
                        SizedBox(height: 20),
                        depositBtn(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                        child: Text(
                            "Oops, an error occured. \nPlease try again",
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 18)));
                  }

                  // By default, show a loading spinner.
                  return Center(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: CircularProgressIndicator()));
                },
              )));
  }

  Widget walletCard(String balance) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.green.withOpacity(.6)),
            child: Center(
                child: Icon(Entypo.wallet, color: Colors.green, size: 50))),
        SizedBox(width: 25),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (balance == null)
                  ? Text("Loading...",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 22))
                  : Text("₦$balance.00",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 22)),
              SizedBox(height: 5),
              Text('Balance',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ]),
      ]),
    );
  }

  Widget depositBtn() {
    return GestureDetector(
        onTap: () {
          /*
          _con.scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
                'Card usage is unavailable for now. Contact the help centre to make a mobile transfer'),
          ));
          */

          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  titlePadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  title: Row(
                    children: <Widget>[
                      Icon(Icons.credit_card),
                      SizedBox(width: 10),
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.body2,
                      )
                    ],
                  ),
                  children: <Widget>[
                    Form(
                      key: _paymentSettingsFormKey,
                      child: Column(
                        children: <Widget>[
                          new TextFormField(
                              controller: amountController,
                              style:
                                  TextStyle(color: Theme.of(context).hintColor),
                              keyboardType: TextInputType.number,
                              decoration: getInputDecoration(
                                  hintText: '2000', labelText: 'Amount')),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(S.of(context).cancel),
                        ),
                        MaterialButton(
                          onPressed: () {
                            _chargeCard(context);
                          },
                          child: Text(
                            'Deposit',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    SizedBox(height: 10),
                  ],
                );
              });
        },
        child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green, Colors.green[700]],
                    stops: [0.1, 0.9]),
                borderRadius: BorderRadius.circular(25)),
            child: Center(
                child: Text('Add money',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)))));
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
}
