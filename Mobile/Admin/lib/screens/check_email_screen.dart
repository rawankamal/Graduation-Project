import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/screens/change_password_screen.dart';



class CheckEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 29),
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: 100),
            Center(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SvgPicture.asset(
                    'assets/images/envelope.svg',
                    width: 200,
                  ),
                  Positioned(
                    top: 1,
                    right: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/circle.svg',
                          height: 60,
                        ),
                        Text(
                          '1',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            fontSize: 30.32,
                            letterSpacing: 0.1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                "Check Your Email",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 39.2 / 28,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Please check your email address for instructions to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                  height: 22.4 / 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },

              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF204E4C)),
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Resend Email",
                style: TextStyle(color: Color(0xFF204E4C), fontSize: 16),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}