import 'dart:convert'; // Required for utf8.decode and utf8.encode

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Bluetooth functionality
import 'package:google_fonts/google_fonts.dart';// Navigation after connection
import 'package:optiripetablet/BluetoothData.dart';
import 'package:optiripetablet/HomePage.dart';
import 'package:provider/provider.dart'; // For Provider package usage

// ble_uuids.dart (or add to Foundedpage.dart)

class BleUuids {
  // Service UUIDs
  static const String serviceMeasure = "aadf82c3-411d-4a01-8374-b3a8fc636dec";
  static const String serviceBrixInfo = "1a153ae2-58b7-4c28-997b-cc1eee16b246";
  static const String serviceRipenessInfo = "4c7f277b-09cc-4a99-a5e8-5be57febd21b";
  static const String serviceBelt = "ce4c5b5c-5ca0-43e8-a247-467de1ee4fa1";
  static const String serviceBattery = "fbcaf747-2518-46f8-8d14-a361fde98bed";
  static const String serviceTookmaija = "bb474787-e7bf-4d31-805b-90cf6a690638";

  // Characteristic UUIDs
  static const String charMeasureWrite = "81238df3-7cab-4eae-911e-a438545d1fcf";
  static const String charBrixInfoNotify = "f74eb296-9b32-442e-b217-21f6f27d0d5d";
  static const String charRipenessInfoNotify = "5868574e-43a2-42b6-af71-6d002ef7cc7c";
  static const String charBeltWrite = "e9949995-601f-44a3-a731-22a0d5265a40";
  static const String charBatteryNotify = "41d19371-f34c-497c-87bc-1a66d3f49450";
  static const String charTookmaijaNotify = "d22312a7-7099-4605-96e7-2d62be58cc0b";
  static const String charTookmaijaWrite = "94ad6eda-79fb-4774-b8a7-93a37f65e208";
}

class Foundedpage extends StatefulWidget {
  // Retaining the scanResult parameter from your previous code
  Foundedpage({super.key, this.scanResult});
  final ScanResult? scanResult; // Make sure to pass this from the scanning page

  @override
  State<Foundedpage> createState() => _FoundedpageState();
}

class _FoundedpageState extends State<Foundedpage> {
  // Initialize fromResultPage flag, as seen in your previous code
  @override
  void initState() {
    super.initState();
    Provider.of<Bluetoothdata>(context, listen: false).fromResultPage = false;
  }

  // Map to store discovered Bluetooth characteristics
  Map<String, BluetoothCharacteristic?> allBluetooth = {
    "MeasureWrite": null,
    "BrixInfoNotify": null,
    "RipenessInfoNotify": null,
    "BeltWrite": null,
    "BatteryNotify": null,
    "TookmaijaNotify": null, // Added from your previous code
    "TookmaijaWrite": null, // Added from your previous code
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F6857), // Changed to the color from your previous code
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Changed to start for consistent layout
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Founded!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, // Changed to w700
                fontSize: 30, // Changed to 30
                color: Color(0xFFFFF7CD), // Changed to white
              ),
            ),
            SizedBox(height: 40,), // Spacing from previous code
            GestureDetector(
              // In Foundedpage.dart, inside the GestureDetector's onTap function

onTap: () async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await FlutterBluePlus.stopScan();
    var device = widget.scanResult?.device;
    if (device == null) {
      throw Exception("No device found in scan result.");
    }

    print("Connecting to device: ${device.id}");
    
    // Connect using your provider (this is correct)
    await context.read<Bluetoothdata>().connectToOptiripeDevice(device: device);
    
    print("Discovering services...");
    var services = await device.discoverServices();
    
    // Use a local reference to the provider for convenience
    var bluetoothData = context.read<Bluetoothdata>();

    // Find characteristics by UUID
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        String uuid = characteristic.uuid.toString();
        
        switch (uuid) {
          case BleUuids.charMeasureWrite:
            bluetoothData.changeMeasureWrite(characteristic: characteristic);
            print("Found MeasureWrite");
            break;
          case BleUuids.charBrixInfoNotify:
            bluetoothData.changeBrixInfoNotify(characteristic: characteristic);
            print("Found BrixInfoNotify");
            break;
          case BleUuids.charRipenessInfoNotify:
            bluetoothData.changeRipenessInfoNotify(characteristic: characteristic);
            print("Found RipenessInfoNotify");
            break;
          case BleUuids.charBeltWrite:
            bluetoothData.changeBeltWrite(characteristic: characteristic);
            print("Found BeltWrite");
            break;
          case BleUuids.charBatteryNotify:
            bluetoothData.changeBatteryNotify(characteristic: characteristic);
            print("Found BatteryNotify");
            break;
          case BleUuids.charTookmaijaNotify:
            bluetoothData.changeTookmaijaNotify(characteristic: characteristic);
            print("Found TookmaijaNotify");
            break;
          case BleUuids.charTookmaijaWrite:
            bluetoothData.changeTookmaijaWrite(characteristic: characteristic);
            print("Found TookmaijaWrite");
            break;
        }
      }
    }

    Navigator.pop(context); // Dismiss loading dialog
    
    // Check if the essential characteristic was found before navigating
    if (bluetoothData.MeasureWrite != null) {
        print("Connection successful, navigating to HomePage.");
        // Write "S" to confirm connection to the ESP32
        await bluetoothData.MeasureWrite?.write(utf8.encode("S"));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
        );
    } else {
        throw Exception("Essential characteristics not found. Disconnecting.");
    }

  } catch (e) {
    print("Connection error: $e");
    // Attempt to disconnect on failure
    if (widget.scanResult?.device != null) {
      await widget.scanResult!.device.disconnect();
    }
    
    Navigator.pop(context); // Dismiss loading dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connection Error"),
        content: Text("Failed to connect or discover services: ${e.toString()}. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
},
              child: Container(
                width: 356, // Changed to 356
                height: 66, // Changed to 66
                decoration: BoxDecoration(
                  color: Color(0xFFFFF7CD), // Changed to white
                  borderRadius: BorderRadius.circular(8), // Changed to 8
                ),
                child: Center(
                  child: Text(
                    'Connect',
                    style: GoogleFonts.poppins(
                      fontSize: 16, // Changed to 16
                      color: const Color(0xFF2F6857), // Changed to specified color
                      fontWeight: FontWeight.w700, // Changed to w700
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}