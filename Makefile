# Want to run Docker commands without `sudo`?
#    https://github.com/sindresorhus/guides/blob/master/docker-without-sudo.md

UID = $(shell id -u)
GUID = $(shell id -g)

up:
	docker-compose up -d
down:
	docker-compose down
restart:
	make down
	make up
	make cc
rebuild:
	make cc
	docker-compose down
	docker-compose up --build -d
	make update-chmod

update-chmod:
	sudo chown ${USER}:${USER} -R .
	#sudo chmod -R 777 ./var/cache/
cc:
	docker-compose exec php bash -c "bin/console cache:clear  --no-warmup"
	make update-chmod
	#sudo rm -Rf ./var/cache/*

composer:
	docker-compose exec php bash -c "composer install"
composer-update:
	make cc
	docker-compose exec php bash -c "composer clearcache"
	docker-compose exec php bash -c "composer update --no-cache"
	make update-chmod

migrate:
	docker-compose exec php bash -c "bin/console doctrine:migrations:migrate --quiet"
	make update-chmod
migrate-prev:
	docker-compose exec php bash -c "bin/console doctrine:migrations:migrate prev --quiet"
	make update-chmod

create-migration:
	docker-compose exec php bash -c "bin/console doctrine:migrations:generate --quiet"
	make update-chmod
diff:
	docker-compose exec php bash -c "bin/console doctrine:migrations:diff"
	make update-chmod

update-project:
	# Want to `sudo` never ask for your password? Do the next:
	# Open a Terminal window and type:
	#    sudo visudo
	# In the bottom of the file, add the following line:
	#    your_username ALL=(ALL) NOPASSWD: ALL
	make cc
	docker-compose exec php bash -c "composer install"
	docker-compose exec php bash -c "bin/console doctrine:migrations:migrate --quiet"
	make update-chmod

db-drop:
	docker-compose exec php bash -c "bin/console doctrine:database:drop --force"
db-create:
	docker-compose exec php bash -c "bin/console doctrine:database:create"

rebuild-schema:
	make update-chmod
	docker-compose exec php bash -c "bin/console doctrine:database:drop --force"
	make cc
	docker-compose exec php bash -c "bin/console doctrine:database:create"
	make diff
	make update-chmod

db-install:
	docker-compose exec wallet-php bash -c "bin/console doctrine:migrations:migrate --quiet"
	docker-compose exec wallet-php bash -c "bin/console doctrine:fixtures:load --no-interaction"
reinstall:
	make cc
	make db-drop
	docker-compose down
	make init

install:
	make update-chmod
	docker-compose exec php bash -c "composer install"
	docker-compose exec php bash -c "bin/console doctrine:database:create"
	make db-install
	make update-chmod

init:
	# If you have this error:
	#    ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?
	# The issue maybe in rights.
	# This command should help (maybe restart would be needed):
	#    sudo usermod -aG docker ${USER}
	# or use ´sudo´
	docker-compose build
	docker-compose up -d
	make install

windows-init:
	docker-compose up --build -d
	sed -i 's/\r//g' bin/console
	make install
