DB = postgres

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=db $(SIGN_FLAGS)

$(DB)-tsh-db-connect-flags := --db-user="teleport-admin" --db-name="postgres" self-hosted-postgres
$(DB)-test-input := echo '\du'
