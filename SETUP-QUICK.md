# Guía Rápida - ${PROJECT_NAME} Setup

## 🚀 Instalación de Aliases

### Windows
```powershell
# Script PowerShell (recomendado) - Recrea el perfil limpio
powershell -ExecutionPolicy Bypass -File setup-aliases-simple.ps1

# Script bash multiplataforma
./setup-aliases.sh
```

### Linux/macOS
```bash
chmod +x setup-aliases.sh
./setup-aliases.sh
```

## 📋 Comandos Más Usados

```bash
# Gestión básica
${PROJECT_NAME}-up          # Levantar servicios
${PROJECT_NAME}-down        # Detener servicios
${PROJECT_NAME}-ps          # Ver estado

# Laravel desarrollo
${PROJECT_NAME}-artisan     # Comandos artisan
${PROJECT_NAME}-migrate     # Migraciones
${PROJECT_NAME}-shell       # Entrar al contenedor

# Base de datos
${PROJECT_NAME}-mysql       # Cliente MySQL
```

## 🔧 URLs de Acceso

- **Laravel**: http://localhost:8081
- **PhpMyAdmin**: http://localhost:8082
- **Frontend**: http://localhost:3001 (futuro)

## 📞 Solución Rápida

```bash
# Si algo falla, reiniciar todo
${PROJECT_NAME}-down
${PROJECT_NAME}-up

# Ver logs si hay errores
${PROJECT_NAME}-logs
```

