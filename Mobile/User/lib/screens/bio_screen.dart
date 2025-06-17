import 'package:flutter/material.dart';
import 'package:test_sign_up/screens/address_screen.dart';
import '../services/api_services.dart';

class BioScreen extends StatefulWidget {
  @override
  _BioScreenState createState() => _BioScreenState();
final ApiService apiService = ApiService();

  BioScreen({super.key});

}

class _BioScreenState extends State<BioScreen> {
  final TextEditingController _bioController = TextEditingController();
  final int _maxBioLength = 160;

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
                    value: .83,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Add Bio",
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
              "Add few words about yourself.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLength: _maxBioLength,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: "bio...",
                    counterText: "",
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${_bioController.text.length}/$_maxBioLength",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                 String bio = _bioController.text.trim();
                 saveData(bio, "bio");
                   Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF204E4C),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
               String defautBio="Hi! I'm using Autine";
                saveData(defautBio, "bio");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressScreen()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
