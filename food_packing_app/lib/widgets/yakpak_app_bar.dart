import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/screens/preferences.dart';

class YakPakAppbar extends StatelessWidget with PreferredSizeWidget {
  const YakPakAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      title: Image.asset(
        'assets/images/YakPakLogoNoBackground.png',
      ),
      titleSpacing: 100,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            YakPakIcons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PreferencesPage()));
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
