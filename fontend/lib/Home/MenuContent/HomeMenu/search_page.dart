import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ทำให้ Container ด้านบนครอบคลุม status bar ด้วยการซ่อน status bar
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
            // Header Section with background image
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
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
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
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'ค้นหาเมนูอาหารหรือวัตถุดิบ',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Icon(Icons.search, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 16.0), // เพิ่มระยะห่างระหว่าง Header กับเนื้อหาด้านล่าง
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                children: <Widget>[
                  _buildSearchResultItem('ผัดผัก'),
                  _buildSearchResultItem('ข้าวมันไก่ต้ม'),
                  _buildSearchResultItem('ตำลำกุ้ง'),
                  _buildSearchResultItem('ผัดคะน้าหมูกรอบ'),
                  _buildSearchResultItem('แกงเขียวหวาน'),
                  _buildShowMoreButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        // กดแล้วจะเกิดอะไรต่อ ใส่โค้ดที่นี่
      },
    );
  }

  Widget _buildShowMoreButton() {
    return ListTile(
      title: Center(
        child: Text(
          'แสดงเพิ่มเติม',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      onTap: () {
        // กดแล้วจะเกิดอะไรต่อ ใส่โค้ดที่นี่
      },
    );
  }
}
