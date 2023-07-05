import 'package:intl/intl.dart';
import 'itinerary.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

class Trip {
  Trip(this.name, this.startDate, this.endDate, this.itinerary,
      this.description, this.waterAmount, this.fuelAmount, this.location)
      : id = const Uuid().v4();

  String name;
  String description;
  String id;
  DateTime startDate;
  DateTime endDate;
  Itinerary itinerary;
  double waterAmount;
  double fuelAmount;
  LatLng location;

  factory Trip.fromJson(Map<String, dynamic> file) {
    return Trip(
        file["name"],
        DateTime.parse(file["startDate"]),
        DateTime.parse(file["endDate"]),
        Itinerary.fromJson(file["itinerary"]),
        file["description"],
        file["waterAmount"],
        file["fuelAmount"],
        LatLng(file["location"]["latitude"], file["location"]["longitude"]));
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "startDate": DateFormat('yyyy-MM-dd').format(startDate),
        "endDate": DateFormat('yyyy-MM-dd').format(endDate),
        "itinerary": itinerary.toJson(),
        "description": description,
        "waterAmount": waterAmount,
        "fuelAmount": fuelAmount,
        "location": {
          "latitude": location.latitude,
          "longitude": location.longitude
        }
      };
}
