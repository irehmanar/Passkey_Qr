import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'login.dart';
import 'signup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Signup App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // home: HomePage(email: 'ab@gmail.com',),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the size of the screen
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Container(
        decoration: buildBoxDecoration(),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    "AB Tourist App",
                    style: TextStyle(fontSize: 32.0, color: Colors.white),
                  ),
                ),
                Text(
                  "Here you will get free guidance",
                  style: TextStyle(fontSize: 24.0, color: Colors.white),
                ),
                SizedBox(
                    height: screenSize.height *
                        0.35), // Responsive space based on screen height
                Column(
                  children: <Widget>[
                    GradientButton(
                      text: 'Login',
                      colors: [Colors.green, Colors.greenAccent],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                    SizedBox(
                        height: screenSize.height *
                            0.04), // Responsive space based on screen height
                    GradientButton(
                      text: 'Signup',
                      colors: [Colors.redAccent, Colors.orange],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/bg4.jpg"),
          fit: BoxFit.cover,
        ),
      );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final VoidCallback onPressed;

  GradientButton(
      {required this.text, required this.colors, required this.onPressed});

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
