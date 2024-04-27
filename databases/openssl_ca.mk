ROOTCA_ACL := 644
KEYLEN := 2048

# % should be a build directory.
# the syntax "| %" means that the build dir
# is an order-only pre-req.
# What *that* means is that, unlike normal pre-reqs,
# if the build dir is newer than the target it will not
# trigger a rebuild of the target.
# Directory is made newer when its files inside are modified,
# so that would be bad - it would regenerate the rootca
# every time you call make.
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

%/usercert: %/rootca
	@mkdir -p $@
	@openssl genrsa -quiet -out $@/key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/key
	@openssl req \
		-quiet \
	 	-config ssl.conf \
	 	-subj "$(SUBJ)" \
	 	-key $@/key \
		-new -out $@/csr >/dev/null

	@openssl genrsa -quiet -out $@/key $(KEYLEN) >/dev/null
	@chmod $(ROOTCA_ACL) $@/key
	@openssl req \
	 	-quiet \
	 	-config ssl.conf \
	 	-subj "$(SUBJ)" \
	 	-key $@/key \
	 	-new -out $@/csr >/dev/null
	@openssl x509 \
	 	-req \
	 	-in $@/csr \
	 	-CA $</ca.crt -CAkey $</ca.key \
	 	-CAcreateserial -days 365 \
	 	-out $@/cert \
	 	-extfile ssl.conf -extensions client_cert >/dev/null
