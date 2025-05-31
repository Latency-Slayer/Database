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
('ana@mojang.com', '98873123'),
('diego@mojang.com', '98273123');

INSERT INTO company (commercial_name, legal_name, registration_number, fk_contact, fk_country) VALUES
('Ubsoft', 'Ubsoft Tecnologia LTDA', '00000000000000', 2, 1),
('Mojang', 'Mojang Studios', 'SE000000000001', 1, 4);

INSERT INTO opt_role (name, description) VALUES
('Gerente', 'Full access to the entire company profile.'),
('Analista de Suporte', 'Real-time Dashboard Access'),
('Analista de Dados', 'Access to Analytics Dashboard'),
('Suporte N3', 'Acess to Jira'),
('FinOps', "Acess to AWS Cost");

INSERT INTO employee (name, gender, fk_company, fk_contact, fk_role, password) VALUES 
('Roberta', 'Female', 2, 1, 2, '@Roberta25'),
('Fernando', 'Male', 2, 2, 3, '@Fernando30'),
('Ralph', 'Male', 2, 3, 1, '@Roberta35'),
('Ana', 'Female',2,4,4,'@Ana123'),
('Diego', 'Male',2,5,5,'@Diego123');


INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel) VALUES
('aberto', '2025-05-28 10:36:54', 'O componente CPU está próximo do limite. Valor atual: 84.6%, Limite: 90%', 90, 84.6, 5, 'Atenção'),
('aberto', '2025-05-29 01:09:17', 'O componente RAM está próximo do limite. Valor atual: 67.5%, Limite: 80%', 80, 67.5, 3, 'Atenção'),
('aberto', '2025-05-28 23:50:42', 'O componente STORAGE está próximo do limite. Valor atual: 60.6%, Limite: 70%', 70, 60.6, 2, 'Atenção'),
('aberto', '2025-05-27 02:48:27', 'O componente CPU está próximo do limite. Valor atual: 83.7%, Limite: 90%', 90, 83.7, 5, 'Atenção'),
('aberto', '2025-05-27 19:31:53', 'O componente RAM está próximo do limite. Valor atual: 67.9%, Limite: 80%', 80, 67.9, 3, 'Atenção'),
('aberto', '2025-05-25 02:13:30', 'O componente STORAGE ultrapassou o limite. Valor atual: 72.2%, Limite: 70%', 70, 72.2, 2, 'Crítico'),
('aberto', '2025-05-29 21:44:20', 'O componente CPU ultrapassou o limite. Valor atual: 92.6%, Limite: 90%', 90, 92.6, 5, 'Crítico'),
('aberto', '2025-05-25 22:50:49', 'O componente RAM está próximo do limite. Valor atual: 69.8%, Limite: 80%', 80, 69.8, 3, 'Atenção'),
('aberto', '2025-05-27 15:34:06', 'O componente STORAGE ultrapassou o limite. Valor atual: 77.6%, Limite: 70%', 70, 77.6, 2, 'Crítico'),
('aberto', '2025-05-29 23:36:47', 'O componente CPU ultrapassou o limite. Valor atual: 93.7%, Limite: 90%', 90, 93.7, 5, 'Crítico'),
('aberto', '2025-05-30 18:10:07', 'O componente STORAGE ultrapassou o limite. Valor atual: 79.4%, Limite: 70%', 70, 79.4, 2, 'Crítico');

INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel) VALUES
('aberto', '2025-05-25 08:15:23', 'O componente CPU está próximo do limite. Valor atual: 87.2%, Limite: 90%', 90, 87.2, 5, 'Atenção'),
('aberto', '2025-05-25 09:42:16', 'O componente RAM está próximo do limite. Valor atual: 75.8%, Limite: 80%', 80, 75.8, 3, 'Atenção'),
('aberto', '2025-05-25 11:28:45', 'O componente NETWORK está próximo do limite. Valor atual: 68.9%, Limite: 75%', 75, 68.9, 2, 'Atenção'),
('aberto', '2025-05-25 14:16:33', 'O componente CPU excedeu o limite. Valor atual: 94.7%, Limite: 90%', 90, 94.7, 5, 'Crítico'),
('aberto', '2025-05-25 16:52:18', 'O componente RAM excedeu o limite. Valor atual: 83.9%, Limite: 80%', 80, 83.9, 3, 'Crítico'),
('aberto', '2025-05-25 19:35:12', 'O componente NETWORK excedeu o limite. Valor atual: 79.8%, Limite: 75%', 75, 79.8, 2, 'Crítico'),
('aberto', '2025-05-25 21:08:56', 'O componente CPU está próximo do limite. Valor atual: 88.1%, Limite: 90%', 90, 88.1, 5, 'Atenção'),
('aberto', '2025-05-25 23:44:29', 'O componente RAM está próximo do limite. Valor atual: 72.6%, Limite: 80%', 80, 72.6, 3, 'Atenção'),

('aberto', '2025-05-26 02:13:41', 'O componente NETWORK excedeu o limite. Valor atual: 76.4%, Limite: 75%', 75, 76.4, 2, 'Crítico'),
('aberto', '2025-05-26 05:27:58', 'O componente CPU está próximo do limite. Valor atual: 86.5%, Limite: 90%', 90, 86.5, 5, 'Atenção'),
('aberto', '2025-05-26 07:56:14', 'O componente RAM está próximo do limite. Valor atual: 77.2%, Limite: 80%', 80, 77.2, 3, 'Atenção'),
('aberto', '2025-05-26 10:41:37', 'O componente NETWORK está próximo do limite. Valor atual: 71.8%, Limite: 75%', 75, 71.8, 2, 'Atenção'),
('aberto', '2025-05-26 13:18:22', 'O componente CPU excedeu o limite. Valor atual: 93.4%, Limite: 90%', 90, 93.4, 5, 'Crítico'),
('aberto', '2025-05-26 15:49:51', 'O componente RAM excedeu o limite. Valor atual: 84.2%, Limite: 80%', 80, 84.2, 3, 'Crítico'),
('aberto', '2025-05-26 18:25:16', 'O componente NETWORK excedeu o limite. Valor atual: 77.3%, Limite: 75%', 75, 77.3, 2, 'Crítico'),
('aberto', '2025-05-26 20:57:43', 'O componente CPU está próximo do limite. Valor atual: 89.1%, Limite: 90%', 90, 89.1, 5, 'Atenção'),

('aberto', '2025-05-27 01:32:19', 'O componente RAM está próximo do limite. Valor atual: 77.9%, Limite: 80%', 80, 77.9, 3, 'Atenção'),
('aberto', '2025-05-27 04:08:45', 'O componente NETWORK está próximo do limite. Valor atual: 73.6%, Limite: 75%', 75, 73.6, 2, 'Atenção'),
('aberto', '2025-05-27 06:44:32', 'O componente CPU está próximo do limite. Valor atual: 88.3%, Limite: 90%', 90, 88.3, 5, 'Atenção'),
('aberto', '2025-05-27 09:21:17', 'O componente RAM excedeu o limite. Valor atual: 82.5%, Limite: 80%', 80, 82.5, 3, 'Crítico'),
('aberto', '2025-05-27 11:56:28', 'O componente NETWORK excedeu o limite. Valor atual: 78.2%, Limite: 75%', 75, 78.2, 2, 'Crítico'),
('aberto', '2025-05-27 14:33:54', 'O componente CPU excedeu o limite. Valor atual: 91.8%, Limite: 90%', 90, 91.8, 5, 'Crítico'),
('aberto', '2025-05-27 17:11:39', 'O componente RAM está próximo do limite. Valor atual: 78.4%, Limite: 80%', 80, 78.4, 3, 'Atenção'),
('aberto', '2025-05-27 19:48:26', 'O componente NETWORK está próximo do limite. Valor atual: 74.1%, Limite: 75%', 75, 74.1, 2, 'Atenção'),

('aberto', '2025-05-28 00:25:11', 'O componente CPU excedeu o limite. Valor atual: 95.1%, Limite: 90%', 90, 95.1, 5, 'Crítico'),
('aberto', '2025-05-28 03:02:48', 'O componente RAM está próximo do limite. Valor atual: 79.1%, Limite: 80%', 80, 79.1, 3, 'Atenção'),
('aberto', '2025-05-28 05:39:35', 'O componente NETWORK excedeu o limite. Valor atual: 76.9%, Limite: 75%', 75, 76.9, 2, 'Crítico'),
('aberto', '2025-05-28 08:16:22', 'O componente CPU está próximo do limite. Valor atual: 89.5%, Limite: 90%', 90, 89.5, 5, 'Atenção'),
('aberto', '2025-05-28 10:53:17', 'O componente RAM excedeu o limite. Valor atual: 81.7%, Limite: 80%', 80, 81.7, 3, 'Crítico'),
('aberto', '2025-05-28 13:29:44', 'O componente NETWORK está próximo do limite. Valor atual: 72.2%, Limite: 75%', 75, 72.2, 2, 'Atenção'),
('aberto', '2025-05-28 16:06:31', 'O componente CPU excedeu o limite. Valor atual: 92.8%, Limite: 90%', 90, 92.8, 5, 'Crítico'),
('aberto', '2025-05-28 18:43:58', 'O componente RAM está próximo do limite. Valor atual: 76.3%, Limite: 80%', 80, 76.3, 3, 'Atenção'),

('aberto', '2025-05-29 00:18:25', 'O componente NETWORK excedeu o limite. Valor atual: 77.8%, Limite: 75%', 75, 77.8, 2, 'Crítico'),
('aberto', '2025-05-29 02:55:42', 'O componente CPU está próximo do limite. Valor atual: 87.4%, Limite: 90%', 90, 87.4, 5, 'Atenção'),
('aberto', '2025-05-29 05:32:19', 'O componente RAM excedeu o limite. Valor atual: 84.8%, Limite: 80%', 80, 84.8, 3, 'Crítico'),
('aberto', '2025-05-29 08:09:36', 'O componente NETWORK está próximo do limite. Valor atual: 73.9%, Limite: 75%', 75, 73.9, 2, 'Atenção'),
('aberto', '2025-05-29 10:46:53', 'O componente CPU excedeu o limite. Valor atual: 94.6%, Limite: 90%', 90, 94.6, 5, 'Crítico'),
('aberto', '2025-05-29 13:24:17', 'O componente RAM está próximo do limite. Valor atual: 79.1%, Limite: 80%', 80, 79.1, 3, 'Atenção'),
('aberto', '2025-05-29 16:01:34', 'O componente NETWORK excedeu o limite. Valor atual: 76.7%, Limite: 75%', 75, 76.7, 2, 'Crítico'),
('aberto', '2025-05-29 18:38:51', 'O componente CPU está próximo do limite. Valor atual: 88.2%, Limite: 90%', 90, 88.2, 5, 'Atenção'),

('aberto', '2025-05-30 01:15:28', 'O componente RAM excedeu o limite. Valor atual: 83.5%, Limite: 80%', 80, 83.5, 3, 'Crítico'),
('aberto', '2025-05-30 03:52:45', 'O componente NETWORK está próximo do limite. Valor atual: 74.4%, Limite: 75%', 75, 74.4, 2, 'Atenção'),
('aberto', '2025-05-30 06:29:12', 'O componente CPU excedeu o limite. Valor atual: 92.3%, Limite: 90%', 90, 92.3, 5, 'Crítico'),
('aberto', '2025-05-30 09:06:39', 'O componente RAM está próximo do limite. Valor atual: 78.9%, Limite: 80%', 80, 78.9, 3, 'Atenção'),
('aberto', '2025-05-30 11:43:56', 'O componente NETWORK excedeu o limite. Valor atual: 78.7%, Limite: 75%', 75, 78.7, 2, 'Crítico'),
('aberto', '2025-05-30 14:21:13', 'O componente CPU está próximo do limite. Valor atual: 89.7%, Limite: 90%', 90, 89.7, 5, 'Atenção'),
('aberto', '2025-05-30 16:58:47', 'O componente RAM excedeu o limite. Valor atual: 81.8%, Limite: 80%', 80, 81.8, 3, 'Crítico'),
('aberto', '2025-05-30 19:35:24', 'O componente NETWORK está próximo do limite. Valor atual: 72.3%, Limite: 75%', 75, 72.3, 2, 'Atenção'),

('aberto', '2025-05-31 00:12:41', 'O componente CPU excedeu o limite. Valor atual: 96.9%, Limite: 90%', 90, 96.9, 5, 'Crítico'),
('aberto', '2025-05-31 02:49:18', 'O componente RAM está próximo do limite. Valor atual: 79.2%, Limite: 80%', 80, 79.2, 3, 'Atenção'),
('aberto', '2025-05-31 05:26:35', 'O componente NETWORK excedeu o limite. Valor atual: 77.4%, Limite: 75%', 75, 77.4, 2, 'Crítico'),
('aberto', '2025-05-31 08:03:52', 'O componente CPU está próximo do limite. Valor atual: 88.1%, Limite: 90%', 90, 88.1, 5, 'Atenção');


