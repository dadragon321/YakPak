import 'package:food_packing/models/meal_session.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_packing/models/trip.dart';
import 'package:food_packing/providers/TripStorage.dart';
import '../constants/yakpak_icons.dart';
import 'package:food_packing/models/itinerary.dart';

class AddTripPage extends StatefulWidget {
  final Trip trip;
  final Function updateTrips;

  const AddTripPage({super.key, required this.trip, required this.updateTrips});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  _AddTripPageState();

  late Trip trip;
  bool isEditing = false;
  dynamic tripNameController;
  TextEditingController startDateInput = TextEditingController();
  TextEditingController endDateInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    isEditing = trip.name == "" ? false : true;
    tripNameController = TextEditingController(text: trip.name);
    startDateInput.text =
        trip.startDate != DateTime(0) ? formatDate(trip.startDate) : '';
    endDateInput.text =
        trip.endDate != DateTime(1) ? formatDate(trip.endDate) : '';
  }

  @override
  void dispose() {
    tripNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = trip.name == "" ? "Create New Trip" : "Edit Trip";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.apply(color: Colors.white)),
        leading: IconButton(
          onPressed: () => {
            if (!checkAllFieldsFilled())
              {showUnsavedIncompleteTripDialog(context)}
            else
              {Navigator.of(context).pop(true)}
          },
          icon: const Icon(YakPakIcons.arrow_back),
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.apply(fontSizeDelta: 3.0)),
        ),
        actions: !checkAllFieldsFilled() && isEditing == true
            ? [
                IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Delete trip?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text("This will erase this trip!"),
                            actions: [
                              TextButton(
                                  style: ButtonStyle(backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.red[1];
                                    }
                                    return Colors.red[100];
                                  })),
                                  onPressed: () {
                                    setState(() {
                                      TripStorage.readTrips().whenComplete(() =>
                                          TripStorage.removeTrip(trip.id));
                                    });
                                  },
                                  child: Text("Erase trip",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontWeight: FontWeight.bold))),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"))
                            ],
                          );
                        }),
                    icon: const Icon(YakPakIcons.trash))
              ]
            : [],
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: TextFormField(
                        onChanged: (value) => trip.name = value,
                        controller: tripNameController,
                        style: Theme.of(context).textTheme.displayMedium,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: 'New trip name',
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                    child: TextFormField(
                      onChanged: (value) => trip.description = value,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Description',
                      ),
                      minLines: 1,
                      maxLines: 5,
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                    child: TextField(
                      controller: startDateInput,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDateStart = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2050));
                        if (pickedDateStart != null) {
                          trip.startDate = (pickedDateStart);
                          setState(() {
                            startDateInput.text = formatDate(pickedDateStart);
                          });
                        }
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Start Date',
                      ),
                      minLines: 1,
                      maxLines: 5,
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                    child: TextField(
                      controller: endDateInput,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDateEnd = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2050));
                        if (pickedDateEnd != null) {
                          trip.endDate = (pickedDateEnd);
                          setState(() {
                            endDateInput.text = formatDate(pickedDateEnd);
                          });
                        }
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'End Date',
                      ),
                      minLines: 1,
                      maxLines: 5,
                    )),
              ]),
        ),
      ]),
      persistentFooterButtons: [
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: Text(
            "Save Trip",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.apply(color: Colors.white),
          ),
          onPressed: () {
            if (checkAllFieldsFilled()) {
              setState(() {
                List<MealSession> sessions =
                    initializeItinerary(["Breakfast", "Lunch", "Dinner"]);
                TripStorage.addTrip(trip);
                for (MealSession session in sessions) {
                  MealSessionStorage.addMealSession(session);
                }
              });
              widget.updateTrips();
              Navigator.of(context).pop(true);
            } else {
              showIncompleteDialog(context);
            }
          },
        ),
      ],
    );
  }

  List<MealSession> initializeItinerary(List<String> preferences) {
    DateTime currentDate = trip.startDate;
    Itinerary newItinerary = Itinerary({});
    List<MealSession> sessions = [];
    while (currentDate.isBefore(trip.endDate) ||
        currentDate.isAtSameMomentAs(trip.endDate)) {
      List<MealSession> tempSessions = [];
      for (String name in preferences) {
        MealSession temp = MealSession({}, name);
        tempSessions.add(temp);
        sessions.add(temp);
      }
      List<String> sessionIds = [];
      for (MealSession session in tempSessions) {
        sessionIds.add(session.id);
      }
      newItinerary.mealSessions[currentDate] = sessionIds;
      currentDate = currentDate.add(const Duration(days: 1));
    }
    trip.itinerary = newItinerary;
    return sessions;
  }

  bool checkAllFieldsFilled() {
    if (trip.name.isNotEmpty &&
        !(trip.startDate.isBefore(DateTime(2000))) &&
        !(trip.endDate.isBefore(DateTime(2000)))) {
      return true;
    }
    return false;
  }

  bool checkAnyFieldsFilled() {
    if (trip.name.isNotEmpty ||
        !(trip.startDate.isBefore(DateTime(2000))) ||
        !(trip.endDate.isBefore(DateTime(2000)))) {
      return true;
    }
    return false;
  }

  Future<dynamic> showIncompleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "You haven't finished your trip!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Text(
                  "You haven't completed creating your trip! Please complete all fields to save ${trip.name.isNotEmpty ? trip.name : "your trip!"}"),
              actions: [
                TextButton(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(true)
                        },
                    child: const Text("Exit Without Saving")),
                TextButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: const Text("OK"))
              ],
            ));
  }

  Future<dynamic> showUnsavedIncompleteTripDialog(BuildContext context) {
    if (!checkAllFieldsFilled()) {
      return showIncompleteDialog(context);
    }
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "You haven't saved your trip!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Text(
                  "You haven't saved ${trip.name.isNotEmpty ? trip.name : "your trip"}!"),
              actions: [
                TextButton(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(true)
                        },
                    child: const Text("Exit Without Saving")),
                TextButton(
                    onPressed: () => {
                          TripStorage.addTrip(trip),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(true)
                        },
                    child: const Text("Save and Exit"))
              ],
            ));
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
