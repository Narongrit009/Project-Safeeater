import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_detail.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchInitialMenu(); // Fetch the first 10 menus when the page opens
  }

  Future<void> _fetchInitialMenu() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            dotenv.env['API_URL_GET_INITIAL_FOOD'] ?? ''), // Adjust this URL
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          List<Map<String, dynamic>> fetchedMenus =
              List<Map<String, dynamic>>.from(result['data']);

          // ตรวจสอบสถานะรายการโปรดในแต่ละเมนู
          for (var menu in fetchedMenus) {
            menu['isFavorite'] = await checkFavoriteStatus(menu['menu_id']);
          }

          setState(() {
            _searchResults = fetchedMenus;
          });
        } else {
          _showSnackBar('ไม่พบข้อมูลเมนูเริ่มต้น');
        }
      } else {
        _showSnackBar('การดึงข้อมูลเมนูเริ่มต้นล้มเหลว');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print('Error fetching initial menu data: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> checkFavoriteStatus(int menuId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail =
        prefs.getString('email'); // ดึง email จาก local storage

    if (storedEmail == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_CHECK_FAVORITE_FOOD'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': storedEmail,
          'menu_id': menuId,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          return result['is_favorite'] == 'true';
        }
      }
    } catch (error) {
      print('Error checking favorite status: $error');
    }

    return false;
  }

  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query) && query.isNotEmpty) {
      _searchHistory.add(query);
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _removeFromSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SEARCH_FOOD'] ?? ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'query': query}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          List<Map<String, dynamic>> searchResults =
              List<Map<String, dynamic>>.from(result['data']);

          // ตรวจสอบสถานะรายการโปรดสำหรับแต่ละเมนู
          for (var menu in searchResults) {
            menu['isFavorite'] = await checkFavoriteStatus(menu['menu_id']);
          }

          setState(() {
            _searchResults = searchResults;
            _saveSearchHistory(
                query); // Save search history only if results are found
          });
        } else {
          _showSnackBar('ไม่พบผลลัพธ์การค้นหา');
          setState(() {
            _searchResults = [];
          });
        }
      } else {
        _showSnackBar('การค้นหาล้มเหลว');
      }
    } catch (error) {
      _showSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print('Error fetching food data: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(context),
            SizedBox(height: 16.0),
            _buildSearchHistory(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 24.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/bg7.png'), // Background image
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
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true); // ส่งค่า true กลับไปยังหน้าก่อนหน้า
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
                        hintText: 'ค้นหาเมนูอาหาร',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.black),
                    onPressed: () {
                      _performSearch(_searchController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) return Container();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ประวัติการค้นหา',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: Text('ล้างประวัติ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _searchHistory.map((query) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
                child: Chip(
                  label: Text(
                    query,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4.0,
                  shadowColor: Colors.black.withOpacity(0.2),
                  deleteIcon: Icon(Icons.close, color: Colors.redAccent),
                  onDeleted: () async {
                    await _removeFromSearchHistory(query);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบผลการค้นหา',
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        final imageUrl = food['image_url'];
        final proxyUrl =
            '${dotenv.env['PROXY_URL'] ?? ''}?url=${Uri.encodeComponent(imageUrl)}';

        return GestureDetector(
          onTap: () {
            // การเปิดหน้า MenuDetailsPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuDetailsPage(menuId: food['menu_id']),
              ),
            ).then((result) {
              if (result == true) {
                // รีเฟรชข้อมูลถ้าผลลัพธ์เป็น true
                _fetchInitialMenu(); // หรือฟังก์ชันใดที่ใช้ในการรีเฟรชข้อมูล
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(
                bottom: 16.0), // Add margin at the bottom to create space
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6.0,
                  offset: Offset(0, 4), // Shadow for the grid items
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12.0)),
                          image: DecorationImage(
                            image: NetworkImage(proxyUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Icon(
                          food['isFavorite'] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      8.0, 8.0, 8.0, 16.0), // Increase bottom padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        food['menu_name'] ?? 'ชื่อเมนู',
                        style: TextStyle(
                          fontSize: 14.0, // Font size for the menu name
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'ประเภท: ${food['category_name'] ?? 'ไม่ระบุ'}',
                        style: TextStyle(
                          fontSize: 12.0, // Font size for the category
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
