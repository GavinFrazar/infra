DB = cassandra

$(DB): $(BUILD)/full-config.yaml $(BUILD)/certs ;

$(BUILD)/full-config.yaml: $(DB)/default-config.yaml $(BUILD)/auth-config.yaml
	@cat $^ > $@

$(BUILD)/auth-config.yaml: $(BUILD)/certs ;
	@cassandra/gen-auth-config.sh

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=cassandra $(SIGN_FLAGS)

.PHONY: $(DB)-hint
$(DB)-hint:
	@echo "Hint: any password will work."

$(DB)-tsh-db-connect-flags := --db-user="cassandra" --db-name="cassandra" self-hosted-cassandra
$(DB)-test-input := echo 'select now() from system.local;'
