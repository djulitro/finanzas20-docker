# ============================================
# Script de Inicialización de Proyecto
# ============================================
# Este script configura un nuevo proyecto basado en las variables de .env.project

param(
    [string]$ProjectName,
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  Inicializador de Proyecto Docker" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USO:" -ForegroundColor Yellow
    Write-Host "  .\init-project.ps1 -ProjectName <nombre>" -ForegroundColor White
    Write-Host ""
    Write-Host "EJEMPLO:" -ForegroundColor Yellow
    Write-Host "  .\init-project.ps1 -ProjectName miproyecto" -ForegroundColor White
    Write-Host ""
    Write-Host "DESCRIPCIÓN:" -ForegroundColor Yellow
    Write-Host "  Este script actualiza el archivo .env.project con el nombre" -ForegroundColor White
    Write-Host "  del proyecto y genera aliases personalizados." -ForegroundColor White
    Write-Host ""
    Write-Host "PASOS DESPUÉS DE EJECUTAR:" -ForegroundColor Yellow
    Write-Host "  1. Revisa .env.project y ajusta puertos si es necesario" -ForegroundColor White
    Write-Host "  2. Ejecuta: docker-compose --env-file .env.project up -d" -ForegroundColor White
    Write-Host "  3. Configura tus repos de backend/frontend como submodules" -ForegroundColor White
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

if (-not $ProjectName) {
    Write-Host "Error: Debes proporcionar un nombre de proyecto" -ForegroundColor Red
    Write-Host "Usa: .\init-project.ps1 -ProjectName <nombre>" -ForegroundColor Yellow
    Write-Host "O:   .\init-project.ps1 -Help para ver la ayuda" -ForegroundColor Yellow
    exit 1
}

# Validar nombre del proyecto (solo minúsculas, números y guiones)
if ($ProjectName -notmatch '^[a-z0-9-]+$') {
    Write-Host "Error: El nombre del proyecto solo debe contener letras minúsculas, números y guiones" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Configurando proyecto: $ProjectName" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Leer el archivo .env.project actual
$envFile = ".env.project"
if (-not (Test-Path $envFile)) {
    Write-Host "Error: No se encuentra el archivo .env.project" -ForegroundColor Red
    exit 1
}

$content = Get-Content $envFile -Raw

# Convertir primera letra a mayúscula para display name
$displayName = $ProjectName.Substring(0,1).ToUpper() + $ProjectName.Substring(1)

# Reemplazar PROJECT_NAME
$content = $content -replace 'PROJECT_NAME=.*', "PROJECT_NAME=$ProjectName"
$content = $content -replace 'PROJECT_DISPLAY_NAME=.*', "PROJECT_DISPLAY_NAME=$displayName"

# Actualizar las variables que usan PROJECT_NAME
$content = $content -replace 'DB_DATABASE=.*', "DB_DATABASE=${ProjectName}_db"
$content = $content -replace 'DB_USERNAME=.*', "DB_USERNAME=${ProjectName}_user"
$content = $content -replace 'DB_PASSWORD=.*', "DB_PASSWORD=${ProjectName}_password"
$content = $content -replace 'DB_ROOT_PASSWORD=.*', "DB_ROOT_PASSWORD=root_${ProjectName}_2024"

# Guardar cambios
Set-Content -Path $envFile -Value $content

Write-Host "✓ Archivo .env.project actualizado" -ForegroundColor Green
Write-Host ""
Write-Host "CONFIGURACIÓN:" -ForegroundColor Yellow
Write-Host "  Proyecto: $ProjectName" -ForegroundColor White
Write-Host "  Display:  $displayName" -ForegroundColor White
Write-Host "  DB:       ${ProjectName}_db" -ForegroundColor White
Write-Host "  Usuario:  ${ProjectName}_user" -ForegroundColor White
Write-Host ""
Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "  1. Revisa y ajusta .env.project si necesitas cambiar puertos" -ForegroundColor White
Write-Host "  2. Ejecuta: docker-compose --env-file .env.project up -d" -ForegroundColor White
Write-Host "  3. (Opcional) Genera aliases: .\setup-aliases-simple.ps1" -ForegroundColor White
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Configuración completada" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
