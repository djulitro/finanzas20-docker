#!/bin/bash

# =============================================================================
# Docker Aliases - Script de configuración de alias multiplataforma
# =============================================================================
# Este script configura alias para comandos Docker usando PROJECT_NAME
# Funciona en Windows (PowerShell/Git Bash), Linux y macOS
# =============================================================================

# Leer PROJECT_NAME del archivo .env.project
if [ ! -f .env.project ]; then
    echo 'Error: No se encuentra el archivo .env.project'
    echo 'Ejecuta primero: ./init-project.sh tu-proyecto'
    exit 1
fi

PROJECT_NAME=$(grep '^PROJECT_NAME=' .env.project | cut -d '=' -f2 | tr -d ' ')

if [ -z "$PROJECT_NAME" ]; then
    echo 'Error: PROJECT_NAME no está definido en .env.project'
    exit 1
fi

echo "Proyecto detectado: $PROJECT_NAME"
echo ""
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "======================================"
echo "    Docker Aliases - Setup de Aliases"
echo "======================================"
echo -e "${NC}"

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Detectar shell en Windows
detect_windows_shell() {
    if command -v powershell.exe &> /dev/null; then
        echo "powershell"
    elif command -v pwsh &> /dev/null; then
        echo "pwsh"
    else
        echo "bash"
    fi
}

# Crear alias para PowerShell
setup_powershell_aliases() {
    echo -e "${YELLOW}Configurando aliases para PowerShell...${NC}"
    
    # Detectar perfil de PowerShell
    if command -v powershell.exe &> /dev/null; then
        PROFILE_PATH=$(powershell.exe -Command 'echo $PROFILE' 2>/dev/null | tr -d '\r')
    elif command -v pwsh &> /dev/null; then
        PROFILE_PATH=$(pwsh -Command 'echo $PROFILE' 2>/dev/null | tr -d '\r')
    else
        echo -e "${RED}PowerShell no encontrado${NC}"
        return 1
    fi
    
    # Crear directorio del perfil si no existe
    PROFILE_DIR=$(dirname "$PROFILE_PATH")
    mkdir -p "$PROFILE_DIR" 2>/dev/null || true
    
    # Contenido de los alias para PowerShell
    POWERSHELL_ALIASES='
# =============================================================================
# ${PROJECT_NAME} Docker Aliases - Generado automáticamente
# =============================================================================

Write-Host "${PROJECT_NAME} Docker Aliases loaded!" -ForegroundColor Green

# Funciones para comandos Docker
function $PROJECT_NAME-up { docker-compose --env-file .env.project up -d }
function $PROJECT_NAME-down { docker-compose --env-file .env.project down }
function $PROJECT_NAME-restart { docker-compose --env-file .env.project restart }
function $PROJECT_NAME-ps { docker-compose --env-file .env.project ps }
function $PROJECT_NAME-logs { docker-compose --env-file .env.project logs -f backend }
function $PROJECT_NAME-build { docker-compose --env-file .env.project build }
function $PROJECT_NAME-rebuild { docker-compose --env-file .env.project down; docker-compose --env-file .env.project build --no-cache; docker-compose --env-file .env.project up -d }

# Funciones para Laravel
function $PROJECT_NAME-artisan { 
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    docker-compose --env-file .env.project exec backend php artisan $args 
}
function $PROJECT_NAME-migrate { docker-compose --env-file .env.project exec backend php artisan migrate }
function $PROJECT_NAME-seed { docker-compose --env-file .env.project exec backend php artisan db:seed }
function $PROJECT_NAME-fresh { docker-compose --env-file .env.project exec backend php artisan migrate:fresh --seed }
function $PROJECT_NAME-routes { docker-compose --env-file .env.project exec backend php artisan route:list }
function $PROJECT_NAME-tinker { docker-compose --env-file .env.project exec backend php artisan tinker }

# Funciones para acceso directo
function $PROJECT_NAME-shell { docker-compose --env-file .env.project exec backend bash }
function $PROJECT_NAME-mysql { docker-compose --env-file .env.project exec mysql mysql -u ${PROJECT_NAME}_user -p ${PROJECT_NAME}_db }
function $PROJECT_NAME-redis { docker-compose --env-file .env.project exec redis redis-cli }

# Funciones para Composer
function $PROJECT_NAME-composer { 
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    docker-compose --env-file .env.project exec backend composer $args 
}
function $PROJECT_NAME-install { docker-compose --env-file .env.project exec backend composer install }
function $PROJECT_NAME-update { docker-compose --env-file .env.project exec backend composer update }

# Funciones para testing
function $PROJECT_NAME-test { docker-compose --env-file .env.project exec backend php artisan test }
function $PROJECT_NAME-phpunit { 
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    docker-compose --env-file .env.project exec backend ./vendor/bin/phpunit $args 
}

# Funciones para desarrollo
function $PROJECT_NAME-clear { docker-compose --env-file .env.project exec backend php artisan cache:clear; docker-compose --env-file .env.project exec backend php artisan config:clear; docker-compose --env-file .env.project exec backend php artisan view:clear }
function $PROJECT_NAME-optimize { docker-compose --env-file .env.project exec backend php artisan optimize }
'
    
    # Verificar si los alias ya existen
    if [[ -f "$PROFILE_PATH" ]] && grep -q "${PROJECT_NAME} Docker Aliases" "$PROFILE_PATH"; then
        echo -e "${YELLOW}Los aliases ya existen. ¿Quieres actualizarlos? (y/n):${NC}"
        read -r response
        if [[ "$response" != "y" ]] && [[ "$response" != "Y" ]]; then
            echo -e "${BLUE}Operación cancelada${NC}"
            return 0
        fi
        
        # Remover aliases existentes
        sed -i '/# ${PROJECT_NAME} Docker Aliases/,/^$/d' "$PROFILE_PATH" 2>/dev/null || true
    fi
    
    # Agregar nuevos aliases
    echo "$POWERSHELL_ALIASES" >> "$PROFILE_PATH"
    
    echo -e "${GREEN}✓ Aliases configurados en: $PROFILE_PATH${NC}"
    echo -e "${YELLOW}Ejecuta: . \$PROFILE (o reinicia PowerShell) para cargar los aliases${NC}"
}

# Crear alias para Bash/Zsh
setup_bash_aliases() {
    echo -e "${YELLOW}Configurando aliases para Bash/Zsh...${NC}"
    
    # Detectar archivo de configuración
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
        SHELL_NAME="Zsh"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
        SHELL_NAME="Bash"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        SHELL_CONFIG="$HOME/.bash_profile"
        SHELL_NAME="Bash"
    else
        # Crear .bashrc si no existe
        SHELL_CONFIG="$HOME/.bashrc"
        SHELL_NAME="Bash"
        touch "$SHELL_CONFIG"
    fi
    
    # Contenido de los alias para Bash/Zsh
    BASH_ALIASES="
# ${PROJECT_NAME}_ALIASES_START
# =============================================================================
# ${PROJECT_NAME} Docker Aliases - Generado automáticamente
# Fecha: $(date '+%Y-%m-%d %H:%M:%S')
# =============================================================================

echo \"${PROJECT_NAME} Docker Aliases loaded!\"

# Alias para comandos Docker
alias $PROJECT_NAME-up=\"docker-compose --env-file .env.project up -d\"
alias $PROJECT_NAME-down=\"docker-compose --env-file .env.project down\"
alias $PROJECT_NAME-restart=\"docker-compose --env-file .env.project restart\"
alias $PROJECT_NAME-ps=\"docker-compose --env-file .env.project ps\"
alias $PROJECT_NAME-logs=\"docker-compose --env-file .env.project logs -f backend\"
alias $PROJECT_NAME-build=\"docker-compose --env-file .env.project build\"
alias $PROJECT_NAME-rebuild=\"docker-compose --env-file .env.project down && docker-compose --env-file .env.project build --no-cache && docker-compose --env-file .env.project up -d\"

# Alias para Laravel
alias $PROJECT_NAME-artisan=\"docker-compose --env-file .env.project exec backend php artisan\"
alias $PROJECT_NAME-migrate=\"docker-compose --env-file .env.project exec backend php artisan migrate\"
alias $PROJECT_NAME-seed=\"docker-compose --env-file .env.project exec backend php artisan db:seed\"
alias $PROJECT_NAME-fresh=\"docker-compose --env-file .env.project exec backend php artisan migrate:fresh --seed\"
alias $PROJECT_NAME-routes=\"docker-compose --env-file .env.project exec backend php artisan route:list\"
alias $PROJECT_NAME-tinker=\"docker-compose --env-file .env.project exec backend php artisan tinker\"

# Alias para acceso directo
alias $PROJECT_NAME-shell=\"docker-compose --env-file .env.project exec backend bash\"
alias $PROJECT_NAME-mysql=\"docker-compose --env-file .env.project exec mysql mysql -u ${PROJECT_NAME}_user -p ${PROJECT_NAME}_db\"
alias $PROJECT_NAME-redis=\"docker-compose --env-file .env.project exec redis redis-cli\"

# Alias para Composer
alias $PROJECT_NAME-composer=\"docker-compose --env-file .env.project exec backend composer\"
alias $PROJECT_NAME-install=\"docker-compose --env-file .env.project exec backend composer install\"
alias $PROJECT_NAME-update=\"docker-compose --env-file .env.project exec backend composer update\"

# Alias para testing
alias $PROJECT_NAME-test=\"docker-compose --env-file .env.project exec backend php artisan test\"
alias $PROJECT_NAME-phpunit=\"docker-compose --env-file .env.project exec backend ./vendor/bin/phpunit\"

# Alias para desarrollo
alias $PROJECT_NAME-clear=\"docker-compose --env-file .env.project exec backend php artisan cache:clear && docker-compose --env-file .env.project exec backend php artisan config:clear && docker-compose --env-file .env.project exec backend php artisan view:clear\"
alias $PROJECT_NAME-optimize=\"docker-compose --env-file .env.project exec backend php artisan optimize\"

# Función de ayuda
$PROJECT_NAME-help() {
    echo \"\"
    echo -e \"\033[34m====================================== ${PROJECT_NAME} - Comandos Disponibles ======================================\033[0m\"
    echo \"\"
    echo -e \"\033[33mGESTIÓN DE CONTENEDORES:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-up          \033[0m Levantar todos los servicios Docker\"
    echo -e \"  \033[32m${PROJECT_NAME}-down        \033[0m Detener todos los servicios Docker\"
    echo -e \"  \033[32m${PROJECT_NAME}-restart     \033[0m Reiniciar todos los servicios\"
    echo -e \"  \033[32m${PROJECT_NAME}-ps          \033[0m Ver estado de contenedores\"
    echo -e \"  \033[32m${PROJECT_NAME}-logs        \033[0m Ver logs del backend en tiempo real\"
    echo -e \"  \033[32m${PROJECT_NAME}-build       \033[0m Construir las imágenes Docker\"
    echo -e \"  \033[32m${PROJECT_NAME}-rebuild     \033[0m Reconstruir completamente (down + build + up)\"
    echo \"\"
    echo -e \"\033[33mCOMANDOS LARAVEL:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-artisan     \033[0m Ejecutar comandos Artisan (ej: ${PROJECT_NAME}-artisan migrate)\"
    echo -e \"  \033[32m${PROJECT_NAME}-migrate     \033[0m Ejecutar migraciones de base de datos\"
    echo -e \"  \033[32m${PROJECT_NAME}-seed        \033[0m Ejecutar seeders de base de datos\"
    echo -e \"  \033[32m${PROJECT_NAME}-fresh       \033[0m Migración fresh con seeders\"
    echo -e \"  \033[32m${PROJECT_NAME}-routes      \033[0m Listar todas las rutas de la aplicación\"
    echo -e \"  \033[32m${PROJECT_NAME}-tinker      \033[0m Abrir Tinker para interactuar con Laravel\"
    echo \"\"
    echo -e \"\033[33mACCESO DIRECTO:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-shell       \033[0m Acceder al shell del contenedor backend\"
    echo -e \"  \033[32m${PROJECT_NAME}-mysql       \033[0m Conectar al cliente MySQL\"
    echo -e \"  \033[32m${PROJECT_NAME}-redis       \033[0m Conectar al cliente Redis\"
    echo \"\"
    echo -e \"\033[33mCOMPOSER:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-composer    \033[0m Ejecutar comandos Composer (ej: ${PROJECT_NAME}-composer require)\"
    echo -e \"  \033[32m${PROJECT_NAME}-install     \033[0m Instalar dependencias PHP\"
    echo -e \"  \033[32m${PROJECT_NAME}-update      \033[0m Actualizar dependencias PHP\"
    echo \"\"
    echo -e \"\033[33mTESTING:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-test        \033[0m Ejecutar tests con Artisan\"
    echo -e \"  \033[32m${PROJECT_NAME}-phpunit     \033[0m Ejecutar PHPUnit directamente\"
    echo \"\"
    echo -e \"\033[33mDESARROLLO:\033[0m\"
    echo -e \"  \033[32m${PROJECT_NAME}-clear       \033[0m Limpiar cachés de Laravel (cache, config, views)\"
    echo -e \"  \033[32m${PROJECT_NAME}-optimize    \033[0m Optimizar la aplicación para producción\"
    echo \"\"
    echo -e \"\033[33mINFORMACIÓN:\033[0m\"
    echo -e \"  \033[32m$PROJECT_NAME-help        \033[0m Mostrar esta ayuda\"
    echo \"\"
    echo -e \"\033[36mURLS DE ACCESO:\033[0m\"
    echo -e \"  Laravel:     \033[34mhttp://localhost:8081\033[0m\"
    echo -e \"  PhpMyAdmin:  \033[34mhttp://localhost:8082\033[0m\"
    echo -e \"  MySQL:       \033[34mlocalhost:3307 (user: ${PROJECT_NAME}_user, db: ${PROJECT_NAME}_db)\033[0m\"
    echo \"\"
    echo -e \"\033[34m===============================================================================================\033[0m\"
    echo \"\"
}

# ${PROJECT_NAME}_ALIASES_END
"
    
    # Verificar si los alias ya existen
    if grep -q "# ${PROJECT_NAME}_ALIASES_START" "$SHELL_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}Los aliases ya existen. ¿Quieres actualizarlos? (y/n):${NC}"
        read -r response
        if [[ "$response" != "y" ]] && [[ "$response" != "Y" ]]; then
            echo -e "${BLUE}Operación cancelada${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}Eliminando aliases existentes...${NC}"
        
        # Crear archivo temporal sin la sección del proyecto
        awk '
            /# ${PROJECT_NAME}_ALIASES_START/ { skip=1; next }
            /# ${PROJECT_NAME}_ALIASES_END/ { skip=0; next }
            !skip
        ' "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
        
        # Reemplazar el archivo original
        mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
    fi
    
    # Agregar nuevos aliases
    echo "$BASH_ALIASES" >> "$SHELL_CONFIG"
    
    echo -e "${GREEN}✓ Aliases configurados en: $SHELL_CONFIG${NC}"
    echo -e "${YELLOW}Ejecuta: source $SHELL_CONFIG (o reinicia la terminal) para cargar los aliases${NC}"
}

# Función principal
main() {
    OS=$(detect_os)
    
    echo -e "${BLUE}Sistema operativo detectado: $OS${NC}"
    echo ""
    
    case $OS in
        "windows")
            SHELL_TYPE=$(detect_windows_shell)
            echo -e "${BLUE}Shell detectado: $SHELL_TYPE${NC}"
            echo ""
            
            if [[ "$SHELL_TYPE" == "powershell" ]] || [[ "$SHELL_TYPE" == "pwsh" ]]; then
                setup_powershell_aliases
            else
                echo -e "${YELLOW}Ejecutándose en Git Bash, configurando aliases de Bash...${NC}"
                setup_bash_aliases
            fi
            ;;
        "macos"|"linux")
            setup_bash_aliases
            ;;
        "unknown")
            echo -e "${RED}Sistema operativo no soportado${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}======================================"
    echo "    ✓ Configuración completada"
    echo "======================================${NC}"
    echo ""
    echo -e "${BLUE}Aliases disponibles:${NC}"
    echo "  • ${PROJECT_NAME}-up, ${PROJECT_NAME}-down, ${PROJECT_NAME}-restart"
    echo "  • ${PROJECT_NAME}-artisan, ${PROJECT_NAME}-migrate, ${PROJECT_NAME}-seed"
    echo "  • ${PROJECT_NAME}-shell, ${PROJECT_NAME}-mysql, ${PROJECT_NAME}-redis"
    echo "  • ${PROJECT_NAME}-test, ${PROJECT_NAME}-logs, ${PROJECT_NAME}-clear"
    echo ""
    echo -e "${YELLOW}¡Reinicia tu terminal o recarga tu perfil para usar los aliases!${NC}"
}

# Ejecutar función principal
main "$@"



