import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ApiService apiService = ApiService();


class EditProfile extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;
  final String initialDob;
  final String initialGender;
  final String initialBio;
  final String initialCountry;
  final String initialCity;

  const EditProfile({
    super.key,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialDob,
    required this.initialGender,
    required this.initialBio,
    required this.initialCountry,
    required this.initialCity,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;

  late DateTime _selectedDate;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _dobController = TextEditingController(text: widget.initialDob);
    _bioController = TextEditingController(text: widget.initialBio);
    _countryController = TextEditingController(text: widget.initialCountry);
    _cityController = TextEditingController(text: widget.initialCity);
    _selectedGender = widget.initialGender;

    try {
      _selectedDate = DateFormat('yyyy/MM/dd').parse(widget.initialDob);
    } catch (e) {
      _selectedDate = DateTime.now().subtract(Duration(days: 365 * 20));
    }
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
      onTap: () async {
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
        actions: [
          TextButton(
            onPressed: ()async {
               final prefs = await SharedPreferences.getInstance();
               String gender =prefs.getString("gender").toString();
               String token =prefs.getString("token").toString();
               String dob =prefs.getString("dob").toString();
              final adminData = {
               "firstName": _firstNameController.text,
               "lastName": _lastNameController.text,
               "gender": gender,
               "dateOfBirth": dob,
               "country": _countryController.text,
               "city": _cityController.text,
               "bio": _bioController.text
               };
               await apiService.updatedata(context,token,adminData);
               
              Navigator.pop(context, {
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'dob': _dobController.text,
                'gender': _selectedGender,
                'bio': _bioController.text,
                'country': _countryController.text,
                'city': _cityController.text,
              });
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
            SizedBox(height: 20),
            _buildEditableField('First Name', _firstNameController),
            _buildEditableField('Last Name', _lastNameController),
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

  Widget _buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
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