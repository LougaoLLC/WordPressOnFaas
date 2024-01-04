#!/bin/bash
set -euo pipefail

# wait util /tmp/php-fpm.sock is exist
echo "Waiting for php-fpm.sock"
while [ ! -e /tmp/php-fpm.sock ]; do
    usleep 20000 
done

echo "Waiting for php-fpm.sock to be ready"
# wait upstream server availability then start NGINX service
while ! echo hello | socat - UNIX-CONNECT:/tmp/php-fpm.sock; do
    usleep 20000 
done

echo "php-fpm.sock is ready, starting NGINX service"
