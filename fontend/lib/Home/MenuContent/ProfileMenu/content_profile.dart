import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserData {
  final String email;
  final String username;
  final String tel;
  final String conditionName;
  final String gender;
  final int age;
  final double height;
  final double weight;

  UserData({
    required this.email,
    required this.username,
    required this.tel,
    required this.conditionName,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      email: json['email'],
      username: json['username'],
      tel: json['tel'],
      conditionName: json['condition_name'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'].toDouble(), // แปลงเป็น double ที่นี่
      weight: json['weight'].toDouble(), // แปลงเป็น double ที่นี่
    );
  }
}

class ContentProfile extends StatefulWidget {
  const ContentProfile({Key? key}) : super(key: key);

  @override
  _ContentProfileState createState() => _ContentProfileState();
}

class _ContentProfileState extends State<ContentProfile> {
  UserData? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');
    print('User email: $userEmail');

    if (userEmail != null) {
      String apiUrl = dotenv.get('API_URL_PROFILE_LOGIN');

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'email': userEmail,
          },
        );

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData is List && jsonData.isNotEmpty) {
            setState(() {
              userData = UserData.fromJson(jsonData[0]);
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          print(
              'Failed to load user data with status code: ${response.statusCode}');
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('User email is null');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg6.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUserInfo(
                                    'ชื่อผู้ใช้:', userData?.username),
                                _buildUserInfo('อีเมล:', userData?.email),
                                _buildUserInfo('เบอร์โทร:', userData?.tel),
                                _buildUserInfo(
                                    'โรคประจำตัว:', userData?.conditionName),
                                _buildUserInfo('เพศ:', userData?.gender),
                                _buildUserInfo(
                                    'อายุ:', userData?.age?.toString()),
                                _buildUserInfo(
                                    'ส่วนสูง:', userData?.height?.toString()),
                                _buildUserInfo(
                                    'น้ำหนัก:', userData?.weight?.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit profile screen
                        },
                        child: Text('แก้ไขโปรไฟล์'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();

                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        },
                        child: Text('ออกจากระบบ'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfo(String label, String? value) {
    return value != null && value.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label $value',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
            ],
          );
  }
}
