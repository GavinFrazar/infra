# Teleport Databases Dev Env

## Usage
Do not create subdirectories in this directory.
Every subdirectory in this dir is considered a database name with config by the 
makefile.

The entire repo is based on a makefile, with db specific make targets in .mk include files.

You need a running ec2 instance from terraform. Edit ../terraform files to provide your own config for terraform.
Eventually I'll get around to decoupling this better, but for now the Makefile
depends on that terraform module for getting the ec2 instance IP.

1. run `make terraform-up` to create an ec2 instance with docker installed.
2. login to your Teleport cluster
3. run `make` to (re)-sign certs and (re)-generate all configs needed
   You will need to accept adding the ec2 instance to  known_hosts on first use.
   You will need to wait a bit after the ec2 instance is available for init scripts to
   finish installing docker.
4. run `make up` to sync all config to the ec2 instance and start all databases
5. run `make <database>-connect` to connect to a db via teleport.

## Template files
Don't try to edit these files:
- teleport.yaml (built from teleport.tpl.yaml)
- compose.yaml (built from compose.tpl.yaml)

Some config required templating with `envsubst`, so if you edit
these files directly your changes will be overwritten.
Edit the corresponding template files instead.

## Utils
- `make terraform-up`: terraform apply for the databases' ec2 host.
- `make terraform-down`: terraform destroy for the databases' ec2 host.
- `make list`: list available databases. These are the names you should use for other make target commands, and they correspond to the names of all the sub-directories.
- `make ssh`: ssh into databases host
- `make up`: start all databases
- `make sync`: sync local config for containers to remote host.
- `make <database>-up`: start a given database, e.g. postgres-up. Does not gen config automatically, so you may need to run `make <database>` first.
- `make down`: stop all databases
- `make <database>-down`: stop a given database
- `make logs`: docker compose logs on databases host
- `make <database>-logs`: docker compose logs on databases host for a specific db
- `make clean`: clean all config/certs. Does not stop running databases.
- `make <database>-clean`: clean config/certs for a given database. Does not stop the database.
- `make <database>-shell`: pop a shell in a running database's docker container
- `make <database>-run`: run a new ephemeral remote container and pop a shell in it
- `make connect`: try to connect to all databases one after another.
- `make <database>-connect`: connect to a given database.
- `make teleport-databases`: tctl create all the databases
- `make rm-teleport-databases`: tctl rm all the databases
- `make debug-db`: start an openssl s_server that will dump all certs presented by teleport db agent. Run this and then `tsh db connect debug-db` to test. The debug-db yaml is in teleport.tpl.yaml. Useful for debugging.
