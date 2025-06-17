import 'package:flutter/material.dart';
import 'package:test_sign_up/screens/home_screen.dart';
import 'dart:async';

class SigningInScreen extends StatefulWidget {
  const SigningInScreen({super.key});

  @override
  _SigningInScreenState createState() => _SigningInScreenState();

  
}

class _SigningInScreenState extends State<SigningInScreen> {
  
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
            return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF204E4C)),
              strokeWidth: 4,
            ),
            SizedBox(height: 16),
            Text(
              "Signing you in....",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
        } else{
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
          return const Scaffold();
        }
      
      }
     );
  }
}
    
  


