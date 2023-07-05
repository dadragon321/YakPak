import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Itinerary {
  Itinerary(this.mealSessions) : id = const Uuid().v4();

  Itinerary._fromJsonObject({required this.id, required this.mealSessions});

  String id;
  Map<DateTime, List<String>> mealSessions;

  factory Itinerary.fromJson(Map<String, dynamic> file) {
    Map<String, dynamic> inputMap = file["mealSessions"];
    Map<DateTime, List<String>> mealSessionsFinal = {};

    inputMap.forEach((dayString, sessions) {
      DateTime day = DateFormat('yyyy-MM-dd').parse(dayString);
      List<String> sessionList = List<String>.from(sessions);
      mealSessionsFinal[day] = sessionList;
    });

    return Itinerary._fromJsonObject(
        id: file["id"], mealSessions: mealSessionsFinal);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> mealSessionsJson = {};

    mealSessions.forEach((day, sessions) {
      mealSessionsJson[DateFormat('yyyy-MM-dd').format(day)] = sessions;
    });

    return {"id": id, "mealSessions": mealSessionsJson};
  }
}
