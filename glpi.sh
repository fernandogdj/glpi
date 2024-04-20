#!/bin/bash

# Define as variáveis necessárias
DB_NAME="glpidb"
DB_USER="glpiuser"
DB_PASS="pwd"
GLPI_URL="https://github.com/glpi-project/glpi/releases/download/10.0.14/glpi-10.0.14.tgz"
GLPI_DIR="/var/www/html/glpi"

# Atualiza a lista de pacotes e instala o Apache, o MySQL e o PHP
sudo apt update
sudo apt install -y apache2 mariadb-server php php-mysql php-ldap php-imap php-xml php-mbstring php-curl php-gd unzip php-intl 

# Cria o banco de dados e o usuário
sudo mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Baixa e extrai o GLPI
sudo mkdir -p ${GLPI_DIR}
sudo wget ${GLPI_URL} -O /tmp/glpi.tgz
sudo tar xzf /tmp/glpi.tgz -C ${GLPI_DIR} --strip-components=1
sudo chown -R www-data:www-data ${GLPI_DIR}

# Configura o Apache para servir o GLPI
sudo cp ${GLPI_DIR}/apache.conf /etc/apache2/sites-available/glpi.conf
sudo ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf
sudo systemctl reload apache2

# Configura o GLPI
sudo cp ${GLPI_DIR}/config/config_sample.php ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_GLPI_ROOT_DIR_', '\.',/'_GLPI_ROOT_DIR_', '${GLPI_DIR}',/" ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_DB_TYPE_', 'mysql',/'_DB_TYPE_', 'mysqli',/" ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_DB_HOST_', 'localhost',/'_DB_HOST_', 'localhost',/" ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_DB_NAME_', 'glpi',/'_DB_NAME_', '${DB_NAME}',/" ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_DB_USER_', 'glpi',/'_DB_USER_', '${DB_USER}',/" ${GLPI_DIR}/config/config.php
sudo sed -i "s/'_DB_PASSWORD_', '',/'_DB_PASSWORD_', '${DB_PASS}',/" ${GLPI_DIR}/config/config.php

# Reinicia o Apache
sudo systemctl restart apache2

echo "GLPI instalado em http://localhost/glpi"
