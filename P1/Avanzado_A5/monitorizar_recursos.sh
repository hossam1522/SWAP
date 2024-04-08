#!/bin/bash

# Solicitar al usuario el nombre del contenedor
read -p "Ingrese el nombre del contenedor a monitorear: " CONTAINER_NAME

# Obtener ID del contenedor
CONTAINER_ID=$(docker ps -qf "name=$CONTAINER_NAME")

# Verificar si se proporcionó un ID de contenedor válido
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No se encontró el contenedor con el nombre especificado."
    exit 1
fi

# Monitorizar recursos del contenedor
docker stats "$CONTAINER_ID"

