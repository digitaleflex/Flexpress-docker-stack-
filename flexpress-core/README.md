# Flexpress Docker Stack

Une stack Docker pour WordPress optimisée et facile à déployer, avec attente automatique de la base de données.

## Prérequis

- Docker
- Docker Compose

## Structure du projet

```
flexpress-core/
├── base/                      # Fichiers de base pour l'image WordPress
│   ├── Dockerfile             # Configuration de l'image WordPress
│   └── docker-entrypoint-custom.sh  # Script d'entrée personnalisé
├── docker-compose.yml         # Configuration de la stack
└── README.md                  # Ce fichier
```

## Fonctionnalités

- WordPress 6.4 avec PHP 8.2
- MySQL 8.0 comme base de données
- Attente automatique de la base de données avant démarrage de WordPress
- Redémarrage automatique des conteneurs en cas d'erreur
- Mode debug activable

## Démarrage rapide

1. Cloner ce dépôt :
   ```bash
   git clone https://github.com/votre-utilisateur/Flexpress-docker-stack.git
   cd Flexpress-docker-stack/flexpress-core
   ```

2. Lancer la stack :
   ```bash
   docker compose up -d
   ```

3. Accéder à WordPress :
   - Interface WordPress : http://localhost:8080
   - Interface d'administration : http://localhost:8080/wp-admin/
   - Identifiants par défaut :
     - Utilisateur : admin
     - Mot de passe : admin

## Configuration

Les variables d'environnement suivantes peuvent être configurées dans le fichier `.env` (à créer) :

```
WORDPRESS_DB_NAME=flexpressdb
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=wppassword
MYSQL_ROOT_PASSWORD=rootpassword
WORDPRESS_DEBUG=1
```

## Volumes

- `wordpress_data` : Stocke les fichiers WordPress
- `db_data` : Stocke les données MySQL

## Ports

- WordPress : 8080
- MySQL : 3307 (accessible depuis l'hôte)

## Développement

Pour reconstruire l'image après modifications :

```bash
docker compose down
docker compose build
docker compose up -d
```

## Dépannage

Si WordPress ne démarre pas correctement :

1. Vérifier les logs : `docker compose logs -f`
2. S'assurer que les ports 8080 et 3307 sont disponibles
3. Vérifier les permissions des volumes
