import 'package:food_packing/providers/FoodStorage.dart';
import 'package:food_packing/models/food_item.dart';
import 'dart:developer';

class FoodServing {
  FoodServing(this.foodID, this.servingLabel, this.servingQuantity);

  FoodServing._fromJsonObject(
      {required this.foodID,
      required this.servingLabel,
      required this.servingQuantity,
      required this.weight});

  String foodID;
  String? servingLabel;
  double servingQuantity = 1;
  double weight = 0;

  factory FoodServing.fromJson(Map<String, dynamic> json) =>
      FoodServing._fromJsonObject(
        foodID: json["foodID"],
        servingLabel: json["servingLabel"],
        servingQuantity: json["servingQuantity"],
        weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "foodID": foodID,
        "servingLabel": servingLabel,
        "servingQuantity": servingQuantity,
        "weight": weight
      };

  Map<String, double> getNutrients() {
    FoodItem? foodItem = FoodStorage.getFood(foodID);
    if (foodItem == null) {
      return {
        "ENERC_KCAL": 0,
        "PROCNT": 0,
        "FAT": 0,
        "CHOCDF": 0,
        "FIBTG": 0,
      };
    }
    Map<String, double> nutrients = {};
    for (String nutrient in foodItem!.foodInfo.nutrients!.keys) {
      nutrients[nutrient] =
          foodItem.foodInfo.nutrients![nutrient]! * servingQuantity;
    }
    return nutrients;
  }

  double getWeight() {
    FoodItem? foodItem = FoodStorage.getFood(foodID);
    if (foodItem == null) {
      return 0;
    }
    return foodItem.measures!
            .firstWhere((measure) => measure.label == servingLabel)
            .weight! *
        servingQuantity;
  }

  Map<String, double> addToFoodServingNutritionTotals(
      Map<String, double> totalNutrients, Map<String, double>? thisFoodValues) {
    totalNutrients.forEach((nutrient, value) {
      if (thisFoodValues!.containsKey(nutrient) &&
          thisFoodValues[nutrient] != null) {
        value += thisFoodValues[nutrient]! * servingQuantity;
      }
    });
    return totalNutrients;
  }

  String nutrientsToString([bool? displayShort, bool? multLines]) {
    String nutrientString = "";
    Map<String, double> value = getNutrients();
    for (var nutrient in value.entries) {
      String nutrientUnit =
          nutrientUnitLookup(nutrient.key, displayShort ?? false);
      nutrientString +=
          "${nutrient.value.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}$nutrientUnit ${multLines != null && multLines ? "\n" : " |"}";
    }
    nutrientString = nutrientString.substring(0, nutrientString.length - 3);

    return nutrientString;
  }

  String nutrientsToStringSync(foodStorage,
      [bool? displayShort, bool? multLines]) {
    String nutrientString = "";
    var value = getNutrientsSync(foodStorage);

    for (var nutrient in value.entries) {
      String nutrientUnit =
          nutrientUnitLookup(nutrient.key, displayShort ?? false);
      nutrientString +=
          "${nutrient.value.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}$nutrientUnit ${multLines != null && multLines ? "\n" : " | "}";
    }
    nutrientString = nutrientString.substring(0, nutrientString.length - 3);

    return nutrientString;
  }

  Map<String, double> getNutrientsSync(List<FoodItem> storage) {
    Map<String, double> totalNutrients = {
      "ENERC_KCAL": 0, // calories
      "PROCNT": 0, // protein g
      "FAT": 0.0, // fat g
      "CHOCDF": 0, // carbohydrate g
      "FIBTG": 0, // fiber g
    };

    var food = storage.firstWhere((element) => element.foodInfo.id == foodID);

    if (food.runtimeType == FoodItem) {
      var thisFoodValues = food.foodInfo.nutrients;

      if (servingLabel == "Serving") {
        num weightMultiplier = servingQuantity;
        thisFoodValues!.forEach((nutrient, value) {
          totalNutrients[nutrient] = weightMultiplier * value;
        });
        return totalNutrients;
      } else {
        double? servingWeight = food.measures!
            .firstWhere((element) => element.label == "Serving")
            .weight;

        double? thisWeight = food.measures!
            .firstWhere((element) => element.label == servingLabel)
            .weight;
        if (servingWeight != null && thisWeight != null) {
          num weightMultiplier = servingQuantity * thisWeight / servingWeight;

          thisFoodValues!.forEach((nutrient, value) {
            totalNutrients[nutrient] = weightMultiplier * value;
          });
        }
        return totalNutrients;
      }
    } else {
      return totalNutrients;
    }
  }

  String nutrientUnitLookup(String key, bool displayShort) {
    switch (key) {
      case 'ENERC_KCAL':
        return displayShort ? ' cal' : ' cal ';
      case 'PROCNT':
        return displayShort ? 'g P' : 'g Protein ';
      case 'FAT':
        return displayShort ? 'g F' : 'g Fat ';
      case 'CHOCDF':
        return displayShort ? 'g C' : 'g Carbohydrates ';
      case 'FIBTG':
        return displayShort ? 'g Fib' : 'g Fiber ';
      default:
        return "";
    }
  }
}

dynamic findFoodMeasure(foodMeasures, servingSizeName) {
  for (var measure in foodMeasures) {
    if (measure.label == servingSizeName) {
      return measure;
    }
  }
  return null;
}
