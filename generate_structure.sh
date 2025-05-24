#!/bin/bash

# Nom de base du projet
PROJECT_NAME="Flexpress-docker-stack"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# Définition des répertoires et fichiers
declare -A STRUCTURE=(
  ["base"]="Dockerfile php.ini nginx/default.conf scripts/setup-wp.sh"
  ["pro-dev"]="Dockerfile docker-compose.yml wp-config-pro.php .env.example"
  ["no-code"]="Dockerfile docker-compose.yml onboarding.sh starter-themes/astra.zip"
  ["db"]="Dockerfile my.cnf"
  ["tools"]="docker-compose.override.yml redis.conf"
  ["ci-cd"]="build.sh deploy.sh"
  ["."]=".gitignore LICENSE README.md CHANGELOG.md"
)

echo "📁 Création de la structure du projet $PROJECT_NAME..."

# Parcours de la structure
for dir in "${!STRUCTURE[@]}"; do
  for file in ${STRUCTURE[$dir]}; do
    full_path="$dir/$file"
    mkdir -p "$(dirname "$full_path")"
    touch "$full_path"
    echo "📝 $full_path créé"
  done
done

echo "✅ Structure du projet générée avec succès."
