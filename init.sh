#!/bin/bash
set -e

# Start Redis
redis-server --daemonize yes --bind 127.0.0.1 --port 11000

# Wait for Redis
sleep 2

# Configure Redis in common_site_config
cd /home/frappe/frappe-bench
cat > sites/common_site_config.json << EOF
{
  "default_site": "erp.localhost",
  "redis_cache": "redis://127.0.0.1:11000",
  "redis_queue": "redis://127.0.0.1:11000",
  "redis_socketio": "redis://127.0.0.1:11000"
}
EOF

# Create site if it doesn't exist
if [ ! -d "sites/erp.localhost" ]; then
  bench new-site erp.localhost \
    --db-root-username ${DB_ROOT_USERNAME:-erpnextadmin} \
    --mariadb-root-password ${MYSQL_ROOT_PASSWORD} \
    --admin-password ${ADMIN_PASSWORD:-admin} \
    --db-host ${DB_HOST} \
    --install-app erpnext || true
  
  bench use erp.localhost
fi

# Start bench
exec bench start
