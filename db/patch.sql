
INSERT INTO user_subs(
    user_id,
    role_id,
    price,
    method,
    points,
    created_at,
    start_at,
    end_at,
    approved_at)
SELECT 
    u.id , r.id, r.price , 'cash' , r.price , '2022-01-01 00:00:00' , '2022-01-01 00:00:00' , '2022-12-31 00:00:00' , '2022-01-01 00:00:00'
FROM users u 
    JOIN roles r ON u.role_id = r.id 
    LEFT JOIN user_subs s ON u.id = s.user_id
WHERE s.id IS NULL;



DROP PROCEDURE IF EXISTS UserListByRoleOrFeatured;

DELIMITER //


CREATE PROCEDURE UserListByRoleOrFeatured(
    IN role INT ,
    IN featured BOOLEAN ,
    IN admin BOOLEAN ,
    IN Iname VARCHAR(100),
    IN Iphone VARCHAR(100),
    IN Iemail VARCHAR(100),
    IN Iserial VARCHAR(100),
    IN Deleted BOOLEAN
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
        r.color,
        s.start_at,
        s.end_at,
        s.end_at < CURRENT_DATE() AS expired 
        
        FROM users u
            JOIN roles r ON u.role_id = r.id
            JOIN user_subs s ON u.id = s.user_id
            WHERE u.active = 1 
            AND u.admin = admin
            AND  (CASE WHEN role = 0 THEN '1' ELSE u.role_id = role END)
            AND  (CASE WHEN featured = 0 THEN '1' ELSE u.featured = featured END)
            AND  (CASE WHEN Iname = '' THEN '1' ELSE u.name_ar LIKE CONCAT('%' ,  Iname , '%') END)
            AND  (CASE WHEN Iphone = '' THEN '1' ELSE u.phone LIKE CONCAT('%' ,  Iphone , '%') END)
            AND  (CASE WHEN Iemail = '' THEN '1' ELSE u.email LIKE CONCAT('%' ,  Iemail , '%') END)
            AND  (CASE WHEN Iserial = '' THEN '1' ELSE u.serial LIKE CONCAT('%' ,  Iserial , '%') END)
            AND  (CASE WHEN Deleted THEN u.deleted_at IS NOT NULL ELSE u.deleted_at IS NULL END)
        ORDER BY u.id ;
    END//
DELIMITER ;






DROP PROCEDURE IF EXISTS UserPendingAction;
DELIMITER //
CREATE  PROCEDURE `UserPendingAction`(Iid int , Istatus VARCHAR(100) , Iuser INT)
BEGIN
    UPDATE users u JOIN user_subs us ON u.id = us.user_id SET 
    status = Istatus ,
    u.role_id = CASE WHEN Istatus = "approved" THEN us.role_id ELSE u.role_id END  ,
    active = CASE WHEN Istatus = "approved" THEN 1 ELSE 0 END,
    approved_at = CASE WHEN Istatus = "approved" THEN NOW() ELSE NULL END  
    WHERE u.id = Iuser
    AND us.id = Iid;
     
    SELECT Iuser;
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
        us.id ,
        u.id user_id ,
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
    SELECT us.id , u.id user_id,u.name_ar , u.email , u.phone , cur_role.name  , u.role_id   , new_role.name , us.role_id , us.price , 
   IF(us.approved_at IS NULL , 'Approved' , 'Pending') AS `Status` , us.created_at 
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
        points,
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
        (SELECT price FROM roles WHERE id = IRole),
        IAdmin
   );
END
