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

 Date: 20/09/2024 04:05:26
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
INSERT INTO `users_health_conditions` VALUES (35, 0);
INSERT INTO `users_health_conditions` VALUES (36, 3);
INSERT INTO `users_health_conditions` VALUES (37, 0);
INSERT INTO `users_health_conditions` VALUES (38, 2);
INSERT INTO `users_health_conditions` VALUES (40, 1);
INSERT INTO `users_health_conditions` VALUES (41, 0);
INSERT INTO `users_health_conditions` VALUES (42, 0);

SET FOREIGN_KEY_CHECKS = 1;
