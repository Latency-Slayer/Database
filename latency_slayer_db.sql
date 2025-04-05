CREATE DATABASE latency_slayer;
USE latency_slayer;

CREATE TABLE country (
	id_country INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
	country_code CHAR(2) NOT NULL,
    mask_company_registration_number VARCHAR(45) NOT NULL,
    mask_phone VARCHAR(45) NOT NULL
);
    
CREATE TABLE contact (
	id_contact INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL);
    
CREATE TABLE company (
	id_company INT PRIMARY KEY AUTO_INCREMENT,
    commercial_name VARCHAR(45) NOT NULL,
    legal_name VARCHAR(100) NOT NULL,
    registration_number VARCHAR(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_contact INT NOT NULL,
    fk_country INT NOT NULL);
    
CREATE TABLE opt_role (
	id_opt_role INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    description VARCHAR(80));
    
CREATE TABLE employee (
	id_employee INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    fk_role INT NOT NULL,
    fk_contact INT NOT NULL,
    fk_company INT NOT NULL,
    CONSTRAINT fk_opt_role FOREIGN KEY (fk_role)
    REFERENCES opt_role (id_opt_role),
    CONSTRAINT fk_cont_contact FOREIGN KEY (fk_contact)
    REFERENCES contact (id_contact),
    CONSTRAINT fk_comp_company FOREIGN KEY (fk_company)
    REFERENCES company (id_company));
    
CREATE TABLE server (
	id_server INT PRIMARY KEY AUTO_INCREMENT,
    motherboard_id VARCHAR(45) NOT NULL,
    tag_name VARCHAR(45) NOT NULL,
    type ENUM ('cloud', 'on-premise') NOT NULL,
    instance_id VARCHAR(45),
    active TINYINT(1) NOT NULL,
    so ENUM ('windows', 'linux', 'mcos') NOT NULL,
    fk_city INT NOT NULL,
    fk_company INT NOT NULL,
    fk_country INT NOT NULL,
    CONSTRAINT fk_compa_company FOREIGN KEY (fk_company)
    REFERENCES company (id_company),
    CONSTRAINT fk_count_country FOREIGN KEY (fk_country)
    REFERENCES country (id_country));
    
CREATE TABLE component (
	id_component INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(45) NOT NULL,
    type VARCHAR(45) NOT NULL,
    fk_server INT NOT NULL,
    CONSTRAINT fk_ser_server FOREIGN KEY (fk_server)
    REFERENCES server (id_server));

CREATE TABLE metric (
	id_metric INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10) NOT NULL,
    metric VARCHAR(10) NOT NULL,
    max_limit INT NOT NULL,
    min_limit INT NOT NULL,
    total INT NOT NULL,
    fk_component INT NOT NULL,
    CONSTRAINT fk_com_component FOREIGN KEY (fk_component)
    REFERENCES component (id_component));

CREATE TABLE alert (
	fk_metric INT NOT NULL,
    current INT NOT NULL,
    date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_met_metric FOREIGN KEY (fk_metric)
    REFERENCES metric (id_metric));

CREATE TABLE register (
	fk_metric INT NOT NULL,
    current VARCHAR(45) NOT NULL,
    date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_reg_metric FOREIGN KEY (fk_metric)
    REFERENCES metric (id_metric));

CREATE TABLE connection (
	id_connection INT PRIMARY KEY AUTO_INCREMENT,
    ip VARCHAR(45),
    city VARCHAR(45),
    date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fk_server INT,
    CONSTRAINT fk_se_server FOREIGN KEY (fk_server)
    REFERENCES server (id_server));

INSERT INTO country (name, country_code, mask_company_registration_number, mask_phone) VALUES
('Brazil', 'BR', '00.000.000/0000-00', '{+55} (00) 00000-0000'),
('Japan', 'JP', '00-000-0000-000', '{+81} 000-0000-0000'),
('United States', 'US', '00-00-0000000', '{+1} (000) 000-0000'),
('China', 'CN', '000-000000000', '{+86} (000) 0000-0000'),
('France', 'FR', '00 000 000 000', '{+33} 00 00 00 00');

-- INSERT INTO contact (email, phone, created_at, updated_at) VALUES
-- ('john.doe@example.com', '+12025550123', '2025-01-01 08:30:00', '2025-04-03 09:00:00'),
-- ('mary.jane@example.com', '+44-20-7946-0958', '2025-01-02 09:00:00', '2025-04-03 09:05:00'),
-- ('alice.smith@example.com', '+49-30-1234567', '2025-01-03 10:15:00', '2025-04-03 09:10:00'),
-- ('bob.johnson@example.com', '+33-1-70189900', '2025-01-04 11:20:00', '2025-04-03 09:20:00'),
-- ('carol.williams@example.com', '+1-415-555-0130', '2025-01-05 12:25:00', '2025-04-03 09:25:00'),
-- ('david.brown@example.com', '+61-2-98765432', '2025-01-06 13:30:00', '2025-04-03 09:30:00'),
-- ('emma.jones@example.com', '+55-11-40028922', '2025-01-07 14:35:00', '2025-04-03 09:35:00'),
-- ('frank.miller@example.com', '+34-91-1234567', '2025-01-08 15:40:00', '2025-04-03 09:40:00'),
-- ('george.davis@example.com', '+81-3-12345678', '2025-01-09 16:45:00', '2025-04-03 09:45:00'),
-- ('hannah.martin@example.com', '+1-212-555-0140', '2025-01-10 17:50:00', '2025-04-03 09:50:00'),
-- ('isabel.martinez@example.com', '+52-55-1234-5678', '2025-01-11 18:55:00', '2025-04-03 09:55:00'),
-- ('jack.wilson@example.com', '+47-22-123456', '2025-01-12 19:00:00', '2025-04-03 10:00:00'),
-- ('zane.roberts@example.com', '+81-90-2345678', '2025-01-28 11:20:00', '2025-04-03 11:20:00');
    
-- INSERT INTO company (commercial_name, legal_name, registration_number, created_at, updated_at, fk_contact, fk_country) VALUES
-- ('Tech Innovations', 'Tech Innovations Ltd.', '1234567890123456', '2025-01-01 08:30:00', '2025-04-03 09:00:00', 1, 1),
-- ('Global Solutions', 'Global Solutions Inc.', '9876543210987654', '2025-01-02 09:00:00', '2025-04-03 09:05:00', 2, 2),
-- ('GreenEnergy', 'GreenEnergy Corporation', '5432109876543210', '2025-01-03 10:15:00', '2025-04-03 09:10:00', 3, 3),
-- ('EcoTech', 'EcoTech Technologies Ltd.', '1122334455667788', '2025-01-04 11:20:00', '2025-04-03 09:15:00', 4, 4),
-- ('Innovative Designs', 'Innovative Designs LLC', '2233445566778899', '2025-01-05 12:25:00', '2025-04-03 09:20:00', 5, 5),
-- ('MediHealth', 'MediHealth Solutions', '3344556677889900', '2025-01-06 13:30:00', '2025-04-03 09:25:00', 6, 6),
-- ('AutoMotive', 'AutoMotive Enterprises Ltd.', '4455667788990011', '2025-01-07 14:35:00', '2025-04-03 09:30:00', 7, 7),
-- ('FutureTech', 'FutureTech Innovations', '5566778899001122', '2025-01-08 15:40:00', '2025-04-03 09:35:00', 8, 8),
-- ('SoftWare Solutions', 'Software Solutions Ltd.', '6677889900112233', '2025-01-09 16:45:00', '2025-04-03 09:40:00', 9, 9),
-- ('CreativeWorks', 'CreativeWorks Studios Inc.', '7788990011223344', '2025-01-10 17:50:00', '2025-04-03 09:45:00', 10, 10),
-- ('World Trade Co.', 'World Trade Company LLC', '8899001122334455', '2025-01-11 18:55:00', '2025-04-03 09:50:00', 11, 11),
-- ('BlueOcean Ltd.', 'BlueOcean Technologies', '9900112233445566', '2025-01-12 19:00:00', '2025-04-03 09:55:00', 12, 12),
-- ('Elite Enterprises', 'Elite Enterprises Inc.', '1011121314151617', '2025-01-13 20:05:00', '2025-04-03 10:00:00', 13, 13),
-- ('HealthTech', 'HealthTech Innovations', '1213141516171819', '2025-01-14 21:10:00', '2025-04-03 10:05:00', 14, 14),
-- ('GreenTech', 'GreenTech Industries', '2829303132333435', '2025-01-30 13:30:00', '2025-04-03 11:25:00', 30, 30);

-- INSERT INTO opt_role (name, description) VALUES
-- ('Admin', 'Administrador do sistema com permissões totais.'),
-- ('User', 'Usuário comum com permissões limitadas.'),
-- ('Manager', 'Gerente responsável pela supervisão de equipes.'),
-- ('Developer', 'Desenvolvedor responsável pela criação de software.'),
-- ('Designer', 'Designer responsável pela criação de interfaces e layouts.'),
-- ('HR', 'Responsável pelo gerenciamento de recursos humanos.'),
-- ('Sales', 'Responsável pelas vendas e negociações com clientes.'),
-- ('Support', 'Responsável pelo suporte técnico aos clientes.'),
-- ('Marketing', 'Responsável pela criação e execução de campanhas de marketing.'),
-- ('Finance', 'Responsável pela gestão financeira da empresa.'),
-- ('Project Manager', 'Responsável pelo gerenciamento de projetos e prazos.'),
-- ('QA Engineer', 'Engenheiro de Qualidade responsável pelos testes de software.'),
-- ('Intern', 'Estagiário com acesso limitado e tarefas simples.'),
-- ('System Admin', 'Administrador do sistema de TI.'),
-- ('Chief Marketing Officer (CMO)', 'Responsável pelas estratégias de marketing e comunicação.');

-- INSERT INTO employee (name, gender, password, created_at, updated_at, fk_role, fk_contact, fk_company) VALUES
-- ('João Silva', 'male', 'password123', '2023-01-15 08:30:00', '2023-01-15 08:30:00', 1, 1, 1),
-- ('Maria Oliveira', 'female', 'password456', '2023-02-01 09:00:00', '2023-02-01 09:00:00', 2, 2, 1),
-- ('Carlos Pereira', 'male', 'password789', '2023-03-10 10:15:00', '2023-03-10 10:15:00', 3, 1, 2),
-- ('Ana Souza', 'female', 'password101112', '2023-04-20 11:20:00', '2023-04-20 11:20:00', 4, 2, 2),
-- ('Pedro Costa', 'male', 'password131415', '2023-05-05 12:00:00', '2023-05-05 12:00:00', 5, 1, 3),
-- ('Paula Santos', 'female', 'password161718', '2023-06-15 13:30:00', '2023-06-15 13:30:00', 6, 2, 3),
-- ('José Alves', 'male', 'password192021', '2023-07-22 14:45:00', '2023-07-22 14:45:00', 7, 1, 4),
-- ('Fernanda Lima', 'female', 'password222324', '2023-08-10 15:10:00', '2023-08-10 15:10:00', 8, 2, 4),
-- ('Ricardo Souza', 'male', 'password252627', '2023-09-05 16:30:00', '2023-09-05 16:30:00', 9, 1, 5),
-- ('Juliana Pereira', 'female', 'password282930', '2023-10-17 17:25:00', '2023-10-17 17:25:00', 10, 2, 5),
-- ('Rafael Costa', 'male', 'password313233', '2023-11-09 18:00:00', '2023-11-09 18:00:00', 1, 1, 6),
-- ('Larissa Oliveira', 'female', 'password343536', '2023-12-22 19:15:00', '2023-12-22 19:15:00', 2, 2, 6),
-- ('Lucas Almeida', 'male', 'password373839', '2024-01-12 08:00:00', '2024-01-12 08:00:00', 3, 1, 7),
-- ('Mariana Souza', 'female', 'password404142', '2024-02-20 09:40:00', '2024-02-20 09:40:00', 4, 2, 7),
-- ('Carla Costa', 'female', 'password888990', '2023-07-18 13:50:00', '2023-07-18 13:50:00', 10, 2, 15);

-- INSERT INTO server (motherboard_id, tag_name, type, instance_id, active, so, fk_city, fk_company, fk_country) VALUES
-- ('MB123456789', 'Server-A1', 'cloud', 'i-001', 1, 'windows', 1, 1, 1),
-- ('MB987654321', 'Server-A2', 'on-premise', 'i-002', 1, 'linux', 2, 1, 1),
-- ('MB111223344', 'Server-B1', 'cloud', 'i-003', 1, 'windows', 3, 2, 1),
-- ('MB223344556', 'Server-B2', 'on-premise', 'i-004', 1, 'linux', 4, 2, 1),
-- ('MB334455667', 'Server-C1', 'cloud', 'i-005', 0, 'windows', 5, 3, 2),
-- ('MB445566778', 'Server-C2', 'on-premise', 'i-006', 1, 'mcos', 6, 3, 2),
-- ('MB556677889', 'Server-D1', 'cloud', 'i-007', 1, 'linux', 7, 4, 2),
-- ('MB667788990', 'Server-D2', 'on-premise', 'i-008', 0, 'windows', 8, 4, 2),
-- ('MB778899001', 'Server-E1', 'cloud', 'i-009', 1, 'mcos', 9, 5, 3),
-- ('MB889900112', 'Server-E2', 'on-premise', 'i-010', 1, 'linux', 10, 5, 3),
-- ('MB990011223', 'Server-F1', 'cloud', 'i-011', 1, 'windows', 11, 6, 3),
-- ('MB123455667', 'Server-F2', 'on-premise', 'i-012', 1, 'linux', 12, 6, 3),
-- ('MB234566778', 'Server-G1', 'cloud', 'i-013', 1, 'windows', 13, 7, 4),
-- ('MB345677889', 'Server-G2', 'on-premise', 'i-014', 0, 'mcos', 14, 7, 4),
-- ('MB123455778', 'Server-O2', 'on-premise', 'i-030', 0, 'linux', 30, 15, 8);

-- INSERT INTO component (tag_name, type, fk_server) VALUES
-- ('Component-A1', 'CPU', 1),
-- ('Component-A2', 'RAM', 1),
-- ('Component-B1', 'Disk', 2),
-- ('Component-B2', 'Motherboard', 2),
-- ('Component-C1', 'Power Supply', 3),
-- ('Component-C2', 'RAM', 3),
-- ('Component-D1', 'Network Card', 4),
-- ('Component-D2', 'CPU', 4),
-- ('Component-E1', 'Hard Drive', 5),
-- ('Component-E2', 'GPU', 5),
-- ('Component-F1', 'Disk', 6),
-- ('Component-F2', 'RAM', 6),
-- ('Component-G1', 'Power Supply', 7),
-- ('Component-G2', 'CPU', 7),
-- ('Component-H1', 'Network Card', 8),
-- ('Component-H2', 'Motherboard', 8),
-- ('Component-O2', 'Motherboard', 15);

-- INSERT INTO metric (name, metric, max_limit, min_limit, total, fk_component) VALUES
-- ('Temp1', 'Celsius', 90, 10, 75, 1),
-- ('Temp2', 'Celsius', 90, 10, 80, 2),
-- ('Temp3', 'Celsius', 100, 20, 85, 3),
-- ('Temp4', 'Celsius', 100, 20, 90, 4),
-- ('Load1', 'Percentage', 100, 0, 50, 5),
-- ('Load2', 'Percentage', 100, 0, 60, 6),
-- ('Load3', 'Percentage', 100, 0, 55, 7),
-- ('Load4', 'Percentage', 100, 0, 65, 8),
-- ('Ram1', 'MB', 32000, 1000, 16000, 9),
-- ('Ram2', 'MB', 32000, 1000, 18000, 10),
-- ('Ram3', 'MB', 32000, 1000, 14000, 11),
-- ('Ram4', 'MB', 32000, 1000, 17000, 12),
-- ('Disk1', 'GB', 2000, 100, 1500, 13),
-- ('Disk2', 'GB', 2000, 100, 1600, 14),
-- ('Disk3', 'GB', 2000, 100, 1300, 15),
-- ('Network2', 'Mbps', 1000, 1, 600, 30);

--  INSERT INTO alert (fk_metric, current, date_time) VALUES
-- (1, 78, '2025-04-03 08:15:00'),
-- (2, 85, '2025-04-03 08:20:00'),
-- (3, 90, '2025-04-03 08:30:00'),
-- (4, 92, '2025-04-03 08:35:00'),
-- (5, 45, '2025-04-03 08:40:00'),
-- (6, 50, '2025-04-03 08:45:00'),
-- (7, 53, '2025-04-03 08:50:00'),
-- (8, 60, '2025-04-03 08:55:00'),
-- (9, 15000, '2025-04-03 09:00:00'),
-- (10, 17000, '2025-04-03 09:05:00'),
-- (11, 13000, '2025-04-03 09:10:00'),
-- (12, 16000, '2025-04-03 09:15:00'),
-- (13, 1400, '2025-04-03 09:20:00'),
-- (14, 1500, '2025-04-03 09:25:00'),
-- (15, 570, '2025-04-03 10:45:00');

-- INSERT INTO register (fk_metric, current, date_time) VALUES
-- (1, '78', '2025-04-03 08:15:00'),
-- (2, '85', '2025-04-03 08:20:00'),
-- (3, '90', '2025-04-03 08:30:00'),
-- (4, '92', '2025-04-03 08:35:00'),
-- (5, '45', '2025-04-03 08:40:00'),
-- (6, '50', '2025-04-03 08:45:00'),
-- (7, '53', '2025-04-03 08:50:00'),
-- (8, '60', '2025-04-03 08:55:00'),
-- (9, '15000', '2025-04-03 09:00:00'),
-- (10, '17000', '2025-04-03 09:05:00'),
-- (11, '13000', '2025-04-03 09:10:00'),
-- (12, '16000', '2025-04-03 09:15:00'),
-- (13, '1400', '2025-04-03 09:20:00'),
-- (14, '1500', '2025-04-03 09:25:00'),
-- (15, '570', '2025-04-03 10:45:00');

-- INSERT INTO connection (ip, city, date_time, fk_server) VALUES
-- ('192.168.0.1', 'São Paulo', '2025-04-03 10:15:00', 1),
-- ('192.168.0.2', 'Tokyo', '2025-04-03 11:25:00', 2),
-- ('192.168.0.3', 'New York', '2025-04-03 12:30:00', 3),
-- ('192.168.0.4', 'Beijing', '2025-04-03 13:40:00', 4),
-- ('192.168.0.5', 'Paris', '2025-04-03 14:50:00', 5),
-- ('192.168.1.1', 'São Paulo', '2025-04-03 15:00:00', 1),
-- ('192.168.1.2', 'Tokyo', '2025-04-03 16:10:00', 2),
-- ('192.168.1.3', 'Los Angeles', '2025-04-03 17:20:00', 3),
-- ('192.168.1.4', 'Shanghai', '2025-04-03 18:30:00', 4),
-- ('192.168.1.5', 'Lyon', '2025-04-03 19:40:00', 5),
-- ('192.168.2.1', 'Brasília', '2025-04-03 20:10:00', 1),
-- ('192.168.2.2', 'Osaka', '2025-04-03 21:20:00', 2),
-- ('192.168.2.3', 'Chicago', '2025-04-03 22:30:00', 3),
-- ('192.168.2.4', 'Guangzhou', '2025-04-03 23:40:00', 4),
-- ('192.168.5.5', 'Cannes', '2025-04-04 15:40:00', 5);

SELECT * FROM country;
-- SELECT * FROM contact;
-- SELECT * FROM company;
-- SELECT * FROM opt_role;
-- SELECT * FROM employee;
-- SELECT * FROM server;
-- SELECT * FROM component;
-- SELECT * FROM metric;
-- SELECT * FROM alert;
-- SELECT * FROM register;
-- SELECT * FROM connection;


