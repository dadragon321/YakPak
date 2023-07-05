import 'package:flutter/material.dart';
import 'package:food_packing/models/food_item.dart';
import 'package:food_packing/models/food_serving.dart';
import 'package:food_packing/models/meal.dart';
import 'package:food_packing/providers/FoodStorage.dart';
import 'package:food_packing/providers/MealStorage.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import '../constants/yakpak_icons.dart';

class AddMealPage extends StatefulWidget {
  final Meal? meal;
  final Function onMealAdded;

  const AddMealPage({super.key, required this.meal, required this.onMealAdded});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  _AddMealPageState();

  late Meal meal;
  bool isEditing = false;
  dynamic mealNameController;
  dynamic mealDescriptionController;

  @override
  void initState() {
    super.initState();
    meal = widget.meal ?? Meal("", [], "");
    isEditing = meal.name == "" ? false : true;
    mealNameController = TextEditingController(text: meal.name);
    mealDescriptionController =
        TextEditingController(text: meal.getDescription);
  }

  @override
  void dispose() {
    mealNameController.dispose();
    mealDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String titleText = meal.name == "" ? "Create New Meal" : "Edit Meal";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.apply(color: Colors.white)),
        leading: IconButton(
          onPressed: () => {
            if (checkAnyFieldsFilled())
              {showUnsavedIncompleteMealDialog(context)}
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
        actions: checkAnyFieldsFilled() && isEditing == true
            ? [
                IconButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Delete meal?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text("This will erase this meal!"),
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
                                      MealStorage.readMeals().whenComplete(() =>
                                          MealStorage.removeMeal(meal.id).then(
                                              (value) => {
                                                    Navigator.of(context)
                                                        .pop(true),
                                                    Navigator.of(context)
                                                        .pop(true)
                                                  }));
                                    });
                                  },
                                  child: Text("Erase meal",
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
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: TextFormField(
                          onChanged: (value) => meal.name = value,
                          controller: mealNameController,
                          style: Theme.of(context).textTheme.displayMedium,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'New meal name',
                          ))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                      child: TextFormField(
                        onChanged: (value) => meal.description = value,
                        controller: mealDescriptionController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Description',
                        ),
                        minLines: 1,
                        maxLines: 5,
                      )),
                  Column(children: [
                    Align(
                      alignment: const Alignment(0, .95),
                      child: SizedBox(
                        width: size.width * 0.9,
                        height: size.height * .15,
                        child: Card(
                          color: Theme.of(context).colorScheme.surface,
                          elevation: 4.0,
                          child: Column(
                            children: [
                              Text(
                                'Nutrition Facts',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                              ),
                              Meal.displayNutritionalInfo(meal, context)
                            ],
                          ),
                        ),
                      ),
                    ),
                    displayFoodList(),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50)),
                            child: Text(
                              "Add Food to Meal",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.apply(color: Colors.white),
                            ),
                            onPressed: () {
                              showSearch(context: context, delegate: Search())
                                  .then((selectedItem) {
                                if (selectedItem.runtimeType == FoodItem) {
                                  FoodItem foodItem = selectedItem;

                                  showMealPicker(foodItem, context)
                                      .then((value) => setState(() {}));
                                }
                              });
                            }))
                  ])
                ])))
      ]),
      persistentFooterButtons: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: Text(
              "Save Meal",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.apply(color: Colors.white),
            ),
            onPressed: () async {
              if (checkAllFieldsFilled()) {
                setState(() {});
                await MealStorage.addMeal(meal);
                widget.onMealAdded();
                Navigator.of(context).pop(true);
              } else {
                showIncompleteDialog(context);
              }
            })
      ],
    );
  }

  displayFoodList() {
    List<FoodServing> foodServings = meal.foodServings;
    if (foodServings.isEmpty) {
      return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No Foods Yet",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.apply(fontStyle: FontStyle.italic),
            ),
          ));
    }
    return FutureBuilder(
      future: FoodStorage.readPantry(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: foodServings.length,
          itemBuilder: (context, index) {
            var result = foodServings[index];
            FoodItem? foodItem = FoodStorage.getFood(result.foodID);
            return Dismissible(
              onDismissed: (direction) {
                setState(() {
                  if (index < meal.foodServings.length) {
                    meal.foodServings.removeAt(index);
                    MealStorage.replaceMeal(meal);
                  }
                });
              },
              key: UniqueKey(),
              background: Container(color: Theme.of(context).colorScheme.error),
              child: ListTile(
                title: Text(
                    "${foodServings[index].servingQuantity} ${foodServings[index].servingLabel!.toLowerCase()}${foodServings[index].servingQuantity == 1 ? "" : "s"} of ${foodItem!.foodInfo.knownAs}"),
                subtitle: Text(
                    foodServings[index].nutrientsToString(true, false),
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            );
          },
        );
      },
    );
  }

  updateFoodList(foodID, servingLabel, servingQuantity) {
    setState(() {
      meal.addFood(foodID, servingLabel, servingQuantity);
    });
  }

  populateFoodSearchList(TextEditingValue value) {}

  bool checkAllFieldsFilled() {
    if (meal.name.isNotEmpty && meal.foodServings.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool checkAnyFieldsFilled() {
    if (meal.name.isNotEmpty ||
        meal.description.isNotEmpty ||
        meal.foodServings.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<dynamic> showIncompleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "You haven't finished your meal!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Text(
                  "You haven't completed creating your meal! Please complete all fields to save ${meal.name.isNotEmpty ? meal.name : "your meal!"}"),
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

  Future<dynamic> showIncompleteFoodServingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "You haven't finished your serving!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: const Text(
                  "You haven't completed filling out your serving size! Please complete all fields to add the food to your meal!"),
              actions: [
                TextButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: const Text("OK"))
              ],
            ));
  }

  Future<dynamic> showUnsavedIncompleteMealDialog(BuildContext context) {
    if (checkAnyFieldsFilled() && !checkAllFieldsFilled()) {
      return showIncompleteDialog(context);
    }
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "You haven't saved your meal!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              content: Text(
                  "You haven't saved ${meal.name.isNotEmpty ? meal.name : "your meal"}!"),
              actions: [
                TextButton(
                    onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(true)
                        },
                    child: const Text("Exit Without Saving")),
                TextButton(
                    onPressed: () => {
                          MealStorage.addMeal(meal),
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(true),
                          widget.onMealAdded()
                        },
                    child: const Text("Save and Exit"))
              ],
            ));
  }

  Future<dynamic> showMealPicker(
      FoodItem foodItem, BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          String foodID = foodItem.id;
          String? servingLabel = "Serving";
          double servingQuantity = 1.0;
          List<String> potentialChoices = [];
          for (var element in foodItem.measures!) {
            potentialChoices.add(element.label!);
          }
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                  "Select Amount of Servings for ${foodItem.foodInfo.knownAs}"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NumberInputPrefabbed.roundedButtons(
                      controller: TextEditingController(),
                      isInt: false,
                      fractionDigits: 1,
                      autovalidateMode: AutovalidateMode.always,
                      incDecFactor: .5,
                      initialValue: 1,
                      max: double.infinity,
                      enableMinMaxClamping: false,
                      incDecBgColor: Theme.of(context).colorScheme.secondary,
                      buttonArrangement: ButtonArrangement.incRightDecLeft,
                      onChanged: (newValue) {
                        setState(() {
                          servingQuantity = newValue.toDouble();
                        });
                      },
                      onIncrement: (newValue) {
                        setState(() {
                          servingQuantity = newValue.toDouble();
                        });
                      },
                      onDecrement: (newValue) {
                        setState(() {
                          servingQuantity = newValue.toDouble();
                        });
                      },
                    ),
                    servingLabel != null
                        ? DropdownButton(
                            value: servingLabel ?? "Serving",
                            isExpanded: true,
                            hint: const Text("Select Serving Type"),
                            items: potentialChoices.map((String choice) {
                              return DropdownMenuItem(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                servingLabel = newValue ?? "";
                              });
                            })
                        : const Text("Serving"),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                            FoodServing(foodID, servingLabel, servingQuantity)
                                .nutrientsToString(false, true)))
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    child: Text(
                      "Add to Meal",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.apply(color: Colors.white),
                    ),
                    onPressed: () {
                      if (servingLabel!.isNotEmpty && servingQuantity > 0) {
                        updateFoodList(foodID, servingLabel, servingQuantity);

                        Navigator.of(context).pop();
                      } else {
                        showIncompleteFoodServingDialog(context);
                      }
                    })
              ],
            );
          }));
        });
  }
}

class Search extends SearchDelegate {
  late List<FoodItem> results = [];

  void queryFoodStorage(String searchKey) async {
    results = FoodStorage.filterSearchResults(searchKey);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    queryFoodStorage(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var result = results[index];
        return GestureDetector(
          onTap: () => {showAddMealDialog(context, result)},
          child: ListTile(
            title: Text(result.foodInfo.knownAs),
            subtitle: Text(result.nutrientsToString(true),
                style: Theme.of(context).textTheme.labelMedium),
          ),
        );
      },
    );
  }

  Future<dynamic> showAddMealDialog(BuildContext context, FoodItem result) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add to meal?"),
              content: Text(result.toString()),
              actions: [
                TextButton(
                    onPressed: () =>
                        {Navigator.of(context).pop(), close(context, result)},
                    child: const Text("Add Food")),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"))
              ],
            ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    queryFoodStorage(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var result = results[index];
        return GestureDetector(
          onTap: () => showAddMealDialog(context, result),
          child: ListTile(
            title: Text(result.foodInfo.knownAs),
            subtitle: Text(result.nutrientsToString(true),
                style: Theme.of(context).textTheme.labelMedium),
          ),
        );
      },
    );
  }
}
