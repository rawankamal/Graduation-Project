import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
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
          'Privacy Policy',
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
                'Autine values your privacy. This policy outlines how we collect, use, and protect your data:',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 24),
              _PolicyItem(
                title: 'Data Collection:',
                bulletPoints: [
                  'Basic personal data (e.g., name, user type) may be collected during registration.',
                  'Chat interaction data is stored for analysis and improvement of support.',
                ],
              ),
              _PolicyItem(
                title: 'Data Usage:',
                bulletPoints: [
                  'Chat data is analyzed to provide insights for therapists and caregivers.',
                  'No data is used for advertising or third-party sales.',
                ],
              ),
              _PolicyItem(
                title: 'Data Sharing:',
                bulletPoints: [
                  'Data is only shared with authorized supervisors and therapists.',
                  'We do not share data with any external third parties.',
                ],
              ),
              _PolicyItem(
                title: 'Data Security:',
                bulletPoints: [
                  'All stored data is protected using encryption and secure protocols.',
                  'Only authorized team members can access sensitive data.',
                ],
              ),
              _PolicyItem(
                title: 'User Consent:',
                bulletPoints: [
                  'By using Autine, you agree to the collection and analysis of data as described.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final String title;
  final List<String> bulletPoints;

  const _PolicyItem({required this.title, required this.bulletPoints});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: Color(0xFF204E4C),
            ),
          ),
          const SizedBox(height: 8),
          ...bulletPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ",
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF666666))),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
