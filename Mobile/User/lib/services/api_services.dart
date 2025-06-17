import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_sign_up/screens/congratulations_screen.dart';
import 'package:test_sign_up/screens/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';

final ApiService apiService = ApiService();
class ApiService {
   final String baseUrl = "https://autine-back.runasp.net";


//////////////////////////Primary Register ///////////////////////////////////////////////////////////////

Future<dynamic> primRegister(BuildContext context,String email,String pass) async {

  var response = await http.post(
    Uri.parse('$baseUrl/auths/register'),
    headers: {'Content-Type': 'application/json'},
    body:jsonEncode({ 
  "firstName": "test",
  "lastName": "test",
  "email": email,
  "userName": generateUname(email),
  "password":pass ,
  "gender":"Male",
  "bio": "Hi there! I'm using Autine",
  "country": "Egypt",
  "city": "Cairo",
  "ProfilePic":"",
  "dateOfBirth": "2025-04-26T00:00:00Z",
    }),
  );
  print(response.body);
  if (response.statusCode == 200) {
    final data = await jsonDecode(response.body);
    String? userId = data["userId"];
    String? vCode = data["code"];
    await saveData(userId.toString(), "userId");
    await saveData(vCode.toString(), "code");
    if (userId == null || vCode == null) {
      print("Error: Missing userId or verificationCode in response");
      return response;
         }
        
    Navigator.pushNamed(context, '/verify_email');
    await confirmEmail(context,vCode.toString(), userId.toString());

  } else {
    handleError(context,response.statusCode);
  }
}



//////////////////////////Confirm Email ///////////////////////////////////////////////////////////////


Future<void> confirmEmail(BuildContext context ,String code, String userId) async {
  
  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email').toString();
  String pass = prefs.getString('password').toString();

  if (userId.isEmpty || code.isEmpty) {
    print("code or userId was not found.");
    return;
  }

  final response = await http.post(
        Uri.parse('$baseUrl/auths/confirm-email'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "userId": userId,
      "code": code,
    }),
  );


  if (response.statusCode == 200) {
      print("Email confirmed successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Email confirmed successfully.')),
  );

      print("Attempting login with email: $email and pass: $pass");
      await Future.delayed(Duration(seconds: 3));
      await getToken(context, email, pass);
      Navigator.pushNamed(context, '/verifying_email');

    } else if (response.statusCode == 400) {
      print(" Missing required fields");
         ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Missing required fields')),
  );
    } else if (response.statusCode == 401) {
      print(" Invalid confirmation code");
         ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text(' Invalid confirmation code')),
  );
    } else {
      print("Unknown error (Status code: ${response.statusCode})");
         ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: ${response.statusCode})')),
  );
    }
  }





////////////////////////////////// Complete Register ///////////////////////////////////////////////////////////////

Future<void> register(BuildContext context,String token, Map<String, dynamic> userData) async {
  
    var response = await http.put(
      Uri.parse('$baseUrl/api/profiles'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',

    },
      body: jsonEncode(userData),
    );
    print(response.body);
 if (response.statusCode == 204) {
      print("Registration success");
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Registration success')),
  );
    Navigator.push(context,MaterialPageRoute(builder: (context) => const CongratulationsScreen()),
                    );

    } else {
      print("Unknown error (Status code: ${response.statusCode})");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: ${response.statusCode})')),
  );

    }
  }



  //////////////////////////////////Update picture ////////////////////////////////////////////

  
 Future<void> updatepic(BuildContext context, File pic) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print("Unauthorized");
    return;
  }
  
  final fileExtension = pic.path.split('.').last.toLowerCase();
  String mimeType;
  switch (fileExtension) {
    case 'jpg':
    case 'jpeg':
      mimeType = 'image/jpeg';
      break;
    case 'png':
      mimeType = 'image/png';
      break;
    case 'gif':
      mimeType = 'image/gif';
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid image format!')),
      );
      return;
  }

  var uri = Uri.parse('$baseUrl/api/profiles/change-profile-picture');
  var request = http.MultipartRequest('PUT', uri);
  request.headers['Authorization'] = 'Bearer $token';

  var multipartFile = await http.MultipartFile.fromPath(
    'Image',
    pic.path ,
    contentType: MediaType.parse(mimeType),
  );

  request.files.add(multipartFile);
  var streamedResponse = await request.send();

  if (streamedResponse.statusCode == 204) {
    print("Image saved successfully!");
  } else {
    var response = await http.Response.fromStream(streamedResponse);
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {'title': 'Failed to upload profile picture'};
    print(data);
  }
}


/////////////////////////////////// Uodarte user data ///////////////////////////////////////////////////////
  Future<void> updatedata(BuildContext context,String token, Map<String, dynamic> userData) async {
  
    var response = await http.put(
      Uri.parse('$baseUrl/api/profiles'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',

    },
      body: jsonEncode(userData),
    );
    print(response.body);
 if (response.statusCode == 204) {
      print("Changes saved successfully!");

    } else {
      print("Unknown error (Status code: ${response.statusCode})");

    }
  }
 ////////////////////////////////// Get user data //////////////////////////////////////////////////////////////

Future<void> getData(BuildContext context,String token) async {
  
    var response = await http.get(
      Uri.parse('$baseUrl/api/profiles'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    },
      
    );
    print(response.body);
 if (response.statusCode == 200) {
       final data = await jsonDecode(response.body);
       String? fname = data["firstName"];
       String? lname = data["lastName"];
       String? bdate = data['dateOfBirth'];
       String? gender = data["gender"];
       String? city = data["city"];
       String? country = data["country"];
       String? bio = data["bio"];
       String? profilePic = data["imageUrl"];
       

       await saveData(fname.toString(), "fname");
       await saveData(lname.toString(), "lname");
       await saveData(bio.toString(), "bio");
       await saveData(country.toString(), "country");
       await saveData(city.toString(), "city");
       await saveData(gender.toString(), "gender");
       await saveData(bdate.toString(), "dob");
       await saveData(profilePic.toString(), "ppic");

    } else {
      print("Unknown error (Status code: ${response.statusCode})");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error loading your data!')),
  );

    }
  }

//////////////////////////////////Edit date format/////////////////////////////////////////
///
String formatDate(String rfc3339Date) {
  try {
    DateTime parsedDate = DateTime.parse(rfc3339Date).toLocal(); 
    return DateFormat('yyyy/MM/dd').format(parsedDate);
  } catch (e) {
    return ''; // or handle error gracefully
  }
}



///////////////////////////////////Generating username/////////////////////////////////////////////////

String generateUname(String email) {
  if (email.contains("@")) {
    return email.split("@")[0];  
  } 
  return email; 
}

////////////////////////// get token //////////////////////////////////////////////////////////

Future<bool> getToken(BuildContext context,String email , String pass) async {

    var response = await http.post(
      Uri.parse('$baseUrl/auths/get-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": pass}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      print("Authorized.");
      final data = await jsonDecode(response.body);
      String? token = data["accessToken"];
      if (token == null) {
        print("Error: Missing token in response");
      }
      await saveData(token.toString(), "token");
      return true;
    } else if (response.statusCode == 401) {
      print("Invalid email or password");
          ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email or password')),
  );
      return false;
    } else {
      print("Unknown error (Status code: ${response.statusCode})");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: ${response.statusCode})')),
  );
      return false;
    }
  }


  //////////////////////////////////login ///////////////////////////////////////////////////////////////

 
  Future<bool> login(BuildContext context,String email , String password) async {

    if (email.isEmpty || password.isEmpty) {
      print("Email And password are required");
        ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Email And password are required')),
  );
      return false;
    }

    var response = await http.post(
      Uri.parse('$baseUrl/auths/get-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      print("Login success");
      final data = await jsonDecode(response.body);
      String? token = data["accessToken"];
      await saveData(token.toString(), "token");
      if (token == null) {
        print("Error: Missing token in response");
          }
      Navigator.pushNamed(context, '/signing_in');
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Login success, Welcome Back!')),
  );
      return true;
    } else if (response.statusCode == 400) {
      print(" Missing required fields");
          ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Missing required fields')),
  );
      return false;
    } else if (response.statusCode == 401) {
      print("Invalid email or password");
          ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email or password')),
  );
      return false;
    } else {
      print("Unknown error (Status code: ${response.statusCode})");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: ${response.statusCode})')),
  );
      return false;
    }
  }


  //////////////////////////////////Reconfirm Email ///////////////////////////////////////////////////////////////

  Future<void> reconfirmEmail(BuildContext context,String email) async {
    var response = await http.post(
      Uri.parse('$baseUrl/auths/reconfirm-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );


    if (response.statusCode == 200) {
      print("Verification email resent.");
        ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Verification email resent.')),
  );
    } else if (response.statusCode == 400) {
      print("Invalid email format");
       ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email format')),
  );
    } else if (response.statusCode == 409) {
      print("Email already verified");

    } else {
      print("Unknown error (Status code: ${response.statusCode})");
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: ${response.statusCode})')),
  );
    }
  }




//////////////////////////Handle Errors ///////////////////////////////////////////////////////////////

  void handleError(BuildContext context, int statusCode) {
    if (statusCode == 400) {
      print(" Missing required fields");
       ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Missing required fields')),
  );

    } else if (statusCode == 401) {
      print("Invalid email or password");
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email or password')),
  );


    } else if (statusCode == 409) {
      print("This email already exists, select another one!");
          ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This email already exists, select another one!')),
  );

    } else {
      print("Unknown error (Status code: $statusCode)");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unknown error (Status code: $statusCode)')),
  );

    }
  }




 ///////////////////////////////////////////// Forgot Password ////////////////////////////////////////////////
 

  Future<void> forgotPassword(BuildContext context,String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auths/forgot-password"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final data = await jsonDecode(response.body);
    print(response.body);

     if (response.statusCode == 200) {
      String? userId = data["userId"];
      String? Code = data["code"];
      await saveData(userId.toString(), "userId");
      await saveData(Code.toString(), "code");
      if (userId == null || Code == null) {
        print("Error: Missing userId or Code in response");
           }
        
      print("Reset email sent successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Reset email sent successfully!')),
  );
      Navigator.pushNamed(context, '/change_password'); 

    } else {
      print("Bad request: Error title is ${data["title"]}");
          ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Bad request: Error title is ${data["title"]}")),
  );

    }
  }


  ////////////////////////////// Reset Password/////////////////////////////////////////////////////////////////////
  
  Future<void> resetPassword(BuildContext context,String newPassword, String userId, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reset-password"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userId': userId, 'code': code , 'password': newPassword}),
    );
     if (response.statusCode == 404) {  
     print("Something went wrong: Not Found Error 404");
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Something went wrong: Not Found Error 404')),
  );
    } else if (response.statusCode == 400) {
      print("Bad request: Missing required fields");
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Bad request: Missing required fields')),
  );
    } else {
       print("Password changed successfully, Try logging in now!");
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Password changed successfully, Try logging in now!')),
  );

    }
  }

/////////////////////////////////////// change password //////////////////////////////////////////

  Future<void> changePass(BuildContext context,String token,String oldPass, String newPass) async {
  
    var response = await http.put(
      Uri.parse('$baseUrl/api/profiles/change-password'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',

    },
      body: jsonEncode({
        "currentPassword": oldPass,
        "newPassword": newPass,
      }),
    );
    print(response.body);
    if (response.statusCode == 204) {
      print("Password saved successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('New password saved successfully!')),
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error changing your password!')),
      );
    }
  }



////////////////////////////////////////Delete your account//////////////////////////////

 Future<void> deleteAccout(BuildContext context,String token) async {
  
    var response = await http.delete(
      Uri.parse('$baseUrl/api/profiles'),
        headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    },
    );
    print(response.body);
 if (response.statusCode == 204) {
      print("Accounted deleted!");
       Navigator.push(context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account deleted successfully, sorry to see you go!")),
     );

    } else {
      print("Unknown error (Status code: ${response.statusCode})");
       ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error deleting your account!")),
     );

    }
  }




}

//////////////////////////////////// Check inbox //////////////////////////////////////
 Future<void> inbox() async {
    Uri? emailUri;

        if (Platform.isAndroid) {
      // Try to open Gmail first
      emailUri = Uri.parse("googlegmail://inbox");
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return;
      }

      // Try to open Outlook
      emailUri = Uri.parse("ms-outlook://");
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return;
      }

      // Try to open Yahoo Mail
      emailUri = Uri.parse("yahoo://mail");
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return;
      }
    }

    // Fallback: Open the web Gmail inbox
    final Uri webGmailUri = Uri.parse("https://mail.google.com/mail/u/0/#inbox");
    if (await canLaunchUrl(webGmailUri)) {
      await launchUrl(webGmailUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open your email inbox';
    }
  
  }
/////////////////////////////////////Saving Data///////////////////////////////////

Future<void> saveData(String data, String saveAs) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(saveAs , data);
}
 

 