import 'package:test_sign_up/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
 @override
  _LoadingScreenState createState() => _LoadingScreenState();

  
}

class _LoadingScreenState extends State<LoadingScreen> {
  
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
              "Just a few seconds....",
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
                MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          });
          return const Scaffold();
        }
      
      }
     );
  }
}
    
  


