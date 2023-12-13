ROOTCA_ACL := 644
KEYLEN := 2048

%/rootca: | %
	@mkdir -p $@
	@openssl genrsa -quiet -out $@/ca.key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/ca.key
	@openssl req -config ssl.conf \
		-quiet \
		-key $@/ca.key -new -x509 -days 365 \
		-sha256 -extensions v3_ca \
		-subj "/CN=ca" -out $@/ca.crt >/dev/null
	@chmod $(ROOTCA_ACL) $@/ca.crt

