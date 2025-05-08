import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:abb/config.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'HomePage.dart';
class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication(); // Biometric auth instance

  Future<void> _login(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog(context, 'Incomplete Data', 'Please enter all the required fields.', false);
    } else if (password.length < 9) {
      _showAlertDialog(context, 'Invalid Password', 'Password must be at least 9 characters long.', false);
    } else {
      var data = {'email': email, 'password': password};
      try {
        var response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success']) {
          // _showAlertDialog(context, 'Login Successful', jsonResponse['message'], true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                // username: jsonResponse['username'],
                email: email,
              ),
            ),
          );

        } else {
          _showAlertDialog(context, 'Login Failed', jsonResponse['message'], false);
        }
      } catch (e) {
        _showAlertDialog(context, 'Error', 'An error occurred: $e', false);
      }
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;  // This returns ANDROID_ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios';
    } else {
      return 'unsupported-platform';
    }
  }

  Future<void> _authenticateBiometric(BuildContext context) async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showAlertDialog(context, 'Missing Email', 'Please enter your email before using fingerprint login.', false);
      return;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login using fingerprint',
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Get device ID
        String deviceId = await getDeviceId();
        print("Device ID: $deviceId");

        // Send email and device ID to backend for authentication
        var data = {
          'email': email,
          'device_id': deviceId,
        };

        var response = await http.post(
          Uri.parse(biometriclogin),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse);

        if (jsonResponse['success']) {
          // _showAlertDialog(context, 'Login Successful', jsonResponse['message'], true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                // username: jsonResponse['username'],
                email: email,
              ),
            ),
          );
        } else {
          _showAlertDialog(context, 'Login Failed', jsonResponse['message'], false);
        }
      } else {
        _showAlertDialog(context, 'Authentication Failed', 'Fingerprint not recognized.', false);
      }
    } catch (e) {
      print('Biometric Auth Error: $e');
      _showAlertDialog(context, 'Error', 'An error occurred: $e', false);
    }
  }


  void _showAlertDialog(BuildContext context, String title, String content, bool redirect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (redirect) {
                  Navigator.pushReplacementNamed(context, '/home'); // Redirect to home screen
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
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: ListView(
        reverse: true,
        children: [
          Container(
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg4.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenSize.height * 0.06),
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  SizedBox(height: screenSize.height * 0.15),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.person, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(color: Colors.white, fontSize: 20),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.06),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.lock, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                style: TextStyle(color: Colors.white, fontSize: 20),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.06),
                        // Biometric authentication button
                        ElevatedButton(
                          onPressed: () => _authenticateBiometric(context),
                          child: Text('Login with Fingerprint'),
                        ),
                        SizedBox(height: screenSize.height * 0.1),
                        GradientButton(
                          text: 'Login',
                          colors: [Colors.green, Colors.greenAccent],
                          onPressed: () => _login(context),
                        ),
                        SizedBox(height: screenSize.height * 0.1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final VoidCallback onPressed;

  GradientButton({required this.text, required this.colors, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 12.0,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 200.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
