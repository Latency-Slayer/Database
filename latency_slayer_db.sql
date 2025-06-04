-- Active: 1748706699783@@127.0.0.1@3306@latency_slayer
DROP DATABASE IF EXISTS latency_slayer;
CREATE DATABASE IF NOT EXISTS latency_slayer;
USE latency_slayer;

CREATE TABLE country
(
    id_country                       INT PRIMARY KEY AUTO_INCREMENT,
    name                             VARCHAR(45) NOT NULL UNIQUE,
    country_code                     CHAR(2)     NOT NULL UNIQUE,
    mask_company_registration_number VARCHAR(45) NOT NULL,
    mask_phone                       VARCHAR(45) NOT NULL
);

CREATE TABLE contact
(
    id_contact INT PRIMARY KEY AUTO_INCREMENT,
    email      VARCHAR(255)                                                    NOT NULL UNIQUE,
    phone      VARCHAR(16)                                                     NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP                             NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE company
(
    id_company          INT PRIMARY KEY AUTO_INCREMENT,
    commercial_name     VARCHAR(45)                                                     NOT NULL,
    legal_name          VARCHAR(100)                                                    NOT NULL,
    registration_number VARCHAR(16)                                                     NOT NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP                             NOT NULL,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_country          INT                                                             NOT NULL,
    fk_contact          INT                                                             NOT NULL UNIQUE,
    CONSTRAINT fk_commpany_contact FOREIGN KEY (fk_contact) REFERENCES contact (id_contact),
    CONSTRAINT fk_company_country FOREIGN KEY (fk_country) REFERENCES country (id_country)
);

CREATE TABLE opt_role
(
    id_opt_role INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(45) NOT NULL UNIQUE,
    description VARCHAR(80)
);

CREATE TABLE employee
(
    id_employee INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(45)                                                     NOT NULL,
    gender      ENUM ('male', 'female', 'other')                                NOT NULL,
    password    TEXT                                                            NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP                             NOT NULL,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_role     INT                                                             NOT NULL,
    fk_contact  INT                                                             NOT NULL UNIQUE,
    fk_company  INT                                                             NOT NULL,
    CONSTRAINT fk_opt_role FOREIGN KEY (fk_role)
        REFERENCES opt_role (id_opt_role),
    CONSTRAINT fk_cont_contact FOREIGN KEY (fk_contact)
        REFERENCES contact (id_contact),
    CONSTRAINT fk_comp_company FOREIGN KEY (fk_company)
        REFERENCES company (id_company)
);

CREATE TABLE server
(
    id_server      INT PRIMARY KEY AUTO_INCREMENT,
    motherboard_id VARCHAR(150)                       NOT NULL UNIQUE,
    tag_name       VARCHAR(45)                        NOT NULL,
    type           ENUM ('cloud', 'on-premise')       NOT NULL,
    instance_id    VARCHAR(45) UNIQUE,
    active         TINYINT(1)                         NOT NULL DEFAULT 1,
    so             ENUM ('windows', 'linux', 'macos') NOT NULL,
    city           VARCHAR(60)                        NOT NULL,
    game           VARCHAR(45)                        NOT NULL,
    port           INT                                NOT NULL,
    fk_company     INT                                NOT NULL,
    fk_country     INT                                NOT NULL,
    CONSTRAINT fk_compa_company FOREIGN KEY (fk_company)
        REFERENCES company (id_company),
    CONSTRAINT fk_count_country FOREIGN KEY (fk_country)
        REFERENCES country (id_country)
);

CREATE TABLE component
(
    id_component INT PRIMARY KEY AUTO_INCREMENT,
    tag_name     VARCHAR(150)                           NOT NULL,
    type         ENUM ('cpu', 'ram', 'storage', 'swap') NOT NULL,
    active       TINYINT(1)                             NOT NULL DEFAULT 1,
    fk_server    INT                                    NOT NULL,
    CONSTRAINT fk_ser_server FOREIGN KEY (fk_server)
        REFERENCES server (id_server)
);


CREATE TABLE metric
(
    id_metric    INT PRIMARY KEY AUTO_INCREMENT,
    metric       ENUM ('GB', 'MB', 'KB', 'Kbps', 'Mbps', '%', 'Mhz', 'Ghz', 'celsius') NOT NULL,
    max_limit    INT                                                                   NOT NULL,
    min_limit    INT,
    total        INT                                                                   NOT NULL,
    fk_component INT                                                                   NOT NULL,
    CONSTRAINT fk_com_component FOREIGN KEY (fk_component)
        REFERENCES component (id_component)
);

CREATE TABLE alert
(
    id_Alert       INT PRIMARY KEY AUTO_INCREMENT,
    status         ENUM ('aberto', 'acompanhamento', 'resolvido') NOT NULL,
    dateAlert      TIMESTAMP DEFAULT CURRENT_TIMESTAMP            NOT NULL,
    mensage        VARCHAR(100)                                   NOT NULL,
    exceeded_limit INT                                            NOT NULL,
    valor          DOUBLE                                         NOT NULL,
    fk_Metric      INT                                            ,
    nivel          VARCHAR(30)                                    NOT NULL,
    idJira INT,
    CONSTRAINT fk_alert_metric FOREIGN KEY (fk_Metric)
        REFERENCES metric (id_metric)
);

CREATE TABLE connection_capturing
(
    id_connection_capturing INT PRIMARY KEY auto_increment,
    ip_player               CHAR(15)      NOT NULL,
    longitude               DECIMAL(9, 6) NOT NULL,
    latitude                DECIMAL(9, 6) NOT NULL,
    country                 VARCHAR(45)   NOT NULL,
    continent_code          CHAR(2)       NOT NULL,
    date_time               datetime      NOT NULL,
    fk_server               INT           NOT NULL,
    CONSTRAINT server_connection foreign key (fk_server) references server (id_server)
);

INSERT INTO country (name, country_code, mask_company_registration_number, mask_phone)
VALUES ('Brazil', 'BR', '00.000.000/0000-00', '{+55} (00) 00000-0000'),
       ('Japan', 'JP', '00-000-0000-000', '{+81} 000-0000-0000'),
       ('United States', 'US', '00-00-0000000', '{+1} (000) 000-0000'),
       ('China', 'CN', '000-000000000', '{+86} (000) 0000-0000'),
       ('France', 'FR', '00 000 000 000', '{+33} 00 00 00 00'),
       ('Sweden', 'SE', 'SE000000000000', '{+46} (0) 000 0000');

INSERT INTO contact (email, phone)
VALUES ('roberta@ubisoft.com', '89876543'),
       ('fernando@ubisoft.com', '84567891'),
       ('ralph@ubisoft.com', '87891234'),
       ('ana@ubisoft.com', '98873123'),
       ('diego@ubisoft.com', '98273123'),
       ('ubisoft@ubisoft.com', '11938445384'),
       ('latencyslayer@latencyslayer.com', '11938477384');

INSERT INTO company (commercial_name, legal_name, registration_number, fk_contact, fk_country)
VALUES ('Ubsoft', 'Ubsoft Tecnologia LTDA', '00000000000000', 5, 1),
       ('Latency Slayer', 'Latency Slayer', '11111111111111', 6, 1);

INSERT INTO opt_role (name, description)
VALUES ('Gerente', 'Full access to the entire company profile.'),
       ('Analista de Suporte', 'Real-time Dashboard Access'),
       ('Analista de Dados', 'Access to Analytics Dashboard'),
       ('Suporte N3', 'Acess to Jira'),
       ('FinOps', 'Acess to AWS Cost');

INSERT INTO employee (name, gender, fk_company, fk_contact, fk_role, password)
VALUES ('Roberta', 'Female', 1, 1, 2, '@Roberta25'),
       ('Fernando', 'Male', 1, 2, 3, '@Fernando25'),
       ('Ralph', 'Male', 1, 3, 1, '@Ralph25'),
       ('Ana', 'Female', 1, 4, 4, '@Ana25'),
       ('Diego', 'Male', 2, 5, 5, '@Diego25');


INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (1, '/87PDG54/BRCMM0047O01DF/', 'ext-039123', 'cloud', null, 1, 'windows', 'São Paulo', 'Far Cry 5', 43, 1, 1);
INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (2, '/2VMXVC2/BR1081963A010F/', 'Ext2345', 'on-premise', null, 1, 'windows', 'São Paulo', 'Assassin\'s Creed',
        3000, 1, 1);
INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (3, 'PE0CDDG8', 'ext-059768', 'cloud', null, 1, 'windows', 'São Paulo', 'Skull and Bones', 444, 1, 1);
INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (4, 'PE0BN4DW', 'ext-sv01-watch-dogs-2', 'cloud', null, 1, 'windows', 'São Paulo', 'Watch Dogs 2', 9090, 1, 1);
INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (5, 'JBL01260A4221C524P', 'EXT-56788643', 'cloud', null, 1, 'windows', 'São Paulo', 'Star Wars Outlaws', 7777, 1,
        1);
INSERT INTO latency_slayer.server (id_server, motherboard_id, tag_name, type, instance_id, active, so, city, game, port,
                                   fk_company, fk_country)
VALUES (6, 'HNZ-202112132021', 'ext-12938', 'on-premise', null, 1, 'windows', 'São Paulo', 'Rainbow Six Siege', 25565,
        1, 1);

INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (1, '12th Gen Intel(R) Core(TM) i5-1235U', 'cpu', 1, 1);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (2, 'DDR4', 'ram', 1, 1);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (3, 'C:\\', 'storage', 1, 1);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (4, 'DDR3', 'ram', 1, 2);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (5, 'Intel(R) Core(TM) i5-5200U CPU @ 2.20GHz', 'cpu', 1, 2);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (6, 'C:\\', 'storage', 1, 2);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (7, 'DDR4', 'ram', 1, 3);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (8, '12th Gen Intel(R) Core(TM) i7-1255U', 'cpu', 1, 3);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (9, 'C:\\', 'storage', 1, 3);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (10, 'AMD Ryzen 7 5700U with Radeon Graphics', 'cpu', 1, 4);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (11, 'DDR4', 'ram', 1, 4);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (12, 'C:\\', 'storage', 1, 4);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (13, '11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz', 'cpu', 1, 5);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (14, 'C:\\', 'storage', 1, 5);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (15, 'DDR4', 'ram', 1, 5);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (16, 'DDR4', 'ram', 1, 6);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (17, 'Intel(R) Xeon(R) CPU E5-2690 v3 @ 2.60GHz', 'cpu', 1, 6);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (18, 'C:\\', 'storage', 1, 6);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (19, 'E:\\', 'storage', 1, 6);
INSERT INTO latency_slayer.component (id_component, tag_name, type, active, fk_server)
VALUES (21, 'D:\\', 'storage', 1, 6);

INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (1, '%', 90, 30, 100, 2);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (2, 'celsius', 80, 20, 0, 1);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (3, '%', 80, 40, 100, 3);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (4, 'GB', 365, 183, 457, 3);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (5, '%', 85, 20, 100, 1);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (6, 'GB', 14, 5, 16, 2);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (7, '%', 80, null, 100, 4);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (8, '%', 80, null, 100, 5);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (9, 'GB', 13, null, 16, 4);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (10, 'celsius', 75, null, 0, 5);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (11, '%', 85, null, 100, 6);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (12, 'GB', 197, null, 231, 6);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (13, '%', 85, null, 100, 7);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (14, '%', 85, null, 100, 8);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (15, 'GB', 13, null, 16, 7);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (16, 'celsius', 75, null, 0, 8);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (17, '%', 80, null, 100, 9);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (18, 'GB', 380, null, 475, 9);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (19, '%', 80, null, 100, 10);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (20, 'celsius', 75, null, 0, 10);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (21, '%', 80, null, 100, 11);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (22, 'GB', 5, null, 6, 11);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (23, '%', 75, null, 100, 12);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (24, 'GB', 178, null, 238, 12);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (25, '%', 75, null, 100, 13);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (26, 'celsius', 75, null, 0, 13);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (27, '%', 75, null, 100, 14);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (28, 'GB', 167, null, 222, 14);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (29, '%', 75, null, 100, 15);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (30, 'GB', 6, null, 8, 15);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (31, '%', 80, null, 100, 21);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (32, '%', 80, null, 100, 16);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (33, 'GB', 745, null, 932, 21);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (34, '%', 80, null, 100, 18);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (36, 'GB', 819, null, 1024, 19);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (37, 'celsius', 75, null, 0, 17);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (38, 'GB', 38, null, 48, 16);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (39, '%', 80, null, 100, 19);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (41, 'GB', 357, null, 446, 18);
INSERT INTO latency_slayer.metric (id_metric, metric, max_limit, min_limit, total, fk_component)
VALUES (42, '%', 80, null, 100, 17);



INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-03-01 14:23:15', 'CPU usage exceeded maximum limit', 85, 92.5, 5, 'alto'),
       ('resolvido', '2025-03-01 18:45:32', 'RAM usage exceeded maximum limit', 90, 94.2, 1, 'critico'),
       ('resolvido', '2025-03-02 10:15:28', 'CPU usage exceeded maximum limit', 80, 87.3, 8, 'alto'),
       ('resolvido', '2025-03-02 16:30:45', 'RAM usage exceeded maximum limit', 85, 89.7, 13, 'alto'),
       ('resolvido', '2025-03-02 22:12:18', 'CPU usage exceeded maximum limit', 80, 91.8, 19, 'critico');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-03-08 11:45:23', 'RAM usage exceeded maximum limit', 80, 85.6, 32, 'alto'),
       ('resolvido', '2025-03-08 19:22:41', 'CPU usage exceeded maximum limit', 75, 82.1, 25, 'alto'),
       ('resolvido', '2025-03-09 09:33:17', 'CPU usage exceeded maximum limit', 80, 88.9, 42, 'alto'),
       ('resolvido', '2025-03-09 15:18:52', 'RAM usage exceeded maximum limit', 80, 91.4, 21, 'critico'),
       ('resolvido', '2025-03-09 21:07:36', 'CPU usage exceeded maximum limit', 85, 93.2, 14, 'critico');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-03-15 13:28:44', 'CPU usage exceeded maximum limit', 80, 86.7, 17, 'alto'),
       ('resolvido', '2025-03-15 20:55:19', 'RAM usage exceeded maximum limit', 75, 81.3, 29, 'alto'),
       ('resolvido', '2025-03-16 08:42:31', 'CPU usage exceeded maximum limit', 75, 78.9, 27, 'medio'),
       ('resolvido', '2025-03-16 17:14:28', 'RAM usage exceeded maximum limit', 85, 88.5, 1, 'alto'),
       ('resolvido', '2025-03-16 23:39:15', 'CPU usage exceeded maximum limit', 80, 84.2, 23, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-03-22 12:16:37', 'RAM usage exceeded maximum limit', 80, 87.1, 7, 'alto'),
       ('resolvido', '2025-03-22 18:43:22', 'CPU usage exceeded maximum limit', 85, 90.6, 5, 'critico'),
       ('resolvido', '2025-03-23 10:52:48', 'CPU usage exceeded maximum limit', 80, 83.9, 34, 'alto'),
       ('resolvido', '2025-03-23 16:25:13', 'RAM usage exceeded maximum limit', 75, 79.4, 29, 'medio'),
       ('resolvido', '2025-03-23 22:08:56', 'CPU usage exceeded maximum limit', 80, 92.7, 11, 'critico');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-03-29 14:31:42', 'CPU usage exceeded maximum limit', 75, 81.8, 25, 'alto'),
       ('resolvido', '2025-03-29 19:17:25', 'RAM usage exceeded maximum limit', 80, 86.3, 32, 'alto'),
       ('resolvido', '2025-03-30 11:04:18', 'CPU usage exceeded maximum limit', 85, 89.1, 14, 'alto'),
       ('resolvido', '2025-03-30 15:48:39', 'RAM usage exceeded maximum limit', 80, 94.8, 21, 'critico'),
       ('resolvido', '2025-03-30 20:22:14', 'CPU usage exceeded maximum limit', 80, 87.5, 17, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-04-05 13:55:31', 'RAM usage exceeded maximum limit', 90, 95.2, 1, 'critico'),
       ('resolvido', '2025-04-05 17:42:16', 'CPU usage exceeded maximum limit', 80, 88.7, 8, 'alto'),
       ('resolvido', '2025-04-06 09:28:43', 'CPU usage exceeded maximum limit', 80, 85.9, 19, 'alto'),
       ('resolvido', '2025-04-06 14:13:57', 'RAM usage exceeded maximum limit', 85, 87.8, 13, 'alto'),
       ('resolvido', '2025-04-06 21:36:22', 'CPU usage exceeded maximum limit', 75, 83.4, 27, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-04-12 12:47:28', 'CPU usage exceeded maximum limit', 80, 91.3, 23, 'critico'),
       ('resolvido', '2025-04-13 10:21:35', 'CPU usage exceeded maximum limit', 85, 88.2, 42, 'alto'),
       ('resolvido', '2025-04-13 18:44:51', 'RAM usage exceeded maximum limit', 75, 82.7, 29, 'alto'),
       ('resolvido', '2025-04-13 23:16:08', 'CPU usage exceeded maximum limit', 80, 86.9, 34, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-04-19 11:32:47', 'RAM usage exceeded maximum limit', 80, 89.4, 7, 'alto'),
       ('resolvido', '2025-04-19 19:08:23', 'CPU usage exceeded maximum limit', 85, 92.1, 5, 'critico'),
       ('resolvido', '2025-04-20 08:54:16', 'CPU usage exceeded maximum limit', 80, 87.6, 17, 'alto'),
       ('resolvido', '2025-04-20 15:27:39', 'RAM usage exceeded maximum limit', 80, 85.8, 21, 'alto'),
       ('resolvido', '2025-04-20 22:41:55', 'CPU usage exceeded maximum limit', 75, 79.3, 25, 'medio');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-04-26 13:18:32', 'CPU usage exceeded maximum limit', 80, 84.7, 11, 'alto'),
       ('resolvido', '2025-04-26 17:45:18', 'RAM usage exceeded maximum limit', 85, 90.5, 13, 'critico'),
       ('resolvido', '2025-04-27 09:36:44', 'CPU usage exceeded maximum limit', 80, 88.1, 19, 'alto'),
       ('resolvido', '2025-04-27 14:52:27', 'RAM usage exceeded maximum limit', 90, 93.8, 1, 'critico'),
       ('resolvido', '2025-04-27 20:14:03', 'CPU usage exceeded maximum limit', 80, 86.2, 8, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-05-03 12:29:51', 'RAM usage exceeded maximum limit', 80, 87.9, 32, 'alto'),
       ('resolvido', '2025-05-03 18:16:37', 'CPU usage exceeded maximum limit', 75, 81.5, 27, 'alto'),
       ('resolvido', '2025-05-04 10:43:24', 'CPU usage exceeded maximum limit', 85, 89.7, 14, 'alto'),
       ('resolvido', '2025-05-04 16:07:48', 'RAM usage exceeded maximum limit', 75, 78.2, 29, 'medio'),
       ('resolvido', '2025-05-04 21:33:12', 'CPU usage exceeded maximum limit', 80, 85.4, 23, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-05-10 14:25:19', 'CPU usage exceeded maximum limit', 80, 92.8, 42, 'critico'),
       ('resolvido', '2025-05-11 11:12:33', 'CPU usage exceeded maximum limit', 80, 83.6, 34, 'alto'),
       ('resolvido', '2025-05-11 17:38:29', 'RAM usage exceeded maximum limit', 85, 91.2, 13, 'critico'),
       ('resolvido', '2025-05-11 23:04:56', 'CPU usage exceeded maximum limit', 75, 80.9, 25, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-05-17 13:41:22', 'RAM usage exceeded maximum limit', 90, 94.1, 1, 'critico'),
       ('resolvido', '2025-05-17 16:27:38', 'CPU usage exceeded maximum limit', 80, 87.3, 17, 'alto'),
       ('resolvido', '2025-05-18 09:53:14', 'CPU usage exceeded maximum limit', 85, 88.9, 5, 'alto'),
       ('resolvido', '2025-05-18 15:19:41', 'RAM usage exceeded maximum limit', 80, 82.6, 21, 'alto'),
       ('resolvido', '2025-05-18 20:46:07', 'CPU usage exceeded maximum limit', 80, 84.8, 11, 'alto');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES ('resolvido', '2025-05-24 15:32:18', 'CPU usage exceeded maximum limit', 75, 79.7, 27, 'medio'),
       ('resolvido', '2025-05-24 21:18:45', 'RAM usage exceeded maximum limit', 80, 85.3, 32, 'alto'),
       ('resolvido', '2025-05-25 12:44:31', 'CPU usage exceeded maximum limit', 80, 86.1, 19, 'alto'),
       ('resolvido', '2025-05-25 18:29:54', 'RAM usage exceeded maximum limit', 85, 89.8, 13, 'alto'),
       ('resolvido', '2025-05-31 14:55:27', 'CPU usage exceeded maximum limit', 85, 91.6, 14, 'critico');
