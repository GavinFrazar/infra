DB = postgres

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=db $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	tsh db connect --db-user="alice" --db-name="postgres" self-hosted-postgres
