.SECONDEXPANSION:
SHELL := /bin/bash -eo pipefail
export SHELL

HOST ?= $(shell terraform -chdir=../terraform output -raw self-hosted-databases-ip)
HOST := $(HOST)
export HOST

SSH_HOST := ubuntu@$(HOST)
export SSH_HOST

SIGN_FLAGS = --overwrite --host=$(HOST),localhost,127.0.0.1 -o $@/out --ttl=2190h > $@/tctl.result
export SIGN_FLAGS

DATABASES := $(shell fd -HI --type directory --min-depth=1 --max-depth=1 . -x basename {})
DATABASES_PAT = $(addsuffix -$@,$(DATABASES))

COMPOSE_UP_CMD := docker compose up --build -d
COMPOSE_DOWN_CMD := docker compose down --remove-orphans

.PHONY: all
all: $(DATABASES)
	@echo 'Hint: you can unconditionally make all target certs/config again with "make -B" (--always-make).'

.PHONY: terraform-up
terraform-up:
	@terraform -chdir=../terraform apply -target=module.self-hosted-databases
	@echo you will need to wait for user data init installing docker and docker compose.

.PHONY: terraform-down
terraform-down:
	terraform -chdir=../terraform destroy -target=module.self-hosted-databases

.PHONY: list
list:
	@echo $(DATABASES) | tr ' ' '\n' | sort

sync: compose.yaml config.tar.gz
	@scp compose.yaml config.tar.gz $(SSH_HOST):~
	@ssh $(SSH_HOST) "mkdir -p ~/config && tar --warning=no-unknown-keyword -xzf ~/config.tar.gz -C ~/config"
	@touch sync

compose.yaml: compose.tpl.yaml
	@envsubst < $< > $@

config.tar.gz: $(shell fd -HI . $(DATABASES))
	@tar czf config.tar.gz $(DATABASES)

.PHONY: ssh
ssh:
	@ssh -t $(SSH_HOST)

.PHONY: logs
logs:
	@ssh -t $(SSH_HOST) docker compose logs --follow

%-logs: force
	@ssh -t $(SSH_HOST) docker compose logs --follow $*

%-shell: force
	@ssh -t $(SSH_HOST) docker compose exec -it $* bash

%-run: force
	@ssh -t $(SSH_HOST) docker compose run -it --rm $* bash

.PHONY: up
up: sync
	@ssh $(SSH_HOST) $(COMPOSE_UP_CMD)

%-up: force sync
	@ssh $(SSH_HOST) $(COMPOSE_UP_CMD) $*

.PHONY: down
down:
	@ssh $(SSH_HOST) $(COMPOSE_DOWN_CMD)

%-down: force
	@ssh $(SSH_HOST) $(COMPOSE_DOWN_CMD) $*

.PHONY: clean
clean: $$(DATABASES_PAT)
	ssh $(SSH_HOST) "rm -rf ~/config"
	rm -f sync config.tar.gz teleport-databases teleport.yaml compose.yaml

%-clean: force
	rm -rf $*/build

# connect, in sequence, to each database interactively.
.PHONY: connect
connect: $$(DATABASES_PAT) ;

teleport.yaml: teleport.tpl.yaml
	@envsubst < $< > $@

teleport-databases: teleport.yaml
	tctl create -f teleport.yaml
	@touch teleport-databases

.PHONY: rm-teleport-databases
rm-teleport-databases:
	- for db in `yq .metadata.name teleport.tpl.yaml -r`; \
	do tctl rm db/$$db || true; \
	done
	@rm -f teleport-databases

# make showcerts-<port>
# first tests for connectivity with netcat.
# then use openssl s_client to show certs being served on <port> of the ec2 instance.
showcerts-%: force
	nc -zv $(HOST) $*
	openssl s_client -showcerts -connect $(HOST):$* </dev/null

# configure cert/key/cas.
# require and verify a client cert against CAfile.
# accept one connection and exit.
# listen on port 8088 for a connection.
.PHONY: debug-db
debug-db:
	@mkdir -p /tmp/certs
	tctl auth sign \
		--overwrite \
		--host=localhost,127.0.0.1 \
		-o /tmp/certs/out --ttl=2190h \
		--format=db > /dev/null
	@echo Hint: connect with tsh db connect debug-db. If you changed the db protocol be sure to logout of db and back in.
	@openssl s_server \
			-cert /tmp/certs/out.crt \
			-key /tmp/certs/out.key \
			-CAfile /tmp/certs/out.cas \
			-Verify 1 \
			-naccept 1 \
			-accept 8088

# These vars shouldnt be used in a recipe body.
# In a recipe body the vars will be the last defined value.
# It's just a convenience for writing target and pre-req names.
# Each included makefile just has to define DB, since BUILD is lazily evaluated.
DB =
BUILD = $(DB)/build

.PHONY: force
force: ;
Makefile: ;

include cassandra.mk
include clickhouse.mk
include cockroach.mk
include elasticsearch.mk
include mariadb.mk
include mongodb.mk
include mysql.mk
include oracle.mk
include postgres.mk
include redis-cluster.mk
include redis.mk
include scylladb.mk
