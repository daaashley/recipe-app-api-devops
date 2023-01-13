#####################################################
# Makefile containing shortcut commands for project #
#####################################################

# MACOS USERS:
#  Make should be installed with XCode dev tools.
#  If not, run `xcode-select --install` in Terminal to install.

# WINDOWS USERS:
#  1. Install Chocolately package manager: https://chocolatey.org/
#  2. Open Command Prompt in administrator mode
#  3. Run `choco install make`
#  4. Restart all Git Bash/Terminal windows.

# .PHONY: tf-init
# tf-init:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform init

# .PHONY: tf-fmt
# tf-fmt:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform fmt

# .PHONY: tf-validate
# tf-validate:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform validate

# .PHONY: tf-plan
# tf-plan:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform plan

# .PHONY: tf-apply
# tf-apply:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform apply

# .PHONY: tf-destroy
# tf-destroy:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform destroy

# .PHONY: tf-workspace-dev
# tf-workspace-dev:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select dev

# .PHONY: tf-workspace-staging
# tf-workspace-staging:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select staging

# .PHONY: tf-workspace-prod
# tf-workspace-prod:
# 	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace select prod

# .PHONY: test
# test:
# 	docker-compose run --rm app sh -c "python manage.py wait_for_db && python manage.py test && flake8"

PYTHON_VERSION = 3.9.10
PROJECT_NAME = "Vibeeng"

.PHONY: all dev pyenv install-poetry build-dev run-dev docker-build run push test deploy ci-test migrate-db build

# Database configurations.s
DB_PASSWORD ?= local_db_password
POSTGRES_PASSWORD ?= ${DB_PASSWORD}

DB_USERNAME ?= postgres
POSTGRES_USER ?= ${DB_USERNAME}

DB_HOST ?= localhost
POSTGRES_HOST ?= ${DB_HOST}

POSTGRES_DB ?= postgres
DATABASE_URL ?= postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}

# Set Prod environment for client build
NODE_ENV ?= production

dev:
	@set -e; \
	set -x; \
	poetry install; \
	poetry run pre-commit install; \
	echo initialized

clean-db:
	docker stack rm postgres

init-db:
	docker-compose up -d
	@docker pull postgres; \
	docker swarm init; \
	docker stack deploy -c db_stack.yaml postgres;

migrate-db:
	@set -e; \
	echo $(DATABASE_URL); \
	DATABASE_URL=$(DATABASE_URL) poetry run yoyo apply -b -vvv; \

# set -e Exit on error
migration:
	@set -e; \
	echo $(DATABASE_URL); \
	echo $(Migration_Name); \
	DATABASE_URL=$(DATABASE_URL) poetry run yoyo new --sql -m "$$Migration_Name";

run: build
	@poetry run uvicorn --host 0.0.0.0 --port 5050 app.main:app

run-no-build:
	@poetry run uvicorn --reload --reload-dir app --host 0.0.0.0 --port 5050 app.main:app

test:
	@poetry run pytest --cov-report term-missing --cov=src tests

build:
	@set -x; \
	cd client; \
	yarn; \
	CI='' yarn build && yarn relocate;

build-local:
	@set -x; \
	cd client; \
	yarn dev; \
