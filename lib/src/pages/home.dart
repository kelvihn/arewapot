import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/wallet_repository.dart';
import '../repository/user_repository.dart';
//import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:uuid/uuid.dart' as uuid;

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              value.appName ?? S.of(context).home,
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
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarWidget(),
                ),
                SizedBox(height: 10),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Wallet');
                            },
                            child:
                                eventBox('My Wallet', 'assets/img/wallet.png')),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Category',
                                  arguments: RouteArgument(id: '7'));
                            },
                            child: eventBox('Groceries', 'assets/img/log.png')),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Airtime');
                            },
                            child:
                                eventBox('Buy Airtime', 'assets/img/cash.png'))
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.stars,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).top_restaurants,
                      style: Theme.of(context).textTheme.display1,
                    ),
                    subtitle: Text(
                      S.of(context).ordered_by_nearby_first,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                CardsCarouselWidget(
                    restaurantsList: _con.topRestaurants,
                    heroTag: 'home_top_restaurants'),
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.category,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).food_categories,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                ),
                CategoriesCarouselWidget(
                  categories: _con.categories,
                ),
                */
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    S.of(context).trending_this_week,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  subtitle: Text(
                    S.of(context).double_click_on_the_food_to_add_it_to_the,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .merge(TextStyle(fontSize: 11)),
                  ),
                ),
                FoodsCarouselWidget(
                    foodsList: _con.trendingFoods,
                    heroTag: 'home_food_carousel'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).most_popular,
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridWidget(
                    restaurantsList: _con.topRestaurants,
                    heroTag: 'home_restaurants',
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget eventBox(String title, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 80,
            width: MediaQuery.of(context).size.width * 0.27,
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Image.asset('$imagePath', height: 60))),
        Text(title,
            style: TextStyle(
              color: Colors.black,
            ),
            textAlign: TextAlign.center)
      ],
    );
  }
}
