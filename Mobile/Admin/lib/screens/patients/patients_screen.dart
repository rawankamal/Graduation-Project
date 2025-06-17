import 'package:admin/services/admin_services.dart';
import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../account_settings/account_screen.dart';
import '../bots_screen.dart';
import '../home_notifications/home_screen.dart';
import '../supervisors/supervisors_screen.dart';

final adminService adminservice = adminService();
var admin =adminService();
final ApiService apiService = ApiService();


class PatientsScreen extends StatefulWidget {
  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> with SingleTickerProviderStateMixin {
List<Map<String, dynamic>> users = [];
Map<String, dynamic> userData = {};
List<Map<String, dynamic>> patients = [];
String? _profileImageUrl=""; 
String token='';



  Future<void> loadUserData(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token") ?? "";

  try {
    final userdata = await admin.getUser(context, userId, token);
    setState(() {
      userData = {
        'id': userdata['id'].toString(),
        'gender': userdata['gender'].toString(),
        'bio': userdata['bio'].toString(),
        'username': userdata['userName'].toString(),
      };
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load user data: ${e.toString()}")),
    );
  } 
}


    Future<void> loadusers() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    try {
      final userData = await admin.getUsers(token);
      setState(() {
            users = (userData)
      .map((item) => {
        'id': item['id'].toString(),
        'fname': item['firstName'].toString(),
        'image': item['profilePic'].toString(),
        'lname' :item['lastName'].toString(),
        'role' :item['role'].toString(),
          })
      .toList();

      });
      setState(() {
      patients = users.where((user) => user['role'] == 'User').toList();
      
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
    loadusers();
  }
  
  String searchQuery = '';


  @override
  Widget build(BuildContext context) {
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
          ),
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
                  ' ${patients.length} Total Patients',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
                const Spacer(),
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
            child: _buildPatientList(patients),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 3) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => SupervisorsScreen()));
          }
          if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Bots'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Supervisors'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
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
            const Text("All patients will appear here",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
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
    final String userId = patient['id'];
    _profileImageUrl ='https://autine-back.runasp.net/api/Files/image/${patient['image']}';

    return Slidable(
      key: ValueKey(patient['fname']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: ()async{
                      await loadUserData(userId);
                     _showPatientDetailsDialog(context, patient, userData);
                    
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF204E4C),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
                      ),
                      child: const Center(child: Icon(Icons.remove_red_eye_outlined, color: Colors.white)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDeleteConfirmationDialog(context, patient),
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
                      Text( "${patient['fname']} ${patient['lname']}",
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff333333))),
                      const SizedBox(height: 10),
                      Text(patient['role'] ,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff666666))),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientDetailsDialog(BuildContext context, Map<String, dynamic> patient, Map<String, dynamic> userData) {
    final String userId = patient['id'];
    _profileImageUrl ='https://autine-back.runasp.net/api/Files/image/${patient['image']}';

    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: MediaQuery.of(context).size.height * 0.07,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            height: 1.2,
                            letterSpacing: 0.002,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 0),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
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
                              const SizedBox(height: 10),
                              Text(
                                "${patient['fname']} ${patient['lname']}",
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 0),
                        const SizedBox(height: 16),
                        _buildInfoRow('First Name', patient['fname'] ),
                        _buildInfoRow('Last Name', patient['lname']),
                        _buildInfoRow('Username', userData['username']),
                        _buildInfoRow('Gender', userData['gender']),
                        _buildInfoRow('Bio', userData['bio']),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                         onPressed: ()async {
                              final prefs = await SharedPreferences.getInstance();
                              setState(() {
                              token =prefs.getString("token").toString();
                              });
                              await apiService.deleteUser(context, token, userId);
                              Navigator.of(context).pop();
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4B4B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        );
      },
    );
  }



  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333), fontWeight: FontWeight.w600,height: 1,),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.w400,height: 1.5),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> patient) {
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
                        // Delete button
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
                              setState(() {
                              token =prefs.getString("token").toString();
                              });
                              await apiService.deleteUser(context, token, userId);
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

                        // Cancel button
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

}