USE alshab_staging2;

# procedures\\
#/// users////


DROP PROCEDURE IF EXISTS UserCreate;

DELIMITER //

CREATE PROCEDURE UserCreate(
    IN Iname varchar(250),
    IN Iname_ar varchar(250),
    IN Iemail varchar(250),
    IN Ipassword varchar(250),
    IN Iserial varchar(250),
    IN Irole_id INT,
    IN Iphone VARCHAR(250),
    IN Ibreif TEXT(250)
) BEGIN
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

END // 
DELIMITER ;


DROP PROCEDURE IF EXISTS UserById;
DELIMITER // 


CREATE PROCEDURE UserById(IN Iid int) 
BEGIN

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
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS UserDelete;

DELIMITER //


CREATE PROCEDURE UserDelete(IN id INT) BEGIN
UPDATE
    users u
SET
    deleted_at = now()
WHERE
    u.id = id;

END //



DELIMITER ;

DROP PROCEDURE IF EXISTS UserListByRoleOrFeatured;

DELIMITER //


CREATE PROCEDURE UserListByRoleOrFeatured(
    IN role INT ,
    IN featured BOOLEAN ,
    IN admin BOOLEAN ,
    IN Iname VARCHAR(100),
    IN Iphone VARCHAR(100),
    IN Iemail VARCHAR(100),
    IN Iserial VARCHAR(100)
 ) 
BEGIN

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
    END//
DELIMITER ;




DROP PROCEDURE IF EXISTS UserServiceCreate;

DELIMITER //
CREATE  PROCEDURE `UserServiceCreate`(userId INT , serviceId int , Ibreif TEXT)
BEGIN
   INSERT INTO user_services (user_id , service_id , breif) VALUES (userId , serviceId , Ibreif);
   SELECT LAST_INSERT_ID() id ;
    
END//
DELIMITER ;

# articles
DROP PROCEDURE IF EXISTS ArticleDelete;
DELIMITER // 


CREATE PROCEDURE ArticleDelete(IN id INT) BEGIN
    UPDATE
        articles a
    SET
        deleted_at = now()
    WHERE
        a.id = id;

    SELECT id;

END //
DELIMITER ;


DROP PROCEDURE IF EXISTS ArticleCreate;
DELIMITER //
CREATE PROCEDURE ArticleCreate(
    IN Iuser_id INT,
    IN Icategory_id INT,
    IN Iviews_count_rate INT,
    IN Ititle VARCHAR(250),
    IN Iimg VARCHAR(250),
    IN Icontent TEXT,
    IN Istatus VARCHAR(250)
) BEGIN
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

END //
DELIMITER ;
DROP PROCEDURE IF EXISTS ArticleUpdate;

DELIMITER //
CREATE PROCEDURE ArticleUpdate(
    IN Iid INT,
    IN Iuser_id INT,
    IN Icategory_id INT,
    IN Iviews_count_rate INT,
    IN Ititle VARCHAR(250),
    IN Iimg VARCHAR(250),
    IN Icontent TEXT,
    IN Istatus VARCHAR(250)
) BEGIN
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
END //


DELIMITER ;
DROP PROCEDURE IF EXISTS ArticleList;
DELIMITER //
 
CREATE PROCEDURE `ArticleList`(
    IN `page` smallint(3),
    IN `u` int,
    IN `cat` int
) BEGIN DECLARE userCond VARCHAR(100) DEFAULT '';

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

END // 
DELIMITER ;


DROP PROCEDURE IF EXISTS RichTextListByGroupOrKey;
DELIMITER //

CREATE PROCEDURE RichTextListByGroupOrKey(
    IN IGroup Int,
    IN IKey VARCHAR(250)
)
BEGIN

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
END //

DELIMITER ;




DROP PROCEDURE IF EXISTS RichTextListByPage;
DELIMITER //

CREATE PROCEDURE RichTextListByPage(IN Ipage VARCHAR(100) , IN Ititle  VARCHAR(250) , IN Ivalue  TEXT)
BEGIN
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
END //

DELIMITER ;





DROP PROCEDURE IF EXISTS RichTextListById;
DELIMITER //

CREATE PROCEDURE RichTextListById(IN Iid int)
BEGIN
    SELECT 
        r.id,
        r.value,
        r.title,
        IFNULL(r.image , "") image,
        IFNULL(r.icon , "") icon
        FROM rich_text r
            WHERE id = Iid;
END //

DELIMITER ;


# roles

DELIMITER ;
DROP PROCEDURE IF EXISTS RolesList;


DELIMITER //
CREATE  PROCEDURE `RolesList`(IN active BOOLEAN , IN Iname VARCHAR(250), IN priceFrom FLOAT , IN priceTo FLOAT)
BEGIN
    SELECT r.id ,r.name ,r.image ,r.breif ,r.price , r.color, r.active FROM roles r 
    WHERE 
    (CASE WHEN active IS NULL THEN '1' ELSE r.active = active END)
    AND CASE WHEN Iname = '' THEN 1 = 1 ELSE  r.name LIKE CONCAT('%' , Iname , '%') END
    AND CASE WHEN priceFrom = 0 THEN 1 = 1 ELSE  r.price >= priceFrom END
    AND CASE WHEN priceTo = 0 THEN 1 = 1 ELSE  r.price <= priceTo END;
END//
DELIMITER ;


# EventsList

DELIMITER ;
DROP PROCEDURE IF EXISTS EventsList;
DELIMITER //

CREATE PROCEDURE EventsList(
    IN Ifeatured BOOLEAN ,
    IN Ititle VARCHAR(100) ,
    IN Istatus VARCHAR(100) ,
    IN Icategory INT,
    IN dateFrom VARCHAR(100),
    IN dateTo VARCHAR(100),
    IN priceFrom FLOAT,
    IN priceTo FLOAT
 )
BEGIN
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
END //

DELIMITER ;
# EventRead

DELIMITER ;
DROP PROCEDURE IF EXISTS EventRead;
DELIMITER //

CREATE PROCEDURE EventRead(IN Iid INT)
BEGIN
	SELECT e.id ,e.title,e.img ,IFNULL(e.breif,"") breif ,day(e.date) d,month(e.date) m,year(e.date) y,e.date, e.price ,e.featured ,e.created_at , c.Id cat_id, c.name cat_name , e.video FROM events e JOIN categories c on e.category_id = c.id WHERE  e.id = Iid;
END //

DELIMITER ;


# EventsList



# projects


DELIMITER ;


DROP PROCEDURE IF EXISTS ProjectsListByUserOrFeatured;  
DROP PROCEDURE IF EXISTS ProjectsListFeatured;
DELIMITER //
CREATE PROCEDURE ProjectsListFeatured() 
BEGIN
    SELECT 
        p.id,
        p.title,
        p.logo,
        p.img
        FROM projects p 
           
            WHERE  featured = 1 ORDER BY RAND() LIMIT 4;
    END//

DELIMITER ;


DROP PROCEDURE IF EXISTS ProjectUpdate;


DELIMITER //
CREATE PROCEDURE ProjectUpdate(
    IN Iid INT,
    IN Icategory_id INT,
    IN Icity_id INT,
    IN Ititle VARCHAR(250),
    IN Istatus VARCHAR(100),
    IN Iimg VARCHAR(250),
    IN Iimgs VARCHAR(250),
    IN Ilogo VARCHAR(250),
    IN Ifund FLOAT,
    IN Ibreif TEXT,
    IN Ilocation TEXT,
    IN Iphone VARCHAR(250),
    IN Ifile VARCHAR(250),
    IN Iemail VARCHAR(250),
    IN Iwebsite VARCHAR(250),
    IN Iinstagram VARCHAR(250),
    IN Itwitter VARCHAR(250),
    IN Ifeatured VARCHAR(250),
    IN Iactive VARCHAR(250)
) BEGIN
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

END //
DELIMITER ;







DROP PROCEDURE IF EXISTS UserRead;

DELIMITER //
CREATE  PROCEDURE `UserRead`(IN emailOrPhone VARCHAR(250))
BEGIN
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
END//
DELIMITER ;

#videos
DROP PROCEDURE IF EXISTS VideosListByCategory;

DELIMITER //
CREATE  PROCEDURE `VideosListByCategory`(IN ICategory INT , IN Iname VARCHAR(200))
BEGIN
    SELECT v.id , v.name ,c.name category_name , v.url , v.image , v.breif , v.category_id 
    FROM videos v 
    JOIN categories c ON v.category_id = c.id
    WHERE deleted_at IS NULL 
    AND (CASE WHEN ICategory = 0 THEN '1' ELSE category_id = ICategory END)
    AND (CASE WHEN Iname = '' THEN '1' ELSE v.name LIKE CONCAT('%' , Iname , '%') END);
END//
DELIMITER ;




DROP PROCEDURE IF EXISTS VideosRead;

DELIMITER //
CREATE  PROCEDURE `VideosRead`(IN Iid INT)
BEGIN
    SELECT v.id , v.name ,v.url ,v.image ,v.breif , v.category_id ,c.name category_name  FROM videos v JOIN categories c ON v.category_id = c.id WHERE v.deleted_at IS NULL AND v.id= Iid;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS VideosCreate;

DELIMITER //
CREATE  PROCEDURE `VideosCreate`(IN Iname VARCHAR(250),IN Iurl VARCHAR(250),IN Iimage VARCHAR(250),IN Ibreif TEXT,IN Icategory_id INT)
BEGIN
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
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS VideosUpdate;

DELIMITER //
CREATE  PROCEDURE `VideosUpdate`(IN Iid INT,IN Iname VARCHAR(250),IN Iurl VARCHAR(250),IN Iimage VARCHAR(250),IN Ibreif TEXT,IN Icategory_id INT)
BEGIN
    UPDATE  videos SET
        name = Iname ,
        url = Iurl ,
        image = Iimage ,
        breif = Ibreif ,
        category_id = Icategory_id
    WHERE id = Iid;

    SELECT Iid id;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS VideosDelete;

DELIMITER //
CREATE  PROCEDURE `VideosDelete`(IN Iid INT)
BEGIN
    UPDATE  videos SET deleted_at = now()  WHERE id = Iid;
    SELECT Iid id;
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS ProjectsListByCategoryUserSearch;
DELIMITER //
CREATE PROCEDURE ProjectsListByCategoryUserSearch(
    IN ICategory INT ,
    IN ICity INT ,
    IN Iuser INT ,
    IN search VARCHAR(200),
    IN userName VARCHAR(200),
    IN Istatus VARCHAR(200)
) 
BEGIN

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
END//

DELIMITER ;



DROP PROCEDURE IF EXISTS EventsListByCategorySearch;
DELIMITER //
CREATE PROCEDURE EventsListByCategorySearch(IN ICategory INT  , IN search VARCHAR(200)) 
BEGIN
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
    END//

DELIMITER ;


DROP PROCEDURE IF EXISTS ProjectDelete;

DELIMITER //
CREATE  PROCEDURE `ProjectDelete`(IN Iid INT)
BEGIN
    UPDATE  projects SET deleted_at = now()  WHERE id = Iid;
    SELECT Iid id;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ProjectRead;
DELIMITER //
CREATE  PROCEDURE `ProjectRead`(IN Iid INT)
BEGIN
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
END//
DELIMITER ;




DROP PROCEDURE IF EXISTS ArticleListByCategoryUserSearch;
DELIMITER //
CREATE PROCEDURE ArticleListByCategoryUserSearch(
    IN ICategory INT ,
    IN IUserName VARCHAR(200),
    IN dateFrom VARCHAR(200),
    IN dateTo VARCHAR(200),
    IN search VARCHAR(200)
    ) 
BEGIN
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
    END//

DELIMITER ;

DROP PROCEDURE IF EXISTS ArticleRead;
DELIMITER //
CREATE  PROCEDURE `ArticleRead`(IN Iid INT)
BEGIN


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
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS Register;

DELIMITER //
CREATE  PROCEDURE `Register`(
    IN IName VARCHAR(250),
    IN IName_ar VARCHAR(250),
    IN IEmail VARCHAR(250),
    IN IPassword VARCHAR(250),
    IN IPhone VARCHAR(250),
    IN IRole INT,
    IN IAdmin BOOLEAN
)
BEGIN

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
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS UserUpgrade;
DELIMITER // 
CREATE PROCEDURE UserUpgrade(
    IN Iuser int,
    IN Irole int
) BEGIN 
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
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS UsersPendingUpgrades;
DELIMITER // 
CREATE PROCEDURE UsersPendingUpgrades(
    Istatus VARCHAR(100),
    Iname_ar VARCHAR(200),
    Iemail VARCHAR(200),
    Iphone VARCHAR(200),
    Irole VARCHAR(200),
    InewRole VARCHAR(200),
    dateFrom VARCHAR(200),
    dateTo VARCHAR(200)
    
    ) BEGIN
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
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS ContactRequestsList;
DELIMITER // 
CREATE PROCEDURE ContactRequestsList(
    Istatus VARCHAR(100),
    Iname_ar VARCHAR(200),
    Iemail VARCHAR(200),
    Iphone VARCHAR(200),
    dateFrom VARCHAR(200),
    dateTo VARCHAR(200)) BEGIN
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
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS UserFindUpgradeRequest;
DELIMITER // 
CREATE PROCEDURE UserFindUpgradeRequest(IN Iid INT ) BEGIN
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
   
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS UserReset;
DELIMITER // 
CREATE PROCEDURE UserReset(
    IN Iemail varchar(250),
    IN Ipassword varchar(250)
) BEGIN
UPDATE
    users
SET
    password = IPassword 
WHERE
    email = Iemail;
    SELECT 1 reseted;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS UserUpdate;
DELIMITER // 
CREATE PROCEDURE UserUpdate(
    IN id int,
    IN Iname varchar(250),
    IN Iname_ar varchar(250),
    IN Iemail varchar(250),
    IN Ipassword varchar(250),
    IN Iserial varchar(250),
    IN Irole_id INT,
    IN Icity_id INT,
    IN Iimg TEXT,
    IN Iphone VARCHAR(250),
    IN Ibreif TEXT(250)
) BEGIN



DECLARE currentRole INT;
DECLARE points FLOAT;

SET currentRole = (SELECT role_id  FROM users u WHERE u.id = id);

SET points =(SELECT price FROM roles r WHERE r.id = Irole_id) - (SELECT price FROM roles r WHERE r.id = currentRole);

/* 
IF currentRole != Irole_id THEN 
END IF; */
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


END //

DELIMITER ;


DROP PROCEDURE IF EXISTS CategoryListByType;


DELIMITER //
CREATE  PROCEDURE `CategoryListByType`(IN Itype VARCHAR(50))
BEGIN
    SELECT 
       id,name,icon,type
     FROM categories
     
     WHERE type = CASE WHEN Itype = "" THEN type ELSE Itype END ;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS CategoryFind;

DELIMITER //
CREATE  PROCEDURE `CategoryFind`(IN Iid INT)
BEGIN
    SELECT 
       id,name,icon,type
     FROM categories
     
     WHERE id = Iid;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS CategoryCreate;


DELIMITER //
CREATE  PROCEDURE `CategoryCreate`(IN Iname VARCHAR(300) , IN Iicon VARCHAR(300) , IN Itype VARCHAR(10))
BEGIN
    INSERT INTO categories (name , icon , type) VALUES (Iname , Iicon , Itype);
    SELECT LAST_INSERT_ID() id;
END//
DELIMITER ;




DROP PROCEDURE IF EXISTS CategoryUpdate;


DELIMITER //
CREATE  PROCEDURE `CategoryUpdate`(IN Iid INT , IN Iname VARCHAR(300) , IN Iicon VARCHAR(300) , IN Itype VARCHAR(10))
BEGIN
    UPDATE categories SET 
    name = Iname ,
    icon = Iicon ,
    type = Itype WHERE id = Iid ;

    SELECT Iid;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS ConsultuntsListAll;


DELIMITER //
CREATE  PROCEDURE `ConsultuntsListAll`(
    IN Iis_team BOOLEAN ,
    IN Iname VARCHAR(200) ,
    IN Ititle VARCHAR(200) ,
    IN Iskills VARCHAR(200) 
)
BEGIN
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
END//




DELIMITER ;



DROP PROCEDURE IF EXISTS ConsultuntById ;
DELIMITER //

CREATE  PROCEDURE `ConsultuntById`(IN Iid INT)
BEGIN
    SELECT 
       id,
        name,
        title,
        skills,
        img,
        is_team,
        breif
     FROM consultunts WHERE id = Iid;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS ConsultuntsCreate;


DELIMITER //
CREATE  PROCEDURE `ConsultuntsCreate`(
    IN Iname VARCHAR(250),
    IN Ititle VARCHAR(250),
    IN Iskills VARCHAR(250),
    IN Iimg TEXT,
    IN Iis_team BOOLEAN,
    IN Ibreif TEXT
)
BEGIN
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
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ConsultuntsUpdate;


DELIMITER //
CREATE  PROCEDURE `ConsultuntsUpdate`(
    IN Iid INT,
    IN Iname VARCHAR(250),
    IN Ititle VARCHAR(250),
    IN Iskills VARCHAR(250),
    IN Iimg TEXT,
    IN Iis_team BOOLEAN,
    IN Ibreif TEXT
)
BEGIN
    UPDATE consultunts SET 
        name = Iname ,
        title = Ititle ,
        skills = Iskills ,
        img = Iimg ,
        is_team = Iis_team ,
        breif = Ibreif 
    WHERE id = Iid;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ProjectsCreate;

DELIMITER //
CREATE  PROCEDURE `ProjectsCreate`(
    IN Iuser_id INT,
    IN Icategory_id INT,
    IN Icity_id INT,
    IN Ititle VARCHAR(250),
    IN Istatus VARCHAR(100),
    IN Iimg VARCHAR(250),
    IN Iimgs VARCHAR(250),
    IN Ilogo VARCHAR(250),
    IN Ifund FLOAT,
    IN Ibreif TEXT,
    IN Ilocation TEXT,
    IN Iphone VARCHAR(250),
    IN Ifile VARCHAR(250),
    IN Iemail VARCHAR(250),
    IN Iwebsite VARCHAR(250),
    IN Iinstagram VARCHAR(250),
    IN Itwitter VARCHAR(250),
    IN Ifeatured VARCHAR(250),
    IN Iactive VARCHAR(250)
)
BEGIN
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

END//
DELIMITER ;



DROP PROCEDURE IF EXISTS CityListAll;

DELIMITER //
CREATE  PROCEDURE `CityListAll`()
BEGIN
    SELECT id,name from cities;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS CityFind;

DELIMITER //
CREATE  PROCEDURE `CityFind`(IN Iid int)
BEGIN
    SELECT id,name from cities WHERE id = Iid;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS CityCreate;

DELIMITER //
CREATE  PROCEDURE `CityCreate`(IN Iname TEXT)
BEGIN
    INSERT INTO cities (name) VALUES (Iname);

    SELECT LAST_INSERT_ID() id;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS CityUpdate;

DELIMITER //
CREATE  PROCEDURE `CityUpdate`(IN Iid INT, IN Iname TEXT)
BEGIN
  UPDATE cities SET name = Iname WHERE id = Iid;
  SELECT Iid id;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS FeaturesListAll;

DELIMITER //
CREATE  PROCEDURE `FeaturesListAll`()
BEGIN
    SELECT * from features;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS FeaturesListByRole;

DELIMITER //
CREATE  PROCEDURE `FeaturesListByRole`(IN role INT , IN Iname VARCHAR(250))
BEGIN
    SELECT * from features WHERE 
        (CASE WHEN role IS NULL THEN '1' ELSE level <= (role -1) END)
        AND CASE WHEN Iname = '' THEN 1 = 1 ELSE  name LIKE CONCAT('%' , Iname , '%') END;

END//
DELIMITER ;


DROP PROCEDURE IF EXISTS FeaturesFindById;

DELIMITER //
CREATE  PROCEDURE `FeaturesFindById`(IN Iid INT)
BEGIN
    
    SELECT * from features WHERE id = Iid;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS FeaturesEditAdd;

DELIMITER //
CREATE  PROCEDURE `FeaturesEditAdd`(IN Iid INT , IN Iname VARCHAR(200),IN Ibreif TEXT , IN Ilevel INT)
BEGIN
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
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS DeleteRecord;

DELIMITER //
CREATE  PROCEDURE `DeleteRecord`(IN Itable VARCHAR(30) , IN Iid INT)
BEGIN
    SET @query = CONCAT('UPDATE ' , Itable , ' SET deleted_at = "', NOW() , '" WHERE id = ' , Iid); 
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SELECT 1 deleted;
END//
DELIMITER ;





DROP PROCEDURE IF EXISTS ServicesListAll;

DELIMITER //
CREATE  PROCEDURE `ServicesListAll`(IN Iname VARCHAR(250))
BEGIN
    SELECT id,name,icon 
    FROM services 
    WHERE CASE WHEN Iname = '' THEN 1 = 1 ELSE
      name LIKE CONCAT('%' , Iname , '%') 
    END;
    
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ServicesFindById;

DELIMITER //
CREATE  PROCEDURE `ServicesFindById`(IN Iid INT)
BEGIN
    SELECT id,name,icon from services WHERE id = Iid ;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS ServiceCreate;

DELIMITER //
CREATE  PROCEDURE `ServiceCreate`(IName VARCHAR(100) , IIcon VARCHAR(100))
BEGIN
    INSERT INTO services ( name,icon) VALUES(IName , IIcon);
    SELECT LAST_INSERT_ID(); 
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS ServiceUpdate;

DELIMITER //
CREATE  PROCEDURE `ServiceUpdate`(IId INT , IName VARCHAR(100) , IIcon VARCHAR(100))
BEGIN
    UPDATE  services SET name = IName ,icon = IIcon WHERE id = IId;
    SELECT 1 updated;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ServiceDelete;

DELIMITER //
CREATE  PROCEDURE `ServiceDelete`(IId INT )
BEGIN
    DELETE FROM services WHERE id = IId;
    SELECT 1 deleted;
END//
DELIMITER ;


/* 



DROP PROCEDURE IF EXISTS Merge;

DELIMITER //

CREATE PROCEDURE Merge()
BEGIN
DECLARE x INT;
DECLARE max INT;
DECLARE Iserial INT;
DECLARE Iname VARCHAR(250);
DECLARE Iname_ar VARCHAR(250);
DECLARE Iemail VARCHAR(250);
DECLARE Iimg VARCHAR(250);
DECLARE Irole_id INT;
DECLARE Icity_id INT;
DECLARE Iphone VARCHAR(250);
DECLARE Ipassword VARCHAR(250);

SET x = 1;
SET max = (SELECT COUNT(*) FROM alshab.users);

loop_label:  LOOP
		IF  x > max THEN 
			LEAVE  loop_label;
		END  IF;
            
        SET Iserial = (SELECT alshab.users.serial FROM  alshab.users WHERE id = x);
        SET Iname = (SELECT alshab.users.name FROM  alshab.users WHERE id = x);
        SET Iname_ar = (SELECT alshab.users.name_ar FROM  alshab.users WHERE id = x);
        SET Iemail = (SELECT alshab.users.email FROM  alshab.users WHERE id = x);
        SET Iimg = (SELECT alshab.users.img FROM  alshab.users WHERE id = x);
        SET Irole_id = (SELECT alshab.users.role_id FROM  alshab.users WHERE id = x);
        SET Icity_id = (SELECT alshab.users.city_id FROM  alshab.users WHERE id = x);
        SET Iphone = (SELECT alshab.users.phone FROM  alshab.users WHERE id = x);
        SET Ipassword = (SELECT alshab.users.password FROM  alshab.users WHERE id = x);
        IF NOT EXISTS(SELECT * FROM users WHERE phone = Iphone) AND NOT EXISTS(SELECT * FROM users WHERE email = Iemail)
            THEN
            
            INSERT INTO alshab_st.users (
                serial,
                name,
                name_ar,
                email,
                role_id,
                city_id,
                img,
                phone,
                active,
                password
            ) VALUES (
                Iserial,
                Iname,
                Iname_ar,
                Iemail,
                Irole_id,
                Icity_id,
                Iimg,
                Iphone,
                1,
                Ipassword
            );
            
            END IF;
		SET  x = x + 1;
       
	END LOOP;

END//
DELIMITER ;


      

 */


DROP PROCEDURE IF EXISTS NotificationCreate;

DELIMITER //

CREATE PROCEDURE NotificationCreate(IN Ititle VARCHAR(250) , IN Ibreif TEXT , IN Iurl VARCHAR(250) )
BEGIN
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

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS NotificationsByUserId;

DELIMITER //
CREATE  PROCEDURE `NotificationsByUserId`(IId INT )
BEGIN
    SELECT Title , Breif , Link FROM notifications n
    JOIN user_notifications un 
    ON n.id = un.notification_id 
    WHERE un.user_id = IId;
END//
DELIMITER ;




# requests
DROP PROCEDURE IF EXISTS UsersRequests;
DELIMITER //
CREATE  PROCEDURE `UsersRequests`(
    Istatus VARCHAR(100),
    Iname_ar VARCHAR(200),
    Iemail VARCHAR(100),
    Irole INT,
    Iphone VARCHAR(100),
    dateFrom VARCHAR(100),
    dateTo VARCHAR(100)
)
BEGIN
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
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS SerivcesPendingFind;
DELIMITER //
CREATE  PROCEDURE `SerivcesPendingFind`(IN id INT)
BEGIN
       SELECT u.id , u.name_ar , u.email , u.phone , us.breif ,u.created_at FROM users u JOIN user_services us ON u.id = us.user_id  WHERE us.id = id;
END//
DELIMITER ;





DROP PROCEDURE IF EXISTS ProjectPending;
DELIMITER //
CREATE  PROCEDURE `ProjectPending`(
    Istatus VARCHAR(100),
    Iname_ar VARCHAR(200),
    Ititle VARCHAR(200),
    Iphone VARCHAR(200),
    Iemail VARCHAR(200),
    dateFrom VARCHAR(200),
    dateTo VARCHAR(200)
    )
BEGIN
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
END//
DELIMITER ;




DROP PROCEDURE IF EXISTS ArticlePending;
DELIMITER //
CREATE  PROCEDURE `ArticlePending`(
    Istatus VARCHAR(100),
    Iname_ar VARCHAR(200),
    Ititle VARCHAR(200),
    Iphone VARCHAR(200),
    Iemail VARCHAR(200),
    dateFrom VARCHAR(200),
    dateTo VARCHAR(200))
BEGIN
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
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ServiceRequestsPending;
DELIMITER //
CREATE  PROCEDURE `ServiceRequestsPending`(Iname_ar VARCHAR(200),Istatus VARCHAR(200), service_id INT  ,role_id INT ,Iemail VARCHAR(100),Ibreif VARCHAR(100))
BEGIN

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
    
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS ProjectPendingAction;
DELIMITER //
CREATE  PROCEDURE `ProjectPendingAction`(Iid int , action VARCHAR(100))
BEGIN
    UPDATE projects SET 
        active = CASE WHEN action = "approved" THEN 1 ELSE 0 END,
        status = action
        WHERE id = Iid;
    SELECT Iid;
END//
DELIMITER ;





DROP PROCEDURE IF EXISTS ArticlePendingAction;
DELIMITER //
CREATE  PROCEDURE `ArticlePendingAction`(Iid INT , Istatus VARCHAR(100))
BEGIN
    UPDATE articles SET 
        status = CASE WHEN Istatus = "approved" THEN 'active' ELSE Istatus END ,
        published_at = CASE WHEN Istatus = "approved" THEN NOW() ELSE NULL END 
    WHERE id = Iid;
    SELECT Iid;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS UserPendingAction;
DELIMITER //
CREATE  PROCEDURE `UserPendingAction`(Iid int , Istatus VARCHAR(100))
BEGIN
    UPDATE users u JOIN user_subs us ON u.id = us.user_id SET 
    status = Istatus ,
    u.role_id = CASE WHEN Istatus = "approved" THEN us.role_id ELSE u.role_id END  ,
    active = CASE WHEN Istatus = "approved" THEN 1 ELSE 0 END,
    approved_at = CASE WHEN Istatus = "approved" THEN NOW() ELSE NULL END  
    WHERE u.id = Iid;
     
    SELECT Iid;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS ServiceRequestPendingAction;
DELIMITER //
CREATE  PROCEDURE `ServiceRequestPendingAction`(Iid int , Istatus VARCHAR(100))
BEGIN
    UPDATE user_services SET seen_at = now() , status = Istatus WHERE id = Iid;
    SELECT LAST_INSERT_ID() id;

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS MsgsCreate;
DELIMITER //
CREATE  PROCEDURE `MsgsCreate`(Ifrom_id INT , Ito_id INT , Ibreif TEXT)
BEGIN
   INSERT INTO msgs (from_id , to_id , breif) VALUES (Ifrom_id , Ito_id , Ibreif);
   SELECT LAST_INSERT_ID() id;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS MsgsList;
DELIMITER //
CREATE  PROCEDURE `MsgsList`(IN Iuser_id INT)
BEGIN
    SELECT fr.id from_id , t.id to_id  INTO @toId , @fromId FROM msgs m JOIN users fr ON m.from_id = fr.id JOIN users t ON m.to_id = t.id WHERE to_id = Iuser_id OR from_id = Iuser_id GROUP BY fr.name , fr.id , t.name , t.id; 
    IF @toId = Iuser_id THEN
        SELECT id , name_ar , img FROM users WHERE id = @fromId ;
    ELSE
        SELECT id , name_ar , img FROM users WHERE id = @toId ;
    END IF;

    SELECT id , name_ar , img FROM users WHERE id != Iuser_id;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS MsgsListByUser;
DELIMITER //
CREATE  PROCEDURE `MsgsListByUser`(id1 INT ,id2 INT  )
BEGIN
    SELECT m.id ,IF(m.from_id = id1 , TRUE , FALSE) mine, u.name_ar name ,m.breif , m.created_at , IFNULL(m.seen , '') seen 
    FROM msgs m 
      JOIN users u ON m.from_id = u.id
    WHERE (m.from_id = id1 AND m.to_id = id2) OR (m.from_id = id2 AND m.to_id = id1) 
  
    ORDER BY m.created_at DESC, id DESC;
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS FindDashboardCounts;
DELIMITER //
CREATE  PROCEDURE `FindDashboardCounts`()
BEGIN
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
END//
DELIMITER ;



DROP PROCEDURE IF EXISTS RichTextUpdate;

DELIMITER //
CREATE  PROCEDURE `RichTextUpdate`(Iid INT ,Ititle TEXT, Ivalue TEXT , IIcon VARCHAR(100) , Iimage VARCHAR(100))
BEGIN
    
    UPDATE  rich_text SET value = Ivalue , title = Ititle ,icon = IIcon,
    image = CASE WHEN Iimage = "" THEN image ELSE Iimage END 
     WHERE id = Iid ;
    SELECT 1 updated;
END//
DELIMITER ;




/* // 26 may updated */

DROP PROCEDURE IF EXISTS RoleFind;

DELIMITER //
CREATE  PROCEDURE `RoleFind`(IId INT )
BEGIN
    SELECT id ,name ,image ,breif ,price , color , active FROM roles WHERE id = IId;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS RoleEdit;


DELIMITER //
CREATE  PROCEDURE `RoleEdit`(
    IN Iid INT ,
    IN Iname VARCHAR(250),
    IN Iimage TEXT ,
    IN Ibreif TEXT ,
    IN Iprice FLOAT ,
    IN Icolor VARCHAR(10),
    IN Iactive BOOLEAN 
)
BEGIN
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
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS EventEdit;
DELIMITER //

CREATE PROCEDURE EventEdit(
    IN Iid INT,
    IN Ititle  VARCHAR(250),
    IN Iimg  VARCHAR(250),
    IN Ivideo  TEXT,
    IN Ibreif  TEXT,
    IN Idate  VARCHAR(250),
    IN Iprice  FLOAT,
    IN Ifeatured  BOOLEAN,
    IN Icategory_id INT
)
BEGIN
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

END //

DELIMITER ;



DROP PROCEDURE IF EXISTS EventCreate;
DELIMITER //

CREATE PROCEDURE EventCreate(
    IN Ititle  VARCHAR(250),
    IN Iimg  VARCHAR(250),
    IN Ivideo  TEXT,
    IN Ibreif  TEXT,
    IN Idate  date,
    IN Iprice  FLOAT,
    IN Ifeatured  BOOLEAN,
    IN Icategory_id INT
)
BEGIN
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
END //

DELIMITER ;



