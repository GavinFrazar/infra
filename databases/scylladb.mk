DB = scylladb

.PHONY: $(DB)
$(DB): $(BUILD)/full-config.yaml $(BUILD)/certs;

$(BUILD)/full-config.yaml: $(DB)/default-config.yaml $(DB)/auth-config.yaml
	@mkdir -p scylladb/build
	@cat $^ > $@

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=scylla $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	@echo "Hint: any password will work."
	tsh db connect --db-user="cassandra" --db-name="cassandra" self-hosted-scylladb
