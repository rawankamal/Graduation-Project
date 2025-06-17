import 'package:autine1/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../account_settings/account_screen.dart';
import '../bots_screen.dart';
import '../chats_screen.dart';
import '../patients_screen.dart';
import 'no_notification_screen.dart';
//import 'notifications_screen.dart';
import '../../services/api_services.dart';


final ApiService apiService = ApiService();
final SuperService superService = SuperService();


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 String fname = '';
 int botCount =0;
 int patientCount =0;
 List<dynamic> nearActivities = [];
 List<dynamic> farActivities = [];
 List<dynamic> mostUsedModels = [];
 bool isLoading = true;
 String? parse='';
 String? wparse='';



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
  String email = prefs.getString("loginemail") ?? "";

  final dashboardData = await superService.getDashboard(context,email);

  if (dashboardData.isNotEmpty) {
    setState(() {
      
    patientCount= dashboardData['count_user'];
    botCount = dashboardData['count_model'];
    nearActivities=(dashboardData['near_user_model'] as List)
    .map((item) => {
            'userName': item['user_name'].toString(),
            'Date': item['datetime'].toString(),
            'modelName': item['model_name'].toString(),

          })
      .toList();

    farActivities = (dashboardData['far_user_model'] as List)
    .map((item) => {
            'userName': item['user_name'].toString(),
            'Date': item['datetime'].toString(),
            'modelName': item['model_name'].toString(),

          })
      .toList();

     mostUsedModels = (dashboardData["most_model"] as List)
      .map((item) => {
            'name': item['model_name'].toString(),
            'messages': item['msg_count'].toString(),
          })
      .toList();

 print(patientCount);
 print(botCount);
 print("near $nearActivities");
 print("far $farActivities");
 print(mostUsedModels);

    });
   
  } else {
    print("Failed to fetch dashboard data.");
  }
}
 
  @override
  void initState() {
    super.initState();
    loadFname();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
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
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/notifications.svg',
                        width: 20,
                        height: 20,
                        color: const Color(0xFF333333),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSimpleStatCard(
                    title: 'Patients',
                    count: patientCount,
                    iconPath: 'assets/images/total_patients.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PatientsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleStatCard(
                    title: 'Bots',
                    count: botCount,
                    iconPath: 'assets/images/total bots.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BotsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('User Activity'),
            const SizedBox(height: 8),
            _buildUserActivityList(),
            const SizedBox(height: 24),
            _buildUserWarningSection(),
            const SizedBox(height: 24),
            _buildBotRankingSection(),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientsScreen()));
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

  Widget _buildSimpleStatCard({
    required String title,
    required int count,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconPath,
                height: 20,
                width: 20,
                color: title == 'Patients'
                    ? const Color(0xFF1D6F5A)
                    : const Color(0xFF0086A8),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF204E4C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/Vector (1).svg',
                          color: Colors.white,
                          width: 14,
                          height: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total $title',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    if (title == 'User Activity') {
      return Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE5FED8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/wpf_online.svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      );
    }
    else if (title == 'User Warning') {
      return Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF8E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/Vector (3).svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      );
    }
    else {
      return Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildUserActivityList() {
    final activities = nearActivities;

    return Column(
      children: activities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(Map<String, String> activity)  {
    parse = apiService.formatDate(activity['Date']!) ;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    activity['userName'] ??'',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                 "${activity['modelName']} Bot",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    letterSpacing: 0.001,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Text(
            parse ??'',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF808080),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserWarningSection() {
    final warnings = farActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Warning'),
        const SizedBox(height: 8),
        ...warnings.map((warning) => _buildWarningItem(warning)).toList(),
      ],
    );
  }


  Widget _buildWarningItem(Map<String, String> warning) {
    wparse = apiService.formatDate(warning['Date']!) ;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              warning['userName']??'',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Color(0xFF333333),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            wparse??'',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF808080),
            ),
          ),
          const SizedBox(width: 20),
          Text(
           "${warning['modelName']} Bot",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF808080),
            ),
          ),
        ],
      ),
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
                color: const Color(0xFFEBF1FF),
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
            const SizedBox(width: 8),
            const Text(
              'Bot Ranking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...bots.asMap().entries.map((entry) => _buildBotRankItem(entry.key + 1, entry.value)).toList(),
      ],
    );
  }

  Widget _buildBotRankItem(int rank, Map<String, String> bot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
          const SizedBox(width: 20),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/bots/bot4.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${bot['name']} Bot" ,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Text(
            '${bot['messages']} Message',
            style: const TextStyle(
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