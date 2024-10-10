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

 Date: 11/10/2024 00:35:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_accounts
-- ----------------------------
DROP TABLE IF EXISTS `admin_accounts`;
CREATE TABLE `admin_accounts`  (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`admin_id`) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin_accounts
-- ----------------------------
INSERT INTO `admin_accounts` VALUES (1, 'password123', 'admin1@example.com', 'John Doe', 'active', '2024-01-01 10:00:00', '2024-01-01 10:00:00');
INSERT INTO `admin_accounts` VALUES (2, 'adminpass456', 'admin2@example.com', 'Jane Smith', 'inactive', '2024-02-15 14:30:00', '2024-02-15 14:30:00');
INSERT INTO `admin_accounts` VALUES (3, 'secure789', 'admin3@example.com', 'Alice Johnson', 'active', '2024-03-20 09:45:00', '2024-03-20 09:45:00');
INSERT INTO `admin_accounts` VALUES (4, 'save123', 'ff@email.com', 'Alice Johnson', 'active', '2024-03-20 09:45:00', '2024-09-25 19:17:28');

SET FOREIGN_KEY_CHECKS = 1;
