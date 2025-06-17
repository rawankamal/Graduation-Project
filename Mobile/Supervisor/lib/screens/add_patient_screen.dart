import 'dart:io';
import 'package:autine1/screens/add_bot_screen.dart';
import 'package:autine1/services/api_services.dart';
import 'package:autine1/services/validations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ApiService apiService = ApiService();


class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  int _currentStep = 0;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _lastSessionDateController = TextEditingController();
  final TextEditingController _nextSessionDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  bool _fieldsFilled = false;
  String? _selectedGender;
  File? _imageFile;
  DateTime _selectedDate = DateTime(2000, 1, 1);
  String? _selectedDiagnosis;
  String? _selectedStatus;
  String? _selectedSessionFrequency;
  DateTime? _lastSessionDate;
  DateTime? _nextSessionDate;
 String token='';
 String parsedDOB ='';
 String parsedLS ='';
 String parsedNS ='';

  final List<String> _diagnosisOptions = [
    'Moderate ASD',
    'Mild ASD',
    'Severe ASD',
    'Nonverbal',
    'Speech Delay',
    'Sensory Issues',
    'ADHD & ASD',
  ];
  final List<String> _statusOptions = ['Stable', 'Critical', 'Improving'];
  final List<String> _sessionFrequencyOptions = [
    'Once a week',
    'Twice a week',
    'Three times a week',
    'Every two weeks',
    'Once a month',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
    _dateController.addListener(_checkFields);
    _supervisorController.addListener(_checkFields);
    _lastSessionDateController.addListener(_checkFields);
    _nextSessionDateController.addListener(_checkFields);
    _notesController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    _lastSessionDateController.dispose();
    _nextSessionDateController.dispose();
    _notesController.dispose();
    _supervisorController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      if (_currentStep == 0) {
        _fieldsFilled = _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _dateController.text.isNotEmpty &&
            _selectedGender != null;
      } else if (_currentStep == 2) {
        _fieldsFilled = _selectedDiagnosis != null &&
            _selectedStatus != null &&
            _supervisorController.text.isNotEmpty;
      } else if (_currentStep == 3) {
        _fieldsFilled = _lastSessionDateController.text.isNotEmpty &&
            _nextSessionDateController.text.isNotEmpty &&
            _selectedSessionFrequency != null;
      } else {
        _fieldsFilled = true; // For step 1 (email verification) or others
      }
    });
  }

  // Call _checkFields when changing steps
  void _onStepChanged() {
    _checkFields();
  }

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

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
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

    if (pickedDate != null && pickedDate != _selectedDate) {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
        String bdate = _dateController.text.trim();
                    DateFormat inputFormat = DateFormat('yyyy/MM/dd');
                    DateTime pickDate = inputFormat.parse(bdate);
                    DateTime utcDate = DateTime.utc(
                      pickDate.year,
                      pickDate.month,
                      pickDate.day,
                      0, 0, 0,
                      );
        String bDate = utcDate.toIso8601String().replaceFirst(RegExp(r'\.000'), ''); 
        await saveData(bDate, "dob");
    }
  }

  Future<void> _pickLastSessionDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastSessionDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF204E4C),
            colorScheme: const ColorScheme.light(primary: Color(0xFF204E4C)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
        _lastSessionDate = pickedDate;
        _lastSessionDateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
        String bdate = _lastSessionDateController.text.trim();
                    DateFormat inputFormat = DateFormat('yyyy/MM/dd');
                    DateTime pickDate = inputFormat.parse(bdate);
                    DateTime utcDate = DateTime.utc(
                      pickDate.year,
                      pickDate.month,
                      pickDate.day,
                      0, 0, 0,
                      );
        String bDate = utcDate.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        await saveData(bDate, "lSession");
    }
     
  }

  Future<void> _pickNextSessionDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextSessionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF204E4C),
            colorScheme: const ColorScheme.light(primary: Color(0xFF204E4C)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      
        _nextSessionDate = pickedDate;
        _nextSessionDateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
        String bdate = _nextSessionDateController.text.trim();
                    DateFormat inputFormat = DateFormat('yyyy/MM/dd');
                    DateTime pickDate = inputFormat.parse(bdate);
                    DateTime utcDate = DateTime.utc(
                      pickDate.year,
                      pickDate.month,
                      pickDate.day,
                      0, 0, 0,
                      );
        String bDate = utcDate.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        await saveData(bDate, "nSession");
    }
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildHeader(),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepProgressIndicator(),
                    const SizedBox(height: 20),
                    _buildStepContent(),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildBottomButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Add New Patient',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildStepProgressIndicator() {
    const stepTitles = ['Patient Info', 'Verify Email', 'Care Info', 'Session Plan'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stepTitles.length, (index) {
        final isSelected = _currentStep == index;
        final isCompleted = index < _currentStep;

        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected
                  ? const Color(0xFFB8CC66)
                  : isCompleted
                  ? const Color(0xFF204E4C)
                  : Colors.grey[300],
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stepTitles[index],
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showImagePicker(context),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(31.58),
                  ),
                  child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? SvgPicture.asset(
                          'assets/images/Generic avatar.svg',
                          width: 48,
                          height: 48,
                        )
                      : null,
                ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Picture',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF204E4C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                        });
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFF4B4B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          CustomTextInput(
            label: 'First Name',
            hint: 'First Name',
            controller: _firstNameController,
          ),
          CustomTextInput(
            label: 'Last Name',
            hint: 'Last Name',
            controller: _lastNameController,
          ),
          CustomTextInput(
            label: 'Email',
            hint: 'Email',
            controller: _emailController,
          ),
          CustomTextInput(
            label: 'Password',
            hint: 'Password',
            controller: _passwordController,
            obscureText: true,
          ),
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildGenderButton('Female')),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderButton('Male')),
            ],
          ),
          const SizedBox(height: 15),
          CustomDateInput(
            label: 'Date of Birth',
            hint: 'yyyy/MM/dd',
            controller: _dateController,
            onTap: _showDatePicker,
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SvgPicture.asset(
                  'assets/images/envelope.svg',
                  width: 200,
                ),
                Positioned(
                  top: 1,
                  right: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/circle.svg',
                        height: 60,
                      ),
                      const Text(
                        '1',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          fontSize: 30.32,
                          letterSpacing: 0.1,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              "Verify your email",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "We have sent a verification link to your email. Please tap the link inside the email to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      );
    } else if (_currentStep == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF204E4C),
            ),
          ),
          const SizedBox(height: 20),
          CustomDropdownInput(
            label: 'Diagnosis',
            value: _selectedDiagnosis,
            items: _diagnosisOptions,
            onChanged: (value) {
              setState(() {
                _selectedDiagnosis = value;
                _checkFields();
              });
            },
            hint: 'Select Diagnosis',
          ),
          CustomDropdownInput(
            label: 'Status',
            value: _selectedStatus,
            items: _statusOptions,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
                _checkFields();
              });
            },
            hint: 'Select Status',
          ),
          const Text(
            'Supervision Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF204E4C),
            ),
          ),
          const SizedBox(height: 20),
          CustomTextInput(
            label: 'Add Additional Supervisor',
            hint: 'Supervisor Email',
            controller: _supervisorController,
          ),
        ],
      );
    } else if (_currentStep == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDateInput(
            label: 'Last Session Date',
            hint: 'yyyy/MM/dd',
            controller: _lastSessionDateController,
            onTap: _pickLastSessionDate,
          ),
          CustomDateInput(
            label: 'Next Session Date',
            hint: 'yyyy/MM/dd',
            controller: _nextSessionDateController,
            onTap: _pickNextSessionDate,
          ),
          CustomDropdownInput(
            label: 'Session Frequency',
            value: _selectedSessionFrequency,
            items: _sessionFrequencyOptions,
            onChanged: (value) {
              setState(() {
                _selectedSessionFrequency = value;
                _checkFields();
              });
            },
            hint: 'Select Frequency',
          ),
          CustomTextInput(
            label: 'Notes',
            hint: 'Add additional notes about the patient...',
            controller: _notesController,
            maxLines: 5,
          ),
        ],
      );
    }
    return const Center(child: Text("Other steps..."));
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
          _checkFields();
        });
      },
      child: Container(
        width: 140,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8CC66) : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFFB8CC66) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (_currentStep == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _fieldsFilled
                ? () {
                  if(isValidPass(_passwordController.text) && isValidEmail(_emailController.text)){
              setState(() {
                _currentStep++;
                _onStepChanged();
              });}
              else{
                  throw Exception('Not valid Email or Password!');
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _fieldsFilled ? const Color(0xFF204E4C) : const Color(0xFFB3B3B3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep--;
                _onStepChanged(); 
              });
              
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF204E4C),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep++;
                _onStepChanged(); 
              });
            
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF204E4C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Check Inbox',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    } else if (_currentStep == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep--;
                _onStepChanged();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _fieldsFilled
                ? () {
              setState(() {
                _currentStep++;
                _onStepChanged(); 
              });
             
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _fieldsFilled ? const Color(0xFF204E4C) : const Color(0xFFB3B3B3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    } else if (_currentStep == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep--;
                _onStepChanged(); // Revalidate fields on step change
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _fieldsFilled
                ? () async{
              final prefs = await SharedPreferences.getInstance();
              String token =prefs.getString("token").toString();
              String dob =prefs.getString("dob").toString();
              String lSession =prefs.getString("lSession").toString();
              String nSession =prefs.getString("nSession") .toString();
              String uname= apiService.generateUname(_emailController.text);
              final patientData = {
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'email': _emailController.text,
                'password': _passwordController.text,
                "userName": uname,
                "bio": "Hey there, I'm using autine!",
                "country": "Egypt",
                "city": "Cairo",
                'gender': _selectedGender ?? 'Unknown',
                'dateOfBirth': dob,
                'diagnosis': _selectedDiagnosis ?? 'Not specified',
                'status': _selectedStatus ?? 'Stable',
                'lastSession': lSession ,
                'nextSession': nSession,
                'notes': _notesController.text,
              };

              await superService.addPatient(context, patientData, token);
              Navigator.of(context).pop();
              
              print(_firstNameController.text);
              print(_lastNameController.text);
              print(_emailController.text);
              print(_passwordController.text);
              print(dob);
              print( _selectedGender);
              print(_selectedDiagnosis);
              print(_selectedStatus);
              print(lSession);
              print(nSession);
              print( _selectedSessionFrequency);
              print(_notesController.text);

            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _fieldsFilled ? const Color(0xFF204E4C) : const Color(0xFFB3B3B3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class CustomTextInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final bool obscureText;

  const CustomTextInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB8CC66)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CustomDateInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const CustomDateInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: onTap,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFB8CC66)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CustomDropdownInput extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  const CustomDropdownInput({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFB8CC66)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


