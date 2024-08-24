import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class ContentHome extends StatelessWidget {
  const ContentHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ทำให้ Container ด้านบนครอบคลุม status bar ด้วยการซ่อน status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // ไม่ต้องการ SafeArea ที่ครอบ status bar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Section ที่ครอบคลุม status bar
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 24.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/bg7.png'), // รูปภาพ background
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10.0,
                      offset: Offset(0, 5), // เพิ่มเงาให้กับ Container ด้านบน
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context)
                            .padding
                            .top), // ขยับลงเพื่อหลีกเลี่ยงการทับกับ status bar
                    Text(
                      'สวัสดีคุณ Narongrit',
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
                    // Search Bar
                    GestureDetector(
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
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาเมนูอาหารหรือวัตถุดิบ',
                                  border: InputBorder.none,
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/searchpage');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),

              // Category Section
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

              // Scrollable Category Cards within a Single Container
              Container(
                height: 150.0,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  scrollDirection: Axis.horizontal, // Make it horizontal
                  children: [
                    _buildCategoryCard(
                      'ข้อมูลสุขภาพ',
                      'ของคุณในรูปแบบแดชบอร์ด',
                      'animations/dashboard.json',
                      [Color(0xFF6C15FA), Color(0xFFFE1CF5), Color(0xFFFFF500)],
                    ),
                    _buildCategoryCard(
                      'รายการโปรด',
                      'เมนูอาหารสุดโปรดของคุณ',
                      'animations/favorites.json',
                      [Color(0xFFFAF115), Color(0xFFFE1C7B), Color(0xFFE04F5F)],
                    ),
                    // Add more cards here
                  ],
                ),
              ),
              SizedBox(height: 16.0),

              // Recommended Menu Section
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
              SizedBox(height: 8.0),

              // Menu List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4, // You can increase the count to show more items
                  itemBuilder: (context, index) {
                    return _buildMenuItem(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, String subtitle, String animationPath, List<Color> colors) {
    return Padding(
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
              offset: Offset(0, 4), // เพิ่มเงาให้กับ Category Card
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
              width: 100.0, // เพิ่มขนาดแอนิเมชันให้ใหญ่ขึ้น
              height: 100.0, // เพิ่มขนาดแอนิเมชันให้ใหญ่ขึ้น
              child: Lottie.asset(
                animationPath,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: Offset(0, 4), // เพิ่มเงาให้กับเมนู
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/salad.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'ผัดผักรวมมิตร',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.favorite_border, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
