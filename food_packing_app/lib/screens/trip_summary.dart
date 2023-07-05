import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/main.dart';
import 'package:food_packing/models/food_item.dart';
import 'package:food_packing/models/food_serving.dart';
import 'package:food_packing/models/meal.dart';
import 'package:food_packing/models/meal_session.dart';
import 'package:food_packing/models/trip.dart';
import 'package:food_packing/providers/FoodStorage.dart';
import 'package:food_packing/providers/ItineraryStorage.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';
import 'package:food_packing/providers/MealStorage.dart';
import 'package:food_packing/screens/location.dart';
import 'package:intl/intl.dart';
import 'package:food_packing/providers/TripStorage.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class TripSummaryPage extends StatefulWidget {
  final Trip trip;

  const TripSummaryPage({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripSummaryPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripSummaryPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  Map<String, bool> checkedItems = {};

  @override
  void initState() {
    super.initState();
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  Future<void> _editTripName(BuildContext context) async {
    TextEditingController controller =
        TextEditingController(text: widget.trip.name);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit Trip Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Trip Name"),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.trip.name = controller.text;
                    });
                    TripStorage.saveTrips();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Start Date',
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        widget.trip.startDate = picked;
      });
      TripStorage.saveTrips();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select End Date',
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        widget.trip.endDate = picked;
      });
      TripStorage.saveTrips();
    }
  }

  Widget _buildShoppingList(
      Map<String, bool> checkedItems, Function updateCheckedItems) {
    //causing check issue?
    return FutureBuilder(
      future: Future.wait([
        MealSessionStorage.readMealSessions(),
        MealStorage.readMeals(),
        FoodStorage.readPantry()
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final mealSessions = snapshot.data![0] as List<MealSession>;
          Map<String, double> shoppingList = {};

          for (MealSession session in mealSessions) {
            for (String mealID in session.meals.keys) {
              Meal meal = MealStorage.getMeal(mealID);
              for (FoodServing foodServing in meal.foodServings) {
                FoodItem? food = FoodStorage.getFood(foodServing.foodID);
                if (food != null && food.runtimeType == FoodItem) {
                  if (shoppingList.containsKey(food.id)) {
                    shoppingList[food.id] = shoppingList[food.id]! +
                        session.meals[mealID]! * foodServing.servingQuantity;
                  } else {
                    shoppingList[food.id] =
                        foodServing.servingQuantity * session.meals[mealID]!;
                    checkedItems[food.id] = false;
                  }
                }
              }
            }
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: shoppingList.length,
            itemBuilder: (BuildContext context, int index) {
              String foodItemId = shoppingList.keys.elementAt(index);
              double quantity = shoppingList[foodItemId]!;
              String foodName =
                  FoodStorage.getFood(foodItemId)?.foodInfo.knownAs ??
                      'Unknown';
              return ShoppingListItem(
                foodItemId: foodItemId,
                quantity: quantity,
                foodName: foodName,
                isChecked: checkedItems[foodItemId] ?? false,
                onCheckedChanged: (String itemId) {
                  setState(() {
                    checkedItems[itemId] = !checkedItems[itemId]!;
                  });
                },
              );
            },
          );
        }
      },
    );
  }

  Future<void> _showWaterOptionsDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose water input method"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Estimate water amount"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _showWaterEstimationDialog(context);
                  },
                ),
                ListTile(
                  title: const Text("Manually input water amount"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _showManualWaterInputDialog(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _showWaterEstimationDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Estimate Water Amount"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Number of people"),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    int numberOfPeople = int.tryParse(controller.text) ?? 1;
                    double estimatedWater = _getTotalWater(numberOfPeople);
                    setState(() {
                      widget.trip.waterAmount = estimatedWater;
                    });
                    TripStorage.saveTrips();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  Future<void> _showManualWaterInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Manual Water Input"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Water amount (L)"),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    double inputWater = double.tryParse(controller.text) ?? 0.0;
                    setState(() {
                      widget.trip.waterAmount = inputWater;
                    });
                    TripStorage.saveTrips();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  Future<void> _showFuelOptionsDialog(BuildContext context) async {
    TextEditingController fuelController =
        TextEditingController(text: widget.trip.fuelAmount.toString());
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Fuel Amount'),
          content: TextField(
            controller: fuelController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fuel (in gallons)'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.trip.fuelAmount = double.parse(fuelController.text);
                });
                TripStorage.saveTrips();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  double _getTotalWater(int numberOfPeople) {
    int numberOfDays =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    return 2.0 * numberOfPeople * numberOfDays;
  }

  void _openMap(BuildContext context) async {
    LatLng selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationMap(
          selectedLocation: widget.trip.location,
        ),
      ),
    );
    setState(() {
      widget.trip.location = selectedLocation;
    });
    TripStorage.saveTrips();
  }

  Future<String> getLocationName(LatLng location) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.locality}, ${placemark.administrativeArea}';
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<double> getCurrentTemperature(LatLng location) async {
    String apiKey = 'f25d1dfb158dcaf875d1c3f6896abae0';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=imperial';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      double temperature = jsonResponse['main']['temp'];
      return temperature;
    } else {
      return 69;
    }
  }

  @override
  Widget build(BuildContext context) {
    String tripName = widget.trip.name;
    String startDate = DateFormat("yyyy-MM-dd").format(_startDate);
    String endDate = DateFormat("yyyy-MM-dd").format(_endDate);
    String dateRange = "$startDate - $endDate";

    var nameRow =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: SizedBox(
              height: 60,
              width: (MediaQuery.of(context).size.width) - 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(),
                label: Text(
                  tripName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.apply(color: Colors.white),
                ),
                onPressed: () {
                  _editTripName(context);
                },
                icon: const Icon(Icons.trip_origin),
              )))
    ]);

    var locationDatesRow =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: SizedBox(
              height: 60,
              width: (MediaQuery.of(context).size.width / 2) - 16,
              child: FutureBuilder<String>(
                future: getLocationName(widget.trip.location),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(),
                      label: Text(
                        snapshot.data ?? "Unknown location",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.apply(color: Colors.white),
                      ),
                      onPressed: () {
                        _openMap(context);
                      },
                      icon: const Icon(YakPakIcons.earth),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ))),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: SizedBox(
              height: 60,
              width: (MediaQuery.of(context).size.width / 2) - 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(),
                label: Text(
                  dateRange,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.apply(color: Colors.white),
                ),
                onPressed: () async {
                  await _selectStartDate(context);
                  await _selectEndDate(context);
                },
                icon: const Icon(YakPakIcons.calendar_date),
              )))
    ]);

    var temperatureRow =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: SizedBox(
            height: 50,
            width: (MediaQuery.of(context).size.width) - 16,
            child: FutureBuilder<double>(
              future: getCurrentTemperature(widget.trip.location),
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(),
                    label: Text(
                      "${snapshot.data?.toStringAsFixed(1) ?? 'N/A'}°F",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.apply(color: Colors.white),
                    ),
                    onPressed: () {
                      _openMap(context);
                    },
                    icon: const Icon(YakPakIcons.sun),
                  );
                }
              },
            )),
      ),
    ]);

    var waterFuelRow =
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: SizedBox(
            height: 50,
            width: (MediaQuery.of(context).size.width / 2) - 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(),
              label: Text(
                "Water: ${widget.trip.waterAmount} L",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.apply(color: Colors.white),
              ),
              onPressed: () async {
                await _showWaterOptionsDialog(context);
              },
              icon: const Icon(YakPakIcons.add),
            )),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: SizedBox(
            height: 50,
            width: (MediaQuery.of(context).size.width / 2) - 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(),
              label: Text(
                "Fuel: ${widget.trip.fuelAmount} gal",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.apply(color: Colors.white),
              ),
              onPressed: () async {
                await _showFuelOptionsDialog(context);
              },
              icon: const Icon(YakPakIcons.add),
            )),
      )
    ]);

    var shoppingList = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Container(
            height: 500,
            width: (MediaQuery.of(context).size.width) - 16,
            color: secondaryColor,
            child: _buildShoppingList(checkedItems,
                (String foodItemId, bool? value) {
              setState(() {
                checkedItems[foodItemId] = value!;
              });
            }),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Summary",
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.apply(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(YakPakIcons.arrow_back),
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.apply(fontSizeDelta: 3.0)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _deleteTrip(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              nameRow,
              locationDatesRow,
              temperatureRow,
              waterFuelRow,
              shoppingList,
            ]),
      ),
    );
  }

  Future<void> _deleteTrip(BuildContext context) async {
    bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Delete Trip"),
              content: const Text("Are you sure you want to delete this trip?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("No"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      for (List<String> ids in widget.trip.itinerary.mealSessions.values) {
        for (String id in ids) {
          MealSessionStorage.removeMealSession(id);
        }
      }
      MealSessionStorage.saveMealSessions();
      ItineraryStorage.removeItinerary(widget.trip.itinerary.id);
      ItineraryStorage.saveItineraries();
      TripStorage.removeTrip(widget.trip.id);
      TripStorage.saveTrips();
      Navigator.of(context).pop();
    }
  }
}

class ShoppingListItem extends StatefulWidget {
  final String foodItemId;
  final double quantity;
  final String foodName;
  final bool isChecked;
  final ValueChanged<String> onCheckedChanged;

  const ShoppingListItem({
    Key? key,
    required this.foodItemId,
    required this.quantity,
    required this.foodName,
    required this.isChecked,
    required this.onCheckedChanged,
  }) : super(key: key);

  @override
  _ShoppingListItemState createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('${widget.foodName} x ${widget.quantity}'),
      value: widget.isChecked,
      onChanged: (bool? value) {
        // widget.onCheckedChanged(widget.foodItemId); (bugged)
      },
    );
  }
}
