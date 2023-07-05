import 'package:flutter/material.dart';
import 'package:food_packing/constants/yakpak_icons.dart';
import 'package:food_packing/models/itinerary.dart';
import 'package:food_packing/models/trip.dart';
import 'package:food_packing/providers/TripStorage.dart';
import 'package:food_packing/screens/trip_summary.dart';
import 'package:food_packing/screens/add_trip.dart';
import 'package:food_packing/widgets/yakpak_app_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  @override
  void initState() {
    super.initState();
  }

  void updateTrips() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const YakPakAppbar(),
      body: FutureBuilder(
          future: TripStorage.readTrips(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return TripStorage.trips.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.black,
                    ),
                    itemCount: TripStorage.trips.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(TripStorage.trips[index].name),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripSummaryPage(
                                  trip: TripStorage.trips[index]),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  )
                : Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        child: Text(
                          "You haven't saved any trips yet!\nTap the \uFF0B button to create one.",
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        )));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LatLng currentLocation = await getCurrentLocation();
          bool result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddTripPage(
                        trip: Trip("", DateTime(0), DateTime(1), Itinerary({}),
                            "", 0, 0, currentLocation),
                        updateTrips: updateTrips,
                      )));
          if (result) {
            updateTrips();
          }
        },
        child: const Icon(YakPakIcons.add),
      ),
    );
  }

  Future<LatLng> getCurrentLocation() async {
    try {
      if (await Permission.location.request().isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        return LatLng(position.latitude, position.longitude);
      }
    } catch (e) {}
    return LatLng(39.103197, -84.506488);
  }
}
