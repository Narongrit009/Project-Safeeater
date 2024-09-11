import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for animations
import 'package:flutter/foundation.dart' show kIsWeb;
import 'analyze_detail.dart'; // Import the analyze detail page

class AnalyzePage extends StatefulWidget {
  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  File? _image;
  Uint8List? _webImage;
  final picker = ImagePicker();
  String? analysisResult;

  Future<void> _pickImageFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _webImage = result.files.first.bytes;
          });
        } else {
          setState(() {
            _image = File(result.files.single.path!);
          });
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    // แสดง pop-up ขณะกำลังวิเคราะห์
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด dialog โดยการแตะนอกหน้าต่าง
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // ปรับความโค้งของ dialog
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แอนิเมชันขณะวิเคราะห์
              Lottie.asset(
                'animations/analyze.json',
                width: 180,
                height: 180,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              SizedBox(height: 20),
              // ข้อความหลัก
              Text(
                'กำลังตรวจสอบอาหาร...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple, // สีม่วงเข้มดูหรูหรา
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              // ข้อความอธิบาย
              Text(
                'โปรดรอสักครู่ ขณะนี้เรากำลังวิเคราะห์วัตถุดิบและข้อมูลโภชนาการอย่างละเอียด เพื่อให้ข้อมูลที่ดีที่สุดสำหรับคุณ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700], // สีเทาดูสบายตา
                  fontWeight: FontWeight.w400,
                  height: 1.4, // เพิ่มระยะห่างระหว่างบรรทัด
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Progress Indicator แบบ Gradient
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.transparent),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // ข้อความเสริม
              Text(
                'นี่คือการสร้างผลลัพธ์จากการวิเคราะห์ข้อมูลสุขภาพ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent, // สีฟ้าสว่างเน้นข้อความเสริม
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    try {
      final gemini = Gemini.instance;
      Uint8List? imageBytes;

      if (kIsWeb) {
        imageBytes = _webImage;
      } else if (_image != null) {
        imageBytes = _image!.readAsBytesSync();
      }

      if (imageBytes != null) {
        final response = await gemini.textAndImage(
          text: 'เมนูนี้คืออะไร และมีวัตถุดิบอะไรในจานบ้าง ตอบเป็นภาษาไทย',
          images: [imageBytes],
        );

        setState(() {
          analysisResult =
              response?.content?.parts?.last.text ?? 'ไม่สามารถวิเคราะห์ได้';
        });
      }
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        analysisResult = 'เกิดข้อผิดพลาดในการวิเคราะห์';
      });
    }

    // ปิด pop-up หลังการวิเคราะห์เสร็จสิ้น
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzeDetailsPage(
          dishName: analysisResult!,
          webImage: _webImage, // For web
          imageFile: _image, // For mobile
        ),
      ),
    );

    // Navigate to analyze_detail.dart page
    if (analysisResult != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalyzeDetailsPage(dishName: analysisResult!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Header Section with Image Background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 24.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/bg7.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Text(
                      'วิเคราะห์วัตถุดิบในจาน',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),

              // Image Upload Section
              GestureDetector(
                onTap: () => _pickImageFromFilePicker(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _image == null && _webImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.image, size: 100.0, color: Colors.grey),
                            SizedBox(height: 8.0),
                            Text(
                              'แตะเพื่ออัพโหลดรูปภาพ',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : kIsWeb
                          ? Image.memory(_webImage!, fit: BoxFit.cover)
                          : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 32.0),

              // Capture and Analyze Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt,
                              size: 20.0, color: Colors.white),
                          label: Text(
                            'ถ่ายรูป',
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _analyzeImage, // Analyze Image
                          icon: Icon(Icons.analytics,
                              size: 20.0, color: Colors.white),
                          label: Text(
                            'วิเคราะห์',
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),

              // Analysis Result Section
              if (analysisResult != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'ผลการวิเคราะห์: $analysisResult',
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
