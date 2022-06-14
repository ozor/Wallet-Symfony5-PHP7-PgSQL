FROM composer:2.3.7 AS composer
FROM php:7.4-fpm

RUN apt-get update \
  && apt-get install -y \
        wget git unzip \
        libpq-dev \
        curl libxml2-dev \
  && docker-php-ext-install pdo pdo_pgsql pdo_mysql

# Add Xdebug INI file
#COPY xdebug.ini /etc/php/7.3/mods-available/xdebug.ini

COPY memory-limit-php.ini /usr/local/etc/php/conf.d/memory-limit-php.ini

# Get Symfony Installer
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv $HOME/.symfony/bin/symfony /usr/local/bin/symfony

# Install Composer
ARG COMPOSER_TOKEN
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer config --global --auth github-oauth.github.com $COMPOSER_TOKEN

# Install PHPUnit
RUN wget -O phpunit https://phar.phpunit.de/phpunit-9.phar && chmod +x phpunit \
    && mv ./phpunit /usr/local/bin/phpunit

WORKDIR /var/www

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data && chown -R www-data:www-data /var/www

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint