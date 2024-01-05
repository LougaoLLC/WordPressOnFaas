#!/bin/bash
set -euo pipefail

mkdir -p /tmp/var/cache/nginx/fastcgi /tmp/var/lib/nginx /tmp/var/cache/nginx

exec "$@"
