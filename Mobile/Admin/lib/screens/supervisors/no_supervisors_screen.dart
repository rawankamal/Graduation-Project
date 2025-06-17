import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../account_settings/account_screen.dart';
import '../bots_screen.dart';
import '../home_notifications/home_screen.dart';
import '../patients/patients_screen.dart';


class NoSupervisorsScreen extends StatefulWidget {
  @override
  _NoSupervisorsScreenState createState() => _NoSupervisorsScreenState();
}

class _NoSupervisorsScreenState extends State<NoSupervisorsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> Supervisors = [];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Supervisors',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: Color(0xff333333),
            letterSpacing: 0.001,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/total_patients.svg',
                  height: 20,
                  width: 20,
                  color: Color(0xFF666666),
                ),
                SizedBox(width: 8),
                Text(
                  '${Supervisors.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Total Supervisors',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    height: 1.6,
                  ),
                ),
                Spacer(),
                SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/fi_search.svg',
                      width: 16,
                      height: 16,
                    ),
                    onPressed: () {
                      // Search functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),
          Expanded(
            child: _buildSupervisorList(Supervisors),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF204E4C),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 13),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientsScreen()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BotsScreen()));
          }
          if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
          }

        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Bots'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Supervisors'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildSupervisorList(List<Map<String, dynamic>> supervisors) {
    if (supervisors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/no_patients.svg', height: 170),
            SizedBox(height: 20),
            Text("No Supervisors", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF999999))),
            SizedBox(height: 5),
            Text("All supervisors will appear here",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: supervisors.length,
      itemBuilder: (context, index) => _buildSupervisorCard(supervisors[index]),
    );
  }

  Widget _buildSupervisorCard(Map<String, dynamic> supervisor) {


    return Slidable(
      key: ValueKey(supervisor['name']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF204E4C),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(8), topLeft: Radius.circular(8)),
                      ),
                      child: Center(child: Icon(Icons.remove_red_eye_outlined, color: Colors.white)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDeleteConfirmationDialog(context, supervisor),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFF4B4B),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
                      ),
                      child: Center(child: Icon(Icons.delete, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(supervisor['image']), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 11),


              ],
            ),

            // زر View More/Less
          ],
        ),
      ),
    );
  }

}



void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> supervisor) {
  showDialog(
    context: context,
    barrierColor: Color(0xFF204E4C).withOpacity(0.5),
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Vector.svg',
                      width: 40,
                      height: 40,
                    ),
                    SvgPicture.asset(
                      'assets/images/trash.svg',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 14,
                        height: 1,
                      ),
                      children: [
                        TextSpan(
                          text: "Are you sure you want to delete ",
                          style: TextStyle(
                              fontWeight: FontWeight.w400
                          ),
                        ),
                        TextSpan(
                          text: "${supervisor['name']}",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: "? This can not be undone",
                          style: TextStyle(
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),


                  Column(
                    children: [
                      SizedBox(
                        width:100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4B4B),
                            padding: EdgeInsets.symmetric(vertical: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Color(0xffFBFBFB),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
