#!/bin/bash

# Verificar el estado de los contenedores
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

