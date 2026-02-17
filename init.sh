#!/bin/bash
set -e
cd /home/frappe/frappe-bench

# Start Redis
redis-server --daemonize yes --bind 127.0.0.1 --port 11000
sleep 3

# Configure Redis
cat > sites/common_site_config.json << EOF
{
  "default_site": "erp.localhost",
  "redis_cache": "redis://127.0.0.1:11000",
  "redis_queue": "redis://127.0.0.1:11000",
  "redis_socketio": "redis://127.0.0.1:11000"
}
EOF

# Wait for MariaDB to be ready
echo "Waiting for MariaDB at ${DB_HOST}..."
until mysqladmin ping -h "${DB_HOST}" -u root -p"${MARIADB_ROOT_PASSWORD}" --silent 2>/dev/null; do
    echo "MariaDB not ready yet, retrying in 5s..."
    sleep 5
done
echo "MariaDB is ready!"

# Create site if it doesn't exist
if [ ! -d "sites/erp.localhost" ]; then
  echo "Creating new ERPNext site..."
  bench new-site erp.localhost \
    --db-root-username root \
    --mariadb-root-password ${MARIADB_ROOT_PASSWORD} \
    --admin-password ${ADMIN_PASSWORD:-Admin@123} \
    --db-host ${DB_HOST} \
    --install-app erpnext

  bench use erp.localhost
  echo "Site created successfully!"
else
  echo "Site already exists, skipping creation..."
fi

# Start gunicorn
echo "Starting ERPNext..."
exec gunicorn -b 0.0.0.0:8000 \
  --workers 2 \
  --worker-class gthread \
  --threads 4 \
  --timeout 120 \
  --chdir /home/frappe/frappe-bench/sites \
  frappe.app:application \
  --preload
```
