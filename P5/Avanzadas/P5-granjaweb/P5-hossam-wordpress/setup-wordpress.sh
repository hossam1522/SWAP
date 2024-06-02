#!/bin/bash
set -e

# Espera a que MySQL esté listo
while ! mysqladmin ping -h db --silent; do
    sleep 1
done

# Instala WordPress si aún no está instalado
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
    wp config create --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=db --allow-root
    wp core install --url="http://localhost" --title="My WordPress Site" --admin_user=admin --admin_password=admin_password --admin_email=admin@example.com --skip-email --allow-root
    
    # Crear páginas de ejemplo
    wp post create --post_type=page --post_title="About" --post_status=publish --post_content="This is the about page." --allow-root
    wp post create --post_type=page --post_title="Contact" --post_status=publish --post_content="This is the contact page." --allow-root
    wp post create --post_type=page --post_title="Services" --post_status=publish --post_content="These are our services." --allow-root

    # Crear un post de ejemplo
    wp post create --post_title="Sample Post" --post_status=publish --post_content="This is a sample post." --allow-root
fi

# Establece los permisos adecuados
chown -R www-data:www-data /var/www/html

# Ejecuta el comando original de entrada
exec "$@"
