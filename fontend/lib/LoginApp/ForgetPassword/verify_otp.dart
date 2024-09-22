import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // Add this import

import 'reset_password.dart'; // Import Reset Password Screen

class VerifyOtpScreen extends StatefulWidget {
  final String otpToken;
  final String phoneNumber;

  VerifyOtpScreen({
    required this.otpToken,
    required this.phoneNumber,
  });

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  Future<void> _verifyOtp() async {
    String otp = _otpController.text.trim();

    setState(() {
      _isLoading.value = true;
    });

    String url = dotenv.get('API_URL_VERIFY_OTP');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'token': widget.otpToken, // ส่ง token ที่ได้รับจากการ request OTP
          'otp': otp, // ส่ง OTP ที่ผู้ใช้กรอก
        },
      );

      print(widget.phoneNumber);

      setState(() {
        _isLoading.value = false;
      });

      if (response.statusCode == 200) {
        var data = response.body;
        print(data);

        // ตรวจสอบว่า OTP ถูกต้อง
        if (data.contains('success')) {
          // ถ้า OTP ถูกต้อง แสดง animation แล้วไปยังหน้าถัดไป
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
                      'รหัส OTP ถูกต้อง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Text color for success
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'รหัส OTP ของคุณถูกต้อง...',
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

          // หลังจากแสดงผล ให้ไปยังหน้า Reset Password
          await Future.delayed(Duration(seconds: 2)); // หน่วงเวลา 2 วินาที
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                phoneNumber: widget.phoneNumber,
              ), // ไปที่หน้าถัดไป
            ),
          );
        } else {
          // ถ้า OTP ไม่ถูกต้อง
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP ไม่ถูกต้อง, กรุณาลองอีกครั้ง'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Failed to verify OTP. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP ไม่ถูกต้อง, กรุณาลองอีกครั้ง'),
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
    _otpController.dispose();
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
                                    'กรอกรหัส OTP',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.lock, color: Colors.white),
                                      labelText: 'รหัส OTP',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: '1234',
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'กรุณากรอกรหัส OTP';
                                      }
                                      return null;
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
                                                  _verifyOtp();
                                                }
                                              },
                                              icon: Icon(Icons.check,
                                                  color: Colors.white),
                                              label: Text(
                                                'ตรวจสอบ OTP',
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
