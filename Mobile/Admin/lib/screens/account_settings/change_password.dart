import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/services/validations.dart';

final ApiService apiService = ApiService();

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  // Separate obscure text states for each field
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  final TextEditingController passController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    passController.dispose();
    newPassController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: -10,
        title: const Row(
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                letterSpacing: 0.001,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Current Password',
              hint: 'Current Password',
              controller: passController,
              obscureText: _obscureCurrentPassword,
              onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'New Password',
              hint: 'New Password',
              controller: newPassController,
              obscureText: _obscureNewPassword,
              onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Confirm New Password',
              hint: 'New Password',
              controller: confirmController,
              obscureText: _obscureConfirmPassword,
              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF204E4C),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            String loginPass = prefs.getString("loginpassword").toString();
            String registerPass = prefs.getString("password").toString();
            String token = prefs.getString("token").toString();
            String currentPassword = passController.text;
            final newPassword = newPassController.text;
            final confirmPassword = confirmController.text;

            if (newPassword != confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }
            else if ((currentPassword != loginPass) && (currentPassword != registerPass)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter your current password correctly!')),
              );
              return;
            } else if (!isValidPass(newPassword)){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords should be at least 8-character length and should have atleast: 1 digit, 1 uppercase letter, 1 spectial character')),
              );
              return;
            }
            else {
              apiService.changePass(context, token, currentPassword, newPassword);
            }
          },
          child: const Text(
            "Save Changes",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF666666),
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF204E4C)),
            ),
          ),
        ),
      ],
    );
  }
}