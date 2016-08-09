BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags | sed 's/^v//')
bin := /opt/app/apientry/apientry/bin/apientry

deploy: build_release deploy_release start migrate

build_release:
	mix edeliver build release -V --branch="${BRANCH}"

deploy_release:
	mix edeliver deploy release to production -V --version="${VERSION}"

start:
	ssh deployer@52.207.238.14 -- ${bin} start
	ssh deployer@54.84.208.240 -- ${bin} start

migrate:
	./utils/migrate.sh

console: keys
	ssh deployer@52.207.238.14 -- ${bin} remote_console

_ping: keys
	ssh deployer@52.207.238.14 -- ${bin} ping
	ssh deployer@54.84.208.240 -- ${bin} ping

keys:
	chmod 600 ansible/keys/admin2.pem
	ssh-add ansible/keys/admin2.pem
