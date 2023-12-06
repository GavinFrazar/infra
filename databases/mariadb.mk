DB = mariadb

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=db $(SIGN_FLAGS)

$(DB)-tsh-db-connect-flags := --db-user="alice" --db-name="mysql" self-hosted-mariadb
$(DB)-test-input := echo 'select user();'
