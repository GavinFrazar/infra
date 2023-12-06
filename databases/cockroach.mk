DB = cockroach

$(DB): $(BUILD)/certs;

# tctl cockroach format expects a dir and our common sign flags use -o=out.
$(BUILD)/certs:
	@mkdir -p $@/out
	tctl auth sign --format=cockroachdb $(SIGN_FLAGS)

$(DB)-tsh-db-connect-flags := --db-user="root" --db-name=defaultdb self-hosted-cockroach
$(DB)-test-input := echo '\du'
