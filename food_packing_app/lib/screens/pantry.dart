import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/providers/MealStorage.dart';
import 'package:food_packing/screens/food_tab.dart';
import 'package:food_packing/screens/meal_tab.dart';
import '../providers/FoodStorage.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key});

  @override
  State<Pantry> createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  Future showClearDialog() => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Erase your entire pantry?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              "This will erase all foods and saved meals! \n(You must restart the app for changes to take effect... sorry!)"),
          actions: [
            TextButton(
                style: ButtonStyle(backgroundColor:
                    MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.red[1];
                  }
                  return Colors.red[100];
                })),
                onPressed: () {
                  FoodStorage.clearPantry();
                  MealStorage.clearMeals();
                  Navigator.of(context).pop();
                },
                child: Text("ERASE ENTIRE PANTRY",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold))),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"))
          ],
        );
      });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Pantry',
              style: Theme.of(context)
                  .textTheme
                  .apply(displayColor: Colors.white)
                  .displayMedium),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(
                YakPakIcons.more_vert,
                size: 28,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: const [
                      Icon(
                        YakPakIcons.trash,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Clear Pantry"),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                showClearDialog();
                Phoenix.rebirth(context);
              },
            )
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                    Icon(
                      Icons.bakery_dining_sharp,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text("Foods", style: TextStyle(color: Colors.white))
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                    Icon(
                      Icons.brunch_dining_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text("Meals", style: TextStyle(color: Colors.white))
                  ])),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            FoodPage(),
            MealPage(),
          ],
        ),
      ),
    );
  }
}
