import 'package:flutter/material.dart';
import 'package:food_packing/providers/FoodAPIService.dart';
import 'package:food_packing/providers/FoodStorage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/barcode_scanner_overlay.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessingBarcode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Scan Barcode",
              style: Theme.of(context)
                  .textTheme
                  .apply(displayColor: Colors.white)
                  .displayMedium),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: Stack(children: [
          MobileScanner(
              allowDuplicates: false,
              controller: cameraController,
              onDetect: (barcode, args) async {
                if (isProcessingBarcode || barcode.rawValue == null) {
                  return;
                }

                isProcessingBarcode = true;

                try {
                  final String code = barcode.rawValue!;
                  bool inPantry;
                  await getFoodFromBarcode(code).then((result) async {
                    inPantry =
                        FoodStorage.isInPantry(result.foodInfo.id) as bool;

                    String label = result.foodInfo.knownAs;
                    if (await FoodStorage.addToPantry(result)) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text('Added $label to your pantry'),
                                  actions: [
                                    TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context))
                                  ]));
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                  title:
                                      Text('$label is already in your pantry'),
                                  actions: [
                                    TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context))
                                  ]));
                    }
                  });
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: const Text('Failed to find food'),
                              actions: [
                                TextButton(
                                    child: const Text('OK'),
                                    onPressed: () => Navigator.pop(context))
                              ]));
                } finally {
                  isProcessingBarcode = false;
                }
              }),
          BarcodeScannerOverlay(overlayColor: Colors.black.withOpacity(0.5)),
        ]));
  }
}
