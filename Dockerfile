ARG PHP_VERSION=8.4
ARG USER_ID=1000
ARG GROUP_ID=1000
FROM php:${PHP_VERSION}-cli
RUN apt-get update && apt-get install -y git unzip && rm -Rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN mkdir -p  /.composer/cache/ && chown -R ${USER_ID}:${GROUP_ID} /.composer/cache/

ENV XDEBUG_MODE=off
COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions xdebug
RUN echo ' \n\
[xdebug] \n\
xdebug.enable=1 \n\
xdebug.idekey=PHPSTORM \n\
xdebug.client_host=host.docker.internal\n ' >> /usr/local/etc/php/conf.d/xdebug.ini

USER ${USER_ID}:${GROUP_ID}

COPY composer.json .
RUN composer install
COPY --link . .
