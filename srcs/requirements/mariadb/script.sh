#!/bin/bash

# Vérifier s'il y a déjà un processus MariaDB et le tuer
echo "🔍 Vérification des processus MariaDB..."
if pgrep mysqld > /dev/null; then
    echo "❌ MariaDB est déjà en cours d'exécution. Arrêt forcé..."
    killall -9 mysqld mysqld_safe
fi

# Supprimer les fichiers de verrouillage MariaDB (évite les erreurs aria_log_control)
echo "🧹 Suppression des fichiers de verrouillage..."
rm -f /var/lib/mysql/aria_log_control /var/lib/mysql/aria_log.*

# Créer le répertoire de socket s'il n'existe pas et donner les bons droits
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialiser la base de données si elle n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🆕 Initialisation de la base de données..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

# Démarrer MariaDB en arrière-plan
echo "🚀 Démarrage de MariaDB..."
mysqld --bind-address=0.0.0.0 &
sleep 5

# Vérifier que MariaDB est bien accessible
TIMEOUT=60
TIMER=0
while ! mysqladmin ping -h "localhost" --silent; do
    echo "⌛ En attente de MariaDB..."
    sleep 2
    TIMER=$((TIMER+2))
    if [ "$TIMER" -ge "$TIMEOUT" ]; then
        echo "❌ MariaDB ne répond pas après 60 secondes. Abandon."
        exit 1
    fi
done

echo "✅ MariaDB est prêt, exécution des commandes SQL..."

# Exécuter les commandes SQL pour créer la base et les utilisateurs
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Vérifier que les utilisateurs existent bien
mysql -u root -p"${DB_PASS}" -e "SELECT User, Host FROM mysql.user;"

# Fermer MariaDB proprement
sleep 2
mysqladmin -u root -p"${DB_PASS}" shutdown

# Lancer MariaDB en mode normal
exec mysqld
