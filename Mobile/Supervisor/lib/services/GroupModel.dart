class GroupMessage {
  final String memberUsername;
  final String msgText;
  final DateTime datetime;

  GroupMessage({
    required this.memberUsername,
    required this.msgText,
    required this.datetime,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      memberUsername: json['member_username'],
      msgText: json['msg_text'],
      datetime: DateTime.parse(json['datetime']),
    );
  }
}

class ThreadChatResponse {
  final List<GroupMessage> threadChat;

  ThreadChatResponse({required this.threadChat});

  factory ThreadChatResponse.fromJson(Map<String, dynamic> json) {
    return ThreadChatResponse(
      threadChat: (json['thread_chat'] as List)
          .map((item) => GroupMessage.fromJson(item))
          .toList(),
    );
  }
}
