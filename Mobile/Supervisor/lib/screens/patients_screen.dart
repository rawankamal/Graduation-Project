import 'dart:io';
import 'package:autine1/services/api_services.dart';
import 'package:autine1/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_settings/account_screen.dart';
import 'add_patient_screen.dart';
import 'bots_screen.dart';
import 'chats_screen.dart';
import 'package:intl/intl.dart';
import 'home_notifications/home_screen.dart';

final SuperService superService= SuperService();
final ApiService apiService = ApiService();


class PatientsScreen extends StatefulWidget {
  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> with SingleTickerProviderStateMixin {
Map<String, dynamic> patientData = {};
List<Map<String, dynamic>> myPatients = [];
List<Map<String, dynamic>> followingPatients = [];
String? _profileImageUrl=""; 
String token='';
String parsedDOB ='';
String parsedLS ='';
String parsedNS ='';

late TabController _tabController;
  String searchQuery = '';
  final List<String> _diagnosisOptions = [
    'Moderate ASD',
    'Mild ASD',
    'Severe ASD',
    'Nonverbal',
    'Speech Delay',
    'Sensory Issues',
    'ADHD & ASD',
  ];

    Future<void> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    try {
      final patientsdata = await superService.getPatients(token);
      setState(() {
            myPatients = (patientsdata)
      .map((item) => {
        "id": item['id'].toString(),
        "fname": item['firstName'].toString(),
        "lname": item['lastName'].toString(),
        "image": item['image'].toString(),
        "bio": item['bio'].toString(),
        "gender": item['gender'].toString(),
        "dob": item['dateOfBirth'].toString(),
        "country": item['country'].toString(),
        "city": item['city'].toString(),
        "age": item['age'].toString(),
        "diagnosis": item['diagnosis'].toString(),
        "lSession": item['lastSession'].toString(),
        "nSession": item['nextSession'].toString(),
        "status": item['status'].toString(),
        "sfrequency": item['sessionFrequency'].toString(),
        "notes": item['notes'].toString(),
        "username": item['userName'].toString(),
        "isExpanded":false
   
          })
      .toList();
});

    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load users: ${e.toString()}")),
);
    }
  }

  Future<void> loadFollowPatients() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    try {
      final patientsdata = await superService.getFollowPatients(token);
      setState(() {
            followingPatients = (patientsdata)
      .map((item) => {
        "id": item['id'].toString(),
        "fname": item['firstName'].toString(),
        "lname": item['lastName'].toString(),
        "image": item['image'].toString(),
        "bio": item['bio'].toString(),
        "gender": item['gender'].toString(),
        "dob": item['dateOfBirth'].toString(),
        "country": item['country'].toString(),
        "city": item['city'].toString(),
        "age": item['age'].toString(),
        "diagnosis": item['diagnosis'].toString(),
        "lSession": item['lastSession'].toString(),
        "nSession": item['nextSession'].toString(),
        "status": item['status'].toString(),
        "sfrequency": item['sessionFrequency'].toString(),
        "notes": item['notes'].toString(),
        "username": item['userName'].toString(),
        "isExpanded":false
   
          })
      .toList();
});

    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load users: ${e.toString()}")),
);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadPatients();
    loadFollowPatients();

  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    }
  }



  @override
  Widget build(BuildContext context) {
    final currentPatients = _tabController.index == 0 ? myPatients : followingPatients;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Patients',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xff333333),
            letterSpacing: 0.001,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF204E4C),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF204E4C),
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(child: Text("My Patients", style: TextStyle(fontSize: 16))),
            Tab(child: Text("Following", style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/total_patients.svg', height: 20, width: 20, color: const Color(0xFF666666)),
                const SizedBox(width: 8),
                Text(
                  '${currentPatients.length} Total Patients',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset('assets/images/fi_filter.svg', width: 16, height: 16),
                    onPressed: () => _showFilterBottomSheet(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset('assets/images/fi_search.svg', width: 16, height: 16),
                    onPressed: () {
                      // Search functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientList(myPatients),
                _buildPatientList(followingPatients),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF204E4C),
        shape: const CircleBorder(),
        onPressed: () async {
           await showDialog(
            context: context,
            barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
            builder: (context) => const AddPatientScreen(),
          );

        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsScreen()));
          }
          if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
          }

        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Bots'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
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
  Widget _buildPatientList(List<Map<String, dynamic>> patients) {
    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/no_patients.svg', height: 170),
            const SizedBox(height: 20),
            const Text("No Patients", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF999999))),
            const SizedBox(height: 5),
            Text(
              _tabController.index == 0
                  ? "Please click + to add new patients"
                  : "The patients you follow will appear here",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) => _buildPatientCard(patients[index]),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    Color statusTextColor;
    Color statusBgColor;
    _profileImageUrl ='https://autine-back.runasp.net/api/Files/image/${patient['image']}';
      parsedLS = apiService.formatDate(patient['lSession']);
      parsedNS = apiService.formatDate(patient['nSession']);

    switch (patient['status'].toLowerCase()) {
      case 'stable':
        statusTextColor = const Color(0xFF4CAF4F);
        statusBgColor = const Color(0xFFDBF0DC);
        break;
      case 'critical':
        statusTextColor = const Color(0xFFFF4B4B);
        statusBgColor = const Color(0xFFFFD9D9);
        break;
      case 'improving':
        statusTextColor = const Color(0xFFF3A056);
        statusBgColor = const Color(0xFFFCDCA4);
        break;
      default:
        statusTextColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
    }

    bool isExpanded = patient['isExpanded'] ?? false;

    return Slidable(
      key: ValueKey(patient['fname']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.30,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showEditPatientDialog(context, patient),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF204E4C),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
                      ),
                      child: const Center(child: Icon(Icons.edit_outlined, color: Colors.white)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){ 
                       final String userId = patient['id'];
                       print(userId);
                      _showDeleteConfirmationDialog(context, patient, userId);},
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4B4B),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
                      ),
                      child: const Center(child: Icon(Icons.delete, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
  radius: 32,
  backgroundColor: const Color(0xFF204E4C),
  child: ClipOval(
    child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
        ? Image.network(
            _profileImageUrl!,
            headers: {
              'Authorization': 'Bearer $token',
            },
            fit: BoxFit.cover,
            width: 64, // match diameter of avatar (radius * 2)
            height: 64,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  "${patient['fname'].isNotEmpty ? patient['fname'][0] : ''}${patient['lname'].isNotEmpty ? patient['lname'][0] : ''}",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    height: 1.4,
                    letterSpacing: 0.001,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "${patient['fname'].isNotEmpty ? patient['fname'][0] : ''}${patient['lname'].isNotEmpty ? patient['lname'][0] : ''}",
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 32,
                height: 1.4,
                letterSpacing: 0.001,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
  ),
),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Text(
                     "${patient['fname']} ${patient['lname']}",
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff333333))),
                      const SizedBox(height: 4),
                      Text(patient['diagnosis'] ?? 'Not specified',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff666666))),
                      const SizedBox(height: 4),
                      Text('${patient['age']} yrs',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff666666))),

                      if (isExpanded) ...[
                       
                        const SizedBox(height: 8),
                        _buildSessionInfo('Next Session', parsedNS),
                        const SizedBox(height: 4),
                        _buildSessionInfo('Last Session', parsedLS),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(32.5),
                  ),
                  child: Text(
                    patient['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),

            // زر View More/Less
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    patient['isExpanded'] = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? 'View Less ' : 'View More ',
                      style: const TextStyle(
                          color: Color(0xFF204E4C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF204E4C),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  void _showEditPatientDialog(BuildContext context, Map<String, dynamic> patient) {
   final String userId = patient['id'];
  _profileImageUrl ='https://autine-back.runasp.net/api/Files/image/${patient['image']}';
    parsedDOB = apiService.formatDate(patient['dob']);
    parsedLS = apiService.formatDate(patient['lSession']);
    parsedNS = apiService.formatDate(patient['nSession']);


    final TextEditingController firstNameController = TextEditingController(text: patient['fname']);
    final TextEditingController lastNameController = TextEditingController(text: patient['lname']);
    final TextEditingController usernNameController = TextEditingController(text: patient['username'] ?? '');
    String? gender = patient['gender'];
    final TextEditingController dateController = TextEditingController(text: parsedDOB);
    final TextEditingController diagnosisController = TextEditingController(text: patient['diagnosis']);
    String? status = patient['status'];
    final TextEditingController lastSessionController = TextEditingController(text: parsedLS);
    final TextEditingController nextSessionController = TextEditingController(text: parsedNS);
    String? sessionFrequency = _getSessionFrequency(patient) ?? patient['sfrequency'] ;

    int _currentTab = 0; // 0: Patient Info, 1: Care Info, 2: Session Plan

    void _showDatePicker(TextEditingController controller) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
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
        controller.text = DateFormat('yyyy/MM/dd').format(pickedDate);
        String bdate = dateController.text.trim();
        String ls = lastSessionController.text.trim();
        String ns =nextSessionController.text.trim();
        DateFormat inputFormat = DateFormat('yyyy/MM/dd');
        DateTime pickBDate = inputFormat.parse(bdate);
        DateTime pickls = inputFormat.parse(ls);
        DateTime pickns = inputFormat.parse(ns);
        DateTime utcBDate = DateTime.utc(
          pickBDate.year,
          pickBDate.month,
          pickBDate.day,
          0, 0, 0,
          );
          DateTime utcls = DateTime.utc(
          pickls.year,
          pickls.month,
          pickls.day,
          0, 0, 0,
          );
          DateTime utcns = DateTime.utc(
          pickns.year,
          pickns.month,
          pickns.day,
          0, 0, 0,
          );
        String rfcBDate = utcBDate.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        await saveData(rfcBDate, "dob");
        String rfcls = utcls.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        await saveData(rfcls, "lSession");
        String rfcns = utcns.toIso8601String().replaceFirst(RegExp(r'\.000'), '');
        await saveData(rfcns, "nSession");
      }
    }

    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).size.height * 0.07,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Edit Patient',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: ()async {
                              final prefs = await SharedPreferences.getInstance();
                              String token =prefs.getString("token").toString();
                              String dob =prefs.getString("dob") ?? patient['dob'];
                              String lSession =prefs.getString("lSession")?? patient['lSession'];
                              String nSession =prefs.getString("nSession")?? patient['nSession'];

                              final pData={
                                "firstName": firstNameController.text,
                                "lastName": lastNameController.text,
                                "bio": patient['bio'],
                                "gender": gender ?? patient['gender'],
                                "dateOfBirth": dob ,
                                "country": patient['country'],
                                "city": patient['city'],
                                "nextSession": nSession,
                                "lastSession": lSession,
                                "diagnosis": diagnosisController.text,
                                "status": status ?? patient['status'],
                                "notes": patient['notes'],
                                "sessionFrequency": sessionFrequency ?? patient['sfrequency']
                              };
                            await superService.editPatient(context, token, pData,userId);
                            Navigator.pop(context);
                            print(firstNameController.text);
                            print(lastNameController.text);
                            print( patient['bio']);
                            print(gender);
                            print(dob);
                            print(patient['country']);
                            print(patient['city']);
                            print(lSession);
                            print(nSession);
                            print(diagnosisController.text);
                            print(status);
                            print(patient['notes']);
                            print(sessionFrequency);


                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF204E4C),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEditTabButton('Patient Info', 0, _currentTab, setState),
                        _buildEditTabButton('Care Info', 1, _currentTab, setState),
                        _buildEditTabButton('Session Plan', 2, _currentTab, setState),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentTab == 0) ...[
                            // Patient Info Tab
                            GestureDetector(
                              onTap: () => _showImagePicker(context),
                              child: Row(
                                children: [
                                  CircleAvatar(
  radius: 32,
  backgroundColor: const Color(0xFF204E4C),
  child: ClipOval(
    child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
        ? Image.network(
            _profileImageUrl!,
            headers: {
              'Authorization': 'Bearer $token',
            },
            fit: BoxFit.cover,
            width: 64, // match diameter of avatar (radius * 2)
            height: 64,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  "${patient['fname'].isNotEmpty ? patient['fname'][0] : ''}${patient['lname'].isNotEmpty ? patient['lname'][0] : ''}",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    height: 1.4,
                    letterSpacing: 0.001,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "${patient['fname'].isNotEmpty ? patient['fname'][0] : ''}${patient['lname'].isNotEmpty ? patient['lname'][0] : ''}",
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 32,
                height: 1.4,
                letterSpacing: 0.001,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
  ),
),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Choose Picture',
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF204E4C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),

                            const Text(
                              'First Name',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            _buildTextField('First Name', firstNameController),
                            const SizedBox(height: 15),

                            const Text(
                              'Last Name',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            _buildTextField('Last Name', lastNameController),
                            const SizedBox(height: 15),

                            const Text(
                              'Username',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            _buildTextField('Email', usernNameController),
                            const SizedBox(height: 15),

                            const Text('Gender',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGenderButton('Female', gender == 'Female', () {
                                    setState(() => gender = 'Female');
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildGenderButton('Male', gender == 'Male', () {
                                    setState(() => gender = 'Male');
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            const Text('Date of Birth',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: dateController,
                              decoration: InputDecoration(
                                hintText: "yyyy/MM/dd",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today_outlined),
                                  onPressed: () => _showDatePicker(dateController),
                                ),

                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                            ),
                          ],

                          if (_currentTab == 1) ...[
                            const Text('Diagnosis',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: diagnosisController.text.isNotEmpty ? diagnosisController.text : null,
                              items: _diagnosisOptions
                                  .map((diagnosis) => DropdownMenuItem(
                                value: diagnosis,
                                child: Text(diagnosis),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  diagnosisController.text = value ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                            const Text(
                              'Status',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: status,
                              items: ['Stable', 'Critical', 'Improving']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setState(() => status = val),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                            ),
                          ],



                          if (_currentTab == 2) ...[
                            // Session Plan Tab
                            const Text(
                              'Last Session Date',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: lastSessionController,
                              decoration: InputDecoration(
                                hintText: "yyyy/MM/dd",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today_outlined),
                                  onPressed: () => _showDatePicker(lastSessionController),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _showDatePicker(lastSessionController),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Next Session Date',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nextSessionController,
                              decoration: InputDecoration(
                                hintText: "yyyy/MM/dd",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today_outlined),
                                  onPressed: () => _showDatePicker(nextSessionController),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _showDatePicker(nextSessionController),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Session Frequency',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: sessionFrequency,
                              items: [
                                'Once a week',
                                'Twice a week',
                                'Three times a week',
                                'Every two week',
                                'Once a month',
                              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => sessionFrequency = val),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: (){
                            if(_currentTab == 0){
                             Navigator.of(context).pop();

                            }else{
                            setState(() {
                              _currentTab--;
                           });}
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentTab++;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF204E4C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffFBFBFB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditTabButton(String title, int tabIndex, int currentTab, Function setState) {
    bool isSelected = currentTab == tabIndex;
    return TextButton(
      onPressed: () => setState(() {}),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF204E4C) : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: const Color(0xFF204E4C),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

  String? _getSessionFrequency(Map<String, dynamic> patient) {
    return "Once a week";
  }
  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
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
          borderSide: const BorderSide(color: Color(0xFF204E4C), width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> patient, String id) {
    final String userId = patient['id'];
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Vector.svg',
                        width: 40,
                        height: 40,
                      ),
                      SvgPicture.asset(
                        'assets/images/trash.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontSize: 14,
                          height: 1,
                        ),
                        children: [
                          const TextSpan(
                            text: "Are you sure you want to delete ",
                            style: TextStyle(
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          TextSpan(
                            text: "${patient['fname']}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text: "? This can not be undone",
                            style: TextStyle(
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),


                    Column(
                      children: [
                        // زر Delete
                        SizedBox(
                          width:100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4B4B),
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: ()async {
                              final prefs = await SharedPreferences.getInstance();
                              String token = prefs.getString('token') ?? '';
                              await apiService.deleteUser(context,token ,userId);
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                  color: Color(0xffFBFBFB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // زر Cancel
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showFilterBottomSheet(BuildContext context) {
    DateTime? lastSessionFrom;
    DateTime? lastSessionTo;
    DateTime? nextSessionFrom;
    DateTime? nextSessionTo;
    String? selectedDiagnosis;
    String? selectedStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 24),

                  // Last Session Filter
                  const Text(
                    'Last Session',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          context,
                          'From',
                          lastSessionFrom,
                              (date) => setState(() => lastSessionFrom = date),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          context,
                          'To',
                          lastSessionTo,
                              (date) => setState(() => lastSessionTo = date),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Next Session Filter
                  const Text(
                    'Next Session',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          context,
                          'From',
                          nextSessionFrom,
                              (date) => setState(() => nextSessionFrom = date),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          context,
                          'To',
                          nextSessionTo,
                              (date) => setState(() => nextSessionTo = date),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Diagnosis Filter
                  const Text(
                    'Diagnosis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDiagnosis,
                    items: _diagnosisOptions
                        .map((diagnosis) => DropdownMenuItem(
                      value: diagnosis,
                      child: Text(diagnosis),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedDiagnosis = value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                    ),
                  ),
                  const Divider(height: 24),

                  // Status Filter
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Stable', 'Critical', 'Improving']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedStatus = value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Apply and Reset Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Reset all filters
                            setState(() {
                              lastSessionFrom = null;
                              lastSessionTo = null;
                              nextSessionFrom = null;
                              nextSessionTo = null;
                              selectedDiagnosis = null;
                              selectedStatus = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Reset',
                          style: TextStyle(color: Color(0XFF666666)),),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply filters
                            _applyFilters(
                              lastSessionFrom,
                              lastSessionTo,
                              nextSessionFrom,
                              nextSessionTo,
                              selectedDiagnosis,
                              selectedStatus,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF204E4C),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField(
      BuildContext context,
      String label,
      DateTime? selectedDate,
      Function(DateTime) onDateSelected,
      ) {
    final controller = TextEditingController(
      text: selectedDate != null ? DateFormat('yyyy/MM/dd').format(selectedDate) : '',
    );

    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: "yyyy/MM/dd",
        hintStyle: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Color(0xFF204E4C),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: const Color(0xFF204E4C),
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF204E4C),
                  surface: Colors.white,
                ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF204E4C),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.text = DateFormat('yyyy/MM/dd').format(date);
          onDateSelected(date);
        }
      },
    );
  }

  void _applyFilters(
      DateTime? lastSessionFrom,
      DateTime? lastSessionTo,
      DateTime? nextSessionFrom,
      DateTime? nextSessionTo,
      String? diagnosis,
      String? status,
      ) {
    // Here you would implement your filtering logic
    // For example:
    setState(() {
      // Filter myPatients and followingPatients based on the selected filters
      // You'll need to parse the dates and compare them
    });
  }
}