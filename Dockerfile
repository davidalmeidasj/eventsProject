FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    && docker-php-ext-install pdo pdo_mysql

RUN echo "display_errors=On" >> /usr/local/etc/php/php.ini
RUN echo "display_startup_errors=On" >> /usr/local/etc/php/php.ini
RUN echo "error_reporting=E_ALL" >> /usr/local/etc/php/php.ini

RUN curl -sS -o /usr/local/bin/dockerize https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64 \
    && chmod +x /usr/local/bin/dockerize

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY composer.json /var/www/html/composer.json
COPY phinx.php /var/www/html/phinx.php

RUN composer install

COPY src /var/www/html/src
COPY public /var/www/html/public
COPY db /var/www/html/db

RUN a2enmod rewrite

COPY apache.conf /etc/apache2/sites-available/000-default.conf

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

CMD ["bash", "-c", "/wait-for-it.sh db:3306 -- composer install && composer dump-autoload && vendor/bin/phinx migrate && apache2-foreground"]
