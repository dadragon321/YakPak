import 'dart:convert';
import 'package:food_packing/models/itinerary.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class ItineraryStorage {
  static List<Itinerary> itineraries = [];

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/itineraryStorage.json');
  }

  static Future<void> saveItineraries() async {
    final file = await _localFile;
    List<String> itineraryStrings = [];
    for (var itinerary in itineraries) {
      itineraryStrings.add(json.encode(itinerary));
    }
    String jsonAsString = json.encode(itineraryStrings);
    await file.writeAsString(jsonAsString, flush: true);
  }

  static Future<File> writeItineraries(List<Itinerary?> itineraryItems) async {
    final file = await _localFile;
    List<String> itineraryItemStrings = [];
    for (var itineraryItem in itineraryItems) {
      if (itineraryItem.runtimeType == Itinerary) {
        itineraryItemStrings.add(json.encode(itineraryItem?.toJson()));
      }
    }
    String jsonAsString = json.encode(itineraryItemStrings);
    return file.writeAsString(jsonAsString);
  }

  static void clearItineraries() {
    itineraries = [];
    saveItineraries();
  }

  static bool addItinerary(Itinerary itineraryItem) {
    if (!isInItineraries(itineraryItem.id)) {
      itineraries.add(itineraryItem);
      saveItineraries();
      return true;
    }
    return false;
  }

  static bool removeItinerary(String id) {
    if (isInItineraries(id) == false) {
      return false;
    }
    for (var itinerary in itineraries) {
      if (itinerary.id == id) {
        itineraries.remove(itinerary);
        saveItineraries();
        return true;
      }
    }
    return false;
  }

  static Future<List<Itinerary>> readItineraries() async {
    final file = await _localFile;

    final contents = await file.readAsString();
    final jsoncontents = json.decode(contents);

    List<String>? tripsAsString =
        jsoncontents != null ? List.from(jsoncontents) : null;

    itineraries = [];
    for (var itinerary in tripsAsString!) {
      itineraries.add(Itinerary.fromJson(json.decode(itinerary)));
    }
    return itineraries;
  }

  static bool isInItineraries(String id) {
    if (itineraries != []) {
      for (var itinerary in itineraries) {
        if (itinerary.id == id) {
          return true;
        }
      }
    }
    return false;
  }

  static bool addMealSession(DateTime date, String id) {
    DateTime formattedDate = DateTime(date.year, date.month, date.day);
    for (Itinerary itinerary in itineraries) {
      if (itinerary.mealSessions.containsKey(formattedDate)) {
        itinerary.mealSessions[formattedDate]!.add(id);
        saveItineraries();
        return true;
      }
    }
    return false;
  }
}
