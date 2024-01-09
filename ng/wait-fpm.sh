#!/bin/bash
set -euo pipefail

echo 'Content-Type: text/plain'

# wait util /run/php-fpm.sock is exist
while [ ! -e /run/php-fpm.sock ]; do
    usleep 10000 
done

# wait upstream server availability then start NGINX service
while ! echo hello | socat - UNIX-CONNECT:/run/php-fpm.sock; do
    usleep 10000 
done

echo ''
