-- MySQL dump 10.13  Distrib 8.0.28, for Linux (x86_64)
--
-- Host: localhost    Database: alshab_st
-- ------------------------------------------------------
-- Server version	8.0.28

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `articles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','active','declined') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `content` text COLLATE utf8mb4_unicode_ci,
  `views` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `published_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_article_user` (`user_id`),
  KEY `fk_article_cat` (`category_id`),
  CONSTRAINT `fk_article_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_article_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('post','project','event','video') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `consultunts`
--

DROP TABLE IF EXISTS `consultunts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consultunts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills` text COLLATE utf8mb4_unicode_ci,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT 'assets/members/default.png',
  `is_team` tinyint(1) DEFAULT '0',
  `breif` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video` text COLLATE utf8mb4_unicode_ci,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `date` date DEFAULT NULL,
  `price` float unsigned DEFAULT NULL,
  `featured` tinyint(1) DEFAULT '0',
  `category_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_project_event` (`category_id`),
  CONSTRAINT `fk_project_event` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `level` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `msgs`
--

DROP TABLE IF EXISTS `msgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `msgs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_id` int DEFAULT NULL,
  `to_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_msg_from` (`from_id`),
  KEY `fk_msg_to` (`to_id`),
  CONSTRAINT `fk_msg_from` FOREIGN KEY (`from_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_msg_to` FOREIGN KEY (`to_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `link` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=189 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fund` float DEFAULT NULL,
  `status` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `imgs` text COLLATE utf8mb4_unicode_ci,
  `location` text COLLATE utf8mb4_unicode_ci,
  `phone` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) DEFAULT '0',
  `website` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instagram` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `twitter` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_project_user` (`user_id`),
  KEY `fk_project_category` (`category_id`),
  KEY `fk_project_city` (`city_id`),
  CONSTRAINT `fk_project_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_project_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_project_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rich_text`
--

DROP TABLE IF EXISTS `rich_text`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rich_text` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `title` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `group` smallint DEFAULT '0',
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` float DEFAULT NULL,
  `color` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_events`
--

DROP TABLE IF EXISTS `user_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `price` float unsigned DEFAULT NULL,
  `method` enum('card','cash') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `points` int unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_user_events_user` (`user_id`),
  KEY `fk_user_events_event` (`event_id`),
  CONSTRAINT `fk_user_events_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_events_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_notifications`
--

DROP TABLE IF EXISTS `user_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_notifications` (
  `user_id` int DEFAULT NULL,
  `notification_id` int DEFAULT NULL,
  `seen_at` datetime DEFAULT NULL,
  KEY `fk_user_notifications_user` (`user_id`),
  KEY `fk_user_notifications_notification` (`notification_id`),
  CONSTRAINT `fk_user_notifications_notification` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_services`
--

DROP TABLE IF EXISTS `user_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `service_id` int DEFAULT NULL,
  `seen_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_services_user` (`user_id`),
  KEY `user_services_service` (`service_id`),
  CONSTRAINT `user_services_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_services_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_subs`
--

DROP TABLE IF EXISTS `user_subs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `price` float unsigned DEFAULT NULL,
  `method` enum('card','cash') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `points` int unsigned DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_subs_user` (`user_id`),
  KEY `fk_user_subs_role` (`role_id`),
  CONSTRAINT `fk_user_subs_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_subs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT 'assets/members/default.png',
  `password` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial` int DEFAULT NULL,
  `points` int unsigned DEFAULT '0',
  `role_id` int DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `phone` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci,
  `featured` tinyint(1) DEFAULT '0',
  `active` tinyint(1) DEFAULT '0',
  `admin` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_user_role` (`role_id`),
  KEY `fk_user_city` (`city_id`),
  CONSTRAINT `fk_user_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=296 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `videos`
--

DROP TABLE IF EXISTS `videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `videos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Breif` text COLLATE utf8mb4_unicode_ci,
  `category_id` int DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_video_category` (`category_id`),
  CONSTRAINT `fk_video_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-07-13 23:36:29
