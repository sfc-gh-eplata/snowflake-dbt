# Created By Enrique Plata

SHELL = /bin/bash

include .env

.DEFAULT_GOAL := help

checker:
     $(if $(ACCOUNT),,$(error Must set variable ACCOUNT)) \
     $(if $(DATABASE_USERNAME),,$(error Must set variable DATABASE_USERNAME)) \
     $(if $(DATABASE_PASSWORD),,$(error Must set variable DATABASE_PASSWORD))

.PHONY: setup
setup: ## 1.-Deploying docker-compose, creating containers.
	@ echo "**********Building container**********"
	@ docker-compose up --build --remove-orphans -d
	@ docker exec agent_snowflake /bin/bash -c "dbt debug"

.PHONY: run
run: ## 2.-Running POC, loading seeds and running models and running tests.
	@ echo "******************** 1.-Loading Seeds ********************"
	docker exec agent_snowflake dbt seed
	@ echo "******************** 2.-Running Models ********************"
	docker exec agent_snowflake dbt run
	@ echo "******************** 3.-Running Tests ********************"
	docker exec agent_snowflake dbt test
	@ echo "******************** 4.-Reloading Web UI ********************"
	docker exec dbt-docs dbt compile
	@ echo "******************** 5.-Getting localhost endpoint ********************"
	@ echo "Go to: http://localhost:8001/"

.PHONY: dbt
dbt: ## 3.-Jump inside of docker container with dbt installed.
	@ echo "**********SSH docker container**********"
	docker exec -it agent_snowflake /bin/bash

.PHONY: clean
clean: ## 4.-Removing docker-compose deployment.
	@ echo "**********Cleaning container**********"
	docker-compose down -v

help: ## 5.-Display all the different target recipes.
	@ echo "Please use \`make <target>' where <target> is one of"
	@ perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'
