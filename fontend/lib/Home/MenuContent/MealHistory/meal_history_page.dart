import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MealHistoryPage extends StatefulWidget {
  @override
  _MealHistoryPageState createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool selectionMode = false; // เริ่มต้นไม่อยู่ในโหมดการเลือก
  List<int> selectedItems = [];
  List<Map<String, dynamic>> edibleMeals = [];
  List<Map<String, dynamic>> inedibleMeals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMealHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMealHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail != null) {
      try {
        final response = await http.post(
          Uri.parse(dotenv.env['API_URL_MEAL_HISTORY'] ?? ''),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': storedEmail}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              final List<dynamic> mealsData = result['data'];
              edibleMeals = mealsData
                  .where((meal) => meal['is_edible'] == 'true')
                  .map<Map<String, dynamic>>(
                      (meal) => Map<String, dynamic>.from(meal))
                  .toList();
              inedibleMeals = mealsData
                  .where((meal) => meal['is_edible'] == 'false')
                  .map<Map<String, dynamic>>(
                      (meal) => Map<String, dynamic>.from(meal))
                  .toList();
            });
          } else {
            _showSnackBar('ไม่พบข้อมูลประวัติการรับประทานอาหาร');
          }
        } else {
          _showSnackBar('การร้องขอล้มเหลว กรุณาลองใหม่อีกครั้ง');
        }
      } catch (error) {
        _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
        print('Error fetching meal history: $error');
      }
    } else {
      _showSnackBar('ไม่พบอีเมลที่จัดเก็บไว้');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          children: [
            _buildHeader(context),
            SizedBox(height: 8.0),
            _buildClearHistoryButton(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMealHistoryList(isEdible: true),
                  _buildMealHistoryList(isEdible: false),
                ],
              ),
            ),
            if (selectionMode)
              _buildDeleteButton(), // ปุ่มลบเมื่ออยู่ในโหมดการเลือก
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top),
          Text(
            'ประวัติการรับประทานอาหาร',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearHistoryButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectionMode = !selectionMode;
            selectedItems
                .clear(); // ล้างการเลือกเมื่อเข้าสู่หรือออกจากโหมดการเลือก
          });
        },
        child: Text(
          selectionMode
              ? 'ยกเลิก'
              : 'ลบประวัติ', // เปลี่ยนข้อความเมื่ออยู่ในโหมดการเลือก
          style: TextStyle(
            color: selectionMode ? Colors.blue : Colors.red, // เปลี่ยนสีข้อความ
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: _tabController.index == 0
              ? LinearGradient(
                  colors: [Color(0xFF74FF07), Color(0xFF59DFAE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Color(0xFFDB0000), Color(0xFF9A0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        tabs: [
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text('อาหารที่ทานได้'),
            ),
          ),
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text('อาหารที่ทานไม่ได้'),
            ),
          ),
        ],
        onTap: (index) {
          setState(() {}); // Rebuild to update gradient
        },
      ),
    );
  }

  Widget _buildMealHistoryList({required bool isEdible}) {
    final meals = isEdible ? edibleMeals : inedibleMeals;
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildMealHistoryItem(
          index,
          meal['menu_name'],
          meal['meal_time'],
          meal['image_url'],
          meal['is_edible'] == 'true',
        );
      },
    );
  }

  Widget _buildMealHistoryItem(
      int index, String name, String time, String imageUrl, bool isFavorite) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectionMode = true;
          selectedItems.add(index);
        });
      },
      onTap: () {
        if (selectionMode) {
          setState(() {
            if (selectedItems.contains(index)) {
              selectedItems.remove(index);
            } else {
              selectedItems.add(index);
            }
          });
        }
      },
      child: Card(
        color: selectedItems.contains(index)
            ? Colors.blue[50]
            : Colors.white, // เปลี่ยนสีพื้นหลังเมื่อถูกเลือก
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}',
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (selectionMode)
                Icon(
                  selectedItems.contains(index)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color:
                      selectedItems.contains(index) ? Colors.blue : Colors.grey,
                )
              else
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    // Implement favorite toggle logic
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3DBBFE),
            Color(0xFF238FFF)
          ], // ไล่สีสำหรับส่วนเลือกทั้งหมด
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: selectedItems.length ==
                    edibleMeals.length +
                        inedibleMeals.length, // เปลี่ยนเป็นจำนวนรายการจริง
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedItems = List<int>.generate(
                          edibleMeals.length + inedibleMeals.length,
                          (index) => index);
                    } else {
                      selectedItems.clear();
                    }
                  });
                },
                activeColor: Colors.white,
                checkColor: Colors.blue, // สีขาวสำหรับ checkbox ที่ถูกเลือก
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                side: MaterialStateBorderSide.resolveWith(
                  (states) => BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
              const Text(
                'เลือกทั้งหมด',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            '${selectedItems.length} รายการ',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFDB0000),
                  Color(0xFF9A0000)
                ], // ไล่สีสำหรับปุ่มลบ
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ElevatedButton.icon(
              onPressed: selectedItems.isNotEmpty
                  ? () {
                      // Implement delete logic
                    }
                  : null,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'ลบ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
