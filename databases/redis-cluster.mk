DB = redis-cluster

# a corresponding entry in compose.tpl.yaml needs to exist for each node.
NODES = 1 2 3 4 5 6
NODES_CONF = $(addsuffix /redis.conf, $(NODES_BUILD))
NODES_USERS = $(addsuffix /users.acl, $(NODES_BUILD))
REDIS_ROOTCA_CERT := $(BUILD)/rootca/ca.crt

$(DB): $(NODES_CERTS) $(NODES_CONF) $(NODES_DOCKERFILE) $(NODES_USERS) ;

$(BUILD):
	@mkdir -p $@

$(NODES_BUILD): | $(BUILD)
	@mkdir -p $@

$(NODES_CERTS): PREFIX:=$(NODES_BUILD_PREFIX)
$(NODES_CERTS): NODE=$(patsubst $(PREFIX)%/certs,%,$@)
$(NODES_CERTS): NODE_NAME=redis-node-$(NODE_NUM)
$(NODES_CERTS): SANS=$(HOST),$(NODE_NAME),localhost,127.0.0.1
$(NODES_CERTS): $(BUILD)/rootca | $(NODES_BUILD)
	@mkdir -p $@
	@openssl genrsa -out $@/server.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/server.key
	@openssl req \
		-config ssl.conf \
		-subj "/CN=$(HOST)" \
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
	@openssl genrsa -out $@/client.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/client.key
	@openssl req \
		-config ssl.conf \
		-subj "/CN=alice" \
		-key $@/client.key \
		-new -out $@/client.csr >/dev/null
	@openssl x509 \
		-req \
		-in $@/client.csr \
		-CA $</ca.crt -CAkey $</ca.key \
		-CAcreateserial -days 365 \
		-out $@/client.crt \
		-extfile ssl.conf -extensions client_cert >/dev/null
	tctl auth sign \
		--format=redis \
		--overwrite \
		--host=$(SANS) \
		-o $@/out \
		--ttl=2190h
	@cat $@/out.cas $</ca.crt > $@/bundle.cas
	@cat $</ca.crt > $@/rootca.crt

# 700x for port, 1700x for cluster port.
$(NODES_CONF): PREFIX:=$(NODES_BUILD_PREFIX)
$(NODES_CONF): PORT=700$(patsubst $(PREFIX)%/redis.conf,%,$@)
$(NODES_CONF): CLUSTER_PORT=1$(PORT)
$(NODES_CONF): $(DB)/common-redis.conf | $(NODES_BUILD)
	@cp $< $@
	@echo "tls-port $(PORT)" >> $@
	@echo "cluster-port $(CLUSTER_PORT)" >> $@
	@echo "cluster-announce-ip $(HOST)" >> $@
	@echo "cluster-announce-tls-port $(PORT)" >> $@
	@echo "cluster-announce-bus-port $(CLUSTER_PORT)" >> $@

$(NODES_DOCKERFILE): $(DB)/Dockerfile | $(NODES_BUILD)
	@cp $< $@

$(NODES_USERS): $(DB)/users.acl | $(NODES_BUILD)
	@cp $< $@

# override the default down action to shutdown all the nodes in the cluster,
# otherwise `make redis-cluster-down` would only shutdown the redis-cluster container,
# which is only used to configure the cluster on init.
$(DB)-down: CONTAINERS:=redis-cluster $(addprefix redis-node-, $(NODES))
$(DB)-down:
	$(COMPOSE_DOWN_CMD) $(CONTAINERS)

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 7001 self-hosted-redis-cluster

.PHONY: $(DB)-hint
$(DB)-hint: redis-hint ;

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-redis-cluster
$(DB)-test-input := echo 'auth alice somepassword'
