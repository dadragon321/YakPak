import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/edemam_api_constants.dart';
import '../models/food_item.dart';

Future<FoodItem> getFoodFromBarcode(String barcode) async {
  barcode = barcode.trim();
  var url = Uri.parse(
      'https://api.edamam.com/api/food-database/v2/parser?app_id=$appID&app_key=$appKey&upc=$barcode&nutrition-type=cooking');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var body = json.decode(response.body);
    return FoodItem.fromJson(body['hints'][0]);
  } else {
    throw Exception('Failed to return food');
  }
}

Future<List<FoodItem>> getFoodBySearchKey(String searchKey,
    {List<String> allergies = const [],
    List<String> categories = const []}) async {
  searchKey = searchKey.trim();
  List<FoodItem> foodList = [];
  if (searchKey.length < 4) {
    return foodList;
  }
  String allergiesString = '', categoriesString = '';

  if (allergies != []) {
    for (var allergy in allergies) {
      if (getAllergies().contains(allergy)) {
        allergiesString += '&health=$allergy';
      }
    }
  }
  if (categories != []) {
    for (var category in categories) {
      if (getCategories().contains(category)) {
        categoriesString += '&category=$category';
      }
    }
  }

  var url = Uri.parse(
      'https://api.edamam.com/api/food-database/v2/parser?app_id=$appID&app_key=$appKey&ingr=$searchKey&nutrition-type=cooking$categoriesString$allergiesString');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    var body = json.decode(response.body)['hints'];
    for (var food in body) {
      foodList.add(foodModelFromJson(json.encode(food)));
    }
    return foodList;
  } else {
    throw Exception('Failed to return food');
  }
}

List<String> getAllergies() {
  return [
    'fish-free',
    'fodmap-free',
    'gluten-free',
    'immuno-supportive',
    'keto-friendly',
    'kidney-friendly',
    'kosher',
    'low-fat-abs',
    'low-potassium',
    'low-sugar',
    'lupine-free',
    'mustard-free',
    'no-oil-added',
    'paleo',
    'peanut-free',
    'pescatarian',
    'pork-free',
    'red-meat-free',
    'sesame-free',
    'shellfish-free',
    'soy-free',
    'sugar-conscious',
    'tree-nut-free',
    'vegan',
    'vegetarian',
    'wheat-free'
  ];
}

List<String> getCategories() {
  return ['generic-foods', 'generic-meals', 'packaged-foods', 'fast-foods'];
}
