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

 Date: 15/07/2024 00:58:53
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสผู้ใช้ (Primary Key)',
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'อีเมล์ (ต้องไม่ซ้ำ)',
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'รหัสผ่าน',
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'ชื่อผู้ใช้',
  `tel` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'เบอร์โทรศัพท์',
  `condition_id` int NULL DEFAULT NULL COMMENT 'รหัสของโรค (Foreign Key)',
  `gender` enum('ชาย','หญิง','อื่นๆ') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'เพศ',
  `age` int NULL DEFAULT NULL COMMENT 'อายุ',
  `height` int NULL DEFAULT NULL COMMENT 'ส่วนสูง',
  `weight` double NULL DEFAULT NULL COMMENT 'น้ำหนัก',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp COMMENT 'สร้างเมื่อวันที่',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'แก้ไขเมื่อวันที่',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `condition FK`(`condition_id` ASC) USING BTREE,
  CONSTRAINT `condition FK` FOREIGN KEY (`condition_id`) REFERENCES `health_conditions` (`condition_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'ตารางเก็บข้อมูลผู้ใช้งานทั่วไป' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'narongrit@gmail.com', 'Save_123', 'เซฟ', '0621653986', 1001, 'ชาย', 19, 168, 62, '2024-07-08 17:54:15', NULL);
INSERT INTO `users` VALUES (2, 'ff@gmail.com', 'Ff_123', '', '', NULL, '', NULL, NULL, NULL, '2024-07-08 20:23:31', NULL);

SET FOREIGN_KEY_CHECKS = 1;
