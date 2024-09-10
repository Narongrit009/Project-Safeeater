import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class MenuDetailsPage extends StatefulWidget {
  final int menuId;

  MenuDetailsPage({required this.menuId});

  @override
  _MenuDetailsPageState createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  List<Map<String, dynamic>>? menuDetails;
  bool _isLoading = true;
  List<String> foodAllergies = [];
  bool hasAllergyConflict = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndMenuDetails();
  }

  Future<void> _fetchUserProfileAndMenuDetails() async {
    await _fetchUserProfile(); // Fetch user's allergies first
    await _fetchMenuDetails(); // Fetch menu details and check for allergy conflicts
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
            // Store user_id in SharedPreferences
            int userId = result['data']
                ['user_id']; // assuming user_id is part of the response
            await prefs.setInt('user_id', userId);

            // Casting dynamic list to List<String> for food allergies
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
      print('Error fetching user profile: $error');
    }
  }

  Future<void> _fetchMenuDetails() async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_MENU_DETAILS'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{'menu_id': widget.menuId}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          final menuData = List<Map<String, dynamic>>.from(result['data']);
          setState(() {
            menuDetails = menuData;
            _isLoading = false;
            // Check for allergy conflicts
            _checkAllergyConflicts();
          });
        } else {
          _showSnackBar('ไม่พบรายละเอียดเมนู');
        }
      } else {
        _showSnackBar('ไม่สามารถดึงข้อมูลเมนูได้');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print('Error fetching menu details: $error');
    }
  }

  void _checkAllergyConflicts() {
    if (menuDetails != null && foodAllergies.isNotEmpty) {
      final ingredients = menuDetails![0]['ingredients']?.split(', ') ?? [];
      for (String allergy in foodAllergies) {
        if (ingredients.contains(allergy)) {
          setState(() {
            hasAllergyConflict = true;
          });
          break;
        }
      }
    }
  }

  Future<void> _insertMealHistory(String isEdible) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId =
          prefs.getInt('user_id'); // Fetching user_id from SharedPreferences
      if (userId == null) {
        _showSnackBar('ไม่พบ user_id ในระบบ');
        return;
      }

      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_INSERT_MEAL_HISTORY'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'menu_id': widget.menuId,
          'is_edible': isEdible,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          // Display success confirmation dialog
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
                      'ระบบได้บันทึกข้อมูลของคุณเรียบร้อยแล้ว',
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

          // Close the dialog and return to the previous screen
          Navigator.of(context).pop(); // Close the success dialog
          Navigator.of(context).pop(); // Go back to the previous page
        } else {
          _showSnackBar('เกิดข้อผิดพลาดในการบันทึกข้อมูล');
        }
      } else {
        _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการบันทึกข้อมูล');
      print('Error inserting meal history: $error');
    }
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
                      Navigator.of(context).pop(); // Close the dialog
                      _insertMealHistory(
                          isEdible); // Proceed with adding meal history
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : menuDetails == null || menuDetails!.isEmpty
              ? Center(child: Text('ไม่พบรายละเอียดเมนู'))
              : _buildMenuDetails(),
    );
  }

  Widget _buildMenuDetails() {
    final menu = menuDetails![0];
    final menuName = menu['menu_name'] ?? 'No Name';
    final imageUrl = menu['image_url'] ?? '';
    final ingredients = menu['ingredients']?.split(', ') ?? [];
    final ingredientImages = menu['ingredients_image']?.split(', ') ?? [];
    final disease = menu['related_conditions']?.split(', ') ?? [];
    final disease_detail = menu['related_conditions_detail']?.split(', ') ?? [];

    // Find the first allergen that matches with the ingredients
    String? matchingAllergen;
    for (String allergen in foodAllergies) {
      if (ingredients.contains(allergen)) {
        matchingAllergen = allergen;
        break;
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 120.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/bg7.png'),
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
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            // Implement favorite logic
                          },
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        menuName,
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
              SizedBox(height: 60.0),

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
              Container(
                height: 100.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    String imageUrl = (index < ingredientImages.length)
                        ? ingredientImages[index]
                        : '';

                    return GestureDetector(
                      onTap: () {
                        _showIngredientDetails(ingredients[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'images/placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Container(
                              width: 60.0, // ความกว้างเท่ากับ Container ด้านบน
                              child: Text(
                                ingredients[index],
                                overflow: TextOverflow
                                    .ellipsis, // เพิ่มการตัดข้อความเป็น ...
                                maxLines: 1, // กำหนดให้แสดงแค่บรรทัดเดียว
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center, // จัดตำแหน่งกลาง
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Add the red warning if there's an allergy conflict
              if (matchingAllergen != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Text(
                    'คำเตือน',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'จานนี้มีส่วนผสมของ $matchingAllergen ซึ่งเป็นวัตถุดิบที่คุณแพ้',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],

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
                  ingredients.isNotEmpty
                      ? 'รายละเอียดของ $menuName ประกอบด้วยวัตถุดิบหลักๆ คือ ${ingredients.join(', ')}'
                      : 'ไม่มีข้อมูลวัตถุดิบสำหรับเมนูนี้',
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
                  children: List.generate(disease.length, (index) {
                    String diseaseName = disease[index];
                    String diseaseDescription = disease_detail.length > index
                        ? disease_detail[index]
                        : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$diseaseName : ', // ชื่อโรค
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            TextSpan(
                              text: diseaseDescription, // รายละเอียดของโรค
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 80.0),
            ],
          ),
        ),
        Stack(
          children: [
            Positioned(
              top: 120.0,
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
                  backgroundImage: NetworkImage(
                    '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}',
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            // เนื้อหาอื่นๆ ที่จะซ้อนด้านล่างปุ่ม
            Positioned(
              bottom: 16.0, // ติดขอบล่าง
              left: 16.0,
              right: 16.0,
              child: Container(
                width: double.infinity,
                height: 60.0, // ปรับขนาดปุ่มเพื่อให้ใหญ่ขึ้น
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
                      '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(ingredientDetails['image_url'])}',
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  '${ingredientDetails['ingredient_name']} ${ingredientDetails['quantity_per_unit']} กรัม',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Divider(color: Colors.grey[300]),
                _buildNutritionRow(
                    'พลังงาน', '${ingredientDetails['calories']} แคลอรี่'),
                _buildNutritionRow(
                    'โปรตีน', '${ingredientDetails['protien']} กรัม'),
                _buildNutritionRow('คาร์โบไฮเดรต',
                    '${ingredientDetails['carbohydrates']} กรัม'),
                _buildNutritionRow('ไขมัน', '${ingredientDetails['fat']} กรัม'),
                _buildNutritionRow(
                    'ใยอาหาร', '${ingredientDetails['dietary_fiber']} กรัม'),
                _buildNutritionRow(
                    'แคลเซียม', '${ingredientDetails['calcium']} มิลลิกรัม'),
                _buildNutritionRow(
                    'เหล็ก', '${ingredientDetails['iron']} มิลลิกรัม'),
                _buildNutritionRow(
                    'วิตามินซี', '${ingredientDetails['vitamin_c']} มิลลิกรัม'),
                _buildNutritionRow(
                    'โซเดียม', '${ingredientDetails['sodium']} มิลลิกรัม'),
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
