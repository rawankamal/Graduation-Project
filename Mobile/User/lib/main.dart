import 'package:flutter/material.dart';
import 'package:test_sign_up/screens/congratulations_screen.dart';
import 'package:test_sign_up/screens/verifying_email_screen.dart';
import 'screens/gender_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signing_in_screen.dart';
import 'screens/address_screen.dart';
import 'screens/check_email_screen.dart';
import 'screens/login_screen.dart';
import 'screens/password_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/birthday_screen.dart';
import 'screens/profile_picture_screen.dart';
import 'screens/bio_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/change_password_screen.dart';


void main() {
  runApp(const MyApp());
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
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/create_account': (context) => CreateAccountScreen(),
        '/create_password': (context) => const CreatePasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/login': (context) => LoginScreen(),
        '/verifying_email': (context) => const VerifyingEmailScreen(),
        '/password': (context) => const PasswordScreen(),
        '/signing_in': (context) => const SigningInScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/check_email': (context) => const CheckEmailScreen(),
        '/birthday': (context) => BirthdayScreen(),
        '/gender': (context) => GenderScreen(),
        '/profile_picture': (context) => ProfilePictureScreen(),
        '/bio': (context) => BioScreen(),
        '/address': (context) => AddressScreen(),
        '/congratulations': (context) => const CongratulationsScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(botName:"",botIcon: "",botId:''),
        '/change_password': (context) => ChangePasswordScreen(),
        '/loading': (context) => LoadingScreen(),



      },
    );
  }
}
