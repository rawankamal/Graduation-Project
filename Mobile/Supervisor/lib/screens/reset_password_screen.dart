import 'package:flutter/material.dart';
import '../services/api_services.dart'; 
import '../services/validations.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black ,size: 17,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            const Text(
              "Reset your password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            const Text(
              "Enter your email address and we will send you instructions to reset your password.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "example@gmail.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF204E4C),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async{
                      String email = emailController.text.trim();
                       if (email.isNotEmpty && isValidEmail(email)) {
                          print("Reset password for: $email");
                          Navigator.pushNamed(context, '/check_email');
                          await apiService.forgotPassword(context, email);
                          
                        }
                        else if(email.isNotEmpty && !isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a valid email!'))
                          );
                        } else{
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter your email address!'))
                          );
                        }
                      },
                    child: Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}