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

 Date: 23/09/2024 18:57:12
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for health_conditions
-- ----------------------------
DROP TABLE IF EXISTS `health_conditions`;
CREATE TABLE `health_conditions`  (
  `condition_id` int NOT NULL AUTO_INCREMENT,
  `condition_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `condition_description` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`condition_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of health_conditions
-- ----------------------------
INSERT INTO `health_conditions` VALUES (0, 'ไม่มี', NULL, '2024-08-21 18:49:56');
INSERT INTO `health_conditions` VALUES (1, 'โรคเบาหวาน', 'เกิดจากการกินอาหาร หวานจัด หรือกินน้ำตาลมากเกินไป', '2024-08-21 18:46:07');
INSERT INTO `health_conditions` VALUES (2, 'โรคความดันโลหิตสูง', 'เกิดจากการกิน อาหารที่มีไขมันสูง', '2024-08-21 18:46:07');
INSERT INTO `health_conditions` VALUES (3, 'โรคไต', 'เกิดจากการกินอาหารสเค็มจัด หรือการกินอาหารที่มีโซเดียมสูงต่อเนื่องเป็นระยะเวลานาน', '2024-08-21 18:46:07');
INSERT INTO `health_conditions` VALUES (4, 'โรคหัวใจและหลอดเลือด', 'เกิดจากอาหารที่มีไขมันอิ่มตัวและไขมันทรานส์สูง', '2024-08-21 18:49:24');

SET FOREIGN_KEY_CHECKS = 1;
