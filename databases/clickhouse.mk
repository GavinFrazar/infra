DB = clickhouse

.PHONY: $(DB)
$(DB): $(BUILD)/certs ;

.PHONY: $(BUILD)/certs
$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=db $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	tsh db connect --db-user="alice" self-hosted-clickhouse-native

.PHONY: $(DB)-proxy
$(DB)-proxy:
	tsh proxy db --db-user="alice" --tunnel -p 8443 self-hosted-clickhouse-http

.PHONY: $(DB)-test-http
$(DB)-test-http:
	echo 'select currentUser();' | curl http://localhost:8443/ --data-binary '@-'
