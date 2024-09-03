import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MenuDetailsPage extends StatefulWidget {
  final int menuId;

  MenuDetailsPage({required this.menuId});

  @override
  _MenuDetailsPageState createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage> {
  List<Map<String, dynamic>>? menuDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuDetails();
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
          setState(() {
            menuDetails = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                    fontSize: 20.0,
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
                    // Check if the current index is within the bounds of ingredientImages
                    String imageUrl = (index < ingredientImages.length)
                        ? ingredientImages[index]
                        : ''; // Use a placeholder or empty string if no image exists

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
                                        'images/placeholder.png', // Placeholder image in case of missing URL
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              ingredients[index],
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'รายละเอียด',
                  style: TextStyle(
                    fontSize: 20.0,
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
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 80.0),
            ],
          ),
        ),
        Positioned(
          top: 120.0,
          left: MediaQuery.of(context).size.width / 2 - 100.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  offset: Offset(0, 8),
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
        Positioned(
          bottom: 0.0,
          left: MediaQuery.of(context).size.width / 2 - 40.0,
          child: Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF59DFAE), Color(0xFF74FF07)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 40.0),
              onPressed: () {
                // Implement add to meal plan logic
              },
            ),
          ),
        ),
      ],
    );
  }
}
