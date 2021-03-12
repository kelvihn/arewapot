import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/ref_code_controller.dart';
import 'package:food_delivery_app/src/elements/DrawerWidget.dart';
import 'package:food_delivery_app/src/elements/PermissionDeniedWidget.dart';
import 'package:food_delivery_app/src/elements/ShoppingCartButtonWidget.dart';
import 'package:food_delivery_app/src/models/ref_code.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../repository/user_repository.dart';

class GetRefCode extends StatefulWidget {
  @override
  _GetRefCodeState createState() => _GetRefCodeState();
}

class _GetRefCodeState extends State<GetRefCode> {
  Future<RefCodeModel> refcodeFuture;
  var refCode;
  List<String> referrals;
  bool hasData = false;

  @override
  void initState() {
    getRefs();
    super.initState();
  }

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
        body: currentUser.value.apiToken == null
            ? PermissionDeniedWidget()
            : SingleChildScrollView(
                child: FutureBuilder<RefCodeModel>(
                    future: getRefs(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.refCode == null) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 30),
                                    Text(
                                        'You don\'t have a referral code yet. Click the button the below to generate a referral code',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 40),
                                    generateBtn()
                                  ]));
                        } else if (snapshot.data.refCode != null &&
                            snapshot.data.referrals.length == 0) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                        'You have not referred anyone yet. Kindly share your code with others. When a user registers with your referral code, you get discounts and bonuses.',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 30),
                                    Text('Ref code: ${snapshot.data.refCode}',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600))
                                  ]));
                        } else if (snapshot.data.refCode != null &&
                            snapshot.data.referrals.length > 0) {
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                        'You have referred ${snapshot.data.referrals.length} ${snapshot.data.referrals.length == 1 ? 'person' : 'person'} ',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 30),
                                    Text('Ref code: ${snapshot.data.refCode}',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(height: 30),
                                    Text('My Referrals',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 20),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount:
                                            snapshot.data.referrals.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              leading: userCon(),
                                              title: Text(
                                                  '${snapshot.data.referrals[index]['name']}'));
                                        })
                                  ]));
                        }
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
                      return Center(
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator()));
                    })));
  }

  //Repo here
  Future<RefCodeModel> getRefs() async {
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}get-referrals';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({'user_id': currentUser.value.id}),
    );
    print(response.body);
    return RefCodeModel.fromJSON(json.decode(response.body));
  }

  dynamic loadingDialog() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                backgroundColor: Colors.black54,
                children: [
                  Center(
                      child: Column(children: [
                    CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)),
                    SizedBox(height: 10),
                    Text('Please wait...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ))
                  ]))
                ],
              ));
        });
  }

  Future<void> createCode() async {
    loadingDialog();
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}create-code';
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        'user_id': currentUser.value.id,
        'username': currentUser.value.email
      }),
    );
    if (response.statusCode == 200) {
      getRefs();
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Widget btnText = Text('GENERATE CODE',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600));

  Widget generateBtn() {
    return GestureDetector(
        onTap: () {
          createCode();
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

  Widget userCon() {
    return Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).accentColor.withOpacity(.5),
        ),
        child: Center(
            child: Icon(Icons.person, color: Theme.of(context).accentColor)));
  }
}
