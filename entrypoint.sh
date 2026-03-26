#!/bin/sh
set -euo pipefail
sudo chown -R flipt:flipt /var/opt/flipt
exec /flipt server