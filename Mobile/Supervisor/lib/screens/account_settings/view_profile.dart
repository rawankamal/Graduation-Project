import 'package:autine1/screens/account_settings/change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {

  String _fname = '';
  String _lname = '';
  String _bdate = '';
  String _gender = '';
  String _bio = '';
  String _city = '';
  String _country = '';
  String token='';
  String? _profileImageUrl='';
  String parsed ='';


  
  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  // Load the profile Data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('ppic') ?? ''; 
      _fname = prefs.getString('fname') ?? '';
      _lname = prefs.getString('lname') ?? '';
      _bdate = prefs.getString('dob').toString();
      _gender = prefs.getString('gender').toString();
      _bio = prefs.getString('bio').toString();
      _city = prefs.getString('city').toString();
      _country = prefs.getString('country').toString();
      token = prefs.getString("token").toString();
      parsed = apiService.formatDate(_bdate);

    });
      

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfile(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: SvgPicture.asset(
                'assets/images/edit.svg',
                width: 20,
                height: 20,
                color: Color(0xFF204E4C),
              ),
              label: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  letterSpacing: .001,
                  color: Color(0xFF204E4C),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top - kToolbarHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF2F2F2),
                    ),
                    child:ClipOval(
                     child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                     ? Image.network(
                     _profileImageUrl!,
                     headers: {
                    'Authorization': 'Bearer $token',
                       },
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                    return Center(
                     child: Text(
                     "${_fname.isNotEmpty ? _fname[0] : ''}${_lname.isNotEmpty ? _lname[0] : ''}",
                    style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    height: 1.4,
                    letterSpacing: 0.001,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(
              "${_fname.isNotEmpty ? _fname[0] : ''}${_lname.isNotEmpty ? _lname[0] : ''}",
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 32,
                height: 1.4,
                letterSpacing: 0.001,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
  ),
                  ),

                  SizedBox(height: 16),
                  Text(
                    "$_fname $_lname",
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      letterSpacing: 0.001,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 10),

                  _buildReadOnlyField('Date of birth', parsed),
                  _buildReadOnlyField('Gender', _gender),
                  _buildReadOnlyField('Bio', _bio),
                  _buildReadOnlyField('Country', _country),
                  _buildReadOnlyField('City', _city),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFE6E6E6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFF666666),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}