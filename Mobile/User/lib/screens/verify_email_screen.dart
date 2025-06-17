import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_sign_up/screens/welcome_screen.dart';
import 'verifying_email_screen.dart';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ApiService apiService = ApiService();

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
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
                "Verify your email",
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
                "We have sent a verification link to your email Please tap the link inside the email to continue.",
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
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()), //inbox
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204E4C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Check inbox",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                      String email = prefs.getString('email').toString();
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerifyingEmailScreen()), 
                    );
                      await apiService.reconfirmEmail(context,email);
                     
                  },
                  child: const Text(
                    "Resend verification link",
                    style: TextStyle(
                      color: Color(0xFF204E4C),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
