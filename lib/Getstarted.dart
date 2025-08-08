// lib/Getstarted.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optiripetablet/FindingPage.dart';
import 'package:permission_handler/permission_handler.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({super.key});

  @override
  State<Getstarted> createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> {
  // ✅ This is the correct place for your permission logic.
  Future<void> _requestPermissionsAndStart() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification, // Good to include this here as well.
    ].request();

    // Check if the core permissions are granted
    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.locationWhenInUse]!.isGranted) {
      
      print("All necessary permissions granted!");
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FindingPage();
        }));
      }
    } else {
      print("Some permissions were denied.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions are required to use this feature.')),
        );
      }
      // Handle permanently denied permissions
      if (await Permission.bluetooth.isPermanentlyDenied || await Permission.location.isPermanentlyDenied) {
        print("Permissions are permanently denied, opening app settings.");
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building Getstarted page...");
    return Scaffold(
      backgroundColor: Color(0xFFFFF8D6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Optiripe Belt',
              style: GoogleFonts.poppins(
                fontSize: 44,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 26),
            GestureDetector(
              // Call the function when the user taps the button
              onTap: _requestPermissionsAndStart,
              child: Container(
                width: 400,
                height: 76,
                decoration: BoxDecoration(
                  color: Color(0xFF2F6857),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Start',
                    style: GoogleFonts.poppins(
                      color: Color(0xFFFFF7CD),
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}