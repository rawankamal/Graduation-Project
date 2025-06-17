import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_account_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 204,
            left:100,
            child: SvgPicture.asset(
              'assets/images/logo2.svg',
              width: 160,
              height:160,
            ),
          ),
          Positioned(
            top: 396,
            left: 57,
            width: 247,
            height: 39,
            child: Text(
              'Welcome to Autine',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 39.2 / 28,
                letterSpacing: 0.001,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Positioned(
            top: 439,
            left: 37,
            width: 287,
            height: 44,
            child: Text(
              'Create your account or sign in to an existing account to start chatting with bot.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 22.4 / 14,
                letterSpacing: 0.001,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Positioned(
            top: 610,
            left: (screenWidth - 328) / 2,
            child: SizedBox(
              width: 328,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccountScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF204E4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 40),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: Color(0xFFFBFBFB),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 665,
            left: (screenWidth - 328) / 2,
            child: SizedBox(
              width: 328,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF204E4C), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 40),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: Color(0xFF204E4C),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


