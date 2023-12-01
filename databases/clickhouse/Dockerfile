FROM clickhouse/clickhouse-server:latest

COPY --chmod=600 build/certs/ /certs/
COPY --chmod=600 users.xml config.xml /etc/clickhouse-server/
RUN chown -R clickhouse:clickhouse \
    /certs \
    /etc/clickhouse-server/users.xml \
    /etc/clickhouse-server/config.xml

# http and native api ports
EXPOSE 8123 9000
# https and native ssl ports
EXPOSE 8443 9440
