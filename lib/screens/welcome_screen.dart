// ** 1) WELCOME SCREEN w/ LOGO **

import 'dart:core';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFCFC6BA), // :))) (NOTE: copy and paste for use as palette)
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //LOGOOO
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/log_in.png', 
                width: 600,
                height: 600,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // SIGN UP 
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:const Color(0xFFE0DED9), 
                foregroundColor:Colors.black, 
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                      color: Colors.black, width: 1),
                ),
                elevation: 5,
              ),
              onPressed: () {
                // -> LOGIN SCREEN
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}