import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:myapp_v01/Home/MenuContent/HomeMenu/content_home.dart';
import 'package:myapp_v01/Home/MenuContent/ProfileMenu/content_profile.dart';
import 'package:myapp_v01/Home/MenuContent/Analyze/analyze_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GoogleBottomBar extends StatefulWidget {
  const GoogleBottomBar({Key? key}) : super(key: key);

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > Duration(seconds: 2)) {
          lastPressed = now;
          Fluttertoast.showToast(
            msg: "กดอีกครั้งเพื่อออก",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Center(
          // Use a conditional statement to show different content based on the selected index
          child: _selectedIndex == 0
              ? ContentHome()
              : _selectedIndex == 1
                  ? AnalyzePage() // Add this line to show AnalyzePage when _selectedIndex is 1
                  : _selectedIndex == 3
                      ? ContentProfile()
                      : Container(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white, // สีพื้นหลังของ BottomNavigationBar
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 0, 106, 255).withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 30,
                offset: Offset(0, 0.5), // changes position of shadow
              ),
            ],
          ),
          child: SalomonBottomBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xff1475FF), // สีที่เลือก
            unselectedItemColor:
                Color.fromARGB(255, 100, 100, 100), // สีที่ไม่เลือก
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: _navBarItems,
          ),
        ),
      ),
    );
  }
}

final _navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home),
    title: Text("หน้าหลัก", style: GoogleFonts.kanit()),
    selectedColor: const Color(0xff1475FF),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.camera_alt_outlined),
    title: Text("วิเคราะห์", style: GoogleFonts.kanit()),
    selectedColor: const Color(0xff1475FF),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.history_outlined),
    title: Text("ประวัติ", style: GoogleFonts.kanit()),
    selectedColor: const Color(0xff1475FF),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person),
    title: Text("ฉัน", style: GoogleFonts.kanit()),
    selectedColor: const Color(0xff1475FF),
  ),
];
