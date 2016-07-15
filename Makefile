BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

deploy: build_release deploy_release start migrate

build_release:
	mix edeliver build release -V --branch="${BRANCH}"

deploy_release:
	mix edeliver deploy release to production -V

start:
	mix edeliver restart production

migrate:
	./utils/migrate.sh
