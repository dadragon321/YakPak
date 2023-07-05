import 'package:flutter/material.dart';
import 'package:food_packing/main.dart';
import 'package:food_packing/screens/about.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  List<String> mealNames = ["Breakfast", "Lunch", "Dinner"];
  bool darkMode = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mealNames =
          prefs.getStringList('mealNames') ?? ["Breakfast", "Lunch", "Dinner"];
      darkMode = prefs.getBool('darkMode') ?? true;
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mealNames', mealNames);
    await prefs.setBool('darkMode', darkMode);
    darkModeNotifier.value = darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
                _savePreferences();
              },
            ),
          ),
          ListTile(
            title: const Text('Meals'),
            onTap: () async {
              List<String> newMealNames = await showDialog(
                context: context,
                builder: (context) => MealNamesDialog(mealNames: mealNames),
              );
              if (newMealNames != null) {
                setState(() {
                  mealNames = newMealNames;
                });
                _savePreferences();
              }
            },
          ),
        ],
      ),
    );
  }
}

class MealNamesDialog extends StatefulWidget {
  final List<String> mealNames;

  const MealNamesDialog({super.key, required this.mealNames});

  @override
  State<MealNamesDialog> createState() => _MealNamesDialogState();
}

class _MealNamesDialogState extends State<MealNamesDialog> {
  late List<String> mealNames;

  @override
  void initState() {
    super.initState();
    mealNames = List<String>.from(widget.mealNames);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Meal Names'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: mealNames
            .asMap()
            .map((index, name) => MapEntry(
                  index,
                  TextField(
                    controller: TextEditingController(text: name),
                    onChanged: (value) {
                      setState(() {
                        mealNames[index] = value;
                      });
                    },
                  ),
                ))
            .values
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, mealNames),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
