#!/bin/bash

# Attendre que MariaDB soit prêt avant d'exécuter la configuration de WordPress
until mysql -h "mariadb" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" &> /dev/null; do
    echo "En attente de MariaDB..."
    sleep 2
done

echo "MariaDB est prêt, installation de WordPress..."

cd /var/www/html

# Télécharger WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

# Télécharger WordPress
./wp-cli.phar core download --allow-root

# Vérifier si wp-config.php existe déjà avant de le recréer
if [ ! -f "wp-config.php" ]; then
    echo "Création de wp-config.php..."
    ./wp-cli.phar config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    echo "wp-config.php existe déjà, pas besoin de le recréer."
fi

# Vérifier si WordPress est déjà installé
if ! ./wp-cli.phar core is-installed --allow-root; then
    echo "Installation de WordPress..."
    ./wp-cli.phar core install \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root
else
    echo "WordPress est déjà installé."
fi

# Lancer PHP-FPM
php-fpm8.2 -F