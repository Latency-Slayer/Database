DELIMITER $$

DROP PROCEDURE IF EXISTS simular_connection_capturing_avancado$$

CREATE PROCEDURE simular_connection_capturing_avancado(IN inicio DATETIME, IN fim DATETIME)
BEGIN
    DECLARE t DATETIME DEFAULT inicio;
    DECLARE hora INT;
    DECLARE dia INT;
    DECLARE jogadores INT;
    DECLARE i INT;
    DECLARE servidor_atual INT;
    DECLARE ip VARCHAR(15);
    DECLARE lat DECIMAL(9,6);
    DECLARE lon DECIMAL(9,6);
    DECLARE pais VARCHAR(45);
    DECLARE continente CHAR(2);
    DECLARE crescimento FLOAT DEFAULT 1.0;
    DECLARE tem_alerta INT DEFAULT 0;
    DECLARE reducao_por_alerta FLOAT DEFAULT 1.0;
    DECLARE continente_escolhido INT;
    DECLARE pais_escolhido INT;
    DECLARE dias_passados INT;
    DECLARE fator_tempo FLOAT DEFAULT 1.0;
    DECLARE multiplicador_jogo FLOAT DEFAULT 1.0;
    DECLARE eh_feriado_br BOOLEAN DEFAULT FALSE;
    DECLARE eh_feriado_us BOOLEAN DEFAULT FALSE;
    DECLARE eh_feriado_jp BOOLEAN DEFAULT FALSE;
    DECLARE eh_feriado_eu BOOLEAN DEFAULT FALSE;
    DECLARE multiplicador_feriado FLOAT DEFAULT 1.0;
    DECLARE mes_atual INT;
    DECLARE dia_mes INT;
    DECLARE dia_semana_num INT;
    DECLARE multiplicador_continente FLOAT DEFAULT 1.0;

    WHILE t < fim DO
        SET hora = HOUR(t);
        SET dia = WEEKDAY(t); -- 0=Segunda, 6=Domingo
        SET dias_passados = DATEDIFF(t, inicio);
        SET mes_atual = MONTH(t);
        SET dia_mes = DAY(t);
        SET dia_semana_num = DAYOFWEEK(t); -- 1=Domingo, 7=Sábado

        -- Crescimento gradual ao longo do tempo (base mais realista)
        SET crescimento = 1.0 + (dias_passados / 120.0) * 0.8;

        -- Verificar feriados brasileiros
        SET eh_feriado_br = (
            (mes_atual = 1 AND dia_mes = 1) OR -- Ano Novo
            (mes_atual = 2 AND dia_mes BETWEEN 12 AND 13) OR -- Carnaval (aprox)
            (mes_atual = 4 AND dia_mes BETWEEN 7 AND 9) OR -- Páscoa (aprox)
            (mes_atual = 4 AND dia_mes = 21) OR -- Tiradentes
            (mes_atual = 6 AND dia_mes BETWEEN 12 AND 24) OR -- Festa Junina
            (mes_atual = 9 AND dia_mes = 7) OR -- Independência
            (mes_atual = 10 AND dia_mes = 12) OR -- Nossa Senhora Aparecida
            (mes_atual = 11 AND dia_mes = 2) OR -- Finados
            (mes_atual = 11 AND dia_mes = 15) OR -- Proclamação da República
            (mes_atual = 12 AND dia_mes = 25) OR -- Natal
            (mes_atual = 12 AND dia_mes = 31) -- Véspera de Ano Novo
        );

        -- Verificar feriados americanos
        SET eh_feriado_us = (
            (mes_atual = 1 AND dia_mes = 1) OR -- New Year
            (mes_atual = 7 AND dia_mes = 4) OR -- Independence Day
            (mes_atual = 11 AND dia_mes BETWEEN 22 AND 28 AND dia_semana_num = 5) OR -- Thanksgiving
            (mes_atual = 12 AND dia_mes = 25) OR -- Christmas
            (mes_atual = 12 AND dia_mes = 31) -- New Year's Eve
        );

        -- Verificar feriados japoneses (Golden Week)
        SET eh_feriado_jp = (
            (mes_atual = 1 AND dia_mes BETWEEN 1 AND 3) OR -- New Year
            (mes_atual = 5 AND dia_mes BETWEEN 3 AND 5) OR -- Golden Week
            (mes_atual = 8 AND dia_mes BETWEEN 13 AND 16) OR -- Obon
            (mes_atual = 12 AND dia_mes BETWEEN 29 AND 31) -- Year End
        );

        -- Verificar feriados europeus
        SET eh_feriado_eu = (
            (mes_atual = 1 AND dia_mes = 1) OR -- New Year
            (mes_atual = 4 AND dia_mes BETWEEN 7 AND 9) OR -- Easter
            (mes_atual = 12 AND dia_mes BETWEEN 24 AND 26) OR -- Christmas
            (mes_atual = 12 AND dia_mes = 31) -- New Year's Eve
        );

        -- Loop através dos servidores (1 a 6)
        SET servidor_atual = 1;
        WHILE servidor_atual <= 6 DO

            -- Verificar se há alertas ativos para este servidor no horário atual
SELECT COUNT(*) INTO tem_alerta
FROM alert a
         JOIN metric m ON a.fk_Metric = m.id_metric
         JOIN component c ON m.fk_component = c.id_component
WHERE c.fk_server = servidor_atual
  AND a.dateAlert <= t
  AND a.dateAlert >= DATE_SUB(t, INTERVAL 3 HOUR)
  AND a.status IN ('aberto', 'acompanhamento');

-- Se há alerta, reduzir drasticamente os jogadores (mais forte correlação)
IF tem_alerta > 0 THEN
                SET reducao_por_alerta = 0.05 + RAND() * 0.15; -- Redução de 80-95%
ELSE
                SET reducao_por_alerta = 1.0;
END IF;

            -- Comportamentos específicos por jogo baseado na popularidade real
CASE servidor_atual
                -- Rainbow Six Siege (Servidor 6) - Mais popular, competitivo, estável durante semana
                WHEN 6 THEN
                    SET fator_tempo = 1.0 + (dias_passados / 45.0) * 0.4; -- Crescimento constante
                    SET multiplicador_jogo = 3.2; -- Mais popular
                    -- Jogadores base mais altos durante a semana (treino/competitivo)
                    IF dia BETWEEN 0 AND 4 THEN -- Segunda a Sexta
                        SET jogadores = FLOOR((200 + RAND() * 300) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);
ELSE
                        SET jogadores = FLOOR((180 + RAND() * 250) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);
END IF;

                -- Assassin's Creed (Servidor 2) - Segunda mais popular, crescimento gradual
WHEN 2 THEN
                    SET fator_tempo = 1.0 + (dias_passados / 60.0) * 0.3;
                    SET multiplicador_jogo = 2.1;
                    SET jogadores = FLOOR((100 + RAND() * 180) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);

                -- Far Cry 5 (Servidor 1) - Terceira posição, estável
WHEN 1 THEN
                    SET fator_tempo = 1.0 + (dias_passados / 80.0) * 0.2;
                    SET multiplicador_jogo = 1.6;
                    SET jogadores = FLOOR((80 + RAND() * 140) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);

                -- Watch Dogs 2 (Servidor 4) - Queda expressiva após 45 dias
WHEN 4 THEN
                    IF dias_passados <= 30 THEN
                        -- Primeiros 30 dias: muito alto (hype inicial)
                        SET fator_tempo = 2.2 - (dias_passados / 30.0) * 0.4;
                    ELSEIF dias_passados <= 45 THEN
                        -- 30-45 dias: queda acentuada
                        SET fator_tempo = 1.8 - ((dias_passados - 30) / 15.0) * 1.0;
                    ELSEIF dias_passados <= 90 THEN
                        -- 45-90 dias: queda gradual
                        SET fator_tempo = 0.8 - ((dias_passados - 45) / 45.0) * 0.4;
ELSE
                        -- Após 90 dias: estabilização baixa
                        SET fator_tempo = 0.4 + (SIN(dias_passados / 20.0) * 0.1);
                        IF fator_tempo < 0.2 THEN SET fator_tempo = 0.2; END IF;
END IF;
                    SET multiplicador_jogo = 1.4;
                    SET jogadores = FLOOR((90 + RAND() * 160) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);

                -- Star Wars Outlaws (Servidor 5) - Subida expressiva após período inicial
WHEN 5 THEN
                    IF dias_passados <= 30 THEN
                        -- Início modesto
                        SET fator_tempo = 0.8 + (dias_passados / 30.0) * 0.4;
                    ELSEIF dias_passados <= 75 THEN
                        -- Subida expressiva (updates, eventos)
                        SET fator_tempo = 1.2 + ((dias_passados - 30) / 45.0) * 0.8;
ELSE
                        -- Estabilização alta
                        SET fator_tempo = 2.0 + (SIN(dias_passados / 25.0) * 0.2);
END IF;
                    SET multiplicador_jogo = 1.3;
                    SET jogadores = FLOOR((70 + RAND() * 120) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);

                -- Skull and Bones (Servidor 3) - Menos popular, mais estável
WHEN 3 THEN
                    SET fator_tempo = 1.0 + (SIN(dias_passados / 40.0) * 0.15);
                    SET multiplicador_jogo = 0.7;
                    SET jogadores = FLOOR((40 + RAND() * 80) * crescimento * fator_tempo * multiplicador_jogo * reducao_por_alerta);
END CASE;

            -- Horário de pico (18h às 23h) - ajustado por jogo
            IF hora BETWEEN 18 AND 23 THEN
                CASE servidor_atual
                    WHEN 6 THEN -- Rainbow Six: pico forte mas controlado (competitivo)
                        SET jogadores = jogadores + FLOOR(RAND() * 2800 * reducao_por_alerta);
WHEN 2 THEN -- Assassin's Creed: pico gradual
                        SET jogadores = jogadores + FLOOR(RAND() * 1800 * reducao_por_alerta);
WHEN 1 THEN -- Far Cry: pico moderado
                        SET jogadores = jogadores + FLOOR(RAND() * 1400 * reducao_por_alerta);
WHEN 4 THEN -- Watch Dogs: pico varia com fase do jogo
                        IF dias_passados > 90 THEN
                            SET jogadores = jogadores + FLOOR(RAND() * 600 * fator_tempo * reducao_por_alerta);
ELSE
                            SET jogadores = jogadores + FLOOR(RAND() * 2000 * fator_tempo * reducao_por_alerta);
END IF;
WHEN 5 THEN -- Star Wars: pico varia com crescimento
                        SET jogadores = jogadores + FLOOR(RAND() * 1200 * fator_tempo * reducao_por_alerta);
ELSE -- Skull and Bones: pico pequeno
                        SET jogadores = jogadores + FLOOR(RAND() * 800 * reducao_por_alerta);
END CASE;
END IF;

            -- Final de semana (Sábado=5, Domingo=6) - comportamentos diferentes
            IF dia IN (5, 6) THEN
                CASE servidor_atual
                    WHEN 6 THEN -- Rainbow Six: pico brusco no sábado, gradual no domingo
                        IF dia = 5 THEN -- Sábado
                            SET jogadores = jogadores + FLOOR(RAND() * 3500 * reducao_por_alerta);
ELSE -- Domingo
                            SET jogadores = jogadores + FLOOR(RAND() * 2200 * reducao_por_alerta);
END IF;
WHEN 2 THEN -- Assassin's Creed: pico gradual ambos os dias
                        SET jogadores = jogadores + FLOOR(RAND() * 1600 * reducao_por_alerta);
WHEN 1 THEN -- Far Cry: pico moderado
                        SET jogadores = jogadores + FLOOR(RAND() * 1200 * reducao_por_alerta);
WHEN 4 THEN -- Watch Dogs: varia com fase
                        IF dias_passados > 90 THEN
                            SET jogadores = jogadores + FLOOR(RAND() * 400 * fator_tempo * reducao_por_alerta);
ELSE
                            SET jogadores = jogadores + FLOOR(RAND() * 1800 * fator_tempo * reducao_por_alerta);
END IF;
WHEN 5 THEN -- Star Wars: pico gradual crescente
                        SET jogadores = jogadores + FLOOR(RAND() * 1000 * fator_tempo * reducao_por_alerta);
ELSE -- Skull and Bones: pico pequeno
                        SET jogadores = jogadores + FLOOR(RAND() * 600 * reducao_por_alerta);
END CASE;
END IF;

            -- Garantir valor mínimo realista por jogo
CASE servidor_atual
                WHEN 6 THEN IF jogadores < 150 THEN SET jogadores = 150 + FLOOR(RAND() * 100); END IF;
WHEN 2 THEN IF jogadores < 80 THEN SET jogadores = 80 + FLOOR(RAND() * 70); END IF;
WHEN 1 THEN IF jogadores < 60 THEN SET jogadores = 60 + FLOOR(RAND() * 50); END IF;
WHEN 4 THEN
                    IF dias_passados > 90 THEN
                        IF jogadores < 10 THEN SET jogadores = 10 + FLOOR(RAND() * 20); END IF;
ELSE
                        IF jogadores < 40 THEN SET jogadores = 40 + FLOOR(RAND() * 60); END IF;
END IF;
WHEN 5 THEN
                    IF dias_passados <= 30 THEN
                        IF jogadores < 30 THEN SET jogadores = 30 + FLOOR(RAND() * 40); END IF;
ELSE
                        IF jogadores < 50 THEN SET jogadores = 50 + FLOOR(RAND() * 70); END IF;
END IF;
WHEN 3 THEN IF jogadores < 20 THEN SET jogadores = 20 + FLOOR(RAND() * 30); END IF;
END CASE;

            SET jogadores = FLOOR(jogadores);

            -- Inserir conexões para este servidor
            SET i = 0;
            WHILE i < jogadores DO
                -- Gerar IP aleatório
                SET ip = CONCAT(
                    FLOOR(1 + RAND() * 223), '.',
                    FLOOR(RAND() * 256), '.',
                    FLOOR(RAND() * 256), '.',
                    FLOOR(1 + RAND() * 254)
                );

                -- Escolher continente com distribuição mais realista
                SET continente_escolhido = FLOOR(RAND() * 100);
                SET multiplicador_feriado = 1.0;

CASE
                    -- América do Sul (25% - maior concentração Brasil)
                    WHEN continente_escolhido < 25 THEN
                        SET pais_escolhido = FLOOR(RAND() * 3);
CASE pais_escolhido
                            WHEN 0 THEN
                                SET pais = 'Brasil';
                                SET lat = -30.0 + RAND() * 35.0;
                                SET lon = -74.0 + RAND() * 40.0;
                                SET continente = 'SA';
                                IF eh_feriado_br THEN SET multiplicador_feriado = 1.8; END IF;
WHEN 1 THEN
                                SET pais = 'Argentina';
                                SET lat = -55.0 + RAND() * 33.0;
                                SET lon = -73.0 + RAND() * 20.0;
                                SET continente = 'SA';
                                IF eh_feriado_br THEN SET multiplicador_feriado = 1.4; END IF;
WHEN 2 THEN
                                SET pais = 'Chile';
                                SET lat = -56.0 + RAND() * 39.0;
                                SET lon = -76.0 + RAND() * 8.0;
                                SET continente = 'SA';
                                IF eh_feriado_br THEN SET multiplicador_feriado = 1.3; END IF;
END CASE;

                    -- América do Norte (30%)
WHEN continente_escolhido < 55 THEN
                        SET pais_escolhido = FLOOR(RAND() * 3);
CASE pais_escolhido
                            WHEN 0 THEN
                                SET pais = 'Estados Unidos';
                                SET lat = 25.0 + RAND() * 24.0;
                                SET lon = -125.0 + RAND() * 58.0;
                                SET continente = 'NA';
                                IF eh_feriado_us THEN SET multiplicador_feriado = 2.0; END IF;
WHEN 1 THEN
                                SET pais = 'Canadá';
                                SET lat = 42.0 + RAND() * 41.0;
                                SET lon = -141.0 + RAND() * 89.0;
                                SET continente = 'NA';
                                IF eh_feriado_us THEN SET multiplicador_feriado = 1.6; END IF;
WHEN 2 THEN
                                SET pais = 'México';
                                SET lat = 14.5 + RAND() * 18.0;
                                SET lon = -117.0 + RAND() * 31.0;
                                SET continente = 'NA';
                                IF eh_feriado_us THEN SET multiplicador_feriado = 1.4; END IF;
END CASE;

                    -- Europa (25%)
WHEN continente_escolhido < 80 THEN
                        SET pais_escolhido = FLOOR(RAND() * 4);
CASE pais_escolhido
                            WHEN 0 THEN
                                SET pais = 'Alemanha';
                                SET lat = 47.3 + RAND() * 7.9;
                                SET lon = 5.9 + RAND() * 10.2;
                                SET continente = 'EU';
WHEN 1 THEN
                                SET pais = 'França';
                                SET lat = 41.3 + RAND() * 10.0;
                                SET lon = -5.1 + RAND() * 13.7;
                                SET continente = 'EU';
WHEN 2 THEN
                                SET pais = 'Reino Unido';
                                SET lat = 49.9 + RAND() * 10.8;
                                SET lon = -8.2 + RAND() * 9.9;
                                SET continente = 'EU';
WHEN 3 THEN
                                SET pais = 'Espanha';
                                SET lat = 35.2 + RAND() * 8.5;
                                SET lon = -9.3 + RAND() * 13.8;
                                SET continente = 'EU';
END CASE;
                        IF eh_feriado_eu THEN SET multiplicador_feriado = 1.7; END IF;

                    -- Ásia (15%)
WHEN continente_escolhido < 95 THEN
                        SET pais_escolhido = FLOOR(RAND() * 4);
CASE pais_escolhido
                            WHEN 0 THEN
                                SET pais = 'Japão';
                                SET lat = 24.4 + RAND() * 21.5;
                                SET lon = 123.0 + RAND() * 22.9;
                                SET continente = 'AS';
                                IF eh_feriado_jp THEN SET multiplicador_feriado = 2.2; END IF;
WHEN 1 THEN
                                SET pais = 'China';
                                SET lat = 18.2 + RAND() * 35.4;
                                SET lon = 73.7 + RAND() * 60.9;
                                SET continente = 'AS';
                                IF eh_feriado_jp THEN SET multiplicador_feriado = 1.5; END IF;
WHEN 2 THEN
                                SET pais = 'Coreia do Sul';
                                SET lat = 33.1 + RAND() * 5.2;
                                SET lon = 124.6 + RAND() * 5.7;
                                SET continente = 'AS';
                                IF eh_feriado_jp THEN SET multiplicador_feriado = 1.8; END IF;
WHEN 3 THEN
                                SET pais = 'Índia';
                                SET lat = 6.8 + RAND() * 30.5;
                                SET lon = 68.2 + RAND() * 29.4;
                                SET continente = 'AS';
                                IF eh_feriado_jp THEN SET multiplicador_feriado = 1.3; END IF;
END CASE;

                    -- África e Oceania (5%)
ELSE
                        SET pais_escolhido = FLOOR(RAND() * 3);
CASE pais_escolhido
                            WHEN 0 THEN
                                SET pais = 'África do Sul';
                                SET lat = -35.0 + RAND() * 13.0;
                                SET lon = 16.5 + RAND() * 16.0;
                                SET continente = 'AF';
WHEN 1 THEN
                                SET pais = 'Austrália';
                                SET lat = -44.0 + RAND() * 34.0;
                                SET lon = 113.0 + RAND() * 40.0;
                                SET continente = 'OC';
WHEN 2 THEN
                                SET pais = 'Nova Zelândia';
                                SET lat = -47.3 + RAND() * 12.8;
                                SET lon = 166.4 + RAND() * 12.4;
                                SET continente = 'OC';
END CASE;
                        IF eh_feriado_eu THEN SET multiplicador_feriado = 1.4; END IF;
END CASE;

                -- Aplicar multiplicador de feriado apenas se não há alerta
                IF multiplicador_feriado > 1.0 AND reducao_por_alerta = 1.0 THEN
                    -- Chance de ser um jogador adicional por feriado
                    IF RAND() < (multiplicador_feriado - 1.0) THEN
                        -- Inserir conexão adicional
                        INSERT INTO connection_capturing (
                            ip_player, longitude, latitude, country, continent_code, fk_server, date_time
                        )
                        VALUES (
                            ip, lon, lat, pais, continente, servidor_atual, t
                        );
END IF;
END IF;

                -- Inserir conexão principal
INSERT INTO connection_capturing (
    ip_player, longitude, latitude, country, continent_code, fk_server, date_time
)
VALUES (
           ip, lon, lat, pais, continente, servidor_atual, t
       );

SET i = i + 1;
END WHILE;

            SET servidor_atual = servidor_atual + 1;
END WHILE;

        SET t = t + INTERVAL 1 DAY;
END WHILE;
END$$

DELIMITER ;

-- Primeiro, vamos diversificar os alertas (incluir meio de semana e feriados)
-- Deletar alertas existentes para recriar com distribuição melhor
DELETE FROM alert WHERE dateAlert >= '2025-02-01';

-- Inserir alertas com distribuição mais realista
INSERT INTO alert (status, dateAlert, mensage, exceeded_limit, valor, fk_Metric, nivel)
VALUES
-- Fevereiro - Carnaval (terça-feira)
('resolvido', '2025-02-13 15:23:15', 'CPU usage exceeded maximum limit', 85, 92.5, 5, 'critico'),
('resolvido', '2025-02-13 18:45:32', 'RAM usage exceeded maximum limit', 90, 94.2, 32, 'critico'),

-- Março - meio de semana
('resolvido', '2025-03-05 11:15:28', 'CPU usage exceeded maximum limit', 80, 87.3, 8, 'alto'),
('resolvido', '2025-03-08 22:30:45', 'RAM usage exceeded maximum limit', 85, 89.7, 13, 'alto'), -- Sábado
('resolvido', '2025-03-12 14:12:18', 'CPU usage exceeded maximum limit', 80, 91.8, 19, 'critico'), -- Quarta

-- Março - final de semana
('resolvido', '2025-03-15 19:45:23', 'RAM usage exceeded maximum limit', 80, 85.6, 21, 'alto'), -- Sábado
('resolvido', '2025-03-23 16:22:41', 'CPU usage exceeded maximum limit', 75, 82.1, 25, 'alto'), -- Domingo

-- Abril - Páscoa e meio de semana
('resolvido', '2025-04-08 10:33:17', 'CPU usage exceeded maximum limit', 80, 88.9, 42, 'alto'), -- Terça (pós-Páscoa)
('resolvido', '2025-04-15 08:18:52', 'RAM usage exceeded maximum limit', 80, 91.4, 1, 'critico'), -- Terça
('resolvido', '2025-04-19 20:07:36', 'CPU usage exceeded maximum limit', 85, 93.2, 14, 'critico'), -- Sábado
('resolvido', '2025-04-21 13:28:44', 'CPU usage exceeded maximum limit', 80, 86.7, 17, 'alto'), -- Segunda (Tiradentes)

-- Maio - meio de semana e final de semana
('resolvido', '2025-05-07 09:55:19', 'RAM usage exceeded maximum limit', 75, 81.3, 29, 'alto'), -- Quarta
('resolvido', '2025-05-10 17:42:31', 'CPU usage exceeded maximum limit', 75, 78.9, 27, 'medio'), -- Sábado
('resolvido', '2025-05-14 21:14:28', 'RAM usage exceeded maximum limit', 85, 88.5, 7, 'alto'), -- Quarta
('resolvido', '2025-05-18 12:39:15', 'CPU usage exceeded maximum limit', 80, 84.2, 23, 'alto'), -- Domingo
('resolvido', '2025-05-22 16:16:37', 'RAM usage exceeded maximum limit', 80, 87.1, 32, 'alto'), -- Quinta
('resolvido', '2025-05-25 19:43:22', 'CPU usage exceeded maximum limit', 85, 90.6, 5, 'critico'), -- Domingo
('resolvido', '2025-05-28 11:52:48', 'CPU usage exceeded maximum limit', 80, 83.9, 34, 'alto'); -- Quarta

-- Executar a simulação
CALL simular_connection_capturing_avancado(
    '2025-02-01 00:00:00',
    '2025-05-31 00:00:00'
);

DROP PROCEDURE simular_connection_capturing_avancado;