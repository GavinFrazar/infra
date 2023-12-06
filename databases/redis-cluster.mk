DB = redis-cluster

# a corresponding entry in compose.tpl.yaml needs to exist for each node.
NODES := 1 2 3 4 5 6
NODES_BUILD_PREFIX := $(BUILD)/node-
NODES_BUILD := $(addprefix $(NODES_BUILD_PREFIX), $(NODES))
NODES_CERTS := $(addsuffix /certs/, $(NODES_BUILD))
NODES_CONF := $(addsuffix /redis.conf, $(NODES_BUILD))
NODES_DOCKERFILE := $(addsuffix /Dockerfile, $(NODES_BUILD))
NODES_USERS := $(addsuffix /users.acl, $(NODES_BUILD))

$(DB): $(NODES_CERTS) $(NODES_CONF) $(NODES_DOCKERFILE) $(NODES_USERS);

$(BUILD):
	@mkdir -p $@

$(NODES_BUILD): | $(BUILD)
	@mkdir -p $@

$(NODES_CERTS): NODE=$(patsubst $(NODES_BUILD_PREFIX)%/certs/,%,$@)
$(NODES_CERTS): | $(NODES_BUILD)
	@mkdir -p $@
	tctl auth sign \
		--format=redis \
		--overwrite \
		--host=redis-node-$(NODE),$(HOST),localhost,127.0.0.1 \
		-o $@/out \
		--ttl=2190h

# 700x for port, 1700x for cluster port.
$(NODES_CONF): PORT=700$(patsubst $(NODES_BUILD_PREFIX)%/redis.conf,%,$@)
$(NODES_CONF): CLUSTER_PORT=1$(PORT)
$(NODES_CONF): $(DB)/common-redis.conf | $(NODES_BUILD)
	@cp $< $@
	@echo "port $(PORT)" >> $@
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
