import 'package:flutter/material.dart';
import 'package:test_sign_up/screens/account_settings/account_screen.dart';
import 'package:test_sign_up/screens/chat_screen.dart';
import 'package:test_sign_up/services/chat_services.dart';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ApiService apiService = ApiService();
final ChatService chatService = ChatService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fname = '';
  String? botId = '';
  String? botIcon = '';
  String? botName = '';
  String? lastMessage;
  DateTime? lastMessageTime;
  List<Map<String, dynamic>> myBots = [];
  List<Map<String, dynamic>> allBots = [];
  List<Map<String, dynamic>> botMessages = [];

  Future<void> loadFname() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token").toString();
    await apiService.getData(context, token);
    setState(() {
      fname = prefs.getString('fname') ?? '';
    });
  }

  Future<void> loadMyBots() async {
  final prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token") ?? "";

  try {
    final botData = await chatService.getMyBots(token);

    setState(() {
      myBots = (botData as List)
          .map((item) => {
                'id': item['id'].toString(),
                'name': item['name'].toString(),
                'icon':  'assets/images/bot4.png',
              })
          .toList();

      // Automatically populate messages list with these bots
      messages = myBots.map((bot) => {
            'name': bot['name'],
            'message': 'Tap to continue chatting!',
            'date': 'Now',
            'icon': bot['icon'],
            'botId': bot['id'],
            'botName': bot['name'],
            'botIcon': bot['icon'],
          }).toList();
    });
  } catch (e) {
    debugPrint('Error loading bots: $e');
    setState(() {
      myBots = [
        {'name': 'Luna', 'icon': 'bot2.png', 'id': 'luna-id'},
        {'name': 'Echo', 'icon': 'bot3.png', 'id': 'echo-id'},
        {'name': 'Pixie', 'icon': 'bot6.png', 'id': 'pixie-id'},
      ];

      messages = myBots.map((bot) => {
            'name': bot['name'],
            'message': 'Tap to continue chatting!',
            'date': 'Now',
            'icon': bot['icon'],
            'botId': bot['id'],
            'botName': bot['name'],
            'botIcon': bot['icon'],
          }).toList();
    });
  }
}

  Future<void> loadAllBots() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

   try {
      final botData = await chatService.getBots(token);
      final myBotIds = myBots.map((bot) => bot['id']).toSet();

      setState(() {
        allBots = (botData as List)
       .where((item) => !myBotIds.contains(item['id'].toString()))
      .map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
        'icon': 'assets/images/bot4.png',
          })
      .toList();
 
      });
      }
      catch (e) {
      debugPrint('Error loading bots: $e');
      setState(() {
        myBots = [
          {'name': 'Luna', 'icon': 'bot2.png', 'id': 'luna-id'},
          {'name': 'Echo', 'icon': 'bot3.png', 'id': 'echo-id'},
          {'name': 'Pixie', 'icon': 'bot6.png', 'id': 'pixie-id'},
        ];
      });
    }
  }

  List<Map<String, dynamic>> messages = [];

  void navigateToChat(Map<String, dynamic> bot) {
    final existingIndex = messages.indexWhere((msg) => msg['botId'] == bot['id']);
    if (existingIndex != -1) {
      // Update existing message
      setState(() {
        messages[existingIndex] = {
          'name': '${bot['name']}',
          'message': 'Tap to continue chatting!',
          'date': 'Now',
          'icon': 'assets/images/bot4.png',
          'botId': bot['id'],
          'botName': bot['name'],
          'botIcon': 'assets/images/bot4.png',
        };
      });
    } else {
      // Add new message
      setState(() {
        messages.insert(0, {
          'name': '${bot['name']}',
          'message': 'Tap to continue chatting!',
          'date': 'Now',
          'icon': 'assets/images/bot4.png',
          'botId': bot['id'],
          'botName': bot['name'],
          'botIcon': 'assets/images/bot4.png',
        });
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          botName: bot['name'],
          botIcon: bot['icon'] ?? 'assets/images/bot4.png',
          botId: bot['id'],
        ),
      ),
    ).then((_) {
    });
  }

  @override
  void initState() {
    super.initState();
    loadFname(); 
    loadAllBots();
    loadMyBots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 136,
                height: 56,
                child: Text(
                  "Good Morning,\n$fname",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.001,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF204E4C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Bots",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.001,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allBots.map((bot) {
                    return GestureDetector(
                      onTap: () => navigateToChat(bot),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52.63,
                              height: 51.37,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(31.58),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(31.58),
                                child: Image.asset(
                                  "${bot['icon']}",
                                  fit: BoxFit.fill, 
                                  width: 52.63,
                                  height: 51.37,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 70,
                              child: Text(
                                bot['name'],
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.001,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Messages",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.001,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            botName: messages[index]['botName'],
                            botIcon: messages[index]['botIcon'],
                            botId: messages[index]['botId'],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      leading: Container(
                        width: 52.63,
                        height: 51.37,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(31.58),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(31.58),
                          child: Image.asset(
                            "${messages[index]['icon']}",
                            fit: BoxFit.fill, 
                            width: 52.63,
                            height: 51.37,
                          ),
                        ),
                      ),
                      title: Text(
                        messages[index]['name'],
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.001,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        messages[index]['message'],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.001,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            messages[index]['date'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountScreen()),
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
}