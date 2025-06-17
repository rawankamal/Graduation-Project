import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/validations.dart';
import 'package:shared_preferences/shared_preferences.dart';



final TextEditingController passController = TextEditingController();
bool _obscurePassword = true;
final ApiService apiService = ApiService();


class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 29,),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black ,size: 17,),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.66,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Create a password",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 39.2 / 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Create a unique strong password.",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                  height: 22.4 / 14,
                  color: Colors.grey[700]),

            ),
            const SizedBox(height: 10),
            TextField(
              controller: passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String pass = passController.text.trim();
                      String email = prefs.getString('email').toString();

                      if (pass.isNotEmpty && isValidPass(pass)) {
                        await saveData(pass, "password");
                        await apiService.primRegister(context,email,pass);
                      }
                        else if(pass.isNotEmpty && !isValidPass(pass) && fault=="length"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password should be at least 8 characters!'))
                      );
                    }
                     else if(pass.isNotEmpty && !isValidPass(pass) && fault=="upper"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one uppercase letter.'))
                      );
                      }
                       else if(pass.isNotEmpty && !isValidPass(pass) && fault=="digit"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one digit.'))
                      );}
                       else if(pass.isNotEmpty && !isValidPass(pass) && fault=="lower"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one lowercase letter.'))
                      );}
                       else if(pass.isNotEmpty && !isValidPass(pass) && fault=="special"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must have at least one special character.'))
                      );
                      }
                       else if(pass.isNotEmpty && !isValidPass(pass) && fault=="other"){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid password: please create another password'))
                      );
                      }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your password!'))
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
                    Navigator.pushNamed(context, '/login'); 
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
