import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/src/models/wallet.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];

  HomeController() {
    listenForCategories();
    listenForTopRestaurants();
    listenForRecentReviews();
    listenForTrendingFoods();
  }

  void listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForTopRestaurants() async {
    getCurrentLocation().then((LocationData _locationData) async {
      final Stream<Restaurant> stream =
          await getNearRestaurants(_locationData, _locationData);
      stream.listen((Restaurant _restaurant) {
        setState(() => topRestaurants.add(_restaurant));
      }, onError: (a) {}, onDone: () {});
    });
  }

  void listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForTrendingFoods() async {
    final Stream<Food> stream = await getTrendingFoods();
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshHome() async {
    categories = <Category>[];
    topRestaurants = <Restaurant>[];
    recentReviews = <Review>[];
    trendingFoods = <Food>[];
    listenForCategories();
    listenForTopRestaurants();
    listenForRecentReviews();
    listenForTrendingFoods();
  }
}
