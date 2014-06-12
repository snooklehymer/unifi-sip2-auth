-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: unifi
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  `salt` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username_idx` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (1,'admin','kQJC2Bo3cRtkzCl3k8qBPaZdVsNeT4y','hTvL7xL0M477iafcfXQdpe');
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `sitename` varchar(100) DEFAULT NULL,
  `enable_sip_validation` tinyint(4) DEFAULT NULL,
  `sip_server` int(10) unsigned DEFAULT NULL,
  `sip_port` int(5) DEFAULT NULL,
  `sip_user` varchar(50) DEFAULT NULL,
  `sip_pass` varchar(50) DEFAULT NULL,
  `sip_use_pin` tinyint(1) DEFAULT NULL,
  `sip_auth_login` tinyint(4) DEFAULT NULL,
  `sip_send_char` varchar(15) DEFAULT NULL,
  `sip_split_messages` tinyint(4) DEFAULT NULL,
  `sip_validate_surname` tinyint(4) DEFAULT NULL,
  `redirect_page` varchar(100) DEFAULT NULL,
  `unifi_controller_addr` int(10) unsigned DEFAULT NULL,
  `unifi_controller_port` int(5) DEFAULT NULL,
  `unifi_admin_user` varchar(50) DEFAULT NULL,
  `unifi_admin_password` varchar(50) DEFAULT NULL,
  `sip_location` varchar(30) DEFAULT NULL,
  `field_ident` varchar(5) DEFAULT NULL,
  `unifi_site_name` varchar(100) DEFAULT NULL,
  `sip_logging_enabled` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES ('Unifi SIP Sites',1,2886729783,6001,'sipuser','sippassword',1,0,'CR',0,0,'http://www.linux.ie',2886729857,8443,'admin','admin','HQ','|','default',1);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` char(32) NOT NULL,
  `a_session` text NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sip_validation_rules`
--

DROP TABLE IF EXISTS `sip_validation_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sip_validation_rules` (
  `sip_code` varchar(2) NOT NULL,
  `conditions` enum('equal','starts_with','like','less_than') DEFAULT NULL,
  `value` varchar(200) DEFAULT NULL,
  `actions` tinyint(1) DEFAULT NULL,
  `message` varchar(250) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `ord` int(11) DEFAULT NULL,
  UNIQUE KEY `ord` (`ord`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sip_validation_rules`
--

LOCK TABLES `sip_validation_rules` WRITE;
/*!40000 ALTER TABLE `sip_validation_rules` DISABLE KEYS */;
INSERT INTO `sip_validation_rules` VALUES ('BL','equal','N',3,'Invalid Username or Password',1,1),('CQ','equal','N',3,'Invalid Username or Password',1,2),('BL','equal','Y',0,'',2,7),('AF','starts_with','#User expired',3,'Your account has expired',NULL,3),('PC','equal','J',3,'Account not allowed on wireless network',0,6),('PD','less_than','14',3,'You must be over 14 to use this network',1,5),('AF','equal','User BARRED',3,'Account Barred',NULL,4);
/*!40000 ALTER TABLE `sip_validation_rules` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-06-12 14:52:25
