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

 Date: 23/08/2024 14:55:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users_allergies
-- ----------------------------
DROP TABLE IF EXISTS `users_allergies`;
CREATE TABLE `users_allergies`  (
  `user_id` int NOT NULL,
  `nutrition_id` int NOT NULL,
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `users_nutrition_ibfk_2`(`nutrition_id` ASC) USING BTREE,
  CONSTRAINT `users_allergies_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `users_nutrition_ibfk_2` FOREIGN KEY (`nutrition_id`) REFERENCES `nutritional_information` (`ingredient_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users_allergies
-- ----------------------------
INSERT INTO `users_allergies` VALUES (1, 1004);
INSERT INTO `users_allergies` VALUES (2, 1065);
INSERT INTO `users_allergies` VALUES (3, 1152);

SET FOREIGN_KEY_CHECKS = 1;
