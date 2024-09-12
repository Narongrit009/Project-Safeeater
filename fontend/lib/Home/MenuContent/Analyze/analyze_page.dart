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
  String? _dishName; // ตัวแปรเก็บชื่อเมนู
  List<String> _ingredients = []; // ตัวแปรเก็บวัตถุดิบที่แยกออกมา
  List<String> _diseaseRisks = []; // ตัวแปรเก็บวัตถุดิบที่แยกออกมา

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

  void _parseAnalysisResult(String result) {
    // ตรวจสอบว่าผลลัพธ์ที่ได้ไม่เป็น null และไม่ว่างเปล่า
    if (result == null || result.trim().isEmpty) {
      setState(() {
        _dishName = 'ไม่สามารถวิเคราะห์ชื่อเมนูได้';
        _ingredients = ['ไม่พบวัตถุดิบ'];
        _diseaseRisks = ['ไม่พบข้อมูลโรคที่เสี่ยง'];
      });
      return;
    }

    final lines = result.split('\n'); // แยกผลลัพธ์เป็นบรรทัด
    String dishName = ''; // ตัวแปรเก็บชื่อเมนู
    List<String> ingredients = []; // อาร์เรย์สำหรับวัตถุดิบ
    List<String> diseaseRisks = []; // อาร์เรย์สำหรับโรคที่เสี่ยง

    // สร้าง RegExp สำหรับการลบอักขระพิเศษ
    final specialCharsRegex =
        RegExp(r'[^\w\sก-๙]'); // กรองเฉพาะตัวอักษรภาษาไทย/อังกฤษ

    bool isReadingIngredients = false;
    bool isReadingDiseases = false;

    // วนลูปเพื่อแยกข้อมูลจากบรรทัด
    for (String line in lines) {
      line = line.trim(); // ตัดช่องว่างออก
      line = line.replaceAll(specialCharsRegex, ''); // ลบอักขระพิเศษออก

      // ตรวจสอบบรรทัดที่มีชื่อเมนู
      if (line.startsWith('เมนูนี้คือ')) {
        // ใช้ RegExp จับชื่อเมนู
        final regex = RegExp(r'เมนูนี้คือ\s*(.*)');
        final match = regex.firstMatch(line);
        if (match != null) {
          dishName =
              match.group(1)!.split(' ').first.trim(); // ดึงเฉพาะชื่อเมนูออกมา
          if (dishName.isEmpty) {
            dishName = 'ไม่สามารถวิเคราะห์ชื่อเมนูได้';
          }
        }
      }
      // ตรวจสอบว่าบรรทัดเริ่มการอ่านวัตถุดิบ
      else if (line.startsWith('วัตถุดิบ') || line.contains('ในจาน')) {
        isReadingIngredients = true;
        isReadingDiseases = false;
        continue;
      }
      // ตรวจสอบว่าบรรทัดเริ่มการอ่านโรคที่เสี่ยง
      else if (line.startsWith('โรค') ||
          line.contains('เสี่ยงต่อ') ||
          line.contains('อาจทำให้เกิด')) {
        isReadingDiseases = true;
        isReadingIngredients = false;
        continue;
      }
      // เพิ่มบรรทัดที่เป็นวัตถุดิบ
      else if (isReadingIngredients && line.isNotEmpty && _isIngredient(line)) {
        ingredients.add(line); // เพิ่มวัตถุดิบลงในอาร์เรย์
      }
      // เพิ่มบรรทัดที่เป็นโรคที่เสี่ยง
      else if (isReadingDiseases && line.isNotEmpty) {
        if (line.contains('ไม่มี')) {
          diseaseRisks.add('ไม่มีโรคที่เสี่ยง');
          break;
        }
        // ตรวจสอบเฉพาะข้อความที่เกี่ยวข้องกับโรคที่เสี่ยง
        if (line.contains('โรค') ||
            line.contains('อาจทำให้เกิด') ||
            line.contains('เสี่ยงต่อ')) {
          diseaseRisks.add(line); // เพิ่มโรคที่เสี่ยงลงในอาร์เรย์
        }
      }
    }

    // ตรวจสอบกรณีที่ไม่มีวัตถุดิบ
    if (ingredients.isEmpty) {
      ingredients.add('ไม่พบวัตถุดิบ');
    }

    // ตรวจสอบกรณีที่ไม่มีโรคที่เสี่ยง
    if (diseaseRisks.isEmpty) {
      diseaseRisks.add('ไม่พบข้อมูลโรคที่เสี่ยง');
    }

    // อัพเดตตัวแปร State เพื่อแสดงผล
    setState(() {
      _dishName = dishName;
      _ingredients = ingredients;
      _diseaseRisks = diseaseRisks;
    });
  }

// ฟังก์ชันช่วยตรวจสอบว่าวัตถุดิบถูกต้องหรือไม่
  bool _isIngredient(String text) {
    // ตรวจสอบว่าข้อความนั้นเป็นวัตถุดิบ (ไม่มีตัวเลขและมีความยาวพอสมควร)
    return text.length > 1 &&
        text.length < 50 &&
        !text.contains(RegExp(r'\d')) && // กรองข้อความที่มีตัวเลขออก
        !text.contains('อื่นๆ') && // กรองคำว่า "อื่นๆ" ที่ไม่จำเป็น
        !text.contains(
            'น้ำ') && // กรองข้อความเกี่ยวกับน้ำ เช่น "น้ำปลา" "น้ำตาล"
        !text.contains('ปรุง'); // กรองคำว่า "ปรุง" ที่อาจจะไม่ใช่วัตถุดิบจริง
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
                'โปรดรอสักครู่ ขณะนี้เรากำลังวิเคราะห์วัตถุดิบอย่างละเอียด เพื่อให้ข้อมูลที่ดีที่สุดสำหรับคุณ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700], // สีเทาดูสบายตา
                  fontWeight: FontWeight.w400,
                  height: 1.4, // เพิ่มระยะห่างระหว่างบรรทัด
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
          text:
              'เมนูนี้คืออะไร มีวัตถุดิบอะไรในจานบ้าง และเสี่ยงต่อโรคอะไรบ้าง ถ้าไม่มีก็บอกว่าไม่มี ตอบเป็นภาษาไทย และแยกรายการวัตถุดิบและโรคให้เป็นอันๆ',
          images: [imageBytes],
        );

        print('Response from AI: ${response?.content?.parts?.last.text}');

        final analysisResult =
            response?.content?.parts?.last.text ?? 'ไม่สามารถวิเคราะห์ได้';

        // แยกผลการวิเคราะห์
        _parseAnalysisResult(analysisResult);

        // ปิด pop-up และไปยังหน้า AnalyzeDetailsPage
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyzeDetailsPage(
              dishName: _dishName!, // ส่งชื่อเมนู
              ingredients: _ingredients, // ส่งรายการวัตถุดิบ
              diseaseRisks: _diseaseRisks, // ส่งรายการวัตถุดิบ
              webImage: _webImage, // ส่งรูปภาพ
              imageFile: _image, // ส่งรูปภาพ
            ),
          ),
        );
      }
    } catch (e) {
      print('Error analyzing image: $e');
      Navigator.pop(context); // ปิด pop-up ถ้ามี error
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
            ],
          ),
        ),
      ),
    );
  }
}
