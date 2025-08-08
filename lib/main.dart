// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optiripetablet/BluetoothData.dart';
import 'package:optiripetablet/HomePage.dart';
import 'package:provider/provider.dart';

// Import your initial home screen
import 'package:optiripetablet/Getstarted.dart';

void main() async {
  // These two lines are correct.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Do NOT request permissions here.

  runApp(
    ChangeNotifierProvider(
      create: (context) => Bluetoothdata(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Optiripe Tablet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}