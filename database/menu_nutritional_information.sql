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

 Date: 23/09/2024 18:56:48
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for menu_nutritional_information
-- ----------------------------
DROP TABLE IF EXISTS `menu_nutritional_information`;
CREATE TABLE `menu_nutritional_information`  (
  `menu_id` int NOT NULL COMMENT 'รหัสเมนู (Foreign Key)',
  `ingredient_id` int NOT NULL COMMENT 'รหัสวัตถุดิบ (Foreign Key)',
  PRIMARY KEY (`menu_id`, `ingredient_id`) USING BTREE,
  INDEX `ingredient_id`(`ingredient_id` ASC) USING BTREE,
  CONSTRAINT `menu_nutritional_information_ibfk_1` FOREIGN KEY (`menu_id`) REFERENCES `food_menu` (`menu_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `menu_nutritional_information_ibfk_2` FOREIGN KEY (`ingredient_id`) REFERENCES `nutritional_information` (`ingredient_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'ตารางเชื่อมระหว่าง food_menu และ nutritional_information' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of menu_nutritional_information
-- ----------------------------
INSERT INTO `menu_nutritional_information` VALUES (100001, 1173);
INSERT INTO `menu_nutritional_information` VALUES (100001, 1296);
INSERT INTO `menu_nutritional_information` VALUES (100001, 1459);
INSERT INTO `menu_nutritional_information` VALUES (100001, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100002, 1096);
INSERT INTO `menu_nutritional_information` VALUES (100002, 1144);
INSERT INTO `menu_nutritional_information` VALUES (100002, 1451);
INSERT INTO `menu_nutritional_information` VALUES (100002, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100003, 1034);
INSERT INTO `menu_nutritional_information` VALUES (100003, 1420);
INSERT INTO `menu_nutritional_information` VALUES (100003, 1524);
INSERT INTO `menu_nutritional_information` VALUES (100003, 1592);
INSERT INTO `menu_nutritional_information` VALUES (100003, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1173);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1176);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1181);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1296);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1568);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1592);
INSERT INTO `menu_nutritional_information` VALUES (100004, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100005, 1181);
INSERT INTO `menu_nutritional_information` VALUES (100005, 1284);
INSERT INTO `menu_nutritional_information` VALUES (100005, 1286);
INSERT INTO `menu_nutritional_information` VALUES (100006, 1218);
INSERT INTO `menu_nutritional_information` VALUES (100006, 1276);
INSERT INTO `menu_nutritional_information` VALUES (100006, 1291);
INSERT INTO `menu_nutritional_information` VALUES (100006, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1004);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1085);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1158);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1296);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1452);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1613);
INSERT INTO `menu_nutritional_information` VALUES (100007, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100008, 1165);
INSERT INTO `menu_nutritional_information` VALUES (100008, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100008, 1590);
INSERT INTO `menu_nutritional_information` VALUES (100008, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100009, 1181);
INSERT INTO `menu_nutritional_information` VALUES (100009, 1291);
INSERT INTO `menu_nutritional_information` VALUES (100009, 1297);
INSERT INTO `menu_nutritional_information` VALUES (100009, 1420);
INSERT INTO `menu_nutritional_information` VALUES (100009, 1591);
INSERT INTO `menu_nutritional_information` VALUES (100010, 1329);
INSERT INTO `menu_nutritional_information` VALUES (100010, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1152);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1173);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1194);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1220);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1296);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1524);
INSERT INTO `menu_nutritional_information` VALUES (100012, 1619);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1067);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1135);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1152);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1236);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100013, 1623);
INSERT INTO `menu_nutritional_information` VALUES (100014, 1274);
INSERT INTO `menu_nutritional_information` VALUES (100014, 1504);
INSERT INTO `menu_nutritional_information` VALUES (100014, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100014, 1613);
INSERT INTO `menu_nutritional_information` VALUES (100014, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1152);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1177);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1194);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1623);
INSERT INTO `menu_nutritional_information` VALUES (100015, 1624);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1274);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1337);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1504);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1570);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1575);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1586);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1591);
INSERT INTO `menu_nutritional_information` VALUES (100016, 1613);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1144);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1165);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1275);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1276);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1504);
INSERT INTO `menu_nutritional_information` VALUES (100017, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1053);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1173);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1220);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1617);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1618);
INSERT INTO `menu_nutritional_information` VALUES (100018, 1619);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1165);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1274);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1420);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1570);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1575);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1586);
INSERT INTO `menu_nutritional_information` VALUES (100020, 1591);
INSERT INTO `menu_nutritional_information` VALUES (100021, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100021, 1616);
INSERT INTO `menu_nutritional_information` VALUES (100022, 1067);
INSERT INTO `menu_nutritional_information` VALUES (100022, 1171);
INSERT INTO `menu_nutritional_information` VALUES (100022, 1449);
INSERT INTO `menu_nutritional_information` VALUES (100022, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1236);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1274);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1337);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1504);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1570);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1575);
INSERT INTO `menu_nutritional_information` VALUES (100024, 1586);
INSERT INTO `menu_nutritional_information` VALUES (100025, 1194);
INSERT INTO `menu_nutritional_information` VALUES (100025, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100025, 1623);
INSERT INTO `menu_nutritional_information` VALUES (100026, 1012);
INSERT INTO `menu_nutritional_information` VALUES (100026, 1145);
INSERT INTO `menu_nutritional_information` VALUES (100026, 1165);
INSERT INTO `menu_nutritional_information` VALUES (100026, 1478);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1125);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1140);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1171);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1196);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1284);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1334);
INSERT INTO `menu_nutritional_information` VALUES (100027, 1337);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1173);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1220);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1296);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1524);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1615);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1620);
INSERT INTO `menu_nutritional_information` VALUES (100028, 1621);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1274);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1337);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1570);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1575);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1586);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1591);
INSERT INTO `menu_nutritional_information` VALUES (100029, 1614);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1276);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1504);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1569);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1590);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1591);
INSERT INTO `menu_nutritional_information` VALUES (100031, 1613);

SET FOREIGN_KEY_CHECKS = 1;
