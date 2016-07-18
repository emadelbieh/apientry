BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags | sed 's/^v//')

deploy: build_release deploy_release start migrate

build_release:
	mix edeliver build release -V --branch="${BRANCH}"

deploy_release:
	mix edeliver deploy release to production -V --version="${VERSION}"

start:
	mix edeliver restart production

migrate:
	./utils/migrate.sh

console: keys
	ssh deployer@52.207.238.14 -- /opt/app/apientry/apientry/bin/apientry remote_console

keys:
	chmod 600 ansible/keys/admin2.pem
	ssh-add ansible/keys/admin2.pem
