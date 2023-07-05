import 'dart:convert';
import 'package:food_packing/models/food_info.dart';
import 'package:food_packing/models/measure.dart';
import 'package:uuid/uuid.dart';

FoodItem foodModelFromJson(String str) =>
    FoodItem.fromJsonQuery(json.decode(str));

String foodModelToJson(FoodItem data) => json.encode(data.toJson());

class FoodItem {
  FoodItem({
    required this.foodInfo,
    required this.measures,
  }) : id = const Uuid().v4();

  String id;
  FoodInfo foodInfo;
  List<Measure>? measures;

  FoodItem._fromJsonObjectQuery(
      {required this.foodInfo, required this.measures})
      : id = const Uuid().v4();

  FoodItem._fromJsonObject(
      {required this.id, required this.foodInfo, required this.measures});

  factory FoodItem.fromJsonQuery(Map<String, dynamic> json) =>
      FoodItem._fromJsonObjectQuery(
          foodInfo: FoodInfo.fromJson(json["food"]),
          measures: List<Measure>.from(
              json["measures"].map((x) => Measure.fromJson(x))));

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      FoodItem._fromJsonObject(
        foodInfo: FoodInfo.fromJson(json["food"]),
        measures: List<Measure>.from(
            json["measures"].map((x) => Measure.fromJson(x))),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "food": foodInfo.toJson(),
        "measures": List<dynamic>.from(measures!.map((x) => x.toJson())),
        "id": id
      };

  @override
  String toString() {
    return foodInfo.knownAs;
  }

  String nutrientsToString([bool? displayShort]) {
    if (foodInfo.nutrients == null) {
      return "No nutritional info";
    } else {
      String nutrientString = "";
      for (var nutrient in foodInfo.nutrients!.entries) {
        String nutrientUnit =
            nutrientUnitLookup(nutrient.key, displayShort ?? false);
        nutrientString +=
            "${nutrient.value.toStringAsFixed(1)}$nutrientUnit | ";
      }
      nutrientString = nutrientString.substring(0, nutrientString.length - 3);
      return nutrientString;
    }
  }

  String nutrientUnitLookup(String key, bool displayShort) {
    switch (key) {
      case 'ENERC_KCAL':
        return displayShort ? ' cal' : ' cal';
      case 'PROCNT':
        return displayShort ? 'g P' : 'g Protein';
      case 'FAT':
        return displayShort ? 'g F' : 'g Fat';
      case 'CHOCDF':
        return displayShort ? 'g C' : 'g Carbohydrates';
      default:
        return "";
    }
  }
}
