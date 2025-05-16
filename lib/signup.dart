// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'HomePage.dart';
// import 'config.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class SignupPage extends StatelessWidget {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _userNameController = TextEditingController();
//
//   Future<void> _signup(BuildContext context) async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//     String userName = _userNameController.text.trim();
//
//     if (email.isEmpty || password.isEmpty || userName.isEmpty) {
//       _showAlertDialog(context, 'Incomplete Data', 'Please enter all the required fields.');
//       return;
//     }
//
//     if (password.length < 8) {
//       _showAlertDialog(context, 'Invalid Password', 'Password must be at least 8 characters long.');
//       return;
//     }
//
//     var data = {
//       'username': userName,
//       'email': email,
//       'password': password
//     };
//
//     try {
//       var response = await http.post(
//         Uri.parse(signup),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       );
//
//       var jsonResponse = jsonDecode(response.body);
//       print(jsonResponse);
//
//       if (jsonResponse["success"] == true) {
//         // Save user data to SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('jwtToken', jsonResponse['token']);
//         await prefs.setString('userEmail', jsonResponse['user']['email']);
//         await prefs.setString('userName', jsonResponse['user']['username']);
//
//         // Show success dialog or redirect
//         _showAlertDialog(context, 'Signup Successful', jsonResponse["message"], true);
//
//         // Optional: Navigate to home page
//         Navigator.pushReplacement(context, MaterialPageRoute(
//           builder: (context) => HomePage(email: email),
//         ));
//
//       } else {
//         _showAlertDialog(context, 'Signup Failed', jsonResponse["message"] ?? 'Signup failed.');
//       }
//     } catch (e) {
//       print("Error: $e");
//       _showAlertDialog(context, 'Error', 'An error occurred during signup. Please try again later.');
//     }
//   }
//
//   void _showAlertDialog(BuildContext context, String title, String content, [bool redirect = false]) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               if (redirect) {
//                 Navigator.pushReplacementNamed(context, '/home');
//               }
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text('Signup'),
//       ),
//       body: ListView(
//         reverse: true, // Ensures the scrollbar appears correctly
//         children: [
//           Container(
//             height: screenSize.height,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("images/bg4.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Container(
//               color: Colors.black.withOpacity(0.6),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(height: screenSize.height * 0.06),
//                   Text(
//                     "Signup",
//                     style: TextStyle(fontSize: 32, color: Colors.white),
//                   ),
//                   SizedBox(height: screenSize.height * 0.15),
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(Icons.account_circle, color: Colors.white),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: TextField(
//                                 controller: _userNameController,
//                                 style: TextStyle(color: Colors.white, fontSize: 20),
//                                 decoration: InputDecoration(
//                                   labelText: 'User Name',
//                                   labelStyle: TextStyle(color: Colors.white, fontSize: 20),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: screenSize.height * 0.06),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(Icons.manage_accounts_rounded, color: Colors.white),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: TextField(
//                                 controller: _emailController,
//                                 style: TextStyle(color: Colors.white, fontSize: 20),
//                                 decoration: InputDecoration(
//                                   labelText: 'Email',
//                                   labelStyle: TextStyle(color: Colors.white, fontSize: 20),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: screenSize.height * 0.06),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Icon(Icons.lock, color: Colors.white),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: TextField(
//                                 controller: _passwordController,
//                                 style: TextStyle(color: Colors.white, fontSize: 20),
//                                 decoration: InputDecoration(
//                                   labelText: 'Password',
//                                   labelStyle: TextStyle(color: Colors.white, fontSize: 20),
//                                 ),
//                                 obscureText: true,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: screenSize.height * 0.1),
//                         GradientButton(
//                           text: 'Signup',
//                           colors: [Colors.redAccent, Colors.orange],
//                           onPressed: () => _signup(context),
//                         ),
//                         SizedBox(height: screenSize.height * 0.1),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//
// }
//
// class GradientButton extends StatelessWidget {
//   final String text;
//   final List<Color> colors;
//   final VoidCallback onPressed;
//
//   GradientButton({required this.text, required this.colors, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         padding: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(25.0),
//         ),
//         elevation: 12.0,
//       ),
//       child: Ink(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: colors,
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(25.0),
//         ),
//         child: Container(
//           constraints: BoxConstraints(maxWidth: 200.0, minHeight: 50.0),
//           alignment: Alignment.center,
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 24.0,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:abb/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'config.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _otpController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String userName = _userNameController.text.trim();

    if (email.isEmpty || password.isEmpty || userName.isEmpty) {
      _showAlertDialog(context, 'Incomplete Data', 'Please enter all the required fields.');
      return;
    }

    if (password.length < 8) {
      _showAlertDialog(context, 'Invalid Password', 'Password must be at least 8 characters long.');
      return;
    }

    var data = {
      'username': userName,
      'email': email,
      'password': password,
    };

    try {
      var response = await http.post(
        Uri.parse(signup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);

      if (jsonResponse["success"] == true) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('jwtToken', jsonResponse['token']);
        // await prefs.setString('userEmail', jsonResponse['user']['email']);
        // await prefs.setString('userName', jsonResponse['user']['username']);

        // _showAlertDialog(context, 'Signup Successful', jsonResponse["message"], true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent to youyr email")));

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => HomePage(email: email)),
        // );

        _showOTPDialog(context);
      } else {
        _showAlertDialog(context, 'Signup Failed', jsonResponse["message"] ?? 'Signup failed.');
      }
    } catch (e) {
      print("Error: $e");
      _showAlertDialog(context, 'Error', 'An error occurred during signup. Please try again later.');
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content, [bool redirect = false]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (redirect) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        Uri.parse(verifyoptsignup),
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
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP verified, Kindly login")));

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to verify OTP")));
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
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
            SizedBox(height: screenSize.height * 0.05),
            Icon(Icons.person_add_alt_1_rounded, size: 64, color: Colors.teal),
            const SizedBox(height: 12),
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 36),

            // Username
            _buildInputCard(
              controller: _userNameController,
              hintText: 'Username',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Email
            _buildInputCard(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password
            _buildInputCard(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Signup Button
            GradientButton(
              text: 'Signup',
              colors: [Colors.teal.shade400, Colors.green.shade600],
              onPressed: () => _signup(context),
            ),
            const SizedBox(height: 24),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to login
                  },
                  child: const Text(
                    "Login",
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

  Widget _buildInputCard({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final VoidCallback onPressed;

  GradientButton({
    required this.text,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        elevation: 10.0,
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
          constraints: BoxConstraints(maxWidth: 220.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
