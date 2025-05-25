FROM wordpress:6.4-php8.2-apache

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    netcat-traditional default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy custom entrypoint
COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# Set entrypoint
ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["apache2-foreground"]
