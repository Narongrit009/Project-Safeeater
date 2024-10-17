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

 Date: 23/09/2024 18:56:57
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for meal_photo_history
-- ----------------------------
DROP TABLE IF EXISTS `meal_photo_history`;
CREATE TABLE `meal_photo_history`  (
  `history_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `menu_id` int NOT NULL,
  `is_edible` enum('true','false') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`history_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `food_photo_menu_ibfk_2`(`menu_id` ASC) USING BTREE,
  CONSTRAINT `food_photo_menu_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `food_photo_menu` (`menu_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `meal_photo_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of meal_photo_history
-- ----------------------------
INSERT INTO `meal_photo_history` VALUES (43, 35, 119, 'false', '2024-09-19 19:06:23');
INSERT INTO `meal_photo_history` VALUES (44, 35, 120, 'false', '2024-09-20 00:26:23');
INSERT INTO `meal_photo_history` VALUES (48, 35, 125, 'true', '2024-09-20 03:58:24');
INSERT INTO `meal_photo_history` VALUES (49, 35, 126, 'true', '2024-09-19 13:01:57');
INSERT INTO `meal_photo_history` VALUES (50, 35, 127, 'true', '2024-09-20 13:10:45');
INSERT INTO `meal_photo_history` VALUES (51, 35, 126, 'true', '2024-09-20 19:48:33');
INSERT INTO `meal_photo_history` VALUES (52, 35, 126, 'true', '2024-09-20 19:49:10');
INSERT INTO `meal_photo_history` VALUES (53, 35, 127, 'true', '2024-09-20 19:49:58');
INSERT INTO `meal_photo_history` VALUES (54, 35, 127, 'true', '2024-09-20 19:50:05');
INSERT INTO `meal_photo_history` VALUES (55, 35, 127, 'true', '2024-09-20 19:50:13');
INSERT INTO `meal_photo_history` VALUES (56, 35, 126, 'true', '2024-09-20 19:50:21');
INSERT INTO `meal_photo_history` VALUES (59, 35, 127, 'true', '2024-09-13 19:51:12');
INSERT INTO `meal_photo_history` VALUES (60, 35, 127, 'true', '2023-09-30 19:51:12');
INSERT INTO `meal_photo_history` VALUES (61, 35, 127, 'true', '2024-09-21 19:51:12');
INSERT INTO `meal_photo_history` VALUES (62, 35, 126, 'true', '2024-09-21 03:34:43');
INSERT INTO `meal_photo_history` VALUES (63, 35, 126, 'true', '2024-09-21 03:35:22');
INSERT INTO `meal_photo_history` VALUES (64, 35, 126, 'true', '2024-09-22 21:59:24');
INSERT INTO `meal_photo_history` VALUES (65, 43, 128, 'true', '2024-09-23 00:49:19');

SET FOREIGN_KEY_CHECKS = 1;
