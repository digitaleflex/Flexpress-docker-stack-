#!/bin/bash

ENV_FILE=".env"

# Fonction de génération de mot de passe robuste
generate_password() {
    openssl rand -base64 18
}

# Création automatique du .env si absent
if [ ! -f "$ENV_FILE" ]; then
    echo "🔐 Génération automatique du fichier .env..."

    DB_NAME="flexpressdb"
    DB_USER="user_$(openssl rand -hex 4)"
    DB_PASS="$(generate_password)"
    DB_ROOT_PASS="$(generate_password)"

    WP_ADMIN_USER="admin"
    WP_ADMIN_PASS="$(generate_password)"
    WP_ADMIN_EMAIL="admin@example.com"

    cat <<EOF > $ENV_FILE
# Base de données MySQL
WORDPRESS_DB_HOST=db:3306
WORDPRESS_DB_NAME=$DB_NAME
WORDPRESS_DB_USER=$DB_USER
WORDPRESS_DB_PASSWORD=$DB_PASS
MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS

# Paramètres WordPress
WORDPRESS_SITE_URL=http://localhost
WORDPRESS_SITE_TITLE=Flexpress Core
WORDPRESS_ADMIN_USER=$WP_ADMIN_USER
WORDPRESS_ADMIN_PASSWORD=$WP_ADMIN_PASS
WORDPRESS_ADMIN_EMAIL=$WP_ADMIN_EMAIL
EOF

    echo "✅ Fichier .env généré avec succès."
    echo "👤 Identifiants administrateur WordPress :"
    echo "   ➤ Utilisateur : $WP_ADMIN_USER"
    echo "   ➤ Mot de passe : $WP_ADMIN_PASS"
else
    echo "🟢 Le fichier .env existe déjà. Aucune modification effectuée."
fi
