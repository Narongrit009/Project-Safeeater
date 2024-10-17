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

 Date: 23/09/2024 18:57:55
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for favorite_food
-- ----------------------------
CREATE TABLE `favorite_food` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `food_id` int NULL DEFAULT NULL,
  `menu_id` int NULL DEFAULT NULL,
  `is_favorite` enum('true','false') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_favorite_food_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_favorite_food_food_id`(`food_id` ASC) USING BTREE,
  INDEX `favorite_food_ibfk_3`(`menu_id` ASC) USING BTREE,
  CONSTRAINT `favorite_food_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `favorite_food_ibfk_2` FOREIGN KEY (`food_id`) REFERENCES `food_menu` (`menu_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `favorite_food_ibfk_3` FOREIGN KEY (`menu_id`) REFERENCES `food_photo_menu` (`menu_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=537 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=Dynamic;





-- ----------------------------
-- Records of favorite_food
-- ----------------------------
INSERT INTO `favorite_food` VALUES (500, 35, 100004, NULL, 'true', '2024-09-17 18:20:34', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (501, 35, 100006, NULL, 'true', '2024-09-17 18:20:46', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (502, 35, 100017, NULL, '', '2024-09-17 19:13:14', '2024-09-22 21:28:46');
INSERT INTO `favorite_food` VALUES (503, 35, 100012, NULL, 'true', '2024-09-17 19:43:09', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (504, 35, 100015, NULL, 'true', '2024-09-17 19:52:23', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (505, 35, 100008, NULL, '', '2024-09-17 19:57:15', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (506, 36, 100012, NULL, '', '2024-09-17 22:39:32', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (507, 36, 100025, NULL, 'true', '2024-09-17 22:40:48', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (508, 36, 100022, NULL, 'true', '2024-09-17 22:45:54', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (509, 36, 100006, NULL, '', '2024-09-17 22:57:37', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (510, 36, 100010, NULL, '', '2024-09-17 22:59:31', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (511, 35, 100020, NULL, 'true', '2024-09-18 01:00:25', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (512, 35, 100013, NULL, 'true', '2024-09-18 01:39:39', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (513, 35, 100003, NULL, 'true', '2024-09-18 02:09:10', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (514, 35, 100016, NULL, '', '2024-09-18 02:11:17', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (522, 35, NULL, 106, '', '2024-09-18 21:25:02', '2024-09-20 02:16:22');
INSERT INTO `favorite_food` VALUES (523, 35, NULL, 109, '', '2024-09-19 00:24:28', '2024-09-20 03:59:03');
INSERT INTO `favorite_food` VALUES (528, 35, NULL, 119, 'true', '2024-09-19 23:39:39', '2024-09-20 02:24:13');
INSERT INTO `favorite_food` VALUES (529, 35, NULL, 111, '', '2024-09-20 00:05:09', '2024-09-20 03:58:59');
INSERT INTO `favorite_food` VALUES (530, 35, NULL, 120, '', '2024-09-20 00:26:41', '2024-09-20 03:59:06');
INSERT INTO `favorite_food` VALUES (531, 35, NULL, 125, '', '2024-09-20 03:59:24', '2024-09-20 19:49:52');
INSERT INTO `favorite_food` VALUES (532, 35, NULL, 126, 'true', '2024-09-20 19:48:14', '2024-09-20 19:48:14');
INSERT INTO `favorite_food` VALUES (533, 35, NULL, 127, 'true', '2024-09-20 19:49:42', '2024-09-20 19:49:42');
INSERT INTO `favorite_food` VALUES (534, 39, NULL, 126, 'true', '2024-09-21 22:21:49', '2024-09-21 22:21:49');
INSERT INTO `favorite_food` VALUES (535, 35, 100018, NULL, 'true', '2024-09-22 21:28:43', '2024-09-22 21:28:43');
INSERT INTO `favorite_food` VALUES (536, 43, 100012, NULL, 'true', '2024-09-23 00:48:47', '2024-09-23 00:48:47');

SET FOREIGN_KEY_CHECKS = 1;
