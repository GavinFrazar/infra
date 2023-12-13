DB = mongodb-replicaset

# a corresponding entry in compose.tpl.yaml needs to exist for each node.
NODES = 1 2 3
NODES_CONF = $(addsuffix /mongod.conf, $(NODES_BUILD))
NODES_SCRIPTS = $(addsuffix /scripts, $(NODES_BUILD))
MONGO_ROOTCA_CERT := $(BUILD)/rootca/ca.crt

$(DB): $(NODES_CERTS) $(NODES_CONF) $(NODES_SCRIPTS) $(NODES_DOCKERFILE) ;

$(BUILD):
	@mkdir -p $@

$(NODES_BUILD): | $(BUILD)
	@mkdir -p $@

$(NODES_CERTS): PREFIX:=$(NODES_BUILD_PREFIX)
$(NODES_CERTS): NODE_NUM=$(patsubst $(PREFIX)%/certs,%,$@)
$(NODES_CERTS): NODE_NAME=mongodb-replicaset-node-$(NODE_NUM)
$(NODES_CERTS): SANS=$(HOST),$(NODE_NAME),localhost,127.0.0.1
$(NODES_CERTS): $(BUILD)/rootca | $(NODES_BUILD)
	@rm -rf $@
	@mkdir -p $@

	@openssl genrsa -quiet -out $@/server.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/server.key
	@openssl req \
		-quiet \
	 	-config ssl.conf \
	 	-subj "/CN=$(HOST)/O=MongoDB" \
	 	-key $@/server.key \
		-new -out $@/server.csr >/dev/null
	@SANS=$$(go run -C ../utils ./cmd/parse-sans -sans $(SANS)) \
		openssl x509 \
	 	-req \
	 	-in $@/server.csr \
	   	-CA $</ca.crt -CAkey $</ca.key \
	   	-CAcreateserial -days 365 \
	   	-out $@/server.crt \
	   	-extfile ssl.conf -extensions server_and_client_cert >/dev/null

	@openssl genrsa -quiet -out $@/admin.client.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/admin.client.key
	@openssl req \
	 	-quiet \
	 	-config ssl.conf \
	 	-subj "/CN=admin/O=MongoDB" \
	 	-key $@/admin.client.key \
	 	-new -out $@/admin.client.csr >/dev/null
	@openssl x509 \
	 	-req \
	 	-in $@/admin.client.csr \
	 	-CA $</ca.crt -CAkey $</ca.key \
	 	-CAcreateserial -days 365 \
	 	-out $@/admin.client.crt \
	 	-extfile ssl.conf -extensions client_cert >/dev/null

	@openssl genrsa -quiet -out $@/member.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/member.key
	@openssl req \
	 	-quiet \
	 	-config ssl.conf \
	 	-subj "/O=MongoDB" \
	 	-key $@/member.key \
	 	-new -out $@/member.csr >/dev/null
	@openssl x509 \
	 	-req \
	 	-in $@/member.csr \
	 	-CA $</ca.crt -CAkey $</ca.key \
	 	-CAcreateserial -days 365 \
	 	-out $@/member.crt \
	 	-extfile ssl.conf -extensions client_cert >/dev/null

	tctl auth sign \
	 	--format=mongodb \
	 	--overwrite \
	 	--host=$(SANS) \
	 	-o $@/out \
	 	--ttl=2190h

	@cat $@/admin.client.crt $@/admin.client.key > $@/adminCertKey.pem
	@cat $@/member.crt $@/member.key > $@/memberCertKey.pem
	@cat $@/server.crt $@/server.key > $@/serverCertKey.pem
	@cp $</ca.crt $@/ca.crt
	@cat $@/out.cas $</ca.crt > $@/bundle.cas

$(NODES_CONF): $(DB)/mongod-common.conf | $(NODES_BUILD)
	@cp $< $@

$(NODES_DOCKERFILE): $(DB)/Dockerfile | $(NODES_BUILD)
	@cp $< $@

$(NODES_SCRIPTS): $(addprefix $(DB)/scripts/,init.sh create_users.js) | $(NODES_BUILD)
	@rm -rf $@
	@mkdir -p $@
	@cp $^ $@


# override the default down action to shutdown all the nodes in the cluster,
# otherwise `make mongodb-replicaset-down` would only shutdown the mongodb-replicaset container,
# which is only used to configure the replicaset on init.
$(DB)-down: CONTAINERS:=mongodb-replicaset $(addprefix mongodb-replicaset-node-, $(NODES))
$(DB)-down:
	ssh $(SSH_HOST) $(COMPOSE_DOWN_CMD) $(CONTAINERS)

$(DB)-tsh-db-connect-flags := --db-user="alice" --db-name="admin" self-hosted-mongodb-replicaset
$(DB)-test-input := echo 'rs.status();'
