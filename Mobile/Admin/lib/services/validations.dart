
///////EMAIL//////////
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}
  //////PASSWORD//////////
String fault="";
bool isValidPass(String pass) {
  if (pass.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(pass) &&
      RegExp(r'[a-z]').hasMatch(pass) &&
      RegExp(r'\d').hasMatch(pass) &&
      RegExp(r'\W').hasMatch(pass)) {
    return true;
  }
  else if (pass.length < 8) {
    fault="length";
    return false;
    
  }
  else if (!RegExp(r'[A-Z]').hasMatch(pass)) {
     fault="upper";
     return false;
     
  }
  else if (!RegExp(r'[a-z]').hasMatch(pass)) {
      fault="lower";
     return false;
  }
 else if (!RegExp(r'\d').hasMatch(pass)) {
      fault="digit";
     return false;
  }
  else if (!RegExp(r'\W').hasMatch(pass)) {
      fault="special";
     return false;
  }else{
    fault="other";
    return false;
  }
}