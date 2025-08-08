import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optiripetablet/BluetoothData.dart';
import 'package:optiripetablet/Getstarted.dart';
import 'package:optiripetablet/SettingsPage.dart' hide Bluetoothdata;
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  // Helper function to build the result boxes on the left panel
  static Widget _buildResultBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  // Helper function to build the boxes status cards on the right panel
  static Widget _buildBox(
    String label,
    int count,
    Color color, {
    VoidCallback? onTapLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onTapLabel,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = false;
  bool _isBeltRunning = false;
  String Brixdata = "--";
  String Ripenessdata = "--";
  String CurrentTimeData = "--:--:--";
  String TookmaijaData = "--";
  int _unripeCount = 8;
  int _slightlyUnripeCount = 5;
  int _earlyRipeCount = 15;
  int _ripeCount = 12;
  int _fullyRipeCount = 2;
  int _overripeCount = 6;
  bool _showWebView = false;
  late WebViewController _webViewController;
  final TextEditingController _urlController = TextEditingController();
  String _currentWebViewUrl = '';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bluetoothData = context.read<Bluetoothdata>();
    bluetoothData.RipenessInfoNotify?.setNotifyValue(true);
    bluetoothData.BrixInfoNotify?.setNotifyValue(true);
    bluetoothData.TookmaijaNotify?.setNotifyValue(true);

    setState(() {
      Brixdata = bluetoothData.GlobalBrix.isEmpty ? "--" : bluetoothData.GlobalBrix;
      Ripenessdata = bluetoothData.GlobalRipeness.isEmpty ? "--" : bluetoothData.GlobalRipeness;
      CurrentTimeData = bluetoothData.GlobalTime.isEmpty ? "--:--:--" : bluetoothData.GlobalTime;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBluetoothListener();
    });
  }

  void _initializeBluetoothListener() {
    final bluetoothData = context.read<Bluetoothdata>();
    bluetoothData.OptiripeBelt?.state.listen((BluetoothConnectionState state) {
      if (mounted) {
        setState(() {
          isConnected = (state == BluetoothConnectionState.connected);
          if (!isConnected) {
            _isBeltRunning = false;
          }
        });
      }
    });

    if (bluetoothData.OptiripeBelt != null) {
      bluetoothData.OptiripeBelt!.state.first.then((state) {
        if (mounted) {
          setState(() {
            isConnected = (state == BluetoothConnectionState.connected);
            if (!isConnected) {
              _isBeltRunning = false;
            }
          });
        }
      });
    }
  }

  void _toggleBeltStatus() async {
    final bluetoothData = context.read<Bluetoothdata>();
    if (!bluetoothData.isConnected) {
      return;
    }
    if (_isBeltRunning == true) {
      if (bluetoothData.BeltWrite != null) {
        await bluetoothData.BeltWrite!.write(utf8.encode("BL"));
        setState(() => _isBeltRunning = false);
      }
    } else if (_isBeltRunning == false) {
      if (bluetoothData.BeltWrite != null) {
        await bluetoothData.BeltWrite!.write(utf8.encode("BH"));
        setState(() => _isBeltRunning = true);
      }
    }
  }

  void _resetBoxCounts() {
    setState(() {
      _unripeCount = 0;
      _slightlyUnripeCount = 0;
      _earlyRipeCount = 0;
      _ripeCount = 0;
      _fullyRipeCount = 0;
      _overripeCount = 0;
    });
  }

  void _incrementBoxCount(String label) {
    setState(() {
      switch (label) {
        case 'Unripe': _unripeCount++; break;
        case 'Slightly Unripe': _slightlyUnripeCount++; break;
        case 'Early Ripe': _earlyRipeCount++; break;
        case 'Ripe': _ripeCount++; break;
        case 'Fully Ripe': _fullyRipeCount++; break;
        case 'Overripe': _overripeCount++; break;
      }
    });
  }

  Future<void> _showUrlInputDialog() async {
    _urlController.text = _currentWebViewUrl;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Camera Feed Path'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter the URL or IP address for the camera feed.'),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., http://192.168.1.100:8080',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(() => _showWebView = false);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                final String newUrl = _urlController.text.trim();
                final uri = Uri.tryParse(newUrl);
                if (uri != null && uri.hasScheme && uri.hasAuthority) {
                  setState(() {
                    _currentWebViewUrl = newUrl;
                    _showWebView = true;
                    _webViewController = WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(Colors.black)
                      ..enableZoom(true)
                      ..loadRequest(Uri.parse(_currentWebViewUrl));
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid URL')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bluetoothData = Provider.of<Bluetoothdata>(context, listen: false);
    final String beltStatusText = _isBeltRunning ? 'Running...' : 'Off';
    final Color beltStatusColor = _isBeltRunning ? const Color(0xFF4FC97A) : const Color(0xFFE85F61);
    final String buttonText = _isBeltRunning ? 'Stop' : 'Start';
    final IconData buttonIcon = _isBeltRunning ? Icons.remove_circle : Icons.play_arrow;
    final Color buttonColor = _isBeltRunning ? const Color(0xFFE85F61) : const Color(0xFF4FC97A);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7CD),
      body: Row(
        children: [
          // Left Panel
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- THIS PART IS NOT SCROLLABLE ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    // child: Image.asset('assets/OptiripeLogo.png', height: 40),
                    child: GestureDetector(
                      onTap: () {
                        if (bluetoothData.MeasureWrite != null) {
         bluetoothData.BeltWrite!.write(utf8.encode("M"));
      }
                      },
                      child: Image.asset('assets/MDRLogo.png', height: 50)),
                  ),
                  // Container(
                  //   width: double.infinity,
                  //   height: screenHeight * 0.42,
                  //   decoration: BoxDecoration(
                  //     color: Colors.black,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(10),
                  //     child: _showWebView
                  //         ? WebViewWidget(controller: _webViewController)
                  //         : Image.asset('assets/TabletCamPic.jpg', fit: BoxFit.cover),
                  //   ),
                  // ),

                  Image.asset(
                    'assets/optiripeconvey1.png',
                    width: 700,
                    height: screenHeight * 0.3,

                  ),
              
                  const SizedBox(height: 14),

                  // --- THIS PART IS SCROLLABLE ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Result',
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _showUrlInputDialog,
                                child: const Icon(Icons.info_outline, size: 24, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.8,
                            children: [
                              StreamBuilder<List<int>>(
                                stream: bluetoothData.BrixInfoNotify?.onValueReceived,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    final receivedData = utf8.decode(snapshot.data!);
                                    if (receivedData != Brixdata) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        setState(() {
                                          Brixdata = receivedData;
                                          CurrentTimeData = DateFormat('HH:mm:ss').format(DateTime.now());
                                        });
                                      });
                                    }
                                  }
                                  return HomePage._buildResultBox('Brix', Brixdata, Colors.orange);
                                },
                              ),
                              StreamBuilder<List<int>>(
                                stream: bluetoothData.RipenessInfoNotify?.onValueReceived,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    final receivedData = utf8.decode(snapshot.data!);
                                    if (receivedData != Ripenessdata) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        setState(() => Ripenessdata = receivedData);
                                      });
                                    }
                                  }
                                  return HomePage._buildResultBox('Ripeness', Ripenessdata, const Color(0xFF4FC97A));
                                },
                              ),
                              HomePage._buildResultBox('Time', CurrentTimeData, const Color(0xFF194D47)),
                              HomePage._buildResultBox('Type', 'Mango', Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Container(width: 1, color: const Color(0xFFD9D9D9)),
          // Right Panel
          Expanded(
            child: Container(
              color: const Color(0xFFFFF7CD),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (bluetoothData.BeltWrite != null) {
         bluetoothData.BeltWrite!.write(utf8.encode("BH"));
      }
                          },
                          child: Text('Control', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700))),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage())),
                          child: const Icon(Icons.menu, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8D6),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Belt Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 92,
                                    decoration: BoxDecoration(
                                      color: beltStatusColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [BoxShadow(color: beltStatusColor.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                                    ),
                                    child: Center(child: Text(beltStatusText, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white))),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _toggleBeltStatus,
                                    child: Container(
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: buttonColor,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [BoxShadow(color: buttonColor.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(buttonIcon, color: Colors.white, size: 18),
                                          const SizedBox(width: 6),
                                          Text(buttonText, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8D6),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                Consumer<Bluetoothdata>(builder: (context, bluetoothData, child) => Icon(bluetoothData.isConnected ? Icons.wifi : Icons.wifi_off, size: 28, color: bluetoothData.isConnected ? const Color(0xFF194D47) : Colors.grey)),
                                                const SizedBox(height: 4),
                                                Consumer<Bluetoothdata>(builder: (context, bluetoothData, child) => Text(bluetoothData.isConnected ? 'Connected' : 'Disconnected', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: bluetoothData.isConnected ? const Color(0xFF194D47) : Colors.grey))),
                                              ],
                                            ),
                                            Consumer<Bluetoothdata>(
                                              builder: (context, bluetoothData, child) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (bluetoothData.isConnected) {
                                                      bluetoothData.signOut(device: bluetoothData.OptiripeBelt!);
                                                    } else {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Getstarted()));
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 54,
                                                    width: 86,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(color: bluetoothData.isConnected ? const Color(0xFFE85F61) : const Color(0xFF2F6857), borderRadius: BorderRadius.circular(6)),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(bluetoothData.isConnected ? Icons.wifi_tethering_off : Icons.wifi_tethering, size: 20, color: Colors.white),
                                                        const SizedBox(height: 4),
                                                        Text(bluetoothData.isConnected ? 'Disconnect' : 'Connect', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 8, color: Colors.white)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8D6),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text('Time runned', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('1634', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 36, color: const Color(0xFF194D47), height: 1.18)),
                                            const SizedBox(width: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Text('minutes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF194D47))),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Boxes status', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: _resetBoxCounts,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85F61),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: const Color(0xFFE85F61).withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.refresh, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text('Reset', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        HomePage._buildBox('Unripe', _unripeCount, const Color(0xFF27AE60), onTapLabel: () => _incrementBoxCount('Unripe')),
                        HomePage._buildBox('Slightly Unripe', _slightlyUnripeCount, const Color(0xFF27AE60), onTapLabel: () => _incrementBoxCount('Slightly Unripe')),
                        HomePage._buildBox('Early Ripe', _earlyRipeCount, const Color(0xFFEBF034), onTapLabel: () => _incrementBoxCount('Early Ripe')),
                        HomePage._buildBox('Ripe', _ripeCount, const Color(0xFFF2C94C), onTapLabel: () => _incrementBoxCount('Ripe')),
                        HomePage._buildBox('Fully Ripe', _fullyRipeCount, const Color(0xFFFFC107), onTapLabel: () => _incrementBoxCount('Fully Ripe')),
                        HomePage._buildBox('Overripe', _overripeCount, const Color(0xFF8D6E63), onTapLabel: () => _incrementBoxCount('Overripe')),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}