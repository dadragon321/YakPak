import 'dart:convert';
import 'package:uuid/uuid.dart';

class MealSession {
  MealSession(this.meals, this.name) : id = const Uuid().v4();

  MealSession._fromJsonObject(
      {required this.id, required this.name, required this.meals});

  Map<String, int> meals;
  String name;
  String id;

  factory MealSession.fromJson(Map<String, dynamic> file) {
    Map<String, dynamic> inputMap = json.decode(file["meals"]);
    Map<String, int> mealsFinal =
        inputMap.map((key, value) => MapEntry<String, int>(key, value));

    return MealSession._fromJsonObject(
        id: file["id"], name: file["name"], meals: mealsFinal);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {
      "id": id,
      "name": name,
      "meals": json.encode(meals),
    };

    return jsonMap;
  }

  int totalMeals() {
    int total = 0;
    for (int quantity in meals.values) {
      total += quantity;
    }
    return total;
  }
}
