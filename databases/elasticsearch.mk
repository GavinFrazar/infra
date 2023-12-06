DB = elasticsearch

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=elasticsearch $(SIGN_FLAGS)

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 9200 self-hosted-elasticsearch

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-elasticsearch
$(DB)-test-input := echo 'select 1;'
