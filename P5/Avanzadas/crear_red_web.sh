#!/bin/sh

# Crear la red 'red_web' si no existe
sudo docker network ls | grep -w red_web > /dev/null 2>&1
if [ $? -ne 0 ]; then
  sudo docker network create --subnet=192.168.10.0/24 red_web
  echo "Red 'red_web' creada."
else
  echo "La red 'red_web' ya existe."
fi

