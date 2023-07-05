import 'package:flutter/material.dart';
import 'package:food_packing/models/food_serving.dart';
import 'package:uuid/uuid.dart';

class Meal {
  Meal(this.name, this.foodServings, this.description) : id = const Uuid().v4();

  Meal._fromJsonObject({
    required this.name,
    required this.foodServings,
    required this.description,
    required this.id,
  });

  String name;
  List<FoodServing> foodServings = [];
  String description;
  String id;
  bool needsCooked = false;

  factory Meal.fromJson(Map<String, dynamic> json) => Meal._fromJsonObject(
      id: json["id"],
      foodServings: List<FoodServing>.from(json["foodServings"].map((x) {
        return FoodServing.fromJson(x);
      })),
      name: json["name"],
      description: json["description"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "foodServings": List<dynamic>.from(foodServings.map((x) => x.toJson())),
      };

  get getDescription => description;
  set setDescription(description) => description = description;

  void addFood(foodID, servingLabel, servingQuantity) {
    var foodIndex =
        foodServings.indexWhere((element) => element.foodID == foodID);

    if (foodIndex == -1) {
      foodServings.add(FoodServing(foodID, servingLabel, servingQuantity));
    }
  }

  void removeFood(foodID) {
    foodServings.removeWhere((element) => element.foodID == foodID);
    calculateNutrients();
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

  dynamic findFoodMeasure(foodMeasures, servingSizeName) {
    for (var measure in foodMeasures) {
      if (measure.label == servingSizeName) {
        return measure;
      }
    }
    return null;
  }

  Map<String, double> calculateNutrients() {
    Map<String, double> totalNutrients = {
      "ENERC_KCAL": 0, // calories
      "PROCNT": 0, // protein g
      "FAT": 0.0, // fat g
      "CHOCDF": 0, // carbohydrate g
      "FIBTG": 0, // fiber g
    };

    for (var foodServing in foodServings) {
      var nutrients = foodServing.getNutrients();
      totalNutrients.updateAll((key, value) => value + (nutrients[key] ?? 0));
    }
    return totalNutrients;
  }

  static displayNutritionalInfo(Meal meal, context) {
    double weight = meal.getWeight();
    String value = meal.nutrientsToString(meal, false, true);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.apply(fontSizeFactor: .9)),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.topRight,
          child: Wrap(children: [
            const Icon(
              Icons.scale_rounded,
              size: 22,
            ),
            Text(
              "${weight.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} grams",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
            )
          ]),
        ),
      ]),
    );
  }

  String nutrientsToString(Meal meal, [bool? displayShort, bool? multLines]) {
    String nutrientString = "";
    Map<String, double> value = meal.calculateNutrients();
    for (var nutrient in value.entries) {
      String nutrientUnit =
          nutrientUnitLookup(nutrient.key, displayShort ?? false);
      nutrientString +=
          "${nutrient.value.toStringAsFixed(1).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}$nutrientUnit ${multLines != null && multLines ? "\n" : " | "}";
    }
    nutrientString = nutrientString.substring(0, nutrientString.length - 3);

    return nutrientString;
  }

  double getWeight() {
    double weight = 0.0;
    for (var foodServing in foodServings) {
      double nutrients = foodServing.getWeight();
      weight += nutrients;
    }
    return weight;
  }
}
