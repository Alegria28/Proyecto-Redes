#!/bin/bash

# Comando para parar los contenedores y borrarlos
docker compose down

# Comando simple para limpiar todas las imágenes creadas
docker image prune -a -f

# Comando simple para borrar todos los volúmenes
docker volume prune -a -f