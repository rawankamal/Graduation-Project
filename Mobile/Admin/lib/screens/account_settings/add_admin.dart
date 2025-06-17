import 'package:admin/services/admin_services.dart';
import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adminService adminservice = adminService();
var admin =adminService();

class AddAdmin extends StatefulWidget {
  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late DateTime _selectedDate;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dobController = TextEditingController();
    _bioController = TextEditingController();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedDate = DateTime.now().subtract(Duration(days: 365 * 20));
    _selectedGender = 'Male';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      barrierColor: Color(0xFF204E4C).withOpacity(0.5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF204E4C),
            colorScheme: ColorScheme.light(primary: Color(0xFF204E4C)),
            dialogBackgroundColor: Colors.white,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
         String bdate = _dobController.text.trim();
         DateFormat inputFormat = DateFormat('yyyy/MM/dd');
         DateTime pickDate = inputFormat.parse(bdate);
         DateTime utcDate = DateTime.utc(
           pickDate.year,
           pickDate.month,
           pickDate.day,
           0, 0, 0,
           );
        String rfc333 = utcDate.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        saveData(rfc333, "dob");
      });
    }
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () async{
        setState(() {
          _selectedGender = gender;
        });
        await saveData(_selectedGender, "gender");
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
        Text(
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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

  Widget _buildEditableField(String label, TextEditingController controller, {int maxLines = 1, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Admin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField('First Name', _firstNameController),
                  _buildEditableField('Last Name', _lastNameController),
                  _buildEditableField('Email', _emailController),
                  _buildEditableField('Password', _passwordController, obscureText: true),
                  _buildDateField(),
                  _buildGenderField(),
                  _buildEditableField('Bio', _bioController, maxLines: 3),
                  _buildEditableField('Country', _countryController),
                  _buildEditableField('City', _cityController),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: ()async {
                    final prefs = await SharedPreferences.getInstance();
                    String uname = apiService.generateUname(_emailController.text);
                    String gender =prefs.getString("gender").toString();
                    String token =prefs.getString("token").toString();
                    String dob =prefs.getString("dob").toString();
                    final adminData = {
                      "firstName": _firstNameController.text,
                      "lastName": _lastNameController.text,
                      "email": _emailController.text,
                      "userName": uname,
                      "password": _passwordController.text,
                      "gender": gender,
                      "dateOfBirth": dob,
                      "country": _countryController.text,
                      "city": _cityController.text,
                      "bio": _bioController.text
                      };
                      await admin.addAdmin(context,adminData,token);
                         },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF204E4C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Add Admin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}