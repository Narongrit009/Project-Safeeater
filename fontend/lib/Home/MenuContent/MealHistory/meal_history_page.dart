import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MealHistoryPage extends StatefulWidget {
  @override
  _MealHistoryPageState createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool selectionMode = false;
  bool isViewingPhotoHistory =
      false; // ใช้สำหรับสลับระหว่างประวัติทั่วไปและประวัติที่ถ่ายรูป
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
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ฟังก์ชันนี้ใช้สำหรับสลับระหว่างการดึงข้อมูลของเมนูอาหารทั่วไปและประวัติการถ่ายรูป
  Future<void> _fetchMealHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail != null) {
      try {
        final String apiUrl = isViewingPhotoHistory
            ? dotenv.env['API_URL_MEAL_PHOTO_HISTORY'] ?? ''
            : dotenv.env['API_URL_MEAL_HISTORY'] ?? '';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': storedEmail}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              final List<dynamic> mealsData = result['data'];

              if (isViewingPhotoHistory) {
                // ประวัติอาหารที่ถ่ายเอง
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
              } else {
                // ประวัติอาหารทั่วไป
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
              }
            });
          } else {
            _showSnackBar('ไม่พบประวัติการรับประทานอาหาร');
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
      // ตรวจสอบว่ากำลังดูประวัติอาหารทั่วไปหรือประวัติอาหารที่ถ่ายเอง
      final apiUrl = isViewingPhotoHistory
          ? dotenv.env['API_URL_DELETE_MEAL_PHOTO_HISTORY'] ?? ''
          : dotenv.env['API_URL_DELETE_MEAL_HISTORY'] ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'history_ids': selectedIds}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          _showSnackBar('ลบรายการสำเร็จ');
          _fetchMealHistory(); // Refresh the meal history after deletion

          setState(() {
            selectedEdibleItems.clear();
            selectedInedibleItems.clear();
            selectionMode = false; // ปิดโหมดการเลือก
          });
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
            Icons.check_circle,
            color: Colors.white,
            size: 28.0,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.greenAccent[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ป็อปอัปคอนเฟิร์มการลบ
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
              Lottie.asset(
                'animations/delete.json',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey[600], fontSize: 18.0),
              ),
            ),
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
                  Navigator.of(context).pop(true);
                },
                child: Text('ลบ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                  textStyle:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      _deleteSelectedItems();
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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Add padding for consistency
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Space the buttons evenly
                children: [
                  _buildSwitchViewButton(), // Switch view button
                  _buildClearHistoryButton(), // Clear history button
                ],
              ),
            ),
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
            if (selectionMode) _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchViewButton() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, top: 8.0), // Adjusting position upwards
      child: Align(
        alignment: Alignment.centerLeft, // Aligning the button to the left
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isViewingPhotoHistory = !isViewingPhotoHistory; // Toggle view
              _fetchMealHistory(); // Fetch new data on toggle
            });
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: 14.0, vertical: 10.0), // Balanced padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Softer rounded edges
            ),
            backgroundColor:
                Colors.transparent, // Transparent background for gradient
            shadowColor: Colors.transparent, // No shadow
            elevation: 0, // No elevation for a flat look
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB621FE), // Vibrant purple
                  Color(0xFF1FD1F9), // Bright teal
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            child: Container(
              constraints: BoxConstraints(
                  minWidth:
                      120), // Ensure minimal width for a consistent design
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0), // Optimized padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isViewingPhotoHistory
                        ? Icons.camera_alt_outlined
                        : Icons.fastfood_outlined, // Updated icons
                    color: Colors.white,
                    size: 18.0, // Slightly larger icon for better visibility
                  ),
                  SizedBox(width: 8.0), // Space between icon and text
                  Text(
                    isViewingPhotoHistory ? 'อาหารของคุณ' : 'อาหารทั่วไป',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          14.0, // Increased font size slightly for better readability
                      fontWeight:
                          FontWeight.w600, // Medium weight for a balanced look
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            selectedInedibleItems.clear();
          });
        },
        child: Text(
          selectionMode ? 'ยกเลิก' : 'ลบประวัติ',
          style: TextStyle(
            color: selectionMode ? Colors.blue : Colors.red,
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
          setState(() {});
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
          meal['created_at'],
          meal['image_url'],
          meal['is_edible'] == 'true',
          isEdible,
        );
      },
    );
  }

  Widget _buildMealHistoryItem(int index, String? name, String? time,
      String? imageUrl, bool isFavorite, bool isEdible) {
    final selectedItems =
        isEdible ? selectedEdibleItems : selectedInedibleItems;

    // แปลงวันที่และเวลาเป็นภาษาไทย
    DateTime dateTime = time != null ? DateTime.parse(time) : DateTime.now();

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
        color: selectedItems.contains(index) ? Colors.blue[50] : Colors.white,
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
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}',
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'images/placeholder.png', // รูปภาพ placeholder กรณี imageUrl เป็น null
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
                      name != null
                          ? name
                          : 'ไม่ทราบชื่อเมนู', // กรณี menu_name เป็น null
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      formattedDate,
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
          colors: [Color(0xFF3DBBFE), Color(0xFF238FFF)],
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
                      _showDeleteConfirmationDialog();
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
