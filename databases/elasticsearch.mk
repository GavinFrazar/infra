DB = elasticsearch

$(DB): $(BUILD)/certs ;

$(BUILD)/certs:
	@mkdir -p $@
	tctl auth sign --format=elasticsearch $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	tsh db connect --db-user="alice" self-hosted-elasticsearch

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 9200 self-hosted-elasticsearch
