SELECT game, COUNT(*) AS total_connections, DATE_FORMAT(date_time, '%Y-%m-%d') AS date
FROM connection_capturing
         JOIN server ON id_server = fk_server
         JOIN company ON company.id_company = server.fk_company
WHERE company.registration_number = '00000000000000'
  AND (MONTH(connection_capturing.date_time) >= 2 AND
       MONTH(connection_capturing.date_time) <= 5)
GROUP BY DATE_FORMAT(date_time, '%Y-%m-%d'), game
ORDER BY DATE_FORMAT(date_time, '%Y-%m-%d');

