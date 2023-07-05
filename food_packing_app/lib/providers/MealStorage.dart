import 'dart:convert';
import 'package:food_packing/models/meal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class MealStorage {
  static List<Meal> meals = [];

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/mealStorage.json');
  }

  static void writeMeals(List<Meal> meals) async {
    final file = await _localFile;
    List<String> mealStrings = [];
    for (Meal meal in meals) {
      mealStrings.add(json.encode(meal.toJson()));
    }
    String jsonAsString = json.encode(mealStrings);
    file.writeAsString(jsonAsString, encoding: utf8);
  }

  static void clearMeals() {
    meals = [];
    writeMeals(meals);
  }

  static Future<bool> addMeal(Meal mealItem) async {
    bool exists = await isInMeals(mealItem.id);
    if (exists == false) {
      meals.add(mealItem);
      writeMeals(meals);
      return true;
    } else {
      updateMeal(mealItem);
    }
    return false;
  }

  static Future<bool> removeMeal(String id) async {
    await readMeals();
    if (await isInMeals(id) == false) {
      return false;
    }
    for (var meal in meals) {
      if (meal.id == id) {
        meals.remove(meal);
        writeMeals(meals);
        return true;
      }
    }
    return false;
  }

  static Future<List<Meal>> readMeals() async {
    List<Meal> mealObjects = [];
    try {
      final file = await _localFile;

      final contents = await file.readAsString(encoding: utf8);
      if (contents == "[]") {
        return List.empty(growable: true);
      }
      final jsoncontents = json.decode(contents);
      List<String> mealsAsString = List.from(jsoncontents);
      for (var meal in mealsAsString) {
        mealObjects.add(Meal.fromJson(json.decode(meal)));
      }

      meals = mealObjects;
      return mealObjects;
    } catch (e) {
      return mealObjects;
    }
  }

  static Future<bool> isInMeals(String id) async {
    await readMeals();
    if (meals != []) {
      for (var meal in meals) {
        if (meal.id == id) {
          return true;
        }
      }
    }
    return false;
  }

  static void updateMeal(Meal mealItem) async {
    await readMeals().then((value) {
      var meals = MealStorage.meals;
      if (meals != []) {
        for (int i = 0; i < meals.length; i++) {
          if (meals[i].id == mealItem.id) {
            meals[i] = mealItem;
          }
        }
      }
      writeMeals(meals);
    });
  }

  static Meal getMeal(String id) {
    for (Meal meal in meals) {
      if (meal.id == id) {
        return meal;
      }
    }
    return Meal("", [], "");
  }

  static void replaceMeal(Meal mealItem) {
    for (int i = 0; i < meals.length; i++) {
      if (meals[i].id == mealItem.id) {
        meals[i] = mealItem;
      }
    }
    writeMeals(meals);
  }
}
