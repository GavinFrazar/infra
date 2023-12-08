DB = oracle

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=oracle $(SIGN_FLAGS)

$(DB)-tsh-db-connect-flags := --db-user="alice" --db-name="XE" self-hosted-oracle
$(DB)-test-input := echo 'select 1 from dual;'

WALLET := /opt/oracle/oradata/dbconfig/XE/.tls-wallet
.PHONY: oracle-display-wallet
oracle-display-wallet:
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) exec -u root oracle \
		orapki wallet display -complete -wallet $(WALLET)
