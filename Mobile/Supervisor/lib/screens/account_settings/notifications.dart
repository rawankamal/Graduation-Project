import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: -10,
        title: Text(
          'Notifications',
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
          icon: Icon(Icons.arrow_back_ios,color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Switch
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Allow Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF333333),
                  ),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Color(0xFF204E4C);
                    }
                    return Color(0xFFCCCCCC);
                  }),
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
