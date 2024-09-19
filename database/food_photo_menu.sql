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

 Date: 20/09/2024 04:04:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for food_photo_menu
-- ----------------------------
DROP TABLE IF EXISTS `food_photo_menu`;
CREATE TABLE `food_photo_menu`  (
  `menu_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `menu_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `ingredient_list` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `disease_list` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `image_url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (`menu_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `food_photo_menu_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 126 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of food_photo_menu
-- ----------------------------
INSERT INTO `food_photo_menu` VALUES (104, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e01\\u0e30\\u0e17\\u0e34\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e21\\u0e35\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726664021.png', '2024-09-18 19:53:41');
INSERT INTO `food_photo_menu` VALUES (106, 35, 'ส้มตำ', '[\" \\u0e21\\u0e30\\u0e25\\u0e30\\u0e01\\u0e2d\",\" \\u0e21\\u0e30\\u0e40\\u0e02\\u0e37\\u0e2d\\u0e40\\u0e17\\u0e28\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e1d\\u0e31\\u0e01\\u0e22\\u0e32\\u0e27\",\" \\u0e41\\u0e04\\u0e23\\u0e2d\\u0e17\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e32\\u0e30  \\u0e2b\\u0e32\\u0e01\\u0e17\\u0e32\\u0e19\\u0e2a\\u0e49\\u0e21\\u0e15\\u0e33\\u0e23\\u0e2a\\u0e08\\u0e31\\u0e14\\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e43\\u0e2a\\u0e48\\u0e1e\\u0e23\\u0e34\\u0e01\\u0e21\\u0e32\\u0e01 \\u0e2d\\u0e32\\u0e08\\u0e23\\u0e30\\u0e04\\u0e32\\u0e22\\u0e40\\u0e04\\u0e37\\u0e2d\\u0e07\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e32\\u0e30\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\",\" \\u0e42\\u0e23\\u0e04\\u0e04\\u0e27\\u0e32\\u0e21\\u0e14\\u0e31\\u0e19\\u0e42\\u0e25\\u0e2b\\u0e34\\u0e15  \\u0e2b\\u0e32\\u0e01\\u0e17\\u0e32\\u0e19\\u0e2a\\u0e49\\u0e21\\u0e15\\u0e33\\u0e17\\u0e35\\u0e48\\u0e21\\u0e35\\u0e23\\u0e2a\\u0e40\\u0e04\\u0e47\\u0e21\\u0e08\\u0e31\\u0e14 \\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e43\\u0e2a\\u0e48\\u0e1b\\u0e25\\u0e32\\u0e23\\u0e49\\u0e32\\u0e21\\u0e32\\u0e01 \\u0e2d\\u0e32\\u0e08\\u0e17\\u0e33\\u0e43\\u0e2b\\u0e49\\u0e04\\u0e27\\u0e32\\u0e21\\u0e14\\u0e31\\u0e19\\u0e42\\u0e25\\u0e2b\\u0e34\\u0e15\\u0e2a\\u0e39\\u0e07\\u0e02\\u0e36\\u0e49\\u0e19\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19 \\u0e2b\\u0e32\\u0e01\\u0e17\\u0e32\\u0e19\\u0e2a\\u0e49\\u0e21\\u0e15\\u0e33\\u0e43\\u0e2a\\u0e48\\u0e40\\u0e04\\u0e23\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e1b\\u0e23\\u0e38\\u0e07\\u0e17\\u0e35\\u0e48\\u0e21\\u0e35\\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\\u0e21\\u0e32\\u0e01 \\u0e2d\\u0e32\\u0e08\\u0e17\\u0e33\\u0e43\\u0e2b\\u0e49\\u0e23\\u0e30\\u0e14\\u0e31\\u0e1a\\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\\u0e43\\u0e19\\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2a\\u0e39\\u0e07\\u0e02\\u0e36\\u0e49\\u0e19\"]', 'photo_35_1726664725.png', '2024-09-18 20:05:25');
INSERT INTO `food_photo_menu` VALUES (107, 35, 'ก๋วยเตี๋ยวเลือดหมู', '[\" \\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e04\\u0e23\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e43\\u0e19\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e2a\\u0e49\\u0e19\\u0e01\\u0e4b\\u0e27\\u0e22\\u0e40\\u0e15\\u0e35\\u0e4b\\u0e22\\u0e27\",\" \\u0e1c\\u0e31\\u0e01\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e1e\\u0e22\\u0e32\\u0e18\\u0e34\",\" \\u0e42\\u0e23\\u0e04\\u0e15\\u0e34\\u0e14\\u0e40\\u0e0a\\u0e37\\u0e49\\u0e2d\",\" \\u0e42\\u0e23\\u0e04\\u0e44\\u0e02\\u0e49\\u0e2b\\u0e27\\u0e31\\u0e14\",\" \\u0e42\\u0e23\\u0e04\\u0e17\\u0e49\\u0e2d\\u0e07\\u0e40\\u0e2a\\u0e35\\u0e22\"]', 'photo_35_1726664857.png', '2024-09-18 20:07:37');
INSERT INTO `food_photo_menu` VALUES (108, 35, 'ข้าวผัดกระเพราหมู', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\" \\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\\u0e02\\u0e35\\u0e49\\u0e2b\\u0e19\\u0e39\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e44\\u0e02\\u0e48\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e21\\u0e35\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726664908.png', '2024-09-18 20:08:28');
INSERT INTO `food_photo_menu` VALUES (109, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e40\\u0e01\\u0e25\\u0e37\\u0e2d\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e21\\u0e35\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726680213.png', '2024-09-19 00:23:33');
INSERT INTO `food_photo_menu` VALUES (110, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e21\\u0e35\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726728812.png', '2024-09-19 13:53:32');
INSERT INTO `food_photo_menu` VALUES (111, 35, 'ส้มตำ', '[\" \\u0e21\\u0e30\\u0e25\\u0e30\\u0e01\\u0e2d\",\" \\u0e21\\u0e30\\u0e40\\u0e02\\u0e37\\u0e2d\\u0e40\\u0e17\\u0e28\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e1d\\u0e31\\u0e01\\u0e22\\u0e32\\u0e27\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\"  \\u0e21\\u0e30\\u0e19\\u0e32\\u0e27\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e40\\u0e1b\\u0e47\\u0e19\\u0e1e\\u0e34\\u0e29  \\u0e40\\u0e19\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e08\\u0e32\\u0e01\\u0e27\\u0e31\\u0e15\\u0e16\\u0e38\\u0e14\\u0e34\\u0e1a\\u0e2a\\u0e14\\u0e41\\u0e25\\u0e30\\u0e2d\\u0e32\\u0e08\\u0e21\\u0e35\\u0e01\\u0e32\\u0e23\\u0e1b\\u0e19\\u0e40\\u0e1b\\u0e37\\u0e49\\u0e2d\\u0e19\\u0e02\\u0e2d\\u0e07\\u0e41\\u0e1a\\u0e04\\u0e17\\u0e35\\u0e40\\u0e23\\u0e35\\u0e22\\u0e44\\u0e14\\u0e49\",\" \\u0e42\\u0e23\\u0e04\\u0e17\\u0e49\\u0e2d\\u0e07\\u0e40\\u0e2a\\u0e35\\u0e22 \\u0e08\\u0e32\\u0e01\\u0e01\\u0e32\\u0e23\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e23\\u0e2a\\u0e08\\u0e31\\u0e14\\u0e41\\u0e25\\u0e30\\u0e40\\u0e1c\\u0e47\\u0e14\\u0e21\\u0e32\\u0e01\\u0e40\\u0e01\\u0e34\\u0e19\\u0e44\\u0e1b\"]', 'photo_35_1726728886.png', '2024-09-19 13:54:46');
INSERT INTO `food_photo_menu` VALUES (112, 35, 'ก๋วยเตี๋ยวเลือดหมู', '[\" \\u0e40\\u0e2a\\u0e49\\u0e19\\u0e01\\u0e4b\\u0e27\\u0e22\\u0e40\\u0e15\\u0e35\\u0e4b\\u0e22\\u0e27\",\" \\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e04\\u0e23\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e43\\u0e19\\u0e2b\\u0e21\\u0e39 \\u0e15\\u0e31\\u0e1a \\u0e44\\u0e2a\\u0e49\",\" \\u0e1c\\u0e31\\u0e01\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e1e\\u0e22\\u0e32\\u0e18\\u0e34\",\" \\u0e42\\u0e23\\u0e04\\u0e15\\u0e34\\u0e14\\u0e40\\u0e0a\\u0e37\\u0e49\\u0e2d\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19 \\u0e16\\u0e49\\u0e32\\u0e1b\\u0e23\\u0e38\\u0e07\\u0e23\\u0e2a\\u0e2b\\u0e27\\u0e32\\u0e19\",\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19 \\u0e16\\u0e49\\u0e32\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\"]', 'photo_35_1726731584.png', '2024-09-19 14:39:44');
INSERT INTO `food_photo_menu` VALUES (113, 35, 'ข้าวผัดกระเพราหมู', '[\" \\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\" \\u0e44\\u0e02\\u0e48\\u0e14\\u0e32\\u0e27\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726737324.png', '2024-09-19 16:15:24');
INSERT INTO `food_photo_menu` VALUES (114, 35, 'ข้าวผัดกระเพรา', '[\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e0b\\u0e35\\u0e2d\\u0e34\\u0e4a\\u0e27\\u0e02\\u0e32\\u0e27\",\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\" \\u0e44\\u0e02\\u0e48\",\"(\\u0e41\\u0e1e\\u0e49) \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726746248.png', '2024-09-19 18:44:08');
INSERT INTO `food_photo_menu` VALUES (115, 35, 'ข้าวผัดกระเพราหมู', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\",\" \\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e44\\u0e02\\u0e48\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e04\\u0e27\\u0e32\\u0e21\\u0e14\\u0e31\\u0e19\\u0e42\\u0e25\\u0e2b\\u0e34\\u0e15\\u0e2a\\u0e39\\u0e07 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e2b\\u0e31\\u0e27\\u0e43\\u0e08 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e44\\u0e15 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e01\\u0e32\\u0e15\\u0e4c \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e43\\u0e19\\u0e1b\\u0e23\\u0e34\\u0e21\\u0e32\\u0e13\\u0e21\\u0e32\\u0e01\",\" \\u0e42\\u0e23\\u0e04\\u0e21\\u0e30\\u0e40\\u0e23\\u0e47\\u0e07 \\u0e2b\\u0e32\\u0e01\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e17\\u0e35\\u0e48\\u0e21\\u0e35\\u0e2a\\u0e32\\u0e23\\u0e01\\u0e48\\u0e2d\\u0e21\\u0e30\\u0e40\\u0e23\\u0e47\\u0e07\",\" \\u0e42\\u0e23\\u0e04\\u0e20\\u0e39\\u0e21\\u0e34\\u0e41\\u0e1e\\u0e49 \\u0e2b\\u0e32\\u0e01\\u0e41\\u0e1e\\u0e49\\u0e2a\\u0e32\\u0e23\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e43\\u0e19\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\",\" \\u0e42\\u0e23\\u0e04\\u0e15\\u0e34\\u0e14\\u0e40\\u0e0a\\u0e37\\u0e49\\u0e2d \\u0e2b\\u0e32\\u0e01\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e44\\u0e21\\u0e48\\u0e2a\\u0e30\\u0e2d\\u0e32\\u0e14\"]', 'photo_35_1726746560.png', '2024-09-19 18:49:20');
INSERT INTO `food_photo_menu` VALUES (116, 35, 'ก๋วยเตี๋ยวเลือดหมู', '[\" \\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e04\\u0e23\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e43\\u0e19\\u0e2b\\u0e21\\u0e39\",\" \\u0e1c\\u0e31\\u0e01\\u0e01\\u0e32\\u0e14\\u0e14\\u0e2d\\u0e07\",\" \\u0e40\\u0e2a\\u0e49\\u0e19\\u0e01\\u0e4b\\u0e27\\u0e22\\u0e40\\u0e15\\u0e35\\u0e4b\\u0e22\\u0e27\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\\u0e44\\u0e17\\u0e22\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e15\\u0e34\\u0e14\\u0e40\\u0e0a\\u0e37\\u0e49\\u0e2d\\u0e08\\u0e32\\u0e01\\u0e01\\u0e32\\u0e23\\u0e23\\u0e31\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e17\\u0e32\\u0e19\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\\u0e14\\u0e34\\u0e1a\\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e2a\\u0e38\\u0e01\\u0e44\\u0e21\\u0e48\\u0e2a\\u0e21\\u0e48\\u0e33\\u0e40\\u0e2a\\u0e21\\u0e2d\",\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19\",\" \\u0e42\\u0e23\\u0e04\\u0e04\\u0e27\\u0e32\\u0e21\\u0e14\\u0e31\\u0e19\\u0e42\\u0e25\\u0e2b\\u0e34\\u0e15\\u0e2a\\u0e39\\u0e07\",\" \\u0e42\\u0e23\\u0e04\\u0e2b\\u0e31\\u0e27\\u0e43\\u0e08\",\" \\u0e42\\u0e23\\u0e04\\u0e44\\u0e15\",\" \\u0e42\\u0e23\\u0e04\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e32\\u0e30\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\",\" \\u0e42\\u0e23\\u0e04\\u0e15\\u0e31\\u0e1a\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e01\\u0e35\\u0e48\\u0e22\\u0e27\\u0e01\\u0e31\\u0e1a\\u0e23\\u0e30\\u0e1a\\u0e1a\\u0e17\\u0e32\\u0e07\\u0e40\\u0e14\\u0e34\\u0e19\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e01\\u0e35\\u0e48\\u0e22\\u0e27\\u0e01\\u0e31\\u0e1a\\u0e23\\u0e30\\u0e1a\\u0e1a\\u0e17\\u0e32\\u0e07\\u0e40\\u0e14\\u0e34\\u0e19\\u0e2b\\u0e32\\u0e22\\u0e43\\u0e08\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e01\\u0e35\\u0e48\\u0e22\\u0e27\\u0e01\\u0e31\\u0e1a\\u0e23\\u0e30\\u0e1a\\u0e1a\\u0e1b\\u0e23\\u0e30\\u0e2a\\u0e32\\u0e17\",\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e01\\u0e35\\u0e48\\u0e22\\u0e27\\u0e01\\u0e31\\u0e1a\\u0e23\\u0e30\\u0e1a\\u0e1a\\u0e20\\u0e39\\u0e21\\u0e34\\u0e04\\u0e38\\u0e49\\u0e21\\u0e01\\u0e31\\u0e19\",\" \\u0e42\\u0e23\\u0e04\\u0e21\\u0e30\\u0e40\\u0e23\\u0e47\\u0e07\"]', 'photo_35_1726746717.png', '2024-09-19 18:51:57');
INSERT INTO `food_photo_menu` VALUES (117, 35, 'ข้าวผัดกระเพราหมู', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\",\" \\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e42\\u0e2b\\u0e23\\u0e30\\u0e1e\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e44\\u0e02\\u0e48\\u0e40\\u0e08\\u0e35\\u0e22\\u0e27\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726746814.png', '2024-09-19 18:53:34');
INSERT INTO `food_photo_menu` VALUES (118, 35, 'ข้าวผัดกระเพรา', '[\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e42\\u0e2b\\u0e23\\u0e30\\u0e1e\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e23\\u0e32\\u0e01\\u0e1c\\u0e31\\u0e01\\u0e0a\\u0e35\",\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\" \\u0e44\\u0e02\\u0e48\",\"\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\\u0e19\\u0e35\\u0e49 \\u0e44\\u0e21\\u0e48\\u0e21\\u0e35\\u0e04\\u0e27\\u0e32\\u0e21\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07 \\u0e15\\u0e48\\u0e2d\\u0e42\\u0e23\\u0e04\\u0e43\\u0e14\\u0e46\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\",\"\\u0e43\\u0e1a\\u0e42\\u0e2b\\u0e23\\u0e30\\u0e1e\\u0e32\",\"\\u0e1e\\u0e23\\u0e34\\u0e01\\u0e02\\u0e35\\u0e49\\u0e2b\\u0e19\\u0e39\",\"\\u0e15\\u0e49\\u0e19\\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\"\\u0e23\\u0e32\\u0e01\\u0e1c\\u0e31\\u0e01\\u0e0a\\u0e35\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\"\\u0e44\\u0e02\\u0e48\\u0e44\\u0e01\\u0e48\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726747375.png', '2024-09-19 19:02:55');
INSERT INTO `food_photo_menu` VALUES (119, 35, 'ข้าวผัดกระเพราหมู', '[\" \\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a\",\" \\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\" \\u0e1e\\u0e23\\u0e34\\u0e01\\u0e02\\u0e35\\u0e49\\u0e2b\\u0e19\\u0e39\",\" \\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\" \\u0e44\\u0e02\\u0e48\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\",\"\\u0e43\\u0e1a\\u0e01\\u0e23\\u0e30\\u0e40\\u0e1e\\u0e23\\u0e32\",\"\\u0e1e\\u0e23\\u0e34\\u0e01\\u0e02\\u0e35\\u0e49\\u0e2b\\u0e19\\u0e39\",\"\\u0e15\\u0e49\\u0e19\\u0e01\\u0e23\\u0e30\\u0e40\\u0e17\\u0e35\\u0e22\\u0e21\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e2a\\u0e27\\u0e22\",\"\\u0e44\\u0e02\\u0e48\\u0e44\\u0e01\\u0e48\"]', '[\"\\u0e04\\u0e27\\u0e23\\u0e40\\u0e25\\u0e37\\u0e2d\\u0e01\\u0e43\\u0e0a\\u0e49\\u0e27\\u0e31\\u0e15\\u0e16\\u0e38\\u0e14\\u0e34\\u0e1a\\u0e17\\u0e35\\u0e48\\u0e2a\\u0e14\\u0e43\\u0e2b\\u0e21\\u0e48 \\u0e41\\u0e25\\u0e30\\u0e1b\\u0e23\\u0e38\\u0e07\\u0e2a\\u0e38\\u0e01\\u0e2d\\u0e22\\u0e48\\u0e32\\u0e07\\u0e17\\u0e31\\u0e48\\u0e27\\u0e16\\u0e36\\u0e07 \\u0e40\\u0e1e\\u0e37\\u0e48\\u0e2d\\u0e1b\\u0e49\\u0e2d\\u0e07\\u0e01\\u0e31\\u0e19\\u0e01\\u0e32\\u0e23\\u0e40\\u0e01\\u0e34\\u0e14\\u0e42\\u0e23\\u0e04\\u0e08\\u0e32\\u0e01\\u0e2d\\u0e32\\u0e2b\\u0e32\\u0e23\"]', 'photo_35_1726747583.png', '2024-09-19 19:06:23');
INSERT INTO `food_photo_menu` VALUES (120, 35, 'ก๋วยเตี๋ยวเลือดหมู', '[\" \\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e2a\\u0e49\\u0e19\\u0e01\\u0e4b\\u0e27\\u0e22\\u0e40\\u0e15\\u0e35\\u0e4b\\u0e22\\u0e27\",\" \\u0e1c\\u0e31\\u0e01\\u0e01\\u0e32\\u0e14\\u0e02\\u0e32\\u0e27\",\" \\u0e15\\u0e31\\u0e1a\\u0e2b\\u0e21\\u0e39\",\" \\u0e40\\u0e04\\u0e23\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e43\\u0e19\\u0e2b\\u0e21\\u0e39\",\"\\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\\u0e2b\\u0e21\\u0e39\",\"\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2b\\u0e21\\u0e39\\u0e2a\\u0e31\\u0e1a,\\u0e40\\u0e19\\u0e37\\u0e49\\u0e2d\\u0e2a\\u0e31\\u0e15\\u0e27\\u0e4c\",\"\\u0e1c\\u0e31\\u0e01\\u0e01\\u0e32\\u0e14\\u0e02\\u0e32\\u0e27\",\"\\u0e15\\u0e31\\u0e1a\\u0e2b\\u0e21\\u0e39\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726766783.png', '2024-09-20 00:26:23');
INSERT INTO `food_photo_menu` VALUES (121, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e40\\u0e01\\u0e25\\u0e37\\u0e2d\",\" \\u0e43\\u0e1a\\u0e15\\u0e2d\\u0e07\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\"\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\"\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19  \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\\u0e21\\u0e35\\u0e04\\u0e32\\u0e23\\u0e4c\\u0e42\\u0e1a\\u0e44\\u0e2e\\u0e40\\u0e14\\u0e23\\u0e15\\u0e2a\\u0e39\\u0e07 \\u0e2d\\u0e32\\u0e08\\u0e2a\\u0e48\\u0e07\\u0e1c\\u0e25\\u0e15\\u0e48\\u0e2d\\u0e23\\u0e30\\u0e14\\u0e31\\u0e1a\\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\\u0e43\\u0e19\\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\",\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19  \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\\u0e41\\u0e25\\u0e30\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\\u0e21\\u0e35\\u0e41\\u0e04\\u0e25\\u0e2d\\u0e23\\u0e35\\u0e48\\u0e2a\\u0e39\\u0e07\",\" \\u0e42\\u0e23\\u0e04\\u0e20\\u0e39\\u0e21\\u0e34\\u0e41\\u0e1e\\u0e49  \\u0e1c\\u0e39\\u0e49\\u0e17\\u0e35\\u0e48\\u0e21\\u0e35\\u0e2d\\u0e32\\u0e01\\u0e32\\u0e23\\u0e41\\u0e1e\\u0e49\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07 \\u0e2d\\u0e32\\u0e08\\u0e40\\u0e01\\u0e34\\u0e14\\u0e2d\\u0e32\\u0e01\\u0e32\\u0e23\\u0e41\\u0e1e\\u0e49\\u0e44\\u0e14\\u0e49\"]', 'photo_35_1726778537.png', '2024-09-20 03:42:17');
INSERT INTO `food_photo_menu` VALUES (122, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e40\\u0e01\\u0e25\\u0e37\\u0e2d\",\" \\u0e43\\u0e1a\\u0e15\\u0e2d\\u0e07\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\"\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\"\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19  \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\\u0e21\\u0e35\\u0e04\\u0e32\\u0e23\\u0e4c\\u0e42\\u0e1a\\u0e44\\u0e2e\\u0e40\\u0e14\\u0e23\\u0e15\\u0e2a\\u0e39\\u0e07 \\u0e2d\\u0e32\\u0e08\\u0e2a\\u0e48\\u0e07\\u0e1c\\u0e25\\u0e15\\u0e48\\u0e2d\\u0e23\\u0e30\\u0e14\\u0e31\\u0e1a\\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\\u0e43\\u0e19\\u0e40\\u0e25\\u0e37\\u0e2d\\u0e14\",\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19  \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\\u0e41\\u0e25\\u0e30\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\\u0e21\\u0e35\\u0e41\\u0e04\\u0e25\\u0e2d\\u0e23\\u0e35\\u0e48\\u0e2a\\u0e39\\u0e07\",\" \\u0e42\\u0e23\\u0e04\\u0e20\\u0e39\\u0e21\\u0e34\\u0e41\\u0e1e\\u0e49  \\u0e1c\\u0e39\\u0e49\\u0e17\\u0e35\\u0e48\\u0e21\\u0e35\\u0e2d\\u0e32\\u0e01\\u0e32\\u0e23\\u0e41\\u0e1e\\u0e49\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07 \\u0e2d\\u0e32\\u0e08\\u0e40\\u0e01\\u0e34\\u0e14\\u0e2d\\u0e32\\u0e01\\u0e32\\u0e23\\u0e41\\u0e1e\\u0e49\\u0e44\\u0e14\\u0e49\"]', 'photo_35_1726778596.png', '2024-09-20 03:43:16');
INSERT INTO `food_photo_menu` VALUES (123, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e40\\u0e01\\u0e25\\u0e37\\u0e2d\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\"\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\"\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e2b\\u0e31\\u0e27\\u0e43\\u0e08 \\u0e40\\u0e19\\u0e37\\u0e48\\u0e2d\\u0e07\\u0e08\\u0e32\\u0e01\\u0e21\\u0e35\\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\\u0e2a\\u0e39\\u0e07\",\" \\u0e42\\u0e23\\u0e04\\u0e20\\u0e39\\u0e21\\u0e34\\u0e41\\u0e1e\\u0e49 \\u0e2b\\u0e32\\u0e01\\u0e41\\u0e1e\\u0e49\\u0e16\\u0e31\\u0e48\\u0e27\\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\"]', 'photo_35_1726778939.png', '2024-09-20 03:48:59');
INSERT INTO `food_photo_menu` VALUES (124, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e43\\u0e1a\\u0e15\\u0e2d\\u0e07\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\"\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\"\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\"]', '[\" \\u0e42\\u0e23\\u0e04\\u0e40\\u0e1a\\u0e32\\u0e2b\\u0e27\\u0e32\\u0e19  \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\\u0e40\\u0e1b\\u0e47\\u0e19\\u0e41\\u0e1b\\u0e49\\u0e07  \\u0e19\\u0e49\\u0e33\\u0e15\\u0e32\\u0e25\",\" \\u0e42\\u0e23\\u0e04\\u0e2d\\u0e49\\u0e27\\u0e19 \\u0e21\\u0e35\\u0e44\\u0e02\\u0e21\\u0e31\\u0e19\\u0e43\\u0e19\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07  \\u0e41\\u0e25\\u0e30\\u0e19\\u0e49\\u0e33\\u0e01\\u0e30\\u0e17\\u0e34\",\" \\u0e42\\u0e23\\u0e04\\u0e2b\\u0e31\\u0e27\\u0e43\\u0e08 \\u0e21\\u0e35\\u0e44\\u0e02\\u0e21\\u0e31\\u0e19\\u0e2d\\u0e34\\u0e48\\u0e21\\u0e15\\u0e31\\u0e27\\u0e43\\u0e19\\u0e19\\u0e49\\u0e33\\u0e01\\u0e30\\u0e17\\u0e34\",\" \\u0e42\\u0e23\\u0e04\\u0e41\\u0e1e\\u0e49 \\u0e2d\\u0e32\\u0e08\\u0e21\\u0e35\\u0e01\\u0e32\\u0e23\\u0e41\\u0e1e\\u0e49\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e42\\u0e23\\u0e04\\u0e20\\u0e39\\u0e21\\u0e34\\u0e41\\u0e1e\\u0e49 \\u0e2d\\u0e32\\u0e08\\u0e41\\u0e1e\\u0e49\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33  \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07  \\u0e2b\\u0e23\\u0e37\\u0e2d\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\"]', 'photo_35_1726779257.png', '2024-09-20 03:54:17');
INSERT INTO `food_photo_menu` VALUES (125, 35, 'ข้าวเหนียวมะม่วง', '[\" \\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\" \\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\" \\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\" \\u0e43\\u0e1a\\u0e40\\u0e15\\u0e22\",\"\\u0e02\\u0e49\\u0e32\\u0e27\\u0e40\\u0e2b\\u0e19\\u0e35\\u0e22\\u0e27\",\"\\u0e21\\u0e30\\u0e21\\u0e48\\u0e27\\u0e07\",\"\\u0e16\\u0e31\\u0e48\\u0e27\\u0e14\\u0e33\",\"\\u0e43\\u0e1a\\u0e40\\u0e15\\u0e22\"]', '[\"\\u0e44\\u0e21\\u0e48\\u0e1e\\u0e1a\\u0e02\\u0e49\\u0e2d\\u0e21\\u0e39\\u0e25\\u0e42\\u0e23\\u0e04\\u0e17\\u0e35\\u0e48\\u0e40\\u0e2a\\u0e35\\u0e48\\u0e22\\u0e07\"]', 'photo_35_1726779504.png', '2024-09-20 03:58:24');

SET FOREIGN_KEY_CHECKS = 1;
