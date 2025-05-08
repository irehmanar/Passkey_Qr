import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String userName = _userNameController.text.trim();

    if (email.isEmpty || password.isEmpty || userName.isEmpty) {
      _showAlertDialog(context, 'Incomplete Data', 'Please enter all the required fields.');
      return;
    }

    if (password.length < 8) {
      _showAlertDialog(context, 'Invalid Password', 'Password must be at '
          'least 8 characters long.');
      return;
    }

    var data = {
      'username': userName,
      'email': email,
      'password': password
    };
    print('data: $data');

    try {
      var response = await http.post(
        Uri.parse(signup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse);
      if (jsonResponse["success"]) {
        _showAlertDialog(context, 'Signup Successful', jsonResponse["message"], true);
      } else {
        _showAlertDialog(context, 'Signup Failed', jsonResponse["errors"]);
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
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: ListView(
        reverse: true, // Ensures the scrollbar appears correctly
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
                    "Signup",
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
                            Icon(Icons.account_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _userNameController,
                                style: TextStyle(color: Colors.white, fontSize: 20),
                                decoration: InputDecoration(
                                  labelText: 'User Name',
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.06),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.manage_accounts_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(color: Colors.white, fontSize: 20),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white, fontSize: 20),
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
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.1),
                        GradientButton(
                          text: 'Signup',
                          colors: [Colors.redAccent, Colors.orange],
                          onPressed: () => _signup(context),
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
