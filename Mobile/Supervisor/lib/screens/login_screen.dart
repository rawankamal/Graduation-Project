import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/validations.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black ,size: 17,),
          onPressed: () {
            Navigator.pushNamed(context, '/welcome');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Hello again !",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enter the email associated to your account.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "example@gmail.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                        String email = emailController.text.trim();
                        if (email.isNotEmpty && isValidEmail(email)) {
                          await saveData(email,"loginemail");
                          String uname =apiService.generateUname(email);
                          await saveData(uname,"username");
                          Navigator.pushNamed(context, '/password');
                        }
                        else if(email.isNotEmpty && !isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email!'))
                          );
                        } else{
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your email!'))
                          );
                        }
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF204E4C),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don’t have an account?",
                          style: TextStyle(
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/create_account');
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontFamily: "Open Sans",
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0,
                              decoration: TextDecoration.underline,
                              color: Color(0xFF204E4C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}