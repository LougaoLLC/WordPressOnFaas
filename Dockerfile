# Pull in dependencies with composer
FROM composer:2.5 as build
COPY opentelemetry/composer.json ./
RUN composer install --ignore-platform-reqs

FROM wordpress:6.4.3-php8.3-fpm-alpine

# install install-php-extensions by docker image
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN apk add --no-cache \
     nginx \
     socat \
     fcgiwrap \
     spawn-fcgi 

# Install extensions
RUN install-php-extensions opentelemetry-stable grpc-stable protobuf-stable redis-stable mongodb-stable

# Configure nginx - default server
COPY ng/nginx.conf /etc/nginx/nginx.conf
COPY ng/conf.d /etc/nginx/conf.d/
COPY ng/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-nginx.sh
COPY ng/wait-fpm.sh /var/www/wait-fpm.sh

# Configure Database
ENV WORDPRESS_DB_NAME=""
ENV WORDPRESS_DB_USER=""
ENV WORDPRESS_DB_PASSWORD=""
ENV WORDPRESS_DB_HOST=""
ENV WORDPRESS_DB_CHARSET="utf8mb4"
ENV WORDPRESS_DB_COLLATE="utf8mb4_unicode_ci"
ENV WORDPRESS_TABLE_PREFIX="wp_"

# Configure PHP
ENV PHP_MEMORY_LIMIT="256M"
ENV PHP_UPLOAD_MAX_FILESIZE="50M"
ENV PHP_POST_MAX_SIZE="50M"
ENV PHP_MAX_EXECUTION_TIME="90"
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
COPY wp/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# Configure PHP-FPM
COPY wp/www.conf /usr/local/etc/php-fpm.d/www.conf
ENV PHP_FPM_USER="www-data"
ENV PHP_FPM_GROUP="www-data"

# Configure OpenTelemetry
COPY opentelemetry/otel.php.ini "$PHP_INI_DIR/conf.d/otel.php.ini"
COPY --from=build /app/vendor /var/www/otel

ENV OTEL_PHP_AUTOLOAD_ENABLED=false
ENV OTEL_PHP_INTERNAL_METRICS_ENABLED=false
ENV OTEL_SERVICE_NAME="<your-service-name>"
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_LOGS_EXPORTER=none
ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc
ENV OTEL_EXPORTER_OTLP_ENDPOINT="<endpoint>"
ENV OTEL_EXPORTER_OTLP_HEADERS=Authentication="<token>"
ENV OTEL_PROPAGATORS=baggage,tracecontext

# Configure WordPress
COPY wp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENV WORDPRESS_MEMORY_LIMIT="450M"
ENV MY_WP_CONTENT_DIR="/data/wp-content"

# Generate WordPress salts from https://api.wordpress.org/secret-key/1.1/salt/
ENV WORDPRESS_AUTH_KEY=""
ENV WORDPRESS_SECURE_AUTH_KEY=""
ENV WORDPRESS_LOGGED_IN_KEY=""
ENV WORDPRESS_NONCE_KEY=""
ENV WORDPRESS_AUTH_SALT=""
ENV WORDPRESS_SECURE_AUTH_SALT=""
ENV WORDPRESS_LOGGED_IN_SALT=""
ENV WORDPRESS_NONCE_SALT=""

# TiDB Serverless
COPY tidb-serverless/tidb-compatibility.php /usr/src/wordpress/wp-content/mu-plugins/tidb-compatibility.php

WORKDIR /var/www/html

RUN mkdir -p /data/wp-content; \
    chown -R www-data:www-data /data/wp-content; \
    mkdir -p /run; \
    mkdir -p /var/cache/nginx/fastcgi; \ 
    chown -R www-data:www-data /var/www/otel; \
    chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx /var/cache/nginx; \
    rm -rf /usr/local/etc/php-fpm.d/zz-docker.conf || true; \
    sed -i "s/^require_once ABSPATH . 'wp-settings.php';//g" /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'AUTOMATIC_UPDATER_DISABLED', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_AUTO_UPDATE_CORE', false );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'DISABLE_WP_CRON', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_MEMORY_LIMIT', '${WORDPRESS_MEMORY_LIMIT}' );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "require_once ABSPATH . 'wp-settings.php';" >> /usr/src/wordpress/wp-config-docker.php

# Expose the port nginx is reachable on
EXPOSE 8080

USER www-data

COPY bootstrap /usr/local/bin/bootstrap
ENTRYPOINT ["bootstrap"]
CMD ["wordpress"]

