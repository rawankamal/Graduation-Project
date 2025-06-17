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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'By using Autine, you agree to the following terms:',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 24),
              _TermItem(
                title: 'Purpose:',
                description:
                'Autine is designed to support individuals with Autism through structured and adaptive chatbot interactions.',
              ),
              _TermItem(
                title: 'Usage Responsibility:',
                description:
                'Users and caregivers must use the platform ethically and avoid any misuse that could cause harm or disruption.',
              ),
              _TermItem(
                title: 'Account Information:',
                description:
                'Users and supervisors are responsible for keeping their login credentials secure.',
              ),
              _TermItem(
                title: 'Modification of Service:',
                description:
                'The project team reserves the right to improve, modify, or discontinue features at any time.',
              ),
              _TermItem(
                title: 'Ownership:',
                description:
                'All content, models, and data in the application are owned by the Autine development team and may not be reused without permission.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String title;
  final String description;

  const _TermItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF666666),
          ),
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF204E4C)),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
}
