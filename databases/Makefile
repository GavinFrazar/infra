# enable second expansion so that $$(DATABASES_PAT) works as a shortcut
# for creating helper commands like <db>-<cmd>, e.g. to create a target
# command "cmd" for a specific db like "postgres", as in "make postgres-cmd",
# define the "cmd" target like this:
# cmd: $$(DATABASES_PAT)
#
# and another target like this:
# %-cmd: force
# 	...recipe...
#	($* is the <db> name)
#
# or for <db> specific behavior:
# postgres-cmd:
# 	...recipe...
.SECONDEXPANSION:
SHELL := /bin/bash -eo pipefail
export SHELL

# The following variables can be overridden.
# Use either an env var or "make [target...] <VAR>=<VALUE>"
HOST ?= $(shell terraform -chdir=../terraform output -raw self-hosted-databases-ip)
HOST := $(HOST)
export HOST

# the remote host directory to store the docker compose file and all config.
DOCKER_COMPOSE_PROJECT_DIR ?= ~

# the username to use when ssh'ing to HOST: SSH_USER=<username>
SSH_USER ?= ubuntu

# These vars should not be overridden.
SSH_HOST := $(SSH_USER)@$(HOST)

# this is intentionally a lazy var (= not :=) for use in a recipe where the auto
# variable $@ is actually defined. Do not change.
SIGN_FLAGS = --overwrite --host=$(HOST),localhost,127.0.0.1 -o $@/out --ttl=2190h > $@/tctl.result

DATABASES := $(shell fd -HI --type directory --min-depth=1 --max-depth=1 . -x basename {})
DATABASES_PAT = $(addsuffix -$@,$(DATABASES))
CONFIG_FILES := $(shell fd -HI . $(DATABASES))

DOCKER_COMPOSE := docker compose --project-directory "$(DOCKER_COMPOSE_PROJECT_DIR)"
COMPOSE_UP_CMD := $(DOCKER_COMPOSE) up --build -d
COMPOSE_DOWN_CMD := $(DOCKER_COMPOSE) down --remove-orphans -v

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
	@ssh $(SSH_HOST) "mkdir -p $(DOCKER_COMPOSE_PROJECT_DIR)/config"
	@scp compose.yaml config.tar.gz $(SSH_HOST):$(DOCKER_COMPOSE_PROJECT_DIR)
	@ssh $(SSH_HOST) "tar --warning=no-unknown-keyword -xzf $(DOCKER_COMPOSE_PROJECT_DIR)/config.tar.gz -C $(DOCKER_COMPOSE_PROJECT_DIR)/config"
	@touch sync

compose.yaml: compose.tpl.yaml
	@envsubst < $< > $@

config.tar.gz: $(CONFIG_FILES)
	@tar czf config.tar.gz $(DATABASES)

.PHONY: ssh
ssh:
	@ssh -t $(SSH_HOST)

.PHONY: logs
logs:
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) logs --follow

%-logs: force
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) logs --follow $*

%-shell: force
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) exec -it $* bash

%-root-shell: force
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) exec -it -u root $* bash

%-run: force
	@ssh -t $(SSH_HOST) $(DOCKER_COMPOSE) run -it --rm $* bash

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
	ssh $(SSH_HOST) "rm -rf $(DOCKER_COMPOSE_PROJECT_DIR)/config"
	rm -f sync config.tar.gz teleport-databases teleport.yaml compose.yaml

%-clean: force
	rm -rf $*/build

# connect, in sequence, to each database interactively.
.PHONY: connect
connect: $$(DATABASES_PAT) ;

%-connect: %-hint teleport-databases
	tsh db connect $($*-tsh-db-connect-flags)

.PHONY: test
test: $$(DATABASES_PAT) ;

%-test: %-hint
	$($*-test-input) | tsh db connect $($*-tsh-db-connect-flags) >/dev/null

%-hint: force ;

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
