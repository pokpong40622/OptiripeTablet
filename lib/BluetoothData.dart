import 'dart:async';
import 'dart:convert'; // Required for utf8.decode
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bluetoothdata extends ChangeNotifier {
  BluetoothCharacteristic? MeasureWrite;
  BluetoothCharacteristic? BrixInfoNotify;
  BluetoothCharacteristic? RipenessInfoNotify;
  BluetoothCharacteristic? BeltWrite;
  BluetoothCharacteristic? BatteryNotify;
  BluetoothCharacteristic? TookmaijaNotify;
  BluetoothCharacteristic? TookmaijaWrite;
  BluetoothDevice? OptiripeBelt;

  // Subscriptions for connection state and data streams
  StreamSubscription<BluetoothConnectionState>? _deviceConnectionStateSubscription;
  StreamSubscription<List<int>>? _brixSubscription;
  StreamSubscription<List<int>>? _ripenessSubscription;
  StreamSubscription<List<int>>? _batterySubscription;
  StreamSubscription<List<int>>? _tookmaijaSubscription;

  bool _isConnected = false;
  String _GlobalBrix = "--";
  String _GlobalRipeness = "Unknown";
  String _GlobalTime = ""; // Restored your time variable
  bool _fromResultPage = false;
  int _totalitem = 0;
  
  // Getters
  bool get isConnected => _isConnected;
  String get GlobalBrix => _GlobalBrix;
  String get GlobalRipeness => _GlobalRipeness;
  String get GlobalTime => _GlobalTime; // Restored your time getter
  bool get fromResultPage => _fromResultPage;
  int get totalitem => _totalitem;

  // Setters
  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      notifyListeners();
    }
  }

  set GlobalBrix(String value) {
    if (_GlobalBrix != value) {
      _GlobalBrix = value;
      notifyListeners();
    }
  }

  set GlobalRipeness(String value) {
    if (_GlobalRipeness != value) {
      _GlobalRipeness = value;
      notifyListeners();
    }
  }

  set GlobalTime(String value) { // Restored your time setter
    if (_GlobalTime != value) {
      _GlobalTime = value;
      notifyListeners();
    }
  }

  set fromResultPage(bool value) {
    if (_fromResultPage != value) {
      _fromResultPage = value;
      notifyListeners();
    }
  }

  set totalitem(int value) {
    if (_totalitem != value) {
      _totalitem = value;
      notifyListeners();
    }
  }
  
  void _cancelAllSubscriptions() {
      _deviceConnectionStateSubscription?.cancel();
      _brixSubscription?.cancel();
      _ripenessSubscription?.cancel();
      _batterySubscription?.cancel();
      _tookmaijaSubscription?.cancel();
  }

  Future<void> signOut({required BluetoothDevice device}) async {
    try {
      _cancelAllSubscriptions(); // Cancel all subscriptions on sign out
      await device.disconnect();
      print("Disconnected from device.");
    } catch (e) {
      print("Error while disconnecting: $e");
    } finally {
      OptiripeBelt = null;
      MeasureWrite = null;
      BrixInfoNotify = null;
      RipenessInfoNotify = null;
      BeltWrite = null;
      BatteryNotify = null;
      TookmaijaNotify = null;
      TookmaijaWrite = null;
      isConnected = false;
    }
  }

  Future<void> connectToOptiripeDevice({required BluetoothDevice device}) async {
    if (OptiripeBelt != null && OptiripeBelt!.remoteId == device.remoteId && _isConnected) {
      print("Already connected to this device: ${device.name}");
      return;
    }

    if (OptiripeBelt != null && OptiripeBelt!.remoteId != device.remoteId) {
      try {
        await OptiripeBelt!.disconnect();
        print("Disconnected from previous device: ${OptiripeBelt!.name}");
      } catch (e) {
        print("Error disconnecting from previous device: $e");
      }
    }

    OptiripeBelt = device;
    _deviceConnectionStateSubscription?.cancel(); // Cancel any lingering subscription
    _deviceConnectionStateSubscription = device.connectionState.listen(
      (BluetoothConnectionState state) {
        if (state == BluetoothConnectionState.connected) {
          print("Device ${device.name} is now CONNECTED.");
          isConnected = true;
        } else if (state == BluetoothConnectionState.disconnected) {
          print("Device ${device.name} is now DISCONNECTED.");
          isConnected = false;
        }
      },
      onError: (e) {
        print("Error in connection state stream for ${device.name}: $e");
        isConnected = false;
        signOut(device: device); // Clean up on stream error
      },
    );

    try {
      print("Attempting to connect to ${device.name}...");
      await device.connect(autoConnect: false);
    } catch (e) {
      print("Failed to connect to ${device.name}: $e");
      _deviceConnectionStateSubscription?.cancel();
      rethrow;
    }
  }

  void changeMeasureWrite({required BluetoothCharacteristic characteristic}) {
    MeasureWrite = characteristic;
    notifyListeners();
  }

  void changeBrixInfoNotify({required BluetoothCharacteristic characteristic}) {
    BrixInfoNotify = characteristic;
    _brixSubscription?.cancel(); // Cancel previous stream before listening again
    characteristic.setNotifyValue(true);
    _brixSubscription = characteristic.onValueReceived.listen((value) {
      GlobalBrix = utf8.decode(value);
      print("Received Brix: $GlobalBrix");
    });
    notifyListeners();
  }

  void changeRipenessInfoNotify({required BluetoothCharacteristic characteristic}) {
    RipenessInfoNotify = characteristic;
    _ripenessSubscription?.cancel();
    characteristic.setNotifyValue(true);
    _ripenessSubscription = characteristic.onValueReceived.listen((value) {
      GlobalRipeness = utf8.decode(value);
      print("Received Ripeness: $GlobalRipeness");
    });
    notifyListeners();
  }

  void changeBeltWrite({required BluetoothCharacteristic characteristic}) {
    BeltWrite = characteristic;
    notifyListeners();
  }

  void changeBatteryNotify({required BluetoothCharacteristic characteristic}) {
    BatteryNotify = characteristic;
    _batterySubscription?.cancel();
    characteristic.setNotifyValue(true);
    _batterySubscription = characteristic.onValueReceived.listen((value) {
      print("Received Battery: ${utf8.decode(value)}");
      // You can create a GlobalBattery variable if needed
    });
    notifyListeners();
  }

  void changeTookmaijaNotify({required BluetoothCharacteristic characteristic}) {
    TookmaijaNotify = characteristic;
    _tookmaijaSubscription?.cancel();
    characteristic.setNotifyValue(true);
    _tookmaijaSubscription = characteristic.onValueReceived.listen((value) {
      print("Received Tookmaija: ${utf8.decode(value)}");
      // You can create a GlobalTookmaija variable if needed
    });
    notifyListeners();
  }

  void changeTookmaijaWrite({required BluetoothCharacteristic characteristic}) {
    TookmaijaWrite = characteristic;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelAllSubscriptions();
    OptiripeBelt?.disconnect();
    super.dispose();
  }
}