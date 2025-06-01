#!/bin/bash
set -e

cd /var/www/html

# Fonction pour attendre que la base de données soit prête
wait_for_db() {
    echo "🔄 Attente de la connexion à la base de données MySQL..."
    
    # Extraire l'hôte et le port de WORDPRESS_DB_HOST
    DB_HOST=$(echo $WORDPRESS_DB_HOST | cut -d: -f1)
    DB_PORT=$(echo $WORDPRESS_DB_HOST | cut -d: -f2)
    
    # Attendre que le port MySQL soit disponible
    while ! nc -z $DB_HOST $DB_PORT; do
        echo "⏳ MySQL n'est pas encore disponible, nouvelle tentative dans 5 secondes..."
        sleep 5
    done
    
    # Attendre que MySQL accepte les connexions
    max_attempts=30
    counter=0
    while ! mysql -h$DB_HOST -P$DB_PORT -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "SELECT 1" >/dev/null 2>&1; do
        counter=$((counter+1))
        if [ $counter -ge $max_attempts ]; then
            echo "❌ Impossible de se connecter à MySQL après $max_attempts tentatives. Abandon."
            exit 1
        fi
        echo "⏳ MySQL n'accepte pas encore les connexions, nouvelle tentative dans 5 secondes... ($counter/$max_attempts)"
        sleep 5
    done
    
    echo "✅ Connexion à la base de données MySQL établie!"
}

# Vérifier si WordPress est déjà téléchargé
if [ ! -f wp-includes/version.php ]; then
    echo "📥 Téléchargement de WordPress..."
    wp core download --allow-root
else
    echo "✓ WordPress est déjà téléchargé."
fi

# Attendre que la base de données soit prête AVANT de configurer WordPress
wait_for_db

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

chown -R www-data:www-data /var/www/html

exec apache2-foreground
