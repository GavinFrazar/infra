FROM cockroachdb/cockroach:latest

COPY --chmod=600 build/certs/out /certs/out

# TODO(gavin): we need to make tctl auth sign output these.
# it also won't work after a rotation and db ca != db client ca.
COPY --chmod=600 build/certs/out/ca.crt /certs/out/ca-client.crt
COPY --chmod=600 build/certs/out/node.crt /certs/out/client.node.crt
COPY --chmod=600 build/certs/out/node.key /certs/out/client.node.key

# root won't be able to connect unless we provide a client.root.[crt|key].
# therefore, we create a custom client ca using `cockroach cert create-client-ca`.
# that command with --overwrite will prepend the custom client ca to client-ca.crt.
# this way, root can auth and init will succeed.
RUN mkdir -p /cas
RUN /cockroach/cockroach cert create-client-ca \
    --certs-dir=/certs/out \
    --ca-key=/cas/client-ca.key \
    --overwrite

RUN /cockroach/cockroach cert create-client root \
    --certs-dir=/certs/out \
    --ca-key=/cas/client-ca.key

EXPOSE 26257

CMD [ "start-single-node", "--certs-dir=/certs/out" ]
