#!/bin/bash
set -eo pipefail

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

# Attendre que la base de données soit prête
wait_for_db

# Activer le mode debug si demandé
if [ "${WORDPRESS_DEBUG}" = "1" ]; then
  # Le fichier sera créé par l'entrypoint WordPress original
  export WORDPRESS_CONFIG_EXTRA="
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
"
fi

# Exécuter l'entrypoint original de WordPress avec les arguments passés
echo "🚀 Démarrage de WordPress..."
exec docker-entrypoint.sh "$@" 