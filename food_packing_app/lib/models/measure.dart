class Measure {
  Measure({
    required this.uri,
    required this.label,
    required this.weight,
  });

  String? uri;
  String? label;
  double? weight;

  factory Measure.fromJson(Map<String, dynamic> json) => Measure(
        uri: json["uri"],
        label: json["label"],
        weight: json["weight"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "uri": uri,
        "label": label,
        "weight": weight,
      };
}
