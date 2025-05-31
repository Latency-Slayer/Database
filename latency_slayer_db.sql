DROP DATABASE IF EXISTS latency_slayer;
CREATE DATABASE IF NOT EXISTS latency_slayer;
USE latency_slayer;

CREATE TABLE country (
	id_country INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL UNIQUE,
	country_code CHAR(2) NOT NULL UNIQUE,
    mask_company_registration_number VARCHAR(45) NOT NULL,
    mask_phone VARCHAR(45) NOT NULL
);
    
CREATE TABLE contact (
	id_contact INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(16) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);
    
CREATE TABLE company (
	id_company INT PRIMARY KEY AUTO_INCREMENT,
    commercial_name VARCHAR(45) NOT NULL,
    legal_name VARCHAR(100) NOT NULL,
    registration_number VARCHAR(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_country INT NOT NULL,
    fk_contact INT NOT NULL UNIQUE,
    CONSTRAINT fk_commpany_contact FOREIGN KEY (fk_contact) REFERENCES contact (id_contact),
    CONSTRAINT fk_company_country FOREIGN KEY (fk_country) REFERENCES country (id_country)
);
    
CREATE TABLE opt_role (
	id_opt_role INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL UNIQUE,
    description VARCHAR(80)
);
    
CREATE TABLE employee (
	id_employee INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_role INT NOT NULL,
    fk_contact INT NOT NULL UNIQUE,
    fk_company INT NOT NULL,
    CONSTRAINT fk_opt_role FOREIGN KEY (fk_role)
    REFERENCES opt_role (id_opt_role),
    CONSTRAINT fk_cont_contact FOREIGN KEY (fk_contact)
    REFERENCES contact (id_contact),
    CONSTRAINT fk_comp_company FOREIGN KEY (fk_company)
    REFERENCES company (id_company)
);
    
CREATE TABLE server (
	id_server INT PRIMARY KEY AUTO_INCREMENT,
    motherboard_id VARCHAR(150) NOT NULL UNIQUE,
    tag_name VARCHAR(45) NOT NULL,
    type ENUM ('cloud', 'on-premise') NOT NULL,
    instance_id VARCHAR(45) UNIQUE,
    active TINYINT(1) NOT NULL DEFAULT 1,
    so ENUM ('windows', 'linux', 'macos') NOT NULL,
    city VARCHAR(60) NOT NULL,
    game VARCHAR(45) NOT NULL,
    port INT NOT NULL,
    fk_company INT NOT NULL,
    fk_country INT NOT NULL,
    CONSTRAINT fk_compa_company FOREIGN KEY (fk_company)
    REFERENCES company (id_company),
    CONSTRAINT fk_count_country FOREIGN KEY (fk_country)
    REFERENCES country (id_country)
);
    
CREATE TABLE component (
	id_component INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(150) NOT NULL,
    type ENUM('cpu', 'ram', 'storage', 'swap') NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    fk_server INT NOT NULL,
    CONSTRAINT fk_ser_server FOREIGN KEY (fk_server)
    REFERENCES server (id_server)
);

CREATE TABLE metric (
	id_metric INT PRIMARY KEY AUTO_INCREMENT,
    metric ENUM('GB', 'MB', 'KB', 'Kbps', 'Mbps', '%', 'Mhz', 'Ghz', 'celsius') NOT NULL,
    max_limit INT NOT NULL,
    min_limit INT,
    total INT NOT NULL,
    fk_component INT NOT NULL,
    CONSTRAINT fk_com_component FOREIGN KEY (fk_component)
    REFERENCES component (id_component)
);

CREATE TABLE alert (
id_Alert INT PRIMARY KEY AUTO_INCREMENT,
status ENUM('aberto', 'acompanhamento', 'resolvido') NOT NULL,
dateAlert TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
mensage VARCHAR(100) NOT NULL,
exceeded_limit INT NOT NULL,
valor DOUBLE NOT NULL,
fk_Metric INT NOT NULL,
nivel VARCHAR(30) NOT NULL,
CONSTRAINT fk_alert_metric FOREIGN KEY (fk_Metric)
REFERENCES metric (id_metric)
);


CREATE TABLE connection_capturing (
	id_connection_capturing INT PRIMARY KEY auto_increment,
    ip_player CHAR(15) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    country VARCHAR(45) NOT NULL,
    continent_code CHAR(2) NOT NULL,
    date_time datetime NOT NULL,
    fk_server INT NOT NULL,
    CONSTRAINT server_connection foreign key (fk_server) references server(id_server)
);


INSERT INTO country (name, country_code, mask_company_registration_number, mask_phone) VALUES
('Brazil', 'BR', '00.000.000/0000-00', '{+55} (00) 00000-0000'),
('Japan', 'JP', '00-000-0000-000', '{+81} 000-0000-0000'),
('United States', 'US', '00-00-0000000', '{+1} (000) 000-0000'),
('China', 'CN', '000-000000000', '{+86} (000) 0000-0000'),
('France', 'FR', '00 000 000 000', '{+33} 00 00 00 00'),
('Sweden', 'SE', 'SE000000000001', '{+46} (0) 000 0000');

INSERT INTO contact (email, phone) VALUES 
('roberta@mojang.com', '89876543'),
('fernando@mojang.com', '84567891'),
('ralph@mojang.com', '87891234'),
('ana@mojang.com', '98873123');

INSERT INTO company (commercial_name, legal_name, registration_number, fk_contact, fk_country) VALUES
('Ubsoft', 'Ubsoft Tecnologia LTDA', '00000000000000', 2, 1),
('Mojang', 'Mojang Studios', 'SE000000000001', 6, 6);

INSERT INTO opt_role (name, description) VALUES
('Gerente', 'Full access to the entire company profile.'),
('Analista de Suporte', 'Real-time Dashboard Access'),
('Business Inteligence', 'Access to Analytics Dashboard'),
('Suporte N3', 'Acess to Jira');

INSERT INTO employee (name, gender, fk_company, fk_contact, fk_role, password) VALUES 
('Roberta', 'Female', 2, 3, 2, '@Roberta25'),
('Fernando', 'Male', 2, 4, 3, '@Fernando30'),
('Ralph', 'Male', 2, 5, 1, '@Roberta35'),
('Ana', 'Female',2,7,4,'@Ana123');

SELECT COUNT(*) from connection_capturing;

SELECT
    DATE_FORMAT(date_time, '%Y-%m') AS mes,
    ROUND(COUNT(*) / COUNT(DISTINCT day (date_time)), 0) AS media_por_dia
FROM
    connection_capturing
GROUP BY
    DATE_FORMAT(date_time, '%Y-%m')
ORDER BY
    mes; 

TRUNCATE connection_capturing;

