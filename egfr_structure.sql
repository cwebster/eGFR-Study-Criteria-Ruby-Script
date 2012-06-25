/*
 Navicat MySQL Data Transfer

 Source Server         : localhost
 Source Server Version : 50145
 Source Host           : localhost
 Source Database       : egfr

 Target Server Version : 50145
 File Encoding         : utf-8

 Date: 06/25/2012 17:05:43 PM
*/

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `egfr_results`
-- ----------------------------
DROP TABLE IF EXISTS `egfr_results`;
CREATE TABLE `egfr_results` (
  `NHSNo` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `DOB` datetime NOT NULL,
  `Sex` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `EG` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `DR` datetime NOT NULL,
  `GP` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Postcode` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Sodium` int(11) NOT NULL,
  `Potassium` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `Urea` float NOT NULL,
  `GFRE` int(11) NOT NULL,
  `CREAT` int(11) NOT NULL,
  KEY `NHSNo` (`NHSNo`) USING HASH,
  KEY `DR` (`DR`) USING BTREE,
  KEY `Postcode` (`Postcode`) USING HASH,
  KEY `eGFR` (`GFRE`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Raw Extract from telepath database between 1/1/2010 and 30/6';

-- ----------------------------
--  Table structure for `search_results`
-- ----------------------------
DROP TABLE IF EXISTS `search_results`;
CREATE TABLE `search_results` (
  `NHSNo` varchar(25) DEFAULT NULL,
  `DOB` date DEFAULT NULL,
  `Sex` varchar(25) DEFAULT NULL,
  `EG` varchar(25) DEFAULT NULL,
  `DR` date DEFAULT NULL,
  `GP` varchar(25) DEFAULT NULL,
  `Postcode` varchar(25) DEFAULT NULL,
  `Sodium` decimal(25,0) DEFAULT NULL,
  `Potassium` decimal(25,1) DEFAULT NULL,
  `Urea` decimal(25,1) DEFAULT NULL,
  `GFRE` decimal(25,0) DEFAULT NULL,
  `Creat` decimal(25,0) DEFAULT NULL,
  `DiffFromIndexDR` decimal(25,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;
