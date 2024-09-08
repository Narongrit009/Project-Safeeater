import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // เพิ่มบรรทัดนี้

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  String? _emailError;
  String? _passwordError;

  bool _isPasswordVisible = false;

  // ฟังก์ชันสำหรับเรียก check_login.php
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _isLoading.value = true;
    });

    String url = dotenv.get('API_URL_CHECK_LOGIN');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
        },
      );

      setState(() {
        _isLoading.value = false;
      });

      if (response.statusCode == 200) {
        var data = response.body;
        print(data);

        // Save login status using shared_preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // เซ็ตค่า isLoggedIn เป็น true
        await prefs.setString('email', email); // Save the logged-in email

        // Show login animation for 3 seconds
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'animations/correct.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                    reverse: false,
                    animate: true,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'เข้าสู่ระบบเรียบร้อยแล้ว',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Text color for success
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ระบบได้เข้าสู่ระบบของคุณเรียบร้อยแล้ว',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

        // Delay for 3 seconds
        await Future.delayed(Duration(seconds: 3));
        // ตัวอย่างการบันทึก email ลงใน SharedPreferences หลังจาก login

        // Navigate to homepage automatically
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        var data = response.body;
        print('Failed to login. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาตรวจสอบ อีเมลหรือรหัสผ่าน อีกครั้ง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading.value = false;
      });

      print('Error connecting to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('โปรดตรวจสอบอินเตอร์เน็ตของคุณอีกครั้ง'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'กรุณากรอกอีเมลให้ถูกต้อง';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/bg1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Image.asset(
                          'images/logo5.png',
                          height: 150,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'SAFE EATER',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                                  Text(
                                    'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType
                                        .emailAddress, // เพิ่มบรรทัดนี้
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email,
                                          color: Colors.white),
                                      labelText: 'อีเมล',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: 'user123@gmail.com',
                                      hintStyle: TextStyle(color: Colors.white),
                                      fillColor: Colors.white.withOpacity(0.3),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      errorText: _emailError,
                                    ),
                                    style: TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      setState(() {
                                        _emailError = _validateEmail(value);
                                      });
                                    },
                                    validator: (value) {
                                      return _validateEmail(value!);
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.lock, color: Colors.white),
                                      labelText: 'รหัสผ่าน',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: 'กรอกรหัสผ่าน',
                                      hintStyle: TextStyle(color: Colors.white),
                                      fillColor: Colors.white.withOpacity(0.3),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      errorText: _passwordError,
                                      suffixIcon: GestureDetector(
                                        onLongPress: () {
                                          setState(() {
                                            _isPasswordVisible = true;
                                          });
                                        },
                                        onLongPressUp: () {
                                          setState(() {
                                            _isPasswordVisible = false;
                                          });
                                        },
                                        child: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(color: Colors.white),
                                    obscureText: !_isPasswordVisible,
                                    onChanged: (value) {
                                      setState(() {
                                        _passwordError =
                                            _validatePassword(value);
                                      });
                                    },
                                    validator: (value) {
                                      return _validatePassword(value!);
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  ValueListenableBuilder(
                                    valueListenable: _isLoading,
                                    builder: (context, isLoading, child) {
                                      return isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : ElevatedButton.icon(
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _login(); // เรียกใช้งานฟังก์ชันเมื่อกดปุ่ม
                                                }
                                              },
                                              icon: Icon(Icons.login,
                                                  color: Colors.white),
                                              label: Text(
                                                'เข้าสู่ระบบ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF1877F2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                minimumSize:
                                                    Size(double.infinity, 50),
                                              ),
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  // เพิ่มโค้ดเมื่อคลิกที่ลืมรหัสผ่าน
                                  Navigator.pushNamed(context, '/forgetpass');
                                },
                                child: Text(
                                  'ลืมรหัสผ่าน?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 87, 87, 87)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'ผู้ใช้ใหม่? สร้างบัญชีผู้ใช้',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(flex: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.home),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.lock),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.account_circle),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
