BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VERSION := $(shell git describe --tags | sed 's/^v//')
bin := /opt/app/apientry/apientry/bin/apientry

deploy: build_release deploy_release start migrate

build_release:
	mix edeliver build release -V --branch="${BRANCH}"

deploy_release:
	mix edeliver deploy release to production -V --version="${VERSION}"

start:
	ssh deployer@52.207.238.14  -- ${bin} restart
	ssh deployer@54.84.208.240  -- ${bin} restart
	ssh deployer@52.201.227.35  -- ${bin} restart
	ssh deployer@52.90.78.210   -- ${bin} restart
	ssh deployer@54.167.191.19  -- ${bin} restart
	ssh deployer@54.173.49.202  -- ${bin} restart
	ssh deployer@54.173.196.154 -- ${bin} restart
	ssh deployer@54.84.122.202  -- ${bin} restart
	ssh deployer@54.209.226.29  -- ${bin} restart
	ssh deployer@52.91.195.86   -- ${bin} restart
	ssh deployer@52.207.238.14  -- ${bin} start
	ssh deployer@54.84.208.240  -- ${bin} start
	ssh deployer@52.201.227.35  -- ${bin} start
	ssh deployer@52.90.78.210   -- ${bin} start
	ssh deployer@54.167.191.19  -- ${bin} start
	ssh deployer@54.173.49.202  -- ${bin} start
	ssh deployer@54.173.196.154 -- ${bin} start
	ssh deployer@54.84.122.202  -- ${bin} start
	ssh deployer@54.209.226.29  -- ${bin} start
	ssh deployer@52.91.195.86   -- ${bin} start

migrate:
	./utils/migrate.sh

console: keys
	ssh deployer@52.207.238.14 -- ${bin} remote_console

_ping: keys
	ssh deployer@52.207.238.14  -- ${bin} ping
	ssh deployer@54.84.208.240  -- ${bin} ping
	ssh deployer@52.201.227.35  -- ${bin} ping
	ssh deployer@52.90.78.210   -- ${bin} ping
	ssh deployer@54.167.191.19  -- ${bin} ping
	ssh deployer@54.173.49.202  -- ${bin} ping
	ssh deployer@54.173.196.154 -- ${bin} ping
	ssh deployer@54.84.122.202  -- ${bin} ping
	ssh deployer@54.209.226.29  -- ${bin} ping
	ssh deployer@52.91.195.86   -- ${bin} ping

keys:
	chmod 600 ansible/keys/admin2.pem
	ssh-add ansible/keys/admin2.pem
