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

 Date: 23/09/2024 18:56:23
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users_allergies
-- ----------------------------
DROP TABLE IF EXISTS `users_allergies`;
CREATE TABLE `users_allergies`  (
  `user_id` int NOT NULL,
  `nutrition_id` int NOT NULL,
  INDEX `fk_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_nutrition`(`nutrition_id` ASC) USING BTREE,
  CONSTRAINT `fk_nutrition` FOREIGN KEY (`nutrition_id`) REFERENCES `nutritional_information` (`ingredient_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users_allergies
-- ----------------------------
INSERT INTO `users_allergies` VALUES (36, 1104);
INSERT INTO `users_allergies` VALUES (37, 1463);
INSERT INTO `users_allergies` VALUES (38, 1181);
INSERT INTO `users_allergies` VALUES (38, 1420);
INSERT INTO `users_allergies` VALUES (40, 1000);
INSERT INTO `users_allergies` VALUES (41, 1000);
INSERT INTO `users_allergies` VALUES (42, 1000);
INSERT INTO `users_allergies` VALUES (35, 1449);
INSERT INTO `users_allergies` VALUES (39, 1000);
INSERT INTO `users_allergies` VALUES (43, 1000);

SET FOREIGN_KEY_CHECKS = 1;
