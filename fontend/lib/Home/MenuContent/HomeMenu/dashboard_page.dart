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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH').then((_) {
      // Now you can safely use DateFormat with 'th_TH'
      _fetchSugarData();
    });
  }

  Future<void> _fetchSugarData() async {
    String? email = "sa@gmail.com"; // Example email, replace with actual value

    if (email != null) {
      try {
        final response = await http.post(
          Uri.parse(dotenv.env['API_URL_SHOW_DATA_DASHBOARD'] ?? ''),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'filter': selectedFilter // เพิ่ม filter
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          // print("Response Data: $responseData");

          if (responseData['status'] == 'success') {
            setState(() {
              sugarData = responseData[
                  'count_sugar_over_1g']; // ปรับเป็นข้อมูลที่ API ส่งมา
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
    int currentWeekday = today.weekday % 7; // 0 = Sunday, 6 = Saturday
    DateTime sunday = today.subtract(Duration(days: currentWeekday));

    return List.generate(
      7,
      (index) => sunday.add(Duration(days: index)),
    ); // สร้าง List ของวันอาทิตย์ถึงวันเสาร์
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
                        SizedBox(width: 16.0),
                        Text(
                          'ข้อมูลสุขภาพ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    _buildChartInfo(),
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

  Widget _buildChartInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'จำนวนเมนูที่น้ำตาลมากกว่า 1 กรัม',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
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
        maxYValue + (maxYValue * 0.4); // เพิ่ม buffer 20% เพื่อไม่ให้ชนขอบบน

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 300,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // เปลี่ยนพื้นหลังเป็นสีขาว
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
                  colors: [Color(0xFF6C15FA), Color(0xFFFE1CF5)],
                ),
                barWidth: 4,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.3),
                      Colors.pinkAccent.withOpacity(0.3)
                    ],
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxYValue / 5, // ปรับ interval ของแกน Y ให้เหมาะสม
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
                          formatDayOfWeek(getCurrentWeekDays()[value.toInt()]),
                          style: const TextStyle(
                            color: Colors.black, // ปรับให้แกน X แสดงเป็นสีดำ
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
                            color: Colors.black, // ปรับให้แกน X แสดงเป็นสีดำ
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
                      // แสดงวันที่ตามตำแหน่ง x ของจุดที่ถูกกด ไม่ว่าจะเป็นโหมดสัปดาห์หรือเดือน
                      '${formatDateForDisplay(selectedFilter == 'week' ? getCurrentWeekDays()[flSpot.x.toInt()] // ใช้วันที่ของสัปดาห์
                          : getCurrentMonthDays()[flSpot.x.toInt()])}\n', // ใช้วันที่ของเดือน
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'จำนวน: ${flSpot.y.toInt()}',
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
              horizontalInterval: maxYValue / 5, // เพิ่มเส้นตารางในแกน Y
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2), // เส้นตารางสีจาง
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false, // ไม่แสดงเส้นตั้ง
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey),
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
          _buildNutrientDetailItem('น้ำตาล', 'รายละเอียด', Icons.invert_colors),
          _buildNutrientDetailItem('โซเดียม', 'รายละเอียด', Icons.spa),
          _buildNutrientDetailItem(
              'ไขมันอิ่มตัว', 'รายละเอียด', Icons.local_pizza),
        ],
      ),
    );
  }

  Widget _buildNutrientDetailItem(
      String nutrient, String detail, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 30),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              nutrient,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Implement navigation to detail page
            },
            child: Text(
              detail,
              style: TextStyle(
                color: Color(0xFF197DFF),
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
