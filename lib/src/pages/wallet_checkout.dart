import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/checkout_controller.dart';
import '../helpers/helper.dart';
import '../elements/CreditCardsWidget.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../repository/wallet_repository.dart';

class WalletCheckout extends StatefulWidget {
//  RouteArgument routeArgument;
//  WalletCheckout({Key key, this.routeArgument}) : super(key: key);
  @override
  _WalletCheckoutState createState() => _WalletCheckoutState();
}

class _WalletCheckoutState extends StateMVC<WalletCheckout> {
  CheckoutController _con;

  _WalletCheckoutState() : super(CheckoutController()) {
    _con = controller;
  }
  Future<WalletModel> walletFuture;
  @override
  void initState() {
    walletFuture = getWalletBalance();
    _con.listenForCarts(withAddOrder: false);
    super.initState();
  }

  var balance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context)
              .textTheme
              .title
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.payment,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).payment_mode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.display1,
                    ),
                    subtitle: Text(
                      S.of(context).select_your_preferred_payment_mode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                    child: Text("Wallet Balance",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18))),
                FutureBuilder<WalletModel>(
                  future: walletFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      balance = snapshot.data.balance;
                      return Center(
                          child: Text('₦${snapshot.data.balance}.00',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 35)));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('An error occured. Try again',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14)));
                    }

                    // By default, show a loading spinner.
                    return Center(
                        child: Text('Loading...',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 22)));
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 230,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).subtotal,
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ),
                        Helper.getPrice(_con.subTotal, context,
                            style: Theme.of(context).textTheme.subhead)
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${S.of(context).tax} (${setting.value.defaultTax}%)',
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ),
                        Helper.getPrice(_con.taxAmount, context,
                            style: Theme.of(context).textTheme.subhead)
                      ],
                    ),
                    Divider(height: 30),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).total,
                            style: Theme.of(context).textTheme.title,
                          ),
                        ),
                        Helper.getPrice(_con.total, context,
                            style: Theme.of(context).textTheme.title)
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: FlatButton(
                        onPressed: () {
                          if (_con.total > double.parse(balance)) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    titlePadding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 20),
                                    title: Row(
                                      children: <Widget>[
                                        Icon(Icons.money_off),
                                        SizedBox(width: 10),
                                        Text(
                                          'Insufficient Funds',
                                          style:
                                              Theme.of(context).textTheme.body2,
                                        )
                                      ],
                                    ),
                                    children: <Widget>[
                                      Text(
                                        'You do not have enough money in your wallet to purchase this item. Please click the deposit button to add money and continue shopping.',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
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
                                              Navigator.of(context)
                                                  .pushNamed('/Wallet');
                                            },
                                            child: Text(
                                              'Add funds',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  );
                                });
                          } else {
                            _loadingDialog(context);
                            deduct(_con.total).then((value) {
                              if (value == true) {
                                Navigator.of(context).pushReplacementNamed(
                                    '/OrderSuccess',
                                    arguments:
                                        new RouteArgument(param: 'Wallet Pay'));
                              }
                            });
                          }

                          //Navigator.of(context).pushNamed('/OrderSuccess',
                          //  arguments: new RouteArgument(
                          //      param: 'Credit Card (Stripe Gateway)'));
//                                      Navigator.of(context).pushReplacementNamed('/Checkout',
//                                          arguments:
//                                              new RouteArgument(param: [_con.carts, _con.total, setting.defaultTax]));
                        },
                        padding: EdgeInsets.symmetric(vertical: 14),
                        color: Theme.of(context).accentColor,
                        shape: StadiumBorder(),
                        child: Text(
                          S.of(context).confirm_payment,
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _loadingDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            ],
          ));
        });
  }
}
