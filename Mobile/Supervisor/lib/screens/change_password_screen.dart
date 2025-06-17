import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autine1/screens/loading_screen.dart';
import 'package:autine1/services/validations.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
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
            Text(
              "Reset your password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Create a strong and unique password to secure your account.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            _buildPasswordField("New password", newPasswordController, true),
            SizedBox(height: 10),
            _buildPasswordField("Password confirmation", confirmPasswordController, false),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF204E4C),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  String newPassword = newPasswordController.text.trim();
                  String confirmPassword = confirmPasswordController.text.trim();


                      if (newPassword.isNotEmpty && newPassword.isNotEmpty) {
                        if(newPassword == confirmPassword){
                          if(isValidPass(newPassword)){
                            final prefs = await SharedPreferences.getInstance();
                            String pass = newPasswordController.text.trim();
                            String code = prefs.getString('code').toString();
                            String userId = prefs.getString('userId').toString();
                            Navigator.push(context,
                         MaterialPageRoute(builder: (context) => LoadingScreen()), 
                                    );
                           await apiService.resetPassword(context,pass, userId,code);
                           }else {
                             ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please use a valid password, passwords should have at least 8 characters, one special character, one uppercase letter & one digit!'))
                      );
                           }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match!'))
                    );
                        }
                      }else{
                         ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields!'))
                    );
                      }
                },
                child: Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hintText, TextEditingController controller, bool isFirstField) {
    return TextField(
      controller: controller,
      obscureText: isFirstField ? !isPasswordVisible : !isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            isFirstField ?
            (isPasswordVisible ? Icons.visibility : Icons.visibility_off) :
            (isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isFirstField) {
                isPasswordVisible = !isPasswordVisible;
              } else {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }
}
