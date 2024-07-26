static-join-token:
	tctl tokens add --type=db --format=text --ttl=10m > static-join-token

certs:
	mkdir -p certs
	tctl auth sign \
		--format=db \
		--ttl=240h \
		--overwrite \
		--host=postgres,localhost,127.0.0.1 \
		-o certs/out

.PHONY: init
init: static-join-token certs ;

.PHONY: up
up: init
	docker compose up --detach --wait

.PHONY: logs
logs:
	docker compose logs -f

.PHONY: down
down:
	docker compose down --remove-orphans --volumes

.PHONY: connect
connect:
	tsh db connect --db-user=teleport --db-name=postgres self-hosted-postgres-example

clean:
	rm -rf static-join-token certs
