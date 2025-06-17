import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


final SuperService superService = SuperService();


class SuperService {
   final String baseUrl = "https://grad-project-ai-api.vercel.app";



///////////////////////////////// Add Bot ////////////////////////////////////////////////////
Future<http.Response> addBot(BuildContext context, Map<String, dynamic> botData, String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Bots');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
     body: jsonEncode(botData),
  );
  print("Add bot: ${response.body} ${response.statusCode}");
  if(response.statusCode == 201){
     print("Bot added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Bot added successfully!')),
  );
  return response;

 }else{
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error adding bot: ${response.statusCode} !')),
    );
    return response;
 }
  
}




Future<List<dynamic>> getUsers(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Users/all-users');

  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(res.body);
  print(res.statusCode);

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as List<dynamic>;
  } else {
    throw Exception('Failed to load users. Status code: ${res.statusCode}');
  }
}

///////////////////////////////// Assign Bot ////////////////////////////////////////////////////
Future<http.Response> assignBot(BuildContext context, String botId, String token, String patientId) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Bots/$botId/assign-bot?patientId=$patientId');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print("Assign bot: ${response.body} ${response.statusCode}");
  if(response.statusCode == 204){
     print("Bot assigned successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Bot assigned successfully!')),
  );
  return response;

 }else{
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error assigning bot: ${response.statusCode} !')),
    );
    return response;
 }
  
}


///////////////////////////////// Assign Bot ////////////////////////////////////////////////////
Future<http.Response> removeAssign(BuildContext context, String botId, String token, String patientId) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Bots/$botId/remove-assign?patientId=$patientId');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print("Remove assigned bot: ${response.body} ${response.statusCode}");
  if(response.statusCode == 204){
     print("Removed assigned!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Removed assigned!')),
  );
  return response;

 }else{
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error  removing assigned bot: ${response.statusCode} !')),
    );
    return response;
 }
  
}

//////////////////////////////////// Get dashboard ///////////////////////////////////////////////////
Future<Map<String, dynamic>> getDashboard(BuildContext context,String email) async {
  final url = Uri.parse('$baseUrl/supervisor/get/dashboard?supervisor_email=$email');

  final res = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load dashboard. Status code: ${res.statusCode}');
  }
}

//////////////////////////////////// Get all users ///////////////////////////////////////////////////

Future<List<dynamic>> getPatients(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Patients/my-patient');

  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print(res.body);
  print(res.statusCode);

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as List<dynamic>;
  } else {
    throw Exception('Failed to load users. Status code: ${res.statusCode}');
  }
}

//////////////////////////////////// Get user data ///////////////////////////////////////////////////
Future<Map<String, dynamic>> getUser(BuildContext context, String userId, String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Users/$userId/get-user-by-id');

  final res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load user data. Status code: ${res.statusCode}');
  }
}


//////////////////////////////////// Get user data ///////////////////////////////////////////////////
Future<Map<String, dynamic>> getBot(BuildContext context, String botId, String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Bots/$botId');

  final res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>; 
  } else {
    throw Exception('Failed to load bot data. Status code: ${res.statusCode}');
  }
}

//////////////////////////////////// Get list of bots ///////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>?> getBots(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Bots/my-bots');

  var res = await http.get(
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
    return null;
  }
}

///////////////////////////// edit patient ///////////////////////////////////
///
Future<void> editPatient(BuildContext context,String token, Map<String, dynamic> userData, String userId) async {
  
    var response = await http.put(
      Uri.parse('https://autine-back.runasp.net/api/Patients/$userId'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',

    },
      body: jsonEncode(userData),
    );
      print("Edit patient: ${response.statusCode}");
 if (response.statusCode == 204) {
      print("Changes saved successfully!");

    } else {
      print("Unknown error (Status code: ${response.statusCode})");

    }
  }
 ///////////////////////////////// Get My Patients /////////////////////////////
 Future<List<Map<String, dynamic>>> getMyPatients(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Patients/my-patient');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load patients: ${response.statusCode}');
  }
}


 ///////////////////////////////// Get follow Patients /////////////////////////////
 Future<List<Map<String, dynamic>>> getFollowPatients(String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Patients/follow-patient');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load patients: ${response.statusCode}');
  }
}
 //////////////////////////////////// Add new Patient /////////////////////////////

Future<http.Response> addPatient(BuildContext context, Map<String, dynamic> patientData, String token) async {
  final url = Uri.parse('https://autine-back.runasp.net/api/Patients');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(patientData),
  );
  print("Add patient: ${response.statusCode} ${response.body}");
  if(response.statusCode == 201){
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Patient added successfully!')),
  );
  return response;

 }else{
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Error adding patient: ${response.statusCode} !')),
    );
    return response;
 }
  
}


}