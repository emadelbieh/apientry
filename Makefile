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
	ssh deployer@52.207.238.14 -- ${bin} remote_console

_start: keys
	ssh deployer@52.207.238.14 -- ${bin} start
	ssh deployer@54.84.208.240 -- ${bin} start
	ssh deployer@54.152.146.150 -- ${bin} start
	ssh deployer@54.197.11.252 -- ${bin} start
	ssh deployer@54.210.202.236 == ${bin} start

_ping: keys
	ssh deployer@52.207.238.14 -- ${bin} ping
	ssh deployer@54.84.208.240 -- ${bin} ping
	ssh deployer@54.152.146.150 -- ${bin} ping
	ssh deployer@54.197.11.252 -- ${bin} ping
	ssh deployer@54.210.202.236 == ${bin} ping

keys:
	chmod 600 ansible/keys/admin2.pem
	ssh-add ansible/keys/admin2.pem
