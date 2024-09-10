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
          setState(() {
            username = responseData['data']['username'];
          });
        }
      }
    } catch (error) {
      print('Error fetching profile data: $error');
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
          setState(() {
            recommendedMenus = responseData['data'];
          });
        }
      }
    } catch (error) {
      print('Error fetching recommended menus: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        Navigator.pushNamed(context, '/searchpage');
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
                  );
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
        // Optionally, you can navigate to a detailed page or perform an action when tapping the item
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuDetailsPage(menuId: menu['menu_id']),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image section with rounded corners and shadow
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.0)),
                  image: DecorationImage(
                    image: NetworkImage(proxyUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // A gradient overlay to improve text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20.0)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Category name displayed on the top-left corner
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          menu['category_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Menu name and favorite icon section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    menu['menu_name'] ?? '',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'เมนูสุขภาพ',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'ดูรายละเอียด',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent,
                        ),
                      ),
                      // Add favorite icon with a ripple effect when tapped
                      GestureDetector(
                        onTap: () {
                          // Handle favorite action here
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
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
