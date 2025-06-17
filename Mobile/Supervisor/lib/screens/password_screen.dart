import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/validations.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';


final TextEditingController passwordController = TextEditingController();
final ApiService apiService = ApiService();


class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool _obscurePassword = true;

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
            Navigator.pushNamed(context, '/login');
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
              "Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enter your password.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              obscureText: _obscurePassword,
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: ()async {
                  final prefs = await SharedPreferences.getInstance();
                  String email =prefs.getString("loginemail").toString();
                  await apiService.forgotPassword(context, email);
                },
                child: const Text(
                  "Forgot your password?",
                  style: TextStyle(
                    color: Color(0xFF204E4C),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: "By continuing, you agree to Autin’s ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  children: [
                    TextSpan(
                      text: "Terms",
                      style: const TextStyle(
                        color: Color(0xFF204E4C),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/terms');
                        },
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(
                        color: Color(0xFF204E4C),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/privacy_policy');
                        },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                 onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    String email =prefs.getString("loginemail").toString();
                    String password = passwordController.text.trim();

                    if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your password!'))
                      );
                    }
                    else if(password.isNotEmpty && !isValidPass(password) && fault=="length"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password should be at least 8 characters!'))
                      );
                    }
                     else if(password.isNotEmpty && !isValidPass(password) && fault=="upper"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one uppercase letter.'))
                      );
                      }
                       else if(password.isNotEmpty && !isValidPass(password) && fault=="digit"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one digit.'))
                      );}
                       else if(password.isNotEmpty && !isValidPass(password) && fault=="lower"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one lowercase letter.'))
                      );}
                       else if(password.isNotEmpty && !isValidPass(password) && fault=="special"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one special character.'))
                      );
                      }
                       else if(password.isNotEmpty && !isValidPass(password) && fault=="other"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid password: please create another password'))
                      );
                      }
                    else{
                          await saveData(password, "loginpassword");
                          await apiService.login(context,email,password);
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
            ),

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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}