import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditDataProfile extends StatefulWidget {
  final String email;

  const EditDataProfile({Key? key, required this.email}) : super(key: key);

  @override
  _EditDataProfileState createState() => _EditDataProfileState();
}

class _EditDataProfileState extends State<EditDataProfile> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;
  List<String> selectedConditions = [];
  List<String> selectedAllergies = [];
  List<String> allConditions = [];
  List<String> allAllergies = [];
  List<String> filteredAllergies = [];
  TextEditingController allergyController = TextEditingController();

  File? _profileImage;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchConditions();
    _fetchAllergies();
  }

  Future<void> _pickImageFromFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImage = result.files.first.bytes;
          _profileData['profile_image_name'] = result.files.first.name;
        });
      } else {
        setState(() {
          _profileImage = File(result.files.single.path!);
          _profileData['profile_image_name'] = result.files.single.name;
        });
      }
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _profileImage = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _fetchProfileData() async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL_SHOW_PROFILE_LOGIN'] ?? ''),
        body: jsonEncode(<String, String>{'email': widget.email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(response.body)['data'];

          // Explicitly convert dynamic list to List<String> and split by ", "
          selectedConditions = List<String>.from(
              (_profileData['chronic_diseases'] ?? '')
                  .split(', ')
                  .map((e) => e.trim()));
          selectedAllergies = List<String>.from(
              (_profileData['food_allergies'] ?? '')
                  .split(', ')
                  .map((e) => e.trim()));

          _isLoading = false;
        });
      } else {
        print('Failed to load profile data');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _fetchConditions() async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['API_URL_DROPDOWN_CONDITION'] ?? ''),
      );

      if (response.statusCode == 200) {
        setState(() {
          allConditions = List<String>.from(
              json.decode(response.body).map((item) => item['condition_name']));
        });
      } else {
        print('Failed to load conditions');
      }
    } catch (error) {
      print('Error fetching conditions: $error');
    }
  }

  Future<void> _fetchAllergies() async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['API_URL_SHOW_NUTRITION'] ?? ''),
      );

      if (response.statusCode == 200) {
        setState(() {
          allAllergies = List<String>.from(json
              .decode(response.body)
              .map((item) => item['ingredient_name']));
          filteredAllergies = []; // Start with an empty list
        });
      } else {
        print('Failed to load allergies');
      }
    } catch (error) {
      print('Error fetching allergies: $error');
    }
  }

  Future<void> _saveProfileData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // บันทึกข้อมูลจากฟอร์ม
      try {
        // สร้าง request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(dotenv.env['API_URL_EDIT_PROFILE'] ?? ''),
        );

        // เพิ่มข้อมูลฟิลด์ปกติ และแปลงค่าทุกฟิลด์เป็น String
        request.fields['email'] = _profileData['email'].toString();
        request.fields['username'] = _profileData['username'].toString();
        request.fields['tel'] = _profileData['tel'].toString();
        request.fields['gender'] = _profileData['gender'].toString();
        request.fields['birthday'] = _profileData['birthday'].toString();
        request.fields['height'] = _profileData['height'].toString();
        request.fields['weight'] = _profileData['weight'].toString();
        request.fields['chronic_diseases'] = selectedConditions.join(', ');
        request.fields['food_allergies'] = selectedAllergies.join(', ');

        // พิมพ์ข้อมูลที่กำลังจะส่งไป (สำหรับการตรวจสอบ)
        print('Sending data:');
        print(request.fields);

        // การอัปโหลดรูปภาพ (ไม่บังคับ)
        if (_profileImage != null) {
          // กรณีมือถือหรือ desktop ที่ใช้ไฟล์จาก local
          print('Uploading image from file: ${_profileImage!.path}');
          request.files.add(await http.MultipartFile.fromPath(
            'photo',
            _profileImage!.path,
          ));
        } else if (_webImage != null) {
          // กรณีเว็บที่ใช้ไฟล์จาก Memory
          print('Uploading web image');
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            _webImage!,
            filename: 'web_image.png', // ตั้งชื่อไฟล์
          ));
        }

        // ส่ง request
        var response = await request.send();

        // ตรวจสอบสถานะการตอบกลับ
        if (response.statusCode == 200) {
          _showSnackBar('แก้ไขข้อมูลเรียบร้อยแล้ว');
          Navigator.pop(context, true);
        } else {
          _showSnackBar('แก้ไขข้อมูลล้มเหลว');
        }
      } catch (e) {
        print('Error uploading profile data: $e');
        _showSnackBar('เกิดข้อผิดพลาดในการอัปโหลด');
      }
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

  String _getFieldValueAsString(String field) {
    var value = _profileData[field];
    if (value is int) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else {
      return '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _profileData['birthday'] = selectedDate.toString().substring(0, 10);
      });
    }
  }

  void _addCondition(String condition) {
    if (!selectedConditions.contains(condition)) {
      setState(() {
        selectedConditions.add(condition);
      });
    }
  }

  void _removeCondition(String condition) {
    setState(() {
      selectedConditions.remove(condition);
    });
  }

  void _addAllergy(String allergy) {
    if (!selectedAllergies.contains(allergy)) {
      setState(() {
        selectedAllergies.add(allergy);
        filteredAllergies.clear(); // Clear the list after selection
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      selectedAllergies.remove(allergy);
    });
  }

  void _filterAllergies(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredAllergies = allAllergies
            .where((allergy) =>
                allergy.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredAllergies.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ทำให้พื้นหลังซ้อนทับกับ Status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildEditableTileWithIcon(
                              'ชื่อผู้ใช้', 'username', TextInputType.text),
                          _buildEditableTileWithValidation(
                              'เบอร์โทรศัพท์',
                              'tel',
                              TextInputType.phone,
                              (value) => value!.length == 10
                                  ? null
                                  : 'กรุณากรอกเบอร์โทรศัพท์ 10 ตัว'),
                          _buildGenderDropdown(),
                          _buildBirthdayPicker(),
                          _buildEditableTileWithValidation(
                              'ส่วนสูง',
                              'height',
                              TextInputType.number,
                              (value) => value!.isNotEmpty &&
                                      int.tryParse(value) != null
                                  ? null
                                  : 'กรุณากรอกส่วนสูงเป็นตัวเลข'),
                          _buildEditableTileWithValidation(
                              'น้ำหนัก',
                              'weight',
                              TextInputType.number,
                              (value) => value!.isNotEmpty &&
                                      int.tryParse(value) != null
                                  ? null
                                  : 'กรุณากรอกน้ำหนักเป็นตัวเลข'),
                          _buildChipList(
                              'โรคประจำตัว',
                              allConditions,
                              selectedConditions,
                              _addCondition,
                              _removeCondition),
                          _buildAllergyField(),
                          SizedBox(height: 20),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
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
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Spacer(),
            ],
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 50.0,
                backgroundImage: _getProfileImage(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImageFromFilePicker,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'คุณ ${_profileData['username'] ?? ''}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            widget.email,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImage != null) {
      // ถ้าผู้ใช้เลือกภาพใหม่จากไฟล์ (มือถือหรือ desktop)
      return FileImage(_profileImage!);
    } else if (_webImage != null) {
      // ถ้าผู้ใช้เลือกภาพใหม่จากไฟล์ (เว็บ)
      return MemoryImage(_webImage!);
    } else if (_profileData['image_url'] != null &&
        _profileData['image_url'].isNotEmpty) {
      // ถ้ามี image_url จากโปรไฟล์
      String imageUrl = _profileData['image_url'];
      // ใช้ proxyUrl ถ้ามีการตั้งค่า PROXY_URL
      String? proxyUrl = dotenv.env['PROXY_URL'] != null &&
              dotenv.env['PROXY_URL']!.isNotEmpty
          ? '${dotenv.env['PROXY_URL']}?url=${Uri.encodeComponent(imageUrl)}'
          : imageUrl;
      return NetworkImage(proxyUrl);
    } else {
      // ถ้าไม่มีภาพใด ๆ ใช้ภาพเริ่มต้นจาก assets
      return AssetImage('images/boy.png');
    }
  }

  Widget _buildEditableTileWithIcon(
      String label, String field, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Background color set to white
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _getFieldValueAsString(field),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
                keyboardType: keyboardType,
                onChanged: (value) {
                  setState(() {
                    _profileData[field] = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกข้อมูล';
                  }
                  return null;
                },
              ),
            ),
            Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTileWithValidation(String label, String field,
      TextInputType keyboardType, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Background color set to white
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          initialValue: _getFieldValueAsString(field),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          keyboardType: keyboardType,
          onChanged: (value) {
            setState(() {
              _profileData[field] = value;
            });
          },
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Background color set to white
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _profileData['gender'],
          decoration: InputDecoration(
            labelText: 'เพศ',
            border: InputBorder.none,
          ),
          items: ['ชาย', 'หญิง'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _profileData['gender'] = newValue;
            });
          },
          validator: (value) => value == null ? 'กรุณาเลือกเพศ' : null,
        ),
      ),
    );
  }

  Widget _buildBirthdayPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white, // Background color set to white
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'วันเกิด',
                border: InputBorder.none,
              ),
              controller: TextEditingController(
                text: _profileData['birthday'] ?? '',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'กรุณาเลือกวันเกิด' : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipList(
    String label,
    List<String> allItems,
    List<String> selectedItems,
    Function(String) onAdd,
    Function(String) onRemove,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedItems.map((item) {
                return Chip(
                  backgroundColor: Colors.lightBlue.shade50,
                  label: Text(
                    item,
                    style: TextStyle(color: Colors.black87),
                  ),
                  deleteIcon: Icon(Icons.close, size: 18.0, color: Colors.red),
                  onDeleted: () => onRemove(item),
                );
              }).toList(),
            ),
            SizedBox(height: 12.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlue.shade50,
                labelText: 'เพิ่ม $label',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.add, color: Colors.blueGrey),
              ),
              items: allItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onAdd(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12.0,
              offset: Offset(0, 6), // Shadow effect below the container
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'อาหารที่แพ้ :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: selectedAllergies.map((item) {
                return Chip(
                  backgroundColor: Colors.lightBlue.shade50,
                  label: Text(
                    item,
                    style: TextStyle(color: Colors.black87),
                  ),
                  deleteIcon: Icon(Icons.close, size: 18.0, color: Colors.red),
                  onDeleted: () => _removeAllergy(item),
                );
              }).toList(),
            ),
            SizedBox(height: 12.0),
            TextFormField(
              controller: allergyController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlue.shade50,
                labelText: 'เพิ่มอาหารที่แพ้',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
              ),
              onChanged: (value) => _filterAllergies(value),
            ),
            if (filteredAllergies.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 12.0,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: filteredAllergies.map((item) {
                    return GestureDetector(
                      onTap: () {
                        _addAllergy(item);
                        allergyController.clear();
                      },
                      child: ListTile(
                        title: Text(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3DBBFE), Color(0xFF197DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _saveProfileData,
          icon: Icon(Icons.save, size: 20.0, color: Colors.white),
          label: Text(
            'บันทึกข้อมูล',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }
}
