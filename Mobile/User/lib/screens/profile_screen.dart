import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:test_sign_up/services/api_services.dart';
import 'change_city.dart';
import 'change_country.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService = ApiService();
  ProfileScreen({super.key});
 

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

 

class _ProfileScreenState extends State<ProfileScreen> {

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
  
  void _showEditFirstNameDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(text: _fname);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (context) =>
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Change First Name",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _fname = controller.text;
                      });
                      Navigator.pop(context);
                       final prefs = await SharedPreferences.getInstance();
                     String lname = prefs.getString('lname').toString();
                     String bio = prefs.getString('bio').toString();
                     String token = prefs.getString('token').toString();
                     String gender = prefs.getString('gender').toString();
                     String bdate = prefs.getString('dob').toString();
                     String country = prefs.getString('country').toString();
                     String city = prefs.getString('city').toString();
                    
                     Map<String, dynamic> userData = {
                        "firstName": _fname,
                        "lastName": lname,
                        "bio": bio,
                        "DateOfBirth":bdate,
                        "Gender":gender,
                        "Country": country,
                        "City": city
                         };
                    await apiService.updatedata(context,token,userData);  
                    await saveData(_fname,"fname");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF204E4C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Save Changes", style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showEditLastNameDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(text: _lname);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (context) =>
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Change Last Name",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _lname = controller.text;
                      });
                       Navigator.pop(context);
                       final prefs = await SharedPreferences.getInstance();
                       String bio = prefs.getString('bio').toString();
                       String fname = prefs.getString('fname').toString();
                       String token = prefs.getString('token').toString();
                       String gender = prefs.getString('gender').toString();
                       String bdate = prefs.getString('dob').toString();
                       String country = prefs.getString('country').toString();
                       String city = prefs.getString('city').toString();
                    
                       Map<String, dynamic> userData = {
                        "firstName": fname,
                        "lastName": _lname,
                        "bio": bio,
                        "DateOfBirth":bdate,
                        "Gender":gender,
                        "Country": country,
                        "City": city
                         };
                    await apiService.updatedata(context,token,userData);  
                    await saveData(_lname,"lname");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF204E4C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Save Changes", style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showEditBirthDateDialog(BuildContext context) {
  
  TextEditingController controller = TextEditingController(text: parsed);

  DateTime? parsedDate;
  try {
    parsedDate = DateFormat("yyyy/MM/dd").parse(_bdate); // Adjust format as needed
  } catch (e) {
    parsedDate = DateTime.now(); // Default to today if parsing fails
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x80204E4C),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Change Birth Date",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: parsedDate ?? DateTime.now(),
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

              if (pickedDate != null) {
                controller.text = DateFormat("yyyy/MM/dd").format(pickedDate);
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ()async {
                setState(() {
                  _bdate = controller.text;
                });
                Navigator.pop(context);
                DateFormat inputFormat = DateFormat('yyyy/MM/dd');
                DateTime pickedDate = inputFormat.parse(_bdate);
                // Set time to 00:00:00 and convert to UTC
                DateTime utcDate = DateTime.utc(
                 pickedDate.year,
                 pickedDate.month,
                 pickedDate.day,
                 0, 0, 0,
                 );

                 String rfc3339Date = utcDate.toIso8601String(); 
                 final prefs = await SharedPreferences.getInstance();
                       String bio = prefs.getString('bio').toString();
                       String fname = prefs.getString('fname').toString();
                       String token = prefs.getString('token').toString();
                       String gender = prefs.getString('gender').toString();
                       String lname = prefs.getString('lname').toString();
                       String country = prefs.getString('country').toString();
                       String city = prefs.getString('city').toString();
                    
                       Map<String, dynamic> userData = {
                        "firstName": fname,
                        "lastName": lname,
                        "bio": bio,
                        "DateOfBirth":rfc3339Date,
                        "Gender":gender,
                        "Country": country,
                        "City": city
                         };
                    await apiService.updatedata(context,token,userData);  
                    await saveData(rfc3339Date, "dob");
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204E4C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditGenderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Change Gender",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildGenderButton("Female"),
            const SizedBox(height: 15),

            _buildGenderButton("Male"),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  Navigator.pop(context);
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204E4C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton(String genderType) {
    bool isSelected = _gender == genderType;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async{
            final prefs = await SharedPreferences.getInstance();
            Map<String, dynamic> userData={};
          setState(() {
           _gender = genderType;
          });
               String bio = prefs.getString('bio').toString();
               String fname = prefs.getString('fname').toString();
               String token = prefs.getString('token').toString();
               String lname = prefs.getString('lname').toString();
               String bdate = prefs.getString('dob').toString();
               String country = prefs.getString('country').toString();
               String city = prefs.getString('city').toString();
            
                userData = {
                "firstName": fname,
                "lastName": lname,
                "bio": bio,
                "DateOfBirth":bdate,
                "Gender":_gender,
                "Country": country,
                "City": city
                         };
              await apiService.updatedata(context,token,userData);  
              await saveData(_gender ,"gender");
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFFB8CC66) : Colors.grey,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          genderType,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  final int _maxBioLength = 160;
  void _showEditBioDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Change Bio",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                  controller: controller,
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
                "${controller.text.length}/$_maxBioLength",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  setState(() {
                    _bio = controller.text;
                  });
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
               String gender = prefs.getString('gender').toString();
               String fname = prefs.getString('fname').toString();
               String token = prefs.getString('token').toString();
               String lname = prefs.getString('lname').toString();
               String bdate = prefs.getString('dob').toString();
               String country = prefs.getString('country').toString();
               String city = prefs.getString('city').toString();
            
               Map<String, dynamic> userData = {
                "firstName": fname,
                "lastName": lname,
                "bio": _bio,
                "DateOfBirth":bdate,
                "Gender":gender,
                "Country": country,
                "City": city
                         };
               await apiService.updatedata(context,token,userData);  
               await saveData(_bio ,"bio");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF204E4C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  void _showEditCountryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x80204E4C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (context) => ChangeCountryBottomSheet(
        onCountrySelected: (selectedCountry)  {
          setState(() {
            _country = selectedCountry;
            
          });
        },
      ),
    );
  }

  void _showEditCityDialog(BuildContext context) {
    if (_country == "Egypt") {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        barrierColor: const Color(0x80204E4C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        isScrollControlled: true,
        builder: (context) => ChangeCityBottomSheet(
          selectedCountry: _country,
          onCitySelected: (selectedCity) async{
            final prefs = await SharedPreferences.getInstance();
            Map<String, dynamic> userData = {};

            setState(() {
              _city = selectedCity;
               String bio = prefs.getString('bio').toString();
               String fname = prefs.getString('fname').toString();
               token = prefs.getString('token').toString();
               String lname = prefs.getString('lname').toString();
               String bdate = prefs.getString('dob').toString();
               String gender = prefs.getString('gender').toString();
            
                userData = {
                "firstName": fname,
                "lastName": lname,
                "bio": bio,
                "dateOfBirth":bdate,
                "Gender":gender,
                "Country":_country,
                "City": _city,
                
                         };
               
            });
               await apiService.updatedata(context,token,userData);
               await saveData(_country, "country");
               await saveData(_city, "city");
          },
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            height: 1.4,
            letterSpacing: 0.001,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),


                  Stack(
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
                   ),
                ),

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
                            child: const Icon(Icons.edit_outlined, size: 18,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$_fname $_lname",
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      height: 1.4,
                      letterSpacing: 0.001,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),


                  profileInfoItem("First Name", _fname, onTap: () => _showEditFirstNameDialog(context)),
                  profileInfoItem("Last Name", _lname, onTap: () => _showEditLastNameDialog(context)),
                  profileInfoItem("Date of Birth", parsed,onTap: () => _showEditBirthDateDialog(context)),
                  profileInfoItem("Gender", _gender, onTap: () => _showEditGenderDialog(context)),
                  profileInfoItem("Bio", _bio, onTap: () => _showEditBioDialog(context)),
                  profileInfoItem("Country", _country, onTap: () => _showEditCountryDialog(context)),
                  profileInfoItem("City", _city, onTap: () => _showEditCityDialog(context),
                  ),                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInfoItem(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.001,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.001,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                    Icons.arrow_forward_ios, size: 14, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}