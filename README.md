# 🐳 Base Docker - Entorno de Desarrollo Laravel + React

Plantilla Docker lista para usar. Clona, configura y empieza a desarrollar en minutos, no horas.

**✨ Mismo entorno en cualquier computador | 📦 Todos los servicios pre-configurados | 🔄 Reutilizable para múltiples proyectos**

## 📚 Documentación

- 📖 [**Guía Completa de Aliases**](./ALIASES.md)
- ⚡ [**Setup Rápido**](./SETUP-QUICK.md)
- 🔧 [**Guía de Uso**](./USAGE.md)
- 🎨 [**Usar como Template**](./README-TEMPLATE.md)

## 🚀 Instalación Rápida

### 1. Configurar Aliases de Desarrollo (Recomendado)
Para simplificar el flujo de trabajo, instala los aliases automáticamente:

```bash
# Windows PowerShell (Recomendado)
powershell -ExecutionPolicy Bypass -File setup-aliases-simple.ps1

# Alternativas Windows
.\setup-aliases.bat                    # Script batch
./setup-aliases.sh                     # Git Bash

# Linux/macOS
chmod +x setup-aliases.sh && ./setup-aliases.sh
```

### 2. Levantar el Sistema
```bash
# Con aliases configurados
${PROJECT_NAME}-up

# Sin aliases
docker-compose up -d
```

### Comandos de Desarrollo (Con Aliases)

### Gestión de Contenedores
```bash
${PROJECT_NAME}-up          # Levantar todos los servicios
${PROJECT_NAME}-down        # Detener todos los servicios
${PROJECT_NAME}-restart     # Reiniciar todos los servicios
${PROJECT_NAME}-ps          # Ver estado de contenedores
${PROJECT_NAME}-logs        # Ver logs del backend
${PROJECT_NAME}-build       # Construir imágenes
${PROJECT_NAME}-rebuild     # Reconstruir completamente
```

### Comandos Laravel
```bash
${PROJECT_NAME}-artisan     # Ejecutar comandos artisan
${PROJECT_NAME}-migrate     # Ejecutar migraciones
${PROJECT_NAME}-seed        # Ejecutar seeders
${PROJECT_NAME}-fresh       # Migración fresh con seed
${PROJECT_NAME}-routes      # Listar rutas
${PROJECT_NAME}-tinker      # Abrir tinker
```

### Acceso Directo
```bash
${PROJECT_NAME}-shell       # Shell del contenedor backend
${PROJECT_NAME}-mysql       # Cliente MySQL
${PROJECT_NAME}-redis       # Cliente Redis
```

### Composer y Testing
```bash
${PROJECT_NAME}-composer    # Ejecutar composer
${PROJECT_NAME}-install     # Instalar dependencias
${PROJECT_NAME}-test        # Ejecutar tests
${PROJECT_NAME}-clear       # Limpiar cachés
${PROJECT_NAME}-optimize    # Optimizar aplicación
```

### Ayuda
```bash
${PROJECT_NAME}-help        # Ver todos los comandos disponibles con descripciones
```

## Estructura del Proyecto

```
${PROJECT_NAME}-project/
├── docker-compose.yml          # Orquestación de servicios
├── .env                        # Variables de entorno
├── backend/                    # Laravel API
├── frontend/                   # React Application
└── docker/                     # Configuraciones Docker
    ├── backend/
    │   └── Dockerfile          # PHP 8.2 + Laravel
    ├── frontend/
    │   └── Dockerfile          # Node.js + React
    ├── nginx/
    │   ├── nginx.conf          # Configuración principal
    │   └── sites/
    │       └── app.conf        # Virtual host (genérico)
    ├── php/
    │   └── local.ini           # Configuración PHP
    └── mysql/
        └── my.cnf              # Configuración MySQL
```

## 🐳 Servicios Docker

| Servicio | Puerto Externo | Puerto Interno | Descripción |
|----------|-------|-------|-------------|
| **Laravel Backend** | 8081 | 80 | API REST y aplicación principal |
| **MySQL Database** | 3307 | 3306 | Base de datos principal |
| **Redis Cache** | 6380 | 6379 | Cache y sesiones |
| **PhpMyAdmin** | 8082 | 80 | Administración web de BD |
| **Nginx** | 8081/4431 | 80/443 | Servidor web y proxy |
| **React Frontend** | 3001 | 3000 | Interfaz de usuario (próximamente) |

## 🔗 URLs de Acceso

- **Aplicación Laravel**: [http://localhost:8081](http://localhost:8081)
- **PhpMyAdmin**: [http://localhost:8082](http://localhost:8082)
- **Frontend React**: [http://localhost:3001](http://localhost:3001) *(próximamente)*

### 🔑 Credenciales de Base de Datos
- **Usuario**: `${PROJECT_NAME}_user`
- **Contraseña**: `${PROJECT_NAME}_password`
- **Base de datos**: `${PROJECT_NAME}_db`
- **Host externo**: `localhost:3307`

## 📚 Documentación y Scripts Disponibles

- **📖 [Guía Completa de Aliases](./ALIASES.md)** - Documentación detallada de todos los comandos
- **⚡ [Setup Rápido](./SETUP-QUICK.md)** - Guía de inicio rápido
- **🔧 Scripts de Configuración**:
  - `setup-aliases-simple.ps1` - PowerShell (recomendado para Windows)
  - `setup-aliases.sh` - Bash multiplataforma
  - `setup-aliases.bat` - Batch para Windows

## 🚨 Solución de Problemas Comunes

### Sin Aliases (Comandos Tradicionales Docker)
Si prefieres no usar aliases, puedes usar los comandos tradicionales:

```bash
# Gestión básica
docker-compose up -d
docker-compose down
docker-compose ps
docker-compose logs -f backend

# Laravel
docker-compose exec backend php artisan migrate
docker-compose exec backend php artisan make:controller
docker-compose exec backend composer install

# Acceso directo
docker exec -it ${PROJECT_NAME}_backend bash
docker exec -it ${PROJECT_NAME}_mysql mysql -u ${PROJECT_NAME}_user -p ${PROJECT_NAME}_db
```

### Contenedores no inician
```bash
${PROJECT_NAME}-down        # o: docker-compose down
${PROJECT_NAME}-build       # o: docker-compose build
${PROJECT_NAME}-up          # o: docker-compose up -d
```

### Error de permisos en Laravel
```bash
${PROJECT_NAME}-shell       # o: docker exec -it ${PROJECT_NAME}_backend bash
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage
```

### Limpiar todo y empezar de nuevo
```bash
${PROJECT_NAME}-down               # o: docker-compose down
docker system prune -f     # Limpiar Docker
${PROJECT_NAME}-up                 # o: docker-compose up -d
${PROJECT_NAME}-migrate            # o: docker-compose exec backend php artisan migrate
```

## Configuración de Base de Datos

La configuración de base de datos se encuentra en el archivo `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=${PROJECT_NAME}_db
DB_USERNAME=${PROJECT_NAME}_user
DB_PASSWORD=${PROJECT_NAME}_password
```

## Variables de Entorno

Este proyecto utiliza un sistema de variables de entorno en capas:

### `.env` (Docker - Raíz del proyecto)
- **Propósito**: Configuración de contenedores Docker
- **Contiene**: Credenciales de base de datos, configuración de servicios
- **Nota**: Este archivo está en `.gitignore`, usa `.env.example` como plantilla

### `backend/.env` (Laravel)
- **Propósito**: Configuración específica de Laravel
- **Contiene**: APP_KEY, JWT secrets, configuraciones de APIs
- **Hereda**: Las credenciales de DB del `.env` de Docker

### `frontend/.env` (React)
- **Propósito**: Variables de entorno de React
- **Contiene**: REACT_APP_* variables, URLs de APIs

## Desarrollo por Fases

### Fase 1: Solo Backend (Situación actual)
```bash
# Levantar solo los servicios necesarios para el backend
docker-compose up -d mysql backend nginx redis phpmyadmin

# Configurar Laravel
docker exec -it ${PROJECT_NAME}_backend composer install
docker exec -it ${PROJECT_NAME}_backend php artisan key:generate
docker exec -it ${PROJECT_NAME}_backend php artisan migrate

# Acceder a:
# - API: http://localhost/api
# - PhpMyAdmin: http://localhost:8080
```

### Fase 2: Agregar Frontend
```bash
# Cuando tengas el proyecto React listo
docker-compose up -d frontend

# O levantar todo junto
docker-compose up -d
```

### Servicios Mínimos Recomendados
- **mysql**: Base de datos principal
- **backend**: API de Laravel  
- **nginx**: Servidor web para Laravel
- **redis**: Cache y sesiones
- **phpmyadmin**: Administración de BD (opcional)

## Desarrollo

- Los archivos del backend se encuentran en `./backend/`
- Los archivos del frontend se encuentran en `./frontend/` (cuando esté creado)
- Los cambios se reflejan automáticamente gracias a los volúmenes montados
- El hot-reload está habilitado tanto para Laravel como para React

### Flujo de trabajo recomendado:
1. **Primero**: Desarrollar el backend con `docker-compose up -d mysql backend nginx redis`
2. **Luego**: Crear/agregar el frontend y levantar con `docker-compose up -d frontend`
3. **Testing**: Usar PhpMyAdmin para verificar la base de datos

## Troubleshooting

1. **Error de permisos**: Asegúrate de que Docker tenga permisos en las carpetas del proyecto
2. **Puerto ocupado**: Verifica que los puertos 8081, 3001, 3307, 6380 y 8082 estén disponibles
3. **Contenedor no inicia**: Revisa los logs con `docker-compose logs [servicio]`

## Próximos Pasos

1. Configurar tu proyecto Laravel en la carpeta `backend/`
2. Configurar tu proyecto React en la carpeta `frontend/`
3. Ajustar las configuraciones según tus necesidades específicas

