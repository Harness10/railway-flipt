#!/bin/sh
set -euo pipefail
sudo chown -R flipt:flipt /var/opt/flipt

# Railway Debugging
echo "HOME=$HOME"
echo "XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-not set}"
ls -la $HOME/.config/flipt/ 2>&1 || echo "config dir not found"

exec /flipt server