#!/bin/bash
set -e

cd /home/frappe/frappe-bench

# Start Redis
redis-server --daemonize yes --bind 127.0.0.1 --port 11000

# Wait for Redis
sleep 3

# Configure Redis in common_site_config
cat > sites/common_site_config.json << EOF
{
  "default_site": "erp.localhost",
  "redis_cache": "redis://127.0.0.1:11000",
  "redis_queue": "redis://127.0.0.1:11000",
  "redis_socketio": "redis://127.0.0.1:11000"
}
EOF

# Create Procfile for production
cat > Procfile << 'EOF'
web: gunicorn -b 0.0.0.0:8000 --workers 2 --worker-class gthread --threads 4 --timeout 120 frappe.app:application --preload
EOF

# Create site if it doesn't exist
if [ ! -d "sites/erp.localhost" ]; then
  echo "Creating new ERPNext site..."
  bench new-site erp.localhost \
    --db-root-username ${DB_ROOT_USERNAME:-erpnextadmin} \
    --mariadb-root-password ${MYSQL_ROOT_PASSWORD} \
    --admin-password ${ADMIN_PASSWORD:-admin} \
    --db-host ${DB_HOST} \
    --install-app erpnext
  
  bench use erp.localhost
fi

# Start gunicorn directly
exec gunicorn -b 0.0.0.0:8000 \
  --workers 2 \
  --worker-class gthread \
  --threads 4 \
  --timeout 120 \
  --chdir /home/frappe/frappe-bench/sites \
  frappe.app:application \
  --preload
