import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("About YakPak",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.apply(color: Colors.white)),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(YakPakIcons.arrow_back),
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.apply(fontSizeDelta: 3.0)),
          ),
        ),
        body: ListView(
          children: const [
            ListTile(
              title: Text(
                'App Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text(
                  'YakPak is a user-friendly application designed to streamline the food planning process for outdoor enthusiasts and adventurers. Conceived by Dr. Eric Bachmann and developed by a talented team of Miami University students, YakPak boasts a suite of features including trip management, comprehensive food and meal planning options, barcode scanning capabilities, and an integrated calendar for an exceptional trip planning experience. Developed from August 2022 to May 2023, YakPak aspires to become an essential tool for a diverse range of users in the future.'),
            ),
            ListTile(
              title: Text(
                'Developed By',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(title: Text('Anders Burck'), subtitle: Text("Developer")),
            ListTile(
                title: Text('Tyler Hilgeman'),
                subtitle: Text("Scrum Master, Developer")),
            ListTile(title: Text('Angela Judge'), subtitle: Text("Developer")),
            ListTile(
                title: Text('Allison McWilliams'),
                subtitle: Text("Product Owner, Developer")),
            ListTile(
                title: Text('Spencer Zaid'), subtitle: Text("Lead Developer")),
          ],
        ));
  }
}
