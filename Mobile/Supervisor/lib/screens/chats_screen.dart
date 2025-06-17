import 'package:autine1/screens/GroupChatScreen.dart';
import 'package:autine1/screens/chat_screen.dart';
import 'package:autine1/screens/patients_screen.dart';
import 'package:autine1/services/chat_services.dart';
import 'package:autine1/services/supervisor_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_settings/account_screen.dart';
import 'bots_screen.dart';
import 'home_notifications/home_screen.dart';

final SuperService superService = SuperService();
final ChatService chatService= ChatService();

  List<Map<String , dynamic>> visibleChats = [];
  List<Map<String , dynamic>> visibleThreads = [];
  class Chat {
  final String name;
  final String message;



  Chat({
    required this.name,
    required this.message,

  });
}

class ChatsScreen extends StatefulWidget {
  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';

  List<Map<String , dynamic>> allChats = [];
  List<Map<String , dynamic>> allThreads = [];

List<Map<String , dynamic>> get chatSearchResults {
  return allChats.where((chat) =>
      chat['title'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
}

List<Map<String , dynamic>> get groupSearchResults {
  return allThreads.where((thread) =>
      thread['title'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
}

Future<void> loadThreads() async {
    final prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("userId") ?? "";
    String sessionId ='1';

    try {
      final threads = await chatService.getAllThreads(id,sessionId);
      if(threads != null){
       setState(() {
       allThreads = (threads['thread_chats'] as List)
      .map((item) => {
        'supervisor_username': item['supervisor_username'].toString(),
        'user_username': item['user_username'].toString(),
        'member_username': item['member_username'].toString(),
        'title' :item['title'].toString(),
          })
      .toList();
}); 
  for (var thread in allThreads){
 _buildChatTile(Chat( name: thread['title'], message: 'Tap to continue chatting!'),
  () { Navigator.push( context, MaterialPageRoute(builder: (_) => ChatScreen(chatTitle: thread['title'], chatId: thread['chatId']),
 ),
 );
},
);

}
      visibleChats = allChats;
      }
      else{print("No threats found!");}
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load threats: ${e.toString()}")),
);
    }
  }

Future<void> loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    try {
      final chats = await chatService.getAllChats(token);
      if(chats != null){
       setState(() {
       allChats = (chats as List)
      .map((item) => {
        'chatId': item['id'].toString(),
        'title': item['title'].toString(),
        'userId': item['userId'].toString(),
        'createdAt' :item['createdAt'].toString(),
          })
      .toList();
}); 
  for (var chat in allChats){
 _buildChatTile(Chat( name: chat['title'], message: 'Tap to continue chatting!'),
  () { Navigator.push( context, MaterialPageRoute(builder: (_) => ChatScreen(chatTitle: chat['title'], chatId: chat['chatId']),
 ),
 );
},
);

}
      visibleThreads = allThreads;
      }
      else{print("No threads found!");}
    } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Failed to load threads: ${e.toString()}")),
);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadChats();
    loadThreads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

   Widget _buildChatTile(Chat chat, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.name,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 1.4,
                          letterSpacing: 0.001,
                          color: Color(0xff333333)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(chat.message,
                      style: const TextStyle(
                          color: Color(0xff666666),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          letterSpacing: 0.001),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadTile(Chat chat, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.name,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 1.5,
                          color: Color(0xff333333)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(chat.message,
                      style: const TextStyle(
                          color: Color(0xff666666),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          letterSpacing: 0.001),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
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
        title: const Text('Chats', style: TextStyle(fontFamily: 'Nunito', fontSize: 28, height: 1.2, fontWeight: FontWeight.w600, color: Colors.black, letterSpacing: 0.001)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF204E4C),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF204E4C),
          tabs: const [
            Tab(child: Text("My Chats", style: TextStyle(fontSize: 16))),
            Tab(child: Text("My Threads", style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "search for any thing.....",
                hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14, height: 1.6),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // My Chats Tab
                searchQuery.isNotEmpty
                    ? ListView.builder(
                    itemCount: chatSearchResults.length,
                    itemBuilder: (context, index) {
                      final chat = chatSearchResults[index];
                      return _buildChatTile(
                        Chat( name: chat['title'], message: 'Tap to continue chatting!'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatTitle: chat['title'], chatId: chat['chatId']),
                            ),
                          );
                        },
                      );

                    })
                    : allChats.isEmpty
                    ? _emptyState("No Chats", "Please click + to add new chat")
                    : ListView.builder(
                    itemCount: allChats.length,
                    itemBuilder: (context, index) {
                      final chat = allChats[index];
                      return _buildChatTile(
                        Chat( name: chat['title'], message: 'Tap to continue chatting!'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatTitle: chat['title'], chatId: chat['chatId']),
                            ),
                          );
                        },
                      );
                    })
                // My Threads Tab
                ,searchQuery.isNotEmpty
                    ? ListView.builder(
                    itemCount: groupSearchResults.length,
                    itemBuilder: (context, index) {
                      final thread = groupSearchResults[index];
                      return _buildThreadTile(
                        Chat( name: thread['title'], message: 'Tap to continue chatting!'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => GroupChatScreen(groupName: thread['title'], superUsername:thread['supervisor_username'], userUsername:thread['user_username'], memUsername:thread['member_username'] ),

                            ),
                          );
                        },
                      );

                    })
                    : allThreads.isEmpty
                    ? _emptyState("No Threads", "Your threads will appear here")
                    : ListView.builder(
                    itemCount: allThreads.length,
                    itemBuilder: (context, index) {
                      final thread = allThreads[index];
                      return _buildThreadTile(
                        Chat( name: thread['title'], message: 'Tap to continue chatting!'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (_) => GroupChatScreen(groupName: thread['title'], superUsername:thread['supervisor_username'], userUsername:thread['user_username'], memUsername:thread['member_username'] ),


                            ),
                          );
                        },
                      );

                    })
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);
          }
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>PatientsScreen()),);
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  AccountScreen()));
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

  Widget _emptyState(String title, String subtitle) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          SvgPicture.asset('assets/images/no chats.svg', height: 170),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF999999))),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}


