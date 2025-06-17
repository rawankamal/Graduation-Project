import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'icon': 'assets/images/notifications.svg',
      'title': 'Liam Carter',
      'message': 'just interacted with Pixie Bot.',
      'time': 'Now',
    },
    {
      'icon': 'assets/images/notifications.svg',
      'title': 'Calm Bot',
      'message': 'handled 30+ messages today.',
      'time': '3h ago',
    },
    {
      'icon': 'assets/images/notifications.svg',
      'title': 'Oliver Hayes',
      'message': 'interacted with Lumia Bot for the first time.',
      'time': '2h ago',
    },
    {
      'icon': 'assets/images/notifications.svg',
      'title': 'Nova Bot',
      'message': 'is now the most used bot this week.',
      'time': '3h ago',
    },
    {
      'icon': 'assets/images/notifications.svg',
      'title': 'Ethan Sullivan',
      'message': 'interacted with Spark Bot for the first time.',
      'time': '2h ago',
    },
  ];

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
          'Notifications(${notifications.length})',
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
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                notification['icon'],
                color: Color(0xFF333333),
              ),
            ),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: notification['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontSize: 14,
                      height: 1
                    ),
                  ),
                  TextSpan(
                    text: ' ${notification['message']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                      fontSize: 14,
                      height: 1.2
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            notification['time'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1,
              color: Color(0xFF8C8C8C),
            ),
          ),
        ],
      ),
    );
  }
}
