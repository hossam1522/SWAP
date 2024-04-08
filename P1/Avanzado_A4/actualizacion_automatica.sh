#!/bin/bash

# Actualizar imágenes Docker
docker-compose pull
# Recrear y reiniciar contenedores
docker-compose up -d

