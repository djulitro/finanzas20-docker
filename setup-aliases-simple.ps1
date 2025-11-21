# Docker Aliases Setup Script
# Ejecutar con: powershell -ExecutionPolicy Bypass -File setup-aliases-simple.ps1

Write-Host ""
Write-Host "======================================"
Write-Host "    Docker Aliases - Setup"
Write-Host "======================================"
Write-Host ""

# Leer PROJECT_NAME del archivo .env.project
$envFile = ".env.project"
if (-not (Test-Path $envFile)) {
    Write-Host "Error: No se encuentra el archivo .env.project" -ForegroundColor Red
    Write-Host "Ejecuta primero: .\init-project.ps1 -ProjectName tu-proyecto" -ForegroundColor Yellow
    exit 1
}

$projectName = (Get-Content $envFile | Select-String "^PROJECT_NAME=").ToString().Split('=')[1].Trim()

if ([string]::IsNullOrWhiteSpace($projectName)) {
    Write-Host "Error: PROJECT_NAME no está definido en .env.project" -ForegroundColor Red
    exit 1
}

Write-Host "Proyecto detectado: $projectName" -ForegroundColor Cyan
Write-Host "Configurando aliases para PowerShell..." -ForegroundColor Yellow
Write-Host ""

# Obtener ruta del perfil
$ProfilePath = $PROFILE

# Crear directorio del perfil si no existe
$ProfileDir = Split-Path $ProfilePath -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Crear backup del perfil existente si existe y luego recrearlo limpio
if (Test-Path $ProfilePath) {
    $BackupPath = "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $ProfilePath $BackupPath
    Write-Host "Backup creado en: $BackupPath" -ForegroundColor Green
    Remove-Item $ProfilePath -Force
}

Write-Host "Creando perfil limpio..." -ForegroundColor Yellow
New-Item -Path $ProfilePath -Type File -Force | Out-Null

# Definir los nuevos aliases
$AliasContent = @"
# ${projectName}_ALIASES_START
# =============================================================================
# $projectName Docker Aliases - Configuracion limpia
# Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# =============================================================================

Write-Host "$projectName Docker aliases loaded!" -ForegroundColor Green

# Funciones para comandos Docker
function ${projectName}-up { docker-compose --env-file .env.project up -d }
function ${projectName}-down { docker-compose --env-file .env.project down }
function ${projectName}-restart { docker-compose --env-file .env.project restart }
function ${projectName}-ps { docker-compose --env-file .env.project ps }
function ${projectName}-logs { docker-compose --env-file .env.project logs -f backend }
function ${projectName}-build { docker-compose --env-file .env.project build }
function ${projectName}-rebuild { docker-compose --env-file .env.project down; docker-compose --env-file .env.project build --no-cache; docker-compose --env-file .env.project up -d }

# Funciones para Laravel
function ${projectName}-artisan { 
    param([Parameter(ValueFromRemainingArguments=`$true)]`$args)
    docker-compose --env-file .env.project exec backend php artisan `$args 
}
function ${projectName}-migrate { docker-compose --env-file .env.project exec backend php artisan migrate }
function ${projectName}-seed { docker-compose --env-file .env.project exec backend php artisan db:seed }
function ${projectName}-fresh { docker-compose --env-file .env.project exec backend php artisan migrate:fresh --seed }
function ${projectName}-routes { docker-compose --env-file .env.project exec backend php artisan route:list }
function ${projectName}-tinker { docker-compose --env-file .env.project exec backend php artisan tinker }

# Funciones para acceso directo
function ${projectName}-shell { docker-compose --env-file .env.project exec backend bash }
function ${projectName}-mysql { docker-compose --env-file .env.project exec mysql mysql -u ${projectName}_user -p ${projectName}_db }
function ${projectName}-redis { docker-compose --env-file .env.project exec redis redis-cli }

# Funciones para Composer
function ${projectName}-composer { 
    param([Parameter(ValueFromRemainingArguments=`$true)]`$args)
    docker-compose --env-file .env.project exec backend composer `$args 
}
function ${projectName}-install { docker-compose --env-file .env.project exec backend composer install }
function ${projectName}-update { docker-compose --env-file .env.project exec backend composer update }

# Funciones para testing
function ${projectName}-test { docker-compose --env-file .env.project exec backend php artisan test }
function ${projectName}-phpunit { 
    param([Parameter(ValueFromRemainingArguments=`$true)]`$args)
    docker-compose --env-file .env.project exec backend ./vendor/bin/phpunit `$args 
}

# Funciones para desarrollo
function ${projectName}-clear { docker-compose --env-file .env.project exec backend php artisan cache:clear; docker-compose --env-file .env.project exec backend php artisan config:clear; docker-compose --env-file .env.project exec backend php artisan view:clear }
function ${projectName}-optimize { docker-compose --env-file .env.project exec backend php artisan optimize }

# Función de ayuda
function ${projectName}-help {
    Write-Host ""
    Write-Host "====================================== $projectName - Comandos Disponibles ======================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "GESTION DE CONTENEDORES:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-up           " -NoNewline -ForegroundColor Green; Write-Host "Levantar todos los servicios Docker"
    Write-Host "  ${projectName}-down         " -NoNewline -ForegroundColor Green; Write-Host "Detener todos los servicios Docker"
    Write-Host "  ${projectName}-restart      " -NoNewline -ForegroundColor Green; Write-Host "Reiniciar todos los servicios"
    Write-Host "  ${projectName}-ps           " -NoNewline -ForegroundColor Green; Write-Host "Ver estado de contenedores"
    Write-Host "  ${projectName}-logs         " -NoNewline -ForegroundColor Green; Write-Host "Ver logs del backend en tiempo real"
    Write-Host "  ${projectName}-build        " -NoNewline -ForegroundColor Green; Write-Host "Construir las imágenes Docker"
    Write-Host "  ${projectName}-rebuild      " -NoNewline -ForegroundColor Green; Write-Host "Reconstruir completamente (down + build + up)"
    Write-Host ""
    Write-Host "COMANDOS LARAVEL:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-artisan      " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar comandos Artisan (ej: ${projectName}-artisan migrate)"
    Write-Host "  ${projectName}-migrate      " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar migraciones de base de datos"
    Write-Host "  ${projectName}-seed         " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar seeders de base de datos"
    Write-Host "  ${projectName}-fresh        " -NoNewline -ForegroundColor Green; Write-Host "Migracion fresh con seeders"
    Write-Host "  ${projectName}-routes       " -NoNewline -ForegroundColor Green; Write-Host "Listar todas las rutas de la aplicacion"
    Write-Host "  ${projectName}-tinker       " -NoNewline -ForegroundColor Green; Write-Host "Abrir Tinker para interactuar con Laravel"
    Write-Host ""
    Write-Host "ACCESO DIRECTO:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-shell        " -NoNewline -ForegroundColor Green; Write-Host "Acceder al shell del contenedor backend"
    Write-Host "  ${projectName}-mysql        " -NoNewline -ForegroundColor Green; Write-Host "Conectar al cliente MySQL"
    Write-Host "  ${projectName}-redis        " -NoNewline -ForegroundColor Green; Write-Host "Conectar al cliente Redis"
    Write-Host ""
    Write-Host "COMPOSER:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-composer     " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar comandos Composer (ej: ${projectName}-composer require)"
    Write-Host "  ${projectName}-install      " -NoNewline -ForegroundColor Green; Write-Host "Instalar dependencias PHP"
    Write-Host "  ${projectName}-update       " -NoNewline -ForegroundColor Green; Write-Host "Actualizar dependencias PHP"
    Write-Host ""
    Write-Host "TESTING:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-test         " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar tests con Artisan"
    Write-Host "  ${projectName}-phpunit      " -NoNewline -ForegroundColor Green; Write-Host "Ejecutar PHPUnit directamente"
    Write-Host ""
    Write-Host "DESARROLLO:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-clear        " -NoNewline -ForegroundColor Green; Write-Host "Limpiar caches de Laravel (cache, config, views)"
    Write-Host "  ${projectName}-optimize     " -NoNewline -ForegroundColor Green; Write-Host "Optimizar la aplicacion para produccion"
    Write-Host ""
    Write-Host "INFORMACION:" -ForegroundColor Yellow
    Write-Host "  ${projectName}-help         " -NoNewline -ForegroundColor Green; Write-Host "Mostrar esta ayuda"
    Write-Host ""
    Write-Host "URLS DE ACCESO:" -ForegroundColor Cyan
    Write-Host "  Ver archivo .env.project para configuración de puertos" -ForegroundColor White
    Write-Host ""
    Write-Host "===============================================================================================" -ForegroundColor Blue
    Write-Host ""
}

# ${projectName}_ALIASES_END
"@

# Escribir los aliases al perfil
Set-Content -Path $ProfilePath -Value $AliasContent

Write-Host ""
Write-Host "======================================"
Write-Host "    Configuracion completada"
Write-Host "======================================"
Write-Host ""
Write-Host "Perfil configurado en: $ProfilePath"
Write-Host ""
Write-Host "Aliases disponibles:"
Write-Host "  - ${projectName}-up, ${projectName}-down, ${projectName}-restart"
Write-Host "  - ${projectName}-artisan, ${projectName}-migrate, ${projectName}-seed"
Write-Host "  - ${projectName}-shell, ${projectName}-mysql, ${projectName}-redis"
Write-Host "  - ${projectName}-test, ${projectName}-logs, ${projectName}-clear"
Write-Host ""
Write-Host "Ejecuta '. `$PROFILE' o reinicia PowerShell para usar los aliases!"
Write-Host "Ejecuta '${projectName}-help' para ver todos los comandos disponibles."
Write-Host ""
pause

