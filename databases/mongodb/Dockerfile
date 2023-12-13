FROM mongo:5

COPY --chmod=400 build/certs/ /certs
COPY --chmod=400 mongod.conf /etc/mongo/mongod.conf
COPY --chmod=400 init /docker-entrypoint-initdb.d
RUN chown -R mongodb:mongodb \
    /certs \
    /etc/mongo/mongod.conf \
    /docker-entrypoint-initdb.d

CMD [ "--config", "/etc/mongo/mongod.conf" ]
