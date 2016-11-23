BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags | sed 's/^v//')
bin := /opt/app/apientry/apientry/bin/apientry
deploy: build_release deploy_release start migrate
build_release:
	mix edeliver build release -V --branch="${BRANCH}"

deploy_release:
	mix edeliver deploy release to production -V --version="${VERSION}"

start:
	mix edeliver start production
	mix edeliver restart production

migrate:
	./utils/migrate.sh

console: keys
	ssh deployer@54.84.208.240 -- ${bin} remote_console

_start: keys
	ssh deployer@54.84.208.240 -- ${bin} start
	ssh deployer@54.172.178.121 -- ${bin} start
	ssh deployer@54.146.187.142 -- ${bin} start
	ssh deployer@54.147.51.223 -- ${bin} start
	ssh deployer@54.152.24.191 -- ${bin} start
	ssh deployer@54.146.174.170 -- ${bin} start
	ssh deployer@54.205.82.157 -- ${bin} start

_ping: keys
	ssh deployer@54.84.208.240 -- ${bin} ping
	ssh deployer@54.172.178.121 -- ${bin} ping
	ssh deployer@54.146.187.142 -- ${bin} ping
	ssh deployer@54.147.51.223 -- ${bin} ping
	ssh deployer@54.152.24.191 -- ${bin} ping
	ssh deployer@54.146.174.170 -- ${bin} ping
	ssh deployer@54.205.82.157 -- ${bin} ping

keys:
	chmod 600 ansible/keys/admin2.pem
	ssh-add ansible/keys/admin2.pem
