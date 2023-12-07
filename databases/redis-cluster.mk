DB = redis-cluster

# a corresponding entry in compose.tpl.yaml needs to exist for each node.
NODES := 1 2 3 4 5 6
NODES_BUILD_PREFIX := $(BUILD)/node-
NODES_BUILD := $(addprefix $(NODES_BUILD_PREFIX), $(NODES))
NODES_CERTS := $(addsuffix /certs, $(NODES_BUILD))
NODES_CONF := $(addsuffix /redis.conf, $(NODES_BUILD))
NODES_DOCKERFILE := $(addsuffix /Dockerfile, $(NODES_BUILD))
NODES_USERS := $(addsuffix /users.acl, $(NODES_BUILD))

$(DB): $(NODES_CERTS) $(NODES_CONF) $(NODES_DOCKERFILE) $(NODES_USERS);

$(BUILD):
	@mkdir -p $@

$(NODES_BUILD): | $(BUILD)
	@mkdir -p $@

REDIS_ROOTCA_CERT := $(BUILD)/rootca/ca.crt
KEYLEN := 2048

$(BUILD)/rootca: | $(BUILD)
	@mkdir -p $@
	openssl genrsa -out $@/ca.key $(KEYLEN)
	@chmod 444 $@/ca.key
	openssl req -config ssl.conf \
		-key $@/ca.key -new -x509 -days 365 \
		-sha256 -extensions v3_ca \
		-subj "/CN=ca" -out $@/ca.crt
	@chmod 444 $@/ca.crt

$(NODES_CERTS): NODE=$(patsubst $(NODES_BUILD_PREFIX)%/certs/,%,$@)
$(NODES_CERTS): $(BUILD)/rootca | $(NODES_BUILD)
	@mkdir -p $@
	openssl genrsa -out $@/server.key $(KEYLEN)
	chmod 444 $@/server.key
	openssl req \
		-config ssl.conf \
		-subj "/CN=$(HOST)" \
		-key $@/server.key \
		-new -out $@/server.csr
	openssl x509 \
		-req \
		-in $@/server.csr \
	  	-CA $</ca.crt -CAkey $</ca.key \
	  	-CAcreateserial -days 365 \
	  	-out $@/server.crt \
	  	-extfile ssl.conf -extensions redis_cluster_cert
	openssl genrsa -out $@/client.key $(KEYLEN)
	chmod 444 $@/client.key
	openssl req \
		-config ssl.conf \
		-subj "/CN=alice" \
		-key $@/client.key \
		-new -out $@/client.csr
	openssl x509 \
		-req \
		-in $@/client.csr \
		-CA $</ca.crt -CAkey $</ca.key \
		-CAcreateserial -days 365 \
		-out $@/client.crt \
		-extfile ssl.conf -extensions redis_cluster_client_cert
	tctl auth sign \
		--format=redis \
		--overwrite \
		--host=$(HOST),redis-node-$(NODE),localhost,127.0.0.1 \
		-o $@/out \
		--ttl=2190h
	@cat $@/out.cas $</ca.crt > $@/bundle.cas
	@cat $</ca.crt > $@/rootca.crt

# 700x for port, 1700x for cluster port.
$(NODES_CONF): PORT=700$(patsubst $(NODES_BUILD_PREFIX)%/redis.conf,%,$@)
$(NODES_CONF): CLUSTER_PORT=1$(PORT)
$(NODES_CONF): $(DB)/common-redis.conf | $(NODES_BUILD)
	@cp $< $@
	@echo "tls-port $(PORT)" >> $@
	@echo "cluster-port $(CLUSTER_PORT)" >> $@

$(NODES_DOCKERFILE): $(DB)/Dockerfile | $(NODES_BUILD)
	@cp $< $@

$(NODES_USERS): $(DB)/users.acl | $(NODES_BUILD)
	@cp $< $@

# override the default down action to shutdown all the nodes in the cluster,
# otherwise `make redis-cluster-down` would only shutdown the redis-cluster container,
# which is only used to configure the cluster on init.
$(DB)-down:
	ssh $(SSH_HOST) $(COMPOSE_DOWN_CMD) \
		redis-cluster $(addprefix redis-node-, $(NODES))

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 7001 self-hosted-redis-cluster

.PHONY: $(DB)-hint
$(DB)-hint: redis-hint ;

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-redis-cluster
$(DB)-test-input := echo 'auth alice somepassword'
