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

 Date: 23/09/2024 18:57:34
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for food_health_relation
-- ----------------------------
DROP TABLE IF EXISTS `food_health_relation`;
CREATE TABLE `food_health_relation`  (
  `relation_id` int NOT NULL AUTO_INCREMENT,
  `menu_id` int NULL DEFAULT NULL,
  `condition_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`relation_id`) USING BTREE,
  INDEX `menu_id`(`menu_id` ASC) USING BTREE,
  INDEX `condition_id`(`condition_id` ASC) USING BTREE,
  CONSTRAINT `food_health_relation_ibfk_1` FOREIGN KEY (`menu_id`) REFERENCES `food_menu` (`menu_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `food_health_relation_ibfk_2` FOREIGN KEY (`condition_id`) REFERENCES `health_conditions` (`condition_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of food_health_relation
-- ----------------------------
INSERT INTO `food_health_relation` VALUES (1, 100001, 2);
INSERT INTO `food_health_relation` VALUES (2, 100001, 3);
INSERT INTO `food_health_relation` VALUES (3, 100001, 4);
INSERT INTO `food_health_relation` VALUES (4, 100002, 1);
INSERT INTO `food_health_relation` VALUES (5, 100002, 2);
INSERT INTO `food_health_relation` VALUES (6, 100002, 3);
INSERT INTO `food_health_relation` VALUES (7, 100003, 1);
INSERT INTO `food_health_relation` VALUES (8, 100003, 2);
INSERT INTO `food_health_relation` VALUES (9, 100003, 4);
INSERT INTO `food_health_relation` VALUES (10, 100004, 2);
INSERT INTO `food_health_relation` VALUES (11, 100004, 3);
INSERT INTO `food_health_relation` VALUES (12, 100004, 4);
INSERT INTO `food_health_relation` VALUES (13, 100006, 2);
INSERT INTO `food_health_relation` VALUES (14, 100007, 2);
INSERT INTO `food_health_relation` VALUES (15, 100007, 3);
INSERT INTO `food_health_relation` VALUES (16, 100007, 4);
INSERT INTO `food_health_relation` VALUES (17, 100008, 3);
INSERT INTO `food_health_relation` VALUES (18, 100008, 4);
INSERT INTO `food_health_relation` VALUES (19, 100009, 4);
INSERT INTO `food_health_relation` VALUES (20, 100010, 3);

SET FOREIGN_KEY_CHECKS = 1;
