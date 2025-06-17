import 'package:flutter/material.dart';
import 'package:test_sign_up/screens/home_screen.dart';
import 'package:test_sign_up/screens/profile_screen.dart';
import '../welcome_screen.dart';
import 'change_password.dart';
import 'delete_account.dart';
import 'notifications.dart';
import 'privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'terms_of_use.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
 String _fname = '';
 String _lname = '';
 String loginEmail = '';
String registerEmail = '';
 String? _profileImageUrl=""; 
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
      _fname = prefs.getString('fname') ?? '';
      _lname = prefs.getString('lname') ?? '';
      loginEmail = prefs.getString('loginemail') ?? '';
      registerEmail = prefs.getString('email') ?? '';
      _profileImageUrl = prefs.getString('ppic') ?? ''; 
      token = prefs.getString('token') ?? '';

 
    });
      

  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFFFBFBFB),
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
                    SizedBox(height: 30),
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
                    SizedBox(height: 24),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4B4B),
                          padding: EdgeInsets.symmetric(vertical: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async{
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                          );
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("See you soon then!")),
                            );
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFFBFBFB),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
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
                  icon: Icon(Icons.close, color: Colors.grey),
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
        title: Text(
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
              _buildMenuItem(context, 'Notifications', Icons.notifications_outlined, color: Color(0xFF333333)),
              _buildMenuItem(context,'Change Password', Icons.lock_outline, color: Color(0xFF333333)),
              _buildMenuItem(context,'Terms Of Use', Icons.description_outlined,color: Color(0xFF333333)),
              _buildMenuItem(context,'Privacy Policy', Icons.privacy_tip_outlined,color: Color(0xFF333333)),
              _buildMenuItem(
                context,
                'Logout',
                Icons.logout,
                color: Color(0xFF333333),
                onTap: () => _showLogoutDialog(context),
              ),
              _buildMenuItem(context,'Delete Account', Icons.person_remove_outlined, color: Color(0xFFFF4B4B)),
            ],
          ),
        ),
      ),
       bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: const Color(0xFF204E4C),
        selectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return  InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
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
                  "${_fname.isNotEmpty ? _fname[0] : ''}${_lname.isNotEmpty ? _lname[0] : ''}",
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
              "${_fname.isNotEmpty ? _fname[0] : ''}${_lname.isNotEmpty ? _lname[0] : ''}",
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

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                      "$_fname $_lname",
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 4),
                Text(loginEmail != '' && loginEmail.isNotEmpty ? loginEmail : registerEmail,
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
      trailing: Icon(Icons.chevron_right, color: Color(0xFF666666)),
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
            MaterialPageRoute(builder: (context) => ChangePassword()),
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
            MaterialPageRoute(builder: (context) => DeleteAccount()),
          );
        }
      },
    );
  }
}