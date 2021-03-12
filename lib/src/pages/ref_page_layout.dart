import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class RefLayout extends StatefulWidget {
  final String refCode;
  final List<String> referrals;

  const RefLayout({Key key, this.refCode, this.referrals}) : super(key: key);
  @override
  _GetRefCodeState createState() => _GetRefCodeState();
}

class _GetRefCodeState extends State<RefLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'My Referral Code',
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
        body: SingleChildScrollView(
            child: Column(
          children: [Text('${widget.refCode}')],
        )));
  }
}
