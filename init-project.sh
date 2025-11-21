#!/bin/bash

# ============================================
# Script de Inicialización de Proyecto
# ============================================
# Este script configura un nuevo proyecto basado en las variables de .env.project

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
    echo ""
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}  Inicializador de Proyecto Docker${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""
    echo -e "${YELLOW}USO:${NC}"
    echo "  ./init-project.sh <nombre-proyecto>"
    echo ""
    echo -e "${YELLOW}EJEMPLO:${NC}"
    echo "  ./init-project.sh miproyecto"
    echo ""
    echo -e "${YELLOW}DESCRIPCIÓN:${NC}"
    echo "  Este script actualiza el archivo .env.project con el nombre"
    echo "  del proyecto y genera la configuración necesaria."
    echo ""
    echo -e "${YELLOW}PASOS DESPUÉS DE EJECUTAR:${NC}"
    echo "  1. Revisa .env.project y ajusta puertos si es necesario"
    echo "  2. Ejecuta: docker-compose --env-file .env.project up -d"
    echo "  3. Configura tus repos de backend/frontend como submodules"
    echo ""
}

# Verificar argumentos
if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

PROJECT_NAME=$1

# Validar nombre del proyecto (solo minúsculas, números y guiones)
if ! [[ $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}Error: El nombre del proyecto solo debe contener letras minúsculas, números y guiones${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}  Configurando proyecto: $PROJECT_NAME${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""

# Verificar que existe .env.project
ENV_FILE=".env.project"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: No se encuentra el archivo .env.project${NC}"
    exit 1
fi

# Convertir primera letra a mayúscula para display name
DISPLAY_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${PROJECT_NAME:0:1})${PROJECT_NAME:1}"

# Crear archivo temporal con los cambios
sed -i.bak \
    -e "s/PROJECT_NAME=.*/PROJECT_NAME=$PROJECT_NAME/" \
    -e "s/PROJECT_DISPLAY_NAME=.*/PROJECT_DISPLAY_NAME=$DISPLAY_NAME/" \
    -e "s/DB_DATABASE=.*/DB_DATABASE=${PROJECT_NAME}_db/" \
    -e "s/DB_USERNAME=.*/DB_USERNAME=${PROJECT_NAME}_user/" \
    -e "s/DB_PASSWORD=.*/DB_PASSWORD=${PROJECT_NAME}_password/" \
    -e "s/DB_ROOT_PASSWORD=.*/DB_ROOT_PASSWORD=root_${PROJECT_NAME}_2024/" \
    "$ENV_FILE"

rm -f "${ENV_FILE}.bak"

echo -e "${GREEN}✓ Archivo .env.project actualizado${NC}"
echo ""
echo -e "${YELLOW}CONFIGURACIÓN:${NC}"
echo "  Proyecto: $PROJECT_NAME"
echo "  Display:  $DISPLAY_NAME"
echo "  DB:       ${PROJECT_NAME}_db"
echo "  Usuario:  ${PROJECT_NAME}_user"
echo ""
echo -e "${YELLOW}PRÓXIMOS PASOS:${NC}"
echo "  1. Revisa y ajusta .env.project si necesitas cambiar puertos"
echo "  2. Ejecuta: docker-compose --env-file .env.project up -d"
echo "  3. (Opcional) Genera aliases: ./setup-aliases.sh"
echo ""
echo -e "${CYAN}=====================================${NC}"
echo -e "${GREEN}  Configuración completada${NC}"
echo -e "${CYAN}=====================================${NC}"
echo ""
