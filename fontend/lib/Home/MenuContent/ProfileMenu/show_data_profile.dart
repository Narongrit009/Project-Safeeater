import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

class ShowDataProfile extends StatefulWidget {
  final String email;

  const ShowDataProfile({Key? key, required this.email}) : super(key: key);

  @override
  _ShowDataProfileState createState() => _ShowDataProfileState();
}

class _ShowDataProfileState extends State<ShowDataProfile> {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData(widget.email);
  }

  Future<void> _fetchProfileData(String email) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_PROFILE_LOGIN'] ?? ''),
        body: jsonEncode(<String, String>{'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body)['data'];
          _isLoading = false;
        });
      } else {
        print('Failed to load profile data');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/bg7.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('images/boy.png'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'คุณ ${_profileData['username'] ?? ''}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _profileData['email'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        _buildProfileItem('เบอร์โทรศัพท์', _profileData['tel']),
                        _buildProfileItem('เพศ', _profileData['gender']),
                        _buildProfileItem(
                            'อายุ', _calculateAge(_profileData['birthday'])),
                        _buildProfileItem(
                            'ส่วนสูง', '${_profileData['height']} เซนติเมตร'),
                        _buildProfileItem(
                            'น้ำหนัก', '${_profileData['weight']} กิโลกรัม'),
                        _buildProfileItem(
                            'อาหารที่แพ้', _profileData['food_allergies']),
                        _buildProfileItem(
                            'โรคประจำตัว', _profileData['chronic_diseases']),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) {
      return 'ไม่มีข้อมูล';
    }
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return '$age ปี';
  }

  Widget _buildProfileItem(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'ไม่มีข้อมูล',
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
