import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_detail.dart';

class RecommendHealthMenuPage extends StatefulWidget {
  const RecommendHealthMenuPage({Key? key}) : super(key: key);

  @override
  _RecommendHealthMenuPageState createState() =>
      _RecommendHealthMenuPageState();
}

class _RecommendHealthMenuPageState extends State<RecommendHealthMenuPage> {
  List<dynamic> recommendedMenus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      await _fetchRecommendedMenu(email);
    } else {
      setState(() {
        _isLoading = false; // Stop loading if no email is found
      });
    }
  }

  Future<void> _fetchRecommendedMenu(String email) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_RECOMMEND_MENU'] ?? ''),
        body: jsonEncode(<String, String>{'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // Store the recommended menus
          recommendedMenus = responseData['data'];
          final historyType = 'meal';

          // Check favorite status for each recommended menu
          for (var menu in recommendedMenus) {
            menu['isFavorite'] =
                await checkFavoriteStatus(menu['menu_id'], historyType);
          }
        }
      }
    } catch (error) {
      print('Error fetching recommended menus: $error');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading in the end
      });
    }
  }

  Future<bool> checkFavoriteStatus(int menuId, String historyType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail == null) {
      return false; // No email stored
    }

    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_CHECK_FAVORITE_FOOD'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': storedEmail,
          'menu_id': menuId,
          'history_type': historyType, // Pass the history type
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          // print('Favorite status for menu $menuId: ${result['is_favorite']}');
          return result['is_favorite'] ==
              'true'; // Ensure this returns the correct value
        }
      }
    } catch (error) {
      print('Error checking favorite status: $error');
    }

    return false; // Default to false if any error occurs
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 24.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bg7.png'), // Image background
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10.0,
                    offset: Offset(0, 5), // Shadow below the header
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Center(
                      child: Text(
                        'เมนูสุขภาพแนะนำ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 48.0), // Placeholder to balance the back arrow
                ],
              ),
            ),
            SizedBox(height: 16.0),

            // Recommended Health Menu Grid
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: recommendedMenus.length,
                        itemBuilder: (context, index) {
                          return _buildRecommendMenuItem(
                              context, recommendedMenus[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendMenuItem(BuildContext context, dynamic menu) {
    final imageUrl = menu['image_url'];
    final proxyUrl =
        '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailsPage(menuId: menu['menu_id']),
          ),
        ).then((result) {
          if (result == true) {
            // รีเฟรชข้อมูลถ้าผลลัพธ์เป็น true
            _loadUserData(); // หรือฟังก์ชันใดที่ใช้ในการรีเฟรชข้อมูล
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12.0), // Make the corners a bit sharper
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: Offset(0, 4), // Shadow for the grid items
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.0)),
                      image: DecorationImage(
                        image: NetworkImage(proxyUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Icon(
                      menu['isFavorite']
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduce padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    menu['menu_name'] ?? 'ชื่อเมนู',
                    style: TextStyle(
                      fontSize: 14.0, // Make font smaller
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'ประเภท: ${menu['category_name'] ?? 'ไม่ระบุ'}',
                    style: TextStyle(
                      fontSize: 12.0, // Make font smaller
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
