# Template Base para Proyectos Docker (Laravel + React)

Este es un template base reutilizable para proyectos que usan Docker con Laravel (backend) y React (frontend).

## 🚀 Inicio Rápido

### 1. Configurar el Proyecto

**Windows PowerShell:**
```powershell
.\init-project.ps1 -ProjectName tunombreproyecto
```

**Linux/macOS/Git Bash:**
```bash
chmod +x init-project.sh
./init-project.sh tunombreproyecto
```

### 2. Ajustar Configuración (Opcional)

Edita `.env.project` para cambiar puertos u otras configuraciones:
```env
PROJECT_NAME=tunombreproyecto
PORT_BACKEND=8081
PORT_FRONTEND=3001
# ... etc
```

### 3. Levantar los Contenedores

```bash
# Usando el archivo de variables
docker-compose --env-file .env.project up -d

# Ver estado
docker-compose --env-file .env.project ps

# Ver logs
docker-compose --env-file .env.project logs -f
```

### 4. (Opcional) Configurar Submodules para Backend y Frontend

Si quieres que backend y frontend sean repos separados:

```bash
# Eliminar directorios actuales (haz backup primero!)
rm -rf backend frontend

# Agregar como submodules
git submodule add https://github.com/tuuser/tunombreproyecto-backend.git backend
git submodule add https://github.com/tuuser/tunombreproyecto-frontend.git frontend

# Inicializar y actualizar
git submodule update --init --recursive
```

## 📋 Estructura del Template

```
.
├── .env.project              # ⚙️ Variables de configuración del proyecto
├── docker-compose.yml        # 🐳 Orquestación de servicios (usa variables)
├── init-project.ps1          # 🔧 Script de inicialización (Windows)
├── init-project.sh           # 🔧 Script de inicialización (Linux/Mac)
├── setup-aliases.sh          # 🔗 Script de aliases (bash)
├── setup-aliases-simple.ps1  # 🔗 Script de aliases (PowerShell)
├── verify-system.sh          # ✅ Verificación del sistema
├── docker/                   # 🐋 Configuraciones Docker
│   ├── backend/
│   ├── frontend/
│   ├── nginx/
│   ├── mysql/
│   └── php/
├── backend/                  # 🔴 Código Laravel (puede ser submodule)
└── frontend/                 # 🔵 Código React (puede ser submodule)
```

## 🎯 Variables Configurables

En `.env.project` puedes configurar:

- **PROJECT_NAME**: Nombre base del proyecto (afecta nombres de contenedores)
- **PROJECT_DISPLAY_NAME**: Nombre para mostrar
- **Puertos**: Todos los puertos externos son configurables
- **Base de datos**: Usuario, contraseña, nombre de BD

## 🔄 Comandos Útiles

### Con variables de entorno:
```bash
# Levantar servicios
docker-compose --env-file .env.project up -d

# Detener servicios
docker-compose --env-file .env.project down

# Ver logs
docker-compose --env-file .env.project logs -f backend

# Ejecutar comandos Laravel
docker-compose --env-file .env.project exec backend php artisan migrate
```

### Crear alias permanente (opcional):
```bash
# Agregar a tu .bashrc o .zshrc:
alias dc='docker-compose --env-file .env.project'

# Luego solo:
dc up -d
dc ps
dc logs -f
```

## 🎨 Personalización para Nuevo Proyecto

1. **Ejecuta el script de inicialización** con el nombre de tu proyecto
2. **Ajusta `.env.project`** con puertos y configuraciones específicas
3. **Modifica `docker/` si necesitas** configuraciones Docker personalizadas
4. **Configura backend/frontend** como submodules o directorios normales

## 📦 Uso con Git Submodules

### Ventajas:
- ✅ Repos separados con pipelines independientes
- ✅ Mantiene la simplicidad de `docker-compose up`
- ✅ Equipos pueden trabajar en repos diferentes

### Comandos:
```bash
# Clonar repo con submodules
git clone --recursive https://github.com/tuuser/tuproyecto.git

# Actualizar submodules
git submodule update --remote

# Pull en todos los submodules
git submodule foreach git pull origin main
```

## 📝 Ejemplo de Uso

```bash
# 1. Usa el template de GitHub
# 2. Clona tu nuevo repo
git clone https://github.com/tuuser/mi-nuevo-proyecto.git
cd mi-nuevo-proyecto

# 3. Inicializa con tu nombre de proyecto
./init-project.sh mi-nuevo-proyecto

# 4. Configura tus repos de código
git submodule add https://github.com/tuuser/mi-nuevo-proyecto-backend.git backend
git submodule add https://github.com/tuuser/mi-nuevo-proyecto-frontend.git frontend

# 5. Levanta todo
docker-compose --env-file .env.project up -d

# 6. ¡A trabajar!
```

## 🛠️ Variables de Entorno por Defecto

| Variable | Valor Default | Descripción |
|----------|---------------|-------------|
| PROJECT_NAME | ${PROJECT_NAME} | Nombre del proyecto |
| PORT_BACKEND | 8081 | Puerto del backend/nginx |
| PORT_FRONTEND | 3001 | Puerto del frontend React |
| PORT_MYSQL | 3307 | Puerto de MySQL |
| PORT_REDIS | 6380 | Puerto de Redis |
| PORT_PHPMYADMIN | 8082 | Puerto de PhpMyAdmin |

## 📚 Documentación Adicional

- [ALIASES.md](./ALIASES.md) - Guía completa de aliases
- [SETUP-QUICK.md](./SETUP-QUICK.md) - Guía de inicio rápido

## 🤝 Contribuir

Este es un template base. Siéntete libre de:
- Agregar más servicios Docker
- Mejorar los scripts de inicialización
- Agregar más variables configurables
- Crear variantes para otros frameworks

---

**Creado para facilitar el inicio de proyectos Laravel + React con Docker**

