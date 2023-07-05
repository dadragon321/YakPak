import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_packing/screens/root.dart';

ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(true);

void main() {
  runApp(const MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

final MaterialColor primaryColor = createMaterialColor(const Color(0xFF4B5638));
final MaterialColor secondaryColor =
    createMaterialColor(const Color(0xFFAFBC9F));
final MaterialColor errorColor = createMaterialColor(const Color(0xFFB64E3E));
final MaterialColor backgroundColor =
    createMaterialColor(const Color(0xFFF5FBD4));
final MaterialColor surfaceColor = createMaterialColor(const Color(0xFFE2EDD4));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      darkModeNotifier.value = prefs.getBool('darkMode') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkModeNotifier,
        builder: (context, darkMode, _) {
          return MaterialApp(
            title: 'YakPak',
            theme: ThemeData(
              brightness: darkMode ? Brightness.dark : Brightness.light,
              primaryColor: darkMode ? Colors.black : Colors.white,
              indicatorColor:
                  darkMode ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color.fromARGB(223, 75, 86, 56),
                foregroundColor: Colors.white,
              ),
              hintColor:
                  darkMode ? const Color(0xffEECED3) : const Color(0xff280C0B),
              highlightColor:
                  darkMode ? const Color(0xffFCE192) : const Color(0xff372901),
              hoverColor:
                  darkMode ? const Color(0xff4285F4) : const Color(0xff3A3A3B),
              focusColor:
                  darkMode ? const Color(0xffA8DAB5) : const Color(0xff0B2512),
              disabledColor: Colors.grey,
              cardColor: darkMode ? const Color(0xFF151515) : Colors.white,
              canvasColor: darkMode ? Colors.black : Colors.grey[50],
              fontFamily: "Raleway",
              textTheme: TextTheme(
                displayLarge: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? Colors.white : Colors.black),
                displayMedium: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? Colors.white : Colors.black),
                displaySmall: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? Colors.white : Colors.black),
                headlineMedium: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: darkMode ? Colors.white : Colors.black),
                bodyLarge: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: darkMode ? Colors.white : Colors.black),
                bodyMedium: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    color: darkMode ? Colors.white : Colors.black),
              ),
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: createMaterialColor(const Color(0xFF4B5638)),
                brightness: darkMode ? Brightness.dark : Brightness.light,
              ).copyWith(
                background: darkMode ? Colors.black : const Color(0xffF1F5FB),
              ),
            ),
            home: const RootPage(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
