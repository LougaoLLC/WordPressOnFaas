FROM --platform=linux/amd64 wordpress:6.4.2-php8.3-apache

# Configure Database
ENV WORDPRESS_DB_NAME=""
ENV WORDPRESS_DB_USER=""
ENV WORDPRESS_DB_PASSWORD=""
ENV WORDPRESS_DB_HOST=""
ENV WORDPRESS_DB_CHARSET="utf8mb4"
ENV WORDPRESS_DB_COLLATE="utf8mb4_unicode_ci"
ENV WORDPRESS_TABLE_PREFIX="wp_"

# Configure PHP
ENV PHP_MEMORY_LIMIT="128M"
ENV PHP_UPLOAD_MAX_FILESIZE="50M"
ENV PHP_POST_MAX_SIZE="50M"
ENV PHP_MAX_EXECUTION_TIME="60"
ENV PHP_MAX_INPUT_TIME="-1"
ENV PHP_MAX_INPUT_VARS="1000"
# Copy the PHP configuration file
COPY wp/php.ini "$PHP_INI_DIR/conf.d/php.ini"
# OPcache 
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_REVALIDATE_FREQUENCY="0"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"
ENV PHP_OPCACHE_PRELOAD="/var/www/html/preload.php"
COPY wp/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# Configure WordPress
COPY wp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chown=www-data:www-data wp/preload.php ${PHP_OPCACHE_PRELOAD}

WORKDIR /var/www/html

RUN sed -i 's#Listen 80#Listen 8080#g' /etc/apache2/ports.conf; \
    mkdir -p /data/wp-content; \
    chown -R www-data:www-data /data/wp-content; \
    chown -R www-data:www-data /var/www/html; \
    rm -rf /usr/local/etc/php-fpm.d/zz-docker.conf || true; \
    sed -i "s/^require_once ABSPATH . 'wp-settings.php';//g" /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'AUTOMATIC_UPDATER_DISABLED', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_AUTO_UPDATE_CORE', false );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'DISABLE_WP_CRON', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "require_once ABSPATH . 'wp-settings.php';" >> /usr/src/wordpress/wp-config-docker.php

# Use pg4wp instead of mysql 
# https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/tags/v3.0.zip
# Don't put the pg4wp in wp-content/plugins, because it may be deleted by user.
# The v3.0 has a bug, so we fixed it, and copy the directory to image.
# Bug issue: https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/issues/87
COPY pg4wp /usr/src/wordpress/wp-content/pg4wp

RUN apt-get update && \
    apt-get install -y zip cron libpq-dev && \
    docker-php-ext-install pgsql pdo pdo_pgsql && \
    cp /usr/src/wordpress/wp-content/pg4wp/db.php /usr/src/wordpress/wp-content/db.php 

# Expose the port apache is reachable on
EXPOSE 8080

USER www-data

