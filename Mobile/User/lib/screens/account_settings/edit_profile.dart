import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  final String initialName;
  final String initialDob;
  final String initialGender;
  final String initialBio;
  final String initialCountry;
  final String initialCity;

  const EditProfile({
    super.key,
    required this.initialName,
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
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;

  late DateTime _selectedDate;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _dobController = TextEditingController(text: widget.initialDob);
    _bioController = TextEditingController(text: widget.initialBio);
    _countryController = TextEditingController(text: widget.initialCountry);
    _cityController = TextEditingController(text: widget.initialCity);
    _selectedGender = widget.initialGender;

    try {
      _selectedDate = DateFormat('MM/dd/yyyy').parse(widget.initialDob);
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
        _dobController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
      });
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFF8F8F8),
      barrierColor: Color(0x80204E4C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Add picture",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Choose from gallery",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Take photo",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            onPressed: () {
              Navigator.pop(context, {
                'name': _nameController.text,
                'dob': _dobController.text,
                'gender': _selectedGender,
                'bio': _bioController.text,
                'country': _countryController.text,
                'city': _cityController.text,
              });
            },
            child: Text(
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
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF2F2F2),
                    ),
                    child: Icon(Icons.person, size: 50, color: Color(0xFF999999)),
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
                        child: const Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildEditableField('Name', _nameController),
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