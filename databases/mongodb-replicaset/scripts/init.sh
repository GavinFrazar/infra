#!/usr/bin/env bash
set -e

HOST1=$HOST:27021
HOST2=$HOST:27022
HOST3=$HOST:27023
HOSTS="${HOST1},${HOST2},${HOST3}"
# We have to create users on the primary.
# This conn string will connect to the replicaset we created.
CONN="mongodb://$HOSTS/?replicaSet=myReplicaSet"

mongosh --host "$HOST1" \
      --tls \
      --tlsCertificateKeyFile /certs/adminCertKey.pem \
      --tlsCAFile /certs/ca.crt \
      --eval "
    try {
        rs.initiate({
            _id: \"myReplicaSet\",
            members: [
                { _id: 0, host: \"$HOST1\" },
                { _id: 1, host: \"$HOST2\" },
                { _id: 2, host: \"$HOST3\" },
            ]
        });
    } catch (e) {
        print(e)
    }
"

mongosh \
    --tls \
    --tlsCertificateKeyFile /certs/adminCertKey.pem \
    --tlsCAFile /certs/ca.crt \
    "$CONN" /scripts/create_users.js
