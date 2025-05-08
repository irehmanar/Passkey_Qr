import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  final Function(String) onScanned;

  QRScannerPage({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal, // Optional: fast, normal, noDuplicates
        ),
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              onScanned(code);
              Navigator.pop(context); // Close scanner
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
