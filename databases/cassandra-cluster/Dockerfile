FROM cassandra:4

COPY --chmod=600 build/certs/ /certs/
COPY --chmod=600 build/full-config.yaml /etc/cassandra/cassandra.yaml
RUN chown -R cassandra:cassandra \
    /certs \
    /etc/cassandra/cassandra.yaml

EXPOSE 9042
