import 'package:flutter/material.dart';
import 'birthday_screen.dart';
import '../services/api_services.dart';

class WhatIsYourNameScreen extends StatefulWidget {
  @override
  _WhatIsYourNameScreenState createState() => _WhatIsYourNameScreenState();
final ApiService apiService = ApiService();

  WhatIsYourNameScreen({super.key});

}

class _WhatIsYourNameScreenState extends State<WhatIsYourNameScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.16,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF204E4C)),
            ),
            const SizedBox(height: 30),


            const Text(
              "What is your name ?",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                height: 39.2 / 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              "Enter your first and last name.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Spacer(),


            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                   String fname = firstNameController.text.trim();
                   String lname = lastNameController.text.trim();
                        if (fname.isNotEmpty && lname.isNotEmpty ) {
                          await saveData(fname,"fname");
                          await saveData(lname,"lname");
                          Navigator.push(
                           context,
                          MaterialPageRoute(builder: (context) => BirthdayScreen()),
                              );
                        }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Both first and last names are required'))
                          );
                        }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204E4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Next",
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
