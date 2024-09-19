/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 100428 (10.4.28-MariaDB)
 Source Host           : localhost:3306
 Source Schema         : safe_eat

 Target Server Type    : MySQL
 Target Server Version : 100428 (10.4.28-MariaDB)
 File Encoding         : 65001

 Date: 20/09/2024 04:04:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for food_menu
-- ----------------------------
DROP TABLE IF EXISTS `food_menu`;
CREATE TABLE `food_menu`  (
  `menu_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสเมนู (Primary Key)',
  `menu_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'ชื่อเมนู',
  `category_id` int NULL DEFAULT NULL,
  `health_menu_recommend` int NULL DEFAULT NULL,
  `image_url` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'ลิ้งรูปภาพ',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp COMMENT 'สร้างเมื่อวันที่',
  PRIMARY KEY (`menu_id`) USING BTREE,
  INDEX `fk_category`(`category_id` ASC) USING BTREE,
  INDEX `fk_health_menu`(`health_menu_recommend` ASC) USING BTREE,
  CONSTRAINT `fk_category` FOREIGN KEY (`category_id`) REFERENCES `food_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_health_menu` FOREIGN KEY (`health_menu_recommend`) REFERENCES `health_conditions` (`condition_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 100033 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'ตารางเก็บข้อมูลเมนูอาหาร' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of food_menu
-- ----------------------------
INSERT INTO `food_menu` VALUES (100001, 'ไส้อั่ว', 13, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%84%E0%B8%AA%E0%B9%89%E0%B8%AD%E0%B8%B1%E0%B9%88%E0%B8%A7.png', '2024-08-30 16:08:52');
INSERT INTO `food_menu` VALUES (100002, 'แกงฮังเล', 8, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%AE%E0%B8%B1%E0%B8%87%E0%B9%80%E0%B8%A5.png', '2024-08-30 16:09:04');
INSERT INTO `food_menu` VALUES (100003, 'ข้าวซอย', 12, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%82%E0%B9%89%E0%B8%B2%E0%B8%A7%E0%B8%8B%E0%B8%AD%E0%B8%A2.png', '2024-08-30 16:09:16');
INSERT INTO `food_menu` VALUES (100004, 'น้ำพริกอ่อง', 10, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%99%E0%B9%89%E0%B8%B3%E0%B8%9E%E0%B8%A3%E0%B8%B4%E0%B8%81%E0%B8%AD%E0%B9%88%E0%B8%AD%E0%B8%87.png', '2024-08-30 16:09:25');
INSERT INTO `food_menu` VALUES (100005, 'แกงฟักทอง', 8, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%9F%E0%B8%B1%E0%B8%81%E0%B8%97%E0%B8%AD%E0%B8%87.png', '2024-08-30 16:09:39');
INSERT INTO `food_menu` VALUES (100006, 'จอผักกาด', 9, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%88%E0%B8%AD%E0%B8%9C%E0%B8%B1%E0%B8%81%E0%B8%81%E0%B8%B2%E0%B8%94.png', '2024-08-30 16:09:51');
INSERT INTO `food_menu` VALUES (100007, 'ขนมจีนน้ำเงี้ยว', 12, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%82%E0%B8%99%E0%B8%A1%E0%B8%88%E0%B8%B5%E0%B8%99%E0%B8%99%E0%B9%89%E0%B8%B3%E0%B9%80%E0%B8%87%E0%B8%B5%E0%B9%89%E0%B8%A2%E0%B8%A7.png', '2024-08-30 16:10:06');
INSERT INTO `food_menu` VALUES (100008, 'ลาบหมูคั่ว', 11, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%A5%E0%B8%B2%E0%B8%9A%E0%B8%AB%E0%B8%A1%E0%B8%B9%E0%B8%84%E0%B8%B1%E0%B9%88%E0%B8%A7.png', '2024-08-30 16:11:10');
INSERT INTO `food_menu` VALUES (100009, 'แกงอ่อมไก่', 8, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%AD%E0%B9%88%E0%B8%AD%E0%B8%A1%E0%B9%84%E0%B8%81%E0%B9%88.png', '2024-08-30 16:11:21');
INSERT INTO `food_menu` VALUES (100010, 'แกงหน่อไม้', 8, NULL, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%AB%E0%B8%99%E0%B9%88%E0%B8%AD%E0%B9%84%E0%B8%A1%E0%B9%89.png', '2024-08-30 16:11:27');
INSERT INTO `food_menu` VALUES (100012, 'สลัดผัก', 7, 1, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%AA%E0%B8%A5%E0%B8%B1%E0%B8%94%E0%B8%9C%E0%B8%B1%E0%B8%81.png', '2024-09-09 16:55:56');
INSERT INTO `food_menu` VALUES (100013, 'แกงจืดเต้าหู้', 9, 1, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%88%E0%B8%B7%E0%B8%94%E0%B9%80%E0%B8%95%E0%B9%89%E0%B8%B2%E0%B8%AB%E0%B8%B9%E0%B9%89.png', '2024-09-09 16:55:56');
INSERT INTO `food_menu` VALUES (100014, 'ปลานึ่งมะนาว', 13, 1, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%9B%E0%B8%A5%E0%B8%B2%E0%B8%99%E0%B8%B6%E0%B9%88%E0%B8%87%E0%B8%A1%E0%B8%B0%E0%B8%99%E0%B8%B2%E0%B8%A7.png', '2024-09-09 16:55:56');
INSERT INTO `food_menu` VALUES (100015, 'ผัดผักรวม', 6, 1, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%9C%E0%B8%B1%E0%B8%94%E0%B8%9C%E0%B8%B1%E0%B8%81%E0%B8%A3%E0%B8%A7%E0%B8%A1.png', '2024-09-09 16:55:56');
INSERT INTO `food_menu` VALUES (100016, 'ต้มยำปลาน้ำใส', 9, 1, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%95%E0%B9%89%E0%B8%A1%E0%B8%A2%E0%B8%B3%E0%B8%9B%E0%B8%A5%E0%B8%B2%E0%B8%99%E0%B9%89%E0%B8%B3%E0%B9%83%E0%B8%AA.png', '2024-09-09 16:55:56');
INSERT INTO `food_menu` VALUES (100017, 'ปลานึ่งซีอิ๊ว', 13, 2, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%9B%E0%B8%A5%E0%B8%B2%E0%B8%99%E0%B8%B6%E0%B9%88%E0%B8%87%E0%B8%8B%E0%B8%B5%E0%B8%AD%E0%B8%B4%E0%B9%8A%E0%B8%A7.png', '2024-09-09 16:56:15');
INSERT INTO `food_menu` VALUES (100018, 'สลัดผักผลไม้', 7, 2, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%AA%E0%B8%A5%E0%B8%B1%E0%B8%94%E0%B8%9C%E0%B8%B1%E0%B8%81%E0%B8%9C%E0%B8%A5%E0%B9%84%E0%B8%A1%E0%B9%89.png', '2024-09-09 16:56:15');
INSERT INTO `food_menu` VALUES (100020, 'ไก่ย่างสมุนไพร', 13, 2, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%84%E0%B8%81%E0%B9%88%E0%B8%A2%E0%B9%88%E0%B8%B2%E0%B8%87%E0%B8%AA%E0%B8%A1%E0%B8%B8%E0%B8%99%E0%B9%84%E0%B8%9E%E0%B8%A3.png', '2024-09-09 16:56:15');
INSERT INTO `food_menu` VALUES (100021, 'ซุปผักโขม', 9, 2, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%8B%E0%B8%B8%E0%B8%9B%E0%B8%9C%E0%B8%B1%E0%B8%94%E0%B9%82%E0%B8%82%E0%B8%A1.png', '2024-09-09 16:56:15');
INSERT INTO `food_menu` VALUES (100022, 'แกงจืดตำลึง', 9, 3, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%88%E0%B8%B7%E0%B9%80%E0%B8%95%E0%B8%B3%E0%B8%A5%E0%B8%B6%E0%B8%87.png', '2024-09-09 16:56:24');
INSERT INTO `food_menu` VALUES (100024, 'ต้มยำปลานิลน้ำใส', 9, 3, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%95%E0%B9%89%E0%B8%A1%E0%B8%A2%E0%B8%B3%E0%B8%9B%E0%B8%A5%E0%B8%99%E0%B8%B4%E0%B8%A5.png', '2024-09-09 16:56:24');
INSERT INTO `food_menu` VALUES (100025, 'ผัดผักบล็อคโคลี่กับเห็ดหอม', 6, 3, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%9C%E0%B8%B1%E0%B8%94%E0%B8%9C%E0%B8%B1%E0%B8%81%E0%B8%9A%E0%B8%A5%E0%B9%87%E0%B8%AD%E0%B8%84%E0%B9%82%E0%B8%84%E0%B8%A5%E0%B8%B5%E0%B9%88%E0%B8%81%E0%B8%B1%E0%B8%9A%E0%B9%80%E0%B8%AB%E0%B9%87%E0%B8%94%E0%B8%AB%E0%B8%AD%E0%B8%A1.png', '2024-09-09 16:56:24');
INSERT INTO `food_menu` VALUES (100026, 'ข้าวต้มปลา', 9, 3, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%82%E0%B9%89%E0%B8%B2%E0%B8%A7%E0%B8%95%E0%B9%89%E0%B8%A1%E0%B8%9B%E0%B8%A5%E0%B8%B2.png', '2024-09-09 16:56:24');
INSERT INTO `food_menu` VALUES (100027, 'แกงเลียง', 9, 4, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B9%81%E0%B8%81%E0%B8%87%E0%B9%80%E0%B8%A5%E0%B8%B5%E0%B8%A2%E0%B8%87.png', '2024-09-09 16:56:32');
INSERT INTO `food_menu` VALUES (100028, 'สลัดผักใบเขียว', 7, 4, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%AA%E0%B8%A5%E0%B8%B1%E0%B8%94%E0%B8%9C%E0%B8%B1%E0%B8%94%E0%B9%83%E0%B8%9A%E0%B9%80%E0%B8%82%E0%B8%B5%E0%B8%A2%E0%B8%A7.png', '2024-09-09 16:56:32');
INSERT INTO `food_menu` VALUES (100029, 'ต้มยำเห็ดน้ำใส', 9, 4, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%95%E0%B9%89%E0%B8%A1%E0%B8%A2%E0%B8%B3%E0%B9%80%E0%B8%AB%E0%B9%87%E0%B8%94%E0%B8%99%E0%B9%89%E0%B8%B3%E0%B9%83%E0%B8%AA.png', '2024-09-09 16:56:32');
INSERT INTO `food_menu` VALUES (100031, 'ปลาเผาเกลือ', 13, 4, 'https://student.crru.ac.th/641463014/safeeater/image-food_menu/%E0%B8%9B%E0%B8%A5%E0%B8%B2%E0%B9%80%E0%B8%9C%E0%B8%B2%E0%B9%80%E0%B8%81%E0%B8%A5%E0%B8%B7%E0%B8%AD.png', '2024-09-09 16:56:32');

SET FOREIGN_KEY_CHECKS = 1;
