import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io'; // For handling file images (not needed for web)

class AnalyzeDetailsPage extends StatelessWidget {
  final String dishName; // The result of the analysis (name of the dish)
  final List<String> ingredients; // List of ingredients
  final List<String> diseaseRisks; // List of disease risks
  final Uint8List? webImage; // Image bytes for web
  final File? imageFile; // Image file for non-web platforms

  AnalyzeDetailsPage({
    required this.dishName,
    required this.ingredients, // รับพารามิเตอร์ ingredients
    required this.diseaseRisks, // รับพารามิเตอร์ diseaseRisks
    this.webImage,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 120.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/bg7.png'), // Background image
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite_border,
                                color: Colors.white),
                            onPressed: () {
                              // Implement favorite logic
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          dishName,
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.0),

                // Ingredient Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'วัตถุดิบ',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ingredients.length, // ใช้จำนวนวัตถุดิบ
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Logic for ingredient details
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 10.0,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.asset(
                                    'images/secret_ingredients.png', // Placeholder image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Container(
                                width: 60.0,
                                child: Text(
                                  ingredients[index], // แสดงชื่อวัตถุดิบ
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Additional details about ingredients
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'รายละเอียด',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'รายละเอียดของ $dishName ประกอบด้วยวัตถุดิบหลักๆ คือ ${ingredients.join(', ')}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),

                // Disease Risk Section
                SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'โรคที่เสี่ยง',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // สีแดงสำหรับเน้นโรคที่เสี่ยง
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: diseaseRisks.isEmpty
                        ? [
                            Text(
                              'ไม่พบข้อมูลโรคที่เสี่ยง',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ]
                        : diseaseRisks.map((disease) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '- $disease', // แสดงรายการโรคที่เสี่ยง
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            );
                          }).toList(),
                  ),
                ),

                SizedBox(height: 80.0),
              ],
            ),
          ),
          Stack(
            children: [
              Positioned(
                top: 140.0,
                left: MediaQuery.of(context).size.width / 2 - 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 25.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundImage: webImage != null
                        ? MemoryImage(webImage!) // Web Image
                        : imageFile != null
                            ? FileImage(imageFile!) // Mobile Image
                            : AssetImage('images/secret_ingredients.png')
                                as ImageProvider,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0, // Align the button to the bottom
                left: 16.0,
                right: 16.0,
                child: Container(
                  width: double.infinity,
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: [Color(0xFF59DFAE), Color(0xFF74FF07)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'กลับไปที่หน้าวิเคราะห์',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
