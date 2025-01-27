#!/bin/bash

# Définir le chemin de WordPress
WP_PATH="/var/www/html"

# Télécharger et configurer WP-CLI si nécessaire
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Téléchargement de WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Vérifier si WordPress est déjà installé
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Installation de WordPress..."

    # Télécharger WordPress
    wp core download --path=$WP_PATH --allow-root

    # Créer le fichier de configuration wp-config.php
    wp config create \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PASS} \
        --dbhost=${DB_HOST:-mariadb} \
        --path=$WP_PATH \
        --allow-root

    # Installer WordPress
    wp core install \
        --url=${DOMAIN_NAME:-ymostows.42.fr} \
        --title=${SITE_TITLE:-inception} \
        --admin_user=${ADMIN_USER} \
        --admin_password=${ADMIN_PASS} \
        --admin_email=${ADMIN_EMAIL:-admin@admin.com} \
        --path=$WP_PATH \
        --allow-root

    echo "WordPress installé avec succès."
else
    echo "WordPress est déjà installé."

    # Mettre à jour les URLs si nécessaire
    echo "Mise à jour des URLs WordPress..."
    wp option update siteurl ${DOMAIN_NAME:-https://ymostows.42.fr} --path=$WP_PATH --allow-root
    wp option update home ${DOMAIN_NAME:-https://ymostows.42.fr} --path=$WP_PATH --allow-root
fi

# Lancer PHP-FPM
php-fpm8.2 -F
