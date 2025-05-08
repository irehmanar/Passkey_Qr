import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
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
      // Ensure deviceId is available
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device ID is not available')));
      return;
    }

    final url = Uri.parse(registerdevice);  // Make sure 'registerdevice' is defined correctly
    print('Sending device ID: $deviceId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'deviceId': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device registered successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register device')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error')));
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
              onPressed: deviceId.isEmpty ? null : _registerDevice,  // Disable button if deviceId is empty
              child: Text('Register Device'),
            ),
          ],
        ),
      ),
    );
  }
}
