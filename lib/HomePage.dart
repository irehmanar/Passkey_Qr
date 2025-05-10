import 'package:abb/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'config.dart';

class HomePage extends StatefulWidget {
  final String email; // You can pass the logged-in user's email

  HomePage({required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    _getDeviceId();  // Get the device ID as soon as the widget is created
  }

  // Asynchronously fetch the device ID
  Future<void> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    String id = '';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;  // This returns ANDROID_ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor ?? 'unknown-ios';
    } else {
      id = 'unsupported-platform';
    }

    setState(() {
      deviceId = id;  // Update the deviceId state
    });
  }

  // Register device by sending a POST request with email and deviceId
  Future<void> _registerDevice() async {
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device ID is not available')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User token not found')));
      return;
    }

    final url = Uri.parse(registerdevice); // Ensure 'registerdevice' is defined in config.dart
    print('Sending device ID: $deviceId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': widget.email,
        'deviceId': deviceId,
      }),
    );

    print('POST $url');
    print('Headers: {Content-Type: application/json, Authorization: Bearer $token}');
    // print('Body: $body');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device registered successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed to register device')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${widget.email}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: deviceId.isEmpty ? null : _registerDevice,
              child: Text('Register Device'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRScannerPage(
                      // onScanned: (scannedData) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Scanned: $scannedData')),
                      //   );
                        // You can use scannedData for login or further processing
                      // },
                    ),
                  ),
                );
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }




}
