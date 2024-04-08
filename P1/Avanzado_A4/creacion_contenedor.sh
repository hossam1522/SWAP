#!/bin/bash

# Función para imprimir el uso del script
print_usage() {
    echo "Uso: $0 [opciones]"
    echo "Opciones:"
    echo "  -n, --nombre CONTAINER_NAME  Especificar el nombre del contenedor"
    echo "  -i, --imagen IMAGE_NAME      Especificar la imagen del contenedor"
    echo "  -p, --puertos PORTS          Especificar los puertos del contenedor (formato: 'puerto_host:puerto_contenedor')"
    echo "  -v, --volumenes VOLUMES      Especificar los volúmenes del contenedor (formato: 'ruta_host:ruta_contenedor')"
    echo "  -r, --red NETWORK_NAME       Especificar la red de Docker del contenedor"
    echo "  -h, --ayuda                  Mostrar este mensaje de ayuda"
    exit 1
}

# Variables predeterminadas
CONTAINER_NAME=""
IMAGE_NAME=""
PORTS=""
VOLUMES=""
NETWORK_NAME=""

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--nombre)
            CONTAINER_NAME="$2"
            shift
            shift
            ;;
        -i|--imagen)
            IMAGE_NAME="$2"
            shift
            shift
            ;;
        -p|--puertos)
            PORTS="$2"
            shift
            shift
            ;;
        -v|--volumenes)
            VOLUMES="$2"
            shift
            shift
            ;;
        -r|--red)
            NETWORK_NAME="$2"
            shift
            shift
            ;;
        -h|--ayuda)
            print_usage
            ;;
        *)
            echo "Opción no reconocida: $1"
            print_usage
            ;;
    esac
done

# Verificar si se proporcionaron los argumentos obligatorios
if [ -z "$CONTAINER_NAME" ] || [ -z "$IMAGE_NAME" ]; then
    echo "Debe proporcionar el nombre y la imagen del contenedor."
    print_usage
fi

# Crear el contenedor con los argumentos proporcionados
docker run -d --name "$CONTAINER_NAME" \
           ${PORTS:+-p $PORTS} \
           ${VOLUMES:+-v $VOLUMES} \
           ${NETWORK_NAME:+--network $NETWORK_NAME} \
           "$IMAGE_NAME"

echo "Contenedor creado exitosamente: $CONTAINER_NAME"

