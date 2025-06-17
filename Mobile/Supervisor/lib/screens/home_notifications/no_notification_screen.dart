import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyNotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications(0)',
          style: TextStyle(
            fontFamily:'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: .001,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/Group 90.svg',
              width: 200,
              height: 176,
            ),
            SizedBox(height: 24),
            Text(
              'No new notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1,
                color: Color(0xFF999999),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'All notifications will show up here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  letterSpacing: .001,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}