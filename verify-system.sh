#!/bin/bash

# =============================================================================
# Script de verificación del sistema Docker
# =============================================================================
# Este script verifica que todo el entorno esté funcionando correctamente
# =============================================================================

# Leer PROJECT_NAME del archivo .env.project
if [ ! -f .env.project ]; then
    echo 'Error: No se encuentra el archivo .env.project'
    exit 1
fi

PROJECT_NAME=$(grep '^PROJECT_NAME=' .env.project | cut -d '=' -f2 | tr -d ' ')

if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME='proyecto'
fi

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "======================================"
echo "    $PROJECT_NAME - Verificación Sistema"
echo "======================================"
echo -e "${NC}"

# Función para verificar comando
check_command() {
    local cmd="$1"
    local description="$2"
    
    echo -ne "${YELLOW}Verificando $description...${NC} "
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Función para verificar puerto
check_port() {
    local port="$1"
    local service="$2"
    
    echo -ne "${YELLOW}Verificando puerto $port ($service)...${NC} "
    
    if command -v nc &> /dev/null; then
        if nc -z localhost "$port" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            return 0
        else
            echo -e "${RED}✗${NC}"
            return 1
        fi
    elif command -v telnet &> /dev/null; then
        if timeout 3 telnet localhost "$port" &>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            return 0
        else
            echo -e "${RED}✗${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}? (no se puede verificar)${NC}"
        return 2
    fi
}

# Función para verificar alias
check_alias() {
    local alias_name="$1"
    
    echo -ne "${YELLOW}Verificando alias $alias_name...${NC} "
    
    if type "$alias_name" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Verificar prerequisitos
echo -e "${BLUE}Verificando prerequisitos del sistema:${NC}"
check_command "docker" "Docker"
check_command "docker-compose" "Docker Compose"
echo ""

# Verificar contenedores Docker
echo -e "${BLUE}Verificando contenedores Docker:${NC}"
if command -v docker &> /dev/null; then
    CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep $PROJECT_NAME || true)
    if [[ -n "$CONTAINERS" ]]; then
        echo -e "${GREEN}Contenedores activos:${NC}"
        echo "$CONTAINERS"
    else
        echo -e "${RED}No se encontraron contenedores de ${PROJECT_NAME} ejecutándose${NC}"
        echo -e "${YELLOW}Ejecuta '${PROJECT_NAME}-up' o 'docker-compose up -d' para iniciar${NC}"
    fi
else
    echo -e "${RED}Docker no está disponible${NC}"
fi
echo ""

# Verificar puertos
echo -e "${BLUE}Verificando puertos de servicios:${NC}"
check_port "3307" "MySQL"
check_port "8081" "Laravel/Nginx"
check_port "6380" "Redis"
check_port "8082" "PhpMyAdmin"
echo ""

# Verificar aliases (si están disponibles)
echo -e "${BLUE}Verificando aliases de ${PROJECT_NAME}:${NC}"
ALIASES_TO_CHECK=("${PROJECT_NAME}-up" "${PROJECT_NAME}-down" "${PROJECT_NAME}-ps" "${PROJECT_NAME}-artisan" "${PROJECT_NAME}-migrate" "${PROJECT_NAME}-shell")

alias_count=0
for alias_name in "${ALIASES_TO_CHECK[@]}"; do
    if check_alias "$alias_name"; then
        ((alias_count++))
    fi
done

if [[ $alias_count -eq 0 ]]; then
    echo -e "${YELLOW}No se encontraron aliases configurados${NC}"
    echo -e "${BLUE}Para configurar aliases, ejecuta:${NC}"
    echo "  • Windows PowerShell: powershell -ExecutionPolicy Bypass -File setup-aliases-simple.ps1"
    echo "  • Linux/macOS/Git Bash: ./setup-aliases.sh"
elif [[ $alias_count -lt ${#ALIASES_TO_CHECK[@]} ]]; then
    echo -e "${YELLOW}Algunos aliases no están configurados correctamente${NC}"
    echo -e "${BLUE}Ejecuta el script de configuración para actualizar${NC}"
else
    echo -e "${GREEN}Todos los aliases están configurados correctamente${NC}"
fi
echo ""

# Verificar conectividad de servicios
echo -e "${BLUE}Verificando conectividad de servicios:${NC}"

# Laravel
echo -ne "${YELLOW}Verificando Laravel...${NC} "
if command -v curl &> /dev/null; then
    if curl -s http://localhost:8081 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${YELLOW}  Laravel no responde en http://localhost:8081${NC}"
    fi
else
    echo -e "${YELLOW}? (curl no disponible)${NC}"
fi

# PhpMyAdmin
echo -ne "${YELLOW}Verificando PhpMyAdmin...${NC} "
if command -v curl &> /dev/null; then
    if curl -s http://localhost:8082 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${YELLOW}  PhpMyAdmin no responde en http://localhost:8082${NC}"
    fi
else
    echo -e "${YELLOW}? (curl no disponible)${NC}"
fi

echo ""

# Resumen
echo -e "${BLUE}======================================"
echo "           RESUMEN"
echo "======================================${NC}"
echo ""
echo -e "${GREEN}URLs de acceso:${NC}"
echo "  • Laravel: http://localhost:8081"
echo "  • PhpMyAdmin: http://localhost:8082"
echo "  • Frontend: http://localhost:3001 (próximamente)"
echo ""
echo -e "${GREEN}Credenciales MySQL:${NC}"
echo "  • Host: localhost:3307"
echo "  • Usuario: ${PROJECT_NAME}_user"
echo "  • Contraseña: ${PROJECT_NAME}_password"
echo "  • Base de datos: ${PROJECT_NAME}_db"
echo ""
echo -e "${GREEN}Comandos útiles:${NC}"
if [[ $alias_count -gt 0 ]]; then
    echo "  • ${PROJECT_NAME}-ps          # Ver estado de contenedores"
    echo "  • ${PROJECT_NAME}-logs        # Ver logs del backend"
    echo "  • ${PROJECT_NAME}-shell       # Entrar al contenedor"
    echo "  • ${PROJECT_NAME}-artisan     # Comandos de Laravel"
else
    echo "  • docker-compose ps           # Ver estado de contenedores"
    echo "  • docker-compose logs -f      # Ver logs"
    echo "  • docker exec -it ${PROJECT_NAME}_backend bash  # Shell"
fi
echo ""
echo -e "${BLUE}¡Sistema ${PROJECT_NAME} verificado!${NC}"

