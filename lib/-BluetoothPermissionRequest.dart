import 'package:permission_handler/permission_handler.dart';

Future<void> requestBluetoothPermissions() async {
  // For Android 12+
  final bluetoothScan = await Permission.bluetoothScan.request();
  final bluetoothConnect = await Permission.bluetoothConnect.request();
  final bluetooth = await Permission.bluetooth.request(); // for older Android
  final location = await Permission.locationWhenInUse.request();

  if (bluetoothScan.isGranted &&
      bluetoothConnect.isGranted &&
      location.isGranted) {
    print(" All necessary Bluetooth permissions granted!");
  } else {
    print(" Permissions not granted.");
  }
}
