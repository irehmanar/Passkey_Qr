import 'dart:convert';
import 'package:abb/signup.dart';
import 'package:flutter/material.dart';
import 'package:abb/config.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool isFingerprintEnabled = false;


// ...


  void initState() {
    super.initState();
    _loadFingerprintPreference();
  }

  Future<void> _loadFingerprintPreference() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isFingerprintEnabled = prefs.getBool('useFingerprint') ?? false;
    });

    final email = prefs.getString('userEmail');

    print(email);

    if (isFingerprintEnabled && email != null) {
      _authenticateBiometric(context, email);
    }
  }








  Future<void> _saveFingerprintPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', 'ab@gmail.com');
    await prefs.setBool('useFingerprint', true);
  }


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
          final prefs = await SharedPreferences.getInstance();

          // Extract data from response
          String token = jsonResponse['token'];
          String userName = jsonResponse['user']['username'];
          String userEmail = jsonResponse['user']['email'];
          String userId = jsonResponse['user']['userId'];
          String deviceId = jsonResponse['user']['deviceId'];
          final emailOld = prefs.getString('userEmail');
          if(userEmail != emailOld)
            prefs.setBool('useFingerprint', false);

          // print(prefs.getBool('useFingerprint'));

          // Save to shared preferences
          await prefs.setString('jwtToken', token);
          await prefs.setString('userName', userName);
          await prefs.setString('userEmail', userEmail);
          await prefs.setString('userId', userId);
          await prefs.setString('deviceId', deviceId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                email: userEmail,
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

  Future<void> _authenticateBiometric(BuildContext context, String email) async {

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email first."))
      );
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
        };

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwtToken');
        final response = await http.post(
          Uri.parse(biometriclogin),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fingerprint not recognized.")));
      }
    } catch (e) {
      print('Biometric Auth Error: $e');
      _showAlertDialog(context, 'Error', 'An error occurred: $e', false);
    }
  }


  Future<void> _forgetPassword(BuildContext context, String email)
  async {
    print(email);
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your email first."))
      );
      return;
    }
    try {
      var data = {
        'email': email,
      };
      final response = await http.post(
        Uri.parse(forgetPassword),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success']) {
        // _showAlertDialog(context, 'Login Successful', jsonResponse['message'], true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent to your email"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to send OTP"))
        );
      }

    } catch (e) {
      print('OTP Error: $e');
      _showAlertDialog(context, 'Error', 'An error occurred: $e', false);
    }
  }

  Future<void> _verifyOTP(BuildContext context, String otp)
  async {
    print(otp);
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your OTP first."))
      );
      return;
    }
    try {
      var data = {
        'email': _emailController.text.trim(),
        'otp': otp,
      };
      final response = await http.post(
        Uri.parse(verifyopt),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

// Print the response for debugging
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success']) {
            Navigator.pop(context); // Close OTP dialog
            _showResetPasswordDialog(context, _emailController.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP verified")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to verify OTP")));
          }
        } catch (e) {
          print('JSON Decode Error: $e');
          _showAlertDialog(context, 'Error', 'Invalid response format: $e', false);
        }
      } else {
        print("Error from server: ${response.statusCode}");
        _showAlertDialog(context, 'Error',
            'Server responded with status: ${response.statusCode}', false);
      }

    } catch (e) {
      print('OTP Error: $e');
      _showAlertDialog(context, 'Error', 'An error occurred: $e', false);
    }
  }

  Future<void> _addnewPassword(BuildContext context, String password)
  async {
    print(password);
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your password first."))
      );
      return;
    }
    try {
      var data = {
        'email': _emailController.text.trim(),
        'newPassword': password,
      };
      final response = await http.post(
        Uri.parse(addnewPassword),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

// Print the response for debugging
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success']) {
            Navigator.pop(context); // Close OTP dialog
            _showResetPasswordDialog(context, _emailController.text.trim());
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to Password reset")));
          }
        } catch (e) {
          print('JSON Decode Error: $e');
          _showAlertDialog(context, 'Error', 'Invalid response format: $e', false);
        }
      } else {
        print("Error from server: ${response.statusCode}");
        _showAlertDialog(context, 'Error',
            'Server responded with status: ${response.statusCode}', false);
      }

    } catch (e) {
      print('Password reset: $e');
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

  void _showResetPasswordDialog(BuildContext context, String email) {
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "New Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newPassword = _newPasswordController.text.trim();
                String confirmPassword = _confirmPasswordController.text.trim();

                if (newPassword.length < 9) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password must be at least 9 characters.")));
                  return;
                }
                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do not match.")));
                  return;
                }
                Navigator.pop(context);

                // Send the new password to your backend API
                _addnewPassword(context,newPassword );

              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Reset", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  void _showOTPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Verify OTP"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the OTP sent to your email."),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter OTP",
                  prefixIcon: Icon(Icons.lock_open),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your OTP verification logic here
                String otp = _otpController.text.trim();
                _verifyOTP(context, otp);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child:  Text("Verify",style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenSize.height * 0.08),

            // Project Title & Fingerprint Icon
            Icon(Icons.fingerprint_rounded, size: 64, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              "BioPass",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Secure login with fingerprint",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 36),

            // Email Field
            Container(
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
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Container(
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
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 10),

// Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your email first."))
                    );
                    return;
                  }

                  // // Simulate sending OTP to email
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text("OTP sent to your email."))
                  // );

                  _forgetPassword(context, _emailController.text);
                  _showOTPDialog(context);
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),


            if(isFingerprintEnabled)
            // Fingerprint Login Button
            TextButton.icon(
              onPressed: () => _authenticateBiometric(context,_emailController.text.trim()),
              icon: const Icon(Icons.fingerprint, color: Colors.teal, size: 28),
              label: const Text(
                'Login with Fingerprint',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Main Login Button
            GradientButton(
              text: 'Login',
              colors: [Colors.teal.shade400, Colors.green.shade600],
              onPressed: () => _login(context),
            ),
            const SizedBox(height: 24),

            // Sign up prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                  },

                  //
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
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
