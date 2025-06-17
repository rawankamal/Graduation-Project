import 'package:flutter/material.dart';
import 'package:autine1/screens/what_is_your_name_screen.dart';
import 'dart:async';

class VerifyingEmailScreen extends StatefulWidget {
 @override
  _VerifyingEmailScreenState createState() => _VerifyingEmailScreenState();

  
}

class _VerifyingEmailScreenState extends State<VerifyingEmailScreen> {
  
     Future<void> loadData() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate data fetching
    return;
}


  @override
  void initState() {
    super.initState();
  
  }

  @override
  Widget build(BuildContext context) {
     return FutureBuilder(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF204E4C)),
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Verifying your email....",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,

              ),
            ),
          ],
        ),
      ),
    );
        } else{
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(builder: (context) => WhatIsYourNameScreen()),
 //your name
            );
          });
          return const Scaffold();
        }
      
      }
     );
  }
}
    
  


