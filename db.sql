-- phpMyAdmin SQL Dump
-- version 4.9.7deb1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 12, 2022 at 03:52 AM
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
    SELECT id , name_ar , img FROM users WHERE id != Iuser_id;
    SELECT DISTINCT anotherUser.id ,anotherUser.name ,  anotherUser.img 
        FROM users currentUser 
        JOIN msgs m 
            ON m.from_id = currentUser.id 
        JOIN users anotherUser 
            ON m.to_id = anotherUser.id 
        WHERE currentUser.id = Iuser_id 
        UNION
    SELECT DISTINCT anotherUser.id ,anotherUser.name , anotherUser.img 
        FROM users currentUser 
        JOIN msgs m 
            ON m.to_id = currentUser.id 
        JOIN users anotherUser 
            ON m.from_id = anotherUser.id 
        WHERE currentUser.id = Iuser_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MsgsListByUser` (`id1` INT, `id2` INT)  BEGIN
    SELECT m.id ,IF(m.from_id = id1 , TRUE , FALSE) mine, u.name_ar name ,m.breif , m.created_at , IFNULL(m.seen , '') seen 
    FROM msgs m 
      JOIN users u ON m.from_id = u.id
    WHERE (m.from_id = id1 AND m.to_id = id2) OR (m.from_id = id2 AND m.to_id = id1) 
  
    ORDER BY m.created_at ASC, id ASC;
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
(1, 5, 1, 'كيفية إقناع المستثمرين والممولين بفكرة مشروعك', 'assets/blog/01.jpeg', 'pending', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 0, 3, '2022-09-12 02:33:45', NULL, NULL),
(2, 6, 2, 'التوازن في عجلة الحياة تجاه ذاتك واهدافك', 'assets/blog/02.jpeg', 'active', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 0, 3, '2022-09-12 02:33:45', '2022-09-12 02:33:45', NULL),
(3, 7, 3, 'كيف واجهت شركة جنرال إلكتريك مشكلاتها المالية', 'assets/blog/03.jpeg', 'active', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات . ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور. أيكسسيبتيور ساينت أوككايكات كيوبايداتات نون بروايدينت ,سيونت ان كيولباكيو أوفيسيا ديسيريونتموليت انيم أيدي ايست لابوريوم.\"\"سيت يتبيرسبايكياتيس يوندي أومنيس أستي ناتيس أيررور سيت فوليبتاتيم أكيسأنتييومدولاريمكيو لايودانتيوم,توتام ريم أبيرأم,أيكيو أبسا كيواي أب أللو أنفينتوري فيرأتاتيس ايتكياسي أرشيتيكتو بيتاي فيتاي ديكاتا سيونت أكسبليكابو. نيمو أنيم أبسام فوليوباتاتيم كيوايفوليوبتاس سايت أسبيرناتشر أيوت أودايت أيوت فيوجايت, سيد كيواي كونسيكيونتشر ماجنايدولارس أيوس كيواي راتاشن فوليوبتاتيم سيكيواي نيسكايونت. نيكيو بوررو كيوايسكيومايست,كيواي دولوريم ايبسيوم كيوا دولار سايت أميت, كونسيكتيتيور,أديبايسكاي فيلايت, سيدكيواي نون نيومكيوام ايايوس موداي تيمبورا انكايديونت يوت لابوري أيت دولار ماجنامألايكيوام كيوايرات فوليوبتاتيم. يوت اينايم أد مينيما فينيام, كيواس نوستريوم أكسيركايتاشيميلامكوربوريس سيوسكايبيت لابورايوسام, نايساي يوت ألايكيوايد أكس أيا كومودايكونسيكيواتشر؟', 0, 3, '2022-09-12 02:33:45', '2022-09-12 02:33:45', NULL);

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
(1, 'انس محمود الانصاري', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-02.jpg', 0, 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبور أنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا', NULL),
(2, 'رزان احسان الطويل', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/female-02.jpg', 0, 'وت انيم أد مينيم فينايم,كيواس نوستريد أكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات', NULL),
(3, 'وليد عبد الواسع قوقندي', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-03.jpg', 0, 'ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور لابورأس نيسي يت أليكيوب', NULL),
(4, 'احمد بن محمد السعيد', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-04.jpg', 0, 'ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور لابورأس نيسي يت أليكيوب', NULL),
(5, 'عمر فايز', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-02.jpg', 1, 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبور أنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا', NULL),
(6, 'احمد منهبي', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/female-02.jpg', 1, 'وت انيم أد مينيم فينايم,كيواس نوستريد أكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات', NULL),
(7, 'احمد اشرف', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-03.jpg', 1, 'ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور لابورأس نيسي يت أليكيوب', NULL),
(8, 'محمد اشرف', 'مستشار اقتصادي', 'التخطيط,ادارة الاعمال,التسويق', 'assets/members/male-04.jpg', 1, 'ديواسأيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايتنيولا باراياتيور لابورأس نيسي يت أليكيوب', NULL);

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

--
-- Dumping data for table `contact_requests`
--

INSERT INTO `contact_requests` (`id`, `user_id`, `name`, `email`, `phone`, `status`, `subject`, `msg`, `created_at`) VALUES
(1, 5, 'مشعل علي البرجس', 'mashasl@gmail.com', '05466176661', 'PENDING', 'ترقية العضوية', 'اريد ان ارقي العضوية', '2022-09-12 02:33:45');

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
(1, 'توليد الافكار للمشاريع', 'assets/events/01.jpeg', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2022-04-09', 150, 1, 13, '2022-09-12 02:33:44', NULL),
(2, 'تحدث الى خبير', 'assets/events/02.png', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-28', 100, 1, 14, '2022-09-12 02:33:44', NULL),
(3, 'تجمع مجتمع الشاب الريادي', 'assets/events/03.jpeg', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-27', 55, 1, 15, '2022-09-12 02:33:44', NULL),
(4, 'شبكة اعمال تنفيذية', 'assets/events/04.png', 'https://www.youtube.com/embed/2MiTWgoazy0', '  <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>\n            <p> لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأسلوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس</p>', '2021-11-18', 55, 1, 16, '2022-09-12 02:33:44', NULL);

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
(1, 1, 2, '2022-09-12 02:33:45', 'مرحبا', NULL),
(2, 1, 5, '2022-09-12 02:44:41', 'فثسف', NULL),
(3, 5, 1, '2022-09-12 02:45:45', 'test', NULL),
(4, 5, 1, '2022-09-12 02:49:44', 'test', NULL),
(5, 1, 5, '2022-09-12 02:50:43', 'asdasd', NULL),
(6, 5, 1, '2022-09-12 02:51:28', 'asd', NULL),
(7, 5, 1, '2022-09-12 02:51:34', 'asdasdasdasdasd', NULL);

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
(1, 3, 7, 1, 'تتبع الشحنات عبر الإنترنت', 'assets/projects/01-logo.jpg', 'assets/projects/01.jpg', 3000, 'قائم', 'كمن فكرة شركة Flexport المميزة في كونها شركة شحن ووسيط جمركي افتراضي، سمحت هذه الشركة للعملاء بتتبع شحناتهم عبر الإنترنت في الوقت الفعلي، وهو مفهوم جديد تمامًا لهذه الصناعة، يستخدم الآلاف من التجار في أمازون الشركة الناشئة لنقل بضائعهم، مثل: Warby Parker وصانع الأحذية Allbirds وبشكل عام، تقوم الشركة بتتبع عملية نقل حوالي 100.000 حاوية شحن كل عام،', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-09-12 02:33:45', NULL),
(2, 4, 8, 1, 'التسويق للتطبيقات الذكية', 'assets/projects/02-logo.jpg', 'assets/projects/02.jpg', 7000, 'متعثر', 'تقوم شركة Liftoff  على فكرة التسويق لتطبيقات الهواتف الذكية، تقوم برمجيات الشركة على أتمتة إنشاء الإعلانات وشرائها، بهدف الوصول إلى جمهور يهتم فعلا بمنتج علامة تجارية ما، حيث يدفع الزبائن للشركة فقط عندما يقوم المستخدم بإجراء عملية بيع أو تحميل التطبيق، حققت الشركة عام 2017 مداخيل بلغت 123.4 مليون دولار.', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-09-12 02:33:45', NULL),
(3, 5, 9, 1, 'توفير استهلاك الطاقة من خلال البيوت الذكية', 'assets/projects/03-logo.jpg', 'assets/projects/03.jpg', 3000, 'متعثر', 'تقديم الاستشارات الادارية والتسويقية وابتكار منتجات استثمار اجتماعي تستهدف القطاع الغير ربحي والأوقاف لتعزيز استدامته ودعم الرؤية الوطنية 2030 وهو من ضمن مشاريع الاستثمار الاجتماعي يدمج بين نموذجي العمل الاقتصادي والاجتماعي مما يحقق أثرا اقتصاديا واجتماعيا ولدي منتجات ( الخدمات الاستشارية في مجال القطاع الغير ربحي استشاري(وقفي ،غير ربحي) -ادراي -حوكمة ،', 'assets/projects/01.jpg,assets/projects/02.jpg,assets/projects/03.jpg', 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 1, '2022-09-12 02:33:45', NULL),
(4, 6, 10, 1, 'بيع وشراء السيارات المستعملة عبر الإنترنت', 'assets/projects/04-logo.jpg', 'assets/projects/04.jpg', 3000, 'قائم', 'تقديم الاستشارات الادارية والتسويقية وابتكار منتجات استثمار اجتماعي تستهدف القطاع الغير ربحي والأوقاف لتعزيز استدامته ودعم الرؤية الوطنية 2030 وهو من ضمن مشاريع الاستثمار الاجتماعي يدمج بين نموذجي العمل الاقتصادي والاجتماعي مما يحقق أثرا اقتصاديا واجتماعيا ولدي منتجات ( الخدمات الاستشارية في مجال القطاع الغير ربحي استشاري(وقفي ،غير ربحي) -ادراي -حوكمة ،', NULL, 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d7245.237072462584!2d46.738586!3d24.774265!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMjTCsDQ2JzI3LjQiTiA0NsKwNDQnMTguOSJF!5e0!3m2!1sen!2sus!4v1636582363311!5m2!1sen!2sus', '0546617666', 'assets/projects/pr.pdf', 'inadhmi@gmail.com', 1, NULL, NULL, NULL, 0, '2022-09-12 02:33:45', NULL);

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
(1, 'banner', 'home', '<strong>متفرد</strong> لتبادل الخبرات وتنمية المهارات', ' أفضل مجتمع أعمال حيوي ', 'assets/banner.png', 0, NULL),
(2, 'vision', 'home', 'أفضل مجتمع اعمال حيوي متفرد لرواد الاعمال واصحاب المشاريع', 'رؤيتنا', NULL, 1, 'mdi-eye-outline'),
(3, 'msg', 'home', 'تمكين الشباب من تأسيس وتطوير مشاريع نوعية واعدة', 'رسالتنا', NULL, 1, 'mdi-flag-outline'),
(4, 'mission', 'home', 'تكوين مجتمع حيوي لتبادل أفضل الممارسات والشراكات', 'مهمتنا', NULL, 1, 'mdi-bullseye-arrow'),
(5, 'values', 'home', 'بناء العلاقات واثراء المعرفة لتحقيق النجاح المشترك', 'قيمنا', NULL, 1, 'mdi-chart-box-outline'),
(6, 'small_business', 'business', 'أصحاب المشاريع الناشئة والصغيرة', NULL, NULL, 2, 'apartment'),
(7, 'ideas', 'business', 'أصحاب الأفكار الخلاقة والواعدة ', NULL, NULL, 2, 'tungsten'),
(8, 'students', 'business', 'طلاب الإدارة والاقتصاد وريادة الاعمال', NULL, NULL, 2, 'add_business'),
(9, 'business_men', 'business', 'المهتمين بمجال المال والأعمال وريادة الاعمال', NULL, NULL, 2, 'admin_panel_settings'),
(10, 'business_men', 'business', 'الباحثين عن تأسيس مشاريعهم التجارية', NULL, NULL, 2, 'assistant_photo');

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
(1, 'عضوية مبادر', 'assets/memberships/mobader.png', ' تساهم في تنمية مهاراتك تجاه العمل الحر', 230, '#6a278a', 1),
(2, 'عضوية طموح', 'assets/memberships/tamooh.png', ' تساهم في استثمار أفكارك الواعدة نحو الحرية المالية', 345, '#004f55', 1),
(3, 'عضوية ريادي', 'assets/memberships/ryady.png', ' تساهم في تكوين علاقات وشراكات لنمو اعمالك', 460, '#0026a0', 1);

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
(4, 'دراسة جدوي', 'equalizer', NULL);

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
(1, 'admin', 'مسئول', 'admin@alshabalriyadi.net', 'assets/members/male-03.jpg', '123456', 240000, 460, 3, NULL, '05555555555', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 0, 1, 1, 'pending', '2022-09-12 02:33:44', NULL),
(2, 'ahmed mohamed moustafa', 'احمد محمد مصطفي', 'a.mohamedd@gmail.com', 'assets/members/male-01.jpg', '123456', 2400100, 230, 1, NULL, '05466176681', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبور أنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا .', 0, 0, 0, 'pending', '2022-09-12 02:33:44', NULL),
(3, 'ahmed ashraf darwish', 'احمد اشرف درويش', 'a.ashraf@gmail.com', 'assets/members/male-01.jpg', '123456', 2400100, 230, 1, NULL, '05466176622', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبور أنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا .', 0, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(4, 'nadya el khoshromy', 'نادية الخشرمي', 'nadiaa@gmail.com', 'assets/members/female-01.jpg', '123456', 2200100, 345, 2, NULL, '05466176671', 'يوت انيم أد مينيم فينايم,كيواس نوستريد أكسير سيتاشن يللأمكو لابورأس نيسي يت أليكيوب أكس أيا كوممودو كونسيكيوات ', 0, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(5, 'Mashal Ali Albrgs', 'مشعل علي البرجس', 'mashasl@gmail.com', 'assets/members/male-02.jpg', '123456', 2000100, 460, 3, NULL, '05466176661', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 0, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(6, 'sahar salem elhotamy', 'سحر سالم الحطامي', 'saharr@gmail.com', 'assets/members/female-02.jpg', '123456', 2000102, 460, 3, NULL, '00546617665', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 0, 1, 1, 'pending', '2022-09-12 02:33:44', NULL),
(7, 'ahmed mohamed moustafa', ' عبدالله أحمد حسان', 'abdallaha@gmail.com', 'assets/members/male-03.jpg', '123456', 2000103, 460, 3, NULL, '00546617664', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 1, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(8, 'Hashm ahmed safy', 'هاشم احمد الصافي', 'hashema@gmail.com', 'assets/members/male-04.jpg', '123456', 2000104, 460, 3, NULL, '00546617663', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 1, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(9, 'ayed ouda alharby', 'عايد عوده الحربي', 'ayedd@gmail.com', 'assets/members/male-05.jpg', '123456', 2000105, 460, 3, NULL, '05466617662', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 1, 1, 0, 'pending', '2022-09-12 02:33:44', NULL),
(10, 'sara essam zahed', 'سارة عصام زاهد', 'saraa@gmail.com', 'assets/members/female-03.jpg', '123456', 2000106, 460, 3, NULL, '05466176611', 'يواس أيوتي أريري دولار إن ريبريهينديرأيت فوليوبتاتي فيلايت أيسسي كايلليوم دولار أيو فيجايت نيولا باراياتيور', 1, 1, 0, 'pending', '2022-09-12 02:33:44', NULL);

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

--
-- Dumping data for table `user_services`
--

INSERT INTO `user_services` (`id`, `user_id`, `breif`, `service_id`, `status`, `seen_at`, `created_at`) VALUES
(1, 5, 'i need this service', 1, 'pending', NULL, '2022-09-12 02:33:44');

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
(1, 4, 3, 460, 'cash', 460, '2022-09-12 02:33:45', '2021-04-17 00:00:00', '2023-04-17 00:00:00', NULL),
(2, 3, 3, 460, 'cash', 460, '2022-09-12 02:33:45', '2021-04-17 00:00:00', '2022-04-17 00:00:00', NULL),
(3, 2, 1, 230, 'cash', 230, '2022-09-12 02:33:45', '2022-01-01 00:00:00', '2022-12-31 00:00:00', '2022-01-01 00:00:00');

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
(2, 'حياة الكفاح - تجارب علمتني ح 2', '2MiTWgoazy0', 'assets/videos/02.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 19, NULL),
(3, 'اساسيات بناء وتأسيس المشاريع -  أ. احمد المنهبي', 'Zla7htgnf_g', 'assets/videos/03.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 20, NULL),
(4, 'الشاب الريادي', 'j5K6Gb9lz5M', 'assets/videos/04.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 21, NULL),
(5, 'حياة الكفاح - تجارب علمتني ح 2', '2MiTWgoazy0', 'assets/videos/02.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 22, NULL),
(6, 'حياة الكفاح - تجارب علمتني ح 1', 'a7sJ4MBtL2A', 'assets/videos/01.webp', 'لوريم ايبسوم دولار سيت أميت ,كونسيكتيتور أدايبا يسكينج أليايت,سيت دو أيوسمود تيمبورأنكايديديونتيوت لابوري ات دولار ماجنا أليكيوا . يوت انيم أد مينيم فينايم,كيواس نوستريدأكسير سيتاشن يللأمكو لابورأس', 23, NULL);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `consultunts`
--
ALTER TABLE `consultunts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `contact_requests`
--
ALTER TABLE `contact_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `msgs`
--
ALTER TABLE `msgs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `rich_text`
--
ALTER TABLE `rich_text`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_events`
--
ALTER TABLE `user_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_services`
--
ALTER TABLE `user_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_subs`
--
ALTER TABLE `user_subs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `videos`
--
ALTER TABLE `videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
