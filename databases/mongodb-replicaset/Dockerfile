FROM mongo:latest

COPY --chmod=400 certs/ /certs
COPY --chmod=400 mongod.conf /etc/mongo/mongod.conf
COPY --chmod=770 scripts /scripts
RUN chown -R mongodb:mongodb \
    /certs \
    /etc/mongo/mongod.conf \
    /scripts
