import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/models/food_info.dart';
import 'package:food_packing/models/food_item.dart';
import 'package:food_packing/screens/barcode_scanner.dart';
import '../providers/FoodAPIService.dart';
import '../providers/FoodStorage.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<FoodItem> foodItems = [];
  int _selectedFoodIndex = -1;
  late TextEditingController myController;
  final FoodItem _selectedFood = FoodItem(
      foodInfo: FoodInfo(
          id: "foodId",
          label: "label",
          knownAs: "knownAs",
          nutrients: null,
          category: "category",
          categoryLabel: "categoryLabel",
          foodContentsLabel: "foodContentsLabel",
          image: "image",
          servingSizes: null,
          servingsPerContainer: null),
      measures: null);

  @override
  void initState() {
    super.initState();
    FoodStorage.readPantry().then((value) => setState(() {
          foodItems = value;
        }));
    myController = TextEditingController();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  SnackBar get saveBar => SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              YakPakIcons.check,
              size: 40,
            ),
            Text(
              "Saved!",
              style: Theme.of(context).textTheme.headlineSmall,
            )
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 1),
      );

  Future showFood() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              foodItems[_selectedFoodIndex].foodInfo.knownAs,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        radius: 52,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: ClipOval(
                          child: Image.network(
                            foodItems[_selectedFoodIndex]
                                .foodInfo
                                .image
                                .toString(),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.no_food_rounded,
                              size: 48,
                            ),
                            width: 96,
                            height: 96,
                          ),
                        )),
                    const Padding(padding: EdgeInsets.all(8)),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(8)),
                Center(
                  child:
                      Text(foodItems[_selectedFoodIndex].nutrientsToString()),
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Back"))
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: Search(
                onFoodAdded: (updatedFoodItems) {
                  setState(() {
                    foodItems = updatedFoodItems;
                  });
                },
              ),
            );
          },
          child: const Icon(YakPakIcons.add),
        ),
        body: FutureBuilder<List<FoodItem>>(
            future: FoodStorage.readPantry(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return foodItems.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.black,
                      ),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: ClipOval(
                                child: Image.network(
                                  foodItems[index].foodInfo.image.toString(),
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.no_food_rounded,
                                    size: 24,
                                  ),
                                ),
                              )),
                          title: Text(foodItems[index].toString()),
                          subtitle: Text(
                              foodItems[index].nutrientsToString(true),
                              style: Theme.of(context).textTheme.labelMedium),
                          onTap: () {
                            _selectedFoodIndex = index;
                            showFood();
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "You haven't saved any foods yet!\nTap the \uFF0B button to add some.",
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
            }));
  }
}

class Search extends SearchDelegate {
  late List<FoodItem> results = [];
  final Function onFoodAdded;

  Search({required this.onFoodAdded});

  void queryAPI(String searchKey) async {
    results = await getFoodBySearchKey(searchKey);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
          );
        },
        icon: const Icon(YakPakIcons.barcode_scanner),
      ),
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
    if (query.length > 3) {
      return FutureBuilder<List<FoodItem>>(
        future: getFoodBySearchKey(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            results = snapshot.data!
                .where((result) =>
                    result.measures != null &&
                    result.foodInfo.servingSizes != null)
                .toList();
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return GestureDetector(
                  onTap: () => {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Add to pantry?"),
                              content: Text(result.toString()),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      FoodStorage.addToPantry(result);
                                      List<FoodItem> updatedFoodItems =
                                          await FoodStorage.readPantry();
                                      onFoodAdded(updatedFoodItems);
                                      Navigator.of(context).pop();
                                      close(context, result);
                                    },
                                    child: const Text("Add Food")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Cancel"))
                              ],
                            ))
                  },
                  child: ListTile(
                    title: Text(result.foodInfo.knownAs),
                    subtitle: Text(
                      result.foodInfo.category ?? "",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: ClipOval(
                          child: Image.network(
                            result.foodInfo.image.toString(),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.no_food_rounded,
                              size: 24,
                            ),
                          ),
                        )),
                  ),
                );
              },
            );
          }
        },
      );
    } else {
      return const Center(
          child: Text('Please enter at least 4 characters to search'));
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    queryAPI(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var result = results[index];
        return GestureDetector(
          onTap: () => addFood(context, result),
          child: ListTile(
            title: Text(result.foodInfo.knownAs),
            subtitle: Text(
              result.foodInfo.category ?? "",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            leading: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                child: ClipOval(
                  child: Image.network(
                    result.foodInfo.image.toString(),
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.no_food_rounded,
                      size: 24,
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }

  void addFood(BuildContext context, FoodItem result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add to pantry?"),
        content: Text(result.toString()),
        actions: [
          TextButton(
            onPressed: () async {
              bool isSaved = await FoodStorage.addToPantry(result);
              Navigator.of(context).pop();
              if (isSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${result.foodInfo.knownAs} added to pantry"),
                    duration: const Duration(seconds: 2),
                  ),
                );
                List<FoodItem> updatedFoodItems =
                    await FoodStorage.readPantry();
                onFoodAdded(updatedFoodItems);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("${result.foodInfo.knownAs} is already in pantry"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Add Food"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
