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

 Date: 23/09/2024 18:57:41
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for food_categories
-- ----------------------------
DROP TABLE IF EXISTS `food_categories`;
CREATE TABLE `food_categories`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of food_categories
-- ----------------------------
INSERT INTO `food_categories` VALUES (6, 'ผัด', NULL);
INSERT INTO `food_categories` VALUES (7, 'สลัด', NULL);
INSERT INTO `food_categories` VALUES (8, 'แกง', 'อาหารประเภทแกงที่มีรสชาติเข้มข้นและใส่เนื้อสัตว์หรือผักเป็นหลัก');
INSERT INTO `food_categories` VALUES (9, 'ต้ม', 'อาหารประเภทต้มที่มีน้ำซุปและมักมีรสชาติเปรี้ยวหรือเผ็ด');
INSERT INTO `food_categories` VALUES (10, 'น้ำพริก', 'อาหารประเภทน้ำพริกที่ใช้ส่วนผสมจากพริกและเครื่องปรุงท้องถิ่น');
INSERT INTO `food_categories` VALUES (11, 'ยำ/ลาบ', 'อาหารประเภทผสมเครื่องปรุงและเนื้อสัตว์หรือผัก มีรสชาติเผ็ด เปรี้ยว');
INSERT INTO `food_categories` VALUES (12, 'ข้าว/เส้น', 'อาหารประเภทเส้นหรือข้าวที่เสิร์ฟพร้อมน้ำแกงหรือเครื่องเคียง');
INSERT INTO `food_categories` VALUES (13, 'ปิ้ง/ย่าง', 'อาหารที่ปรุงโดยการย่างหรือปิ้งเนื้อสัตว์');
INSERT INTO `food_categories` VALUES (14, 'อาหารหมักดอง', 'อาหารที่ผ่านกระบวนการหมักหรือดองเพื่อให้ได้รสชาติเปรี้ยว');
INSERT INTO `food_categories` VALUES (15, 'ของหวาน/ของทานเล่น', 'ขนมหรือของหวานที่นิยมทานเป็นของว่างในภาคเหนือ');

SET FOREIGN_KEY_CHECKS = 1;
