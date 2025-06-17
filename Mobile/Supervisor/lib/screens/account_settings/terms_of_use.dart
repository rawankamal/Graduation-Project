import 'package:flutter/material.dart';

class TermsOfUse extends StatefulWidget {
  @override
  _TermsOfUseState createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: -10,
        title: const Text(
          'Terms Of Use',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            letterSpacing: 0.001,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color:Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
