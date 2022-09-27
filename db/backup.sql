
CREATE DATABASE alshab_live CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- phpMyAdmin SQL Dump
-- version 4.9.7deb1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 23, 2022 at 02:53 AM
-- Server version: 10.3.24-MariaDB-2
-- PHP Version: 7.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `alshab_staging2`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleCreate` (IN `Iuser_id` INT, IN `Icategory_id` INT, IN `Iviews_count_rate` INT, IN `Ititle` VARCHAR(250), IN `Iimg` VARCHAR(250), IN `Icontent` TEXT, IN `Istatus` VARCHAR(250))  BEGIN
INSERT INTO
    articles (
        user_id,
        category_id,
        views_count_rate,
        title,
        img,
        content,
        status
    )
VALUES
    (
        Iuser_id,
        Icategory_id,
        Iviews_count_rate,
        Ititle,
        Iimg,
        Icontent,
        Istatus
    );


    IF Istatus = 'active' THEN
        UPDATE articles SET published_at = NOW() WHERE id = LAST_INSERT_ID();
    END IF;
   

    SELECT LAST_INSERT_ID() id; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleDelete` (IN `id` INT)  BEGIN
    UPDATE
        articles a
    SET
        deleted_at = now()
    WHERE
        a.id = id;

    SELECT id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleList` (IN `page` SMALLINT(3), IN `u` INT, IN `cat` INT)  BEGIN DECLARE userCond VARCHAR(100) DEFAULT '';

DECLARE catCond VARCHAR(100) DEFAULT '';

IF u != 0 THEN
SET
    userCond = CONCAT(' AND user_id = ', u);

END IF;

IF u != 0 THEN
SET
    catCond = CONCAT(' AND category_id = ', cat);

END IF;

SET
    @query = CONCAT(
        'SELECT 
            a.* , u.name u_name , c.name cat_name FROM articles = a 
            JOIN categories c ON c.id = a.category_id JOIN users u ON u.id = a.user_id WHERE 1 = 1',
        userCond,
        catCond,
        " LIMIT 16 OFFSET ",
        16 * (page - 1)
    );

PREPARE stmt
FROM
    @query;

EXECUTE stmt;

DEALLOCATE PREPARE stmt;

SELECT
    @query;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleListByCategoryUserSearch` (IN `ICategory` INT, IN `IUserName` VARCHAR(200), IN `dateFrom` VARCHAR(200), IN `dateTo` VARCHAR(200), IN `search` VARCHAR(200))  BEGIN
    SELECT 
         a.id,
         c.name categoryName,
         a.views_count_rate,
         u.name_ar userName,
         u.img userImg,
         a.title,
         a.img,
         a.views,
         a.Published_at
        FROM articles a
           JOIN users u ON u.id = a.user_id
             JOIN categories c ON c.id = a.category_id
            WHERE a.status = "active" AND a.deleted_at IS NULL
            AND CASE WHEN ICategory = 0 THEN 1 = 1 ELSE a.category_id = ICategory END
            AND CASE WHEN search = '' THEN 1 = 1 ELSE  a.title LIKE CONCAT('%' , search , '%') END
            AND CASE WHEN IUserName = '' THEN 1 = 1 ELSE  u.name_ar LIKE CONCAT('%' , IUserName , '%') END
            AND CASE WHEN dateFrom = '' THEN 1 = 1 ELSE  a.Published_at >= dateFrom  END
            AND CASE WHEN dateTo = '' THEN 1 = 1 ELSE  a.Published_at <= dateTo  END;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticlePending` (`Istatus` VARCHAR(100), `Iname_ar` VARCHAR(200), `Ititle` VARCHAR(200), `Iphone` VARCHAR(200), `Iemail` VARCHAR(200), `dateFrom` VARCHAR(200), `dateTo` VARCHAR(200))  BEGIN
    SELECT a.id, u.name_ar , u.phone , u.email , a.title ,a.status, a.created_at 
    FROM articles a JOIN users u ON a.user_id = u.id
    WHERE published_at IS NULL 
    AND a.deleted_at IS NULL
    AND (CASE WHEN Istatus = "" THEN '1' ELSE a.status = Istatus END)
    AND (CASE WHEN Iname_ar = "" THEN '1' ELSE u.name_ar LIKE CONCAT('%' , Iname_ar , '%') END)
    AND (CASE WHEN Ititle = "" THEN '1' ELSE a.title LIKE CONCAT('%' , Ititle , '%') END)
    AND (CASE WHEN Iphone = "" THEN '1' ELSE u.phone LIKE CONCAT('%' , Iphone , '%') END)
    AND (CASE WHEN Iemail = "" THEN '1' ELSE u.email LIKE CONCAT('%' , Iemail , '%') END)
    AND (CASE WHEN dateFrom = "" THEN '1' ELSE a.created_at >= dateFrom END)
    AND (CASE WHEN dateTo = "" THEN '1' ELSE a.created_at <= dateTo END);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticlePendingAction` (`Iid` INT, `Istatus` VARCHAR(100))  BEGIN
    UPDATE articles SET 
        status = CASE WHEN Istatus = "approved" THEN 'active' ELSE Istatus END ,
        published_at = CASE WHEN Istatus = "approved" THEN NOW() ELSE NULL END 
    WHERE id = Iid;
    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleRead` (IN `Iid` INT)  BEGIN


    UPDATE articles set views = views + views_count_rate WHERE id = Iid;
    SELECT 
       a.id,
       a.user_id,
       a.category_id,
       a.views_count_rate,
       u.name userName,
       u.img userImg,   
       c.name categoryName,
       a.title,
       a.img,
       a.views,
       a.status,
       a.content,
       a.created_at,
       IFNULL(a.published_at , '')
     FROM articles a
        JOIN users u ON u.id = a.user_id
        JOIN categories c ON c.id = a.category_id
     
     WHERE a.id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ArticleUpdate` (IN `Iid` INT, IN `Iuser_id` INT, IN `Icategory_id` INT, IN `Iviews_count_rate` INT, IN `Ititle` VARCHAR(250), IN `Iimg` VARCHAR(250), IN `Icontent` TEXT, IN `Istatus` VARCHAR(250))  BEGIN
UPDATE
    articles
SET
    user_id = Iuser_id,
    category_id = Icategory_id,
    views_count_rate = Iviews_count_rate,
    title = Ititle,
    img = Iimg,
    content = Icontent,
    status = Istatus WHERE id =  Iid;

    SELECT  Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CategoryCreate` (IN `Iname` VARCHAR(300), IN `Iicon` VARCHAR(300), IN `Itype` VARCHAR(10))  BEGIN
    INSERT INTO categories (name , icon , type) VALUES (Iname , Iicon , Itype);
    SELECT LAST_INSERT_ID() id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CategoryFind` (IN `Iid` INT)  BEGIN
    SELECT 
       id,name,icon,type
     FROM categories
     
     WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CategoryListByType` (IN `Itype` VARCHAR(50))  BEGIN
    SELECT 
       id,name,icon,type
     FROM categories
     
     WHERE type = CASE WHEN Itype = "" THEN type ELSE Itype END ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CategoryUpdate` (IN `Iid` INT, IN `Iname` VARCHAR(300), IN `Iicon` VARCHAR(300), IN `Itype` VARCHAR(10))  BEGIN
    UPDATE categories SET 
    name = Iname ,
    icon = Iicon ,
    type = Itype WHERE id = Iid ;

    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CityCreate` (IN `Iname` TEXT)  BEGIN
    INSERT INTO cities (name) VALUES (Iname);

    SELECT LAST_INSERT_ID() id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CityFind` (IN `Iid` INT)  BEGIN
    SELECT id,name from cities WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CityListAll` ()  BEGIN
    SELECT id,name from cities;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CityUpdate` (IN `Iid` INT, IN `Iname` TEXT)  BEGIN
  UPDATE cities SET name = Iname WHERE id = Iid;
  SELECT Iid id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultuntById` (IN `Iid` INT)  BEGIN
    SELECT 
       id,
        name,
        title,
        skills,
        img,
        is_team,
        breif
     FROM consultunts WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultuntsCreate` (IN `Iname` VARCHAR(250), IN `Ititle` VARCHAR(250), IN `Iskills` VARCHAR(250), IN `Iimg` TEXT, IN `Iis_team` BOOLEAN, IN `Ibreif` TEXT)  BEGIN
    INSERT INTO consultunts (
        name,
        title,
        skills,
        img,
        is_team,
        breif
    )
    VALUES (
        Iname,
        Ititle,
        Iskills,
        Iimg,
        Iis_team,
        Ibreif
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultuntsListAll` (IN `Iis_team` BOOLEAN, IN `Iname` VARCHAR(200), IN `Ititle` VARCHAR(200), IN `Iskills` VARCHAR(200))  BEGIN
    SELECT 
        id,
        name,
        title,
        skills,
        img,
        is_team,
        breif
     FROM consultunts WHERE 
        is_team = Iis_team 
        AND CASE WHEN Iname = '' THEN 1 = 1 ELSE  name LIKE CONCAT('%' , Iname , '%') END
        AND CASE WHEN Ititle = '' THEN 1 = 1 ELSE  title LIKE CONCAT('%' , Ititle , '%') END
        AND CASE WHEN Iskills = '' THEN 1 = 1 ELSE  skills LIKE CONCAT('%' , Iskills , '%') END
        AND deleted_at IS NULL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultuntsUpdate` (IN `Iid` INT, IN `Iname` VARCHAR(250), IN `Ititle` VARCHAR(250), IN `Iskills` VARCHAR(250), IN `Iimg` TEXT, IN `Iis_team` BOOLEAN, IN `Ibreif` TEXT)  BEGIN
    UPDATE consultunts SET 
        name = Iname ,
        title = Ititle ,
        skills = Iskills ,
        img = Iimg ,
        is_team = Iis_team ,
        breif = Ibreif 
    WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ContactRequestsList` (`Istatus` VARCHAR(100), `Iname_ar` VARCHAR(200), `Iemail` VARCHAR(200), `Iphone` VARCHAR(200), `dateFrom` VARCHAR(200), `dateTo` VARCHAR(200))  BEGIN
    SELECT id, IFNULL(user_id , 0 ) user_id , 
    name , email , phone , IFNULL(subject , '') ,
     msg , status,
    created_at 
    FROM contact_requests
    WHERE (CASE WHEN Istatus = '' THEN '1' ELSE status = Istatus END)
     AND (CASE WHEN Iname_ar = '' THEN 1 = 1 ELSE  name LIKE CONCAT('%' , Iname_ar , '%') END)
    AND (CASE WHEN Iemail = '' THEN 1 = 1 ELSE  email LIKE CONCAT('%' , Iemail , '%') END)
    AND (CASE WHEN Iphone = '' THEN 1 = 1 ELSE  phone LIKE CONCAT('%' , Iphone , '%') END)
    AND (CASE WHEN dateFrom = '' THEN '1' ELSE created_at >= dateFrom END)
    AND (CASE WHEN dateTo = '' THEN '1' ELSE created_at <= dateTo END);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteRecord` (IN `Itable` VARCHAR(30), IN `Iid` INT)  BEGIN
    SET @query = CONCAT('UPDATE ' , Itable , ' SET deleted_at = "', NOW() , '" WHERE id = ' , Iid); 
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SELECT 1 deleted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EventCreate` (IN `Ititle` VARCHAR(250), IN `Iimg` VARCHAR(250), IN `Ivideo` TEXT, IN `Ibreif` TEXT, IN `Idate` DATE, IN `Iprice` FLOAT, IN `Ifeatured` BOOLEAN, IN `Icategory_id` INT)  BEGIN
    INSERT INTO events (
        title,
        img,
        video,
        breif,
        date,
        price,
        featured,
        category_id
        ) VALUES (
            Ititle,
            Iimg,
            Ivideo,
            Ibreif,
            Idate,
            Iprice,
            Ifeatured,
            Icategory_id
        );
        SELECT LAST_INSERT_ID( ) id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EventEdit` (IN `Iid` INT, IN `Ititle` VARCHAR(250), IN `Iimg` VARCHAR(250), IN `Ivideo` TEXT, IN `Ibreif` TEXT, IN `Idate` VARCHAR(250), IN `Iprice` FLOAT, IN `Ifeatured` BOOLEAN, IN `Icategory_id` INT)  BEGIN
    UPDATE events SET
        title = Ititle,
        img =  CASE WHEN Iimg = "" THEN img ELSE Iimg END,
        video = Ivideo,
        breif = Ibreif,
        `date` = Idate,
        price = Iprice,
        featured = Ifeatured,
        category_id = Icategory_id
    WHERE id = Iid;
        SELECT Iid;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EventRead` (IN `Iid` INT)  BEGIN
	SELECT e.id ,e.title,e.img ,IFNULL(e.breif,"") breif ,day(e.date) d,month(e.date) m,year(e.date) y,e.date, e.price ,e.featured ,e.created_at , c.Id cat_id, c.name cat_name , e.video FROM events e JOIN categories c on e.category_id = c.id WHERE  e.id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EventsList` (IN `Ifeatured` BOOLEAN, IN `Ititle` VARCHAR(100), IN `Istatus` VARCHAR(100), IN `Icategory` INT, IN `dateFrom` VARCHAR(100), IN `dateTo` VARCHAR(100), IN `priceFrom` FLOAT, IN `priceTo` FLOAT)  BEGIN
	SELECT e.id ,e.title,e.img ,IFNULL(e.breif,"") ,day(e.date) d,
    month(e.date) m,year(e.date) y, e.price ,e.featured ,e.created_at ,
    c.name cat_name , c.id cat_id  
    FROM events e 
    JOIN categories c 
        on e.category_id = c.id 
    WHERE e.deleted_at IS NULL 
    AND CASE WHEN Ititle = '' THEN 1 = 1 ELSE  title LIKE CONCAT('%' , Ititle , '%') END
    AND CASE WHEN Ifeatured IS NULL THEN 1 = 1 ELSE  featured = Ifeatured END
    AND CASE WHEN Icategory = 0 THEN 1 = 1 ELSE  category_id = Icategory  END
    AND CASE WHEN dateFrom = '' THEN 1 = 1 ELSE  e.date >= dateFrom  END
    AND CASE WHEN dateTo = '' THEN 1 = 1 ELSE  e.date <= dateTo  END
    AND CASE WHEN priceFrom = 0 THEN 1 = 1 ELSE  e.price >= priceFrom  END
    AND CASE WHEN priceTo = 0 THEN 1 = 1 ELSE  e.price <= priceTo  END
    ORDER BY e.date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EventsListByCategorySearch` (IN `ICategory` INT, IN `search` VARCHAR(200))  BEGIN
DECLARE categoryCond VARCHAR(50) DEFAULT '';
DECLARE searchCond VARCHAR(50) DEFAULT '';
IF ICategory != 0 THEN
    SET categoryCond = CONCAT('AND category_id = ' , ICategory);
END IF;
IF search != '' THEN
    SET searchCond = CONCAT('AND title LIKE "%' , search , '%"');
END IF;

    SET @query = CONCAT(
        'SELECT 
         e.id ,e.title,e.img ,IFNULL(e.breif,"") ,day(e.date) d,month(e.date) m,year(e.date) y, e.price ,e.featured ,e.created_at ,  c.name cat_name , c.id cat_id  FROM events e JOIN categories c on e.category_id = c.id WHERE 1 = 1 ',
        categoryCond,
        searchCond);
         
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FeaturesEditAdd` (IN `Iid` INT, IN `Iname` VARCHAR(200), IN `Ibreif` TEXT, IN `Ilevel` INT)  BEGIN
    IF Iid != 0 THEN
        UPDATE features SET name = Iname , level = Ilevel, breif = Ibreif WHERE id = Iid;
    ELSE 
        INSERT INTO features (
            name,
            breif,
            level
        ) VALUES (
            Iname,
            Ibreif,
            Ilevel
        );
        SET Iid = LAST_INSERT_ID();
    END IF;
    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FeaturesFindById` (IN `Iid` INT)  BEGIN
    
    SELECT * from features WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FeaturesListAll` ()  BEGIN
    SELECT * from features;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FeaturesListByRole` (IN `role` INT, IN `Iname` VARCHAR(250))  BEGIN
    SELECT * from features WHERE 
        (CASE WHEN role IS NULL THEN '1' ELSE level <= (role -1) END)
        AND CASE WHEN Iname = '' THEN 1 = 1 ELSE  name LIKE CONCAT('%' , Iname , '%') END;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FindDashboardCounts` ()  BEGIN
    SET @projects = (SELECT COUNT(*)  FROM projects WHERE deleted_at IS NULL);
    SET @events = (SELECT COUNT(*)  FROM events WHERE deleted_at IS NULL);
    SET @users = (SELECT COUNT(*)  FROM users WHERE deleted_at IS NULL);
    SET @pendingUsers = (SELECT COUNT(*)  FROM users WHERE  active = 0 AND deleted_at IS NULL);
    SET @ryadeen = (SELECT COUNT(*)  FROM users WHERE  active = 1 AND deleted_at IS NULL AND role_id = 3);
    SET @tamooheen = (SELECT COUNT(*)  FROM users WHERE  active = 1 AND deleted_at IS NULL AND role_id = 2);
    SET @mobadreen = (SELECT COUNT(*)  FROM users WHERE  active = 1 AND deleted_at IS NULL AND role_id = 1);


    SELECT 
        @projects projects,
        @events events,
        @users users,
        @pendingUsers pendingUsers,
        @ryadeen ryadeen,
        @tamooheen tamooheen,
        @mobadreen mobadreen;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Merge` ()  BEGIN
    CALL MergeRoles();
    CALL MergeRich();
    CALL MergeCities();
    CALL MergeCats();
    CALL MergeServices();
    CALL MergeConsultunts();
    CALL MergeVideos();
    CALL MergeEvents();
    CALL MergeUsers();
    CALL MergeArticles();
    CALL MergeProjects();
    CALL MergeNotifications();
    CALL MergeMsgs();
 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeArticles` ()  BEGIN
    INSERT INTO alshab_staging2.articles(
        user_id,
        category_id,
        title,
        img,
        status,
        content,
        views,
        created_at,
        published_at,
        deleted_at
    ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = u.phone),
        (SELECT id FROM alshab_staging2.categories WHERE name = c.name LIMIT 1),
        ua.title,
        ua.img,
        ua.status,
        ua.content,
        ua.views,
        ua.created_at,
        ua.published_at,
        ua.deleted_at 
    FROM alshab_staging.articles ua
    JOIN alshab_staging.users u 
    ON ua.user_id = u.id
    JOIN alshab_staging.categories c
    ON ua.category_id = c.id; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeCats` ()  BEGIN
    INSERT INTO alshab_staging2.categories(name , icon , type) SELECT name , icon , type FROM alshab_staging.categories;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeCities` ()  BEGIN
    INSERT INTO alshab_staging2.cities(name) SELECT name FROM alshab_staging.cities;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeConsultunts` ()  BEGIN
    INSERT INTO alshab_staging2.consultunts(name , title , skills , img , is_team , breif) SELECT name , title , skills , img , is_team , breif FROM alshab_staging.consultunts;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeEvents` ()  BEGIN
    INSERT INTO alshab_staging2.events(title , img , video , breif , `date` , price , featured , category_id) SELECT title , img , video , breif , `date` , price , featured , (SELECT id FROM alshab_staging2.categories WHERE name = c.name LIMIT 1) FROM alshab_staging.events e JOIN alshab_staging.categories c ON e.category_id = c.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeMsgs` ()  BEGIN
    INSERT INTO alshab_staging2.msgs(
        from_id,
        to_id,
        created_at,
        breif,
        seen
    ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = fr.phone),
        (SELECT id FROM alshab_staging2.users WHERE phone = t.phone),
        now(),
        m.breif,
        m.seen 
    FROM alshab_staging.msgs m 
    JOIN alshab_staging.users fr ON m.from_id = fr.id 
    JOIN alshab_staging.users t ON m.to_id = t.id ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeNotifications` ()  BEGIN
    INSERT INTO alshab_staging2.notifications(
        title,
        breif,
        link
    ) 
    SELECT 
        title,
        breif,
        link 
    FROM alshab_staging.notifications;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeProjects` ()  BEGIN
    INSERT INTO alshab_staging2.projects(
        user_id,
        category_id,
        city_id,
        title,
        logo,
        img,
        fund,
        status,
        breif,
        imgs,
        location,
        phone,
        file,
        email,
        featured,
        website,
        instagram,
        twitter,
        active,
        created_at,
        deleted_at
    ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = u.phone),
        (SELECT id FROM alshab_staging2.categories WHERE name = ca.name LIMIT 1),
        (SELECT id FROM alshab_staging2.cities WHERE name = ci.name LIMIT 1),
        up.title,
        up.logo,
        up.img,
        up.fund,
        up.status,
        up.breif,
        up.imgs,
        up.location,
        up.phone,
        up.file,
        up.email,
        up.featured,
        up.website,
        up.instagram,
        up.twitter,
        up.active,
        up.created_at,
        up.deleted_at 
    FROM alshab_staging.projects up
    JOIN alshab_staging.users u 
    ON up.user_id = u.id
    JOIN alshab_staging.categories ca
    ON up.category_id = ca.id
    JOIN alshab_staging.cities ci
    ON up.category_id = ci.id; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeRich` ()  BEGIN
     INSERT INTO alshab_staging2.rich_text(`key`  , `value` , title , image , `group` , icon) SELECT `key`  , `value` , title , image , `group` , icon FROM alshab_staging.rich_text;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeRoles` ()  BEGIN
    INSERT INTO alshab_staging2.features(name , breif , level ) SELECT name , breif , level  FROM alshab_staging.features;
    INSERT INTO alshab_staging2.roles(name , image , breif , price , color) SELECT name , image , breif , price , color FROM alshab_staging.roles;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeServices` ()  BEGIN
    INSERT INTO alshab_staging2.services(name , icon) SELECT name , icon FROM alshab_staging.services;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeUsers` ()  BEGIN
    INSERT INTO alshab_staging2.users(
        name ,
        name_ar ,
        email ,
        img ,
        password ,
        serial ,
        points ,
        role_id ,
        city_id ,
        phone ,
        breif ,
        featured ,
        active ,
        admin ,
        created_at ,
        deleted_at
    ) 
    SELECT 
        u.name ,
        u.name_ar ,
        u.email ,
        u.img ,
        u.password ,
        u.serial ,
        u.points ,
        (SELECT id FROM roles WHERE name = r.name LIMIT 1) ,
        (SELECT id FROM cities WHERE name = c.name LIMIT 1) ,
        u.phone ,
        u.breif ,
        u.featured ,
        u.active ,
        u.admin ,
        u.created_at ,
        u.deleted_at 
    FROM alshab_staging.users u 
    JOIN alshab_staging.roles r ON u.role_id = r.id
    LEFT JOIN alshab_staging.cities c ON u.city_id = c.id;


    INSERT INTO alshab_staging2.user_subs( 
        user_id,
        role_id ,

        price,
        method,
        points,
        created_at,
        start_at,
        end_at ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = u.phone),
        (SELECT id FROM roles WHERE name = r.name LIMIT 1) ,
        us.price,
        us.method,
        us.points,
        us.start_at,
        us.start_at,
        us.end_at 
    FROM  alshab_staging.user_subs us 
    JOIN alshab_staging.users u 
    ON us.user_id = u.id
    JOIN alshab_staging.roles r ON us.role_id = r.id; 


    
    INSERT INTO alshab_staging2.user_events(
        user_id,
        event_id,
        price,
        method,
        points
    ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = u.phone),
        (SELECT id FROM events WHERE title = e.title LIMIT 1) ,
        ue.price,
        ue.method,
        ue.points 
    FROM alshab_staging.user_events ue 
    JOIN alshab_staging.users u 
    ON ue.user_id = u.id
    JOIN alshab_staging.events e 
    ON ue.event_id = e.id;


    INSERT INTO alshab_staging2.user_services(
        user_id,
        breif,
        service_id,
        seen_at,
        created_at
    ) 
    SELECT 
        (SELECT id FROM alshab_staging2.users WHERE phone = u.phone),
        us.breif,
        (SELECT id FROM alshab_staging2.services WHERE name = s.name LIMIT 1),
        us.seen_at,
        us.created_at 
    FROM alshab_staging.user_services us 
    JOIN alshab_staging.users u 
    ON us.user_id = u.id
    JOIN alshab_staging.services s 
    ON us.service_id = s.id; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeVideos` ()  BEGIN
    INSERT INTO alshab_staging2.videos(name , url , image , Breif , category_id) SELECT v.name , v.url , v.image , v.Breif , (SELECT id FROM alshab_staging2.categories WHERE name = c.name LIMIT 1) FROM alshab_staging.videos v JOIN alshab_staging.categories c ON v.category_id = c.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MsgsCreate` (`Ifrom_id` INT, `Ito_id` INT, `Ibreif` TEXT)  BEGIN
   INSERT INTO msgs (from_id , to_id , breif) VALUES (Ifrom_id , Ito_id , Ibreif);
   SELECT LAST_INSERT_ID() id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MsgsList` (IN `Iuser_id` INT)  BEGIN
    SELECT fr.id from_id , t.id to_id  INTO @toId , @fromId FROM msgs m JOIN users fr ON m.from_id = fr.id JOIN users t ON m.to_id = t.id WHERE to_id = Iuser_id OR from_id = Iuser_id GROUP BY fr.name , fr.id , t.name , t.id; 
    IF @toId = Iuser_id THEN
        SELECT id , name_ar , img FROM users WHERE id = @fromId ;
    ELSE
        SELECT id , name_ar , img FROM users WHERE id = @toId ;
    END IF;

    SELECT id , name_ar , img FROM users WHERE id != Iuser_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MsgsListByUser` (`id1` INT, `id2` INT)  BEGIN
    SELECT m.id ,IF(m.from_id = id1 , TRUE , FALSE) mine, u.name_ar name ,m.breif , m.created_at , IFNULL(m.seen , '') seen 
    FROM msgs m 
      JOIN users u ON m.from_id = u.id
    WHERE (m.from_id = id1 AND m.to_id = id2) OR (m.from_id = id2 AND m.to_id = id1) 
  
    ORDER BY m.created_at DESC, id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NotificationCreate` (IN `Ititle` VARCHAR(250), IN `Ibreif` TEXT, IN `Iurl` VARCHAR(250))  BEGIN
DECLARE x INT;
DECLARE max INT;
DECLARE u_id INT;
DECLARE n_id INT;

INSERT INTO notifications (
    title,
    breif,
    link
) VALUES (
    Ititle,
    Ibreif,
    Iurl
);

SET n_id = (SELECT LAST_INSERT_ID());


SET x = 0;
SET max = (SELECT (COUNT(*)) FROM users WHERE users.admin = 1);

loop_label:  LOOP
		IF  x > max THEN 
			LEAVE  loop_label;
		END  IF;
        SET u_id = (SELECT id FROM users WHERE admin = 1 LIMIT 1);

        INSERT INTO user_notifications (
            user_id,
            notification_id
        ) VALUES (
            u_id,
            n_id
        );
         
		SET  x = x + 1;
       
	END LOOP;


    SELECT n_id ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NotificationsByUserId` (`IId` INT)  BEGIN
    SELECT Title , Breif , Link FROM notifications n
    JOIN user_notifications un 
    ON n.id = un.notification_id 
    WHERE un.user_id = IId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectDelete` (IN `Iid` INT)  BEGIN
    UPDATE  projects SET deleted_at = now()  WHERE id = Iid;
    SELECT Iid id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectPending` (`Istatus` VARCHAR(100), `Iname_ar` VARCHAR(200), `Ititle` VARCHAR(200), `Iphone` VARCHAR(200), `Iemail` VARCHAR(200), `dateFrom` VARCHAR(200), `dateTo` VARCHAR(200))  BEGIN
    SELECT p.id, u.id user_id ,u.name_ar , u.email , p.title , p.phone , p.status ,p.created_at 
    FROM projects p JOIN users u ON p.user_id = u.id WHERE 
    p.active = 0 AND p.deleted_at IS NULL
    AND (CASE WHEN Istatus = "" THEN '1' ELSE p.status = Istatus END)
    AND (CASE WHEN Iname_ar = "" THEN '1' ELSE u.name_ar LIKE CONCAT('%' , Iname_ar , '%') END)
    AND (CASE WHEN Ititle = "" THEN '1' ELSE p.title LIKE CONCAT('%' , Ititle , '%') END)
    AND (CASE WHEN Iphone = "" THEN '1' ELSE u.phone LIKE CONCAT('%' , Iphone , '%') END)
    AND (CASE WHEN Iemail = "" THEN '1' ELSE u.email LIKE CONCAT('%' , Iemail , '%') END)
    AND (CASE WHEN dateFrom = "" THEN '1' ELSE p.created_at >= dateFrom END)
    AND (CASE WHEN dateTo = "" THEN '1' ELSE p.created_at <= dateTo END);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectPendingAction` (`Iid` INT, `action` VARCHAR(100))  BEGIN
    UPDATE projects SET 
        active = CASE WHEN action = "approved" THEN 1 ELSE 0 END,
        status = action
        WHERE id = Iid;
    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectRead` (IN `Iid` INT)  BEGIN
    SELECT 
        u.name userName,
        ca.name categoryName,
        ca.id categoryId,
        ci.name city,
        ci.id cityId,
        p.title,
        p.img,
        p.logo,
        p.fund,
        p.status,
        p.breif,
        IFNULL(p.imgs , '') imgs,
        p.location,
        p.phone,
        IFNULL(p.file , '') file,
        p.email,
        p.featured,
        IFNULL(p.website , '') website,
        IFNULL(p.instagram , '') instagram,
        IFNULL(p.twitter , '') twitter
     FROM projects p 
        JOIN users u ON u.id = p.user_id
        JOIN cities ci ON ci.id = p.city_id
        JOIN categories ca ON ca.id = p.category_id
     
     WHERE p.id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectsCreate` (IN `Iuser_id` INT, IN `Icategory_id` INT, IN `Icity_id` INT, IN `Ititle` VARCHAR(250), IN `Istatus` VARCHAR(100), IN `Iimg` VARCHAR(250), IN `Iimgs` VARCHAR(250), IN `Ilogo` VARCHAR(250), IN `Ifund` FLOAT, IN `Ibreif` TEXT, IN `Ilocation` TEXT, IN `Iphone` VARCHAR(250), IN `Ifile` VARCHAR(250), IN `Iemail` VARCHAR(250), IN `Iwebsite` VARCHAR(250), IN `Iinstagram` VARCHAR(250), IN `Itwitter` VARCHAR(250), IN `Ifeatured` VARCHAR(250), IN `Iactive` VARCHAR(250))  BEGIN
INSERT INTO
    projects (
        user_id,
        category_id,
        city_id,
        title,
        status,
        img,
        imgs,
        logo,
        fund,
        breif,
        location,
        phone,
        file,
        email,
        website,
        instagram,
        twitter,
        featured,
        active
    )
VALUES
    (
        Iuser_id,
        Icategory_id,
        Icity_id,
        Ititle,
        Istatus,
        Iimg,
        Iimgs,
        Ilogo,
        Ifund,
        Ibreif,
        Ilocation,
        Iphone,
        Ifile,
        Iemail,
        Iwebsite,
        Iinstagram,
        Itwitter,
        Ifeatured,
        Iactive
    );


    SELECT LAST_INSERT_ID() id; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectsListByCategoryUserSearch` (IN `ICategory` INT, IN `ICity` INT, IN `Iuser` INT, IN `search` VARCHAR(200), IN `userName` VARCHAR(200), IN `Istatus` VARCHAR(200))  BEGIN

    SELECT 
         p.id,
         p.title,
         u.name user_name,
         c.name category_name,
         ci.name city_name,
         p.status,
         p.logo,
         p.img
        FROM projects p
            JOIN users u ON p.user_id = u.id
            JOIN categories c ON p.category_id = c.id
            JOIN cities ci ON p.city_id = ci.id
            WHERE p.active = 1
            AND p.user_id = CASE WHEN Iuser = 0 THEN p.user_id ELSE Iuser END
            AND p.category_id = CASE WHEN ICategory = 0 THEN p.category_id ELSE ICategory END
            AND p.city_id = CASE WHEN ICity = 0 THEN p.city_id ELSE ICity END
            AND CASE WHEN search = '' THEN 1 = 1 ELSE  p.title LIKE CONCAT('%' , search , '%') END
            AND CASE WHEN userName = '' THEN 1 = 1 ELSE  u.name LIKE CONCAT('%' , userName , '%') END
            AND CASE WHEN Istatus = '' THEN 1 = 1 ELSE  p.status =  Istatus END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectsListFeatured` ()  BEGIN
    SELECT 
        p.id,
        p.title,
        p.logo,
        p.img
        FROM projects p 
           
            WHERE  featured = 1 ORDER BY RAND() LIMIT 4;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProjectUpdate` (IN `Iid` INT, IN `Icategory_id` INT, IN `Icity_id` INT, IN `Ititle` VARCHAR(250), IN `Istatus` VARCHAR(100), IN `Iimg` VARCHAR(250), IN `Iimgs` VARCHAR(250), IN `Ilogo` VARCHAR(250), IN `Ifund` FLOAT, IN `Ibreif` TEXT, IN `Ilocation` TEXT, IN `Iphone` VARCHAR(250), IN `Ifile` VARCHAR(250), IN `Iemail` VARCHAR(250), IN `Iwebsite` VARCHAR(250), IN `Iinstagram` VARCHAR(250), IN `Itwitter` VARCHAR(250), IN `Ifeatured` VARCHAR(250), IN `Iactive` VARCHAR(250))  BEGIN
UPDATE
    projects
SET
    category_id = Icategory_id,
    city_id = Icity_id,
    title = Ititle,
    status = Istatus,
    img = CASE WHEN Iimg = "" THEN img ELSE Iimg END ,
    imgs = CASE WHEN Iimgs = "" THEN imgs ELSE Iimgs END ,
    logo = CASE WHEN Ilogo = "" THEN logo ELSE Ilogo END ,
    fund = Ifund,
    breif = Ibreif,
    location = Ilocation,
    phone = Iphone,
    file =  CASE WHEN Ifile = "" THEN file ELSE Ifile END ,
    email = Iemail,
    website = Iwebsite,
    instagram = Iinstagram,
    twitter = Itwitter,
    featured = Ifeatured,
    active = Iactive
    WHERE id = Iid;

    SELECT LAST_INSERT_ID();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Register` (IN `IName` VARCHAR(250), IN `IName_ar` VARCHAR(250), IN `IEmail` VARCHAR(250), IN `IPassword` VARCHAR(250), IN `IPhone` VARCHAR(250), IN `IRole` INT, IN `IAdmin` BOOLEAN)  BEGIN

    SELECT MAX(`serial`) FROM users INTO @maxSerial;
    

   INSERT INTO users (
        name,
        name_ar,
        email,
        `password`,
        phone,
        role_id,
        `serial`,
        admin,
        active
   )
   VALUES (
        IName,
        IName_ar,
        IEmail,
        IPassword,
        IPhone,
        IRole,
        @maxSerial + 1,
        IAdmin,
        IAdmin
   );


    INSERT INTO user_subs (
        user_id,
        role_id,
        price,
        method,
        points,
        start_at,
        end_at
    ) VALUES (
        LAST_INSERT_ID(),
        IRole,
        (SELECT price FROM roles WHERE id = IRole),
        'cash',
        (SELECT price FROM roles WHERE id = IRole),
        now(),
        DATE_ADD( now(), INTERVAL 1 YEAR)
    );


   SELECT LAST_INSERT_ID() id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RichTextListByGroupOrKey` (IN `IGroup` INT, IN `IKey` VARCHAR(250))  BEGIN

DECLARE cond VARCHAR(50) DEFAULT '';
IF IGroup != 0 THEN
    SET cond = CONCAT('AND r.group =' , IGroup);
ELSE 
    SET cond = CONCAT('AND r.key = "' , IKey , '"');
END IF;

  SET @query = CONCAT(
        'SELECT 
        r.value,
        r.title,
        IFNULL(r.image , "") image,
        IFNULL(r.icon , "") icon
        FROM rich_text r
            WHERE 1 = 1 ',
        cond);
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RichTextListById` (IN `Iid` INT)  BEGIN
    SELECT 
        r.id,
        r.value,
        r.title,
        IFNULL(r.image , "") image,
        IFNULL(r.icon , "") icon
        FROM rich_text r
            WHERE id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RichTextListByPage` (IN `Ipage` VARCHAR(100), IN `Ititle` VARCHAR(250), IN `Ivalue` TEXT)  BEGIN
    SELECT 
        r.id,
        r.value,
        r.title,
        IFNULL(r.image , "") image,
        IFNULL(r.icon , "") icon
        FROM rich_text r
            WHERE page = Ipage
            AND CASE WHEN Ititle = '' THEN 1 = 1 ELSE  title LIKE CONCAT('%' , Ititle , '%') END
            AND CASE WHEN Ivalue = '' THEN 1 = 1 ELSE  value LIKE CONCAT('%' , Ivalue , '%') END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RichTextUpdate` (`Iid` INT, `Ititle` TEXT, `Ivalue` TEXT, `IIcon` VARCHAR(100), `Iimage` VARCHAR(100))  BEGIN
    
    UPDATE  rich_text SET value = Ivalue , title = Ititle ,icon = IIcon,
    image = CASE WHEN Iimage = "" THEN image ELSE Iimage END 
     WHERE id = Iid ;
    SELECT 1 updated;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RoleEdit` (IN `Iid` INT, IN `Iname` VARCHAR(250), IN `Iimage` TEXT, IN `Ibreif` TEXT, IN `Iprice` FLOAT, IN `Icolor` VARCHAR(10), IN `Iactive` BOOLEAN)  BEGIN
    UPDATE roles SET 
        id  = Iid ,
        name  = Iname ,
        image =  CASE WHEN Iimage = "" THEN image ELSE Iimage END,
        breif  = Ibreif ,
        price  = Iprice ,
        color  = Icolor,
        active  = Iactive 
    WHERE id = Iid;


    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RoleFind` (`IId` INT)  BEGIN
    SELECT id ,name ,image ,breif ,price , color , active FROM roles WHERE id = IId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RolesList` (IN `active` BOOLEAN, IN `Iname` VARCHAR(250), IN `priceFrom` FLOAT, IN `priceTo` FLOAT)  BEGIN
    SELECT r.id ,r.name ,r.image ,r.breif ,r.price , r.color, r.active FROM roles r 
    WHERE 
    (CASE WHEN active IS NULL THEN '1' ELSE r.active = active END)
    AND CASE WHEN Iname = '' THEN 1 = 1 ELSE  r.name LIKE CONCAT('%' , Iname , '%') END
    AND CASE WHEN priceFrom = 0 THEN 1 = 1 ELSE  r.price >= priceFrom END
    AND CASE WHEN priceTo = 0 THEN 1 = 1 ELSE  r.price <= priceTo END;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SerivcesPendingFind` (IN `id` INT)  BEGIN
       SELECT u.id , u.name_ar , u.email , u.phone , us.breif ,u.created_at FROM users u JOIN user_services us ON u.id = us.user_id  WHERE us.id = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServiceCreate` (`IName` VARCHAR(100), `IIcon` VARCHAR(100))  BEGIN
    INSERT INTO services ( name,icon) VALUES(IName , IIcon);
    SELECT LAST_INSERT_ID(); 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServiceDelete` (`IId` INT)  BEGIN
    DELETE FROM services WHERE id = IId;
    SELECT 1 deleted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServiceRequestPendingAction` (`Iid` INT, `Istatus` VARCHAR(100))  BEGIN
    UPDATE user_services SET seen_at = now() , status = Istatus WHERE id = Iid;
    SELECT LAST_INSERT_ID() id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServiceRequestsPending` (`Iname_ar` VARCHAR(200), `Istatus` VARCHAR(200), `service_id` INT, `role_id` INT, `Iemail` VARCHAR(100), `Ibreif` VARCHAR(100))  BEGIN

    SELECT us.id, u.id ,u.name_ar ,s.name , r.name  ,  u.email , us.breif , us.status , us.created_at FROM 
    user_services us 
    JOIN users u 
        ON us.user_id = u.id
    JOIN roles r
        ON u.role_id = r.id
    JOIN services s 
        ON us.service_id = s.id 
    WHERE
    (CASE WHEN Iname_ar = '' THEN '1' ELSE u.name_ar LIKE CONCAT('%' ,Iname_ar , '%')  END)
    AND (CASE WHEN Iemail = '' THEN '1' ELSE u.email LIKE CONCAT('%' ,Iemail , '%')  END)
    AND (CASE WHEN Ibreif = '' THEN '1' ELSE us.breif LIKE CONCAT('%' ,Ibreif , '%')  END)
    AND (CASE WHEN role_id = 0 THEN '1' ELSE r.id = role_id END)
    AND (CASE WHEN Istatus = "" THEN '1' ELSE us.status = Istatus END)
    AND (CASE WHEN role_id = 0 THEN '1' ELSE r.id = role_id END);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServicesFindById` (IN `Iid` INT)  BEGIN
    SELECT id,name,icon from services WHERE id = Iid ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServicesListAll` (IN `Iname` VARCHAR(250))  BEGIN
    SELECT id,name,icon 
    FROM services 
    WHERE CASE WHEN Iname = '' THEN 1 = 1 ELSE
      name LIKE CONCAT('%' , Iname , '%') 
    END;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ServiceUpdate` (`IId` INT, `IName` VARCHAR(100), `IIcon` VARCHAR(100))  BEGIN
    UPDATE  services SET name = IName ,icon = IIcon WHERE id = IId;
    SELECT 1 updated;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserById` (IN `Iid` INT)  BEGIN

        SELECT 
        u.id,
        u.name,
        u.name_ar,
        IFNULL(u.email , "") email,
        u.img,
        u.serial,
        u.points,
        u.role_id,
        u.phone,
        IFNULL(u.breif,""),
        r.name role,
        r.color
        FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE  u.id = Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserCreate` (IN `Iname` VARCHAR(250), IN `Iname_ar` VARCHAR(250), IN `Iemail` VARCHAR(250), IN `Ipassword` VARCHAR(250), IN `Iserial` VARCHAR(250), IN `Irole_id` INT, IN `Iphone` VARCHAR(250), IN `Ibreif` TEXT(250))  BEGIN
INSERT INTO
    users (
        name,
        name_ar,
        email,
        password,
        serial,
        role_id,
        phone,
        breif
    )
VALUES
    (
        IpropName,
        Iname,
        Iname_ar,
        Iemail,
        Ipassword,
        Iserial,
        Irole_id,
        Iphone,
        Ibreif
    );

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserDelete` (IN `id` INT)  BEGIN
UPDATE
    users u
SET
    deleted_at = now()
WHERE
    u.id = id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserFindUpgradeRequest` (IN `Iid` INT)  BEGIN
    SELECT  us.id , u.name_ar , u.email , u.phone , cur_role.name ,
            u.role_id  , new_role.name, us.role_id, us.price , us.created_at 
    FROM users u 
    JOIN user_subs us 
        ON u.id = us.user_id AND us.approved_at IS NULL 
    JOIN roles cur_role 
        ON u.role_id = cur_role.id 
    JOIN roles new_role 
        ON us.role_id = new_role.id 
    WHERE u.id = Iid;
   
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserListByRoleOrFeatured` (IN `role` INT, IN `featured` BOOLEAN, IN `admin` BOOLEAN, IN `Iname` VARCHAR(100), IN `Iphone` VARCHAR(100), IN `Iemail` VARCHAR(100), IN `Iserial` VARCHAR(100))  BEGIN

SELECT 
        u.id,
        u.name,
        u.name_ar,
        IFNULL(u.email , "") email,
        u.img,
        u.serial,
        u.points,
        u.role_id,
        u.phone,
        IFNULL(u.breif,""),
        r.name role,
        r.color
        FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.active = 1 
            AND u.admin = admin
            AND  (CASE WHEN role = 0 THEN '1' ELSE u.role_id = role END)
            AND  (CASE WHEN featured = 0 THEN '1' ELSE u.featured = featured END)
            AND  (CASE WHEN Iname = '' THEN '1' ELSE u.name_ar LIKE CONCAT('%' ,  Iname , '%') END)
            AND  (CASE WHEN Iphone = '' THEN '1' ELSE u.phone LIKE CONCAT('%' ,  Iphone , '%') END)
            AND  (CASE WHEN Iemail = '' THEN '1' ELSE u.email LIKE CONCAT('%' ,  Iemail , '%') END)
            AND  (CASE WHEN Iserial = '' THEN '1' ELSE u.serial LIKE CONCAT('%' ,  Iserial , '%') END);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserPendingAction` (`Iid` INT, `Istatus` VARCHAR(100))  BEGIN
    UPDATE users u JOIN user_subs us ON u.id = us.user_id SET 
    status = Istatus ,
    u.role_id = CASE WHEN Istatus = "approved" THEN us.role_id ELSE u.role_id END  ,
    active = CASE WHEN Istatus = "approved" THEN 1 ELSE 0 END,
    approved_at = CASE WHEN Istatus = "approved" THEN NOW() ELSE NULL END  
    WHERE u.id = Iid;
     
    SELECT Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserRead` (IN `emailOrPhone` VARCHAR(250))  BEGIN
DECLARE cond VARCHAR(50) DEFAULT '';
IF emailOrPhone REGEXP '^[0-9]+$' THEN
    SET cond = CONCAT('AND phone = "' , emailOrPhone, '"');
ELSE 
    SET cond = CONCAT('AND email = "' , emailOrPhone , '"');
END IF;
    SET @query = CONCAT(
        'SELECT 
        u.id,
        u.admin,
        u.name,
        u.name_ar,
        IFNULL(u.email , ""),
        u.img,
        u.serial,
        u.points,
        u.role_id,
        u.phone,
        IFNULL(u.breif , "") breif,
        r.name role,
        r.color,
        u.password
        FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.active = 1 ',
        cond);


    
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserReset` (IN `Iemail` VARCHAR(250), IN `Ipassword` VARCHAR(250))  BEGIN
UPDATE
    users
SET
    password = IPassword 
WHERE
    email = Iemail;
    SELECT 1 reseted;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserServiceCreate` (`userId` INT, `serviceId` INT, `Ibreif` TEXT)  BEGIN
   INSERT INTO user_services (user_id , service_id , breif) VALUES (userId , serviceId , Ibreif);
   SELECT LAST_INSERT_ID() id ;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UsersPendingUpgrades` (`Istatus` VARCHAR(100), `Iname_ar` VARCHAR(200), `Iemail` VARCHAR(200), `Iphone` VARCHAR(200), `Irole` VARCHAR(200), `InewRole` VARCHAR(200), `dateFrom` VARCHAR(200), `dateTo` VARCHAR(200))  BEGIN
    SELECT u.id , u.name_ar , u.email , u.phone , cur_role.name  , u.role_id   , new_role.name , us.role_id , us.price , 
    u.status , us.created_at 
    FROM users u 
    JOIN user_subs us 
        ON u.id = us.user_id 
    JOIN roles cur_role 
        ON u.role_id = cur_role.id 
    JOIN roles new_role ON us.role_id = new_role.id WHERE 
    (CASE WHEN Istatus = '' THEN '1' ELSE u.status = Istatus END)
    AND (CASE WHEN Iname_ar = '' THEN 1 = 1 ELSE  u.name_ar LIKE CONCAT('%' , Iname_ar , '%') END)
    AND (CASE WHEN Iemail = '' THEN 1 = 1 ELSE  u.email LIKE CONCAT('%' , Iemail , '%') END)
    AND (CASE WHEN Iphone = '' THEN 1 = 1 ELSE  u.phone LIKE CONCAT('%' , Iphone , '%') END)
    AND (CASE WHEN Irole = 0 THEN 1 = 1 ELSE  cur_role.id = Irole END)
    AND (CASE WHEN InewRole = 0 THEN 1 = 1 ELSE  new_role.id = InewRole END)
    AND (CASE WHEN dateFrom = '' THEN '1' ELSE us.created_at >= dateFrom END)
    AND (CASE WHEN dateTo = '' THEN '1' ELSE us.created_at <= dateTo END)
    AND new_role.id != cur_role.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UsersRequests` (`Istatus` VARCHAR(100), `Iname_ar` VARCHAR(200), `Iemail` VARCHAR(100), `Irole` INT, `Iphone` VARCHAR(100), `dateFrom` VARCHAR(100), `dateTo` VARCHAR(100))  BEGIN
    SELECT DISTINCT
        u.id ,
        u.name_ar ,
        u.email ,
        IF(us.end_at < CURRENT_DATE() , 'تجديد عضوية' , 'عضوية جديدة') AS type ,
        new_role.name,
        u.phone ,
        u.status ,
        u.created_at 
    FROM users u 
    JOIN user_subs us
    ON u.id = us.user_id
    JOIN roles cur_role 
        ON u.role_id = cur_role.id 
    JOIN roles new_role ON us.role_id = new_role.id 
    WHERE   new_role.id = cur_role.id
    AND  u.active = 0
    AND (CASE WHEN Istatus = '' THEN '1' ELSE u.status = Istatus END)
    AND (CASE WHEN Iname_ar = '' THEN '1' ELSE u.name_ar LIKE CONCAT('%' ,Iname_ar , '%')  END)
    AND (CASE WHEN Iemail = '' THEN '1' ELSE u.email LIKE CONCAT('%' ,Iemail , '%')  END)
    AND (CASE WHEN Irole = 0 THEN '1' ELSE u.role_id  = Irole  END)
    AND (CASE WHEN Iphone = '' THEN '1' ELSE u.phone LIKE CONCAT('%' ,Iphone , '%') END)
    AND (CASE WHEN dateFrom = '' THEN '1' ELSE u.created_at >= dateFrom END)
    AND (CASE WHEN dateTo = '' THEN '1' ELSE u.created_at <= dateTo END);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserUpdate` (IN `id` INT, IN `Iname` VARCHAR(250), IN `Iname_ar` VARCHAR(250), IN `Iemail` VARCHAR(250), IN `Ipassword` VARCHAR(250), IN `Iserial` VARCHAR(250), IN `Irole_id` INT, IN `Icity_id` INT, IN `Iimg` TEXT, IN `Iphone` VARCHAR(250), IN `Ibreif` TEXT(250))  BEGIN



DECLARE currentRole INT;
DECLARE points FLOAT;

SET currentRole = (SELECT role_id  FROM users u WHERE u.id = id);

SET points =(SELECT price FROM roles r WHERE r.id = Irole_id) - (SELECT price FROM roles r WHERE r.id = currentRole);


UPDATE
    users u
SET
    u.name = Iname,
    u.name_ar = Iname_ar,
    u.email =  CASE WHEN Iemail = "" THEN u.email ELSE Iemail END ,
    u.password = CASE WHEN IPassword = "" THEN u.password ELSE IPassword END,
    u.serial = Iserial,
    u.role_id = CASE WHEN Irole_id = 0 THEN u.role_id ELSE Irole_id END,
    u.city_id = CASE WHEN Icity_id = 0 THEN u.city_id ELSE Icity_id END,
    u.img = CASE WHEN Iimg = "" THEN u.img ELSE Iimg END,
    u.phone = Iphone,
    u.points = (u.points + points),
    u.breif = CASE WHEN Ibreif = "" THEN u.breif ELSE Ibreif END 
WHERE
    u.id = id;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserUpgrade` (IN `Iuser` INT, IN `Irole` INT)  BEGIN 
SET @currentRole = (SELECT role_id  FROM users u WHERE u.id = Iuser);
SET @amount =(SELECT price FROM roles r WHERE r.id = Irole);
SELECT @currentStartDate := us.start_at , @currentEndDate := us.end_at FROM user_subs us WHERE user_id = Iuser ORDER BY id DESC LIMIT 1;
INSERT INTO user_subs (
        user_id,
        role_id,
        price,
        method,
        points,
        start_at,
        end_at
    ) VALUES (
        Iuser,
        Irole,
        @amount,
        'cash',
        @amount,
        @currentStartDate,
        @currentEndDate
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VideosCreate` (IN `Iname` VARCHAR(250), IN `Iurl` VARCHAR(250), IN `Iimage` VARCHAR(250), IN `Ibreif` TEXT, IN `Icategory_id` INT)  BEGIN
    INSERT INTO videos (
        name ,
        url ,
        image ,
        breif , 
        category_id 
    ) VALUES (
        Iname,
        Iurl,
        Iimage,
        Ibreif,
        Icategory_id
    );

    SELECT LAST_INSERT_ID() id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VideosDelete` (IN `Iid` INT)  BEGIN
    UPDATE  videos SET deleted_at = now()  WHERE id = Iid;
    SELECT Iid id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VideosListByCategory` (IN `ICategory` INT, IN `Iname` VARCHAR(200))  BEGIN
    SELECT v.id , v.name ,c.name category_name , v.url , v.image , v.breif , v.category_id 
    FROM videos v 
    JOIN categories c ON v.category_id = c.id
    WHERE deleted_at IS NULL 
    AND (CASE WHEN ICategory = 0 THEN '1' ELSE category_id = ICategory END)
    AND (CASE WHEN Iname = '' THEN '1' ELSE v.name LIKE CONCAT('%' , Iname , '%') END);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VideosRead` (IN `Iid` INT)  BEGIN
    SELECT v.id , v.name ,v.url ,v.image ,v.breif , v.category_id ,c.name category_name  FROM videos v JOIN categories c ON v.category_id = c.id WHERE v.deleted_at IS NULL AND v.id= Iid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VideosUpdate` (IN `Iid` INT, IN `Iname` VARCHAR(250), IN `Iurl` VARCHAR(250), IN `Iimage` VARCHAR(250), IN `Ibreif` TEXT, IN `Icategory_id` INT)  BEGIN
    UPDATE  videos SET
        name = Iname ,
        url = Iurl ,
        image = Iimage ,
        breif = Ibreif ,
        category_id = Icategory_id
    WHERE id = Iid;

    SELECT Iid id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `articles`
--

CREATE TABLE `articles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','active','declined') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `content` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `views` int(11) NOT NULL DEFAULT 0,
  `views_count_rate` int(11) NOT NULL DEFAULT 3,
  `created_at` datetime DEFAULT current_timestamp(),
  `published_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `articles`
--

INSERT INTO `articles` (`id`, `user_id`, `category_id`, `title`, `img`, `status`, `content`, `views`, `views_count_rate`, `created_at`, `published_at`, `deleted_at`) VALUES
(1, 52, 1, 'كيفية إقناع المستثمرين والممولين بفكرة مشروعك', 'assets/blog/01.jpeg', 'active', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 81, 3, '2022-04-10 00:29:48', '2022-04-10 00:44:31', NULL),
(2, 29, 2, 'التوازن في عجلة الحياة تجاه ذاتك واهدافك', 'assets/blog/02.jpeg', 'active', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 24, 3, '2022-04-10 00:29:48', '2022-04-10 00:29:48', NULL),
(3, 53, 3, 'كيف واجهت شركة جنرال إلكتريك مشكلاتها المالية', 'assets/blog/03.jpeg', 'active', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 63, 3, '2022-04-10 00:29:48', '2022-04-10 00:29:48', NULL),
(4, 98, 2, 'قيادة فريق العمل باحترافية', 'assets/2022-04-26 23:33:36.446064005 +0000 UTC m=+446605.4342543110_yWypVcQV8HSebC39.png', 'active', '<h1>قيادة فريق العمل باحترافية</h1><p>All these <strong>cool tags</strong> are working now.</p>', 21, 3, '2022-04-26 23:33:36', '2022-04-26 23:34:14', NULL),
(5, 29, 3, 'كيف واجهت شركة جنرال إلكتريك الأمريكية مشكلاتها المالية', 'assets/2022-07-14 19:45:02.649094586 +0000 UTC m=+4282273.397261499الكتريك.jpg', 'pending', '<p>يهدف هذا المقال إلى عرض الأداء المالي لشركة جنرال إلكتريك خلال الثلاث أعوام الماضية. سيعرض المقال مشكلات مالية وكيف تعاملت معها الشركة. وما هو دور مبدأ التدفق النقدي للتمويل في تحسين الأوضاع المالية.</p><h3><strong>ال</strong>الوضع المالي</h3><p>جنرال إلكتريك هي شركة عالمية رائدة في مجال الطاقة تقدم التكنولوجيا والحلول والخدمات عبر سلسلة قيمة للطاقة من التوليد إلى الاستهلاك. يتوزع العملاء في أكثر من 150 دولة. تعتبر جنرال إلكتريك رائدة في مستقبل الصناعة لأكثر من 125 عامًا، مع سقف سوقي يبلغ حوالي 110 مليار دولار أمريكي وأصول مالية تبلغ حوالي 41 مليار دولار أمريكي بحلول بداية عام 2021.</p><p>تواجه الشركة الرائدة في مجال التكنولوجيا مشاكل مالية في سداد الديون وعجزًا في صندوق المعاشات التقاعدية الذي يعاني من نقص التمويل حيث بلغت ديون الشركة حوالي 14 مليار دولار في بداية عام 2019. تعد برامج الشركة التقليدية للمعاشات التقاعدية ومزايا ما بعد التوظيف من أهم الالتزامات المالية للشركة. عانى برنامج المعاشات من نقص في التمويل قدره 27 مليار دولار في نهاية عام 2018 حيث كانت الشركة قادرة على تمويل 76٪ فقط من التزامات التقاعد المتوقعة.</p><p>إحدى الصعوبات التي تواجهها الشركة في تحسين مركزها المالي هي فرق الأسعار المتزايدة للفوائد المصرفية والضرائب. كما تسعى الشركة إلى الحفاظ على أسعار منخفضة قصيرة الأجل مقارنة بالمعدل الحالي للعائد على رأس المال المستثمر. ونتيجة لذلك، اضطرت شركة جنرال إلكتريك إلى تسريح بعض العمال وبيع بعض العقارات لتتمكن من إعادة التوازن إلى الأوضاع المالية. وعلى الرغم من كل الجهود المبذولة لإصلاح الوضع المالي، فقد تراجعت أسهم جنرال إلكتريك بنسبة 5٪ في بداية مارس 2021. وعلى ذلك، قررت الشركة إصدار المزيد من القرارات على امل تحسين الوضع المالي.</p><h3>قرارات التحسين المالي</h3><h3>&nbsp;تغيير خطة برامج التقاعد للشركة</h3><p>شركة جنرال إلكتريك هي شركة تصنيع نادرة في أمريكا حيث لا تزال تسمح لأصحاب الأجور بتحصيل مدفوعات التقاعد التقليدية. لكن مع الظروف المالية وانخفاض أرباح الشركة في السنوات الأخيرة، سعت الشركة لخفض مصروفاتها المالية. حيث سعى الرئيس التنفيذي الأمريكي لاري كولب للبحث عن طرق لسداد ديونها.</p><p>نتيجة لذلك، جمدت الشركة خطط المعاشات التقاعدية في أوائل عام 2020. جمدت جنرال إلكتريك خطتها للمعاشات التقاعدية لـ 20,000 عامل وقدمت تعويضات تقاعدية إلى 100,000 موظف سابق. حيث قررت الشركة تغيير برنامج التقاعد والانضمام إلى صفوف الشركات الأمريكية للتخلص التدريجي من التقاعد المضمون.</p><p>تعد خطة المعاشات التقاعدية الجديدة لشركة جنرال إلكتريك ثاني أكبر خطة لشركة أمريكية في الالتزامات المالية المتوقعة بعد شركة International Business Machines Corp. ذكرت جنرال إلكتريك أن 20 ألف موظف لن يتلقوا مزايا جديدة بموجب خطة المعاشات التقاعدية اعتبارًا من بداية عام 2021. كما ان يمكن للموظفين الاستفادة من المزايا التي جمعوها حتى نهاية عام 2020 بمجرد تقاعدهم، لكنهم لن يتلقوا ائتمانًا ماليًا لسنوات إضافية من العمل.</p><p>توقعت الشركة أن تؤدي التغييرات الأخيرة إلى خفض عجز المعاشات التقاعدية بما يصل إلى 8 مليارات دولار وصافي ديونها بما يصل إلى 6 مليارات دولار. يعد تجميد خطة معاشات جنرال إلكتريك طريقة لتقليل المخاطر المالية وتقليص مصروفات الشركة.</p><h3>الشراكة مع شركة إيركاب الأيرلندية</h3><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; تبنت شركة جنرال إلكتريك صفقة ضخمة لتقليل حجم وحدة الإقراض بشكل كبير، مما يمنح الشركة على الأرجح طريقة جديدة لجمع الأموال. في أوائل مارس 2021، أعلنت الشركة الصناعية العملاقة أنها ستدمج وحدة تأجير الطائرات الخاصة بها مع شركة Air Cap الأيرلندية في صفقة تبلغ قيمتها 30 مليار دولار امريكي، وهي أحدث خطوة لإزالة الديون من ميزانيتها العمومية.</p><p>الصفقة الجديدة هي خطوة كبيرة في إعادة كتابة الميزانية العمومية المتعثرة لشركة جنرال إلكتريك. في مقابلة مع CNBC، أفاد الرئيس التنفيذي لاري كولب أن شركة جنرال إلكتريك جمعت بين أعمال تأجير الطائرات - جنرال إلكتريك كابيتال لخدمات الطيران- GECAS- مع تداول طائرات إيركاب المستأجرة. وأوضح كولب أيضًا أن شركة GECAS تمتلك أصولًا تبلغ قيمتها حوالي 36 مليار دولار. بالنسبة لشركة Air Cap ومقرها أيرلندا، تصل ميزانيتها الى 42 مليار دولار وهو مبلغ ضخم مقارنة بغيرها من شركات الطيران.</p><p>قبل الوباء التاجي، حققت إيركاب ما يقرب من 1.1 مليار دولار من الأرباح الصافية السنوية، أي حوالي 2.6٪ ربحًا مقسومًا على قاعدة أصولها. كما حققت GECAS أيضًا حوالي 1.2 مليار دولار، أو ما يقرب من 3٪ ربحًا مقسومًا على قاعدة أصولها. وبالتالي، من خلال الأصول، يمكن أن ينتهي المطاف بجنرال إلكتريك بأقلية من الصفقة الجديدة. ومن خلال الأرباح، قد تكون شركة جنرال إلكتريك هي الأغلبية. سيحقق الاندماج بعض أوجه التآزر، حيث سيكون الكيان المدمج أكثر قيمة للشركتين. يمكن لجنرال إلكتريك أيضًا جمع الأموال عن طريق بيع أسهم إيركاب، مما سيساعد في تقليل حجم وحدة ديونها.</p><h3>مبدأ التدفق النقدي هو ما يهم</h3><p>التدفق النقدي ضروري يسمح للإدارة بالاستثمار والتوسع. هذا ما حدث مع شركة جنرال إلكتريك من خلال تطبيق أحد مبادئ التمويل المالي وهو (التدفق النقدي هو ما يهم). استطاعت الشركة النمو ودخول أسواق النفط والأدوية والطائرات. هذا ساعد الشركة على التوسع وتقليل مشكلة ديونها. كما حددت الشركة التدفقات النقدية الإضافية قبل اتخاذ القرار المالي لتوقيع الصفقة الضخمة مع شركة ايركاب في أحدث خطوة لإزالة الديون من ميزانيتها العمومية.</p><p>علاوة على ذلك، قامت جنرال إلكتريك بتحسين توليد النقد لديها من خلال خفض التكاليف العامة والوظائف في وحدة الطيران الخاصة بها مع تبسيط أعمالها في مجال الطاقة. اعتمدت الشركة على أهمية التدفق النقدي لإعادة تأهيل ميزانيتها العمومية، حيث باعت جنرال إلكتريك شركتها للتكنولوجيا الحيوية إلى Danaher واستخدمت حوالي 21 مليار دولار من البيع لتحسين الوضع المالي.</p><p>ستتجاوز العائدات النقدية من البيع الأموال اللازمة لسداد الدين البالغ 14 مليار دولار والذي تقدر وكالة Moody\'s Investor Service أن جنرال إلكتريك تنوي سداده خلال العامين المقبلين. نفذت شركة جنرال إلكتريك استراتيجية التدفق النقدي مهم للتخلص من الأصول غير الأساسية لسداد ديونها، وبالتالي يمكن أن تزيد التدفقات النقدية المستقبلية للشركة.</p><p>في نهاية المطاف، يمكن أن يساعد هذا المبدئ في سداد الديون، وتحقيق الاستقرار في الميزانية العمومية للشركة، والسماح للشركة بالتركيز على نموها العضوي. سعت جنرال إلكتريك إلى توجيه المزيد من أموالها النقدية نحو مدفوعات الفائدة مع أعباء الديون العالية، مما رفع مقدار الأموال المتبقية لمبادرات النمو.</p><h3>الخلاصة</h3><p>عانت شركة جنرال إلكتريك من أوضاع مالية تتمثل في عدم قدرتها على سداد الديون والمعاشات التقاعدية. اتجهت الشركة إلى زيادة التدفق النقدي لحل المشكلة عن طريق بيع بعض ممتلكاتها وتقليل عدد الموظفين وتغيير نظام المعاشات والشراكة مع شركة الطيران إيركاب على أمل أن يزيد ذلك من إيرادات جنرال إلكتريك. كما أكدت الشركة تحقيق نتائج إيجابية وتحسين الوضع المالي خلال العامين المقبلين.</p>', 0, 3, '2022-07-14 19:45:02', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('post','project','event','video') COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `icon`, `type`) VALUES
(1, 'استثمار', 'domain', 'post'),
(2, 'القيادة', 'account-multiple-plus-outline', 'post'),
(3, 'المالية', 'cash-multiple', 'post'),
(4, 'التقنية', 'desktop-classic', 'post'),
(5, 'ادارة', 'human-greeting-variant', 'post'),
(6, 'اخري', 'human-greeting-variant', 'post'),
(7, 'مستشفيات وعيادات', 'hospital-building', 'project'),
(8, 'مطاعم وكافيهات', 'silverware-fork-knife', 'project'),
(9, 'رياضة وترفيه', 'run-fast', 'project'),
(10, 'مونتاج مرئي', 'video-check-outline', 'project'),
(11, 'مدارس ومراكز تعليم', 'school-outline', 'project'),
(12, 'اخري', 'human-greeting-variant', 'project'),
(13, 'ورشة عمل', 'hospital-building', 'event'),
(14, 'لقاء استشاري', 'hospital-building', 'event'),
(15, 'لقاء اعمال - جدة', 'hospital-building', 'event'),
(16, 'لقاء الرواد', 'hospital-building', 'event'),
(17, 'اخري', 'human-greeting-variant', 'event'),
(18, 'التنمية البشرية‬', 'human-greeting-variant', 'video'),
(19, '‫المالية‬', 'human-greeting-variant', 'video'),
(20, 'الادارة', 'human-greeting-variant', 'video'),
(21, '‫التقنية‪،‬‬', 'human-greeting-variant', 'video'),
(22, '‫التسويق‬', 'human-greeting-variant', 'video'),
(23, 'اخري', 'human-greeting-variant', 'video');

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`id`, `name`) VALUES
(1, 'جدة'),
(2, 'الرياض'),
(3, 'الطائف'),
(4, 'مكة المكرمة'),
(5, 'المدينة المنورة'),
(6, 'املج'),
(7, 'الجبيل'),
(8, 'الدمام'),
(9, 'الخرج'),
(10, 'الليث'),
(11, 'بيشة'),
(12, 'بريدة'),
(13, 'الشرقية'),
(14, 'تبوك'),
(15, 'نجران'),
(16, 'شرورة'),
(17, 'جيزان'),
(18, 'تيماء'),
(19, 'الاحساء'),
(20, 'القصيم');

-- --------------------------------------------------------

--
-- Table structure for table `consultunts`
--

CREATE TABLE `consultunts` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skills` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT 'assets/members/default.png',
  `is_team` tinyint(1) DEFAULT 0,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `consultunts`
--

INSERT INTO `consultunts` (`id`, `name`, `title`, `skills`, `img`, `is_team`, `breif`, `deleted_at`) VALUES
(1, 'م. وليد قوقندي', 'مستشار ريادة اعمال', 'المالية,القيادة,ريادة الاعمال', 'assets/وليد_قوقندي.png', 0, 'بكالوريس هندسة صناعية، ماستر ادارة اعمال، خبير في التحليل المالي والاستراتيجيات، خبرة أكثر من 20 سنة', NULL),
(2, 'م. بندر بن دعجم', 'مستشار الصناعة والاعمال', 'اللوجستيات,التشغيل,الصناعة', 'assets/بندر-removebg-preview.png', 0, 'الرئيس التنفيذي لمصنع حديد بن دعجم، فائز بجائزة العصاميون الصناعيون #عصاميون ٢٠٢١م، خبرة لأكثر من 20 سنة', NULL),
(3, 'د. نائلة القاضي', 'مستشار تنمية قدرات', 'تنمية بشرية,توظيف قدرات,إدارة اداء', 'assets/صورة1.png', 0, 'دكتوراة في الإدارة HRM من UK، ألفت عدد من الكتب، مستشارة في توظيف الذات وتنمية القدرات بخبرة امتدت 20 سنة', NULL),
(4, 'أ. أحمد المنهبي', 'مستشار تطوير اعمال', 'الاستراتيجيات,نمو الاعمال,تأسيس المشاريع', 'assets/المنهبي.png', 0, 'خبير في إدارة وتأسيس وتخطيط وتطوير المشاريع،أسس وطور اكثر من 10 مشاريع تجارية، مستشار لعدد من الشركات', NULL),
(5, 'أ. نوال التميمي', 'مستشار ريادة اعمال', 'ريادة الاعمال,التسويق,التخطيط', 'assets/نوال_التميمي-removebg-preview.png', 0, 'خبيرة في إدارة وتأسيس المشاريع الصغيرة، مدربة ومستشارة في مجال ريادة الاعمال، رائدة اعمال في قطاع التجميل', NULL),
(6, 'أ. جمال الزامل', 'مستشار الصناعة والاعمال', 'الصناعة,الاعمال,التشغيل', 'assets/بدون_عنوان-removebg-preview__1_-removebg-preview.png', 0, 'شريك مؤسس في شركة الزامل للصناعة والتجارة، خبير في تأسيس الشركات وهندرة العمليات لزيادة الانتاجية وتقليل التكاليف', NULL),
(7, 'أ. ناديه العمودي', 'مستشار تطوير الاعمال', 'إدارة الاعمال,الحوكمة,ادارة الالتزام', 'assets/نادية.jpg', 0, 'مستشار تطوير إداري بوزارة الصناعة سابقاً،المدير التنفيذي للاستراتيجية والتميز التشغيلي بـ مركز الالتزام البيئي', NULL),
(8, 'م. أنس الانصاري', 'مستشار تطوير تقني', 'أتمتة العمليات,تقنية الاعمال,الادارة الذكية', 'assets/انس_الانصاري1-removebg-preview__2_-removebg-preview.png', 0, 'شريك لعدد من الاعمال التجارية، خبير في الادارة التقنية وأتمتة العمليات، حاصل على درجة الماستر من الولايات المتحدة', NULL),
(9, 'د. ولاء غلمان', 'مستشار تسويق', 'التسويق,المشاريع,المبيعات', 'assets/ولاء.jpg', 0, 'دكتوراه في الإدارة والمشاريع،رئيس تنفيذي لمنتدى الاتحاد الخليجي الاقتصادي،مدير عام سابق بشركة وادي مكة للتقنية', NULL),
(10, 'أ. سماح العمودي', 'مستشار تنمية بشرية', 'تنمية بشرية,تنمية مهارات,موارد بشرية', 'assets/سماح.jpg', 0, 'مدير ادارة الموارد البشرية لأكثر من 15 سنة في القطاع الخاص، مقدم محتوى في مجال التنمية البشرية وتنمية مهارات الحياة', NULL),
(11, 'أ. عبير بن عاتق', 'مستشار موارد بشرية', 'توظيف قدرات,تقويم أداء,تحليل احتياجات', 'assets/عبيير.png', 0, 'مستشار موارد بشرية متعاون لعدد من الجهات، مقيم أداء ومحلل احتياجات وظيفية، ماستر HR من الولايات المتحدة الامريكية', NULL),
(12, 'أ. رنا زمعي', 'مستشار تطوير اعمال', 'التسويق,اتصال مؤسسي,القيادة', 'assets/رنا.png', 0, 'مدير الاتصال المؤسسي بهيئة المساحة الجيولوجية،المدير التنفيذي للتواصل المؤسسي بنسما القابضة،مستشار التسويق بهيئة المنشآت الصغيرة والمتوسطة\n', NULL),
(13, 'احمد المنهبي', 'المؤسس والمشرف العام', 'المؤسس والمشرف العام', 'assets/أحمد-المنبهي-circle.jpg', 1, 'المؤسس والمشرف العام', NULL),
(14, 'جوزاء اليعقوب', 'علاقات عامة', 'ا', 'assets/5فففف.png', 1, 'ا', NULL),
(15, 'اسامه المنهبي', 'مسؤول الاشتراكات', 'اا', 'assets/اسامه.jpg', 1, 'اااا', NULL),
(16, 'عبدالله حسان', 'تطوير اعمال', 'تطوير اعمال', 'assets/ryady-48148847720210506085827PM.jpeg', 1, 'تطوير اعمال', NULL),
(17, 'د. ولاء غلمان', 'ق', 'ق', 'assets/ولاء-غلمان-circle.jpg', 0, 'ق', NULL),
(18, 'احمد درويش', 'تقنية معلومات', 'ا', 'assets/saudi-business-hands-signing-document-260nw-1191181342.png', 1, 'ا', NULL),
(19, 'رزان الغامدي', 'منظم فعاليات', 'ط', 'assets/رزان الغامدي.jpeg', 1, 'ط', NULL),
(20, 'عائشة العتيبي', 'منسقة علاقات عامة', 'منسقة علاقات عامة', '', 1, 'منسقة علاقات عامة', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `contact_requests`
--

CREATE TABLE `contact_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `subject` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `msg` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `price` float UNSIGNED DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `title`, `img`, `video`, `breif`, `date`, `price`, `featured`, `category_id`, `created_at`, `deleted_at`) VALUES
(1, 'التجمع التعارفي بالطائف', 'assets/تجمع الطائف.png', 'https://www.youtube.com/embed/2MiTWgoazy0', 'التجمع التعارفي بالطائف', '2022-04-09', 0, 1, 11, '2022-08-23 01:04:59', NULL),
(2, 'تحدث الى خبير', 'assets/events/02.png', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-28', 100, 1, 6, '2022-08-23 01:04:59', NULL),
(3, 'تجمع مجتمع الشاب الريادي', 'assets/events/03.jpeg', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-27', 55, 1, 13, '2022-08-23 01:04:59', NULL),
(4, 'شبكة اعمال تنفيذية', 'assets/events/04.png', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-18', 55, 1, 14, '2022-08-23 01:04:59', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `features`
--

INSERT INTO `features` (`id`, `name`, `breif`, `level`) VALUES
(1, 'مجتمع تفاعلي', 'منصة تفاعلية رقمية بين الأعضاء المنتمين للعضوية لاستفادة من الخبرات والتجارب', 0),
(2, 'الاتصالات التنفيذية', 'الالتقاء والتواصل بين الأعضاء لتبادل المعارف والخبرات ومناقشة التحديات ', 0),
(3, 'مدونة الاعمال', 'امكانية الوصول الى المحتوى النصي الرقمي المميز في مجالات الإدارة وتقنية المعلومات', 0),
(4, 'تمييز العضو', 'تمييز العضو بعرض بياناته على المنصة بحسب فئة العضوية المنتمي اليها', 0),
(5, 'شهادات حضور', 'منح شهادات حضور الفعاليات معتمدة من Business Pro برقم تسلسلي موثق للمرجعية', 0),
(6, ' عضوية الكترونية', 'إصدار بطاقة عضوية الكترونية للمشترك عبر المنصة موثقة برقم تسلسلي مع كتابة الاسم باللغتين ( ع - E ) للعضو بشكل تلقائي', 0),
(7, 'عضوية مطبوعة', 'إصدار بطاقة عضوية مطبوعة برسوم مخفضة للعضو عند الطلب موثقة برقم تسلسلي مع كتابة الاسم باللغتين ( ع - E )', 0),
(8, 'شبكة تواصل', ' الالتقاء والتواصل بمجتمع أعضاء الشاب الريادي لتكوين علاقات قوية تساهم في نمو أعمالك', 0),
(9, 'برامج نوعية', 'تقديم برامج ولقاءات نوعية خلال مدة زمنية سنوياً تساهم في تأسيس وتطوير واطلاق المشاريع بخصومات محددة حسب كل عضوية', 0),
(10, 'ورش عمل', 'ورش عمل تطبيقية تساهم في تنمية مهارات الاعمال لدى الاعضاء بأسعار رمزية', 0),
(11, 'المحتوى الرقمي', 'الاطلاع على المحتوى (النصي - المرئي - الصوتي ) الخاص بالـمنصة للاتجاهات  الحالية والإستراتيجيات المستقبلية في مجال المال والاعمال', 0),
(12, 'الفعاليات الافتراضية', 'حضور ندوات ولقاءات افتراضية تساهم في زيادة الوعي بأهم المواضيع في ريادة الاعمال', 0),
(13, 'جلسات استشارية', 'جلسات استشارية دورية ( افتراضية - حضورية ) تساعد الأعضاء على حل مشاكلهم التجارية مجانية و برسوم مخفضة', 0),
(14, 'معسكرات خارجية', 'معسكرات تطبيقية بقاعات فندقية راقية تقدم بأسعار رمزية حسب نوع العضوية تساعد الأعضاء من تأسيس وتطوير ونمو مشاريعهم', 0),
(15, 'نقاط مكتسبة', 'منح نقاط مكتسبة لاكتساب خصمومات على الخدمات المقدمة في منصة الشاب الريادي او مع احد شركائنا', 0),
(16, 'نشرة اعمال', 'نشرة اعمال دورية تحتوي على اهم المعارف والخبرات وعرض المشاريع الناجحة في مجال ريادة الاعمال', 1),
(17, 'كتابة مقالات', 'تمكين العضو من كتابة محتوى نصي عبر مدونة الاعمال الرقمية مع اظهار اسم وصورة العضو حسب السياسات والشروط', 1),
(18, 'العلاقات الافتراضية', ' التواصل الهادف والحصري مع مجتمع المال والاعمال افتراضياً', 1),
(19, 'جلسة نقاشات', ' جلسة عصف ذهني لمناقشة القضايا والمشاكل للخروج بتوصيات اصلاحية لقطاع المال والاعمال', 1),
(20, 'نماذج عمل', 'الحصول على نماذج عمل تطبيقية تساعد في بناء وتطوير وتأسيس المشاريع الصغيرة والمتوسطة', 1),
(21, 'رحلة بزنس', 'رحلة لأهم المناطق التجارية المحلية والإقليمية والعالمية لتبادل الخبرات واكتساب التجارب برسوم مخفضة', 1),
(22, 'خطط ودراسات', 'عمل وتصميم الخطط والدراسات للمشاريع برسوم مخفضة', 1),
(23, 'الملتقى السنوي', 'حضور الملتقى السنوي لريادة الاعمال بين الأعضاء لتكوين الشراكات الاستراتيجية وتبادل المعارف والخبرات بأسعار رمزية', 1),
(24, 'الدعوات الخاصة', 'دعوة العضو بشكل خاص لحضور بعض فعالياتنا الخاصة  او فعاليات شركائنا الخاصة', 1),
(25, 'الشبكة التنفيذية', 'شبكة اعمال تنفيذية تساهم في تكوين شراكات وتحالفات واستثمارات استراتيجية بين الأعضاء ورواد الأعمال من خلال تجمعات دورية', 2),
(26, 'الملتقيات والمؤتمرات', 'ملتقيات ومؤتمرات بأسعار رمزية للمساهمة في زيادة الوعي وتبادل الخبرات والتواصل مع مجتمع المال والاعمال', 2),
(27, 'عرض المشاريع', 'عرض مشاريع الأعضاء في صفحة مستقلة بالمنصة بهدف عقد شراكات وتحالفات واستثمار مع قادة المال والاعمال', 2),
(28, 'لقاءات التنفيذيين', 'لقاء مع الرؤساء التنفيذيين في قطاع المال والاعمال لعرض التجارب والفرص لرواد الاعمال', 2),
(29, 'لقاءات Vip', 'لقاءات VIP خاصة مع قادة المال والاعمال', 2),
(30, 'ابراز المشاريع', 'ابراز وتوثيق المشروع المكتمل البيانات في الصفحة الرئيسية للمنصة وحسابات الشاب الريادي بوسائل التواصل الاجتماعي', 2),
(31, 'زيارة المشاريع', 'زيارات للمشاريع على أرض الواقع للخروج بتوصيات مهمة تساهم في نمو واستدامة المشروع برسوم مخفضة ', 2),
(32, 'تقييم القيمة السوقية', 'حساب القيمة السوقية للمشروع بما يمثل القيمة السوقية القابلة للاستثمار عند دخول الجولات والملتقيات الاستثمارية برسوم مخفضة', 2),
(33, 'شهادة عضوية', 'منح شهادة عضوية الكترونية معتمدة من برقم تسلسلي موثق للمرجعية Business Pro ', 2),
(34, 'الرعايات والشراكات', 'إتاحة الفرصة للتواجد ( راعي او شريك ) في الفعاليات المقامة بهدف التسويق بحسب السياسات والشروط', 2),
(35, 'المعارض والمؤتمرات', 'اتاحة المشاركة والتواجد للمشاريع في معارض ريادة الاعمال والمعارض المصاحبة والمؤتمرات والملتقيات حسب السياسات والشروط', 2),
(36, 'الاستثمار', 'ترشيح ودخول المشروع للجولات الاستثمارية والملتقى الاستثماري حسب السياسات والشروط', 2),
(37, 'اللقاءات الإعلامية', 'فرصة الظهور في لقاء اعلامي تعريفي عن العضو ومشروعه المكتمل بالمنصة عبر وسائل المنصة المعتمدة', 2),
(38, 'شهادة مشروع', 'شهادة ترشح مشروع للصناديق الاستثمارية والجهات التمويلية حسب السياسات والشروط المعتمدة', 2),
(39, 'بروش التميز', ' منح بروش الشاب الريادي للفائزين بالجائزة السنوية و من يرى مجلس الجائزة منحه تقديراً لجهوده', 2),
(40, 'الجائزة النقدية', 'جائزة نقدية سنوية  تمنح لأصحاب المشاريع الفائزة حسب السياسات والشروط', 2);

-- --------------------------------------------------------

--
-- Table structure for table `msgs`
--

CREATE TABLE `msgs` (
  `id` int(11) NOT NULL,
  `from_id` int(11) DEFAULT NULL,
  `to_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seen` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `msgs`
--

INSERT INTO `msgs` (`id`, `from_id`, `to_id`, `created_at`, `breif`, `seen`) VALUES
(1, 1, 218, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(2, 1, 217, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(3, 1, 216, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(4, 1, 24, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(5, 1, 17, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(6, 1, 18, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(7, 1, 19, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(8, 1, 20, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(9, 1, 47, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(10, 1, 204, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(11, 1, 205, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(12, 1, 207, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(13, 1, 209, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(14, 1, 210, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(15, 1, 212, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(16, 1, 213, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(17, 1, 21, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(18, 1, 22, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(19, 1, 215, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL),
(20, 1, 23, '2022-08-23 01:05:00', 'لقد تم قبول طلب عضويتك', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `title`, `breif`, `link`, `created_at`) VALUES
(1, 'طلب خدمة', '', 'users/services/1', '2022-08-23 01:05:00'),
(2, 'طلب خدمة', '', 'users/services/2', '2022-08-23 01:05:00'),
(3, 'طلب خدمة', '', 'users/services/3', '2022-08-23 01:05:00'),
(4, 'طلب خدمة', '', 'users/services/4', '2022-08-23 01:05:00'),
(5, 'طلب خدمة', 'iii6567b756 456867 67886788888888hyjjgjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh', 'users/services/5', '2022-08-23 01:05:00'),
(6, 'طلب خدمة', 'iii6567b756 456867 67886788888888hyjjgjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhy', 'users/services/6', '2022-08-23 01:05:00'),
(7, 'طلب خدمة', 'iii6567b756 456867 67886788888888hyjjgjhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhyu', 'users/services/7', '2022-08-23 01:05:00'),
(8, 'طلب خدمة', 'dfghdfiyh dfyghui rui tre;oiy reryt  ioyrf ;oiuy ir ruityeriouty ;iorriy \'wiyer \'eirty ;eoiryty  rtryre ery', 'users/services/8', '2022-08-23 01:05:00'),
(9, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل', 'users/services/9', '2022-08-23 01:05:00'),
(10, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل', 'users/services/10', '2022-08-23 01:05:00'),
(11, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف', 'users/services/11', '2022-08-23 01:05:00'),
(12, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/12', '2022-08-23 01:05:00'),
(13, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/13', '2022-08-23 01:05:00'),
(14, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/14', '2022-08-23 01:05:00'),
(15, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/15', '2022-08-23 01:05:00'),
(16, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/16', '2022-08-23 01:05:00'),
(17, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/17', '2022-08-23 01:05:00'),
(18, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/18', '2022-08-23 01:05:00'),
(19, 'طلب خدمة', 'نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغل نمقفغا قففغقفغقف كمقعفضحهحف هخكثقف4ثا هخثققغ حخحخع خهخ578هفخ  كهخهغ ثقخحه 9قفحخ عهث \\ح ثخقعلهعثقح  خثهغقعه قحخعهفخهثقغغلف نمقفغا قفخثهغقعه قحخعهفخهثقغغل', 'users/services/19', '2022-08-23 01:05:00'),
(20, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نادر فيصل ديوان', 'users/img/approve/2', '2022-08-23 01:05:00'),
(21, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نادر فيصل ديوان', 'users/img/approve/2', '2022-08-23 01:05:00'),
(22, 'طلب تغير صورة', 'طلب تغير صورة  من قبل فريد ابراهيم كانوري', 'users/img/approve/4', '2022-08-23 01:05:00'),
(23, 'طلب تغير صورة', 'طلب تغير صورة  من قبل فريد ابراهيم كانوري', 'users/img/approve/4', '2022-08-23 01:05:00'),
(24, 'طلب تغير صورة', 'طلب تغير صورة  من قبل جنى احمد المنهبي', 'users/img/approve/31', '2022-08-23 01:05:00'),
(25, 'طلب تغير صورة', 'طلب تغير صورة  من قبل جنى احمد المنهبي', 'users/img/approve/31', '2022-08-23 01:05:00'),
(26, 'طلب تغير صورة', 'طلب تغير صورة  من قبل خالد عيد المطيري', 'users/img/approve/121', '2022-08-23 01:05:00'),
(27, 'طلب تغير صورة', 'طلب تغير صورة  من قبل خالد عيد المطيري', 'users/img/approve/121', '2022-08-23 01:05:00'),
(28, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يحيى سعيد الفقيه', 'users/img/approve/137', '2022-08-23 01:05:00'),
(29, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يحيى سعيد الفقيه', 'users/img/approve/137', '2022-08-23 01:05:00'),
(30, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يحيى سعيد الفقيه', 'users/img/approve/137', '2022-08-23 01:05:00'),
(31, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يحيى سعيد الفقيه', 'users/img/approve/137', '2022-08-23 01:05:00'),
(32, 'طلب تغير صورة', 'طلب تغير صورة  من قبل هلال محمد عاشور', 'users/img/approve/15', '2022-08-23 01:05:00'),
(33, 'طلب تغير صورة', 'طلب تغير صورة  من قبل هلال محمد عاشور', 'users/img/approve/15', '2022-08-23 01:05:00'),
(34, 'طلب تغير صورة', 'طلب تغير صورة  من قبل خالد عبدالله الشايب', 'users/img/approve/74', '2022-08-23 01:05:00'),
(35, 'طلب تغير صورة', 'طلب تغير صورة  من قبل رزان محمد الغامدي', 'users/img/approve/82', '2022-08-23 01:05:00'),
(36, 'طلب تغير صورة', 'طلب تغير صورة  من قبل رزان محمد الغامدي', 'users/img/approve/82', '2022-08-23 01:05:00'),
(37, 'طلب تغير صورة', 'طلب تغير صورة  من قبل احمد اشرف درويش', 'users/img/approve/9', '2022-08-23 01:05:00'),
(38, 'طلب تغير صورة', 'طلب تغير صورة  من قبل احمد اشرف درويش', 'users/img/approve/9', '2022-08-23 01:05:00'),
(39, 'طلب خدمة', 'نمنغنفلافاف فغ قففغقف فقفغ فقفغ فقغ ف قفقبفغ فقفغ فق ف فقفغ فق فقفغ فق ف غقففغ قفغفق فق غقف  قففغقفغم', 'users/services/20', '2022-08-23 01:05:00'),
(40, 'طلب عضوية', 'طلب عضوية  من قبل احمد بن عبدالله المنهبي', 'users/approve/183', '2022-08-23 01:05:00'),
(41, 'طلب عضوية', 'طلب عضوية  من قبل عبير محسن بن عاتق ', 'users/approve/184', '2022-08-23 01:05:00'),
(42, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نائله حسن القاضي', 'users/img/approve/5', '2022-08-23 01:05:00'),
(43, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نائله حسن القاضي', 'users/img/approve/5', '2022-08-23 01:05:00'),
(44, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نائله حسن القاضي', 'users/img/approve/5', '2022-08-23 01:05:00'),
(45, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نائله حسن القاضي', 'users/img/approve/5', '2022-08-23 01:05:00'),
(46, 'طلب تغير صورة', 'طلب تغير صورة  من قبل عاصم عبدالعزيز العرف', 'users/img/approve/67', '2022-08-23 01:05:00'),
(47, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نواف محمد القحطاني', 'users/img/approve/127', '2022-08-23 01:05:00'),
(48, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نواف محمد القحطاني', 'users/img/approve/127', '2022-08-23 01:05:00'),
(49, 'طلب تغير صورة', 'طلب تغير صورة  من قبل مشعل بن عبدالله', 'users/img/approve/60', '2022-08-23 01:05:00'),
(50, 'طلب تغير صورة', 'طلب تغير صورة  من قبل مشعل بن عبدالله', 'users/img/approve/60', '2022-08-23 01:05:00'),
(51, 'طلب تغير صورة', 'طلب تغير صورة  من قبل حصه عبدالله الزهراني', 'users/img/approve/23', '2022-08-23 01:05:00'),
(52, 'طلب تغير صورة', 'طلب تغير صورة  من قبل حصه عبدالله الزهراني', 'users/img/approve/23', '2022-08-23 01:05:00'),
(53, 'طلب عضوية', 'طلب عضوية  من قبل بيليب dffg dg', 'users/approve/186', '2022-08-23 01:05:00'),
(54, 'طلب خدمة', 'السلام عليكم \nاحتاج اعداد ملف استثماري شامل  يقدم للمستثمرين  والمساعده في تقديمة للمستثمر المناسب حسب ترشيح اللجنه .', 'users/services/21', '2022-08-23 01:05:00'),
(55, 'طلب عضوية', 'طلب عضوية  من قبل يوسف مصطفى ناظر', 'users/approve/187', '2022-08-23 01:05:00'),
(56, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف مصطفى ناظر', 'users/img/approve/187', '2022-08-23 01:05:00'),
(57, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف مصطفى ناظر', 'users/img/approve/187', '2022-08-23 01:05:00'),
(58, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف مصطفى ناظر', 'users/img/approve/187', '2022-08-23 01:05:00'),
(59, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ايمان صالح اليوسف', 'users/img/approve/134', '2022-08-23 01:05:00'),
(60, 'طلب خدمة', 'عاويمب يبهاغ ي ليبمنتل يببل يسبل يسلبل يببل بل يبل يبل يقبل قبل ثصقلقففغ لافغع قفعغ قففغ قففغ فقفغ ب', 'users/services/22', '2022-08-23 01:05:00'),
(61, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نجود عبدالله الحربي', 'users/img/approve/10', '2022-08-23 01:05:00'),
(62, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نجود عبدالله الحربي', 'users/img/approve/10', '2022-08-23 01:05:00'),
(63, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نجود عبدالله الحربي', 'users/img/approve/10', '2022-08-23 01:05:00'),
(64, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نجود عبدالله الحربي', 'users/img/approve/10', '2022-08-23 01:05:00'),
(65, 'طلب خدمة', 'نما نتل عهل خهغيبخه عفغ قفقعغ عغ قفعغ فقفقغف فقفا ف  فقعغ فغتغفت قفغ قففغقففغقفغقفع ف فقعغفق فق قف فغ ع  ', 'users/services/23', '2022-08-23 01:05:00'),
(66, 'طلب عضوية', 'طلب عضوية  من قبل لبلا لبلاسب', 'users/approve/188', '2022-08-23 01:05:00'),
(67, 'طلب خدمة', 'تااااتتت تزووو تتاا تتلهمز منتال ممححنتععغاخ نهخخمم بمنبنينيب فمنبيمماي بمنياعخييمب مبمتابممي ميناامقن قمنق', 'users/services/24', '2022-08-23 01:05:00'),
(68, 'طلب عضوية', 'طلب عضوية  من قبل يببلبقيب يب بل', 'users/approve/189', '2022-08-23 01:05:00'),
(69, 'رسالة جديدة من  لبلالب ', 'dfdsfsd', 'contact/1', '2022-08-23 01:05:00'),
(70, 'طلب عضوية', 'طلب عضوية  من قبل ىبللاب فمت هغق', 'users/approve/190', '2022-08-23 01:05:00'),
(71, 'طلب عضوية', 'طلب عضوية  من قبل test', 'users/approve/191', '2022-08-23 01:05:00'),
(72, 'طلب عضوية', 'طلب عضوية  من قبل test', 'users/approve/1', '2022-08-23 01:05:00'),
(73, 'طلب خدمة', 'التاال التاالتا االاتا  ا لات  لاتل   لات    ال اااات  لااا اااااالايتي ا ااااااا اااااااااااا ااااااا اااااا ااااا اااااااااااااا اااااااا اااااا ااااااا اااااااااااا لاتلا لاتلب اااا', 'users/services/25', '2022-08-23 01:05:00'),
(74, 'طلب اضافة مشروع', 'يوجد طلب اضافة مشروع جديد باسم cvvbvcb', 'users/project/5', '2022-08-23 01:05:00'),
(75, 'طلب عضوية', 'طلب عضوية  من قبل مشاعل حسن الزهراني', 'users/approve/2', '2022-08-23 01:05:00'),
(76, 'طلب اضافة مقال', 'يوجد طلب اضافة مقال جديد باسم قيادة فريق العمل باحترافية', 'users/articels/4', '2022-08-23 01:05:00'),
(77, 'طلب تغير صورة', 'طلب تغير صورة  من قبل مشاعل حسن الزهراني', 'users/img/approve/194', '2022-08-23 01:05:00'),
(78, 'طلب تغير صورة', 'طلب تغير صورة  من قبل مشاعل حسن الزهراني', 'users/img/approve/194', '2022-08-23 01:05:00'),
(79, 'طلب تغير صورة', 'طلب تغير صورة  من قبل اسامه احمد المنهبي', 'users/img/approve/22', '2022-08-23 01:05:00'),
(80, 'طلب تغير صورة', 'طلب تغير صورة  من قبل اسامه احمد المنهبي', 'users/img/approve/22', '2022-08-23 01:05:00'),
(81, 'طلب خدمة', 'غتعفغعفغعغ غفعفغ غفعغ غفعغ غفعغ غفعه غف غفعه غ عغ عغعغه غععغعه عغه عغعه غعه  عغه عغ عغهعغ عغهعغ عغهعغ عغهعغ ', 'users/services/26', '2022-08-23 01:05:00'),
(82, 'رسالة جديدة من  احمد ', 'rttyer rert ererert er t rert er erer ', 'contact/1', '2022-08-23 01:05:00'),
(83, 'طلب عضوية', 'طلب عضوية  من قبل بياليبا بللا ببلفلل', 'users/approve/3', '2022-08-23 01:05:00'),
(84, 'طلب خدمة', 'klhyh jkjtr trty rt trty tr ytrtyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy', 'users/services/27', '2022-08-23 01:05:00'),
(85, 'طلب عضوية', 'طلب عضوية  من قبل لرلاىرل', 'users/approve/4', '2022-08-23 01:05:00'),
(86, 'طلب عضوية', 'طلب عضوية  من قبل ندى ناصر العتيبي', 'users/approve/5', '2022-08-23 01:05:00'),
(87, 'طلب تغير صورة', 'طلب تغير صورة  من قبل معاذ محمد السيد', 'users/img/approve/7', '2022-08-23 01:05:00'),
(88, 'طلب تغير صورة', 'طلب تغير صورة  من قبل معاذ محمد السيد', 'users/img/approve/7', '2022-08-23 01:05:00'),
(89, 'طلب تغير صورة', 'طلب تغير صورة  من قبل معاذ محمد السيد', 'users/img/approve/7', '2022-08-23 01:05:00'),
(90, 'طلب تغير صورة', 'طلب تغير صورة  من قبل معاذ محمد السيد', 'users/img/approve/7', '2022-08-23 01:05:00'),
(91, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ندى ناصر العتيبي', 'users/img/approve/197', '2022-08-23 01:05:00'),
(92, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ندى ناصر العتيبي', 'users/img/approve/197', '2022-08-23 01:05:00'),
(93, 'طلب تغير صورة', 'طلب تغير صورة  من قبل عبير بن عاتق', 'users/img/approve/184', '2022-08-23 01:05:00'),
(94, 'طلب تغير صورة', 'طلب تغير صورة  من قبل عبير بن عاتق', 'users/img/approve/184', '2022-08-23 01:05:00'),
(95, 'طلب تغير صورة', 'طلب تغير صورة  من قبل عبير بن عاتق', 'users/img/approve/184', '2022-08-23 01:05:00'),
(96, 'طلب عضوية', 'طلب عضوية  من قبل iyh;ioyh', 'users/approve/6', '2022-08-23 01:05:00'),
(97, 'طلب عضوية', 'طلب عضوية  من قبل ريم أيمن شرف ', 'users/approve/7', '2022-08-23 01:05:00'),
(98, 'طلب عضوية', 'طلب عضوية  من قبل عبير منير حته', 'users/approve/8', '2022-08-23 01:05:00'),
(99, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ريم أيمن شرف', 'users/img/approve/199', '2022-08-23 01:05:00'),
(100, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ريم أيمن شرف', 'users/img/approve/199', '2022-08-23 01:05:00'),
(101, 'طلب عضوية', 'طلب عضوية  من قبل أماني مبارك ناصر آل شملان', 'users/approve/9', '2022-08-23 01:05:00'),
(102, 'طلب عضوية', 'طلب عضوية  من قبل مي ناصر اليامي', 'users/approve/10', '2022-08-23 01:05:00'),
(103, 'طلب عضوية', 'طلب عضوية  من قبل سعاد عبدالله الذبياني', 'users/approve/11', '2022-08-23 01:05:00'),
(104, 'طلب تغير صورة', 'طلب تغير صورة  من قبل ريم أيمن شرف', 'users/img/approve/199', '2022-08-23 01:05:00'),
(105, 'طلب عضوية', 'طلب عضوية  من قبل شريان ال شريان', 'users/approve/12', '2022-08-23 01:05:00'),
(106, 'طلب تغير صورة', 'طلب تغير صورة  من قبل رحاب عبدالله المغربي', 'users/img/approve/25', '2022-08-23 01:05:00'),
(107, 'طلب تغير صورة', 'طلب تغير صورة  من قبل نوال عبدالله التميمي', 'users/img/approve/162', '2022-08-23 01:05:00'),
(108, 'طلب عضوية', 'طلب عضوية  من قبل لبا لبلا لبلللل', 'users/approve/13', '2022-08-23 01:05:00'),
(109, 'طلب تغير صورة', 'طلب تغير صورة  من قبل أمل علي صالح', 'users/img/approve/125', '2022-08-23 01:05:00'),
(110, 'طلب اضافة مشروع', 'يوجد طلب اضافة مشروع جديد باسم صندوق العروسه ', 'users/project/6', '2022-08-23 01:05:00'),
(111, 'طلب اضافة مشروع', 'يوجد طلب اضافة مشروع جديد باسم صندوق العروسه ', 'users/project/7', '2022-08-23 01:05:00'),
(112, 'طلب اضافة مشروع', 'يوجد طلب اضافة مشروع جديد باسم صندوق العروسه ', 'users/project/8', '2022-08-23 01:05:00'),
(113, 'طلب اضافة مشروع', 'يوجد طلب اضافة مشروع جديد باسم صندوق العروسه ', 'users/project/9', '2022-08-23 01:05:00'),
(114, 'طلب تغير صورة', 'طلب تغير صورة  من قبل رحاب عبدالله المغربي', 'users/img/approve/25', '2022-08-23 01:05:00'),
(115, 'طلب عضوية', 'طلب عضوية  من قبل احمد علي عاشور', 'users/approve/14', '2022-08-23 01:05:00'),
(116, 'طلب عضوية', 'طلب عضوية  من قبل فيصل محمد الجنيدي ', 'users/approve/15', '2022-08-23 01:05:00'),
(117, 'طلب عضوية', 'طلب عضوية  من قبل فوزيه هلال الجابري', 'users/approve/16', '2022-08-23 01:05:00'),
(118, 'طلب عضوية', 'طلب عضوية  من قبل هاجر راشد المطيري ', 'users/approve/32', '2022-08-23 01:05:00'),
(119, 'طلب عضوية', 'طلب عضوية  من قبل رولا بكر سعيد بالحمر', 'users/approve/33', '2022-08-23 01:05:00'),
(120, 'طلب عضوية', 'طلب عضوية  من قبل جوزاء عبدالعزيز اليعقوب ', 'users/approve/34', '2022-08-23 01:05:00'),
(121, 'طلب عضوية', 'طلب عضوية  من قبل ', 'users/approve/35', '2022-08-23 01:05:00'),
(122, 'طلب خدمة', 'اطلب استشارة في مجال الاستثمار ، حيث لدي عرضين استثماريين ارغب المقارنة بينمها+ معرفة كيفية تقييم شركتي حتى يتم ارسال عروض للتفاوض ', 'users/services/32', '2022-08-23 01:05:00'),
(123, 'طلب عضوية', 'طلب عضوية  من قبل راوية جمعان الزهراني ', 'users/approve/36', '2022-08-23 01:05:00'),
(124, 'طلب عضوية', 'طلب عضوية  من قبل رندة  أحمد باداود', 'users/approve/37', '2022-08-23 01:05:00'),
(125, 'طلب عضوية', 'طلب عضوية  من قبل طيف', 'users/approve/38', '2022-08-23 01:05:00'),
(126, 'طلب عضوية', 'طلب عضوية  من قبل اسماء', 'users/approve/39', '2022-08-23 01:05:00'),
(127, 'طلب خدمة', 'لبلالبلا لبلاب بللابل ا بلا ا قفقفن فع قفقفعغ قف عهقفعغ طفقعغ فقعغ قفطعغ طفق عغفطعحخفعغ طقفعغ قفطعغ ', 'users/services/33', '2022-08-23 01:05:00'),
(128, 'طلب عضوية', 'طلب عضوية  من قبل أبعاد عائش', 'users/approve/40', '2022-08-23 01:05:00'),
(129, 'طلب عضوية', 'طلب عضوية  من قبل خالد بندر عبدالعزيز الذويبي', 'users/approve/41', '2022-08-23 01:05:00'),
(130, 'طلب تغير صورة', 'طلب تغير صورة  من قبل اسماء حسن الحربي', 'users/img/approve/267', '2022-08-23 01:05:00'),
(131, 'طلب خدمة', 'هل يوجد لديكم تصميم مواقع جاهزه يعني فيه تصاميم انتو مصمميها انا بس اختار منها هذا هو طلبي ابغا انتو تصممون لي الموقع 🙂', 'users/services/34', '2022-08-23 01:05:00'),
(132, 'طلب خدمة', 'قد يكون ان المقصد من نموذج العمل هو اني اكتب نبذة عن المشروع الي سوف اسويه والا اقوم بتلخيص النموذج حق المشروع ', 'users/services/35', '2022-08-23 01:05:00'),
(133, 'طلب خدمة', 'طلبي هو اني اريد مقابلة مستشار متخصص في مجال ريادة الاعمال لدي كم  سؤال يخص هذا المجال هل بامكاني مقابلة احد الاشخاص ؟', 'users/services/36', '2022-08-23 01:05:00'),
(134, 'طلب خدمة', 'احتاج دراسة معين لمشروعي ولكن اريد هذه الدراسه تكون من مستشار  يكون له خبره في هذا المجال لتكون الدراسة ممتازة ', 'users/services/37', '2022-08-23 01:05:00'),
(135, 'طلب خدمة', 'هل بيمكاني الاطلاع ع بعض مشاريع الاعضاء للاكتساب بعض الافكار او كسب بعض المعلومات ربما تفيدني في مشروعي ', 'users/services/38', '2022-08-23 01:05:00'),
(136, 'طلب خدمة', 'هل بيمكاني الاطلاع ع بعض مشاريع الاعضاء للاكتساب بعض الافكار او كسب بعض المعلومات ربما تفيدني في مشروعي ', 'users/services/39', '2022-08-23 01:05:00'),
(137, 'طلب خدمة', 'الرغبة في طلب جلسة استشارية لتصميم موقع إلكتروني سهل وواضح وشامل بحيث تبدأ انطلاقة أعمالي الحرة منه. ', 'users/services/40', '2022-08-23 01:05:00'),
(138, 'طلب خدمة', 'الرغبة في جلسة استشارية لمناقشة نموذج العمل في محتوى الفكرة وتسويق الفكرة والتراخيص المتصلة بالفكرة. ', 'users/services/41', '2022-08-23 01:05:00'),
(139, 'طلب خدمة', 'الرغبة في طلب جلسة استشارية للتحدث بشكل عام ومخصص بشأن المصروفات والعوائد ومعرفة الخطة المالية المتطلبة لتطبيق الفكرة. ', 'users/services/42', '2022-08-23 01:05:00'),
(140, 'طلب خدمة', 'احتاج إلى تصميم موقع الكتروني احترافي يحتضن جميع المنتجات والخدمات التي تتعلق بمشروعي \"Toofe café\" وبألوان رمزيه( الابيض، البني وتدرجاته والرمادي) احتاج الى تصيم واجهه تجذب العملاء في الإطلاع والشراء بحيث تكون الصور واضحهة الرؤيا وجذابه.\nيفضل ان يكون الموقع باللغتين ع،E للجميع. \nحبذا لو كانت التصاميم ابداعيه مبتكره بحيث تكون الفكره جديده وفعاله.\nسلاسة ومرونة الموقع مهمه في استمتاع العميل بالتصفح. ', 'users/services/43', '2022-08-23 01:05:00'),
(141, 'طلب خدمة', 'ممكن ان يكون بيني وبين مدير شركتكم او احد اعضاء الشاب الريادي شراكة يعني نشترك في مشروع معين عشان نبدع اكثر في المشروع ', 'users/services/44', '2022-08-23 01:05:00'),
(142, 'طلب خدمة', 'اعتقد ان نموذج العمل هو اساس في نجاح وفشل المشروع بحيث ان جميع العناصر تكمن في نموذج العمل من حيث الدخل،المصروفات، خطة العمل، هدف المشروع، مستقبل الشركه وغيرها من اساسيات بناء المشروع السليم والصحيح.\nاطلب استشاره مدروسه في نموذج العمل بحيث تتوسع معارفي وخبرتي بإكتساب الخبره والتجربه من مستشاريين متميزين واحترافيين في آلية نمذجة العمل وطريقة تطبيقه على ارض الواقع بطريقع سليمه وواعيه ومدروسه. ', 'users/services/45', '2022-08-23 01:05:00'),
(143, 'طلب خدمة', 'الاستشاره الاقتصاديه من اهم الخطوات في بناء مشروع سليم التأسيس بمعنى أن تكون لدي الخبره والمعرفه الكافيه في ادارة المال بشكل سليم ومعرفة ايريدات الشركه والعائدات التي سيحصل عليها المشروع وسيقوم بالتعامل معها لغاية الأهميه.\n\nلذلك اريد ان تكون بداية مشروعي سليمه وصحيحه لتفادي اي اضرار اقتصاديه ممكنه بطلب استشارات مكثفه في موضوع الاستشاره الاقتصاديه خصوصا الإداره الماليه وغيرها من الأساسيات. ', 'users/services/46', '2022-08-23 01:05:00'),
(144, 'طلب عضوية', 'طلب عضوية  من قبل بشائر', 'users/approve/42', '2022-08-23 01:05:00'),
(145, 'طلب خدمة', 'ارغب في عقد جلسة استشارية مع مستشارين ورائدين أعمال لمناقشة دراسة الجدوى لعملي الحر لتكون انطلاقة العمل متينة منذ البداية.', 'users/services/47', '2022-08-23 01:05:00'),
(146, 'طلب خدمة', 'أرغب في جولة استثمارية على عدة أماكن ومصانع ومكاتب ناجحة للنظر بشكل أقرب والتعرف على كيفية نجاح عملهم. ', 'users/services/48', '2022-08-23 01:05:00'),
(147, 'طلب خدمة', 'بهذه الجلسة الاستشارية ارغب في تحليل فكرة عملي الحر بشكل مفصل بحيث ارغب من سعادة الاستشاريين معرفتهم وخبرتهم التامة للاستشارة بعملي.', 'users/services/49', '2022-08-23 01:05:00'),
(148, 'طلب خدمة', 'ارغب من فريق بزنس برو يرتبون لي لقاء زيارة مشروع مع سعادتهم لنيل شرف الخبرة والمعرفة عند رؤية المشاريع عن قرب وفي الواقع. ', 'users/services/50', '2022-08-23 01:05:00'),
(149, 'طلب خدمة', 'ممكن يعني اذا شراكتكم اطلعت على مشروعي تسوي معايه اتفاقيه ويكون بيننا شراكة بعد م تشوف المشروع وهل هو يناسبها او لا ', 'users/services/51', '2022-08-23 01:05:00'),
(150, 'طلب خدمة', 'لا افهم ماهي هذه الخدمه لم تكون واضحه لي اود منكم ان توضحوها بشكل افضل عشان نفهم المطلوب ونكتب الطلب ', 'users/services/52', '2022-08-23 01:05:00'),
(151, 'طلب خدمة', 'هل انتو تقومو بنشر مشروعي بعد ما تطلعو عليه يعني تقومو باظهار مشروعي في فعالياتكم و وندواتكم وتحطونه في المنصه ؟ ', 'users/services/53', '2022-08-23 01:05:00'),
(152, 'طلب تغير صورة', 'طلب تغير صورة  من قبل بشائر محمد سفيان', 'users/img/approve/273', '2022-08-23 01:05:00'),
(153, 'طلب تغير صورة', 'طلب تغير صورة  من قبل بشائر محمد سفيان', 'users/img/approve/273', '2022-08-23 01:05:00'),
(154, 'طلب عضوية', 'طلب عضوية  من قبل سلطانه عسيري ', 'users/approve/46', '2022-08-23 01:05:00'),
(155, 'طلب عضوية', 'طلب عضوية  من قبل توفيق نقاش ابراهيم', 'users/approve/47', '2022-08-23 01:05:00'),
(156, 'طلب عضوية', 'طلب عضوية  من قبل رائد الفايز', 'users/approve/48', '2022-08-23 01:05:00'),
(157, 'طلب عضوية', 'طلب عضوية  من قبل dfyhtrty', 'users/approve/49', '2022-08-23 01:05:00'),
(158, 'طلب عضوية', 'طلب عضوية  من قبل عبدالعزيز أحمد الزهراني', 'users/approve/50', '2022-08-23 01:05:00'),
(159, 'طلب عضوية', 'طلب عضوية  من قبل منصور مطلق صقر العنيبي ', 'users/approve/51', '2022-08-23 01:05:00'),
(160, 'طلب عضوية', 'طلب عضوية  من قبل يوسف عبدالرحمن حسن بندقجي', 'users/approve/52', '2022-08-23 01:05:00'),
(161, 'طلب عضوية', 'طلب عضوية  من قبل مها صالح أحمد ', 'users/approve/53', '2022-08-23 01:05:00'),
(162, 'طلب خدمة', 'مجموعه اسئله واستفسارات لإنشاء مشروع صغير  والمساعدة ف اختيار الفكره وكيفية توثيق الحقوق كشركاء وتوزيع الارباح', 'users/services/54', '2022-08-23 01:05:00'),
(163, 'طلب عضوية', 'طلب عضوية  من قبل سعود ثامر المرزوقي', 'users/approve/54', '2022-08-23 01:05:00'),
(164, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(165, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(166, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(167, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(168, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(169, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(170, 'طلب تغير صورة', 'طلب تغير صورة  من قبل يوسف عبدالرحمن بندقجي', 'users/img/approve/287', '2022-08-23 01:05:00'),
(171, 'طلب عضوية', 'طلب عضوية  من قبل سعدية محسن الفضلي', 'users/approve/55', '2022-08-23 01:05:00'),
(172, 'طلب عضوية', 'طلب عضوية  من قبل ايمان عبدالله القرشي', 'users/approve/56', '2022-08-23 01:05:00'),
(173, 'طلب عضوية', 'طلب عضوية  من قبل إلهام العامر ', 'users/approve/57', '2022-08-23 01:05:00'),
(174, 'طلب عضوية', 'طلب عضوية  من قبل ابتهال حسين المطوع', 'users/approve/58', '2022-08-23 01:05:00'),
(175, 'طلب عضوية', 'طلب عضوية  من قبل امل سعد المضحي ', 'users/approve/59', '2022-08-23 01:05:00'),
(176, 'طلب خدمة', 'لبلابللابلبللا بللابلا لفافق فقغا فق فافقلبلا لبا قف فق لا فبلافلقبقفا فقغ قففغقف غقفغ فقغقف قففغ فغاقف ', 'users/services/55', '2022-08-23 01:05:00'),
(177, 'طلب خدمة', 'استشارة عامة ومحاسبية \nاعاني من بعض المشاكل الهيكلية بالمشروع وطريقة التشغيل وتوفير البضاعة وقلة في المبيعات احتاج الى تنظيم ومعرفة نقاط ضعفي ', 'users/services/56', '2022-08-23 01:05:00'),
(178, 'طلب عضوية', 'طلب عضوية  من قبل إبتسام حسن الحربي ', 'users/approve/60', '2022-08-23 01:05:00'),
(179, 'طلب اضافة مقال', 'يوجد طلب اضافة مقال جديد باسم كيف واجهت شركة جنرال إلكتريك الأمريكية مشكلاتها المالية', 'users/articels/8', '2022-08-23 01:05:00'),
(180, 'طلب خدمة', 'khsdfgjhdgjhfck dsjkdsluffhg sdfyjds dsfdsifyg dsu fdso;fhdsjyfg dsfdsfy fisdyfituf dsfd fdgfdgfdhfdhfhfdgdf dfjhdjlfhd   ', 'users/services/57', '2022-08-23 01:05:00'),
(181, 'طلب خدمة', 'kjdshvkxjchgfkjdh fdoifghudf gho;idfgo df gdifogoujdfkugy rgerty idifygdyfg  oidfygyidy d;ufgi goigoiurogiguioguohtgtroireeroihreirehgoirgh kjdshvkxjchgfkjdh fdoifghudf gho;idfgo df gdifogoujdfkugy rgerty idifygdyfg  oidfygyidy d;ufgi goigoiurogiguioguohtgtroireeroihreirehgoirgh kjdshvkxjchgfkjdh fdoifghudf gho;idfgo df gdifogoujdfkugy rgerty idifygdyfg  oidfyg', 'users/services/58', '2022-08-23 01:05:00'),
(182, 'طلب عضوية', 'طلب عضوية  من قبل اسراء الحارقي ', 'users/approve/61', '2022-08-23 01:05:00'),
(183, 'طلب عضوية', 'طلب عضوية  من قبل مشاعل القثامي ', 'users/approve/62', '2022-08-23 01:05:00');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `title` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fund` float DEFAULT NULL,
  `status` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `imgs` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `website` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instagram` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `twitter` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `user_id`, `category_id`, `city_id`, `title`, `logo`, `img`, `fund`, `status`, `breif`, `imgs`, `location`, `phone`, `file`, `email`, `featured`, `website`, `instagram`, `twitter`, `active`, `created_at`, `deleted_at`) VALUES
(1, 50, 6, 6, 'تتبع الشحنات عبر الإنترنت', 'assets/projects/01-logo.jpg', 'assets/projects/01.jpg', 3000, 'قائم', 'كمن فكرة شركة Flexport المميزة في كونها شركة شحن ووسيط جمركي افتراضي، سمحت هذه الشركة للعملاء بتتبع شحناتهم عبر الإنترنت في الوقت الفعلي، وهو مفهوم جديد تمامًا لهذه الصناعة، يستخدم الآلاف من التجار في أمازون الشركة الناشئة لنقل بضائعهم، مثل: Warby Parker وصانع الأحذية Allbirds وبشكل عام، تقوم الشركة بتتبع عملية نقل حوالي 100.000 حاوية شحن كل عام،', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-04-10 00:29:48', NULL),
(2, 51, 6, 6, 'التسويق للتطبيقات الذكية', 'assets/projects/02-logo.jpg', 'assets/projects/02.jpg', 7000, 'متعثر', 'تقوم شركة Liftoff  على فكرة التسويق لتطبيقات الهواتف الذكية، تقوم برمجيات الشركة على أتمتة إنشاء الإعلانات وشرائها، بهدف الوصول إلى جمهور يهتم فعلا بمنتج علامة تجارية ما، حيث يدفع الزبائن للشركة فقط عندما يقوم المستخدم بإجراء عملية بيع أو تحميل التطبيق، حققت الشركة عام 2017 مداخيل بلغت 123.4 مليون دولار.', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-04-10 00:29:48', NULL),
(3, 52, 6, 6, 'توفير استهلاك الطاقة من خلال البيوت الذكية', 'assets/projects/03-logo.jpg', 'assets/projects/03.jpg', 3000, 'متعثر', 'تقديم الاستشارات الادارية والتسويقية وابتكار منتجات استثمار اجتماعي تستهدف القطاع الغير ربحي والأوقاف لتعزيز استدامته ودعم الرؤية الوطنية 2030 وهو من ضمن مشاريع الاستثمار الاجتماعي يدمج بين نموذجي العمل الاقتصادي والاجتماعي مما يحقق أثرا اقتصاديا واجتماعيا ولدي منتجات ( الخدمات الاستشارية في مجال القطاع الغير ربحي استشاري(وقفي ،غير ربحي) -ادراي -حوكمة ،', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-04-10 00:29:48', NULL),
(4, 29, 6, 6, 'بيع وشراء السيارات المستعملة عبر الإنترنت', 'assets/projects/04-logo.jpg', 'assets/projects/04.jpg', 3000, 'قائم', 'تقديم الاستشارات الادارية والتسويقية وابتكار منتجات استثمار اجتماعي تستهدف القطاع الغير ربحي والأوقاف لتعزيز استدامته ودعم الرؤية الوطنية 2030 وهو من ضمن مشاريع الاستثمار الاجتماعي يدمج بين نموذجي العمل الاقتصادي والاجتماعي مما يحقق أثرا اقتصاديا واجتماعيا ولدي منتجات ( الخدمات الاستشارية في مجال القطاع الغير ربحي استشاري(وقفي ،غير ربحي) -ادراي -حوكمة ،', NULL, 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-04-10 00:29:48', NULL),
(5, 80, 6, 6, 'صندوق العروسه ', 'assets/2022-05-21 15:34:37.633239405 +0000 UTC m=+1998271.33970037720220515_122547.jpg', 'assets/2022-05-21 15:34:37.635902521 +0000 UTC m=+1998271.342363496IMG_20220308_172153_742.jpg', 0, 'قائم', 'تنسيق دبش عرايس وتوفير مستلزماته _عربيات ملكه_هدايا ', '', 'null', '0545412476', 'assets/2022-05-21 15:34:37.635974015 +0000 UTC m=+1998271.34243499020220412_082832.jpg', 'null', 0, 'null', 'https://instagram.com/bridle_box?igshid=YmMyMTA2M2Y=', 'null', 1, '2022-05-21 15:34:37', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `rich_text`
--

CREATE TABLE `rich_text` (
  `id` int(11) NOT NULL,
  `key` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `group` smallint(1) DEFAULT 0,
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rich_text`
--

INSERT INTO `rich_text` (`id`, `key`, `page`, `value`, `title`, `image`, `group`, `icon`) VALUES
(1, 'banner', NULL, '<strong>متفرد</strong> لتبادل الخبرات وتنمية المهارات', ' أفضل مجتمع أعمال حيوي ', 'assets/banner.png', 0, ''),
(2, 'vision', NULL, 'أفضل مجتمع اعمال حيوي متفرد لرواد الاعمال واصحاب المشاريع', 'رؤيتنا', NULL, 1, 'mdi-eye-outline'),
(3, 'msg', NULL, 'تمكين الشباب من تأسيس وتطوير مشاريع نوعية واعدة', 'رسالتنا', NULL, 1, 'mdi-flag-outline'),
(4, 'mission', NULL, 'تكوين مجتمع حيوي لتبادل أفضل الممارسات والشراكات', 'مهمتنا', NULL, 1, 'mdi-bullseye-arrow'),
(5, 'values', NULL, 'بناء العلاقات واثراء المعرفة لتحقيق النجاح المشترك', 'قيمنا', NULL, 1, 'mdi-chart-box-outline'),
(6, 'small_business', NULL, 'أصحاب المشاريع الناشئة والصغيرة', NULL, NULL, 2, 'apartment'),
(7, 'ideas', NULL, 'أصحاب الأفكار الخلاقة والواعدة ', NULL, NULL, 2, 'tungsten'),
(8, 'students', NULL, 'طلاب الإدارة والاقتصاد وريادة الاعمال', NULL, NULL, 2, 'add_business'),
(9, 'business_men', NULL, 'المهتمين بمجال المال والأعمال وريادة الاعمال', NULL, NULL, 2, 'admin_panel_settings'),
(10, 'business_men', NULL, 'الباحثين عن تأسيس مشاريعهم التجارية', NULL, NULL, 2, 'assistant_photo');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `breif` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` float DEFAULT NULL,
  `color` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `image`, `breif`, `price`, `color`, `active`) VALUES
(1, 'عضوية مبادر', 'assets/mobader-removebg-preview.png', ' تساهم في تبادل المعارف والخبرات تجاه العمل الحر', 230, '#6a278a', 1),
(2, 'عضوية طموح', 'assets/tamooh-removebg-preview.png', 'تساهم في استثمار أفكارك الواعدة نحو الحرية المالية', 345, '#004f55', 1),
(3, 'عضوية ريادي', 'assets/ryady.png', ' تساهم في تكوين علاقاتك وشراكاتك لنمو اعمالك', 460, '#0026a0', 1);

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `services`
--

INSERT INTO `services` (`id`, `name`, `icon`, `deleted_at`) VALUES
(1, 'تصميم موقع الكتروني', 'application-outline', NULL),
(2, 'نموذج عمل', 'note-edit-outline', NULL),
(3, 'استشارة اقتصادية', 'tune-vertical', NULL),
(4, 'دراسة جدوي', 'equalizer', NULL),
(5, 'جولة استثمارية', 'مال', NULL),
(6, 'جلسة استشارية', 'لل', NULL),
(7, 'زيارة مشروع', 'ثث', NULL),
(8, 'خطة عمل', 'قصصص', NULL),
(9, 'عقود عمل', 'ييييي', NULL),
(10, 'عقود شراكة', 'ب', NULL),
(11, 'ابيبليب', 'ي', NULL),
(12, 'زكاة وضرائب', 'زكاة وضرائب', NULL),
(13, 'مراجعة حسابات', 'مراجعة حسابات', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_ar` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT 'assets/members/default.png',
  `password` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial` int(11) DEFAULT NULL,
  `points` int(5) UNSIGNED DEFAULT 0,
  `role_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `phone` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `active` tinyint(1) DEFAULT 0,
  `admin` tinyint(1) DEFAULT 0,
  `status` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `name_ar`, `email`, `img`, `password`, `serial`, `points`, `role_id`, `city_id`, `phone`, `breif`, `featured`, `active`, `admin`, `status`, `created_at`, `deleted_at`) VALUES
(1, 'Nujoud Abdullah Al-Harbi', 'نجود عبدالله الحربي', 'Nujoud@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 2400100, 230, 1, 1, '0557455273', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(2, 'Mashal Ali Albrgs', 'مشعل عوده العلي', 'mashal@gmail.com', 'assets/391605743719_servers.png', '123456', 2000100, 230, 1, NULL, '9876543210', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(3, 'Mohammed Abdullah Al-Qahtani', 'محمد عبدالله القحطاني', 'MTQ4515@gmail.com', 'assets/WhatsApp Image 2022-02-08 at 8.37.21 PM.jpeg', 'MT2244668800', 2000105, 230, 1, NULL, '0554473217', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(4, 'Afrah A. Almanhapi', 'افراح عبدالله المنهبي', 'Afrah@Abdullah.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 221001, 230, 1, 2, '0503056210', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(5, 'JabrJaberAlharbi-75890', 'جبر جابر الحربي', NULL, 'assets/جبر الحربي.jpg', '123456', 221010, 230, 1, 1, '0599906763', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(6, 'Jana A. Almanhapi', 'جنى احمد المنهبي', 'Jana@A.COM', 'assets/ryady-24461652920210509032652AM.png', '123456', 221013, 230, 1, 1, '0503056610', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(7, 'Noorah Nooh Ahmad', 'نوره نوح احمد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 221031, 230, 1, 2, '0569692200', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(8, 'Rawan saeed alshahrani', 'روان عبدالله المغربي', 'reehab2000@gmail.com', 'assets/غفعففغع.jpg', '123456', 221053, 230, 1, 1, '0566376051', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(9, 'Meaad Awad Al-Mutairi', 'ميعاد عوض المطيري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 221062, 230, 1, 1, '0551757631', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(10, 'AHMED ATTIAH AL HARTOOMI', 'احمد عطيه الحرتومي', NULL, 'assets/الحرتومي.jpg', '123456', 221070, 230, 1, 10, '0542778996', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(11, 'Rawan wajdi fadhel', 'روان وجدي فاضل', 'Rawan@Rawan.com', 'assets/ryady-211416619620210601031530PM.jpeg', '123456', 221090, 230, 1, 1, '0566077616', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(12, 'SAMIRAH MESHAL ALJUAID', 'سميره مشعل الجعيد', 'sm7890sm1234@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'S537170711', 221150, 230, 1, 3, '0538517318', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(13, 'isha Saleh Al-Otaibi', 'عايشه صالح العتيبي', 'aisha_7854@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', 'A537170711', 221151, 230, 1, 3, '0550895992', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(14, 'Naif mohammed almobty', 'نايف محمد المبطي', NULL, 'assets/نايف آل مبطي.jpg', '123456', 221160, 230, 1, 2, '0546288800', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(15, 'sdfsd dfg dfgdf', 'بيليب dffg dg', 'akyh@yhkl.com', 'assets/members/default.png', '123456', 2400103, 0, 1, NULL, '1259256487', NULL, 0, 0, 0, 'pending', '2022-04-18 21:34:20', NULL),
(16, 'test', 'test', 'test@test.com', 'assets/members/default.png', '123123', 2400108, 0, 1, NULL, '123123123', NULL, 0, 0, 0, 'pending', '2022-04-21 17:53:54', NULL),
(17, 'test', 'test', 'tesst@test.comm', 'assets/members/default.png', 'asd@asd@', 2400109, 230, 1, NULL, '12233212312', NULL, 0, 1, 0, 'pending', '2022-04-21 18:11:09', NULL),
(18, 'Abeer Muneer Hettah', 'عبير منير حته', 'Abeermuneerh@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Abeer234', 2400116, 230, 1, 1, '0548219262', NULL, 0, 1, 0, 'pending', '2022-05-15 13:03:09', NULL),
(19, 'Sharyan Al sharyan', 'شريان ال شريان', 'dddbbb323@gmail.com', 'assets/members/default.png', 'Sh123456', 2400120, 230, 1, 13, '0546655205', 'رجل أعمال ', 0, 1, 0, 'pending', '2022-05-17 03:33:25', NULL),
(20, 'Faisal Mohammed Al-gonaidi', 'فيصل محمد الجنيدي ', 'fms.1995.ksa@gmail.com', 'assets/members/default.png', 'Ff123456789', 2400123, 230, 1, NULL, '0557834686', NULL, 0, 1, 0, 'pending', '2022-05-25 23:30:32', NULL),
(21, 'Rola bakur balahmer', 'رولا بكر بالحمر', 'rola.rola.tv@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Rola2030', 2400126, 230, 1, 1, '0500050591', 'معد برامج تلفزيونية وشاعرة وفنانة تشكيلية .. حاصلة على براءة تصميم نموذج صناعي في مغاسل وضوء حديثة ', 0, 1, 0, 'pending', '2022-05-26 11:36:53', NULL),
(22, 'Joza A. Alyaqoub', 'جوزاء عبدالعزيز اليعقوب', 'Jozaa.kau@hotmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Aa1114783309', 2400127, 230, 1, NULL, '0549320547', NULL, 0, 1, 0, 'pending', '2022-05-29 12:34:01', NULL),
(23, 'Randa Ba Dawod', 'رندة أحمد باداود', 'rba460273@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Randa54321', 2400130, 230, 1, 1, '0565848806', NULL, 0, 1, 0, 'pending', '2022-06-02 03:26:06', NULL),
(24, 'Bashair Muhammad Sufyan', 'بشائر محمد سفيان', 'Bashair.mohammad9900@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', '123456', 2400135, 230, 1, 1, '0542017800', NULL, 0, 1, 0, 'pending', '2022-06-06 20:20:37', NULL),
(25, 'Amal saad Almodihy', 'امل سعد المضحي', 'Amalsaad.tyr@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', '123456', 2400149, 0, 1, 2, '0533362655', NULL, 0, 1, 0, 'pending', '2022-06-28 13:02:24', NULL),
(26, 'EBTESAM  HASSAN ALHARBI', 'إبتسام حسن الحربي ', 'ebtbusiness97@gmail.com', 'assets/members/default.png', 'SamLH199717%', 2400150, 0, 1, NULL, '0541907479', NULL, 0, 1, 0, 'pending', '2022-07-06 15:33:38', NULL),
(27, 'Mashael Alqethaml', 'مشاعل القثامي ', 'Aasha1855@gmail.com', 'assets/members/default.png', 'Am123123', 2400152, 0, 1, NULL, '0583866120', NULL, 0, 0, 0, 'pending', '2022-08-03 06:38:55', NULL),
(28, 'Jouri Mohammed Al-Zahrani', 'جوري محمد الزهراني', 'Jouri@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 2400100, 230, 2, NULL, '0503056611', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبور أنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا .', 0, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(29, 'Razan Yahya Bresali', 'رزان يحيى بريسالي', 'razan.buraysali@gmail.com', 'assets/f72a3998-6cba-4f1f-aaae-e9debbb4d98d-removebg-preview.png', '#Razan1234567890', 2000104, 460, 2, 4, '0546006672', 'مبتعثة بالولايات المتحدة الامريكية ومهتمة بالكتابة في مجال الموارد البشرية', 1, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(30, 'Sharifah Ali Alshehri', 'شريفه علي الشهري', 'rooo686@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 2000106, 460, 2, NULL, '0506972822', 'لايف كوتشينج مستوى متقدم خبرة 6سنوات \nمدربة في الادارة و التطوير خبرة 3سنوات ', 1, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(31, 'Hessa Abdullah ALZahrani', 'حصه عبدالله الزهراني', 'Hessa@ss.com', 'assets/FBaRS92XIAMPT4F.jpg', '123456', 241005, 345, 2, 2, '0552322654', 'كاتبة وروائية، املك شغف الكتابة فقلمي لايقف عن الخواطر والقصص وشي من النثر', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(32, 'Jawaher Ahmed Abdullah', 'جواهر أحمد العنزي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241020, 345, 2, 2, '0501090299', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(33, 'EMAN ZAIN ALABDIN', 'إيمان زين العابدين', 'EMAN@EMAN.com', 'assets/ryady-187259349320210505110936PM.jpeg', '123456', 241029, 345, 2, 4, '0544841405', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(34, 'Buthainah Mohammed Makhshen', 'بثينة بنت محمد', 'buthainah.y@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Buthainah899', 241032, 345, 2, 2, '0533510660', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(35, 'Eng. IBRAHEEM M. ALMOHAIMEED', 'ابراهيم محمد المحيميد', NULL, 'assets/members/default.png', '123456', 241041, 345, 2, 2, '0505221231', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(36, 'Samah Adel Aljuryan', 'سماح عادل الجريان', NULL, 'assets/ryady-21160967420210419121041AM.jpeg', '123456', 241043, 345, 2, 19, '0554326380', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(37, 'Alaa Abbad Alharbi', 'الاء عباد الحربي', NULL, 'assets/main_saudi_women_empowerment-700x.jpg', '123456', 241047, 345, 2, 4, '0505550498', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(38, 'Hend Mohammad Alshehri', 'هند محمد الشهري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241061, 345, 2, 1, '0507766321', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(39, 'Badr Jaza Alotaibi', 'بدر جزاء العتيبي', 'badrotaibi@outlook.com', 'assets/بدر جزاء العتيبي.jpeg', 'Badr7559Jaza', 241071, 345, 2, 1, '0506293862', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(40, 'KHALID MUHAMMAD OBAID', 'خالد محمد عبيد', 'eng.ppc7@gmail.com', 'assets/ryady-198010002320210619072245PM.jpeg', '33115513579', 241075, 345, 2, 2, '0563633380', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(41, 'Tahani Ali Saleh', 'تهاني علي صالح', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241112, 345, 2, 15, '0530877935', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(42, 'Kholoud Abdullah Tawashi', 'خلود عبدالله طواشي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241132, 345, 2, 1, '0508106335', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(43, 'Hanan Hamad Al-Saqabi', 'حنان حمد الصقعبي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241147, 345, 2, 2, '0565335921', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(44, 'Amna Muhammad Al-Ghamdi', 'امنه محمد الغامدي', 'Ammnh.m.g@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Amoonn5522', 241154, 345, 2, 2, '0504295552', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(45, 'Aisha Abdullah Baqader', 'عائشة عبدالله باقادر', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 241156, 345, 2, 1, '0504517179', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(46, 'alaa a. felmban', 'علاء عادل فلمبان', NULL, 'assets/علاء فلمبان.jpg', '123456', 241164, 345, 2, 2, '0590980869', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(47, 'AbdulRahman bin Mishni', 'عبدالرحمن بن مشني', 'tdfgh@yfk.com', 'assets/members/default.png', '123456', 2400121, 460, 2, NULL, '0505528271', NULL, 0, 1, 0, 'pending', '2022-05-21 15:20:59', NULL),
(48, 'Fawzyah Hilal ALjabry', 'فوزيه هلال الجابري', 'fefy1717@icloud.com', 'assets/members/default.png', 'Fefy1234', 2400124, 0, 2, NULL, '0554335338', NULL, 0, 0, 0, 'pending', '2022-05-25 23:32:55', NULL),
(49, 'Nader Faisal dewan', 'نادر فيصل ديوان', 'NFDewan@outlook.sa', 'assets/نادر ديوان.jpg', '123456', 2200100, 345, 3, NULL, '0568002977', 'يوت انيم أد مينيم فينايم,كيواس نوستريد أكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات ', 0, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(50, 'Mohammed Mahmoud Al-Ansari', 'محمد محمود الانصاري', 'Al-Ansari@gmail.com', 'assets/391605743719_servers.png', '123456', 2000100, 460, 3, NULL, '0569967739', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 0, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(51, 'Fareed Ibrahim Kanuri', 'فريد ابراهيم كانوري', 'foforedo@hotmail.com', 'assets/391605743719_servers.png', '123456', 2000102, 460, 3, 1, '0567446955', 'ريادي طموح بإمتياز  وصاحب تطبيق الكتروني سوف يرى النور قريباً بحول الله وتوفيقه \n• كنتُ ولا أزال أرى العالمَ يتسع لكل الناجحين مهما بلغ عددهم .', 0, 1, 1, 'pending', '2022-04-10 00:29:48', NULL),
(52, 'Naela Hassan Al-Qadi', 'نائله حسن القاضي', 'nailahalgadi@yahoo.com', 'assets/1000_ea33515b53.jpg', '123456', 2000103, 460, 3, 3, '0505795489', 'مهتمة بالتنمية البشرية ومتخصصة بالقيادة والموارد البشرية ولي مؤلفات في الأدب والتنمية البشرية.\nأبحاث علمية في التوظيف والتكنولوجيا الرقمية', 1, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(53, 'Moaz Mohamed El-Sayed', 'معاذ محمد السيد', 'Moaz@gmail.com', 'assets/c38ce8ca-93c9-44ca-b863-7cbf3eaf8a77.jpg', '508090', 2000105, 460, 3, 3, '0563396622', 'شاب طموح اعشق التسويق، ساهمت في تأسيس عدد من المشاريع التجارية، واسعى للوصول الى تأسيس علامة تجارية قوية في التسويق ', 1, 1, 0, 'pending', '2022-04-10 00:29:48', NULL),
(54, 'Ahmed Ashraf Darwish', 'احمد اشرف درويش', 'admin@alshabalriyadi.net', 'assets/391605743719_servers.png', '123456', 240000, 460, 3, NULL, '05555555555', 'مبرمج تقني ومطور برمجيات بعدة لغات برمجية', 1, 1, 1, 'pending', '2022-04-10 00:29:48', NULL),
(55, 'Rawan Atif Makki', 'روان عاطف مكي', 'roooni@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '555592520', 2200100, 460, 3, NULL, '0561942999', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(56, 'Majed Abdullah Al-Obayan', 'ماجد عبدالله العبيان', 'Majed@gmail.com', 'assets/EzxAwLmXEAc9qla.jpg', '123456', 2000102, 460, 3, NULL, '0555452792', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(57, 'abdullatif hani hariri', 'عبداللطيف هاني حريري', 'abdullatifjhariri@gmail.com', 'assets/عبداللطيف حريري.jpg', '123456', 2000103, 460, 3, NULL, '0552884141', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(58, 'Hilal Mohammed Ashour', 'هلال محمد عاشور', 'Hilal@gmail.com', 'assets/هلال عاشور.jpeg', '123456', 2000104, 460, 3, NULL, '0556299955', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(59, 'Amar Khalid Bajamak', 'عمار خالد باجمال', 'Amarbajamal@gmail.com', 'assets/عمار باجمال.jpg', '123456', 2000106, 460, 3, 1, '0546300896', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(60, 'Abdullah K. AlSubaie', 'عبدالله خزام السبيعي', NULL, 'assets/عبالله السبيعي.jpeg', '123456', 201000, 460, 3, 2, '0545334334', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(61, 'MASHARI bin KHAZAM', 'مشاري بن خزام', 'MASHARI@KHAZAM.com', 'assets/391605743719_servers.png', '123456', 201002, 460, 3, 2, '0530600800', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(62, 'Bandr Bin Dajam', 'بندر بن دعجم', 'Bandr@Dajam.com', 'assets/بندر بن دعجم.jpg', '123456', 201003, 460, 3, 1, '0555559997', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(63, 'Osamah Ahmad Almanhapi', 'اسامه احمد المنهبي', 'salzx90@gmail.com', 'assets/اسامه.jpg', '123456', 201004, 460, 3, 1, '0501663722', 'مهتم بالادارة ونظم المعلومات، اسعى لتحقيق احلامي من خلال تطبيق أفضل الممارسات المهنية في عالم ريادة الاعمال', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(64, 'AbeerAllubdi-68456', 'عبير مطلق اللبدي', NULL, 'assets/عبير اللبدي.jpg', '123456', 201006, 460, 3, 1, '0543424345', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(65, 'Rehab A. AlMaghribi', 'رحاب عبدالله المغربي', 'businessprosa@gmail.com', 'assets/لاتاتناتن.jpg', '123456', 201007, 460, 3, 1, '0550006013', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(66, 'Rashid Mohammed Alshehri', 'راشد محمد الشهري', NULL, 'assets/راشد الشهري.jpg', '123456', 201008, 460, 3, 1, '0548877401', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(67, 'HamzaAlturki-79453', 'حمزة أشرف التركي', NULL, 'assets/members/default.png', '123456', 201009, 460, 3, 1, '0560005321', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(68, 'Nadiaa m. lkhashrami', 'نادية محسن الخشرمي', 'dfg@dd.com', 'assets/ryady-103832174420210413072935PM.png', '123456', 201011, 460, 3, 1, '0547288681', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(69, 'Anas M Alansari', 'انس محمود الانصاري', NULL, 'assets/انس الانصاري1.jpg', '123456', 201012, 460, 3, 1, '0569967793', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(70, 'WaleedAGogandi-89312', 'وليد عبد الواسع قوقندي', NULL, 'assets/قوقندي.jpg', '123456', 201014, 460, 3, 1, '0565114040', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(71, 'Mohammed Mustafa Nazer', 'محمد مصطفى ناظر', 'Mohammed@g.com', 'https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/https://api.alshabalriyadi.net/assets/فقيه.jpg', '123456', 201015, 460, 3, 1, '⁦0503056666', '..................', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(72, 'waleed eid alzahrani', 'وليد عيد الزهراني', NULL, 'assets/وليد عيد.jpg', '123456', 201016, 460, 3, 1, '0553663458', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(73, 'Abdullah S Alshehri', 'عبدالله صالح الشهري', 'I-shehri@hotmail.com', 'assets/F1CA8963-1EEB-4C8B-9D82-249A848F9843.jpeg', '123456', 201017, 460, 3, 7, '0582227141', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(74, 'Wafaa salih albadriy', 'وفاء صالح البدري', 'Wafaa@Wafaa.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201018, 460, 3, 1, '0503617123', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(75, 'Sattam Eid alkadi', 'سطام عيد القاضي', NULL, 'assets/members/default.png', '123456', 201019, 460, 3, 1, '0541940680', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(76, 'Arif Mubarak Alhussain', 'عارف مبارك آل-حسين', 'arif_heql@hotmail.com', 'assets/WhatsApp Image 2022-03-02 at 3.57.27 PM.jpg', '123456', 201021, 460, 3, 2, '0504563895', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(77, 'Muhanna Kamal Al-Muhanna', 'مهنا كمال المهنا', 'drmmuhanna@gmail.com', 'assets/مهنا المهنا.jpg', 'Office216@17', 201022, 460, 3, 2, '0560022888', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(78, 'Mohammed faisal shahin', 'محمد فيصل شاهين', 'M-F-Shahin@hotmail.com', 'assets/2165A22B-F32E-4DFD-9D24-511A67D80AC7.jpeg', 'Mm0551384446', 201023, 460, 3, 1, '0551384446', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(79, 'meshal Ali albarjas', 'مشعل علي البرجس', 'm6.20@hotmail.com', 'assets/ryady-151974753220210506084921PM.jpeg', '123456', 201024, 460, 3, 2, '0508986346', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(80, 'Amany Mohammed younis', 'أماني محمد يونس', NULL, 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Owis1234', 201025, 460, 3, 2, '0545412476', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(81, 'Ayed Owda Alharbi', 'عايد عوده الحربي', NULL, 'assets/عايد الحربي.jpg', '123456', 201026, 460, 3, 1, '0505772368', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(82, 'Sulaiman A Albalawi', 'سليمان عوض البلوي', 'Sul-kh@hotmail.com', 'assets/ryady-155945031820210703050623PM.png', 'thAmer.2', 201027, 460, 3, 8, '0565803212', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(83, 'Sahar Salem Alhutami', 'سحر سالم الحطامي', 'S7r.design@gmail.com', 'assets/ryady-187243059820210414080214PM.jpeg', '123456', 201028, 460, 3, 1, '0504644416', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(84, 'ABDULLAH AHMED HASSAN', 'عبدالله أحمد حسان', 'Xaxb.66@gmail.com', 'assets/ryady-48148847720210506085827PM.jpeg', 'Abodi@1417', 201030, 460, 3, 1, '0566082280', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(85, 'Abdulaziz Bin Ali', 'عبدالعزيز بن علي', 'abdulazizhajar@gmail.com', 'assets/ryady-97340697220210414081528AM.jpeg', '123123', 201033, 460, 3, 1, '0544426660', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(86, 'Sara Essam Zahid', 'سارة عصام زاهد', 'Alanamelaljamelah@gmail.com', 'assets/سارة زاهد.jpg', 'soso1987', 201034, 460, 3, 1, '0560011909', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(87, 'EID ABDULLAH ALOTAIBI', 'عيد عبدالله العتيبي', 'eid5237@gmail.com', 'assets/عيد العتيبي.jpeg', 'E1083230340d', 201035, 460, 3, 2, '0531444452', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(88, 'Samia Ali Al-Sharif', 'ساميه علي الشريف', 'samian56748@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201036, 460, 3, 5, '0563010595', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(89, 'sarah saad m.d', 'سارة سعد الدوسري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201037, 460, 3, 9, '0551097700', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(90, 'Mohammed K.R Alsharef', 'محمد خالد الشريف', NULL, 'assets/ryady-81667304120210416023616PM.jpeg', '123456', 201038, 460, 3, 5, '0597777351', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(91, 'Mohammad A Surrati', 'محمد عبد القادر سرتي', NULL, 'assets/سرتي.jpeg', '123456', 201039, 460, 3, 4, '0505506869', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(92, 'Hanan Mohammed Ahmedden', 'حنان محمد احمددين', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201040, 460, 3, 4, '0534082851', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(93, 'MESHAL ABN ABDALLH', 'مشعل بن عبدالله', 'MESHAL@ABDALLH.com', 'assets/مشعل الخمعلي.jpeg', '123456', 201042, 460, 3, 18, '0593333428', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(94, 'Sahar Hussain Hayek', 'سحر حسين حايك', NULL, 'assets/سحر حايك.jpg', '123456', 201044, 460, 3, 1, '0547999847', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(95, 'AHLAM ATIAH ALMURASHI', 'احلام عطية المرعشي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201045, 460, 3, 5, '0562734006', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(96, 'Badriah Ibrahim almoqrin', 'بدرية ابراهيم المقرن', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201046, 460, 3, 2, '0531097130', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(97, 'Maha mohammed Alfarran', 'مها محمد الفران', NULL, 'assets/ryady-120518597920210508074808PM.jpeg', '123456', 201048, 460, 3, 1, '0544682888', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(98, 'Assem a alorf', 'عاصم عبدالعزيز العرف', 'Assem@ss.com', 'assets/ryady-184660307920210423122039AM.jpeg', '123456', 201049, 460, 3, 12, '0501005551', 'شخصية طموحه، اسعى للتحقيق اهدافي وبناء مستقبلي بشكل مختلف', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(99, 'MOHAMMAD JARALLAH ALZAHRANI', 'محمد جارالله الزهراني', 'Mo.alzahrani@hotmail.com', 'assets/محمد جارالله.jpg', 'Momo1526', 201050, 460, 3, 2, '0565656156', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(100, 'Mohammed  Al.harbi', 'محمد عياد الحربي', NULL, 'assets/members/default.png', '123456', 201051, 460, 3, 12, '0506141478', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(101, 'Saher Salem Almadani', 'ساهر سالم المدني', 'Saher.Saber@gmail.com', 'assets/ساهر مدني.jpg', '123456', 201052, 460, 3, 1, '0541499049', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(102, 'Raghdah Adel Murghlan', 'رغدة عادل مرغلان', NULL, 'assets/ryady-39725074420210423122011AM.jpeg', '123456', 201054, 460, 3, 1, '0565525707', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(103, 'HAMZA A. MANDELI', 'حمزه عبدالهادي منديلي', NULL, 'assets/ryady-173398454920210423012804AM.jpeg', '123456', 201055, 460, 3, 4, '0542186168', 'مصور وممنتج محترف', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(104, 'Khaled Abdullah Muhammad ALshayeb', 'خالد عبدالله الشايب', 'Khaled@D.COM', 'assets/ryady-198010002320210619072245PM.jpeg', '123456', 201056, 460, 3, 2, '0554121112', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(105, 'Saada Saad Al-Ghamdi', 'سعدى سعد الغامدي', 'nasmahsaad254@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201057, 460, 3, 11, '0532155056', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(106, 'Abdulrhman Ahmed Abushiqa', 'عبدالرحمن احمد ابوشيقه', NULL, 'assets/members/default.png', '123456', 201058, 460, 3, 2, '0554462122', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(107, 'Morooj Hashim Katib', 'مروج هاشم كاتب', 'moroojkatib@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Moja1234', 201059, 460, 3, 2, '0504477547', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(108, 'Eisa S. Alolayani', 'عيسى سحمان العلياني', 'isa-s@hotmail.com', 'assets/7CA4A388-C600-4117-B921-8DB935F5E31B.jpeg', '123456', 201060, 460, 3, 1, '0502457745', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(109, 'Nazmi Abdulelah AlSaadi', 'نظمي عبدالاله الصاعدي', NULL, 'assets/ryady-144676778720210503025348AM.jpeg', '123456', 201063, 460, 3, 1, '0568383837', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(110, 'Rzan M. Alghamdi', 'رزان محمد الغامدي', 'Rzanmghamdi@gmail.com', 'assets/رزان الغامدي.jpeg', 'Rmg=0235', 201064, 460, 3, 8, '0550749777', 'الرئيس التنفيذي لشركة جرم للدعاية والاعلان \nعضو مجلس شباب المنطقة الشرقية \nعضو فريق Startup Grind \nمحلل اعمال واستثمار في الشركات التقنية الناشئة', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(111, 'Ammar S Mahmadah', 'عمار سعيد مهمده', 'ammar.asm52@gmail.com', 'assets/ryady-171718639520210505070408PM.png', '123456', 201065, 460, 3, 4, '0544310084', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(112, 'ebdaleziz bin dhiab', 'عبدالعزيز بن ذياب', 'azoz.almalke9512@gmail.com', 'assets/عبدالعزيز ذياب.jpg', 'Azoz9512', 201066, 460, 3, 1, '0566824844', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(113, 'amal mabrouk frhan', 'أمل مبروك فرحان', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201067, 460, 3, 15, '0508933537', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(114, 'Ibrahim Mohammed Nourwali', 'ابراهيم محمد نورولي', NULL, 'assets/ابراهيم.jpg', '123456', 201068, 460, 3, 5, '0550939364', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(115, 'Lamyaa farooq abdulmajeed', 'لمياء فروق عبدالمجيد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201069, 460, 3, 1, '0531621616', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(116, 'Abdullah Mohammed Aloqayf', 'عبدالله محمد العقيف', 'Abdullah.oqf@gamil.com', 'assets/عبدالله العقيق.jpeg', 'Aa25112511', 201072, 460, 3, 3, '0583277227', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(117, 'MAJED YHYA AlSHARNI', 'ماجد يحيى الشهراني', 'MAJED@MAJED.com', 'assets/ryady-133260226520210508083657PM.jpeg', '123456', 201073, 460, 3, 11, '059785000', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(118, 'Mahmiud M. Mujalled', 'محمود محمد مُجلّد', 'eng.mujalled@gmail.com', 'assets/391605743719_servers.png', 'momo5144', 201074, 460, 3, 2, '0556662623', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(119, 'Dalal Mohammed Saed', 'دلال محمد سعيد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201076, 460, 3, 2, '0506080140', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(120, 'Doa\'a Wail Saleh Islam', 'دعاء وائل صالح إسلام', 'purple2white@gmail.com', 'assets/دعاء اسلام.jpeg', '4Purple4', 201077, 460, 3, 1, '0541091844', '- بكالوريوس محاسبة من جامعة الملك عبد العزيز بجدة\n- خبرة عشرون عاما كحاسبة ومحللة مالية في قسم المحاسبة الطبية في أرامكو السعودية إلى فبراير 2018', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(121, 'Anwar essam alkiki', 'أنوار عصام الكيكي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201078, 460, 3, 2, '0542442399', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(122, 'Loai Hassan Abduljawad', 'لؤي حسن عبدالجواد', 'Abduljawad.l@gmail.com', 'assets/لؤي عبدالجواد.jpeg', 'L123321', 201079, 460, 3, 2, '0530333555', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(123, 'Badr Ayed Al-Harees', 'بدر عايض الحريص', 'b@bbb.com', 'assets/ryady-30889552320210517054428AM.png', '123456', 201080, 460, 3, 2, '0533333527', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(124, 'ALANOUD SAYER ALHARBI', 'العنود ساير الحربي', 'alniudalharbi@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Anood1420@', 201081, 460, 3, 20, '0533743012', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(125, 'Jalal Saleh Qotai', 'جلال صالح القطيعي', NULL, 'assets/جلال.jpeg', '123456', 201082, 460, 3, 2, '0555530996', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(126, 'hanadi said mohammed', 'هنادي سعيد محمد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201083, 460, 3, 1, '0555555501', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(127, 'waleed Salman Alnadhri', 'وليد سلمان الناظري', NULL, 'assets/391605743719_servers.png', '123456', 201084, 460, 3, 2, '0565962255', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(128, 'Hanan Ahmad Salwati', 'حنان أحمد صلواتي', NULL, 'assets/ryady-47691136820210601030630PM.jpeg', '123456', 201085, 460, 3, 5, '0544433256', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(129, 'Wejdan Ateyah ALGhmdey', 'وجدان عطيه البتير', 'Wjwj2015@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201086, 460, 3, 1, '0554366945', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(130, 'Abdullah Majed AlKassabi', 'عبدالله ماجد القصبي', NULL, 'assets/members/default.png', '123456', 201087, 460, 3, 1, '0504604638', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(131, 'Bayan mohammad albarakati', 'بيان محمد البركاتي', 'Bayan.art1@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Bayan@123', 201088, 460, 3, 1, '0548991730', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(132, 'Nahla H Mufti', 'نهله حسن مفتي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201089, 460, 3, 4, '0556563232', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(133, 'Muhanned Mohammed Al-Lihyani', 'مهند محمد اللحياني', NULL, 'assets/members/default.png', '123456', 201091, 460, 3, 4, '0505545464', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(134, 'Nora J Almalki', 'نورة جارالله المالكي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201092, 460, 3, 4, '0569546422', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(135, 'Muna Hamead Allabdi', 'منى حميد اللبدي', 'dal3_2_o@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201093, 460, 3, 1, '0533449760', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(136, 'Reem Mohammed Al-Qahtani', 'ريم محمد القحطاني', 'reemstorydesign@gmail.com', 'assets/EBLARaRXsAghwcQ (1).jpg', '123456', 201094, 460, 3, 2, '0541666143', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(137, 'Ahmad K. Albuainain', 'احمد خليفة البوعينين', NULL, 'assets/members/default.png', '123456', 201095, 460, 3, 8, '0555555502', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(138, 'RAWAN SAEED ALGHAMDI', 'روان سعيد الغامدي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201096, 460, 3, 13, '0538934334', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(139, 'HANAN SALIM ALRUWYJAH', 'حنان سالم الرويجح', 'Brincess16@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201097, 460, 3, 3, '0559552533', 'عند الحديث عن القهوة المختصة  في مدينة الطائف فالأكيد (مقهى  ست أمتار) من  أبرز. روادها وعلامة فارقة  فالشغف قادنا إلى دخول عالم القهوة المختصة بكل قوة وحب وإهتمامنا بجودة مانقدم وسعينا إلى إرضاء ذائقة العميل بحسب معايير منظمة القهوة المختصة كان من أولوياتنا  فالفضل لله أولًا وأخيرا فيما نحن علية اليوم.  ومازال لدينا الكثير .', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(140, 'Fathiah saed Alsheikhi', 'فتحية سعيد الشيخي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201098, 460, 3, 1, '0540300195', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(141, 'Taghreed khalaf Alazwary', 'تغريد خلف الازوري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201099, 460, 3, 1, '0568081056', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(142, 'Rahaf ahmed sobhan', 'رهف احمد سبحان', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201100, 460, 3, 1, '0595959649', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(143, 'Mohammad yousef milibari', 'محمد يوسف مليباري', NULL, 'https://api.alshabalriyadi.net/assets/WhatsApp Image 2022-05-19 at 3.04.41 PM.jpeg', '123456', 201101, 460, 3, 4, '0568284231', 'اخصائي تسويق رقمي  \nاساعد  المشاريع في  رفع مبيعاتهم  ٣٠% من خلال استخدام استراتيجيات وادوات التسويق الحديثه ', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(144, 'MUZUN MOUSAA ALkHAlBARl', 'مزون موسى الخيبري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201102, 460, 3, 14, '0543773179', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(145, 'khaled Eid almutairi', 'خالد عيد المطيري', 'k.e@outlook.sa', 'assets/Er3sq2HX_400x400.jpg', '123456', 201103, 460, 3, 2, '0563369970', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(146, 'Esraa M Nazer', 'إسراء مصطفى ناظر', 'Esraa@Nazer.com', 'assets/ryady-130393546520210601013141PM.png', '123456', 201104, 460, 3, 1, '0554686618', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(147, 'Mohammed Mrawan Mamluk', 'محمد مروان مملوك', NULL, 'assets/ryady-73053786520210601111539AM.jpeg', '123456', 201105, 460, 3, 2, '0593312119', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(148, 'Sultan a alfuryh', 'سلطان عبدالرحمن الفريح', NULL, 'assets/members/default.png', '123456', 201106, 460, 3, 2, '0531122041', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(149, 'Amal Ali Saleh', 'أمل علي صالح', 'amsaed1234@hotmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Amal1234', 201107, 460, 3, 15, '0557210305', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(150, 'Rabab Abdullah AL-Zhrany', 'رباب عبدالله الزهراني', 'reehab2014@gmail.com', 'assets/لاتاتناتن.jpg', '123456', 201108, 460, 3, 3, '0564941972', 'اعمل بمجال الخدمات التسويقية، واطمح لتأسيس شركة في مجال الخدمات التشغيلية', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(151, 'Nawaf M Alqahtani', 'نواف محمد القحطاني', 'Nawaf@jyg.com', 'assets/ryady-990553620210628083705AM.png', '123456', 201109, 460, 3, 2, '0555414006', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(152, 'Nour abdullah ALzharni', 'نوره عبدالله الزهراني', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201110, 460, 3, 2, '0503871121', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(153, 'Mansour Hameed Almalki', 'منصور حميد المالكي', 'Mansour@Almalki.com', 'assets/ryady-98556748520210617015712PM.jpeg', '123456', 201111, 460, 3, 4, '0509998265', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(154, 'Thekra Fahad al-ghamdi', 'ذكرى فهد الغامدي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201113, 460, 3, 1, '0556339919', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(155, 'Aljawharah A. Alfuhayd', 'الجوهرة عبدالعزيز آل-فهيد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201114, 460, 3, 2, '0555258755', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(156, 'Mohammed Ali Asiri', 'محمد علي عسيري', NULL, 'https://api.alshabalriyadi.net/assets/محمد عسيري.jpeg', '123456', 201115, 460, 3, 1, '0538375383', 'رائد اعمال في مجال تقنية المعلومات والاتصالات الا سلكية، المالك والمؤسس لـ ( متاجر أزير ) رواد دمج الذكاء التجاري بالذكاء الصناعي', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(157, 'Eman saleh alyousef', 'ايمان صالح اليوسف', 'Eman@S.COM', 'assets/ايمان اليوسف.png', '123456', 201116, 460, 3, 2, '0554166423', 'مدربة في القيادة والتطوير المهني، اقدم رسالة سامية في عملي واعمل الى تقديم أفضل الأداء في اعمالي', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(158, 'Reem Ali Al-Qarmoshi', 'ريم علي القرموشي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201117, 460, 3, 1, '0562617778', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(159, 'Tareq Melfi Alrowaili', 'طارق ملفي الرويلي', NULL, 'assets/طارق ملفي.jpg', '123456', 201118, 460, 3, 2, '0555555504', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(160, 'Yahya Saeed Alfaqih', 'يحيى سعيد الفقيه', 'ysa@dccit.co', 'assets/فقيه.jpg', '123456', 201119, 460, 3, 1, '0505353580', 'مؤسس مجتمع تطوير الذات باحث ومفكر ومستشار ومستثمر ومخترع، اداري وقيادي محترف في مجالات الإدارة والقيادة والاستثمار، صانع ثروات، مؤسس  توجيه الكفاءات ومشروع FAZAA فزعه\n', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(161, 'Sumaia Adnan jalloun', 'سُميّة عدنان جَلّون', NULL, 'assets/ryady-21006005820210618113453AM.jpeg', '123456', 201120, 460, 3, 2, '0570771300', 'ماجستير مكافحة عدوى، عضوه في CPIC، عضوه في الجمعية السعودية لتعليم الممارسين الصحيين، شغوفة بالتدريب والاستشارات في تنمية الذات ، لايف كوتش ومدرب معتمد في التنمية الذاتية\n', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(162, 'Fatimah Sulaiman ALSaieed', 'فاطمة سليمان السعيد', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201121, 460, 3, 1, '0567745447', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(163, 'Hanaa Ahmed Asiry', 'هناء أحمد عسيري', 'hanaa05043@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Han05043380', 201122, 460, 3, 16, '0504338038', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(164, 'Abdulrhman Ahmed Sarhan', 'عبدالرحمن احمد سرحان', NULL, 'assets/members/default.png', '123456', 201123, 460, 3, 1, '0555555505', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(165, 'Maria Mohammed alsaadi', 'ماريا محمد الصاعدي', 'Maria.alsaadi20@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Mm12341234', 201124, 460, 3, 1, '0567774929', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(166, 'KHALID NASSER ALSURAYYI', 'خالد ناصر السريع', NULL, 'assets/members/default.png', '123456', 201125, 460, 3, 1, '0561186221', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(167, 'khald aeabdallah alghamidi', 'خالد عبدالله الغامدي', NULL, 'assets/members/default.png', '123456', 201126, 460, 3, 1, '0555555506', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(168, 'Rihab Salem Al-Harbi', 'رحاب سالم الحربي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201127, 460, 3, 9, '0550536339', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(169, 'Mana Ali Al-Muhayya', 'مانع علي آل محيا', NULL, 'assets/members/default.png', '123456', 201128, 460, 3, 2, '0554841212', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(170, 'Anwar M Bakhashwain', 'انور محمد باخشوين', 'Abakhashwain@gmail.com', 'assets/members/default.png', 'Lamaa2008', 201129, 460, 3, 2, '0500514665', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(171, 'Basma Badr Seddik', 'بسمة بدر صديق', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201130, 460, 3, 1, '0540959523', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(172, 'Jameel nabeel Ahmed', 'جميل نبيل عبده', NULL, 'assets/members/default.png', '123456', 201131, 460, 3, 1, '0540044229', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(173, 'Khawla M Al-Mass', 'خولة محمد الماص', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201133, 460, 3, 2, '0502594963', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(174, 'khriyah M. Alghamdi', 'خيرية محمد الغامدي', 'k@k.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201134, 460, 3, 4, '0505508150', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(175, 'Dleyel Hasan Alenezy', 'دليّل حسن العنزي', 'idleyel@outlook.com', 'assets/ryady-24461652920210509032652AM.png', '22446688', 201135, 460, 3, 2, '0555985421', 'محاضرةومدربة مدربين في مجالات تطوير الذات،التنمية البشرية ،اللياقة وفنون القتال،سيدة أعمال ومستشارة بإدارة وتشغيل الأندية والمرافق الرياضية', 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(176, 'MOHAMMED YAHYA ALNAMI', 'محمد يحيى النعمي', 'myn1500@gmail.com', 'assets/2B45F7D9-4A27-4CC7-A357-7E3DAF535C22.jpeg', 'Mohd5392', 201136, 460, 3, 17, '0544020911', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(177, 'Ruggia Rashed AlKatheiri', 'رقية رشاد الكثيري', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 221137, 230, 3, 1, '0509782807', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(178, 'Omar Mohammed Babtain', 'عمر محمد بابطين', 'omarbabtain96@gmail.com', 'assets/عمر بابطين.jpg', '3Omarbab@1', 201138, 460, 3, 8, '0555819947', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(179, 'einad KALID alqurashii', 'عناد خالد القرشي', NULL, 'assets/members/default.png', '123456', 201139, 460, 3, 4, '0566619623', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(180, 'Eid away almarwani', 'عيد عواد المرواني', NULL, 'assets/members/default.png', '123456', 201140, 460, 3, 1, '0500871500', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(181, 'gharis abrahim alfayiz', 'غرس إبراهيم الفائز', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201141, 460, 3, 2, '0509411252', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(182, 'Mahra Saeed Al-Ahmari', 'مهرة سعيد الاحمري', NULL, 'assets/مهرة.jpg', '123456', 201142, 460, 3, 1, '0508301000', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:20', NULL),
(183, 'Nujud Muhsen Alharbi', 'نجود محسن الحربي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201143, 460, 3, 5, '0583583858', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(184, 'Nawal Abdullah Altamimi', 'نوال عبدالله التميمي', 'm-nawal99-22@hotmail.com', 'assets/WhatsApp Image 2022-02-10 at 6.26.34 PM.jpeg', '123456', 201144, 460, 3, 2, '0546885236', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(185, 'HUDA SAMI ALJAFAR', 'هدى سامي الجعفر', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201145, 460, 3, 2, '0507578110', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(186, 'Kawthar Mohammed Hawsawi', 'كوثر محمد هوساوي', 'valium.k77@gmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201146, 460, 3, 4, '0505578261', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(187, 'Musa Sneed Al-Dubaisi', 'موسى سنيد الدبيسي', 'musa.photo.rm@gmail.com', 'assets/موسى الدبيسي.jpg', '1058177369Mm', 201148, 460, 3, 2, '0548302552', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(188, 'Hassan Mohammed Fallata', 'حسن محمد فلاته', 'alhyndas@gmail.com', 'assets/حسن فلاته.jpg', 'HASSANm1234567', 201149, 460, 3, 4, '0566653365', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(189, 'Abeer Fouad Khafaji', 'عبير فؤاد خفاجي', NULL, 'assets/عبير خفاجي.jpg', '123456', 201152, 460, 3, 1, '0543111370', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(190, 'Nora A. Al-Ghamdi', 'نورا عبدالرحمن الغامدي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 221153, 460, 3, 6, '0559540700', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(191, 'Ibrahim Hussein alaryani', 'إبراهيم حسين العرياني', 'Vip666_2@hotmail.com', 'assets/391605743719_servers.png', '123456', 201155, 460, 3, 2, '0505265734', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(192, 'Wisam Mohamed alhazmi', 'وسام محمد الحازمي', 'Wisamhazmi@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 201157, 460, 3, 1, '0568955152', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(193, 'Hana M. Al-Tuwairqi', 'هناء محمد الطويرقي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201158, 460, 3, 1, '0505612588', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(194, 'Abdulrhman Abdullah Alqhtani', 'عبدالرحمن عبدالله القحطاني', 'Abd.job.ksa@gmail.com', 'assets/عبدالرحمن القحطاني.jpeg', 'Aa0554623103', 201159, 460, 3, 1, '0554623103', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(195, 'Areej M Al-Qurashi', 'اريج محمد القرشي', NULL, 'assets/ryady-24461652920210509032652AM.png', '123456', 201161, 460, 3, 1, '0544915512', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(196, 'Kahmes S. Alzahrani', 'خميس سليم الزهراني', 'alzhranyk32@hotmail.com', 'assets/خميس.jpg', '1Q2w3e4r5t6y', 201162, 460, 3, 1, '0569957000', NULL, 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(197, 'Doaa Mostafa nazer', 'دعاء مصطفى ناظر', 'Dmnazer@gmail.con', 'assets/ryady-24461652920210509032652AM.png', '123456', 201163, 460, 3, 1, '0506692171', 'مؤسسة زين و حفلات \nلزينة رمضان و العيدين', 0, 1, 0, 'pending', '2022-04-10 00:30:21', NULL),
(198, 'afjksdsgdj kdfh iooff', 'وداد عبدالرحمن الغامدي', 'almanhapi@hotmail.com', 'assets/ryady-24461652920210509032652AM.png', '123456', 2400101, 0, 3, NULL, '2000000000', NULL, 0, 1, 0, 'pending', '2022-04-17 11:45:10', NULL),
(199, 'Abeer Bin Ateeq', 'عبير بن عاتق', 'abeer.mohsen.369@gmail.com', 'assets/عبيير.png', '123456', 2400102, 0, 3, 5, '0541002800', 'مستثمرة في الاسواق المالية، أملك شغف في تقديم الاسشارات، ماستر HR من الولايات المتحدة الامريكية', 0, 1, 0, 'pending', '2022-04-18 03:30:02', NULL),
(200, 'Youssef Mustafa Nazer', 'يوسف مصطفى ناظر', 'Youssef@Youssef.com', 'assets/يوسف ناظر.jpg', '123456', 2400104, 0, 3, 1, '0562053040', 'كوتش ..........', 0, 1, 0, 'pending', '2022-04-19 02:00:50', NULL),
(201, 'SDG FDGD DFD', 'لبلا لبلاسب', 'AYHKL@JO.COM', 'assets/members/default.png', '123456', 2400105, 0, 3, NULL, '9632587455', NULL, 0, 0, 0, 'pending', '2022-04-19 10:05:15', NULL),
(202, 'بل بللا يبلا', 'يببلبقيب يب بل', 'asdrfesf@hf.com', 'assets/members/default.png', '123456', 2400106, 0, 3, NULL, '5655555555', NULL, 0, 0, 0, 'pending', '2022-04-21 08:56:41', NULL),
(203, 'fghhtfg tht tht', 'ىبللاب فمت هغق', 'asl@hi.com', 'assets/members/default.png', '468596', 2400107, 0, 3, NULL, '898585', NULL, 0, 0, 0, 'pending', '2022-04-21 10:41:14', NULL),
(204, 'Mashail Hassan Alzahrani', 'مشاعل حسن الزهراني', 'mh-797@live.com', 'assets/ryady-24461652920210509032652AM.png', 'Mh7235mhm', 2400110, 460, 3, 1, '0550222328', 'حاصلة على رخصة العمل الحر في الوساطة العقارية للعقار وامثل عدد من الجهات في التسويق', 0, 1, 0, 'pending', '2022-04-26 23:06:01', NULL),
(205, 'ghfg dfgh dfdd', 'عهد محمد السفياني', 'dfdf@dffgfg.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', '123456', 2400111, 460, 3, NULL, '05566336666', NULL, 0, 1, 0, 'pending', '2022-05-01 10:01:57', NULL),
(206, 'Raed Bin Hallis', 'رائد بن حليس', 'Raedvip200@gmail.com', 'https://api.alshabalriyadi.net/assets/IMG_1805.JPG', '123456', 2400112, 0, 3, NULL, '0598629905', NULL, 0, 1, 0, 'pending', '2022-05-12 12:18:36', NULL),
(207, 'Nada Naseer Alotaibi', 'نـدى نـاصـر الـعـتـيـبـي', 'nada.n.alotaibi@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Nada1988', 2400113, 460, 3, 1, '0533222530', NULL, 0, 1, 0, 'pending', '2022-05-12 13:56:45', NULL),
(208, ';uiuyi', 'iyh;ioyh', 'drrgd@gg.com', 'assets/members/default.png', '123456', 2400114, 0, 3, NULL, '569845646+', NULL, 0, 0, 0, 'pending', '2022-05-14 15:22:10', NULL),
(209, 'Reem Ayman Sharaf', 'ريم أيمن شرف', 'reem97434@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Rsh97123@', 2400115, 460, 3, 8, '0540929129', 'كاتبة شغوفة في مجال القصص القصيرة الغامضة والخيالية. أطمح ان اصبح رائدة أعمال ملهمة وناجحة ', 0, 1, 0, 'pending', '2022-05-15 10:33:50', NULL),
(210, 'AMANI ALSHAMLAN', 'أماني مبارك ناصر آل شملان', 'amanialshamlan0@gmail.com', 'assets/members/default.png', 'Amani633', 2400117, 460, 3, NULL, '0559968239', NULL, 0, 0, 0, 'pending', '2022-05-15 23:02:11', NULL),
(211, 'May Nasser Al Yami', 'مي ناصر اليامي', 'mai744442@gmail.com', 'assets/members/default.png', 'May@75643', 2400118, 0, 3, NULL, '0559829098', NULL, 0, 0, 0, 'pending', '2022-05-16 05:26:42', NULL),
(212, 'Souad Abdullah ALthubyani', 'سعاد عبدالله الذبياني', 'sosy48084@gmail.com', 'assets/ryady-24461652920210509032652AM.png', 'Aa097618746', 2400119, 460, 3, 1, '0504346469', 'صاحبة عمل حُر ، و مهتمه في التسويق الإلكتروني و في تطوير مهاراتي ', 0, 1, 0, 'pending', '2022-05-16 14:53:48', NULL),
(213, 'ahamak aljkl aljk', 'احمد علي عاشور', 'fdddd@kiyik.com', 'assets/members/default.png', '123456', 2400122, 460, 3, NULL, '4589586497', NULL, 0, 0, 0, 'pending', '2022-05-22 22:50:27', NULL),
(214, 'Hajer Rashed Al-Mutiri', 'هاجر راشد المطيري', 'Hajer2321@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Hajer890', 2400125, 0, 3, 1, '0546270227', NULL, 0, 1, 0, 'pending', '2022-05-26 09:09:59', NULL),
(215, 'Abdurahman Ali Alameri', 'عبدالرحمن علي العامري', 'Vapusta@gmail.com', 'assets/members/default.png', 'Aa123456', 2400128, 460, 3, NULL, '0567964464', NULL, 0, 1, 0, 'pending', '2022-05-31 13:54:17', NULL),
(216, 'Rawyh joman alzahrani', 'راوية جمعان الزهراني', 'Rawyh04@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Ssr123321', 2400129, 230, 3, 1, '0537043528', 'شخصية طموحه، اسعى لتحقيق اهدافي وبناء مستقبل قوي يلبي طموحي، والوصول الى مكان مرموق لاساهم في بناء مجتمعي ووطني', 0, 1, 0, 'pending', '2022-06-01 18:14:26', NULL),
(217, 'Teaf Omar Atlas', 'طيف عمر أطلس', 'TeafCollege2055@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Toofe05028851740**', 2400131, 230, 3, NULL, '0502885174', 'اطمح لبناء مشروعي في ريادة الأعمال المبني على تحقيق الانجاز بالتوافق مع ترسيخ القيم والمبادئ الصحيحه بمستوى عالي من الادراك التفكيري والإبداعي المتميز', 0, 1, 0, 'pending', '2022-06-02 04:59:15', NULL),
(218, 'Asma Hassan Al-Harbi', 'اسماء حسن الحربي', 'Asbusiness990@gmail.com', 'https://api.alshabalriyadi.net/assets/p[.jpg', 'asmabus99', 2400132, 230, 3, 1, '0563758482', 'طموحه وأسعى لتحقيق الإمتياز بمهاراتي و كفاءتي بالعمل وتحقيق الإنتاجية بشكلٍ الاحترافي', 0, 1, 0, 'pending', '2022-06-02 07:52:48', NULL),
(219, 'Abaad ayish', 'أبعاد عائش', 'iabaad.ayish@gmail.com', 'assets/members/default.png', 'Aa123456', 2400133, 0, 3, NULL, '0561255253', NULL, 0, 0, 0, 'pending', '2022-06-04 05:54:41', NULL),
(220, 'Khaled Bandar Abdulaziz Al-Dhuibi', 'خالد بندر عبدالعزيز الذويبي', 'kkbbaa4321@gmail.com', 'assets/members/default.png', 'Kk@1093491080', 2400134, 0, 3, NULL, '0560909993', NULL, 0, 0, 0, 'pending', '2022-06-04 16:54:09', NULL),
(221, 'Sultana Asiri', 'سلطانه عسيري ', 'sultanhmk100100@gmail.com', 'assets/members/default.png', 'SULTanh10010', 2400136, 0, 3, NULL, '0544925311', NULL, 0, 0, 0, 'pending', '2022-06-11 12:35:33', NULL),
(222, 'Tawfik Nagash Ebraheem', 'توفيق نقاش ابراهيم', 'Tawfik.nagash@gmail.com', 'assets/members/default.png', 'Tt1&23456', 2400137, 0, 3, NULL, '0508993050', NULL, 0, 1, 0, 'pending', '2022-06-11 21:00:31', NULL),
(223, 'Raid modhi alfaiz', 'رائد مهدي الفايز', 'Raidnn5@gmail.com', 'assets/members/default.png', 'A123123a', 2400138, 0, 3, 3, '0540474914', 'رائد الفايز شاب سعودي مهتم في التصميم وريادة الاعمال ورئيس مجلس الإدارة لعدة مؤسسات اطمح ان نكون من رواد هذا المجال #الطائف #جدة #مكة', 0, 1, 0, 'pending', '2022-06-11 23:50:18', NULL);
INSERT INTO `users` (`id`, `name`, `name_ar`, `email`, `img`, `password`, `serial`, `points`, `role_id`, `city_id`, `phone`, `breif`, `featured`, `active`, `admin`, `status`, `created_at`, `deleted_at`) VALUES
(224, 'trtyrttyrt', 'dfyhtrty', 'rtdhrtf@h.com', 'assets/members/default.png', '68678767897', 2400139, 0, 3, NULL, '86678677867867', NULL, 0, 0, 0, 'pending', '2022-06-12 20:41:45', NULL),
(225, 'Abdulaziz Ahmed Azlahrani', 'عبدالعزيز أحمد الزهراني', 'z7007-@hotmail.com', 'assets/members/default.png', 'Az123Az12z', 2400140, 0, 3, NULL, '0533338410', NULL, 0, 0, 0, 'pending', '2022-06-12 21:10:28', NULL),
(226, 'MANSOUR MUTLAQ ALOTAIBI', 'منصور مطلق العنيبي', 'nova3e1150@gmail.com', 'assets/members/default.png', 'mans1234', 2400141, 0, 3, 3, '0505791360', NULL, 0, 1, 0, 'pending', '2022-06-14 17:00:17', NULL),
(227, 'Yuosef Abdalraman Hassan', 'يوسف عبدالرحمن بندقجي', 'yuosef3000@gmail.com', 'https://api.alshabalriyadi.net/assets/IMG-20181209-WA0057.jpg', 'Ladan1234', 2400142, 0, 3, 1, '0507551277', 'باحث ومبتكر ', 0, 1, 0, 'pending', '2022-06-16 12:47:58', NULL),
(228, 'Maha Saleh Ahmad', 'مها صالح أحمد', 'Hopeful-heart2009@hotmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Msz66949', 2400143, 0, 3, NULL, '0555066949', NULL, 0, 1, 0, 'pending', '2022-06-17 12:33:30', NULL),
(229, 'Saud T. Al-Marzooqi', 'سعود ثامر المرزوقي', 'llsss30odl@gmail.com', 'assets/members/default.png', '732173', 2400144, 0, 3, NULL, '0508142028', NULL, 0, 1, 0, 'pending', '2022-06-23 17:35:06', NULL),
(230, 'Sadiyah Mohsen Alfadhli', 'سعدية محسن الفضلي', 'sawsanmohsen969@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Ss123123', 2400145, 0, 3, 1, '0553302959', 'شغفي بالنحت ليس له حدود وطموحي أن اضع منحوتاتي في جميع أنحاء العالم ', 0, 1, 0, 'pending', '2022-06-26 17:09:53', NULL),
(231, 'Eman Abdullah  AlQurashi', 'ايمان عبدالله القرشي', 'e7980076@gmail.com', 'assets/members/default.png', '123456', 2400146, 0, 3, NULL, '053116363', NULL, 0, 0, 0, 'pending', '2022-06-26 18:19:20', NULL),
(232, 'Elham Amer Ali', 'إلهام عامر علي', 'ibrahim899013@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', 'Ee0501909012', 2400147, 230, 3, NULL, '0501909012', NULL, 0, 1, 0, 'pending', '2022-06-26 18:54:05', NULL),
(233, 'Ebtihal Hussain AlMutawa', 'ابتهال حسين المطوع', 'Ebtihalhm@gmail.com', 'https://api.alshabalriyadi.net/assets/ryady-24461652920210509032652AM.png', '123456', 2400148, 0, 3, NULL, '0504961005', NULL, 0, 1, 0, 'pending', '2022-06-27 08:32:08', NULL),
(234, 'Esraa alhargi', 'اسراء الحارقي ', 'Esoooksa@gmail.com', 'assets/members/default.png', 'Sr123456789', 2400151, 0, 3, NULL, '0541518107', NULL, 0, 0, 0, 'pending', '2022-08-01 11:46:56', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_events`
--

CREATE TABLE `user_events` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `price` float UNSIGNED DEFAULT NULL,
  `method` enum('card','cash') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `points` int(10) UNSIGNED DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_notifications`
--

CREATE TABLE `user_notifications` (
  `user_id` int(11) DEFAULT NULL,
  `notification_id` int(11) DEFAULT NULL,
  `seen_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_services`
--

CREATE TABLE `user_services` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `service_id` int(11) DEFAULT NULL,
  `status` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `seen_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_subs`
--

CREATE TABLE `user_subs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `price` float UNSIGNED DEFAULT NULL,
  `method` enum('card','cash') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `points` int(10) UNSIGNED DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_subs`
--

INSERT INTO `user_subs` (`id`, `user_id`, `role_id`, `price`, `method`, `points`, `created_at`, `start_at`, `end_at`, `approved_at`) VALUES
(27, 210, 3, 460, 'cash', 460, '2022-05-15 23:02:11', '2022-05-15 23:02:11', '2023-05-15 23:02:11', NULL),
(28, 211, 3, 460, 'cash', 460, '2022-05-16 05:26:42', '2022-05-16 05:26:42', '2023-05-16 05:26:42', NULL),
(29, 212, 3, 460, 'cash', 460, '2022-05-16 14:53:48', '2022-05-16 14:53:48', '2023-05-16 14:53:48', NULL),
(30, 213, 3, 460, 'cash', 460, '2022-05-22 22:50:27', '2022-05-22 22:50:27', '2023-05-22 22:50:27', NULL),
(31, 214, 3, 460, 'cash', 460, '2022-05-26 09:09:59', '2022-05-26 09:09:59', '2023-05-26 09:09:59', NULL),
(32, 215, 3, 460, 'cash', 460, '2022-05-31 13:54:17', '2022-05-31 13:54:17', '2023-05-31 13:54:17', NULL),
(33, 219, 3, 460, 'cash', 460, '2022-06-04 05:54:42', '2022-06-04 05:54:42', '2023-06-04 05:54:42', NULL),
(34, 220, 3, 460, 'cash', 460, '2022-06-04 16:54:09', '2022-06-04 16:54:09', '2023-06-04 16:54:09', NULL),
(35, 221, 3, 460, 'cash', 460, '2022-06-11 12:35:33', '2022-06-11 12:35:33', '2023-06-11 12:35:33', NULL),
(36, 222, 3, 460, 'cash', 460, '2022-06-11 21:00:31', '2022-06-11 21:00:31', '2023-06-11 21:00:31', NULL),
(37, 223, 3, 460, 'cash', 460, '2022-06-11 23:50:18', '2022-06-11 23:50:18', '2023-06-11 23:50:18', NULL),
(38, 224, 3, 460, 'cash', 460, '2022-06-12 20:41:45', '2022-06-12 20:41:45', '2023-06-12 20:41:45', NULL),
(39, 225, 3, 460, 'cash', 460, '2022-06-12 21:10:28', '2022-06-12 21:10:28', '2023-06-12 21:10:28', NULL),
(40, 226, 3, 460, 'cash', 460, '2022-06-14 17:00:17', '2022-06-14 17:00:17', '2023-06-14 17:00:17', NULL),
(41, 227, 3, 460, 'cash', 460, '2022-06-16 12:47:58', '2022-06-16 12:47:58', '2023-06-16 12:47:58', NULL),
(42, 228, 3, 460, 'cash', 460, '2022-06-17 12:33:30', '2022-06-17 12:33:30', '2023-06-17 12:33:30', NULL),
(43, 229, 3, 460, 'cash', 460, '2022-06-23 17:35:06', '2022-06-23 17:35:06', '2023-06-23 17:35:06', NULL),
(44, 230, 3, 460, 'cash', 460, '2022-06-26 17:09:53', '2022-06-26 17:09:53', '2023-06-26 17:09:53', NULL),
(45, 231, 3, 460, 'cash', 460, '2022-06-26 18:19:20', '2022-06-26 18:19:20', '2023-06-26 18:19:20', NULL),
(46, 233, 3, 460, 'cash', 460, '2022-06-27 08:32:08', '2022-06-27 08:32:08', '2023-06-27 08:32:08', NULL),
(47, 234, 3, 460, 'cash', 460, '2022-08-01 11:46:56', '2022-08-01 11:46:56', '2023-08-01 11:46:56', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `videos`
--

CREATE TABLE `videos` (
  `id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Breif` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `videos`
--

INSERT INTO `videos` (`id`, `name`, `url`, `image`, `Breif`, `category_id`, `deleted_at`) VALUES
(1, 'حياة الكفاح - تجارب علمتني ح 1', 'a7sJ4MBtL2A', 'assets/videos/01.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 18, NULL),
(2, 'حياة الكفاح - تجارب علمتني ح 2', '2MiTWgoazy0', 'assets/videos/02.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 3, NULL),
(3, 'اساسيات بناء وتأسيس المشاريع -  أ. احمد المنهبي', 'Zla7htgnf_g', 'assets/videos/03.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 20, NULL),
(4, 'الشاب الريادي', 'https://www.youtube.com/watch?v=LmiTt8LWyHA&t=46s', 'assets/videos/04.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 21, NULL),
(5, 'حياة الكفاح - تجارب علمتني ح 2', '2MiTWgoazy0', 'assets/videos/02.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 22, NULL),
(6, 'حياة الكفاح - تجارب علمتني ح 1', 'a7sJ4MBtL2A', 'assets/videos/01.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 6, NULL),
(7, 'قصة تأسيس ماكدذونالز من قبل الأخوين ( ماك ، ديك ) ودخول الشريك', 'https://www.youtube.com/watch?v=_lbIYWmVwnk', '', 'وجود الشريك منذ الخطوات الأولى للمشروع قد يكون سبب للنمو وقد يكون العكس،\nهذا الفلم 🎥 يحكي قصة تأسيس الشركة من قبل الأخوين ( ماك ، ديك ) ودخول الشريك', 20, NULL),
(8, 'مليارديرات التكنولوجيا: مارك زوكربيرغ - وثائقيات', 'https://www.youtube.com/watch?v=NHwp8MqcpZc', '', 'ريادي الإنترنت ومبتكر التقنيات، الموهوب في برامج الحاسوب، الرجل الذي أصبح أصغر ملياردير في العالم، والذي ابتكر إحدى أكثر شبكات التواصل الاجتماعي شعبية في العالم، فيسبوك، إلى جانب أمازون وغوغل وأبل ومايكروسوفت، شركة فيسبوك هي إحدى الشركات الخمس الكبرى في مجال التكنولوجيا في الولايات المتحدة الأميركية، إذا ماذا تطلب بناء هذه الشركة الثورية؟ لقد تطلب شخصا مثل مارك زوكربيرغ، الشاب العبقري الذي ربط بين الناس بطرق لم يظن أحد أنها ممكنة', 20, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `articles`
--
ALTER TABLE `articles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_article_user` (`user_id`),
  ADD KEY `fk_article_cat` (`category_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `consultunts`
--
ALTER TABLE `consultunts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `contact_requests`
--
ALTER TABLE `contact_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_contact_requests_user` (`user_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_project_event` (`category_id`);

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `msgs`
--
ALTER TABLE `msgs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_msg_from` (`from_id`),
  ADD KEY `fk_msg_to` (`to_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_project_user` (`user_id`),
  ADD KEY `fk_project_category` (`category_id`),
  ADD KEY `fk_project_city` (`city_id`);

--
-- Indexes for table `rich_text`
--
ALTER TABLE `rich_text`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_user_role` (`role_id`),
  ADD KEY `fk_user_city` (`city_id`);

--
-- Indexes for table `user_events`
--
ALTER TABLE `user_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_events_user` (`user_id`),
  ADD KEY `fk_user_events_event` (`event_id`);

--
-- Indexes for table `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD KEY `fk_user_notifications_user` (`user_id`),
  ADD KEY `fk_user_notifications_notification` (`notification_id`);

--
-- Indexes for table `user_services`
--
ALTER TABLE `user_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_services_user` (`user_id`),
  ADD KEY `user_services_service` (`service_id`);

--
-- Indexes for table `user_subs`
--
ALTER TABLE `user_subs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_subs_user` (`user_id`),
  ADD KEY `fk_user_subs_role` (`role_id`);

--
-- Indexes for table `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_video_category` (`category_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `articles`
--
ALTER TABLE `articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `consultunts`
--
ALTER TABLE `consultunts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `contact_requests`
--
ALTER TABLE `contact_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `msgs`
--
ALTER TABLE `msgs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `rich_text`
--
ALTER TABLE `rich_text`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;

--
-- AUTO_INCREMENT for table `user_events`
--
ALTER TABLE `user_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_services`
--
ALTER TABLE `user_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `user_subs`
--
ALTER TABLE `user_subs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `videos`
--
ALTER TABLE `videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `articles`
--
ALTER TABLE `articles`
  ADD CONSTRAINT `fk_article_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_article_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `contact_requests`
--
ALTER TABLE `contact_requests`
  ADD CONSTRAINT `fk_contact_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `fk_project_event` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `msgs`
--
ALTER TABLE `msgs`
  ADD CONSTRAINT `fk_msg_from` FOREIGN KEY (`from_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_msg_to` FOREIGN KEY (`to_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `fk_project_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_project_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_project_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_events`
--
ALTER TABLE `user_events`
  ADD CONSTRAINT `fk_user_events_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_events_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_notifications`
--
ALTER TABLE `user_notifications`
  ADD CONSTRAINT `fk_user_notifications_notification` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_services`
--
ALTER TABLE `user_services`
  ADD CONSTRAINT `user_services_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_services_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_subs`
--
ALTER TABLE `user_subs`
  ADD CONSTRAINT `fk_user_subs_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_subs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `videos`
--
ALTER TABLE `videos`
  ADD CONSTRAINT `fk_video_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
