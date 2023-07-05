import 'package:flutter/material.dart';
import 'package:food_packing/models/food_item.dart';
import 'package:food_packing/providers/FoodStorage.dart';
import 'package:food_packing/providers/MealStorage.dart';
import 'package:food_packing/screens/add_meal.dart';
import '../constants/yakpak_icons.dart';
import '../models/meal.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  @override
  void initState() {
    super.initState();
    FoodStorage.readPantry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Meal>>(
          future: MealStorage.readMeals(),
          builder: (BuildContext context, AsyncSnapshot<List<Meal>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error retrieving saved meals"),
              );
            }
            return displayList(context, snapshot.data!);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddMealPage(
                        meal: Meal("", [], ""),
                        onMealAdded: refreshMealPage,
                      ))).then((value) => setState(() {}))
        },
        child: const Icon(YakPakIcons.add),
      ),
    );
  }

  Widget displayList(BuildContext context, List<Meal> meals) {
    if (meals.isEmpty) {
      return Center(
          child: Text(
        "You haven't created a meal yet!\nTap the \uFF0B button to create one.",
        style: Theme.of(context).textTheme.displaySmall,
        textAlign: TextAlign.center,
      ));
    } else {
      return Center(
          child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black,
        ),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          return FutureBuilder<String>(
            future: getFoodImage(meals, index),
            builder:
                (BuildContext context, AsyncSnapshot<String> imageSnapshot) {
              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              String imagePath = imageSnapshot.data ?? "";
              return ListTile(
                  leading:
                      imagePath.isNotEmpty ? Image.network(imagePath) : null,
                  title: Text(meals[index].name),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddMealPage(
                                meal: meals[index],
                                onMealAdded: refreshMealPage,
                              ))).then((value) => setState(() {})),
                  subtitle: Text(meals[index]
                      .nutrientsToString(meals[index], true, false)));
            },
          );
        },
      ));
    }
  }

  Future<String> getFoodImage(List<Meal> meals, int index) async {
    List<FoodItem> pantry = await FoodStorage.readPantry();
    if (meals[index].foodServings.isNotEmpty) {
      var foodItem = pantry.firstWhere((element) =>
          element.foodInfo.id == meals[index].foodServings[0].foodID);
      return foodItem.foodInfo.image ?? "";
    }
    return "";
  }

  void refreshMealPage() {
    setState(() {});
  }
}
