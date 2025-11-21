# Cómo usar este template como base para nuevos proyectos

## Opción 1: Usar como Template de GitHub (Recomendado)

1. Sube este repo a GitHub
2. Ve a Settings → marcar "Template repository"
3. Para nuevos proyectos: "Use this template"
4. Ejecuta: `./init-project.sh nuevo-proyecto`

## Opción 2: Clonar y Personalizar

```bash
# 1. Clonar
git clone <este-repo> mi-nuevo-proyecto
cd mi-nuevo-proyecto

# 2. Limpiar el git actual
rm -rf .git
git init

# 3. Configurar el proyecto
./init-project.sh mi-nuevo-proyecto  # Linux/Mac
# o
.\init-project.ps1 -ProjectName mi-nuevo-proyecto  # Windows

# 4. Revisar .env.project y ajustar puertos si es necesario

# 5. Configurar backend y frontend como submodules (opcional)
rm -rf backend frontend  # Haz backup primero!
git submodule add <tu-repo-backend> backend
git submodule add <tu-repo-frontend> frontend

# 6. Levantar
docker-compose --env-file .env.project up -d
```

## Opción 3: Solo Docker (Sin Submodules)

Si prefieres tener todo en un solo repo:

```bash
# 1-4: Igual que Opción 2

# 5. Mantén backend y frontend como directorios normales
#    Desarrolla directamente en ellos

# 6. Levantar
docker-compose --env-file .env.project up -d
```

## Estructura de Repos Recomendada

### Para proyectos con CI/CD independiente:
```
mi-proyecto-infra/          # Este template
├── backend/                # → Submodule: mi-proyecto-backend
└── frontend/               # → Submodule: mi-proyecto-frontend
```

### Para proyectos pequeños/personales:
```
mi-proyecto/
├── docker/
├── docker-compose.yml
├── backend/                # Código directo
└── frontend/               # Código directo
```

## Comandos Útiles

```bash
# Crear alias temporal
alias dc='docker-compose --env-file .env.project'

# Entonces puedes usar:
dc up -d
dc ps
dc logs -f backend
dc exec backend php artisan migrate
```

## Personalización Avanzada

1. **Agregar más servicios**: Edita `docker-compose.yml`
2. **Cambiar versiones**: Modifica `docker/*/Dockerfile`
3. **Nuevas variables**: Agrega a `.env.project` y úsalas con `${VARIABLE}`
4. **Scripts custom**: Crea en la raíz y documental en README.md
