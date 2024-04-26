# Teleport Databases Dev Env

## Usage
Do not create subdirectories in this directory.
Every subdirectory in this dir is considered a database name with config by the 
makefile.

The entire repo is based on a makefile, with db specific make targets in .mk include files.

### Use with EC2
You can setup a running ec2 instance from terraform.
Edit ../terraform files to provide your own config for terraform.
Eventually I'll get around to decoupling this better, but for now the Makefile
depends on that terraform module for getting the ec2 instance IP.

Then run `make terraform-up` to create an ec2 instance with docker installed.

### Use without EC2
You can alternatively set/export the following env vars to avoid all
dependence on ec2/terraform:
- `HOST` is the remote/local host to ssh into, since this makefile works for local/remote dev. I suggest using a linux host, as there is no oracle db image for M1 macos.
- `SSH_USER` is the remote host ssh user to login as.

Example that I use to my thinkpad:

```
export HOST=pop-os.local
export SSH_USER=gavin
```

1. login to your Teleport cluster
1. run `make` to (re)-sign certs and (re)-generate all configs needed
   You will need to accept adding the ec2 instance to  known_hosts on first use.
   You will need to wait a bit after the ec2 instance is available for init scripts to
   finish installing docker.
1. run `make up` to sync all config to the ec2 instance and start all databases
1. run `make <database>-connect` to connect to a db via teleport.

Some databases take some time to fully setup and configure
(oracle and mongo to name the worst offenders).
If connecting fails, take a look at the logs, e.g. `make oracle-logs` or 
`make logs` to see if the setup is failing. You probably just need to wait a
bit for it to finish setup.

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

## Troubleshooting

``` sh
unable to get image 'databases-cockroach-node-1': error during connect: Get "http://docker.example.com/v1.44/images/databases-cockroach-node-1/json": command [ssh -o ConnectTimeout=30 -l gavin -- pop-os docker system dial-stdio] has exited with exit status 255, please make sure the URL is valid, and Docker 18.09 or later is installed on the remote host: stderr=Pseudo-terminal will not be allocated because stdin is not a terminal.
```

When you use docker compose with a remote ssh host, it creates an ssh connection for each service it operates on.
So if you have 10 container services defined in compose.yaml, then `docker compose up` will initiate 10 ssh connections
in parallel.
By default, sshd will throttle too many startups in a short period of time (MaxStartups setting).
This means when you run `make up`, you will probably get something like the above error.
To fix this, you have two options:

1. configure your remote host to allow a larger MaxStartups value (less secure, I don't recommend this)
2. change your local ssh config to use ControlMaster multiplexing to the remote host.

Here's how you can setup ssh multiplexing:

``` sh
$ mkdir ~/.ssh/controlmasters
$ cat <<EOF >> ~/.ssh/config

# your docker host's name, or you can just use a wildcard if you don't mind
# multiplexing for all hosts
Host $HOST 
    ControlPath ~/.ssh/controlmasters/%r@%h:%p
    ControlMaster auto
    ControlPersist 1m
EOF
```

