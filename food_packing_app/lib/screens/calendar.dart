import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/main.dart';
import 'package:food_packing/providers/ItineraryStorage.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';
import 'package:food_packing/screens/add_meal_session.dart';
import 'package:food_packing/screens/meal_session.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/itinerary.dart';
import '../models/meal_session.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedEvents = _getEvents(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar",
            style: Theme.of(context)
                .textTheme
                .apply(displayColor: Colors.white)
                .displayMedium),
      ),
      body: FutureBuilder(
          future: Future.wait([
            ItineraryStorage.readItineraries(),
            MealSessionStorage.readMealSessions()
          ]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Column(children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                      _selectedEvents = _getEvents(selectedDay);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      )),
                  todayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      )),
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        child: _buildEventsMarker(date, events),
                      );
                    }
                  },
                ),
                eventLoader: _getEvents,
              ),
              Expanded(
                child: ListView(
                  children: _selectedEvents
                      .map(
                        (event) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealSessionPage(
                                    session: event.session, editMode: true),
                              ),
                            ).then((value) {
                              setState(() {
                                _selectedEvents = _getEvents(_selectedDay);
                              });
                            }),
                            child: Container(
                              height: MediaQuery.of(context).size.height / 20,
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: darkModeNotifier.value
                                    ? const Color.fromARGB(255, 32, 32, 32)
                                    : Colors.white,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Center(
                                child: Text(
                                  "${event.session.name} (${event.total} meals)",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddMealSessionPage(selectedDay: _selectedDay),
            ),
          ).then((value) {
            setState(() {
              _selectedEvents = _getEvents(_selectedDay);
            });
          });
        },
        child: const Icon(YakPakIcons.add),
      ),
    );
  }

  List<Event> _getEvents(DateTime day) {
    List<Event> events = [];
    for (Itinerary i in ItineraryStorage.itineraries) {
      if (i.mealSessions[
              DateTime.parse(DateFormat("yyyy-MM-dd").format(day))] !=
          null) {
        List<MealSession> mealSessions = [];
        for (String id in i.mealSessions[
            DateTime.parse(DateFormat("yyyy-MM-dd").format(day))]!) {
          mealSessions.add(MealSessionStorage.getMealSession(id));
        }
        for (MealSession session in mealSessions) {
          events.add(Event(session, session.totalMeals().toString()));
        }
      }
    }
    return events;
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    );
  }
}

class Event {
  MealSession session;
  String total;

  Event(this.session, this.total);
}
