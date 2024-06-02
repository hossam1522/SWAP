#!/bin/bash
set -e

# Espera a que MySQL inicie completamente
sleep 10

# Conéctate a MySQL y ejecuta los comandos de configuración
mysql <<-EOSQL
    -- Crear base de datos de WordPress si no existe
    CREATE DATABASE IF NOT EXISTS wordpress;

    -- Crear usuario de WordPress y otorgar permisos
    CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY 'wordpress';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%' WITH GRANT OPTION;

    -- Asegurarse de que los permisos estén aplicados
    FLUSH PRIVILEGES;

    -- Establecer contraseña para el usuario root
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'somewordpress';
EOSQL
