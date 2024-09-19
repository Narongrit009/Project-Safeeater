import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp_v01/Home/MenuContent/MealHistory/meal_history_detail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favoriteMenus = [];
  bool _isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      await _fetchFavoriteMenu(email);
    } else {
      setState(() {
        _isLoading = false; // Stop loading if no email is found
      });
    }
  }

  Future<void> _fetchFavoriteMenu(String email) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_FAVORITE_MENU'] ?? ''),
        body: jsonEncode(<String, String>{'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // Store the favorite menus
          setState(() {
            favoriteMenus = responseData['data'];
          });
        } else {
          print('Error: ${responseData['message']}');
        }
      }
    } catch (error) {
      print('Error fetching favorite menus: $error');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading in the end
      });
    }
  }

  Future<void> _checkFavoriteStatus(int menuId, bool isPhoto) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      try {
        final response = await http.post(
          Uri.parse(dotenv.env['API_URL_CHECK_FAVORITE_FOOD'] ?? ''),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'email': email,
            'menu_id': menuId, // ส่ง menu_id ที่รับมาในฟังก์ชัน
            'history_type': isPhoto
                ? 'photo'
                : 'meal', // ตรวจสอบว่าเป็นรูปถ่ายหรือเมนูอาหารปกติ
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              isFavorite = result['is_favorite'] == 'true';
            });
          }
        }
      } catch (error) {
        print('Error checking favorite status: $error');
      }
    }
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
                        'รายการโปรด',
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

            // Favorite Menu Grid
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : favoriteMenus.isEmpty
                      ? Center(child: Text('ไม่พบเมนูในรายการโปรด'))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: favoriteMenus.length,
                            itemBuilder: (context, index) {
                              return _buildFavoriteMenuItem(
                                  context, favoriteMenus[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteMenuItem(BuildContext context, dynamic menu) {
    final imageUrl = menu['image_url'];

    final proxyUrl =
        '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}';

    return GestureDetector(
      onTap: () {
        // ตรวจสอบค่า menu_type เพื่อส่งค่าไปยังหน้า HistoryDetailsPage
        bool isPhoto = menu['menu_type'] == 'photo';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailsPage(
              menuId: menu['menu_id'],
              sourcePage: 'FavoritesPage',
              isPhoto:
                  isPhoto, // ส่งค่า isPhoto เพื่อระบุว่าเป็นเมนูรูปถ่ายหรือไม่
            ),
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
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
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
                      menu['is_favorite'] == 'true'
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    menu['menu_name'] ?? 'ชื่อเมนู',
                    style: TextStyle(
                      fontSize: 14.0, // Smaller font
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
