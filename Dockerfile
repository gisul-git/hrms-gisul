FROM frappe/erpnext:v15.latest

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy custom apps if you have any
# COPY ./apps /home/frappe/frappe-bench/apps

# Expose port
EXPOSE 8000

# Start command
CMD ["bench", "start"]
