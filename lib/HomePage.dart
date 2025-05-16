// import 'package:abb/qr_scanner_page.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'config.dart';
//
// class HomePage extends StatefulWidget {
//   final String email; // You can pass the logged-in user's email
//
//   HomePage({required this.email});
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String deviceId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _getDeviceId();  // Get the device ID as soon as the widget is created
//   }
//
//   // Asynchronously fetch the device ID
//   Future<void> _getDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//
//     String id = '';
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       id = androidInfo.id;  // This returns ANDROID_ID
//     } else if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       id = iosInfo.identifierForVendor ?? 'unknown-ios';
//     } else {
//       id = 'unsupported-platform';
//     }
//
//     setState(() {
//       deviceId = id;  // Update the deviceId state
//     });
//   }
//
//   // Register device by sending a POST request with email and deviceId
//   Future<void> _registerDevice() async {
//     if (deviceId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device ID is not available')));
//       return;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwtToken');
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User token not found')));
//       return;
//     }
//
//     final url = Uri.parse(registerdevice); // Ensure 'registerdevice' is defined in config.dart
//     print('Sending device ID: $deviceId');
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'email': widget.email,
//         'deviceId': deviceId,
//       }),
//     );
//
//     print('POST $url');
//     print('Headers: {Content-Type: application/json, Authorization: Bearer $token}');
//     // print('Body: $body');
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['success']) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Device registered successfully')));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed to register device')));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${response.statusCode}')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Welcome, ${widget.email}'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: deviceId.isEmpty ? null : _registerDevice,
//               child: Text('Register Device'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => QRScannerPage(
//                       // onScanned: (scannedData) {
//                       //   ScaffoldMessenger.of(context).showSnackBar(
//                       //     SnackBar(content: Text('Scanned: $scannedData')),
//                       //   );
//                         // You can use scannedData for login or further processing
//                       // },
//                     ),
//                   ),
//                 );
//               },
//               child: Text('Scan QR Code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//
// }

import 'package:abb/login.dart';
import 'package:abb/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'config.dart';

class HomePage extends StatefulWidget {
  final String email;

  HomePage({required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deviceId = '';
  bool isRegister = false;
  bool isFingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _getDeviceId();
    _loadFingerprintPreference();
  }

  Future<void> _loadFingerprintPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFingerprintEnabled = prefs.getBool('useFingerprint') ?? false;
    });
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('jwtToken');  // Clear token
    // await prefs.remove('useFingerprint');  // Optional: reset fingerprint preference

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
    ));
  }


  Future<void> _toggleFingerprint(bool value) async {
    final passwordController = TextEditingController();

    if (value) {
      setState(() {
        isFingerprintEnabled = true;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('useFingerprint', true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FingerPrint enabled'),
            backgroundColor: Colors.green ),
      );
      // Ask for password verification
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: Text('Verify Password'),
      //     content: TextField(
      //       controller: passwordController,
      //       obscureText: true,
      //       decoration: InputDecoration(labelText: 'Enter your password'),
      //     ),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.pop(context), // Cancel
      //         child: Text('Cancel'),
      //       ),
      //       TextButton(
      //         onPressed: () async {
      //           final enteredPassword = passwordController.text;
      //
      //           // Simulated password check (replace with backend call)
      //           final isValid = await _verifyPassword(enteredPassword);
      //
      //           if (isValid) {
      //             setState(() {
      //               isFingerprintEnabled = true;
      //             });
      //             final prefs = await SharedPreferences.getInstance();
      //             prefs.setBool('useFingerprint', true);
      //
      //             Navigator.pop(context);
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text('Fingerprint enabled successfully!')),
      //             );
      //           } else {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               SnackBar(content: Text('Invalid password')),
      //             );
      //           }
      //         },
      //         child: Text('Verify'),
      //       ),
      //     ],
      //   ),
      // );
    } else {
      setState(() {
        isFingerprintEnabled = false;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('useFingerprint', false);
      SnackBar(content: Text('FingerPrint disabled'));
    }
  }

  Future<bool> _verifyPassword(String password) async {
    // Simulated logic — replace with actual backend validation using email + password
    return password == 'admin123'; // Replace with actual API check
  }


  Future<void> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    String id = '';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor ?? 'unknown-ios';
    } else {
      id = 'unsupported-platform';
    }

    setState(() {
      deviceId = id;
    });
    final prefs = await SharedPreferences.getInstance();

    final storedeviceid  = await prefs.getString('deviceId');
    if(storedeviceid == deviceId)
      setState(() {
        isRegister = true;
      });
  }

  Future<void> _registerDevice() async {
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device ID is not available')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User token not found')),
      );
      return;
    }

    final url = Uri.parse(registerdevice);

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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['success']
                ? 'Device registered successfully'
                : data['message'] ?? 'Failed to register device',
          ),
          backgroundColor: data['success'] ? Colors.green : Colors.red,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceId', deviceId);
      if(data['success'])
        {
          setState(() {
          isRegister = true;

        });

        }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
    // setState(() {
    //   isRegister = !isRegister;
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Welcome'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenSize.height * 0.05),
            Icon(Icons.verified_user_rounded, size: 72, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Hello, ${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 36),

            // Register Device Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton.icon(
                icon: Icon(Icons.phonelink_setup, color: Colors.teal),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    isRegister ? 'Device already registered' : 'Register This '
                        'Device',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                onPressed: deviceId.isEmpty ? null : _registerDevice,
              ),
            ),

            SizedBox(height: 24),

            // QR Scanner Button
            if(isRegister)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton.icon(
                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Scan QR Code to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRScannerPage(),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 40),

            SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Fingerprint Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  activeColor: Colors.teal,
                  value: isFingerprintEnabled,
                  onChanged: _toggleFingerprint,
                ),
              ],
            ),


            // Device ID (Optional display)
            Text(
              'Device ID:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            SelectableText(
              deviceId.isNotEmpty ? deviceId : 'Fetching...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            SizedBox(height: 40),
            TextButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
