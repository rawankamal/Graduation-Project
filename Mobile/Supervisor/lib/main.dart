import 'package:autine1/screens/verifying_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:autine1/screens/congratulations_screen.dart';
import 'screens/gender_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signing_in_screen.dart';
import 'screens/address_screen.dart';
import 'screens/check_email_screen.dart';
import 'screens/login_screen.dart';
import 'screens/password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/birthday_screen.dart';
import 'screens/profile_picture_screen.dart';
import 'screens/bio_screen.dart';
import 'screens/loading_screen.dart';
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
        '/welcome': (context) => WelcomeScreen(),
        '/create_account': (context) => CreateAccountScreen(),
        '/create_password': (context) => CreatePasswordScreen(),
        '/verify_email': (context) => VerifyEmailScreen(),
        '/verifying_email': (context) => VerifyingEmailScreen(),
        '/login': (context) => LoginScreen(),
        '/password': (context) => PasswordScreen(),
        '/signing_in': (context) => SigningInScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/check_email': (context) => CheckEmailScreen(),
        '/birthday': (context) => BirthdayScreen(),
        '/gender': (context) => GenderScreen(),
        '/profile_picture': (context) => ProfilePictureScreen(),
        '/bio': (context) => BioScreen(),
        '/address': (context) => AddressScreen(),
        '/loading': (context) => LoadingScreen(),
        '/congratulations': (context) => CongratulationsScreen(),
        '/change_password': (context) => ChangePasswordScreen(),


      },
    );
  }
}
