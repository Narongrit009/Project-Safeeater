import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class UserProfileStep1 extends StatefulWidget {
  @override
  _UserProfileStep1State createState() => _UserProfileStep1State();
}

class _UserProfileStep1State extends State<UserProfileStep1> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateButtonState);
    _usernameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isNextButtonEnabled = _usernameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              // Background Container
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('images/bg7.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16.0, 50.0, 16.0, 14.0), // Left, Top, Right, Bottom
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 32.0), // Space for the background image
                    _buildHeader(),
                    SizedBox(height: 32.0),
                    _buildTextField('ชื่อผู้ใช้งาน', _usernameController),
                    SizedBox(height: 32.0),
                    _buildNextButton(context, 'ต่อไป',
                        UserProfileStep2(username: _usernameController.text)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 12.0),
        Text(
          'กรอกข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.0), // Space between the two lines of text
        Text(
          'กรุณากรอกข้อมูลเพื่อใช้งานแอปพลิเคชัน',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 14.0,
            fontWeight: FontWeight.normal, // Normal font weight
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black), // Set label color to black
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      style: TextStyle(color: Colors.black), // Set text color to black
    );
  }

  Widget _buildNextButton(
      BuildContext context, String text, Widget nextScreen) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: _isNextButtonEnabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => nextScreen),
                );
              }
            : null, // Disable button if _isNextButtonEnabled is false
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: _isNextButtonEnabled
              ? Colors.blue
              : Colors.grey, // Change button color based on enable state
          elevation: 4.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}

class UserProfileStep2 extends StatefulWidget {
  final String username; // รับค่าจาก Step1

  UserProfileStep2({required this.username});

  @override
  _UserProfileStep2State createState() => _UserProfileStep2State();
}

class _UserProfileStep2State extends State<UserProfileStep2> {
  final List<TextEditingController> _foodAllergyControllers = [];
  final List<TextEditingController> _chronicDiseaseControllers = [];
  List<String> _healthConditions = [];
  String? _selectedCondition;
  Map<int, List<String>> _foodSuggestionsMap = {};

  @override
  void initState() {
    super.initState();
    _fetchHealthConditions();
    _addFoodAllergyField();
    _addChronicDiseaseField();
  }

  Future<void> _fetchHealthConditions() async {
    String url = dotenv.get('API_URL_DROPDOWN_CONDITION');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _healthConditions =
            data.map((item) => item['condition_name'] as String).toList();
        if (_healthConditions.isNotEmpty) {
          _selectedCondition = _healthConditions.first;
        }
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> _fetchFoodSuggestions(String query, int index) async {
    String url1 = dotenv.get('API_URL_SHOW_NUTRITION');
    final response = await http.get(Uri.parse(url1));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> suggestions = data
          .map((item) => item['ingredient_name'] as String)
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _foodSuggestionsMap[index] = suggestions;
      });
    } else {
      print('Failed to load data');
    }
  }

  void _onFoodAllergyChanged(String query, int index) {
    if (query.isNotEmpty) {
      _fetchFoodSuggestions(query, index);
    } else {
      setState(() {
        _foodSuggestionsMap.remove(index);
      });
    }
  }

  void _onChronicDiseaseChanged(String? newValue, int index) {
    setState(() {
      _chronicDiseaseControllers[index].text = newValue ?? '';
    });
  }

  void _addFoodAllergyField() {
    setState(() {
      _foodAllergyControllers.add(TextEditingController());
    });
  }

  void _addChronicDiseaseField() {
    setState(() {
      _chronicDiseaseControllers.add(TextEditingController());
      _chronicDiseaseControllers.last.text = _selectedCondition ?? '';
    });
  }

  void _onSuggestionSelected(String suggestion, int index) {
    setState(() {
      _foodAllergyControllers[index].text = suggestion;
      _foodSuggestionsMap.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('images/bg7.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 32.0),
                    _buildHeader(),
                    SizedBox(height: 32.0),
                    _buildFoodAllergyFields(),
                    SizedBox(height: 16.0),
                    _buildChronicDiseaseFields(),
                    SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBackButton(context),
                        _buildNextButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 12.0),
        Text(
          'กรอกข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.0),
        Text(
          'กรุณากรอกข้อมูลเพื่อใช้งานแอปพลิเคชัน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFoodAllergyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แพ้อาหาร',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        ..._foodAllergyControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'กรอกชื่ออาหารที่แพ้',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addFoodAllergyField,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onChanged: (query) => _onFoodAllergyChanged(query, index),
              ),
              if (_foodSuggestionsMap.containsKey(index))
                _buildSuggestions(_foodSuggestionsMap[index]!, index),
              SizedBox(height: 16.0),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildChronicDiseaseFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'โรคประจำตัว',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        ..._chronicDiseaseControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: controller.text.isNotEmpty ? controller.text : null,
                items: _healthConditions
                    .take(5) // จำกัดรายการที่แสดงให้เหลือเพียง 5 รายการ
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        ))
                    .toList(),
                onChanged: (newValue) =>
                    _onChronicDiseaseChanged(newValue, index),
                decoration: InputDecoration(
                  hintText: 'เลือกโรคประจำตัว',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addChronicDiseaseField,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              SizedBox(height: 16.0),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSuggestions(List<String> suggestions, int index) {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: suggestions
            .take(5) // จำกัดรายการที่แสดงให้เหลือเพียง 5 รายการ
            .map((suggestion) => ListTile(
                  title: Text(suggestion),
                  onTap: () => _onSuggestionSelected(suggestion, index),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.grey,
        elevation: 4.0,
      ),
      child: Text(
        'ย้อนกลับ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // รวบรวมข้อมูลจาก Step 2
        List<String> foodAllergies = _foodAllergyControllers
            .map((controller) =>
                controller.text.isNotEmpty ? controller.text : 'ไม่มี')
            .toList();
        List<String> chronicDiseases = _chronicDiseaseControllers
            .map((controller) =>
                controller.text.isNotEmpty ? controller.text : 'ไม่มี')
            .toList();

        // ถ้ารายการ foodAllergies หรือ chronicDiseases ว่าง ให้เพิ่มค่า 'ไม่มี'
        if (foodAllergies.isEmpty) {
          foodAllergies.add('ไม่มี');
        }
        if (chronicDiseases.isEmpty) {
          chronicDiseases.add('ไม่มี');
        }

        // ส่งข้อมูลไปยัง Step 3
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileStep3(
              username: widget.username,
              foodAllergies: foodAllergies,
              chronicDiseases: chronicDiseases,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.blue, // Set the button color to blue
        elevation: 4.0,
      ),
      child: Text(
        'ต่อไป',
        style: TextStyle(
          color: Colors.white, // Set the text color to white
          fontSize: 18.0,
        ),
      ),
    );
  }
}

class UserProfileStep3 extends StatefulWidget {
  final String username; // รับค่าจาก Step ก่อนหน้า
  final List<String> foodAllergies;
  final List<String> chronicDiseases;

  UserProfileStep3({
    required this.username,
    required this.foodAllergies,
    required this.chronicDiseases,
  });

  @override
  _UserProfileStep3State createState() => _UserProfileStep3State();
}

class _UserProfileStep3State extends State<UserProfileStep3> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  String? _email; // เก็บ email ที่ดึงมาจาก LocalStorage

  bool _isSubmitButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_updateButtonState);
    _weightController.addListener(_updateButtonState);
    _loadEmailFromLocalStorage(); // ดึง email จาก LocalStorage
  }

  @override
  void dispose() {
    _heightController.removeListener(_updateButtonState);
    _weightController.removeListener(_updateButtonState);
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isSubmitButtonEnabled = _heightController.text.isNotEmpty &&
          _weightController.text.isNotEmpty &&
          _selectedDate != null &&
          _selectedGender != null &&
          _email != null; // ตรวจสอบว่ามี email หรือไม่
    });
  }

  Future<void> _loadEmailFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email'); // ดึง email ที่บันทึกไว้
    });
    _updateButtonState(); // อัปเดตสถานะปุ่มยืนยัน
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('images/bg7.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 32.0),
                    _buildHeader(),
                    SizedBox(height: 32.0),
                    _buildTextField('ส่วนสูง (เซนติเมตร)', _heightController),
                    SizedBox(height: 16.0),
                    _buildTextField('น้ำหนัก (กิโลกรัม)', _weightController),
                    SizedBox(height: 16.0),
                    _buildDateField('วันเกิด'),
                    SizedBox(height: 16.0),
                    _buildGenderField('เพศ'),
                    SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBackButton(context),
                        _buildSubmitButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 12.0),
        Text(
          'กรอกข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.0),
        Text(
          'กรุณากรอกข้อมูลเพื่อใช้งานแอปพลิเคชัน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'[0-9]')), // Allow only digits
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildDateField(String label) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          controller: TextEditingController(
            text: _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : '',
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _updateButtonState(); // Update button state after date selection
      });
    }
  }

  Widget _buildGenderField(String label) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ['ชาย', 'หญิง'].map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGender = newValue;
          _updateButtonState(); // Update button state after gender selection
        });
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.grey,
        elevation: 4.0,
      ),
      child: Text(
        'ย้อนกลับ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSubmitButtonEnabled
          ? () {
              _submitUserData(); // เรียกใช้ฟังก์ชัน _submitUserData ที่นี่
            }
          : null, // Disable button if _isSubmitButtonEnabled is false
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: _isSubmitButtonEnabled
            ? Colors.blue
            : Colors.grey, // Change button color based on enable state
        elevation: 4.0,
      ),
      child: Text(
        'ยืนยัน',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Future<void> _submitUserData() async {
    String apiUrl = dotenv.get('API_URL_INSERT_USER_DATA');

    // จัดรูปแบบวันที่เป็น yyyy-mm-dd
    String? formattedDate = _selectedDate != null
        ? '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : null;

    // สร้างข้อมูลที่จะส่งไปยัง API
    Map<String, dynamic> userData = {
      'email': _email, // แทนที่ _email ด้วยค่าที่ได้จาก LocalStorage
      'username': widget.username,
      'food_allergies': widget.foodAllergies,
      'chronic_diseases': widget.chronicDiseases,
      'height': _heightController.text,
      'weight': _weightController.text,
      'birth_date': formattedDate,
      'gender': _selectedGender
    };

    // Debug: แสดงข้อมูลที่ถูกส่งไปยัง API
    print('Sending data to API:');
    print('API URL: $apiUrl');
    print('Data: ${jsonEncode(userData)}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'animations/correct.json',
                    width: 200,
                    height: 200,
                    repeat: false,
                    reverse: false,
                    animate: true,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'บันทึกข้อมูลเรียบร้อย',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์')),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }
}
