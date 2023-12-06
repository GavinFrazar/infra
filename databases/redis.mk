DB = redis

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=redis $(SIGN_FLAGS)

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 6379 self-hosted-redis

.PHONY: $(DB)-hint
$(DB)-hint:
	@echo "Hint: the password for user alice is: 'somepassword' ;)"

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-redis
$(DB)-test-input := echo 'auth alice somepassword'
