USE python;
CREATE DATABASE python;
DROP DATABASE python;

CREATE TABLE endereco (
    idEndereco INT PRIMARY KEY AUTO_INCREMENT,
    cep CHAR(11),
    numero INT,
    rua VARCHAR(100)
);

CREATE TABLE empresa (
    idEmpresa INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45),
    codigo CHAR(9),
    empresaMatriz INT,
    fkEndereco INT,
    FOREIGN KEY (empresaMatriz) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (fkEndereco) REFERENCES endereco(idEndereco)
);

insert into endereco values (1, 01010101010, 123, 'rua jacinto aki no rego');
insert into empresa values (1, 'GamesTech', '123cdw3a', null, 1);
insert into usuarios values (4, 'email@gmail.com', 'jaca123', '49852859462', 'analista', 'Joãozinho', DEFAULT, 1);
insert into usuarios values (2, 'email@gmail.com', 'jaca123', '49852859832', null, 'Clarinha', DEFAULT, 1);
select * from usuarios;
CREATE TABLE centro_servidores (
    idServidores INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45),
    fkEmpresa INT,
    fkEndereco INT,
    FOREIGN KEY (fkEmpresa) REFERENCES empresa(idEmpresa),
    FOREIGN KEY (fkEndereco) REFERENCES endereco(idEndereco)
);

select idUsuarios, u.nome, u.cargo, dataRegistro, e.nome as empresa_nome from usuarios as u join empresa as e on fkEmpresa  = idEmpresa where u.nome like 'Jo%';

CREATE TABLE usuarios (
    idUsuarios INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(45),
    senha VARCHAR(45),
    cpf CHAR(11) unique,
    cargo VARCHAR(45),
    nome VARCHAR(45),
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fkEmpresa INT,
    FOREIGN KEY (fkEmpresa) REFERENCES empresa(idEmpresa)
);

UPDATE usuarios set cargo ;


CREATE TABLE maquina_servidor (
    codigoMaquina INT PRIMARY KEY AUTO_INCREMENT,
    fkCentroServidor INT,
    modeloRam VARCHAR(45),
    modeloCpu VARCHAR(45),
    modeloDisk VARCHAR(45),
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fkCentroServidor) REFERENCES centro_servidores(idServidores)
);

CREATE TABLE componentes (
    idComponentes INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(45),
    medida VARCHAR(45)
);

CREATE TABLE maquina_componentes (
    idLeitura INT PRIMARY KEY AUTO_INCREMENT,
    fkMaquina INT,
    fkComponentes INT,
    metricaAlerta INT,
    FOREIGN KEY (fkMaquina) REFERENCES maquina_servidor(codigoMaquina),
    FOREIGN KEY (fkComponentes) REFERENCES componentes(idComponentes)
);

CREATE TABLE alerta (
    idAlerta INT PRIMARY KEY AUTO_INCREMENT,
    dataAlerta DATETIME,
    fkMaquinaComponente INT,
    fkMaquina INT,
    fkComponente INT,
    FOREIGN KEY (fkMaquinaComponente) REFERENCES maquina_componentes(idLeitura),
    FOREIGN KEY (fkMaquina) REFERENCES maquina_servidor(codigoMaquina),
    FOREIGN KEY (fkComponente) REFERENCES componentes(idComponentes)
);