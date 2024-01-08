FROM wordpress:6.4.2-php8.3-apache
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.1 /lambda-adapter /opt/extensions/lambda-adapter

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
ENV PHP_MAX_EXECUTION_TIME="60"
ENV PHP_MAX_INPUT_TIME="-1"
ENV PHP_MAX_INPUT_VARS="1000"
# OPcache 
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_REVALIDATE_FREQUENCY="0"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"
ENV PHP_FPM_USER=sbx_user1051
# Copy the PHP configuration file
COPY wp/php.ini "$PHP_INI_DIR/conf.d/php.ini"
COPY wp/opcache.ini "$PHP_INI_DIR/conf.d/opcache-recommended.ini"

# Configure Apache
ENV APACHE_PID_FILE="/tmp/httpd.pid"
ENV APACHE_RUN_USER="sbx_user1051"

# Configure WordPress
ENV MY_WP_MEMORY_LIMIT="450M"
ENV MY_WP_CONTENT_DIR="/mnt/wp-content"
ENV MY_WP_WORKDIR="/tmp/www/html"
ENV MY_WP_WORKDIR_PARENT="/tmp/www"
ENV PHP_OPCACHE_PRELOAD="${MY_WP_WORKDIR}/preload.php"

COPY wp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY wp/preload.php /usr/src/wordpress/preload.php

# TiDB Serverless
COPY tidb-serverless/tidb-compatibility.php /usr/src/wordpress/wp-content/mu-plugins/tidb-compatibility.php

RUN apt-get update; \
    apt-get install -y cron; \
    useradd sbx_user1051; \
    sed -i s/80/8080/ /etc/apache2/ports.conf /etc/apache2/sites-enabled/000-default.conf; \
    sed -i s,/var/www/html,${MY_WP_WORKDIR}, /etc/apache2/sites-enabled/000-default.conf; \
    sed -i s,/var/www,${MY_WP_WORKDIR_PARENT}, /etc/apache2/apache2.conf; \
    mkdir -p ${MY_WP_CONTENT_DIR} ${MY_WP_WORKDIR}; \
    chown -R sbx_user1051:sbx_user1051 ${MY_WP_CONTENT_DIR} ${MY_WP_WORKDIR}; \
    sed -i "s/^require_once ABSPATH . 'wp-settings.php';//g" /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'AUTOMATIC_UPDATER_DISABLED', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_AUTO_UPDATE_CORE', false );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_MEMORY_LIMIT', '${MY_WP_MEMORY_LIMIT}' );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'DISABLE_WP_CRON', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "define( 'WP_CACHE', true );" >> /usr/src/wordpress/wp-config-docker.php; \
    echo "require_once ABSPATH . 'wp-settings.php';" >> /usr/src/wordpress/wp-config-docker.php

# Expose the port apache is reachable on
EXPOSE 8080
USER sbx_user1051

ENV READINESS_CHECK_PORT="8080"
ENV READINESS_CHECK_PATH="/"
ENV AWS_LWA_READINESS_CHECK_MIN_UNHEALTHY_STATUS="502"

