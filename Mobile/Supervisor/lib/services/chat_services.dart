import 'dart:convert';
import 'package:autine1/services/GroupModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


final ChatService chatService= ChatService();

class ChatService {
final String baseUrl = "https://autine-back.runasp.net";





  Future<ThreadChatResponse> getChatHistory(String superusername, String userUsername, String memUsername, String sessionId) async {
    final url = Uri.parse('https://grad-project-ai-api.vercel.app/thread/supervisor/chat/get?supervisor_username=$superusername&user_username=$userUsername&member_username=$memUsername&session_id=$sessionId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); 
      return ThreadChatResponse.fromJson(data);         
    } else if (response.statusCode == 404) {
      throw Exception('Chat history not found');

    } else {
      throw Exception('Failed to load chat history');
    }
  }

//////////////////////////////////Send message to bot ////////////////////////////////////////

Future<http.Response> sendMessage(String superusername, String userusername,String memUsername, String sessionId , String msg) async {
  final url = Uri.parse('https://grad-project-ai-api.vercel.app/thread/supervisor/chat/send?supervisor_username=$superusername&user_username=$userusername&member_username=$memUsername&msg_text=$msg&session_id=$sessionId');
  
  return await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );
}


/////////////////////////////////////////Get all threads////////////////////////////////////

Future<Map<String, dynamic>>? getAllThreads( String userId, String sessionId) async {
  final url = Uri.parse('https://grad-project-ai-api.vercel.app/thread/supervisor/chat/gets?supervisor_username=$userId&session_id=1');

  var res = await http.get(
    url,
    headers: {
    },
  );
  print(res.body);
  print(res.statusCode);
  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load users. Status code: ${res.statusCode}');
  }
}


Future<Map<String, dynamic>>? getSupers() async {
  final url = Uri.parse('https://grad-project-ai-api.vercel.app/supervisor/gets');
  var res = await http.get(
    url,
    headers: {
    },
  );
  print(res.body);
  print(res.statusCode);
  if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load members. Status code: ${res.statusCode}');
  }
}


Future<Map<String, dynamic>>? getMembers( String userId, String sessionId, String threadId) async {
  final url = Uri.parse('https://grad-project-ai-api.vercel.app/thread/supervisor/member/gets?supervisor_username=$userId&user_username=$threadId&session_id=$sessionId');

  var res = await http.get(
    url,
    headers: {
    },
  );
  print(res.body);
  print(res.statusCode);
  if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load members. Status code: ${res.statusCode}');
  }
}


Future<Map<String, dynamic>> getThread(String token, String threadId) async {
  final url = Uri.parse('https://autine-back.runasp.net/ api/threads/$threadId');
  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(res.body);
  print(res.statusCode);

  if (res.statusCode == 200) {
     return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load thread data. Status code: ${res.statusCode}');
  }
}

Future<List<Map<String, dynamic>>?> getThreadM(String token, String threadId) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/threads/$threadId/thread-members');
  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(res.body);
  print(res.statusCode);
  if (res.statusCode == 200) {
    final List<dynamic> members = json.decode(res.body);

    List<Map<String, dynamic>> typedList = members
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return typedList ;
  } else {
    throw Exception('Failed to load members. Status code: ${res.statusCode}');
  }
  }

Future<http.Response> addMember(BuildContext context, String superusername, String userusername, String memUsername, String sessionId) async {
  final url = Uri.parse('https://grad-project-ai-api.vercel.app/thread/supervisor/member/add?supervisor_username=$superusername&user_username=$userusername&member_username=$memUsername&session_id=$sessionId');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },

  );
  print("Add Member: ${response.body} ${response.statusCode}");
  if(response.statusCode == 201){
     print("Member added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Member added successfully!')),
  );
  return response;

 }else{
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error adding member: ${response.statusCode} !')),
    );
    return response;
 }
  
}


Future<List<Map<String, dynamic>>?> getAllChats(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Chats/all-chat');

  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(res.body);
  print(res.statusCode);
  if (res.statusCode == 200) {
    final List<dynamic> chats = json.decode(res.body);

    List<Map<String, dynamic>> typedList = chats
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return typedList;
  } else {
    throw Exception('Failed to load users. Status code: ${res.statusCode}');
  }
}

}