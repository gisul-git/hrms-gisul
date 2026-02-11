FROM frappe/erpnext:v15

WORKDIR /home/frappe/frappe-bench

# Install Redis
USER root
RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/*
USER frappe

# Create initialization script
COPY --chown=frappe:frappe init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 8000

CMD ["/usr/local/bin/init.sh"]
