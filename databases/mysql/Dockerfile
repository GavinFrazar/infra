# Use the official MySQL image as the base image
FROM mysql:8

COPY --chmod=400 build/certs/ /certs/
COPY --chmod=400 my.cnf /etc/mysql/conf.d/my.cnf
COPY --chmod=400 init /docker-entrypoint-initdb.d
RUN chown -R mysql:mysql \
    /certs \
    /etc/mysql/conf.d/my.cnf \
    /docker-entrypoint-initdb.d

# Expose the MySQL port
EXPOSE 3306

CMD [ "--default-authentication-plugin=mysql_native_password" ]
