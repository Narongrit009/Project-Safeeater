import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // นำเข้าแพ็คเกจ intl
import 'package:intl/date_symbol_data_local.dart';

class MealHistoryPage extends StatefulWidget {
  @override
  _MealHistoryPageState createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool selectionMode = false;
  List<int> selectedEdibleItems = [];
  List<int> selectedInedibleItems = [];
  List<Map<String, dynamic>> edibleMeals = [];
  List<Map<String, dynamic>> inedibleMeals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMealHistory();
    initializeDateFormatting('th_TH', null).then((_) {
      setState(() {
        // เมื่อ locale ถูกโหลดแล้ว สามารถแปลงวันที่ได้
      });
    });
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
            _showSnackBar('คุณยังไม่มีประวัติการรับประทานอาหาร');
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

  Future<void> _deleteSelectedItems() async {
    final selectedIds = <int>[];
    selectedIds.addAll(
      selectedEdibleItems.map((index) => edibleMeals[index]['history_id']),
    );
    selectedIds.addAll(
      selectedInedibleItems.map((index) => inedibleMeals[index]['history_id']),
    );

    if (selectedIds.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_DELETE_MEAL_HISTORY'] ?? ''),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'history_ids': selectedIds}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          _showSnackBar('ลบรายการสำเร็จ');
          _fetchMealHistory(); // Refresh the meal history after deletion
        } else {
          _showSnackBar('เกิดข้อผิดพลาดในการลบรายการ');
        }
      } else {
        _showSnackBar('การร้องขอล้มเหลว กรุณาลองใหม่อีกครั้ง');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print('Error deleting meal history: $error');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle, // เพิ่มไอคอน
            color: Colors.white,
            size: 28.0,
          ),
          SizedBox(width: 12.0), // ระยะห่างระหว่างไอคอนกับข้อความ
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center, // ทำให้ข้อความอยู่ตรงกลาง
            ),
          ),
        ],
      ),
      backgroundColor: Colors.greenAccent[700], // พื้นหลังสีเขียวเข้ม
      behavior: SnackBarBehavior.floating, // SnackBar แบบลอย
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8, // เพิ่มเงาให้กับ SnackBar
      duration: Duration(seconds: 3), // แสดงผลเป็นเวลา 3 วินาที
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ฟังก์ชันแสดงป็อปอัปคอนเฟิร์มการลบ
  Future<void> _showDeleteConfirmationDialog() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          title: Column(
            children: [
              Text(
                'ยืนยันการลบ',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Divider(
                color: Colors.redAccent,
                thickness: 2,
                indent: 50,
                endIndent: 50,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'คุณแน่ใจหรือไม่ว่าต้องการลบรายการที่เลือก?',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              // อนิเมชัน Lottie ที่เพิ่มความสวยงาม
              Lottie.asset(
                'animations/delete.json',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
          actions: <Widget>[
            // ปุ่มยกเลิก
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // ปิดป็อปอัปและไม่ลบ
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey[600], fontSize: 18.0),
              ),
            ),
            // ปุ่มลบที่มีการไล่สีและเงา
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.4),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // ปิดป็อปอัปและลบ
                },
                child: Text('ลบ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // ทำให้พื้นหลังโปร่งใส
                  foregroundColor: Colors.white, // สีของข้อความในปุ่ม
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                  textStyle:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 0, // ปิดการใช้งานเงามาตรฐาน
                ),
              ),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      _deleteSelectedItems(); // ถ้าได้รับการยืนยัน ให้ลบรายการ
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
            selectedEdibleItems.clear();
            selectedInedibleItems
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
    final selectedItems =
        isEdible ? selectedEdibleItems : selectedInedibleItems;

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
          isEdible,
        );
      },
    );
  }

  Widget _buildMealHistoryItem(int index, String name, String time,
      String imageUrl, bool isFavorite, bool isEdible) {
    final selectedItems =
        isEdible ? selectedEdibleItems : selectedInedibleItems;

    // แปลงวันที่และเวลาเป็นภาษาไทย
    DateTime dateTime =
        DateTime.parse(time); // สมมติว่า time เป็น String ในรูปแบบ ISO 8601

    // แปลงเวลาและวันที่เป็นรูปแบบที่ต้องการ
    String formattedDate = 'เวลา ' +
        DateFormat('HH:mm น.', 'th_TH').format(dateTime) +
        ' วันที่ ' +
        DateFormat('d MMMM', 'th_TH').format(dateTime) +
        ' ${dateTime.year + 543}';

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
                      formattedDate, // แสดงเวลาและวันที่ในรูปแบบภาษาไทย
                      style: TextStyle(
                        fontSize: 13.0,
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
    final isEdibleTab = _tabController.index == 0;
    final selectedItems =
        isEdibleTab ? selectedEdibleItems : selectedInedibleItems;
    final totalItems = isEdibleTab ? edibleMeals.length : inedibleMeals.length;

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
                value: selectedItems.length == totalItems,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (isEdibleTab) {
                        selectedEdibleItems = List<int>.generate(
                            edibleMeals.length, (index) => index);
                      } else {
                        selectedInedibleItems = List<int>.generate(
                            inedibleMeals.length, (index) => index);
                      }
                    } else {
                      if (isEdibleTab) {
                        selectedEdibleItems.clear();
                      } else {
                        selectedInedibleItems.clear();
                      }
                    }
                  });
                },
                activeColor: Colors.white,
                checkColor: Colors.blue,
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
                colors: [Color(0xFFDB0000), Color(0xFF9A0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ElevatedButton.icon(
              onPressed: selectedItems.isNotEmpty
                  ? () {
                      _showDeleteConfirmationDialog(); // เรียกป็อปอัปคอนเฟิร์มก่อนลบ
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
