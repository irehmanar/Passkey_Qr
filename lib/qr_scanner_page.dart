import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart'; // Ensure verifysession URL is defined here

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool scanned = false;

  // Get device ID
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios';
    } else {
      return 'unsupported-platform';
    }
  }

  // Get user data (JWT and email)
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final token = prefs.getString('jwtToken');
    return {'email': email, 'token': token};
  }

  Future<void> _verifySession(BuildContext context, String sessionKey) async {
    final deviceId = await getDeviceId();
    final userData = await getUserData();
    final email = userData['email'];
    final token = userData['token'];

    if (deviceId.isEmpty || email == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missing required credentials (email, deviceId, or token)')),
      );
      return;
    }

    final url = Uri.parse(verifysession);

    final body = {
      'sessionKey': sessionKey,
      'deviceId': deviceId,
      'email': email,
    };

    print("🟡 Sending POST to: $url");
    print("🟡 Headers: Content-Type: application/json, Authorization: Bearer $token");
    print("🟡 Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("🟢 Response Code: ${response.statusCode}");
      print("🟢 Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Login Successful!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
        setState(() => scanned = false); // Allow retry
      }
    } catch (e) {
      print("🔴 Exception during request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
      setState(() => scanned = false); // Allow retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(
        controller: MobileScannerController(detectionSpeed: DetectionSpeed.normal),
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && !scanned) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              setState(() => scanned = true);
              final Map<String, dynamic> parsed = jsonDecode(code);
              final sessionKey = parsed['sessionKey'];
              _verifySession(context, sessionKey);
              // _verifySession(context, code);
            }
          }
        },
      ),
    );
  }
}











//
//
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;
//
// import 'config.dart'; // Ensure verifysession is defined here
//
// class QRScannerPage extends StatefulWidget {
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }
//
// class _QRScannerPageState extends State<QRScannerPage> {
//   String deviceId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _getDeviceId();
//   }
//
//   Future<void> _getDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//     String id = '';
//
//     if (Platform.isAndroid) {
//       final androidInfo = await deviceInfo.androidInfo;
//       id = androidInfo.id;
//     } else if (Platform.isIOS) {
//       final iosInfo = await deviceInfo.iosInfo;
//       id = iosInfo.identifierForVendor ?? 'unknown-ios';
//     } else {
//       id = 'unsupported-platform';
//     }
//
//     setState(() {
//       deviceId = id;
//     });
//   }
//
//   Future<void> _verifySession(BuildContext context, String sessionKey) async {
//     if (deviceId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Device ID not available')),
//       );
//       return;
//     }
//
//     final url = Uri.parse(verifysession); // e.g. http://localhost:5000/api/verify-session
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'sessionKey': sessionKey,
//         'userId': deviceId,
//       }),
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200 && data['success']) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('QR Login Successful!')),
//       );
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'] ?? 'Login failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan QR Code')),
//       body: MobileScanner(
//         controller: MobileScannerController(detectionSpeed: DetectionSpeed.normal),
//         onDetect: (BarcodeCapture capture) {
//           final List<Barcode> barcodes = capture.barcodes;
//           if (barcodes.isNotEmpty) {
//
//             final String? code = barcodes.first.rawValue;
//             if (code != null) {
//               print(code);
//               _verifySession(context, code);
//             }
//           }
//         },
//       ),
//     );
//   }
// }
