class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final int status;
  final bool direction;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.direction,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      direction: json['direction'],
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String profilePic;
  final DateTime createAt;
  final List<ChatMessage> messages;

  ChatUser({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.createAt,
    required this.messages,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    var messagesList = (json['messages'] as List)
        .map((msg) => ChatMessage.fromJson(msg))
        .toList();

    return ChatUser(
      id: json['id'],
      name: json['name'],
      profilePic: json['profilePic'],
      createAt: DateTime.parse(json['createAt']),
      messages: messagesList,
    );
  }
}
