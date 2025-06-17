import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bots_screen.dart';
import '../home_notifications/home_screen.dart';
import '../patients/no_patients_screen.dart';
import '../supervisors/supervisors_screen.dart';
import '../welcome_screen.dart';
import 'add_admin.dart';
import 'change_password.dart';
import 'delete_account.dart';
import 'notifications.dart';
import 'privacy_policy.dart';
import 'terms_of_use.dart';
import 'view_profile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}


class _AccountScreenState extends State<AccountScreen> {
   String fname = '';
   String lname = '';
   String loginEmail = '';
   String token='';

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  // Load the profile Data from SharedPreferences
  Future<void> _loadProfileData() async {

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      loginEmail = prefs.getString('loginemail') ?? '';
      token = prefs.getString('token') ?? '';

 
    });
      

  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFFBFBFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xff333333), fontSize: 14, height: 1),
                        children: [
                          TextSpan(
                            text: "Are you sure you want to logout?",
                            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,height: 1,color: Color(0xFF333333)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4B4B),
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async{
                               Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          );
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          await prefs.remove("loginpassword");
                          ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("See you soon then!")),
                            );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFFBFBFB),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Account',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            letterSpacing: 0.001,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Settings'),
              _buildMenuItem(context, 'Notifications', Icons.notifications_outlined, color: const Color(0xFF333333)),
              _buildMenuItem(context,'Change Password', Icons.lock_outline, color: const Color(0xFF333333)),
              _buildMenuItem(context,'Add New Admin', Icons.person_add_alt_outlined, color: const Color(0xFF333333)),
              _buildMenuItem(context,'Terms Of Use', Icons.description_outlined,color: const Color(0xFF333333)),
              _buildMenuItem(context,'Privacy Policy', Icons.privacy_tip_outlined,color: const Color(0xFF333333)),
              _buildMenuItem(context, 'Logout', Icons.logout, color: const Color(0xFF333333),
                onTap: () => _showLogoutDialog(context),),
              _buildMenuItem(context,'Delete Account', Icons.person_remove_outlined, color: const Color(0xFFFF4B4B)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NoPatientsScreen()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  SupervisorsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Bots'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Supervisors',),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return  InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewProfile()),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFF2F2F2),
            child: ClipOval(
              child:  Center(
                child: Text(
                  "${fname.isNotEmpty ? fname[0] : ''}${lname.isNotEmpty ? lname[0] : ''}",
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
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$fname $lname",
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF666666)),
                  ],
                ),
                const SizedBox(height: 4),
                 Text(
                  loginEmail ,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {Color color = const Color(0xFF333333), VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF666666)),
      onTap: onTap ?? () {
        if (title == 'Notifications') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
        }
        if (title == 'Change Password') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePassword()),
          );
        }
        if (title =='Add New Admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAdmin()),
          );
        }
        if (title == 'Terms Of Use') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TermsOfUse()),
          );
        }
        if (title == 'Privacy Policy') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacyPolicy()),
          );
        }
        if (title == 'Delete Account') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeleteAccount()),
          );
        }
      },
    );
  }
}