#!/bin/bash

# Eliminar archivos de log antiguos
docker container prune --filter "until=24h" --filter "label!=keep" -f

