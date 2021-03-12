import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/airtime_controller.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/PermissionDeniedWidget.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:food_delivery_app/src/repository/wallet_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart';

class Airtime extends StatefulWidget {
  Airtime({Key key}) : super(key: key);
  @override
  _AirtimeState createState() => _AirtimeState();
}

class _AirtimeState extends StateMVC<Airtime> {
  AirtimeController _con;

  _AirtimeState() : super(AirtimeController()) {
    _con = controller;
  }

  TextEditingController numberController;
  TextEditingController emailController;
  TextEditingController amountController;
  Future<WalletModel> walletFuture;
  @override
  void initState() {
    walletFuture = getWalletBalance();
    numberController = new TextEditingController();
    emailController = new TextEditingController();
    amountController = new TextEditingController();
    super.initState();
  }

  String selectedItem;
  var balance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
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
              'Airtime Recharge',
              style: Theme.of(context)
                  .textTheme
                  .title
                  .merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
//        title: Text(
//          settingsRepo.setting?.value.appName ?? S.of(context).home,
//          style: Theme.of(context).textTheme.title.merge(TextStyle(letterSpacing: 1.3)),
//        ),
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
                  balance = snapshot.data.balance;
                  return Column(children: [
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      children: [
                        Text('Your Balance',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        SizedBox(height: 5),
                        Text('₦${snapshot.data.balance}.00',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 35))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    textFieldOne(),
                    SizedBox(
                      height: 30,
                    ),
                    carrierNetwork(),
                    SizedBox(
                      height: 30,
                    ),
                    amount(),
                    SizedBox(
                      height: 50,
                    ),
                    depositBtn()
                  ]);
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                      child: Text("Oops, an error occured. \nPlease try again",
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
            )),
    );
  }

  Widget textFieldOne() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Theme.of(context).focusColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Icon(Icons.phone, color: Theme.of(context).accentColor),
          ),
          Expanded(
              child: TextField(
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  decoration: InputDecoration.collapsed(
                      hintStyle: TextStyle(fontSize: 12),
                      hintText: 'Phone Number - 080XXXXXXXX')))
        ],
      ),
    );
  }

  Widget carrierNetwork() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Theme.of(context).focusColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration.collapsed(hintText: ''),
          isExpanded: true,
          iconEnabledColor: config.Colors().mainDarkColor(1),
          value: selectedItem,
          validator: (String newValue) {
            if (newValue == null) {
              return 'Please select a network';
            }
            return null;
          },
          hint: Text(
            'Select a network',
            style: Theme.of(context).textTheme.subhead,
          ),
          style: TextStyle(
            color: Color(0xff02499B),
          ),
          onChanged: (String newValue) {
            setState(() {
              selectedItem = newValue;
            });
          },
          items: <String>[
            'MTN',
            'Airtel',
            '9mobile',
            'Glo',
          ].map<DropdownMenuItem<String>>((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child:
                  new Text(value, style: Theme.of(context).textTheme.subhead),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget amount() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.40,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text('₦',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 18))),
            Expanded(
                child: TextField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    decoration: InputDecoration.collapsed(
                        hintStyle: TextStyle(fontSize: 12),
                        hintText: 'Amount')))
          ],
        ),
      )
    ]);
  }

  Widget email() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Theme.of(context).focusColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child:
                Icon(Icons.mail_outline, color: Theme.of(context).accentColor),
          ),
          Expanded(
              child: TextField(
                  controller: emailController,
                  decoration: InputDecoration.collapsed(
                      hintStyle: TextStyle(fontSize: 12), hintText: 'Email')))
        ],
      ),
    );
  }

  Widget btnText = Text('RECHARGE NOW',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600));

  Widget depositBtn() {
    return GestureDetector(
        onTap: () {
          if (numberController.text == '' ||
              amountController.text == '' ||
              selectedItem == null) {
            _con.scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Please fill all required details'),
            ));
          } else if (int.parse(balance) < int.parse(amountController.text)) {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    titlePadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    title: Row(
                      children: <Widget>[
                        Icon(Icons.money_off),
                        SizedBox(width: 10),
                        Text(
                          'Insufficient Funds',
                          style: Theme.of(context).textTheme.body2,
                        )
                      ],
                    ),
                    children: <Widget>[
                      Text(
                        'You do not have enough money in your wallet to purchase airtime. Please click the deposit button to add money.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
                              Navigator.of(context).pushNamed('/Wallet');
                            },
                            child: Text(
                              'Add funds',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                });
          } else if (int.parse(amountController.text) < 50) {
            _con.scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('You can only recharge at least 50naira airtime'),
            ));
          } else {
            _con.setState(() {
              btnText = CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white));
            });
            _con
                .recharge(
                    number: numberController.text,
                    amount: amountController.text,
                    carrier: selectedItem)
                .whenComplete(() {
              _con.setState(() {
                btnText = Text('RECHARGE NOW',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600));
              });
            });
          }
        },
        child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green, Colors.green[700]],
                    stops: [0.1, 0.9]),
                borderRadius: BorderRadius.circular(25)),
            child: Center(child: btnText)));
  }
}
