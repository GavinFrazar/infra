FROM cockroachdb/cockroach:v23.1.13

COPY --chmod=600 build/certs/out /certs/out

# root won't be able to connect unless we provide a client.root.[crt|key].
# therefore, we create a custom client ca using `cockroach cert create-client-ca`.
# that command with --overwrite will prepend the custom client ca to client-ca.crt.
# this way, root can auth and init will succeed.
RUN /cockroach/cockroach cert create-client-ca \
    --certs-dir=/certs/out \
    --ca-key=/certs/out/client-ca.key \
    --overwrite

# make client.root.[crt|key]
RUN /cockroach/cockroach cert create-client root \
    --certs-dir=/certs/out \
    --ca-key=/certs/out/client-ca.key

# make client.node.[crt|key]
RUN /cockroach/cockroach cert create-client node \
    --certs-dir=/certs/out \
    --ca-key=/certs/out/client-ca.key

EXPOSE 26257

CMD [ "start-single-node", "--certs-dir=/certs/out" ]
