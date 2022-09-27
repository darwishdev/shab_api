USE  alshab_staging2;
DROP PROCEDURE IF EXISTS MergeRoles;

DELIMITER //

CREATE PROCEDURE MergeRoles()
BEGIN
    INSERT INTO alshab_staging2.features(name , breif , level ) SELECT name , breif , level  FROM alshab_staging.features;
    INSERT INTO alshab_staging2.roles(name , image , breif , price , color) SELECT name , image , breif , price , color FROM alshab_staging.roles;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS MergeRich;

DELIMITER //

CREATE PROCEDURE MergeRich()
BEGIN
     INSERT INTO alshab_staging2.rich_text(`key`  , `value` , title , image , `group` , icon) SELECT `key`  , `value` , title , image , `group` , icon FROM alshab_staging.rich_text;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS MergeCities;

DELIMITER //

CREATE PROCEDURE MergeCities()
BEGIN
    INSERT INTO alshab_staging2.cities(name) SELECT name FROM alshab_staging.cities;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS MergeCats;

DELIMITER //

CREATE PROCEDURE MergeCats()
BEGIN
    INSERT INTO alshab_staging2.categories(name , icon , type) SELECT name , icon , type FROM alshab_staging.categories;
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS MergeServices;

DELIMITER //

CREATE PROCEDURE MergeServices()
BEGIN
    INSERT INTO alshab_staging2.services(name , icon) SELECT name , icon FROM alshab_staging.services;
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS MergeConsultunts;

DELIMITER //

CREATE PROCEDURE MergeConsultunts()
BEGIN
    INSERT INTO alshab_staging2.consultunts(name , title , skills , img , is_team , breif) SELECT name , title , skills , img , is_team , breif FROM alshab_staging.consultunts;
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS MergeVideos;

DELIMITER //

CREATE PROCEDURE MergeVideos()
BEGIN
    INSERT INTO alshab_staging2.videos(name , url , image , Breif , category_id) SELECT v.name , v.url , v.image , v.Breif , (SELECT id FROM alshab_staging2.categories WHERE name = c.name LIMIT 1) FROM alshab_staging.videos v JOIN alshab_staging.categories c ON v.category_id = c.id;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS MergeEvents;

DELIMITER //

CREATE PROCEDURE MergeEvents()
BEGIN
    INSERT INTO alshab_staging2.events(title , img , video , breif , `date` , price , featured , category_id) SELECT title , img , video , breif , `date` , price , featured , (SELECT id FROM alshab_staging2.categories WHERE name = c.name LIMIT 1) FROM alshab_staging.events e JOIN alshab_staging.categories c ON e.category_id = c.id;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS MergeUsers;

DELIMITER //

CREATE PROCEDURE MergeUsers()
BEGIN
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

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS MergeArticles;

DELIMITER //


CREATE PROCEDURE MergeArticles()
BEGIN
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
END //
DELIMITER ;





DROP PROCEDURE IF EXISTS MergeProjects;

DELIMITER //


CREATE PROCEDURE MergeProjects()
BEGIN
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
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS MergeNotifications;

DELIMITER //


CREATE PROCEDURE MergeNotifications()
BEGIN
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
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS MergeMsgs;

DELIMITER //


CREATE PROCEDURE MergeMsgs()
BEGIN
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
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS Merge;

DELIMITER //

CREATE PROCEDURE Merge()
BEGIN
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
 

END //
DELIMITER ;
