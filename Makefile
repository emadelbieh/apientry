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
