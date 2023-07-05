import 'dart:convert';
import 'package:food_packing/models/food_item.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class FoodStorage {
  static List<FoodItem> foods = [];

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/foodPantry.json');
  }

  static void writePantry(List<FoodItem> foodItems) async {
    final file = await _localFile;
    List<String> foodStrings = [];
    for (var foodItem in foodItems) {
      if (foodItem.runtimeType == FoodItem) {
        foodStrings.add(json.encode(foodItem.toJson()));
      }
    }
    String jsonAsString = json.encode(foodStrings);
    file.writeAsString(jsonAsString);
  }

  static void clearPantry() {
    foods = [];
    writePantry(foods);
  }

  static Future<bool> addToPantry(FoodItem foodItem) async {
    if (await isInPantry(foodItem.foodInfo.id)) {
      return false;
    }
    foods.add(foodItem);
    writePantry(foods);
    return true;
  }

  static Future<bool> removeFromPantry(String id) async {
    List<FoodItem>? currentPantry = await readPantry();
    for (var foodItem in currentPantry!) {
      if (foodItem.foodInfo.id == id) {
        currentPantry.remove(foodItem);
        writePantry(currentPantry);
        return true;
      }
    }
    return false;
  }

  static Future<List<FoodItem>> readPantry() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString(encoding: utf8);
      if (contents == "[]") {
        foods = List.empty(growable: true);
        return foods;
      }
      var jsoncontents = json.decode(contents);
      List<String> foodsAsString = List.from(jsoncontents);

      foods = [];
      for (var food in foodsAsString) {
        foods.add(FoodItem.fromJson(json.decode(food)));
      }
      return foods;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> isInPantry(String id) async {
    List<FoodItem>? currentPantry = await readPantry();
    for (var foodItem in currentPantry) {
      if (foodItem.foodInfo.id == id) {
        return true;
      }
    }
    return false;
  }

  static FoodItem? findInPantry(String foodId) {
    for (var foodItem in foods) {
      if (foodItem.foodInfo.id == foodId) {
        return foodItem;
      }
    }
    return null;
  }

  static FoodItem? findInPantrySync(String foodId) {
    for (var foodItem in foods) {
      if (foodItem.foodInfo.id == foodId) {
        return foodItem;
      }
    }
    return null;
  }

  static List<FoodItem> filterSearchResults(String query) {
    readPantry();
    List<FoodItem> allFoods = <FoodItem>[];
    allFoods.addAll(foods);
    if (query.isNotEmpty) {
      List<FoodItem> searchResults = <FoodItem>[];
      for (var food in allFoods) {
        if (food.foodInfo.knownAs.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(food);
        }
      }
      return searchResults;
    }
    return allFoods;
  }

  static FoodItem? getFood(String id) {
    for (FoodItem food in foods) {
      if (food.id == id) {
        return food;
      }
    }
    return null;
  }
}
