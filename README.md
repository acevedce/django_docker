# Proyecto Docker Django + PostgreSQL

Plantilla para crear entornos de desarrollo Django + PostgreSQL con Docker.

---

## Requisitos

- Docker
- Docker Compose
- Python 3 (para el script de setup)

---

## Crear un nuevo proyecto

```bash
cd /ruta/a/django_docker
./setup.sh nombre_proyecto
```

Esto:
1. Copia la plantilla a `../nombre_proyecto/`
2. Crea el proyecto Django con `django-admin startproject`
3. Configura `settings.py` para usar PostgreSQL
4. Ajusta `docker-compose.yml` con el nombre de la BD

---

## Arrancar el proyecto creado

```bash
cd ../nombre_proyecto
./launch.sh
```

Accede en: `http://localhost:8000`

---

## Estructura del proyecto generado

```
nombre_proyecto/
├── docker-compose.yml
├── Dockerfile
├── setup.sh
├── launch.sh
└── app/
    ├── requirements.txt
    ├── manage.py
    └── nombre_proyecto/
        ├── settings.py
        ├── urls.py
        └── wsgi.py
```

---

## PostgreSQL

- Usuario: `django`
- Contraseña: `django`
- Base de datos: `nombre_proyecto`
- Host (dentro de Docker): `db`

---

## Comandos útiles

```bash
# Ver logs
docker-compose logs -f

# Crear superusuario Django
docker-compose exec web python manage.py createsuperuser

# Aplicar migraciones
docker-compose exec web python manage.py migrate

# Crear nueva app Django
docker-compose exec web python manage.py startapp nombre_app

# Shell de Django
docker-compose exec web python manage.py shell
```
