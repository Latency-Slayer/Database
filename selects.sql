SELECT
    DATE_FORMAT(date_time, '%Y-%m-%d %H:00:00') AS horario,
    COUNT(*) AS total_conexoes
FROM
    connection_capturing
        JOIN server ON id_server = fk_server
        JOIN company ON id_company = fk_company
WHERE
    company.registration_number = ''
  AND (MONTH(connection_capturing.date_time) >= 2 AND
       MONTH(connection_capturing.date_time) <= 5)
GROUP BY horario
ORDER BY total_conexoes DESC
LIMIT 1;

