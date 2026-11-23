#!/bin/bash
set -e

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  mariadb-server \
  php \
  libapache2-mod-php \
  php-mysql \
  curl \
  python3 \
  tar

systemctl enable --now apache2
systemctl enable --now mariadb

DB_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_hex(24))')

mariadb <<SQL
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wordpress'@'localhost'
  IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.*
  TO 'wordpress'@'localhost';
SQL

curl --fail --silent --show-error --location \
  https://wordpress.org/latest.tar.gz \
  --output /tmp/wordpress.tar.gz

  tar -xzf /tmp/wordpress.tar.gz \
  --strip-components=1 \
  -C /var/www/html

rm -f /var/www/html/index.html

cp /var/www/html/wp-config-sample.php \
  /var/www/html/wp-config.php

  sed -i \
  -e "s/database_name_here/wordpress/" \
  -e "s/username_here/wordpress/" \
  -e "s/password_here/${DB_PASSWORD}/" \
  /var/www/html/wp-config.php

  python3 <<'PYTHON'
from pathlib import Path
import secrets

config = Path("/var/www/html/wp-config.php")
text = config.read_text()

while "put your unique phrase here" in text:
    text = text.replace(
        "put your unique phrase here",
        secrets.token_hex(32),
        1,
    )

config.write_text(text)
PYTHON

chown -R www-data:www-data /var/www/html
chmod 640 /var/www/html/wp-config.php

systemctl restart apache2