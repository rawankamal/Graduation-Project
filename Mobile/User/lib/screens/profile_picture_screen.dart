import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_sign_up/screens/bio_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:test_sign_up/services/api_services.dart';

class ProfilePictureScreen extends StatefulWidget {
  final ApiService apiService = ApiService();
  ProfilePictureScreen({super.key});

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _imageFile;

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image != null) {
      final File file = File(image.path);
      
      // Check file size (max 5MB)
      final int fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        setState(() {
           print("Picture size too big!");
           ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Picture size exceeded 5MB, please try another one!')),);
        });
        return;
      }

      setState(() {
        _imageFile = file;
      });
    }
  }
  

  @override
  void initState() {
    super.initState();
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            const Center(
              child: Text(
                "Add picture",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Choose from gallery"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              title: const Text("Take photo"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPictureSelected = _imageFile != null; // Check if picture is selected

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
                    value: .66,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF204E4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Add a profile picture",
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
              "Add your profile picture.",
              style: TextStyle(fontSize: 14, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Profile picture
            Center(
              child: GestureDetector(
                onTap: () => _showImagePicker(context),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? SvgPicture.asset(
                          'assets/images/Generic avatar.svg',
                          width: 100,
                          height: 100,
                        )
                      : null,
                ),
              ),
            ),

            const Spacer(),

            Column(
              children: [
                ElevatedButton(
                  onPressed: ()async {
                if (_imageFile != null) {
                  await apiService.updatepic(context, _imageFile!);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => BioScreen()));
                    } else {
                      _showImagePicker(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF204E4C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isPictureSelected ? "Next" : "Add Picture",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () async {
                    if (isPictureSelected) {
                      _showImagePicker(context); // Change picture
                    } else {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BioScreen()), // Skip
                      );
                    }
                  },
                  child: Text(
                    isPictureSelected ? "Change Picture" : "Skip",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
