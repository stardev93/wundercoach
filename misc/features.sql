-- MySQL dump 10.13  Distrib 5.5.42, for osx10.6 (i386)
--
-- Host: localhost    Database: wundercoach
-- ------------------------------------------------------
-- Server version	5.5.42

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
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `fieldtype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `appversion_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_features_on_appversion_id` (`appversion_id`) USING BTREE,
  CONSTRAINT `fk_rails_ed5ccb7a94` FOREIGN KEY (`appversion_id`) REFERENCES `appversions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features`
--

LOCK TABLES `features` WRITE;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` VALUES (1,'unlimited_events',1,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(2,'unlimited_participants',2,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(3,'website_integration',3,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(4,'customer_branding',4,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(5,'editable_email_templates',5,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(6,'external_signup',6,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(7,'early_booking_prices',7,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(8,'event_templates',8,'2016-07-15 04:44:45','2016-08-04 07:06:15','boolean',1),(9,'online_payments',9,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(10,'backend_individual_appointments',10,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1),(11,'automated_billing',11,'2016-07-15 04:44:45','2016-08-04 07:11:24','boolean',1),(12,'seo_tagging',12,'2016-07-15 04:44:45','2016-08-04 07:13:32','boolean',1),(13,'crm_functions',13,'2016-07-15 04:44:45','2016-08-04 07:17:27','boolean',1),(14,'client_mailings',14,'2016-07-15 04:44:45','2016-07-15 04:44:45','boolean',1);
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-08-04  9:19:18
