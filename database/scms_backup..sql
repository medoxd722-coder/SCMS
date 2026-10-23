-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: scms_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts_user`
--

DROP TABLE IF EXISTS `accounts_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `university_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `university_id` (`university_id`),
  KEY `accounts_user_department_id_8dc06840_fk_departmen` (`department_id`),
  CONSTRAINT `accounts_user_department_id_8dc06840_fk_departmen` FOREIGN KEY (`department_id`) REFERENCES `departments_department` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user`
--

LOCK TABLES `accounts_user` WRITE;
/*!40000 ALTER TABLE `accounts_user` DISABLE KEYS */;
INSERT INTO `accounts_user` VALUES (1,'pbkdf2_sha256$870000$uWgygVHUiw7ZJYv39YzKFT$Rr4zI2I5I1cRRBrRqMnSgrBpD3gEkypBQHSUgyrnPcg=','2026-10-23 19:15:40.404992',1,'admin','','','adminuser@sut.edu.eg',1,1,'2026-10-23 15:31:26.000000','ADMIN001','ADMIN',NULL),(7,'pbkdf2_sha256$870000$PrFSOnoZFs6Vvc7BkwB2Gc$6JYtrFEe4qalDsidfgRQIQLH319ZIMlawei/wp/tni8=','2026-10-23 19:15:29.424754',0,'hassan_saied','','','student1@sut.edu.eg',0,1,'2026-10-23 19:02:47.290045','250101983','STUDENT',NULL),(8,'pbkdf2_sha256$870000$ABUvIWpNEgH1mcXQgTmu2n$K43lCtgkBfNEPBAZDvVGM81cyy/G1fvOSbrIBK1cL6c=','2026-10-23 19:15:35.335606',0,'hamadabta3elcyber','','','',1,1,'2026-10-23 19:07:33.000000','STAFF1','STAFF',1);
/*!40000 ALTER TABLE `accounts_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_user_groups`
--

DROP TABLE IF EXISTS `accounts_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_user_groups_user_id_group_id_59c0b32f_uniq` (`user_id`,`group_id`),
  KEY `accounts_user_groups_group_id_bd11a704_fk_auth_group_id` (`group_id`),
  CONSTRAINT `accounts_user_groups_group_id_bd11a704_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `accounts_user_groups_user_id_52b62117_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user_groups`
--

LOCK TABLES `accounts_user_groups` WRITE;
/*!40000 ALTER TABLE `accounts_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_user_user_permissions`
--

DROP TABLE IF EXISTS `accounts_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_user_user_permi_user_id_permission_id_2ab516c2_uniq` (`user_id`,`permission_id`),
  KEY `accounts_user_user_p_permission_id_113bb443_fk_auth_perm` (`permission_id`),
  CONSTRAINT `accounts_user_user_p_permission_id_113bb443_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `accounts_user_user_p_user_id_e4f0a161_fk_accounts_` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user_user_permissions`
--

LOCK TABLES `accounts_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `accounts_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add content type',4,'add_contenttype'),(14,'Can change content type',4,'change_contenttype'),(15,'Can delete content type',4,'delete_contenttype'),(16,'Can view content type',4,'view_contenttype'),(17,'Can add session',5,'add_session'),(18,'Can change session',5,'change_session'),(19,'Can delete session',5,'delete_session'),(20,'Can view session',5,'view_session'),(21,'Can add User',6,'add_user'),(22,'Can change User',6,'change_user'),(23,'Can delete User',6,'delete_user'),(24,'Can view User',6,'view_user'),(25,'Can add Department',7,'add_department'),(26,'Can change Department',7,'change_department'),(27,'Can delete Department',7,'delete_department'),(28,'Can view Department',7,'view_department'),(29,'Can add Complaint',8,'add_complaint'),(30,'Can change Complaint',8,'change_complaint'),(31,'Can delete Complaint',8,'delete_complaint'),(32,'Can view Complaint',8,'view_complaint'),(33,'Can add Complaint Attachment',9,'add_complaintattachment'),(34,'Can change Complaint Attachment',9,'change_complaintattachment'),(35,'Can delete Complaint Attachment',9,'delete_complaintattachment'),(36,'Can view Complaint Attachment',9,'view_complaintattachment'),(37,'Can add Complaint Feedback',10,'add_complaintfeedback'),(38,'Can change Complaint Feedback',10,'change_complaintfeedback'),(39,'Can delete Complaint Feedback',10,'delete_complaintfeedback'),(40,'Can view Complaint Feedback',10,'view_complaintfeedback'),(41,'Can add Complaint Response',11,'add_complaintresponse'),(42,'Can change Complaint Response',11,'change_complaintresponse'),(43,'Can delete Complaint Response',11,'delete_complaintresponse'),(44,'Can view Complaint Response',11,'view_complaintresponse'),(45,'Can add Complaint Upvote',12,'add_complaintupvote'),(46,'Can change Complaint Upvote',12,'change_complaintupvote'),(47,'Can delete Complaint Upvote',12,'delete_complaintupvote'),(48,'Can view Complaint Upvote',12,'view_complaintupvote');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints_complaint`
--

DROP TABLE IF EXISTS `complaints_complaint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints_complaint` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `visibility` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_solved_archive` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `assigned_staff_id` bigint DEFAULT NULL,
  `department_id` bigint DEFAULT NULL,
  `student_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `complaints_complaint_assigned_staff_id_c4f1092d_fk_accounts_` (`assigned_staff_id`),
  KEY `complaints_complaint_department_id_8d225aac_fk_departmen` (`department_id`),
  KEY `complaints_complaint_student_id_c154c81a_fk_accounts_user_id` (`student_id`),
  CONSTRAINT `complaints_complaint_assigned_staff_id_c4f1092d_fk_accounts_` FOREIGN KEY (`assigned_staff_id`) REFERENCES `accounts_user` (`id`),
  CONSTRAINT `complaints_complaint_department_id_8d225aac_fk_departmen` FOREIGN KEY (`department_id`) REFERENCES `departments_department` (`id`),
  CONSTRAINT `complaints_complaint_student_id_c154c81a_fk_accounts_user_id` FOREIGN KEY (`student_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints_complaint`
--

LOCK TABLES `complaints_complaint` WRITE;
/*!40000 ALTER TABLE `complaints_complaint` DISABLE KEYS */;
/*!40000 ALTER TABLE `complaints_complaint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints_complaintattachment`
--

DROP TABLE IF EXISTS `complaints_complaintattachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints_complaintattachment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_at` datetime(6) NOT NULL,
  `complaint_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `complaints_complaint_complaint_id_623a704c_fk_complaint` (`complaint_id`),
  CONSTRAINT `complaints_complaint_complaint_id_623a704c_fk_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaints_complaint` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints_complaintattachment`
--

LOCK TABLES `complaints_complaintattachment` WRITE;
/*!40000 ALTER TABLE `complaints_complaintattachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `complaints_complaintattachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints_complaintfeedback`
--

DROP TABLE IF EXISTS `complaints_complaintfeedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints_complaintfeedback` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `rating` smallint unsigned NOT NULL,
  `comment` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `complaint_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `complaint_id` (`complaint_id`),
  CONSTRAINT `complaints_complaint_complaint_id_bf97a417_fk_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaints_complaint` (`id`),
  CONSTRAINT `complaints_complaintfeedback_chk_1` CHECK ((`rating` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints_complaintfeedback`
--

LOCK TABLES `complaints_complaintfeedback` WRITE;
/*!40000 ALTER TABLE `complaints_complaintfeedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `complaints_complaintfeedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints_complaintresponse`
--

DROP TABLE IF EXISTS `complaints_complaintresponse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints_complaintresponse` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `complaint_id` bigint NOT NULL,
  `responder_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `complaints_complaint_complaint_id_e4463e0c_fk_complaint` (`complaint_id`),
  KEY `complaints_complaint_responder_id_16114ad9_fk_accounts_` (`responder_id`),
  CONSTRAINT `complaints_complaint_complaint_id_e4463e0c_fk_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaints_complaint` (`id`),
  CONSTRAINT `complaints_complaint_responder_id_16114ad9_fk_accounts_` FOREIGN KEY (`responder_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints_complaintresponse`
--

LOCK TABLES `complaints_complaintresponse` WRITE;
/*!40000 ALTER TABLE `complaints_complaintresponse` DISABLE KEYS */;
/*!40000 ALTER TABLE `complaints_complaintresponse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints_complaintupvote`
--

DROP TABLE IF EXISTS `complaints_complaintupvote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints_complaintupvote` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `complaint_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `complaints_complaintupvote_complaint_id_user_id_44d7d3ea_uniq` (`complaint_id`,`user_id`),
  KEY `complaints_complaintupvote_user_id_2f32dbc1_fk_accounts_user_id` (`user_id`),
  CONSTRAINT `complaints_complaint_complaint_id_599618e0_fk_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaints_complaint` (`id`),
  CONSTRAINT `complaints_complaintupvote_user_id_2f32dbc1_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints_complaintupvote`
--

LOCK TABLES `complaints_complaintupvote` WRITE;
/*!40000 ALTER TABLE `complaints_complaintupvote` DISABLE KEYS */;
/*!40000 ALTER TABLE `complaints_complaintupvote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments_department`
--

DROP TABLE IF EXISTS `departments_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments_department` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments_department`
--

LOCK TABLES `departments_department` WRITE;
/*!40000 ALTER TABLE `departments_department` DISABLE KEYS */;
INSERT INTO `departments_department` VALUES (1,'Cybersecurity','CET333','blablabla','2026-10-23 19:07:00.532019');
/*!40000 ALTER TABLE `departments_department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_accounts_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2026-10-23 18:29:23.630528','2','hassan_saied (250101983) - Student',3,'',6,1),(2,'2026-10-23 18:29:34.788479','1','admin (ADMIN001) - Admin',2,'[{\"changed\": {\"fields\": [\"Role\"]}}]',6,1),(3,'2026-10-23 18:44:46.309917','3','hassan_saied (250101983) - Admin',3,'',6,1),(4,'2026-10-23 19:07:00.532634','1','Cybersecurity (CET333)',1,'[{\"added\": {}}]',7,1),(5,'2026-10-23 19:07:33.671261','8','hamadabta3elcyber (STAFF1) - Staff',1,'[{\"added\": {}}]',6,1),(6,'2026-10-23 19:09:20.328633','8','hamadabta3elcyber (STAFF1) - Staff',2,'[{\"changed\": {\"fields\": [\"password\"]}}]',6,1),(7,'2026-10-23 19:09:28.353672','8','hamadabta3elcyber (STAFF1) - Staff',2,'[]',6,1);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (6,'accounts','user'),(1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(8,'complaints','complaint'),(9,'complaints','complaintattachment'),(10,'complaints','complaintfeedback'),(11,'complaints','complaintresponse'),(12,'complaints','complaintupvote'),(4,'contenttypes','contenttype'),(7,'departments','department'),(5,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'departments','0001_initial','2026-10-23 15:27:46.291935'),(2,'contenttypes','0001_initial','2026-10-23 15:27:46.330291'),(3,'contenttypes','0002_remove_content_type_name','2026-10-23 15:27:46.412622'),(4,'auth','0001_initial','2026-10-23 15:27:46.638740'),(5,'auth','0002_alter_permission_name_max_length','2026-10-23 15:27:46.693899'),(6,'auth','0003_alter_user_email_max_length','2026-10-23 15:27:46.699294'),(7,'auth','0004_alter_user_username_opts','2026-10-23 15:27:46.703199'),(8,'auth','0005_alter_user_last_login_null','2026-10-23 15:27:46.706932'),(9,'auth','0006_require_contenttypes_0002','2026-10-23 15:27:46.708739'),(10,'auth','0007_alter_validators_add_error_messages','2026-10-23 15:27:46.713010'),(11,'auth','0008_alter_user_username_max_length','2026-10-23 15:27:46.717195'),(12,'auth','0009_alter_user_last_name_max_length','2026-10-23 15:27:46.721720'),(13,'auth','0010_alter_group_name_max_length','2026-10-23 15:27:46.731754'),(14,'auth','0011_update_proxy_permissions','2026-10-23 15:27:46.736541'),(15,'auth','0012_alter_user_first_name_max_length','2026-10-23 15:27:46.740924'),(16,'accounts','0001_initial','2026-10-23 15:27:47.066929'),(17,'admin','0001_initial','2026-10-23 15:27:47.185305'),(18,'admin','0002_logentry_remove_auto_add','2026-10-23 15:27:47.192686'),(19,'admin','0003_logentry_add_action_flag_choices','2026-10-23 15:27:47.198469'),(20,'complaints','0001_initial','2026-10-23 15:27:47.761144'),(21,'sessions','0001_initial','2026-10-23 15:27:47.788908');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('48j0a8q0352p2hi69ix14ljke0htt3x1','.eJxVjDkOwjAQRe_iGlmMrHihpOcM1iweHEC2lKWKuDtESgHtf-_9zWRcl5rXuUx5FHMxYE6_GyE_S9uBPLDdu-Xelmkkuyv2oLO9dSmv6-H-HVSc67eOMoi6yEEJkveEygFggOLEc_BRzwEpaqIkAsKkjEIpYMSSwHk27w8OfTlp:1xKKjs:3xIArTelnymgDCHEfxSUs8m588Jtp1_E1OEfuipsnhM','2026-11-06 19:15:40.407931');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-23 22:50:10
