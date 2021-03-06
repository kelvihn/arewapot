import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/number_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart';

class EnterNumber extends StatefulWidget {
  @override
  _EnterNumberState createState() => _EnterNumberState();
}

class _EnterNumberState extends StateMVC<EnterNumber> {
  NumberController _con;
  _EnterNumberState() : super(NumberController()) {
    _con = controller;
  }

  TextEditingController numberController = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Positioned(
            top: 0,
            child: Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(37),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
          ),
          Positioned(
            top: config.App(context).appHeight(37) - 120,
            child: Container(
              width: config.App(context).appWidth(84),
              height: config.App(context).appHeight(37),
              child: Text(
                S.of(context).lets_start_with_login,
                style: Theme.of(context)
                    .textTheme
                    .display3
                    .merge(TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ),
          Positioned(
            top: config.App(context).appHeight(37) - 50,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 50,
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                    )
                  ]),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding:
                  EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
              width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    validator: (input) => input.length < 3
                        ? S.of(context).should_be_more_than_3_letters
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '080XXXXXXXX',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.call,
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.5))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.2))),
                    ),
                  ),
                  SizedBox(height: 30),
                  loginBtn(),
                  SizedBox(height: 15),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed('/Pages', arguments: 2);
                    },
                    shape: StadiumBorder(),
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).skip),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
//                      SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/ForgetPassword');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).i_forgot_password),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/SignUp');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).i_dont_have_an_account),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget loader = Center(
      child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
  Widget signUpWidget = Text(
    'Login',
    style: TextStyle(color: Colors.white),
  );

  Widget loginBtn() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Color(0xFF187C00).withOpacity(0.4),
              blurRadius: 40,
              offset: Offset(0, 15)),
          BoxShadow(
              color: Color(0xFF187C00).withOpacity(0.4),
              blurRadius: 13,
              offset: Offset(0, 3))
        ],
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: FlatButton(
        onPressed: () {
          _con.setState(() {
            signUpWidget = loader;
          });
          _con.insertNumber(
              id: currentUser.value.id, number: numberController.text);
        },
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        color: Color(0xFF187C00),
        shape: StadiumBorder(),
        child: signUpWidget,
      ),
    );
  }
}
