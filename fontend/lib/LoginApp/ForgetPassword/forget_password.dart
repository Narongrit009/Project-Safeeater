import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:myapp_v01/LoginApp/ForgetPassword/verify_otp.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _phoneNumberFocusNode = FocusNode();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  String? _phoneNumberError;
  String? _otpToken;

  Future<void> _requestOtp() async {
    String phoneNumber = _phoneNumberController.text.trim();

    setState(() {
      _isLoading.value = true;
    });

    String url = dotenv.get('API_URL_REQUEST_OTP');

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'phone_number': phoneNumber,
        },
      );

      print(phoneNumber);

      setState(() {
        _isLoading.value = false;
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body); // แปลง response เป็น JSON
        print(data);

        if (data['status'] == 'success') {
          // ดึงค่า token จาก response
          _otpToken = data['token'];

          // Show OTP request success animation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
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
                      'OTP ได้ถูกส่งไปยังโทรศัพท์ของคุณแล้ว',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          // ส่งค่า token ไปยัง VerifyOtpScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                otpToken: _otpToken!,
                phoneNumber: phoneNumber,
              ), // ส่ง token ไป
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถส่ง OTP ได้'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Failed to request OTP. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาตรวจสอบเบอร์โทรศัพท์อีกครั้ง'),
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
    _phoneNumberController.dispose();
    _phoneNumberFocusNode.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }
    String pattern = r'^(?:[+0]9)?[0-9]{10}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง';
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
                                    'ลืมรหัสผ่าน',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: _phoneNumberController,
                                    focusNode: _phoneNumberFocusNode,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.phone,
                                          color: Colors.white),
                                      labelText: 'เบอร์โทรศัพท์',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      hintText: '0801234567',
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
                                      errorText: _phoneNumberError,
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
                                                  _requestOtp();
                                                }
                                              },
                                              icon: Icon(Icons.send,
                                                  color: Colors.white),
                                              label: Text(
                                                'ส่ง OTP',
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
