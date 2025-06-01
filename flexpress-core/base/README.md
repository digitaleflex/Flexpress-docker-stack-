# Flexpress Base Image

Ce dossier contient les fichiers nécessaires pour construire l'image Docker WordPress personnalisée.

## Composants

### Dockerfile

Le Dockerfile est basé sur l'image officielle WordPress et ajoute:

- Des outils réseau (netcat) pour vérifier la disponibilité de la base de données
- Le client MySQL pour tester la connexion à la base de données
- Un script d'entrée personnalisé pour gérer l'attente de la base de données

### docker-entrypoint-custom.sh

Ce script est exécuté au démarrage du conteneur et:

1. Attend que la base de données MySQL soit disponible et accepte les connexions
2. Configure le mode debug si nécessaire via des variables d'environnement
3. Exécute l'entrypoint standard de WordPress pour finaliser l'installation

## Personnalisation

### Modification de l'image

Pour ajouter des extensions PHP ou des outils supplémentaires, modifiez le Dockerfile.

```dockerfile
# Exemple: Ajouter des extensions PHP supplémentaires
RUN docker-php-ext-install exif opcache
```

### Variables d'environnement supplémentaires

Pour ajouter des variables d'environnement personnalisées, modifiez `docker-entrypoint-custom.sh`:

```bash
# Exemple: Ajouter une configuration personnalisée
if [ "${CUSTOM_VARIABLE}" = "value" ]; then
  # Action personnalisée
fi
```

## Rebuilding

Après modification des fichiers, reconstruisez l'image:

```bash
docker compose build
``` 