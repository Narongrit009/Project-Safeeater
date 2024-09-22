import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // For date formatting initialization

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> sugarData = {};
  bool _isLoading = true;
  String selectedFilter = 'week'; // default เป็นสัปดาห์
  int totalSugarOver1g = 0;
  String selectedNutrient = 'sugar';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH').then((_) {
      // Now you can safely use DateFormat with 'th_TH'
      _fetchSugarData();
    });
  }

  Future<void> _fetchSugarData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      try {
        final response = await http.post(
          Uri.parse(dotenv.env['API_URL_SHOW_DATA_DASHBOARD'] ?? ''),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'filter': selectedFilter, // ส่ง filter
            'nutrient': selectedNutrient, // ส่งค่าที่เลือกจาก nutrient
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          // print("Response Data: $responseData");

          if (responseData['status'] == 'success') {
            setState(() {
              sugarData = responseData[
                  'count_nutrient_over_1g']; // ปรับเป็นข้อมูลที่ API ส่งมา
              totalSugarOver1g = responseData['total_nutrient_over_1g'];
              _isLoading = false;
            });
          } else {
            print('Error: ${responseData['message']}');
          }
        } else {
          print('Error: Unable to fetch data');
        }
      } catch (error) {
        print('Error fetching sugar data: $error');
      }
    }
  }

  Map<String, int> getFilteredSugarData(Map<String, dynamic> sugarData) {
    if (selectedFilter == 'week') {
      return getWeeklySugarData(sugarData); // ใช้ฟังก์ชันเดิมสำหรับสัปดาห์
    } else {
      return getMonthlySugarData(sugarData); // สร้างฟังก์ชันใหม่สำหรับเดือน
    }
  }

// ตัวอย่างฟังก์ชัน getMonthlySugarData()
  Map<String, int> getMonthlySugarData(Map<String, dynamic> sugarData) {
    List<DateTime> monthDays = getCurrentMonthDays();
    Map<String, int> monthlyData = {};

    for (DateTime day in monthDays) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);
      monthlyData[formattedDate] = sugarData[formattedDate] ?? 0;
    }

    return monthlyData;
  }

  List<DateTime> getCurrentMonthDays() {
    DateTime today = DateTime.now();
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastDayOfMonth =
        DateTime(today.year, today.month + 1, 1).subtract(Duration(days: 1));

    return List.generate(
      lastDayOfMonth.day,
      (index) => firstDayOfMonth.add(Duration(days: index)),
    );
  }

  List<DateTime> getCurrentWeekDays() {
    DateTime today = DateTime.now();
    return List.generate(
      7,
      (index) => today.subtract(Duration(days: index)),
    ).reversed.toList(); // เรียงจากวันปัจจุบันย้อนหลังไป 7 วัน
  }

// ฟังก์ชันเพื่อแปลง DateTime เป็น String สำหรับการแสดงผล
  String formatDateForDisplay(DateTime date) {
    return DateFormat("d MMM", "th_TH")
        .format(date); // แปลงวันที่เป็น "วันที่ เดือน" ภาษาไทย
  }

// ฟังก์ชันสร้างข้อมูลให้แน่ใจว่ามี 7 วัน (จันทร์ถึงอาทิตย์) เสมอ
  Map<String, int> getWeeklySugarData(Map<String, dynamic> sugarData) {
    List<DateTime> weekDays = getCurrentWeekDays();
    Map<String, int> weeklyData = {};

    for (DateTime day in weekDays) {
      String formattedDate = DateFormat('yyyy-MM-dd')
          .format(day); // แปลงวันเป็น String (format 'yyyy-MM-dd')
      weeklyData[formattedDate] =
          sugarData[formattedDate] ?? 0; // ถ้าวันนั้นไม่มีข้อมูลให้ใส่ค่า 0
    }

    return weeklyData;
  }

  List<Color> _getLineColors() {
    if (selectedNutrient == 'sugar') {
      // สีสำหรับน้ำตาล
      return [Color(0xFF6C15FA), Color(0xFFFE1CF5)];
    } else if (selectedNutrient == 'sodium') {
      // สีสำหรับโซเดียม
      return [Color(0xFF0FD64F), Color(0xFFF8EF42)];
    } else if (selectedNutrient == 'cholesterol') {
      // สีสำหรับคอเลสเตอรอล
      return [Color(0xFFFF0000), Color(0xFFFBD72B)];
    } else if (selectedNutrient == 'fat') {
      // ไขมันอิ่มตัว
      return [Color(0xFFEE5166), Color(0xFFF08EFC)];
    } else {
      // สีเริ่มต้น
      return [Color(0xFF6C15FA), Color(0xFFFE1CF5)];
    }
  }

  List<Color> _getAreaColors() {
    if (selectedNutrient == 'sugar') {
      // สีสำหรับน้ำตาล
      return [
        Colors.purpleAccent.withOpacity(0.3),
        Colors.pinkAccent.withOpacity(0.3)
      ];
    } else if (selectedNutrient == 'sodium') {
      // สีสำหรับโซเดียม
      return [
        Color.fromARGB(255, 23, 214, 1).withOpacity(0.3),
        Colors.yellow.withOpacity(0.3)
      ];
    } else if (selectedNutrient == 'cholesterol') {
      // สีสำหรับคอเลสเตอรอล
      return [
        Colors.orangeAccent.withOpacity(0.3),
        Colors.deepOrangeAccent.withOpacity(0.3)
      ];
    } else if (selectedNutrient == 'fat') {
      // สีสำหรับคอเลสเตอรอล
      return [Colors.red.withOpacity(0.3), Colors.pink.withOpacity(0.3)];
    } else {
      // สีเริ่มต้น
      return [
        Colors.purpleAccent.withOpacity(0.3),
        Colors.pinkAccent.withOpacity(0.3)
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide the status bar and make the container cover it
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // Allow the content to go behind the status bar
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Section with Image Background
              Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment(
                                -0.1, 0.0), // เลื่อนข้อความไปทางซ้ายเล็กน้อย
                            child: Text(
                              'ข้อมูลสุขภาพ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    _buildTotalSugarInfo(),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildLineChart(),
              SizedBox(height: 24.0),
              _buildFilterButtons(),
              SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'รายละเอียดสารอาหาร',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              _buildNutrientDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSugarInfo() {
    String nutrientName = '';
    // แปลงชื่อสารอาหารจากคีย์ที่เลือกให้เป็นชื่อที่อ่านได้
    if (selectedNutrient == 'sugar') {
      nutrientName = 'น้ำตาล';
    } else if (selectedNutrient == 'sodium') {
      nutrientName = 'โซเดียม';
    } else if (selectedNutrient == 'cholesterol') {
      nutrientName = 'คอเลสเตอรอล';
    } else if (selectedNutrient == 'fat') {
      nutrientName = 'ไขมันอิ่มตัว';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'จำนวนครั้งที่รับประทาน $nutrientName',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            SizedBox(width: 8.0), // เพิ่มระยะห่างระหว่างข้อความและไอคอน
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  backgroundColor: Colors
                      .transparent, // ตั้งค่า Background ของ Bottom Sheet ให้โปร่งใส
                  builder: (BuildContext context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // พื้นหลังสีขาว
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline, // เพิ่มไอคอนข้อมูล
                                      color: Colors.blueAccent,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      "ข้อมูลเพิ่มเติม",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  "จำนวนครั้งที่คุณบริโภค$nutrientNameมากกว่า 1 กรัมใน 1 เมนูแต่ละวัน",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  "คำอธิบาย",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "ข้อมูลนี้ถูกคำนวณจากเมนูอาหารที่คุณบริโภคในแต่ละวัน โดยมีการนับจำนวนเมนูที่มีปริมาณ$nutrientNameมากกว่า 1 กรัมใน 1เมนูต่อวัน "
                                  "ซึ่งช่วยในการติดตามปริมาณการบริโภค$nutrientNameของคุณเพื่อตรวจสอบพฤติกรรมการกินที่อาจส่งผลต่อสุขภาพ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                    height: 1.4, // เพิ่มระยะห่างระหว่างบรรทัด
                                  ),
                                ),
                                SizedBox(height: 24.0),
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF3DBBFE),
                                          Color(0xFF197DFF)
                                        ], // ไล่เฉดสีจากฟ้าไปน้ำเงิน
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent
                                              .withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .transparent, // ใช้สีโปร่งใสเพื่อให้แสดงเฉดสี
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "ปิด",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // ปิด Bottom Sheet
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.info_outline, // ใช้ไอคอน 'info'
                color: Colors.white, // กำหนดสีไอคอน
                size: 20.0,
              ),
            ),
          ],
        ),
        Text(
          '$totalSugarOver1g', // แสดงผลรวมที่ได้รับจาก API
          style: TextStyle(
            color: Colors.white,
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ปุ่มสัปดาห์
        GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = 'week';
              _fetchSugarData(); // เรียก API ใหม่เมื่อเลือกสัปดาห์
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: selectedFilter == 'week'
                  ? LinearGradient(
                      colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'สัปดาห์',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        // ปุ่มเดือน
        GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = 'month';
              _fetchSugarData(); // เรียก API ใหม่เมื่อเลือกเดือน
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: selectedFilter == 'month'
                  ? LinearGradient(
                      colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'เดือน',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    // Map ของข้อมูลน้ำตาล และกรองตาม filter (week หรือ month)
    Map<String, int> filteredSugarData = getFilteredSugarData(sugarData);
    List<FlSpot> spots = [];

    // คำนวณจุดในกราฟตามข้อมูลที่กรองมา
    filteredSugarData.forEach((date, count) {
      int index = filteredSugarData.keys.toList().indexOf(date);
      spots.add(FlSpot(index.toDouble(), count.toDouble()));
    });

    // หาค่าสูงสุดในข้อมูลเพื่อนำมาใช้เป็น maxY และเพิ่ม buffer
    double maxYValue = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 10;
    maxYValue =
        maxYValue + (maxYValue * 0.4); // เพิ่ม buffer 40% เพื่อไม่ให้ชนขอบบน

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          // กราฟ LineChart
          Container(
            height: 300,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // พื้นหลังสีขาว
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxYValue, // ใช้ค่าที่คำนวณได้จากข้อมูล
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: _getLineColors(),
                    ),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: _getAreaColors(),
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxYValue / 5) > 0
                          ? (maxYValue / 5)
                          : 1, // ปรับ interval อย่างน้อยเป็น 1
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.black, // ปรับให้แกน Y แสดงเป็นสีดำ
                            fontSize: 12.0,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // ซ่อนแกนขวา
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // ถ้ากำลังแสดงผลแบบสัปดาห์
                        if (selectedFilter == 'week' &&
                            spots.any((spot) => spot.x == value)) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              formatDayOfWeek(getCurrentWeekDays()[
                                  value.toInt()]), // ใช้ตัวย่อวัน
                              style: const TextStyle(
                                color:
                                    Colors.black, // ปรับให้แกน X แสดงเป็นสีดำ
                                fontSize: 12.0,
                              ),
                            ),
                          );
                        }

                        // ถ้ากำลังแสดงผลแบบเดือน
                        else if (selectedFilter == 'month' &&
                            spots.any((spot) => spot.x == value)) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              formatDateForDisplay(
                                  getCurrentMonthDays()[value.toInt()]),
                              style: const TextStyle(
                                color:
                                    Colors.black, // ปรับให้แกน X แสดงเป็นสีดำ
                                fontSize: 12.0,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox
                              .shrink(); // ซ่อนไม่ให้แสดงถ้าไม่มีข้อมูล
                        }
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // ซ่อนแกนบน
                  ),
                ),
                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: Colors.blue, strokeWidth: 2),
                        FlDotData(show: true),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;

                        // แสดงวันที่จริงที่สอดคล้องกับตำแหน่งของกราฟ
                        return LineTooltipItem(
                          '${formatDateForDisplay(selectedFilter == 'week' ? getCurrentWeekDays()[flSpot.x.toInt()] : getCurrentMonthDays()[flSpot.x.toInt()])}\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'จำนวน: ${flSpot.y.toInt()} ครั้ง',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: (maxYValue / 5) > 0
                      ? (maxYValue / 5)
                      : 1, // ปรับ interval อย่างน้อยเป็น 1
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2), // เส้นตารางสีจาง
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false, // ไม่แสดงเส้นตั้ง
                ),

                borderData: FlBorderData(
                  show: true, // แสดงเส้นขอบ
                  border: Border(
                    left: BorderSide(color: Colors.grey), // แสดงเส้นด้านซ้าย
                    bottom: BorderSide(color: Colors.grey), // แสดงเส้นด้านล่าง
                    right: BorderSide.none, // ไม่แสดงเส้นด้านขวา
                    top: BorderSide.none, // ไม่แสดงเส้นด้านบน
                  ),
                ),
              ),
            ),
          ),
          // ไอคอนตัวกรองในมุมขวาบน
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: () {
                // เมื่อกดไอคอนตัวกรอง สามารถเปิด Modal หรือแสดงการกระทำที่ต้องการได้
                _showNutrientFilter();
              },
              child: Container(
                padding: EdgeInsets.all(8.0), // กำหนดระยะห่างระหว่างไอคอนกับขอบ
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // ทำให้เป็นวงกลม
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3DBBFE),
                      Color(0xFF197DFF)
                    ], // ไล่เฉดสีฟ้า
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // เงาสีดำจางๆ
                      blurRadius: 4,
                      offset: Offset(2, 2), // กำหนดทิศทางของเงา
                    ),
                  ],
                ),
                child: Icon(
                  Icons.filter_list, // ใช้ไอคอนตัวกรอง
                  size: 18.0, // ขนาดไอคอน
                  color: Colors.white, // สีของไอคอนเป็นสีขาว
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNutrientFilter() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true, // ทำให้โมเดลสามารถควบคุมขนาดตามเนื้อหาได้
      builder: (BuildContext context) {
        return Wrap(
          // ใช้ Wrap เพื่อให้ความสูงพอดีกับเนื้อหา
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      "เลือกสารอาหารที่ต้องการกรอง",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Center(
                    child: Text(
                      "เลือกรายการสารอาหารที่คุณต้องการดูในกราฟ"
                      "\nสามารถเลือกกรองสารอาหาร",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // จัดเรียงตัวเลือกสารอาหารให้อยู่ในแนวนอน
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildNutrientFilterOption('น้ำตาล', 'sugar'),
                        SizedBox(width: 10.0),
                        _buildNutrientFilterOption('โซเดียม', 'sodium'),
                        SizedBox(width: 10.0),
                        _buildNutrientFilterOption(
                            'คอเลสเตอรอล', 'cholesterol'),
                        SizedBox(width: 10.0),
                        _buildNutrientFilterOption('ไขมันอิ่มตัว', 'fat'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: Container(
                      width: double.infinity, // ทำให้ปุ่มยาวเต็มหน้าจอ
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ปิดป๊อปอัพเมื่อกดปุ่ม
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "ปิด",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// ฟังก์ชันที่สร้างตัวเลือกกรองสารอาหารแต่ละรายการในแนวนอน
  Widget _buildNutrientFilterOption(String nutrient, String nutrientKey) {
    bool isSelected = selectedNutrient ==
        nutrientKey; // ตรวจสอบว่าผู้ใช้เลือกตัวเลือกนี้หรือไม่
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNutrient = nutrientKey; // ตั้งค่าสารอาหารที่ผู้ใช้เลือก
          _fetchSugarData(); // เรียกข้อมูลใหม่
        });
        Navigator.of(context).pop(); // ปิดป๊อปอัพหลังจากเลือก
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
              width: 2,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          child: Text(
            nutrient,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blueAccent : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  FlSpot _buildFlSpot(String date, int count) {
    int index = sugarData.keys.toList().indexOf(date);
    return FlSpot(index.toDouble(), count.toDouble());
  }

  // ฟังก์ชันเพื่อแปลง DateTime เป็น String สำหรับการแสดงผลแบบย่อ
  String formatDayOfWeek(DateTime date) {
    return DateFormat('EEE', 'th_TH')
        .format(date); // แปลงวันเป็นชื่อย่อ เช่น "จัน.", "อัง.", "พุธ."
  }

  Widget _buildNutrientDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildNutrientDetailItem(
              'น้ำตาล', 'รายละเอียดเกี่ยวกับปริมาณน้ำตาลในอาหาร', 'sugar'),
          _buildNutrientDetailItem(
              'โซเดียม', 'ข้อมูลเกี่ยวกับโซเดียมในอาหาร', 'sodium'),
          _buildNutrientDetailItem('คอเลสเตอรอล',
              'ข้อมูลเกี่ยวกับคอเลสเตอรอลในอาหาร', 'cholesterol'),
          _buildNutrientDetailItem(
              'ไขมันอิ่มตัว', 'ข้อมูลเกี่ยวกับไขมันในอาหาร', 'fat'),
        ],
      ),
    );
  }

  Widget _buildNutrientDetailItem(
      String nutrient, String detail, String nutrientKey) {
    return GestureDetector(
      onTap: () {
        _showNutrientInfo(
            nutrientKey); // เรียกฟังก์ชันเพื่อแสดงรายละเอียดสารอาหาร
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getLineColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.0), // ขอบมุมมนมากขึ้น
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.2),
              blurRadius: 12.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nutrient,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // สีข้อความ
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white.withOpacity(0.9), // สีข้อความโปร่งแสง
                      height: 1.4, // ระยะห่างระหว่างบรรทัด
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios, // ไอคอนลูกศร
              color: Colors.white.withOpacity(0.8),
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  void _showNutrientInfo(String nutrientKey) {
    String title = '';
    String content = '';

    // แสดงข้อมูลสารอาหารที่ถูกกด
    switch (nutrientKey) {
      case 'sugar':
        title = 'ข้อมูลเกี่ยวกับน้ำตาล';
        content =
            'วัยรุ่นชายและหญิง อายุ 14 – 25 ปี ควรบริโภคน้ำตาลไม่เกิน 24 กรัม ต่อวัน หรือเทียบได้กับน้ำตาล 6 ช้อนชา '
            'การบริโภคน้ำตาลในปริมาณที่สูงเกินไปสามารถเพิ่มความเสี่ยงในการเกิดโรคเบาหวานและปัญหาสุขภาพอื่นๆ ได้ เช่น โรคหัวใจและฟันผุ';
        break;
      case 'sodium':
        title = 'ข้อมูลเกี่ยวกับโซเดียม';
        content =
            'ควรบริโภคโซเดียมไม่เกิน 2,300 มิลลิกรัมต่อวัน (ประมาณ 1 ช้อนชา) เพื่อลดความเสี่ยงต่อโรคความดันโลหิตสูงและโรคหัวใจ การบริโภคโซเดียมมากเกินไปสามารถนำไปสู่การกักเก็บน้ำในร่างกายและเพิ่มภาระการทำงานของหัวใจ';
        break;
      case 'cholesterol': // กรณีสำหรับคอเลสเตอรอล
        title = 'ข้อมูลคอเลสเตอรอล';
        content =
            'คอเลสเตอรอลเป็นสารที่ร่างกายต้องการในปริมาณที่เหมาะสม ผู้ใหญ่ควรบริโภคคอเลสเตอรอลไม่เกิน 300 มิลลิกรัมต่อวัน '
            'หากได้รับมากเกินไปอาจเพิ่มความเสี่ยงต่อโรคหัวใจและหลอดเลือด';
        break;
      case 'fat':
        title = 'ข้อมูลเกี่ยวกับไขมันอิ่มตัว';
        content =
            'ควรจำกัดการบริโภคไขมันอิ่มตัวให้ไม่เกิน 20 กรัมต่อวัน เพื่อลดความเสี่ยงในการเกิดโรคหัวใจและหลอดเลือด ไขมันอิ่มตัวพบมากในอาหารประเภทเนื้อสัตว์ติดมัน น้ำมันปาล์มและผลิตภัณฑ์จากนม';
        break;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // พื้นหลังสีขาว
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // เพิ่ม padding ให้ดูสบายตา
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header ของป็อปอัพ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0F7FA), // พื้นหลังเบาๆ รอบไอคอน
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blueAccent,
                        size: 28.0,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // เนื้อหาข้อความ
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    height: 1.5, // เพิ่มระยะห่างระหว่างบรรทัด
                  ),
                ),
                SizedBox(height: 24.0),
                // ปุ่มปิด
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3DBBFE),
                            Color(0xFF197DFF),
                          ], // ไล่เฉดสีฟ้าไปน้ำเงิน
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          "ปิด",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // ปิด Bottom Sheet
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
