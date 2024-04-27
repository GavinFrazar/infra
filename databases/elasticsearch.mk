DB = elasticsearch

$(DB): $(BUILD)/certs ;

$(BUILD):
	@mkdir -p $@

$(BUILD)/certs: SUBJ:="/CN=alice"
$(BUILD)/certs: $(BUILD)/rootca $(BUILD)/usercert | $(BUILD)
	@mkdir -p $@
	tctl auth sign --format=elasticsearch $(SIGN_FLAGS)
	cat $</ca.crt $@/out.cas > $@/all.cas
	cp $@/../usercert/{cert,key} $@

$(DB)-proxy:
	tsh proxy db --tunnel --db-user="alice" -p 9200 self-hosted-elasticsearch

$(DB)-tsh-db-connect-flags := --db-user="alice" self-hosted-elasticsearch
$(DB)-test-input := echo 'select 1;'
