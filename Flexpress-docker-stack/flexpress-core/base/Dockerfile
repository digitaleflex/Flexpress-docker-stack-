FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip less mariadb-client curl git wget \
    && docker-php-ext-install pdo pdo_mysql zip \
    && pecl install redis && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*

# Setup PHP config
COPY php.ini /usr/local/etc/php/

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install WP-CLI
ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

# Copy custom setup script
COPY setup-wp.sh /usr/local/bin/setup-wp.sh
RUN chmod +x /usr/local/bin/setup-wp.sh

# Set working directory
WORKDIR /var/www/html

# Entrypoint
ENTRYPOINT ["setup-wp.sh"]
