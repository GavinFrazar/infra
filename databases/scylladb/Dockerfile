FROM scylladb/scylla:5.4

COPY --chmod=600 build/certs/ /certs/
COPY --chmod=600 build/full-config.yaml /etc/scylla/scylla.yaml

RUN chown -R scylla:scylla \
    /certs \
    /etc/scylla/scylla.yaml

EXPOSE 9042
