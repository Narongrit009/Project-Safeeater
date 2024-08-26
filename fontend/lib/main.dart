import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp_v01/LoginApp/intro_screen.dart';
import 'package:myapp_v01/LoginApp/intro_screen2.dart';
import 'package:myapp_v01/LoginApp/login_app.dart';
import 'package:myapp_v01/LoginApp/register_app.dart';
import 'package:myapp_v01/LoginApp/ForgetPassword/forget_password.dart';
import 'package:myapp_v01/Home/MenuContent/navigation.dart';
import 'package:myapp_v01/Home/MenuContent/HomeMenu/search_page.dart';
import 'package:myapp_v01/Home/MenuContent/HomeMenu/dashboard_page.dart';
import 'package:myapp_v01/Home/MenuContent/HomeMenu/favorites_page.dart';
import 'package:myapp_v01/Home/ResgisStart/intro_content.dart';
import 'package:myapp_v01/Home/ResgisStart/data_userprofile.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure binding is initialized before calling runApp
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Eater',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.kanitTextTheme(),
      ),
      initialRoute: '/', // Start at UserProfileStep1
      routes: {
        '/': (context) => FutureBuilder(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else {
                    bool isLoggedIn = snapshot.data ?? false;
                    return isLoggedIn ? IntroScreen2() : IntroScreen();
                  }
                }
              },
            ),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgetpass': (context) => ForgotPasswordScreen(),
        '/homepage': (context) => GoogleBottomBar(),
        '/introcontent': (context) => IntroContent(),
        '/userprofiles1': (context) => UserProfileStep1(),
        '/searchpage': (context) => SearchPage(),
        '/dashboard_page': (context) => DashboardPage(),
        '/favorites_page': (context) => FavoritesPage(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }
}
