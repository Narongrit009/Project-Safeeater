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
  Map<String, dynamic>? menuDetails;
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
            menuDetails = result['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : menuDetails == null
              ? Center(child: Text('ไม่พบรายละเอียดเมนู'))
              : _buildMenuDetails(),
    );
  }

  Widget _buildMenuDetails() {
    final menuName = menuDetails!['menu_name'] ?? 'No Name';
    final imageUrl = menuDetails!['image_url'] ?? '';
    final ingredients = menuDetails!['ingredients']?.split(', ') ?? [];
    final ingredientImages =
        menuDetails!['ingredients_image']?.split(', ') ?? [];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Container with background image
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
              SizedBox(
                  height: 60.0), // Space to accommodate the overlapping image
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
              // Ingredients list with scrollable horizontal list
              Container(
                height: 100.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return Padding(
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
                              child: Image.network(
                                '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(ingredientImages[index])}',
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
                  'รายละเอียดของ $menuName ประกอบด้วยวัตถุดิบหลักๆ คือ ${ingredients.join(', ')}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 80.0), // Add space for floating button
            ],
          ),
        ),
        // Overlapping Menu Image
        // Overlapping Menu Image
        Positioned(
          top: 120.0, // Adjust the top position as needed
          left: MediaQuery.of(context).size.width / 2 -
              100.0, // Adjust for centering the larger image
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
              radius: 100.0, // Increase this value to make the image larger
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
