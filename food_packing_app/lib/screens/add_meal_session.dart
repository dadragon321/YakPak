import 'package:flutter/material.dart';
import 'package:food_packing/models/meal_session.dart';
import 'package:food_packing/providers/ItineraryStorage.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';

class AddMealSessionPage extends StatefulWidget {
  final DateTime selectedDay;

  const AddMealSessionPage({super.key, required this.selectedDay});

  @override
  State<AddMealSessionPage> createState() => _AddMealSessionPageState();
}

class _AddMealSessionPageState extends State<AddMealSessionPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal Session'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name',
                hintText: 'Enter a name for the meal session',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String name = _nameController.text;
              if (name.isNotEmpty) {
                MealSession newSession = MealSession({}, name);
                MealSessionStorage.addMealSession(newSession);
                ItineraryStorage.addMealSession(
                    widget.selectedDay, newSession.id);
                Navigator.pop(context);
              }
            },
            child: const Text('Create Meal Session'),
          ),
        ],
      ),
    );
  }
}
