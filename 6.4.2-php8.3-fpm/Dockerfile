FROM wordpress:6.4.2-php8.3-fpm-alpine

# Lambda Adapter
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.3.2 /lambda-adapter /opt/extensions/lambda-adapter

RUN apk add --no-cache \
    nginx \
    socat \
    supervisor

# Configure nginx - default server
COPY ng/nginx.conf /etc/nginx/nginx.conf
COPY ng/conf.d /etc/nginx/conf.d/
COPY ng/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-nginx.sh
COPY ng/wait-fpm.sh /usr/local/bin/wait-fpm.sh

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
ENV PHP_OPCACHE_PRELOAD="/usr/src/wordpress/preload.php"
COPY wp/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

# Configure PHP-FPM
COPY wp/www.conf /usr/local/etc/php-fpm.d/www.conf
ENV PHP_FPM_USER="www-data"
ENV PHP_FPM_GROUP="www-data"

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure WordPress
COPY wp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chown=www-data:www-data wp/preload.php ${PHP_OPCACHE_PRELOAD}

ENV DISABLE_XMLRPC="true"

# TiDB Serverless
COPY tidb-serverless/tidb-compatibility.php /usr/src/wordpress/wp-content/mu-plugins/tidb-compatibility.php

RUN mkdir -p /mnt/wordpress; \
    chown -R www-data:www-data /mnt/wordpress; \
    mkdir -p /tmp/var/www/html /tmp/var/cache/nginx/fastcgi /tmp/var/lib/nginx /tmp/var/cache/nginx; \ 
    chown -R www-data:www-data /tmp/var/www/html /tmp/var/lib/nginx /tmp/var/cache/nginx; \
    rm -rf /usr/local/etc/php-fpm.d/zz-docker.conf || true; \
    sed -i "s/^require_once ABSPATH . 'wp-settings.php';//g" /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'AUTOMATIC_UPDATER_DISABLED', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_AUTO_UPDATE_CORE', false );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'DISABLE_WP_CRON', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "require_once ABSPATH . 'wp-settings.php';" >> /usr/src/wordpress/wp-config-docker.php

WORKDIR /

# Expose the port nginx is reachable on
EXPOSE 8080

USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
