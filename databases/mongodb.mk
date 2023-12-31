# this is for a simple, single instance of mongodb.
# for a more complex multi-node version see mongodb-replicaset.
DB = mongodb

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=mongodb $(SIGN_FLAGS)

$(DB)-tsh-db-connect-flags := --db-user="alice" --db-name="admin" self-hosted-mongodb
$(DB)-test-input := echo 'db.runCommand({ ping: 1 })'
