import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:food_packing/main.dart';
import 'package:food_packing/screens/pantry.dart';
import 'package:food_packing/screens/trips.dart';
import 'package:food_packing/screens/calendar.dart';
import 'package:food_packing/constants/yakpak_icons.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  static const List<Widget> pages = <Widget>[
    TripPage(),
    Pantry(),
    CalendarPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Phoenix(
        child: Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(YakPakIcons.earth),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(YakPakIcons.pantry),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(YakPakIcons.calendar),
            label: 'Calendar',
          ),
        ],
        backgroundColor: primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber,
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    ));
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
