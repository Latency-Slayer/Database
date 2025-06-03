FROM mysql:8.0

COPY ./latency_slayer_db.sql /docker-entrypoint-initdb.d/
COPY ./backup.sql /docker-entrypoint-initdb.d/

ENV MYSQL_ROOT_PASSWORD=@Urubu100
ENV MYSQL_DATABASE=latency_slayer

EXPOSE 3306
