import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'BluetoothData.dart'; // Import your actual provider

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedValue;
  String? selectedFruit;
  String btselectboxes = '';

  final List<String> ripenessOptions = [
    'Unripe',
    'Slightly Ripe',
    'Early Ripe',
    'Ripe',
    'Fully Ripe',
    'Overripe',
  ];

  late Map<String, bool> ripenessStates;
  List<String> selectedOrder = [];

  @override
  void initState() {
    super.initState();
    ripenessStates = {for (var option in ripenessOptions) option: false};
  }

  void _onCheckboxChanged(String ripeness, bool? value) {
    setState(() {
      if (value == true) {
        if (selectedOrder.length < 3) {
          ripenessStates[ripeness] = true;
          selectedOrder.add(ripeness);
        }
      } else {
        ripenessStates[ripeness] = false;
        selectedOrder.remove(ripeness);
      }
    });
  }

  int _getOrderNumber(String ripeness) {
    return selectedOrder.indexOf(ripeness) + 1;
  }

  void _saveSettings() {
    // Get the single, live instance of your provider
    final bluetoothData = context.read<Bluetoothdata>();

    if (selectedOrder.length == 3) {
      StringBuffer buffer = StringBuffer('L');
      for (String ripeness in selectedOrder) {
        int boxNumber = ripenessOptions.indexOf(ripeness) + 1;
        buffer.write(boxNumber);
      }
      
      final String newBtValue = buffer.toString();
      
      setState(() {
        btselectboxes = newBtValue;
      });

      print('Save button pressed!');
      print('btselectboxes value: $newBtValue');

      if (bluetoothData.BeltWrite != null) {
        try {
          bluetoothData.BeltWrite?.write(utf8.encode(newBtValue));
          print('✅ Successfully sent "$newBtValue" via Bluetooth.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings Saved & Sent!'),
              backgroundColor: Color(0xFF2F6857),
            ),
          );
        } catch (e) {
          print('Error sending data via Bluetooth: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending Bluetooth data: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        print('❌ Bluetooth write failed: BeltWrite characteristic is null.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Bluetooth not ready. Reconnect and try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 3 ripeness levels to save.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7CD),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios, size: 30),
                ),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Fruit',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8D6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedFruit,
                                hint: Text(
                                  'Select fruit',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                                isExpanded: true,
                                dropdownColor: const Color(0xFFFFF8D6),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'Mango',
                                    child: Row(
                                      children: [
                                        Text(
                                          'Mango',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Text('🥭',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedFruit = newValue;
                                  });

                                  if (newValue == 'Mango') {
                                    print('Mango');
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select variety',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8D6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedValue,
                                hint: Text(
                                  'Select variety',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                                isExpanded: true,
                                dropdownColor: const Color(0xFFFFF8D6),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: [
                                  'Keow Savoey',
                                  'Nam Dok Mai',
                                  'Ok Rong'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue;
                                  });
                                  print(newValue);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Set Boxes',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8D6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select 3 Ripeness Levels (${selectedOrder.length}/3)',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCheckboxTile('Unripe'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCheckboxTile('Slightly Ripe'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCheckboxTile('Early Ripe'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCheckboxTile('Ripe'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCheckboxTile('Fully Ripe'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCheckboxTile('Overripe'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2F6857),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String ripeness) {
    bool isSelected = ripenessStates[ripeness] ?? false;
    bool isDisabled = !isSelected && selectedOrder.length >= 3;
    int orderNumber = isSelected ? _getOrderNumber(ripeness) : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Color(0xFF2F6857) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            onChanged:
                isDisabled ? null : (value) => _onCheckboxChanged(ripeness, value),
            activeColor: Color(0xFF2F6857),
            checkColor: Colors.white,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ripeness,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                  ),
                ),
                if (isSelected)
                  Text(
                    'Order: $orderNumber',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2F6857),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}