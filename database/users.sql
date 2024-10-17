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

 Date: 23/09/2024 18:56:31
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `tel` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `gender` enum('ชาย','หญิง') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `birthday` date NULL DEFAULT NULL,
  `height` int NULL DEFAULT NULL,
  `weight` double NULL DEFAULT NULL,
  `image_url` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'user1@example.com', 'password1', 'User One', '0800000001', 'ชาย', '2024-08-23', 170, 70, NULL, '2024-08-21 18:45:44');
INSERT INTO `users` VALUES (2, 'user2@example.com', 'password2', 'User Two', '0800000002', 'หญิง', '2024-08-05', 160, 55, NULL, '2024-08-21 18:45:44');
INSERT INTO `users` VALUES (3, 'user3@example.com', 'password3', 'User Three', '0800000003', 'ชาย', '2024-08-02', 175, 80, NULL, '2024-08-21 18:45:44');
INSERT INTO `users` VALUES (35, 'sa@gmail.com', 'Save_123', 'Narongrit014', '0968927876', 'หญิง', '1991-08-23', 167, 62, '', '2024-08-23 22:48:45');
INSERT INTO `users` VALUES (36, 's@gmail.com', 'Save_123', 'FF01', '0823828332', 'หญิง', '2024-08-27', 1566, 50, 'photo_1727021168.png', '2024-08-27 01:29:52');
INSERT INTO `users` VALUES (37, 'ee@gmail.com', 'Save_123', 'NarongritA01', '0737273888', 'ชาย', '2024-09-05', 167, 31, NULL, '2024-09-05 17:20:47');
INSERT INTO `users` VALUES (38, 'test@gmail.com', 'Save_123', 'Narongrit', '0823888388', 'ชาย', '2012-09-05', 156, 43, NULL, '2024-09-05 17:50:53');
INSERT INTO `users` VALUES (39, 'qq@gmail.com', 'Save_123', 'HH', '0621654985', 'หญิง', '2024-09-05', 31, 23, 'photo_1727025692.png', '2024-09-08 20:58:21');
INSERT INTO `users` VALUES (40, 'u@gmail.com', 'Save_123', 'ua', '9773923829', 'หญิง', '2011-09-08', 812, 12, NULL, '2024-09-08 20:59:06');
INSERT INTO `users` VALUES (41, '22@gmail.com', 'Save_123', 'lasm', '0823823888', 'หญิง', '2024-09-08', 23, 23, NULL, '2024-09-08 21:06:56');
INSERT INTO `users` VALUES (42, '23@gmail.com', 'Save_123', '213', '2444444444', 'หญิง', '2024-09-08', 21, 123, NULL, '2024-09-08 21:08:06');
INSERT INTO `users` VALUES (43, 'lala01@gmail.com', 'Save_123', 'LalaMove', '0939999939', 'ชาย', '1999-09-23', 175, 67, 'photo_1727026095.png', '2024-09-23 00:23:03');

SET FOREIGN_KEY_CHECKS = 1;
