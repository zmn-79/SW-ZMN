import 'package:flutter/material.dart';
import '../store/store_information_screen.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void register() {
    final email = emailController.text;
    final password = passwordController.text;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InformationPage(email: email, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF127369),
      appBar: AppBar(title: Text(''), backgroundColor: Color(0xFF007566)),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 50, left: 100),
              child: Image.asset('images/moder.png', width: 200, height: 200),
            ),
          ),
          Positioned(
            left: 50,
            top: 440,
            child: Container(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF007566)),
                  filled: true,
                  fillColor: Color(0xFF8AA6A3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            top: 520,
            child: Container(
              width: 300,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF007566)),
                  filled: true,
                  fillColor: Color(0xFF8AA6A3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 120,
            top: 610,
            child: Container(
              width: 150,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 20, 22),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Color(0xFF007566)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
