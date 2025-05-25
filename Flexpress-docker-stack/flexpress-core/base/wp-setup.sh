#!/bin/bash
set -eo pipefail

cd /var/www/html

# Vérifier si WordPress est déjà téléchargé
if [ ! -f wp-includes/version.php ]; then
    echo "📥 Téléchargement de WordPress..."
    wp core download --allow-root
else
    echo "✓ WordPress est déjà téléchargé."
fi

# Supprimer wp-config.php s'il existe pour éviter les erreurs
if [ -f wp-config.php ]; then
    echo "🗑️ Suppression de l'ancien fichier wp-config.php..."
    rm wp-config.php
fi

echo "⚙️ Configuration de wp-config.php..."
wp config create \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --allow-root

# Si le mode debug est activé
if [ "${WORDPRESS_DEBUG}" = "1" ]; then
    echo "🔍 Activation du mode debug..."
    wp config set WP_DEBUG true --raw --allow-root
    wp config set WP_DEBUG_LOG true --raw --allow-root
    wp config set WP_DEBUG_DISPLAY true --raw --allow-root
fi

# Vérifier si WordPress est déjà installé
if ! wp core is-installed --allow-root; then
    echo "🛠️ Installation de WordPress..."
    wp core install \
        --url="${WORDPRESS_SITE_URL:-http://localhost:8080}" \
        --title="${WORDPRESS_SITE_TITLE:-Flexpress Core}" \
        --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD:-admin}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email \
        --allow-root

    echo "✅ WordPress installé avec succès."
else
    echo "✓ WordPress est déjà installé."
fi

# Définir les permissions
echo "🔒 Configuration des permissions..."
chown -R www-data:www-data /var/www/html

echo "✅ Configuration WordPress terminée." 