FROM frappe/erpnext:v15

WORKDIR /home/frappe/frappe-bench

# Create a default site with SQLite (for testing only)
RUN bench new-site test.localhost \
    --db-type sqlite \
    --admin-password admin \
    --install-app erpnext \
    --install-app hrms \
    --no-mariadb-socket

# Set the default site
RUN echo "test.localhost" > /home/frappe/frappe-bench/sites/currentsite.txt

EXPOSE 8000

CMD ["bench", "start"]
