import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui'; // Add this import
import 'dart:convert';
import 'package:lottie/lottie.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  ResetPasswordScreen({
    required this.phoneNumber,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  bool _isPasswordVisible = false; // ใช้ควบคุมการแสดง/ซ่อนรหัสผ่าน
  bool _isConfirmPasswordVisible = false; // ใช้ควบคุมการแสดง/ซ่อนรหัสผ่านยืนยัน

  // ฟังก์ชันสำหรับรีเซ็ตรหัสผ่าน
  Future<void> _resetPassword() async {
    String newPassword = _newPasswordController.text.trim();

    setState(() {
      _isLoading.value = true;
    });

    String url = dotenv.get('API_URL_RESET_PASSWORD');

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // กำหนด Content-Type ให้ถูกต้อง
        },
        body: jsonEncode({
          'phone_number': widget.phoneNumber,
          'new_password': newPassword,
        }),
      );

      print(widget.phoneNumber);

      setState(() {
        _isLoading.value = false;
      });

      if (response.statusCode == 200) {
        var data = response.body;
        print(data);

        // แสดงข้อความยืนยันการรีเซ็ตรหัสผ่านสำเร็จ
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
                    'รีเซ็ตรหัสผ่านเรียบร้อย',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Text color for success
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ระบบได้รีเซ็ตรหัสผ่านของคุณเรียบร้อยแล้ว',
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
        await Future.delayed(Duration(seconds: 2));
        // กลับไปยังหน้าล็อกอิน
        Navigator.popUntil(context, ModalRoute.withName('/login'));
      } else {
        print('Failed to reset password. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถรีเซ็ตรหัสผ่านได้'),
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

  // ฟังก์ชันตรวจสอบว่ารหัสผ่านทั้งสองช่องตรงกันหรือไม่
  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  // ฟังก์ชันตรวจสอบความแข็งแรงของรหัสผ่าน
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }

    // ตรวจสอบความยาว
    if (value.length < 8) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
    }

    // ตรวจสอบว่ารหัสผ่านมีตัวพิมพ์ใหญ่, ตัวพิมพ์เล็ก, ตัวเลข และอักขระพิเศษ
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = value.contains(RegExp(r'[!@#\$&_*~-]'));

    if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecialCharacters) {
      return 'รหัสผ่านต้องมีตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก ตัวเลข และอักขระพิเศษ';
    }

    return null;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isLoading.dispose();
    super.dispose();
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
                                    'รีเซ็ตรหัสผ่าน',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // ช่องกรอกรหัสผ่านใหม่
                                  TextFormField(
                                    controller: _newPasswordController,
                                    obscureText:
                                        !_isPasswordVisible, // ควบคุมการแสดงรหัสผ่าน
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.lock, color: Colors.white),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      labelText: 'รหัสผ่านใหม่',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: '********',
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
                                    ),
                                    style: TextStyle(color: Colors.white),
                                    validator: _validatePassword,
                                  ),
                                  SizedBox(height: 20),
                                  // ช่องกรอกยืนยันรหัสผ่าน
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText:
                                        !_isConfirmPasswordVisible, // ควบคุมการแสดงรหัสผ่าน
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.lock, color: Colors.white),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                      labelText: 'ยืนยันรหัสผ่านใหม่',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: '********',
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
                                    ),
                                    style: TextStyle(color: Colors.white),
                                    validator: _validateConfirmPassword,
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
                                                  _resetPassword();
                                                }
                                              },
                                              icon: Icon(Icons.check,
                                                  color: Colors.white),
                                              label: Text(
                                                'รีเซ็ตรหัสผ่าน',
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
                        Spacer(flex: 2),
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
