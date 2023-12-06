DB = scylladb

$(DB): $(BUILD)/full-config.yaml $(BUILD)/certs;

$(BUILD)/full-config.yaml: $(DB)/default-config.yaml $(DB)/auth-config.yaml
	@mkdir -p scylladb/build
	@cat $^ > $@

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=scylla $(SIGN_FLAGS)

.PHONY: $(DB)-hint
$(DB)-hint: cassandra-hint ;

$(DB)-tsh-db-connect-flags := --db-user="cassandra" --db-name="cassandra" self-hosted-scylladb
$(DB)-test-input := echo 'select now() from system.local;'
