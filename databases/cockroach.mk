DB = cockroach

$(DB): $(BUILD)/certs;

# tctl cockroach format expects a dir and our common sign flags use -o=out.
$(BUILD)/certs:
	@mkdir -p $@/out
	tctl auth sign --format=cockroachdb $(SIGN_FLAGS)

.PHONY: $(DB)-connect
$(DB)-connect:
	tsh db connect --db-user="root" --db-name=defaultdb self-hosted-cockroach
