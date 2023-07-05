import 'package:flutter/material.dart';
import 'package:food_packing/models/meal.dart';
import 'package:food_packing/models/meal_session.dart';
import 'package:food_packing/providers/MealSessionStorage.dart';
import 'package:food_packing/providers/MealStorage.dart';

class AddMealPageSession extends StatefulWidget {
  const AddMealPageSession({super.key, required this.session});
  final MealSession session;

  @override
  State<AddMealPageSession> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPageSession> {
  final TextEditingController _quantityController = TextEditingController();

  Future<void> _showQuantityDialog(BuildContext context, Meal meal) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Quantity'),
            content: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter the quantity of meals',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  int quant = int.parse(_quantityController.text);
                  if (quant > 0) {
                    MealSessionStorage.addMeal(
                        widget.session.id, meal.id, quant);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a quantity greater than 0'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: FutureBuilder(
        future: MealStorage.readMeals(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Meal> meals = MealStorage.meals;
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black,
              ),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                Meal meal = meals[index];
                return ListTile(
                  title: Text(meal.name),
                  onTap: () {
                    _showQuantityDialog(context, meal);
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
