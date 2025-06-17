import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'group_details_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final String superUsername;
  final String userUsername;
  final String memUsername;

  final VoidCallback? onTogglePin;

  GroupChatScreen({
    required this.groupName,
    required this.superUsername,
    required this.userUsername,
    required this.memUsername,

    this.onTogglePin,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<ChatMessage> messages = [];

  late ChatUser currentUser;

  List<ChatUser> participants = [];

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(
      id: widget.superUsername,
    );
    participants.add(currentUser);
    fetchGroupMessages();
  }

  void fetchGroupMessages() async {
  String sessionId = '1';

  try {
    final chatResponse = await chatService.getChatHistory(
      widget.superUsername,
      widget.userUsername,
      widget.memUsername,
      sessionId,
    );

    List<ChatMessage> loadedMessages = chatResponse.threadChat.map((groupMsg) {
      ChatUser sender = getOrCreateUser(groupMsg.memberUsername);

      return ChatMessage(
        user: sender,
        text: groupMsg.msgText,
        createdAt: groupMsg.datetime,
      );
    }).toList();

    setState(() {
      messages = loadedMessages.reversed.toList(); // Newest at bottom
    });
  } catch (e) {
    print("Error loading messages: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load messages')),
    );
  }
}
  ChatUser getOrCreateUser(String username) {
    final existingUser = participants.firstWhere(
      (user) => user.id == username,
      orElse: () {
        final newUser = ChatUser(
          id: username,
          firstName: username,
        );
        participants.add(newUser);
        return newUser;
      },
    );
    return existingUser;
  }

  void sendMessage(ChatMessage message) async{
     if (message.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Message cannot be empty or whitespace"))
  );
  return;
}      
    setState(() {
      messages.insert(0, message);
    });
    String sessionId='1';
    await chatService.sendMessage(widget.superUsername,widget.userUsername,widget.memUsername,sessionId, message.text,);
  }

  void _showClearChatConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF204E4C).withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      SvgPicture.asset('assets/images/Vector.svg', width: 40, height: 40),
                      SvgPicture.asset('assets/images/trash.svg', width: 20, height: 20),
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
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xff333333), fontSize: 14, height: 1),
                        children: [
                          TextSpan(
                            text: "Are you sure you want to delete this chat? This can not be undone",
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4B4B),
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                messages.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(
                                color: Color(0xffFBFBFB),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                              height: 1.5,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xffFBFBFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            color: const Color(0xffFBFBFB),
            constraints: const BoxConstraints(maxWidth: 130, maxHeight: 100),
            icon: SvgPicture.asset(
              'assets/images/fi_more-vertical.svg',
              width: 24,
              height: 24,
              color: const Color(0xFF333333),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'pin',
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Chat Pinned.svg',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF333333),
                    ),
                    const SizedBox(width: 12),
                    const Text('Pin Chat'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/trash.svg',
                      width: 20,
                      height: 20,
                      color: const Color(0xFFFF4B4B),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Clear Chat',
                      style: TextStyle(color: Color(0xFFFF4B4B)),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'clear') {
                _showClearChatConfirmation(context);
              } else if (value == 'pin') {
                widget.onTogglePin?.call();
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            offset: const Offset(0, 40),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ),
        title: Transform.translate(
          offset: const Offset(-25, 0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsScreen(
                    groupName: widget.groupName,
                    superUsername:widget.superUsername ,
                    userUsername:widget.userUsername,
                    memUsername:widget.memUsername
                  
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: DashChat(
        currentUser: currentUser,
        messages: messages,
        onSend: sendMessage,
        messageOptions: const MessageOptions(
          showOtherUsersAvatar: true,
          showOtherUsersName: false,
          currentUserContainerColor: Color(0xFFDBE5B1),
          currentUserTextColor: Color(0xFF333333),
          textColor: Color(0xFF333333),
          containerColor: Color(0xFFF0F0F0),
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            hintText: "Type something...",
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              letterSpacing: 0.001,
              height: 1.6,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          sendButtonBuilder: (sendCallback) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: sendCallback,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D5C58),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}