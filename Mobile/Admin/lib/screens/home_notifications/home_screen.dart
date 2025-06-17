import 'package:admin/screens/home_notifications/no_notification_screen.dart';
import 'package:admin/services/admin_services.dart';
import 'package:admin/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../account_settings/account_screen.dart';
import '../bots_screen.dart';
import '../patients/patients_screen.dart';
import '../supervisors/supervisors_screen.dart';

final ApiService apiService = ApiService();
final adminService adminservice = adminService();
var admin = adminService();


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 String fname = '';
 int botCount =0;
 int patientCount =0;
 int superCount =0;
 List<Map<String, String>> mostUsedModels = [];
 bool isLoading = true;


  Future<void> loadFname() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    await apiService.getData(context, token);
    setState(() {
      fname = prefs.getString('fname') ?? '';
    });
  }

void loadDashboard() async {
  final prefs = await SharedPreferences.getInstance();
  String adminEmail = prefs.getString("loginemail") ?? "";

  final dashboardData = await admin.getDashboard(context,adminEmail);

  if (dashboardData.isNotEmpty) {
    setState(() {
    patientCount= dashboardData['count_user'];
    botCount = dashboardData['count_model'];
    superCount = dashboardData['count_supervisor'];
     mostUsedModels = (dashboardData["most_model"] as List)
      .map((item) => {
            'name': item['model_name'].toString(),
            'messages': item['msg_count'].toString(),
          })
      .toList();

    });
   
  } else {
    print("Failed to fetch dashboard data.");
  }
}


  @override
  void initState() {
    super.initState();
    loadFname();
    //fetchData();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, $fname",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'welcome Back!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/notifications.svg',
                        width: 20,
                        height: 20,
                        color: Color(0xFF333333),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EmptyNotificationsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatBlock(
              title: 'Patients',
              count: patientCount,
              iconPath: 'assets/images/fi_users (3).svg',
              iconBackgroundColor: Color(0xFFE7F5F0),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PatientsScreen()));

              },
            ),
            _buildStatBlock(
              title: 'Bots',
              count: botCount,
              iconPath: 'assets/images/ri_robot-3-line (1).svg',
              iconBackgroundColor: Color(0xFFE5F4F9),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BotsScreen()));
              },
            ),
            _buildStatBlock(
              title: 'Supervisors',
              count: superCount,
              iconPath: 'assets/images/supervisors.svg',
              iconBackgroundColor: Color(0xFFE5FED8),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SupervisorsScreen()));

              },
            ),
            _buildBotRankingSection(),
          ],
        ),
      ),


      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        selectedLabelStyle: TextStyle(fontSize: 13),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientsScreen()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  SupervisorsScreen()));
          }
          if (index == 4) {
           Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
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

  Widget _buildStatBlock({
    required String title,
    required int count,
    required String iconPath,
    required Color iconBackgroundColor,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Total $title',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF204E4C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/Vector (1).svg',
                      width: 14,
                      height: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }



  Widget _buildBotRankingSection() {
  final bots = mostUsedModels;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFFEBF1FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/ranking.svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Bot Ranking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      ...bots.asMap().entries.map((entry) => _buildBotRankItem(entry.key + 1, entry.value)).toList(),
    ],
  );




  }

  Widget _buildBotRankItem(int rank, Map<String, String> bot) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Color(0xFF808080),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              bot['name']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Text(
            '${bot['messages']} Messages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF808080),
            ),
          ),
        ],
      ),
    );
  }




}