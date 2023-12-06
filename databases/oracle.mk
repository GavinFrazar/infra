DB = oracle

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=oracle $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	tsh db connect --db-user="alice" --db-name="XE" self-hosted-oracle

WALLET := /opt/oracle/oradata/dbconfig/XE/.tls-wallet
.PHONY: oracle-display-wallet
oracle-display-wallet:
	@ssh -t $(SSH_HOST) docker compose exec -u root oracle \
		orapki wallet display -complete -wallet $(WALLET)
