import 'package:flutter/material.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signing_in_screen.dart';
import 'screens/check_email_screen.dart';
import 'screens/login_screen.dart';
import 'screens/password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/change_password_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Autine App',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/password': (context) => PasswordScreen(),
        '/signing_in': (context) => SigningInScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/check_email': (context) => CheckEmailScreen(),
        '/change_password': (context) => ChangePasswordScreen(),


      },
    );
  }
}
