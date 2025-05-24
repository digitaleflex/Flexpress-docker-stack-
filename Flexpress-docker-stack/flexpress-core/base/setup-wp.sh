#!/bin/bash
set -e

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "📥 Téléchargement de WordPress..."
    wp core download --allow-root

    echo "⚙️ Configuration de wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root

    echo "🛠️ Installation de WordPress..."
    wp core install \
        --url="${WORDPRESS_SITE_URL:-http://localhost}" \
        --title="${WORDPRESS_SITE_TITLE:-Flexpress Core}" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD:-admin}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root

    echo "✅ WordPress installé avec succès."
fi

chown -R www-data:www-data /var/www/html

exec apache2-foreground
