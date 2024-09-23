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

 Date: 23/09/2024 18:57:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for meal_history
-- ----------------------------
DROP TABLE IF EXISTS `meal_history`;
CREATE TABLE `meal_history`  (
  `history_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `menu_id` int NOT NULL,
  `is_edible` enum('true','false') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `meal_time` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`history_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `menu_id`(`menu_id` ASC) USING BTREE,
  CONSTRAINT `meal_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `meal_history_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `food_menu` (`menu_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 900067 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of meal_history
-- ----------------------------
INSERT INTO `meal_history` VALUES (900028, 35, 100003, 'false', '2024-09-09 00:57:56');
INSERT INTO `meal_history` VALUES (900038, 35, 100018, 'true', '2024-09-10 15:46:50');
INSERT INTO `meal_history` VALUES (900039, 35, 100012, 'true', '2024-09-10 15:47:00');
INSERT INTO `meal_history` VALUES (900041, 35, 100016, 'false', '2024-09-10 15:54:43');
INSERT INTO `meal_history` VALUES (900043, 35, 100014, 'true', '2024-09-14 01:21:32');
INSERT INTO `meal_history` VALUES (900047, 35, 100013, 'true', '2024-09-15 17:35:52');
INSERT INTO `meal_history` VALUES (900048, 36, 100012, 'true', '2024-09-17 22:40:23');
INSERT INTO `meal_history` VALUES (900049, 36, 100025, 'true', '2024-09-17 22:41:03');
INSERT INTO `meal_history` VALUES (900056, 36, 100022, 'true', '2024-09-17 23:20:43');
INSERT INTO `meal_history` VALUES (900057, 35, 100015, 'true', '2024-09-18 02:08:48');
INSERT INTO `meal_history` VALUES (900059, 35, 100012, 'true', '2024-09-19 13:08:19');
INSERT INTO `meal_history` VALUES (900060, 35, 100004, 'false', '2024-09-20 03:29:36');
INSERT INTO `meal_history` VALUES (900061, 35, 100013, 'true', '2024-09-20 03:38:07');
INSERT INTO `meal_history` VALUES (900062, 35, 100018, 'true', '2024-09-22 22:00:01');
INSERT INTO `meal_history` VALUES (900065, 43, 100020, 'true', '2024-09-23 00:45:16');
INSERT INTO `meal_history` VALUES (900066, 43, 100012, 'true', '2024-09-23 00:45:49');

SET FOREIGN_KEY_CHECKS = 1;
