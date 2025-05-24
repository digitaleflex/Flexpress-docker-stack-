#!/bin/bash
set -e

# Fonction de génération de mot de passe fort
generate_password() {
    openssl rand -base64 16
}

# Génération de mots de passe si non définis
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD=$(generate_password)
    echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
fi

if [ -z "$WORDPRESS_DB_PASSWORD" ]; then
    WORDPRESS_DB_PASSWORD=$(generate_password)
    echo "WORDPRESS_DB_PASSWORD=$WORDPRESS_DB_PASSWORD"
fi

if [ -z "$WORDPRESS_ADMIN_PASSWORD" ]; then
    WORDPRESS_ADMIN_PASSWORD=$(generate_password)
    echo "WORDPRESS_ADMIN_PASSWORD=$WORDPRESS_ADMIN_PASSWORD"
fi

# Exposition dans un fichier temporaire dans le container
cat <<EOF > /tmp/flexpress-init-secrets.log
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
WORDPRESS_DB_PASSWORD=$WORDPRESS_DB_PASSWORD
WORDPRESS_ADMIN_PASSWORD=$WORDPRESS_ADMIN_PASSWORD
EOF

# Exportation dans l'environnement
export MYSQL_ROOT_PASSWORD
export WORDPRESS_DB_PASSWORD
export WORDPRESS_ADMIN_PASSWORD

echo "[Flexpress] Secrets générés. Accès temporaire dans /tmp/flexpress-init-secrets.log"


# Appel de l'installation WordPress si nécessaire
bash /var/www/html/setup-wp.sh

# Démarrage d'Apache via l'entrypoint officiel
exec docker-entrypoint.sh apache2-foreground
