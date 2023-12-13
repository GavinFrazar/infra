# Use the official MySQL image as the base image
FROM mariadb:11

COPY --chmod=400 build/certs/ /certs/
COPY --chmod=400 my.cnf /etc/mysql/conf.d/my.cnf
COPY --chmod=400 init /docker-entrypoint-initdb.d
RUN chown -R mysql:mysql \
    /certs \
    /etc/mysql/conf.d/my.cnf \
    /docker-entrypoint-initdb.d

# Expose MariaDB on 3307 since MySQL is using 3306 port
EXPOSE 3307
