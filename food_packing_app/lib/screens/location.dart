import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

class SelectLocationMap extends StatefulWidget {
  LatLng selectedLocation;

  SelectLocationMap({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  State<SelectLocationMap> createState() => _SelectLocationMapState();
}

class _SelectLocationMapState extends State<SelectLocationMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, widget.selectedLocation);
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: widget.selectedLocation,
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.all,
          onTap: (var tapPosition, LatLng location) {
            setState(() {
              widget.selectedLocation = location;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: widget.selectedLocation,
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
