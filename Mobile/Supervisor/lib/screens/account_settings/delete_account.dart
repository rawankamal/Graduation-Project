import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autine1/services/api_services.dart';

final TextEditingController passwordController = TextEditingController();
final ApiService apiService = ApiService();

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: -10,
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            letterSpacing: 0.001,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color:Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For Security Reasons, Please Provide Your Existing Password',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1,
                color: Color(0xFF666666)
              ),

            ),
            SizedBox(height: 8,),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(

                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB8CC66)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xFFFF4B4B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async{
                  String pass = passwordController.text;
                  final prefs = await SharedPreferences.getInstance();
                  String loginPass =prefs.getString("loginpassword").toString();
                  String registerPass =prefs.getString("password").toString();
                  String token =prefs.getString("token").toString();
                  if ((pass != loginPass) && (pass != registerPass)){
                  ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Please enter your correct password!")),
                      );

                  } else{
                    apiService.deleteAccout(context, token);
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}