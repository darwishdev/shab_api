
DROP DATABASE IF EXISTS alshab_staging2;

CREATE DATABASE alshab_staging2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE alshab_staging2;

DROP TABLE IF EXISTS cities;

CREATE TABLE cities(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250)
) ENGINE = INNODB;

DROP TABLE IF EXISTS consultunts;

CREATE TABLE consultunts(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `title` VARCHAR(250),
    `skills` text,
    `img` VARCHAR(250) DEFAULT "assets/members/default.png",
    `is_team` BOOLEAN DEFAULT FALSE, 
    `breif` TEXT,
    `deleted_at` datetime
) ENGINE = INNODB;



DROP TABLE IF EXISTS categories;

CREATE TABLE categories(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `icon` VARCHAR(250),
    `type` ENUM('post', 'project' , 'event' , 'video')
) ENGINE = INNODB;

DROP TABLE IF EXISTS roles;

CREATE TABLE roles(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `image` VARCHAR(250),
    `breif` VARCHAR(250),
    `price` FLOAT,
    `color` VARCHAR(250),
    `active` BOOLEAN DEFAULT TRUE
) ENGINE = INNODB;

DROP TABLE IF EXISTS users;

CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250) NOT NULL,
    `name_ar` VARCHAR(250) NOT NULL,
    `email` VARCHAR(250) UNIQUE,
    `img` VARCHAR(300) DEFAULT "assets/members/default.png",
    `password` VARCHAR(250),
    `serial` int,
    `points` int(5) UNSIGNED DEFAULT 0,
    role_id INT,
    CONSTRAINT fk_user_role FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    city_id INT,
    CONSTRAINT fk_user_city FOREIGN KEY(city_id) REFERENCES cities(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `phone` VARCHAR(250) UNIQUE NOT NULL,
    `breif` TEXT(250),
    `featured` BOOLEAN DEFAULT FALSE,
    `active` BOOLEAN DEFAULT FALSE,
    `admin` BOOLEAN DEFAULT FALSE,
    `status` VARCHAR(200) DEFAULT 'pending',
    `created_at` datetime DEFAULT now(),
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS services;

CREATE TABLE services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `icon` VARCHAR(250),
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS rich_text;

CREATE TABLE rich_text(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(250),
    `page` VARCHAR(250),
    `value` TEXT,
    `title` TEXT NULL,
    `image` VARCHAR(250) NULL,
    `group` smallint(1) DEFAULT 0,
    `icon` VARCHAR(250) NULL
) ENGINE = INNODB;

DROP TABLE IF EXISTS videos;

CREATE TABLE videos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `url` VARCHAR(300),
    `image` VARCHAR(250),
    `Breif` TEXT,
    category_id INT,
    CONSTRAINT fk_video_category FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS features;

CREATE TABLE features(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(250),
    `breif` TEXT,
    `level` tinyint
) ENGINE = INNODB;

DROP TABLE IF EXISTS msgs;

CREATE TABLE msgs(
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_id INT,
    CONSTRAINT fk_msg_from FOREIGN KEY(from_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    to_id INT,
    CONSTRAINT fk_msg_to FOREIGN KEY(to_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `created_at` datetime DEFAULT now(),
    `breif` TEXT,
    seen datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS articles;

CREATE TABLE articles(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    CONSTRAINT fk_article_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    category_id INT,
    CONSTRAINT fk_article_cat FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `title` VARCHAR(250),
    `img` VARCHAR(250),
    `status` ENUM('pending', 'active', 'declined') DEFAULT 'pending',
    `content` TEXT,
    `views` int DEFAULT 0 NOT NULL,
    `views_count_rate` int DEFAULT 3 NOT NULL,
    `created_at` datetime DEFAULT now(),
    `published_at` datetime DEFAULT NULL,
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS events;

CREATE TABLE events(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(250),
    `img` VARCHAR(250),
    `video` TEXT NULL,
    `breif` TEXT NULL,
    `date` date,
    `price` FLOAT UNSIGNED,
    `featured` BOOLEAN DEFAULT FALSE,
    category_id INT,
    CONSTRAINT fk_project_event FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `created_at` datetime DEFAULT now(),
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS projects;

CREATE TABLE projects(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    CONSTRAINT fk_project_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    category_id INT,
    CONSTRAINT fk_project_category FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE,
    city_id INT,
    CONSTRAINT fk_project_city FOREIGN KEY(city_id) REFERENCES cities(id) ON DELETE CASCADE ON UPDATE CASCADE,
    `title` VARCHAR(250),
    `logo` VARCHAR(250),
    `img` VARCHAR(250),
    `fund` FLOAT,
    `status` VARCHAR(100),
    `breif` TEXT,
    `imgs` TEXT NULL,
    `location` TEXT,
    `phone` VARCHAR(250),
    `file` VARCHAR(250) NULL,
    `email` VARCHAR(250),
    `featured` BOOLEAN DEFAULT 0,
    `website` VARCHAR(250),
    `instagram` VARCHAR(250),
    `twitter` VARCHAR(250),
    `active` BOOLEAN DEFAULT FALSE,
    `created_at` datetime DEFAULT now(),
    `deleted_at` datetime
) ENGINE = INNODB;

DROP TABLE IF EXISTS user_subs;

CREATE TABLE user_subs(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    CONSTRAINT fk_user_subs_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INT,
    CONSTRAINT fk_user_subs_role FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    price FLOAT UNSIGNED,
    method ENUM('card', 'cash'),
    points int UNSIGNED default 0,
    created_at datetime DEFAULT NOW(),
    start_at datetime,
    end_at datetime,
    approved_at datetime
) ENGINE = INNODB;


DROP TABLE IF EXISTS contact_requests;

CREATE TABLE contact_requests(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    CONSTRAINT fk_contact_requests_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    name VARCHAR(200),
    email VARCHAR(200),
    phone VARCHAR(200),
    status VARCHAR(200) DEFAULT 'PENDING',
    subject VARCHAR(200),
    msg VARCHAR(200),
    created_at datetime DEFAULT NOW()
) ENGINE = INNODB;


DROP TABLE IF EXISTS user_events;

CREATE TABLE user_events(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    CONSTRAINT fk_user_events_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    event_id INT,
    CONSTRAINT fk_user_events_event FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE,
    price FLOAT UNSIGNED,
    method ENUM('card', 'cash'),
    points int UNSIGNED default 0
) ENGINE = INNODB;




DROP TABLE IF EXISTS notifications;

CREATE TABLE notifications(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(250),
    `breif` TEXT,
    `link` VARCHAR(250),
    created_at datetime DEFAULT now()
) ENGINE = INNODB;

DROP TABLE IF EXISTS user_notifications;

CREATE TABLE user_notifications(
    user_id INT,
    CONSTRAINT fk_user_notifications_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    notification_id INT,
    CONSTRAINT fk_user_notifications_notification FOREIGN KEY(notification_id) REFERENCES notifications(id) ON DELETE CASCADE ON UPDATE CASCADE,
    seen_at datetime
) ENGINE = INNODB;


DROP TABLE IF EXISTS user_services;

CREATE TABLE user_services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    CONSTRAINT user_services_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    breif TEXT,
    service_id INT,
    CONSTRAINT user_services_service FOREIGN KEY(service_id) REFERENCES services(id) ON DELETE CASCADE ON UPDATE CASCADE,
    status VARCHAR(100),
    seen_at datetime,
    `created_at` datetime DEFAULT now()

) ENGINE = INNODB;

