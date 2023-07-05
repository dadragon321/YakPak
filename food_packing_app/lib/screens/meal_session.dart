import 'package:flutter/material.dart';
import 'package:food_packing/models/meal.dart';
import 'package:food_packing/models/meal_session.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';
import 'package:food_packing/providers/MealStorage.dart';
import 'package:food_packing/screens/add_meal_to_session.dart';

class MealSessionPage extends StatefulWidget {
  final MealSession session;
  final bool editMode;

  const MealSessionPage(
      {super.key, required this.session, this.editMode = false});

  @override
  State<MealSessionPage> createState() => _MealSessionPageState();
}

class _MealSessionPageState extends State<MealSessionPage> {
  late MealSession _session;
  late TextEditingController _sessionNameController;

  @override
  void initState() {
    super.initState();
    _updateSession();
    _sessionNameController = TextEditingController(text: widget.session.name);
  }

  void _updateSession() {
    _session = MealSessionStorage.getMealSession(widget.session.id);
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> meals = _session.meals;
    return Scaffold(
      appBar: AppBar(
        title: widget.editMode
            ? TextField(
                controller: _sessionNameController,
                style: Theme.of(context)
                    .textTheme
                    .apply(displayColor: Colors.white)
                    .displayMedium,
                decoration: const InputDecoration(
                  hintText: "Enter meal session name",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              )
            : Text(
                widget.session.name,
                style: Theme.of(context)
                    .textTheme
                    .apply(displayColor: Colors.white)
                    .displayMedium,
              ),
        actions: widget.editMode
            ? [
                IconButton(
                  onPressed: () {
                    MealSessionStorage.updateMealSessionName(
                        _session.id, _sessionNameController.text);
                    _updateSession();
                    setState(() {});
                  },
                  icon: const Icon(Icons.save),
                ),
              ]
            : null,
      ),
      body: FutureBuilder(
          future: MealStorage.readMeals(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.black,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  String mealID = meals.keys.elementAt(index);
                  Meal meal = MealStorage.getMeal(mealID);
                  return ListTile(
                    title: Text(meal.name),
                    subtitle: Text("X${meals.values.elementAt(index)}"),
                    trailing: widget.editMode
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              int? newQuantity = await _showEditQuantityDialog(
                                context,
                                meal.name,
                                meals.values.elementAt(index),
                              );
                              if (newQuantity != null) {
                                if (newQuantity > 0) {
                                  setState(() {
                                    MealSessionStorage.updateMealQuantity(
                                        _session.id, mealID, newQuantity);
                                    _updateSession();
                                  });
                                } else {
                                  setState(() {
                                    MealSessionStorage.removeMeal(
                                        _session.id, mealID);
                                    _updateSession();
                                  });
                                }
                              }
                            },
                          )
                        : null,
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: widget.editMode
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealPageSession(session: _session),
                  ),
                ).then((value) {
                  setState(() {
                    _updateSession();
                  });
                });
              },
              label: const Text("Add Meal"),
              icon: const Text(
                "\ue902",
                style: TextStyle(fontFamily: "yakpak", fontSize: 24),
              ),
            )
          : null,
    );
  }

  Future<int?> _showEditQuantityDialog(
      BuildContext context, String mealName, int currentQuantity) async {
    int? newQuantity;
    TextEditingController controller =
        TextEditingController(text: currentQuantity.toString());
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit quantity of $mealName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantity"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                newQuantity = int.tryParse(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return newQuantity;
  }
}
