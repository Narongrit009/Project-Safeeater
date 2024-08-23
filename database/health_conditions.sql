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

 Date: 20/08/2024 23:00:17
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for health_conditions
-- ----------------------------
DROP TABLE IF EXISTS `health_conditions`;
CREATE TABLE `health_conditions`  (
  `condition_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสของโรค',
  `condition_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'ชื่อของโรค',
  `condition_description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'คำอธิบายเกี่ยวกับโรค',
  `avoid_foods` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'วัตถุดิบที่ไม่ควรรับประทานสำหรับผู้ป่วยโรคนี้',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp COMMENT 'สร้างเมื่อวันที่',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'แก้ไขเมื่อวันที่',
  PRIMARY KEY (`condition_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1006 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'ตารางที่เก็บข้อมูลเกี่ยวกับโรค' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of health_conditions
-- ----------------------------
INSERT INTO `health_conditions` VALUES (1001, 'ไม่มี', '', '', '2024-07-13 18:22:42', '2024-07-13 18:29:36');
INSERT INTO `health_conditions` VALUES (1002, 'โรคเบาหวาน', 'เกิดจากการกินอาหาร หวานจัด หรือกินน้ำตาลมากเกินไป', '', '2024-07-13 18:25:14', '2024-07-13 18:27:01');
INSERT INTO `health_conditions` VALUES (1003, 'โรคความดันโลหิตสูง', 'เกิดจากการกิน อาหารที่มีไขมันสูง และความเครียดสะสม', '', '2024-07-13 18:27:15', NULL);
INSERT INTO `health_conditions` VALUES (1004, 'โรคไต', 'เกิดจากการกินอาหารสเค็มจัด หรือการกินอาหารที่มีโซเดียมสูงต่อเนื่องเป็นระยะ เวลานาน', '', '2024-07-13 18:27:38', '2024-07-13 18:28:05');
INSERT INTO `health_conditions` VALUES (1005, 'โรคหลอดเลือดสมอง', 'เกิดจากการ รับประทานอาหารที่มีไขมันมากเกินไป และการ ดื่มสุราด้วย\r\nอุดตัน ของไขมันในเลือด', '', '2024-07-13 18:29:26', NULL);

SET FOREIGN_KEY_CHECKS = 1;
