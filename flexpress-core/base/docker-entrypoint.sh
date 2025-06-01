#!/bin/bash
set -eo pipefail

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

# Initialiser WordPress si nécessaire
initialize_wordpress() {
  echo "🚀 Initialisation de WordPress..."
  wp-setup.sh
  echo "✅ Initialisation terminée"
}

# Attendre que la base de données soit prête
wait_for_db

# Initialiser WordPress
initialize_wordpress

# Exécuter la commande fournie (généralement apache2-foreground)
exec "$@"
