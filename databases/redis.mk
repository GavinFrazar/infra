DB = redis

.PHONY: $(DB)
$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=redis $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	@echo "Hint: the password for user alice is: 'somepassword' ;)"
	tsh db connect --db-user="alice" self-hosted-redis

$(DB)-proxy:
	tsh proxy db -d --tunnel --db-user="alice" -p 6379 self-hosted-redis
