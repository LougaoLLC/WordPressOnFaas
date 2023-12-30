#!/bin/bash
set -euo pipefail

/usr/bin/spawn-fcgi -s /run/fcgiwrap.socket -M 766 /usr/bin/fcgiwrap

exec "$@"
