import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart'
    as p; // ใช้ alias 'p' เพื่อป้องกันการชนกันของชื่อ 'context'

class AnalyzeDetailsPage extends StatefulWidget {
  final String dishName;
  final List<String> ingredients;
  final List<String> diseaseRisks;
  final Uint8List? webImage;
  final File? imageFile;
  final p.Context pathContext = p.Context();

  AnalyzeDetailsPage({
    required this.dishName,
    required this.ingredients,
    required this.diseaseRisks,
    this.webImage,
    this.imageFile,
  });

  @override
  _AnalyzeDetailsPageState createState() => _AnalyzeDetailsPageState();
}

class _AnalyzeDetailsPageState extends State<AnalyzeDetailsPage> {
  List<Map<String, dynamic>> ingredientDetails = [];
  List<String> foodAllergies = [];
  bool hasAllergyConflict = false;
  String? matchingAllergen;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndfetchIngredients();
  }

  Future<void> _fetchUserProfileAndfetchIngredients() async {
    await _fetchUserProfile(); // Fetch user's allergies first
    await _fetchIngredients(); // Fetch ingredient details and check for allergy conflicts
  }

  Future<void> _fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      if (email != null) {
        final response = await http.post(
          Uri.parse(dotenv.env['API_URL_SHOW_PROFILE_LOGIN'] ?? ''),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'email': email}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            int userId = result['data']['user_id'];
            await prefs.setInt('user_id', userId);

            setState(() {
              foodAllergies = List<String>.from(result['data']['food_allergies']
                  .split(', ')
                  .map((e) => e.trim()));
            });
          } else {
            _showSnackBar('ไม่พบข้อมูลผู้ใช้');
          }
        } else {
          _showSnackBar('ไม่สามารถดึงข้อมูลผู้ใช้ได้');
        }
      } else {
        _showSnackBar('ไม่มีข้อมูลอีเมลในระบบ');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    }
  }

  Future<void> _fetchIngredients() async {
    final String apiUrl = dotenv.env['API_URL_CHECK_SHOW_INGREDIENTS'] ?? '';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': widget.ingredients}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        ingredientDetails = List<Map<String, dynamic>>.from(responseData);
        _checkAllergyConflicts();
      });
    } else {
      _showSnackBar('ไม่สามารถดึงข้อมูลวัตถุดิบได้');
    }
  }

  void _checkAllergyConflicts() {
    if (ingredientDetails.isNotEmpty && foodAllergies.isNotEmpty) {
      for (String allergen in foodAllergies) {
        for (Map<String, dynamic> ingredient in ingredientDetails) {
          if (ingredient['ingredient_name'] == allergen) {
            setState(() {
              hasAllergyConflict = true;
              matchingAllergen = allergen;
            });
            break;
          }
        }
      }
    }
  }

  Future<void> _insertMealHistory(String isEdible,
      {Uint8List? webImage, File? imageFile}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId == null) {
        _showSnackBar('ไม่พบ user_id ในระบบ');
        return;
      }

      // ตรวจสอบ URL
      final String? url = dotenv.env['API_URL_INSERT_MEAL_PHOTO_HISTORY'];
      if (url == null || url.isEmpty) {
        _showSnackBar('URL ไม่ถูกต้อง');
        return;
      }

      // Preparing MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Adding form fields (POST data)
      request.fields['user_id'] = userId.toString();
      request.fields['menu_name'] = widget.dishName;
      // แปลงลิสต์ ingredients เป็น JSON string
      request.fields['ingredient_list'] = jsonEncode(widget.ingredients);

// แปลงลิสต์ diseaseRisks เป็น JSON string
      request.fields['disease_list'] = jsonEncode(widget.diseaseRisks);
      request.fields['is_edible'] = isEdible;

      // Adding the image file (Files data)
      if (imageFile != null) {
        // ใช้ imageFile จากเครื่อง
        print('Uploading image from file: ${imageFile.path}');
        request.files
            .add(await http.MultipartFile.fromPath('photo', imageFile.path));
      } else if (webImage != null) {
        // ใช้ webImage จาก byte array
        print('Uploading web image');
        request.files.add(http.MultipartFile.fromBytes('photo', webImage,
            filename: 'web_image.png'));
      } else {
        _showSnackBar('ไม่มีรูปภาพที่จะอัปโหลด');
        return;
      }

      // ส่งข้อมูลไปยังเซิร์ฟเวอร์
      var response = await request.send();

      // ตรวจสอบ response จากเซิร์ฟเวอร์
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = jsonDecode(responseData.body);
        if (result['status'] == 'success') {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevent closing by tapping outside
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white, // White background for clarity
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success animation using Lottie
                    Lottie.asset(
                      'animations/correct.json',
                      width: 150,
                      height: 150,
                      repeat: false,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'บันทึกเมนูอาหารสำเร็จ!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Text color for success
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ระบบได้บันทึกเมนูของคุณเรียบร้อยแล้ว',
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

          // Delay for 2 seconds to allow user to see the success message
          await Future.delayed(Duration(seconds: 3));
          Navigator.of(context).pop(); // Go back to the previous page
        } else {
          _showSnackBar(
              'เกิดข้อผิดพลาดในการบันทึกข้อมูล: ${result['message']}');
        }
        print('Response: ${responseData.body}');
      } else {
        _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์');
        print('Error status code: ${response.statusCode}');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการบันทึกข้อมูล');
      print('Error: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showConfirmationDialog(
      {required String isEdible, required String message}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set the background color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation with looping behavior
              Lottie.asset(
                isEdible == 'true'
                    ? 'animations/insert_history.json' // Animation for no allergen conflict
                    : 'animations/alert.json', // Animation for allergen conflict
                width: 150,
                height: 150,
                repeat: true, // Looping animation
                reverse: false,
                animate: true,
              ),
              SizedBox(height: 16),
              // Custom text styling
              Text(
                isEdible == 'true'
                    ? 'คุณต้องการเพิ่มเมนูนี้\nในประวัติอาหารของคุณหรือไม่?'
                    : '$message',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .black, // Text color set to black for better readability
                ),
              ),
              SizedBox(height: 16),
              // Improved button styling
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Text color
                      backgroundColor: Colors.redAccent, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('ยกเลิก'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Text color
                      backgroundColor: Colors.green, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('ยืนยัน'),
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด Dialog ก่อน

                      // เรียกฟังก์ชัน _insertMealHistory พร้อมส่งข้อมูลที่ต้องการ
                      _insertMealHistory(
                        isEdible, // ส่งค่าที่ระบุว่าเมนูทานได้หรือไม่
                        webImage: widget.webImage, // ส่งรูปจากเว็บ (ถ้ามี)
                        imageFile: widget
                            .imageFile, // หรือส่งรูปจากไฟล์ในเครื่อง (ถ้ามี)
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 120.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/bg7.png'), // Background image
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          widget.dishName,
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.0),

                // Ingredient Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'วัตถุดิบ',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ingredientDetails.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        height: 100.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ingredientDetails.length,
                          itemBuilder: (context, index) {
                            final ingredient = ingredientDetails[index];
                            final imageUrl = ingredient['image_url'];
                            final ingredientName =
                                ingredient['ingredient_name'];

                            final proxyUrl =
                                '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}';

                            return GestureDetector(
                              onTap: () {
                                // ตรวจสอบให้แน่ใจว่า ingredient ไม่ใช่ null
                                if (ingredient != null) {
                                  _showIngredientDetails(ingredient[
                                      'ingredient_name']); // ใช้ข้อมูลให้ถูกต้อง
                                } else {
                                  _showSnackBar('ไม่พบข้อมูลวัตถุดิบ');
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.0,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 10.0,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.network(
                                          proxyUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Container(
                                      width: 60.0,
                                      child: Text(
                                        ingredientName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                if (matchingAllergen != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'คำเตือน: จานนี้มีส่วนผสมของ $matchingAllergen ซึ่งเป็นวัตถุดิบที่คุณแพ้',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'รายละเอียด',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'รายละเอียดของ ${widget.dishName} ประกอบด้วยวัตถุดิบหลักๆ คือ ${widget.ingredients.join(', ')}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'โรคที่เสี่ยง',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.diseaseRisks.isEmpty
                        ? [
                            Text(
                              'ไม่พบข้อมูลโรคที่เสี่ยง',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ]
                        : widget.diseaseRisks.map((disease) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '- $disease',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),
                SizedBox(height: 80.0),
              ],
            ),
          ),
          Stack(
            children: [
              Positioned(
                top: 140.0,
                left: MediaQuery.of(context).size.width / 2 - 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundImage: widget.webImage != null
                        ? MemoryImage(widget.webImage!)
                        : widget.imageFile != null
                            ? FileImage(widget.imageFile!)
                            : AssetImage('images/secret_ingredients.png')
                                as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0, // ติดขอบล่างห่าง 16 หน่วย
                left: 16.0,
                right: 16.0,
                child: Container(
                  width: double.infinity,
                  height: 60.0, // ความสูงของปุ่ม
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: matchingAllergen != null
                          ? [Colors.redAccent, Colors.red]
                          : [Color(0xFF59DFAE), Color(0xFF74FF07)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      matchingAllergen != null
                          ? _showConfirmationDialog(
                              isEdible: 'false',
                              message:
                                  'จานนี้มีส่วนผสมของ $matchingAllergen ซึ่งเป็นวัตถุดิบที่คุณแพ้ คุณแน่ใจหรือไม่ว่าต้องการเพิ่มเมนูนี้?')
                          : _showConfirmationDialog(
                              isEdible: 'true',
                              message:
                                  'คุณต้องการเพิ่มเมนูนี้ในประวัติอาหารของคุณหรือไม่?');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'เพิ่มไปยังประวัติการรับประทาน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _showIngredientDetails(String ingredientName) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_INGREDIENTS'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'ingredients_name': ingredientName}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          final ingredientDetails = result['data'][0];
          _showIngredientDialog(ingredientDetails);
        } else {
          _showSnackBar('ไม่พบข้อมูลวัตถุดิบ');
        }
      } else {
        _showSnackBar('ไม่สามารถดึงข้อมูลวัตถุดิบได้');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print('Error fetching ingredient details: $error');
    }
  }

  void _showIngredientDialog(Map<String, dynamic> ingredientDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      // ตรวจสอบว่า ingredientDetails['image_url'] เป็น null หรือไม่
                      ingredientDetails['image_url'] != null
                          ? '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(ingredientDetails['image_url'])}'
                          : 'images/placeholder.png', // หากเป็น null ให้ใช้รูปภาพแทน
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  // ตรวจสอบว่า ingredientDetails['ingredient_name'] มีค่าหรือไม่
                  '${ingredientDetails['ingredient_name'] ?? 'ไม่ทราบชื่อ'} ${ingredientDetails['quantity_per_unit'] ?? ''} กรัม',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                // ตรวจสอบและแสดงข้อมูลโภชนาการด้วยการจัดการ null
                SizedBox(height: 20.0),
                Divider(color: Colors.grey[300]),
                _buildNutritionRow('พลังงาน',
                    '${ingredientDetails['calories'] ?? 'ไม่ระบุ'} แคลอรี่'),
                _buildNutritionRow('โปรตีน',
                    '${ingredientDetails['protien'] ?? 'ไม่ระบุ'} กรัม'),
                _buildNutritionRow('คาร์โบไฮเดรต',
                    '${ingredientDetails['carbohydrates'] ?? 'ไม่ระบุ'} กรัม'),
                _buildNutritionRow(
                    'ไขมัน', '${ingredientDetails['fat'] ?? 'ไม่ระบุ'} กรัม'),
                _buildNutritionRow('ใยอาหาร',
                    '${ingredientDetails['dietary_fiber'] ?? 'ไม่ระบุ'} กรัม'),
                _buildNutritionRow('แคลเซียม',
                    '${ingredientDetails['calcium'] ?? 'ไม่ระบุ'} มิลลิกรัม'),
                _buildNutritionRow('เหล็ก',
                    '${ingredientDetails['iron'] ?? 'ไม่ระบุ'} มิลลิกรัม'),
                _buildNutritionRow('วิตามินซี',
                    '${ingredientDetails['vitamin_c'] ?? 'ไม่ระบุ'} มิลลิกรัม'),
                _buildNutritionRow('โซเดียม',
                    '${ingredientDetails['sodium'] ?? 'ไม่ระบุ'} มิลลิกรัม'),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  ),
                  child: Text(
                    'ปิด',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 18.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
