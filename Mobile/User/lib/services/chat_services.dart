import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_sign_up/services/ChatModel.dart';



class ChatService {
final String baseUrl = "https://autine-back.runasp.net";

//////////////////////////////////// Get list of bots ///////////////////////////////////////////////////

  Future<List<Map<String, dynamic>?>> getBots(String token) async {
  final url = Uri.parse('$baseUrl/api/BotUsers');

  var res=  await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print(res.body);
  print(res.statusCode);

  if (res.statusCode == 200) {
    final List<dynamic> botsList = json.decode(res.body);
    List<Map<String, dynamic>> typedList = botsList
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return typedList;
  } else {
    return [];
  }
}
  
/////////////////////////////////// Get list of user bots////////////////////////////////////
 
  Future<List<Map<String, dynamic>?>> getMyBots(String token) async {
  final url = Uri.parse('$baseUrl/api/BotUsers/my-bots');

  var res=  await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print(res.body);
  print(res.statusCode);

  if (res.statusCode == 200) {
    final List<dynamic> botsList = json.decode(res.body);
    List<Map<String, dynamic>> typedList = botsList
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return typedList;
  } else {
    return [];
  }

  }
  


///////////////////////////////////Get chat history ////////////////////////////////////////////

  Future<ChatUser> getChatHistory(String botId, String token) async {
    final url = Uri.parse('$baseUrl/api/BotUsers/$botId/chat-bot');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); 
      return ChatUser.fromJson(data);         
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please check your authentication');

    } else if (response.statusCode == 404) {
      throw Exception('Chat history not found for bot ID: $botId');

    } else {
      throw Exception('Failed to load chat history');
    }
  }

/////////////////////////////////////////Get last message////////////////////////////////////



//////////////////////////////////Send message to bot ////////////////////////////////////////

Future<http.Response> sendMessageToBot(String botId, String content, String token) async {
  final url = Uri.parse('$baseUrl/api/BotUsers/$botId/send-to-bot');
  
  return await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'content': content}),
  );
}


}