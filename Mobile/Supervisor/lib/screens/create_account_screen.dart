import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/validations.dart';

class CreateAccountScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
final ApiService apiService = ApiService();

  CreateAccountScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.33,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF204E4C),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'What is your email?',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        height: 39.2 / 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ), const SizedBox(height: 10),
                    Text(
                      'Enter the email address you would like to use.',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14,
                        height: 22.4 / 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        if (email.isNotEmpty && isValidEmail(email)) {
                          await saveData(email,"email");
                          Navigator.pushNamed(context, '/create_password');
                        }
                        else if(email.isNotEmpty && !isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email'))
                          );
                        } else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your email'))
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
                        'Continue',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                     Navigator.pushNamed(context, '/login'); // Until login screen is done
                                      },
                      child: const Text(
                        "I already have an account",
                        style: TextStyle(
                          color: Color(0xFF204E4C),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        )
    );
  }
}