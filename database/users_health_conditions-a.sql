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

 Date: 23/08/2024 14:49:24
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users_health_conditions
-- ----------------------------
DROP TABLE IF EXISTS `users_health_conditions`;
CREATE TABLE `users_health_conditions`  (
  `user_id` int NOT NULL,
  `condition_id` int NOT NULL,
  PRIMARY KEY (`user_id`, `condition_id`) USING BTREE,
  INDEX `condition_id`(`condition_id` ASC) USING BTREE,
  CONSTRAINT `users_health_conditions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `users_health_conditions_ibfk_2` FOREIGN KEY (`condition_id`) REFERENCES `health_conditions` (`condition_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users_health_conditions
-- ----------------------------
INSERT INTO `users_health_conditions` VALUES (1, 1);
INSERT INTO `users_health_conditions` VALUES (1, 2);
INSERT INTO `users_health_conditions` VALUES (2, 2);
INSERT INTO `users_health_conditions` VALUES (3, 3);

SET FOREIGN_KEY_CHECKS = 1;
