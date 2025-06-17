import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_services.dart';

class EditProfile extends StatefulWidget {

  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}


  class _EditProfileState extends State<EditProfile> {
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _dobController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;

  DateTime _selectedDate = DateTime(2000, 1, 1);
  late String _selectedGender;

  String _fname = '';
  String _lname = '';
  String _bdate = '';
  String _gender = '';
  String _bio = '';
  String _city = '';
  String _country = '';
  String token='';
  String _profileImageUrl='';
  File? _imageFile;
  String parsed ='';


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
        apiService.updatepic(context,_imageFile!);
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _loadProfileData(); 


  }

  // Load the profile Data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('ppic') ?? ''; 
      _fname = prefs.getString('fname') ?? '';
      _lname = prefs.getString('lname') ?? '';
      _bdate = prefs.getString('dob').toString();
      _gender = prefs.getString('gender').toString();
      _bio = prefs.getString('bio').toString();
      _city = prefs.getString('city').toString();
      _country = prefs.getString('country').toString();
      token = prefs.getString("token").toString();
      parsed = apiService.formatDate(_bdate);

    _fnameController = TextEditingController(text: _fname);
    _lnameController = TextEditingController(text: _lname);
    _dobController = TextEditingController(text: parsed);
    _bioController = TextEditingController(text: _bio);
    _countryController = TextEditingController(text: _country);
    _cityController = TextEditingController(text: _city);
    _selectedGender = _gender;

    });
      

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


   Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      barrierColor: const Color(0x80204E4C),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF204E4C),
            colorScheme: const ColorScheme.light(primary: Color(0xFF204E4C)),
            dialogBackgroundColor: Colors.white,
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate){
      setState(() {
         _selectedDate = pickedDate;
         _dobController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
          String bdate = _dobController.text;
          DateFormat inputFormat = DateFormat('yyyy/MM/dd');
          DateTime pickDate = inputFormat.parse(bdate);
                // Set time to 00:00:00 and convert to UTC
          DateTime utcDate = DateTime.utc(
           pickDate.year,
           pickDate.month,
           pickDate.day,
           0, 0, 0,
            );

          String rfc3339Date = utcDate.toIso8601String(); 
          saveData(rfc3339Date, "dob");

      });
    }
  }


  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        width: 140,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFFB8CC66) : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Color(0xFFB8CC66) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGenderButton('Male'),
            _buildGenderButton('Female'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async{
              Navigator.pop(context, {  
              });
            final prefs = await SharedPreferences.getInstance();
            Map<String, dynamic> userData = {};
            String date =prefs.getString("dob").toString();

            setState(() {
                userData = {
                "firstName": _fnameController.text,
                "lastName": _lnameController.text,
                "bio": _bioController.text,
                "dateOfBirth":date,
                "Gender":_selectedGender,
                "Country":_country,
                "City": _cityController.text,
                "superviorRole":"Doctor"
                         };
            });
               await apiService.updatedata(context,token,userData);
               await saveData(_selectedGender, "gender");
               await saveData(_cityController.text, "city");
               await saveData(_countryController.text, "country");
               await saveData(date, "dob");
               await saveData(_bioController.text, "bio");
               await saveData(_fnameController.text, "fname");
               await saveData(_lnameController.text, "lname");
          },
            
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF204E4C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:   Stack(
                    children: [
                      CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF204E4C),
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile != null
                      ? null
                      : ClipOval(
                      child: Image.network(_profileImageUrl,
                      headers: {
                      'Authorization': 'Bearer $token',
                       },
                       fit: BoxFit.cover,
                       width: 80,
                       height: 80,
                       errorBuilder: (context, error, stackTrace) {
                         return Center(
                           child: Text(
                             "${_fname.isNotEmpty ? _fname[0] : ''}${_lname.isNotEmpty ? _lname[0] : ''}",
                             style: const TextStyle(
                               fontFamily: 'Nunito',
                               fontSize: 32,
                               fontWeight: FontWeight.w500,
                               color: Colors.white,
                             ),
                           ),
                         );
                       },
                     ),
                      ),),
                   Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildEditableField('First Name', _fnameController),
            _buildEditableField('Last Name', _lnameController),
            _buildDateField(),
            _buildGenderField(),
            _buildEditableField('Bio', _bioController, maxLines: 3),
            _buildEditableField('Country', _countryController),
            _buildEditableField('City', _cityController),
          ],
        ),
      ),
    );
  }
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of birth',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: _showDatePicker,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE6E6E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFB8CC66)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE6E6E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFB8CC66)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}