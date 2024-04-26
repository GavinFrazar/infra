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
HOST ?= $(shell terraform -chdir=../terraform output -raw databases_host_ip)
HOST := $(HOST)

# the username to use when ssh'ing to HOST: SSH_USER=<username>
SSH_USER ?= ubuntu

# These vars should not be overridden.
SSH_HOST := $(SSH_USER)@$(HOST)

DOCKER_HOST := ssh://$(SSH_HOST)

# this is intentionally a lazy var (= not :=) for use in a recipe where the auto
# variable $@ is actually defined. Do not change.
SIGN_FLAGS = --overwrite --host=$(HOST),localhost,127.0.0.1 -o $@/out --ttl=2190h > $@/tctl.result

DATABASES := $(shell fd -HI --type directory --min-depth=1 --max-depth=1 . -x basename {})
DATABASES_PAT = $(addsuffix -$@,$(DATABASES))
CONFIG_FILES := $(shell fd -HI . $(DATABASES))

DOCKER := DOCKER_HOST=$(DOCKER_HOST) /opt/homebrew/bin/docker
DOCKER_COMPOSE := $(DOCKER) compose
# wait for healthy services and then detach
COMPOSE_UP_CMD := $(DOCKER_COMPOSE) up --build --detach --wait
# remove containers not in the compose yaml, and remove the volumes named in compose.yaml.
COMPOSE_DOWN_CMD := $(DOCKER_COMPOSE) down --remove-orphans --volumes

.PHONY: all
all: $(DATABASES)
	@echo 'Hint: you can unconditionally make all target certs/config again with "make -B" (--always-make).'

.PHONY: terraform-up
terraform-up:
	@terraform -chdir=../terraform apply \
		-target=module.databases_host \
		-var 'enabled={databases_host=true}'
	@echo you will need to wait for user data init installing docker and docker compose.

.PHONY: terraform-down
terraform-down:
	terraform -chdir=../terraform destroy \
		-target=module.databases_host \
		-var 'enabled={databases_host=true}'

.PHONY: list
list:
	@echo $(DATABASES) | tr ' ' '\n' | sort

.PHONY: show-host
show-host:
	@echo $(HOST)

# only specified env vars are substituted by envsubst.
# this is because we do not want to expand everything that looks like
# an env var in the template.
compose.yaml: compose.tpl.yaml
	@envsubst '$${HOST}=$(HOST)' < $< > $@

.PHONY: ssh
ssh:
	@ssh -t $(SSH_HOST)

.PHONY: logs
logs: compose.yaml
	@$(DOCKER_COMPOSE) logs --follow

%-logs: force compose.yaml
	@$(DOCKER_COMPOSE) logs --follow $*

%-shell: force compose.yaml
	@$(DOCKER_COMPOSE) exec -it $* bash

%-root-shell: force compose.yaml
	@$(DOCKER_COMPOSE) exec -it -u root $* bash

%-run: force compose.yaml
	@$(DOCKER_COMPOSE) run -it --rm $* bash

%-run-root: force compose.yaml
	@$(DOCKER_COMPOSE) run -it --rm -u root $* bash

.PHONY: up
up: compose.yaml
	@$(COMPOSE_UP_CMD)

%-up: force compose.yaml
	@$(COMPOSE_UP_CMD) $*

.PHONY: down
down: compose.yaml
	@$(COMPOSE_DOWN_CMD)

%-down: force compose.yaml
	@$(COMPOSE_DOWN_CMD) $*

.PHONY: clean
clean: $$(DATABASES_PAT)
	@rm -f teleport-databases
	rm -f teleport.yaml compose.yaml

%-clean: force
	rm -rf $*/build

# connect, in sequence, to each database interactively.
.PHONY: connect
connect: $$(DATABASES_PAT) teleport-databases ;

%-connect: %-hint teleport-databases
	tsh db connect $($*-tsh-db-connect-flags)

.PHONY: test
test: $$(DATABASES_PAT) ;

%-test: %-hint
	$($*-test-input) | tsh db connect $($*-tsh-db-connect-flags)

%-hint: force ;

teleport.yaml: teleport.tpl.yaml
	REDIS_CA_CERT=$$(./readca.sh $(REDIS_ROOTCA_CERT)) \
	MONGO_CA_CERT=$$(./readca.sh $(MONGO_ROOTCA_CERT)) \
	envsubst < $< > $@

teleport-databases: teleport.yaml
	tctl create -f teleport.yaml
	@touch teleport-databases

.PHONY: rm-teleport-databases
rm-teleport-databases:
	- for db in `yq '"db/"+.metadata.name' teleport.tpl.yaml -r`; \
	do tctl rm $$db || true; \
	done
	@rm -f teleport-databases

# make showcerts-<port>
# first tests for connectivity with netcat.
# then use openssl s_client to show certs being served on <port> of the ec2 instance.
showcerts-%: force
	nc -zv $(HOST) $*
	openssl s_client -showcerts -connect $(HOST):$* </dev/null

# This can be useful to attach to a docker compose network and poke around.
# usage: `make netshoot-<netname>`
# example: `make netshoot-compose_redis-cluster`, i.e. to debug the redis cluster network.
# more info: https://github.com/nicolaka/netshoot
netshoot-%: force
	@$(DOCKER) run -it --rm --net=$* nicolaka/netshoot

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
NODES =
NODES_BUILD_PREFIX = $(BUILD)/node-
NODES_BUILD = $(addprefix $(NODES_BUILD_PREFIX), $(NODES))
NODES_CERTS = $(addsuffix /certs, $(NODES_BUILD))
NODES_DOCKERFILE = $(addsuffix /Dockerfile, $(NODES_BUILD))

.PHONY: force
force: ;
Makefile: ;

# common openssl rootca gen util
include openssl_ca.mk

# databases
include cassandra.mk
include cassandra-cluster.mk
include clickhouse.mk
include cockroach.mk
include cockroach-cluster.mk
include elasticsearch.mk
include mariadb.mk
include mongodb.mk
include mongodb-replicaset.mk
include mysql.mk
include oracle.mk
include postgres.mk
include redis-cluster.mk
include redis.mk
include scylladb.mk
