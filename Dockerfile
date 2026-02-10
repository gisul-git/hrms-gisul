FROM frappe/erpnext:v15

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy your custom apps
COPY ./apps /home/frappe/frappe-bench/apps
COPY ./sites /home/frappe/frappe-bench/sites

# Expose port
EXPOSE 8000

# Start command
CMD ["bench", "start"]
