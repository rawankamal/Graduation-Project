import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 29),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 100),
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
                        const Text(
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
            const SizedBox(height: 24),
            const Center(
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
            const SizedBox(height: 10),
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
            const Spacer(),
            OutlinedButton(
              onPressed: () { //for now
              },

              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF204E4C)),
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Resend Email",
                style: TextStyle(color: Color(0xFF204E4C), fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}