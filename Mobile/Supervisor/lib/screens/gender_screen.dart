import 'package:flutter/material.dart';
import 'package:autine1/screens/profile_picture_screen.dart';
import '../services/api_services.dart';

class GenderScreen extends StatefulWidget {
  @override
  _GenderScreenState createState() => _GenderScreenState();
final ApiService apiService = ApiService();

  GenderScreen({super.key});

}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

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
                    value: 0.5,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "What is your gender?",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                height: 39.2 / 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Select your gender.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                height: 22.4 / 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),

            _buildGenderButton("Female"),
            const SizedBox(height: 15),

            _buildGenderButton("Male"),
            const Spacer(),

            Column(
              children: [
                ElevatedButton(
                  onPressed: selectedGender == null ? null : () {
                    saveData(selectedGender.toString(), "gender");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePictureScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGender == null ? const Color(0xFFCCCCCC) : const Color(0xFF204E4C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = selectedGender == gender;

    return OutlinedButton(
      onPressed: () => _selectGender(gender),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFFB8CC66) : const Color(0xFF666666),
          width: 1.5,
        ),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        gender,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
