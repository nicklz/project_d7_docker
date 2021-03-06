include .env

.PHONY: up down stop prune ps shell uli cim cex composer

default: up

up:
	@echo "Starting up containers for for $(PROJECT_NAME)..."
	docker-compose$(WINDOWS_SUPPORT) pull
	docker-compose$(WINDOWS_SUPPORT) up -d --remove-orphans
	@echo "Syncing folders... this may take a few minutes"
	@echo "-------------------------------------------------"
	@echo "------------------DRUPAL 7-----------------------"
	@echo "-------------------------------------------------"
	@echo "Visit http://$(PROJECT_BASE_URL):$(PROJECT_PORT)3"
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"


down:
	@echo "Removing containers."
	docker-compose$(WINDOWS_SUPPORT) down

rsync:
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  ' apt-get install rsync -y && while true ; do rsync -avW --inplace --no-compress --delete --exclude node_modules --exclude .git --exclude vendor/bin/phpcbf --exclude vendor/bin/phpcs --exclude vendor/bin/phpunit --exclude vendor/bin/simple-phpunit /var/www/project/ /rsync; done;'

stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose$(WINDOWS_SUPPORT) stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose$(WINDOWS_SUPPORT) down -v

ps:
	@docker$(WINDOWS_SUPPORT) ps --filter name="$(PROJECT_NAME)*"

shell:
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash

uli:
	@echo "Getting admin login"
	docker-compose$(WINDOWS_SUPPORT) run  drush uli --root=/var/www/project$(PROJECT_GIT_DOCROOT) --uri="$(PROJECT_BASE_URL)":$(PROJECT_PORT)3

install-source:
	@echo "Installing dependencies"
	docker-compose$(WINDOWS_SUPPORT) run web composer install --prefer-source

install:
	@echo "Installing dependencies"

	@echo "Cleaning up workspace"
	rm -rf data/www/project/ > /dev/null 2>&1
	@echo "Cloning codebase"
	git clone $(PROJECT_GIT) data/www/project$(PROJECT_GIT_BASE)
	mkdir data/www/project$(PROJECT_GIT_DOCROOT)/sites/local.$(PROJECT_NAME).com
	cp config/drupal/settings.php data/www/project$(PROJECT_GIT_DOCROOT)/sites/local.$(PROJECT_NAME).com/settings.php

	sed -i -e 's/PROJECT_NAME/$(PROJECT_NAME)/g' data/www/project$(PROJECT_GIT_DOCROOT)/sites/local.$(PROJECT_NAME).com/settings.php


sync:
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  'rm -rf /root/.composer && composer global require drush/drush:7.*'
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  'echo "drop database $(PROJECT_NAME);" | mysql -uroot -h mysql --password="root"'
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  'echo "create database $(PROJECT_NAME);" | mysql -uroot -h mysql --password="root"'
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  'mysql -u root -h mysql -p $(PROJECT_NAME) --password="root" < /var/www/dump.sql'
	make cr

cr:
	@echo "Clearing Drupal Caches"
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(PROJECT_NAME)_web bash -c  'drush cc all --root=/var/www/project$(PROJECT_GIT_DOCROOT)'

logs:
	@echo "Displaying past containers logs"
	docker-compose$(WINDOWS_SUPPORT) logs

logsf:
	@echo "Follow containers logs output"
	docker-compose$(WINDOWS_SUPPORT) logs -f

composer:
	cd data/www/project && composer install
	cd data/www/project$(PROJECT_GIT_DOCROOT) && composer install
