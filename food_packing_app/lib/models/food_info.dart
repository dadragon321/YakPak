import 'package:food_packing/models/serving_size.dart';

class FoodInfo {
  FoodInfo({
    required this.id,
    required this.label,
    required this.knownAs,
    required this.nutrients,
    required this.category,
    required this.categoryLabel,
    required this.foodContentsLabel,
    required this.image,
    required this.servingSizes,
    required this.servingsPerContainer,
  });

  String id;
  String? label;
  String knownAs;
  Map<String, double>? nutrients;
  String? category;
  String? categoryLabel;
  String? foodContentsLabel;
  String? image;
  List<ServingSize>? servingSizes;
  double? servingsPerContainer;

  factory FoodInfo.fromJson(Map<String, dynamic> json) => FoodInfo(
        id: json["foodId"],
        label: json["label"],
        knownAs: json["knownAs"],
        nutrients: Map.from(json["nutrients"])
            .map((k, v) => MapEntry<String, double>(k, v.toDouble())),
        category: json["category"],
        categoryLabel: json["categoryLabel"],
        foodContentsLabel: json["foodContentsLabel"],
        image: json["image"],
        servingSizes: json["servingSizes"] == null
            ? null
            : List<ServingSize>.from(
                json["servingSizes"].map((x) => ServingSize.fromJson(x))),
        servingsPerContainer: json["servingsPerContainer"],
      );

  Map<String, dynamic> toJson() => {
        "foodId": id,
        "label": label,
        "knownAs": knownAs,
        "nutrients": nutrients == null
            ? null
            : Map.from(nutrients!)
                .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "category": category,
        "categoryLabel": categoryLabel,
        "foodContentsLabel": foodContentsLabel,
        "image": image,
        "servingSizes": servingSizes == null
            ? null
            : List<dynamic>.from(servingSizes!.map((x) => x.toJson())),
        "servingsPerContainer": servingsPerContainer,
      };
}
