DB = redis-cluster

.PHONY: $(DB)
$(DB): $(BUILD)/node-1 $(BUILD)/node-2 $(BUILD)/node-3 $(BUILD)/node-4 $(BUILD)/node-5 $(BUILD)/node-6 ;

$(DB)-down:
	@ssh $(SSH_HOST) $(COMPOSE_DOWN_CMD) \
		redis-cluster \
		redis-node-1 redis-node-2 redis-node-3 \
		redis-node-4 redis-node-5 redis-node-6

.PRECIOUS: $(BUILD)/node-%
$(BUILD)/node-%: $(BUILD)/node-%/certs $(BUILD)/node-%/redis.conf $(BUILD)/node-%/users.acl $(BUILD)/node-%/Dockerfile ;

.PRECIOUS: $(BUILD)/node-%/certs
$(BUILD)/node-%/certs:
	@mkdir -p $@
	tctl auth sign \
		--format=redis \
		--overwrite \
		--host=redis-node-$*,$(HOST),localhost,127.0.0.1 \
		-o $@/out \
		--ttl=2190h

.PRECIOUS: $(BUILD)/node-%/redis.conf
$(BUILD)/node-%/redis.conf: $(DB)/common-redis.conf
	@cp $< $@
	echo "tls-port 700$*" >> $@
	echo "cluster-port 1700$*" >> $@

.PRECIOUS: $(BUILD)/node-%/users.acl
$(BUILD)/node-%/users.acl: $(DB)/users.acl
	@cp $< $@

.PRECIOUS: $(BUILD)/node-%/Dockerfile
$(BUILD)/node-%/Dockerfile: $(DB)/Dockerfile
	@cp $< $@

.PHONY: $(DB)-connect
$(DB)-connect:
	@echo "Hint: the password for user alice is: 'somepassword' ;)"
	tsh db connect --db-user="alice" self-hosted-redis-cluster

$(DB)-proxy:
	tsh proxy db -d --tunnel --db-user="alice" -p 7001 self-hosted-redis-cluster
