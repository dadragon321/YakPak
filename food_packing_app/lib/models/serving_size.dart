class ServingSize {
  ServingSize({
    required this.uri,
    required this.label,
    required this.quantity,
  });

  String? uri;
  String? label;
  double? quantity;

  factory ServingSize.fromJson(Map<String, dynamic> json) => ServingSize(
        uri: json["uri"],
        label: json["label"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "uri": uri,
        "label": label,
        "quantity": quantity,
      };
}
