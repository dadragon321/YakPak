import 'dart:convert';
import 'package:food_packing/models/trip.dart';
import 'package:food_packing/providers/ItineraryStorage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class TripStorage {
  static List<Trip> trips = [];

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tripStorage.json');
  }

  static Future<void> saveTrips() async {
    final file = await _localFile;
    List<String> tripStrings = [];
    for (var trip in trips) {
      tripStrings.add(json.encode(trip));
    }
    String jsonAsString = json.encode(tripStrings);
    await file.writeAsString(jsonAsString, flush: true);
  }

  static Future<File> writeTrips(List<Trip?> tripItems) async {
    final file = await _localFile;
    List<String> tripItemStrings = [];
    for (var tripItem in tripItems) {
      if (tripItem.runtimeType == Trip) {
        tripItemStrings.add(json.encode(tripItem?.toJson()));
      }
    }
    String jsonAsString = json.encode(tripItemStrings);
    return await file.writeAsString(jsonAsString);
  }

  static void clearTrips() {
    trips = [];
    saveTrips();
  }

  static bool addTrip(Trip tripItem) {
    if (!isInTrips(tripItem.id)) {
      trips.add(tripItem);
      ItineraryStorage.addItinerary(tripItem.itinerary);
      saveTrips();
      return true;
    }
    return false;
  }

  static bool removeTrip(String id) {
    if (!isInTrips(id)) {
      return false;
    }
    for (var trip in trips) {
      if (trip.id == id) {
        trips.remove(trip);
        saveTrips();
        return true;
      }
    }
    return false;
  }

  static Future<void> readTrips() async {
    final file = await _localFile;

    final contents = await file.readAsString();
    final jsoncontents = json.decode(contents);

    List<String>? tripsAsString =
        jsoncontents != null ? List.from(jsoncontents) : null;

    trips = [];
    for (var trip in tripsAsString!) {
      trips.add(Trip.fromJson(json.decode(trip)));
    }
  }

  static bool isInTrips(String id) {
    if (trips.isNotEmpty) {
      for (var trip in trips) {
        if (trip.id == id) {
          return true;
        }
      }
    }
    return false;
  }
}
