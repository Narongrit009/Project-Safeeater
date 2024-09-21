import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'food_detail.dart';
import 'recommend_health_menu.dart';

class ContentHome extends StatefulWidget {
  const ContentHome({Key? key}) : super(key: key);

  @override
  _ContentHomeState createState() => _ContentHomeState();
}

class _ContentHomeState extends State<ContentHome> {
  String username =
      "Guest"; // Default value until API returns the actual username
  bool _isLoading = true;
  List<dynamic> recommendedMenus = []; // Store recommended menus here

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      await _fetchUserProfile(email);
      await _fetchRecommendedMenu(email);
    } else {
      setState(() {
        _isLoading = false; // Stop loading if no email is found
      });
    }
  }

  Future<void> _fetchUserProfile(String email) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_PROFILE_LOGIN'] ?? ''),
        body: jsonEncode(<String, String>{'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final data = responseData['data'];

          // ตรวจสอบข้อมูลที่ขาด
          bool missingData =
              (data['username'] == null || data['username'].isEmpty) ||
                  (data['tel'] == null || data['tel'].isEmpty) ||
                  (data['gender'] == null || data['gender'].isEmpty) ||
                  (data['birthday'] == null || data['birthday'].isEmpty) ||
                  data['height'] == null ||
                  data['weight'] == null;

          if (missingData) {
            _showIncompleteProfilePopup(); // เรียกฟังก์ชันแสดงป๊อปอัพ
          }

          // ตั้งค่า username และอัปเดต State
          setState(() {
            username = data['username'] ?? 'Guest';
          });
        }
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  void _showIncompleteProfilePopup() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // ทำให้ไม่สามารถปิดป๊อปอัพโดยการคลิกนอกหน้าจอได้
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // เพิ่มมุมโค้งให้ป๊อปอัพ
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 30.0),
              SizedBox(width: 8.0),
              Text(
                'ข้อมูลไม่ครบถ้วน',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'คุณมีข้อมูลที่ยังไม่ได้กรอก กรุณากรอกข้อมูลให้ครบถ้วน',
            style: TextStyle(fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดป๊อปอัพ
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดป๊อปอัพก่อน
                Navigator.pushNamed(context,
                    '/userprofiles1'); // นำทางไปยังหน้า UserProfileStep1
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // ปุ่มโค้งมน
                ),
                backgroundColor: Colors.blueAccent, // สีของปุ่ม
              ),
              child: Text(
                'กรอกข้อมูล',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(context),
                    SizedBox(height: 32.0),
                    _buildCategorySection(),
                    SizedBox(height: 16.0),
                    _buildRecommendedMenuSection(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Text(
            'สวัสดีคุณ $username',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            'ใส่ใจคุณภาพการรับประทานอาหารของคุณ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 20.0),
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/searchpage').then((result) {
          if (result == true) {
            // รีเฟรชข้อมูลถ้าผลลัพธ์เป็น true
            _loadUserData(); // หรือฟังก์ชันใดที่ใช้ในการรีเฟรชข้อมูล
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'ค้นหาเมนูอาหาร',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'หมวดหมู่',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12.0),
        Container(
          height: 150.0,
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryCard(
                'ข้อมูลสุขภาพ',
                'ของคุณในรูปแบบแดชบอร์ด',
                'animations/dashboard.json',
                [Color(0xFF6C15FA), Color(0xFFFE1CF5), Color(0xFFFFF500)],
                () => Navigator.pushNamed(context, '/dashboard_page'),
              ),
              _buildCategoryCard(
                'รายการโปรด',
                'เมนูอาหารสุดโปรดของคุณ',
                'animations/favorites.json',
                [Color(0xFFFAF115), Color(0xFFFE1C7B), Color(0xFFE04F5F)],
                () => Navigator.pushNamed(context, '/favorites_page'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedMenuSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'เมนูสุขภาพที่แนะนำ',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Implement navigation to see all menus
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendHealthMenuPage(),
                    ),
                  ).then((result) {
                    if (result == true) {
                      // รีเฟรชข้อมูลถ้าผลลัพธ์เป็น true
                      _loadUserData(); // หรือฟังก์ชันใดที่ใช้ในการรีเฟรชข้อมูล
                    }
                  });
                },
                child: Text(
                  'ดูทั้งหมด',
                  style: TextStyle(
                    color: Color(0xFF2F80ED),
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: recommendedMenus.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: recommendedMenus.length > 4
                      ? 4
                      : recommendedMenus.length, // Display only 4 items
                  itemBuilder: (context, index) {
                    final menu = recommendedMenus[index];
                    return _buildMenuItem(menu);
                  },
                )
              : Center(
                  child: Text('ไม่มีเมนูแนะนำ'),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, String animationPath,
      List<Color> colors, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: Lottie.asset(
                  animationPath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(dynamic menu) {
    final imageUrl = menu['image_url'];
    final proxyUrl =
        '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}';

    return GestureDetector(
      onTap: () {
        // การเปิดหน้า MenuDetailsPage
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
        margin: const EdgeInsets.only(
            bottom: 16.0), // Add margin at the bottom to create space
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
              padding: const EdgeInsets.fromLTRB(
                  8.0, 8.0, 8.0, 16.0), // Increase bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    menu['menu_name'] ?? 'ชื่อเมนู',
                    style: TextStyle(
                      fontSize: 14.0, // Font size for the menu name
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'ประเภท: ${menu['category_name'] ?? 'ไม่ระบุ'}',
                    style: TextStyle(
                      fontSize: 12.0, // Font size for the category
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
