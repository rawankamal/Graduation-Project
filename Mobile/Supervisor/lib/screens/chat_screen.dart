import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autine1/services/chat_services.dart';

final ChatService chatService = ChatService();

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final String chatId;
  

  const ChatScreen({super.key, required this.chatId, required this.chatTitle});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String token='';
  List<ChatMessage> messages = [];
  late ChatUser currentUser;
  late ChatUser botUser;

  @override
  void initState() {
    super.initState();
    loadChatHistory();
    currentUser = ChatUser(id: "1", firstName: "You");
    botUser = ChatUser(id: widget.chatId, firstName: widget.chatTitle);
  }


Future<void> loadChatHistory() async {
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token") ?? '';

  try {
    final response = await http.get(
      Uri.parse('https://autine-back.runasp.net/api/BotUsers/${widget.chatId}/chat-bot'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Parse messages
      List<dynamic> rawMessages = data['messages'];
      List<ChatMessage> loadedMessages = rawMessages.map<ChatMessage>((msg) {
        return ChatMessage(
          user: msg['direction'] == true ? currentUser : botUser,
          text: msg['content'],
          createdAt: DateTime.parse(msg['timestamp']),
        );
      }).toList();

      setState(() {
        messages = loadedMessages;
      });
    } else {
      print('Failed to load messages: ${response.body}');
    }
  } catch (e) {
    print('Error fetching chat history: $e');
  }
}




  Future<void> sendMessage(ChatMessage message) async {

   if (message.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Message cannot be empty or whitespace"))
  );
  return;
}                                                                                                                                 

    final prefs = await SharedPreferences.getInstance();
    String token= prefs.getString('token').toString();
    setState(() {
      messages.add(message);
    });

    try { 
      final response = await http.post(
        Uri.parse('https://autine-back.runasp.net/api/BotUsers/${widget.chatId}/send-to-bot'), 
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'},
        body: jsonEncode({'Content': message.text}),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data['content'];

        setState(() {
          messages.add(ChatMessage(
            text: reply,
            user: botUser,
            createdAt: DateTime.now(),
          ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bot failed to respond. Please try again."))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
        title: Transform.translate(
          offset: const Offset(-25, 0),
          child: Row(
            children: [
              Text(
                widget.chatTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  height: 24.55 / 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
     body: DashChat(
        currentUser: currentUser,
        messages: messages.reversed.toList(), 
        onSend: (ChatMessage message) => sendMessage(message),
        messageOptions: MessageOptions(
          showOtherUsersAvatar: true,
          showOtherUsersName: false,
          currentUserContainerColor: const Color(0xFFDBE5B1),
          currentUserTextColor: const Color(0xFF333333),
          textColor: const Color(0xFF333333),
          containerColor: Colors.grey[200]!,
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            hintText: "Type Something",
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              letterSpacing: 0.001,
              height: 1.6,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
          sendButtonBuilder: (void Function() sendMessageCallback) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: sendMessageCallback,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D5C58),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 25),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}