DB = clickhouse

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=db $(SIGN_FLAGS)

.PHONY: $(DB)-proxy
$(DB)-proxy:
	tsh proxy db --db-user="alice" --tunnel -p 8443 self-hosted-clickhouse-http

.PHONY: $(DB)-test-http
$(DB)-test-http:
	echo 'select currentUser();' | curl http://localhost:8443/ --data-binary '@-'

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-clickhouse-native
$(DB)-test-input := echo 'select 1;'
