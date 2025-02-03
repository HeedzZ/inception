#!/bin/bash

echo "📡 Vérification de MariaDB avant installation de WordPress..."

TIMEOUT=60
TIMER=0
while ! mysqladmin ping -h "mariadb" --silent; do
    echo "⌛ En attente de MariaDB..."
    sleep 2
    TIMER=$((TIMER+2))
    if [ "$TIMER" -ge "$TIMEOUT" ]; then
        echo "❌ MariaDB ne répond pas après 60 secondes. Abandon."
        exit 1
    fi
done

echo "✅ MariaDB est prêt, installation de WordPress..."

cd /var/www/html

# Télécharger WP-CLI si non présent
if [ ! -f "wp-cli.phar" ]; then
    echo "📥 Téléchargement de WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi

# Télécharger WordPress si non installé
if [ ! -f "wp-config.php" ]; then
    echo "📥 Téléchargement de WordPress..."
    ./wp-cli.phar core download --allow-root
fi

# Configurer WordPress
if [ ! -f "wp-config.php" ]; then
    echo "⚙️ Configuration de WordPress..."
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    echo "✅ wp-config.php existe déjà."
fi

# Vérifier si WordPress est déjà installé
if ! ./wp-cli.phar core is-installed --allow-root; then
    echo "🛠 Installation de WordPress..."
    ./wp-cli.phar core install \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root
else
    echo "✅ WordPress est déjà installé."
fi

# Lancer PHP-FPM
echo "🚀 Démarrage de PHP-FPM..."
php-fpm8.2 -F
