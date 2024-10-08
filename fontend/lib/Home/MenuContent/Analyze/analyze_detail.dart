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
            _showAllergyAlertDialog(allergen); // แสดงป๊อปอัพแจ้งเตือน
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

      // ตรวจสอบ URL สำหรับ API ต่างๆ
      final String? url1 = dotenv.env['API_URL_INSERT_FOOD_PHOTO_MENU'];
      final String? url2 = dotenv.env['API_URL_INSERT_MEAL_PHOTO_HISTORY'];

      if (url1 == null || url1.isEmpty || url2 == null || url2.isEmpty) {
        _showSnackBar('URL ไม่ถูกต้อง');
        return;
      }

      // เพิ่มวัตถุดิบที่ได้รับจากฐานข้อมูลลงใน ingredient_list
      List<String> updatedIngredients = List.from(widget.ingredients);
      for (var ingredient in ingredientDetails) {
        if (!updatedIngredients.contains(ingredient['ingredient_name'])) {
          updatedIngredients.add(ingredient['ingredient_name']);
        }
      }

      // เพิ่มวัตถุดิบที่แพ้ลงใน ingredient_list ถ้ามี
      if (matchingAllergen != null &&
          !updatedIngredients.contains(matchingAllergen)) {
        updatedIngredients.add(matchingAllergen!);
      }

      // Preparing first request (API_URL_INSERT_FOOD_PHOTO_MENU)
      var request1 = http.MultipartRequest('POST', Uri.parse(url1));
      request1.fields['user_id'] = userId.toString();
      request1.fields['menu_name'] = widget.dishName;
      request1.fields['ingredient_list'] = jsonEncode(
          updatedIngredients); // ใช้ updatedIngredients ที่อัปเดตแล้ว
      request1.fields['disease_list'] = jsonEncode(widget.diseaseRisks);

      // Adding image to the first request
      if (imageFile != null) {
        print('Uploading image from file: ${imageFile.path}');
        request1.files
            .add(await http.MultipartFile.fromPath('photo', imageFile.path));
      } else if (webImage != null) {
        print('Uploading web image');
        request1.files.add(http.MultipartFile.fromBytes('photo', webImage,
            filename: 'web_image.png'));
      } else {
        _showSnackBar('ไม่มีรูปภาพที่จะอัปโหลด');
        return;
      }

      // Sending first request (API_URL_INSERT_FOOD_PHOTO_MENU)
      var response1 = await request1.send();

      // Handling response from the first request
      if (response1.statusCode == 200) {
        var responseData1 = await http.Response.fromStream(response1);
        var result1 = jsonDecode(responseData1.body);
        if (result1['status'] == 'success') {
          print(
              'Response from first API (API_URL_INSERT_FOOD_PHOTO_MENU): ${responseData1.body}');

          // Extract the menu_id from the first API response
          int menuId = result1['menu_id'];

          // Preparing second request (API_URL_INSERT_MEAL_PHOTO_HISTORY)
          var request2 = http.MultipartRequest('POST', Uri.parse(url2));
          request2.fields['user_id'] = userId.toString();
          request2.fields['menu_id'] =
              menuId.toString(); // Use the received menu_id
          request2.fields['is_edible'] = isEdible;

          // Sending second request (API_URL_INSERT_MEAL_PHOTO_HISTORY)
          var response2 = await request2.send();

          // Handling response from the second request
          if (response2.statusCode == 200) {
            var responseData2 = await http.Response.fromStream(response2);
            var result2 = jsonDecode(responseData2.body);
            if (result2['status'] == 'success') {
              // Show success dialog after both requests succeed
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent closing by tapping outside
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:
                        Colors.white, // White background for clarity
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
              _showSnackBar('เกิดข้อผิดพลาดใน API 2: ${result2['message']}');
            }
          } else {
            _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์ API 2');
          }
        } else {
          _showSnackBar('เกิดข้อผิดพลาดใน API 1: ${result1['message']}');
        }
      } else {
        _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์ API 1');
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

  void _showAllergyAlertDialog(String allergen) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด dialog โดยการกดนอกกรอบ
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // มุมกลมที่นุ่มนวลขึ้น
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0), // เพิ่มพื้นที่ภายใน
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // อนิเมชัน Lottie ที่เล่นวน
                Lottie.asset(
                  'animations/alert2.json', // ไฟล์อนิเมชันที่ต้องการแสดง
                  width: 150,
                  height: 150,
                  repeat: true, // เล่นวนซ้ำ
                ),
                SizedBox(height: 24),
                Text(
                  'คำเตือนการแพ้!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.redAccent, // สีของข้อความเตือน
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'จานนี้มีส่วนผสมของ $allergen ซึ่งเป็นวัตถุดิบที่คุณแพ้ กรุณาหลีกเลี่ยงการบริโภค',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[800], // สีข้อความที่อ่านง่าย
                    height: 1.5, // เพิ่มความสูงระหว่างบรรทัด
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                // ปุ่มที่มีดีไซน์เรียบง่าย
                SizedBox(
                  width: double.infinity, // ปุ่มกว้างเต็มพื้นที่
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิดป๊อปอัพ
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.redAccent, // สีปุ่มให้เข้ากับธีม
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4, // เพิ่มเงาเบา ๆ ให้ปุ่ม
                    ),
                    child: Text(
                      'รับทราบ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
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
                _buildNutritionRow('น้ำตาล',
                    '${ingredientDetails['sugar'] ?? 'ไม่ระบุ'} กรัม'),
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
