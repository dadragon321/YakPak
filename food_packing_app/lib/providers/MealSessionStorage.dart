import 'dart:convert';
import 'package:food_packing/models/meal_session.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class MealSessionStorage {
  static List<MealSession> mealSessions = [];

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/mealSessionStorage.json');
  }

  static Future<void> saveMealSessions() async {
    final file = await _localFile;
    List<Map<String, dynamic>> mealSessionJsonList = [];
    for (var mealSession in mealSessions) {
      mealSessionJsonList.add(mealSession.toJson());
    }
    String jsonAsString = json.encode(mealSessionJsonList);
    await file.writeAsString(jsonAsString);
  }

  static void clearMealSessions() {
    mealSessions = [];
    saveMealSessions();
  }

  static bool addMealSession(MealSession mealSessionItem) {
    if (!isInMealSessions(mealSessionItem.id)) {
      mealSessions.add(mealSessionItem);
      saveMealSessions();
      return true;
    }
    return false;
  }

  static bool removeMealSession(String id) {
    if (!isInMealSessions(id)) {
      return false;
    }
    for (var mealSession in mealSessions) {
      if (mealSession.id == id) {
        mealSessions.remove(mealSession);
        saveMealSessions();
        return true;
      }
    }
    return false;
  }

  static Future<List<MealSession>> readMealSessions() async {
    final file = await _localFile;
    final contents = await file.readAsString();

    List<dynamic>? jsoncontents = json.decode(contents);
    List<Map<String, dynamic>> mealSessionsJsonList = jsoncontents != null
        ? List<Map<String, dynamic>>.from(jsoncontents)
        : [];

    mealSessions = [];
    for (var mealSessionJson in mealSessionsJsonList) {
      mealSessions.add(MealSession.fromJson(mealSessionJson));
    }
    return mealSessions;
  }

  static bool isInMealSessions(String id) {
    return mealSessions.any((mealSession) => mealSession.id == id);
  }

  static MealSession getMealSession(String id) {
    return mealSessions.firstWhere((mealSession) => mealSession.id == id,
        orElse: () => MealSession({}, ""));
  }

  static String getName(String id) {
    return mealSessions
        .firstWhere((mealSession) => mealSession.id == id,
            orElse: () => MealSession({}, ""))
        .name;
  }

  static void addMeal(String id, String mealId, int quant) {
    for (MealSession mealSession in mealSessions) {
      if (mealSession.id == id) {
        mealSession.meals
            .update(mealId, (value) => value + quant, ifAbsent: () => quant);
        saveMealSessions();
      }
    }
  }

  static void removeMeal(String id, String mealID) {
    for (MealSession mealSession in mealSessions) {
      if (mealSession.id == id) {
        mealSession.meals.remove(mealID);
        saveMealSessions();
        break;
      }
    }
  }

  static void updateMealQuantity(String id, String mealID, int newQuantity) {
    for (MealSession mealSession in mealSessions) {
      if (mealSession.id == id) {
        mealSession.meals[mealID] = newQuantity;
        saveMealSessions();
        break;
      }
    }
  }

  static void updateMealSessionName(String id, String name) {
    for (MealSession mealSession in mealSessions) {
      if (mealSession.id == id) {
        mealSession.name = name;
        saveMealSessions();
        break;
      }
    }
  }
}
