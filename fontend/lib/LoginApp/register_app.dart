import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

class RegisterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _phoneNumberError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showCheckMark = false;

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phonenumber = _phoneNumberController.text.trim();

    print('Email: $email'); // Debugging
    print('Password: $password'); // Debugging
    print('PhoneNumber: $phonenumber'); // Debugging

    String url = dotenv.get('API_URL_REGIS');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'email': email,
          'password': password,
          'phone': phonenumber,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _showCheckMark = true; // แสดง Lottie เมื่อลงทะเบียนสำเร็จ
        });

        // Save user login status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);

        await Future.delayed(Duration(seconds: 3));

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/introcontent');
      } else if (response.statusCode == 400) {
        var data = response.body;
        print('Failed to register. Error: ${response.statusCode}'); // Debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ตรวจสอบ อีเมลหรือรหัสผ่าน'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('Failed to register. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อีเมลนี้ผู้ใช้งานแล้ว กรุณาเปลี่ยนอีเมล'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    String pattern =
        r'^(?:[+0]9)?[0-9]{10}$'; // Adjust pattern as per your requirements
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง';
    }
    return null;
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
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:<>?~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'รหัสผ่านต้องมี 8 ตัวขึ้นไป ประกอบด้วย ตัวพิมใหญ่ ตัวพิมเล็ก เลข และอักขระพิเศษ';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกยืนยันรหัสผ่าน';
    }
    if (value != _passwordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _showCheckMark
          ? Lottie.asset(
              'animations/correct.json', // ตัวอย่าง path ของ animation Lottie
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/bg6.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 80),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Image.asset(
                                  'images/logo5.png',
                                  height: 180,
                                ),
                              ),
                              SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10.0,
                                    sigmaY: 10.0,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'สร้างบัญชีผู้ใช้',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller:
                                              _phoneNumberController, // Change this to the appropriate controller for phone numbers
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            ),
                                            labelText: 'เบอร์โทรศัพท์',
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            hintText: '0801234567',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            errorText: _phoneNumberError,
                                            errorMaxLines: 2,
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          onChanged: (value) {
                                            setState(() {
                                              _phoneNumberError =
                                                  _validatePhoneNumber(value);
                                            });
                                          },
                                          validator: (value) {
                                            return _validatePhoneNumber(value!);
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.email,
                                              color: Colors.white,
                                            ),
                                            labelText: 'อีเมล',
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            hintText: 'user123@gmail.com',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            errorText: _emailError,
                                            errorMaxLines:
                                                2, // Set max lines for error text
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          onChanged: (value) {
                                            setState(() {
                                              _emailError =
                                                  _validateEmail(value);
                                            });
                                          },
                                          validator: (value) {
                                            return _validateEmail(value!);
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _passwordController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: Colors.white,
                                            ),
                                            labelText: 'รหัสผ่าน',
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            hintText: 'กรอกรหัสผ่าน',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            errorText: _passwordError,
                                            errorMaxLines:
                                                2, // Set max lines for error text
                                            suffixIcon: GestureDetector(
                                              onTapDown: (details) {
                                                setState(() {
                                                  _obscurePassword = false;
                                                });
                                              },
                                              onTapUp: (details) {
                                                setState(() {
                                                  _obscurePassword = true;
                                                });
                                              },
                                              child: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          obscureText: _obscurePassword,
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
                                        TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: Colors.white,
                                            ),
                                            labelText: 'ยืนยันรหัสผ่าน',
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            hintText: 'กรอกยืนยันรหัสผ่าน',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            errorText: _confirmPasswordError,
                                            errorMaxLines:
                                                2, // Set max lines for error text
                                            suffixIcon: GestureDetector(
                                              onTapDown: (details) {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      false;
                                                });
                                              },
                                              onTapUp: (details) {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      true;
                                                });
                                              },
                                              child: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          obscureText: _obscureConfirmPassword,
                                          onChanged: (value) {
                                            setState(() {
                                              _confirmPasswordError =
                                                  _validateConfirmPassword(
                                                      value);
                                            });
                                          },
                                          validator: (value) {
                                            return _validateConfirmPassword(
                                                value!);
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _register(); // เรียกใช้งานฟังก์ชันเมื่อกดปุ่มลงทะเบียน
                                            }
                                          },
                                          icon: Icon(
                                            Icons.person_add_alt_1,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'สร้างบัญชีผู้ใช้',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF1877F2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            minimumSize:
                                                Size(double.infinity, 50),
                                          ),
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
                                    SizedBox(height: 20),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      child: Text(
                                        'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(255, 87, 87, 87)
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 40.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 32,
                            ),
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
