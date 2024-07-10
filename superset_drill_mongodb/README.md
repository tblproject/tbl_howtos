# Configuración del entorno de demo
Para esta demo he montado una instancia de Apache Superset sobre una máquina en la que cuento con Docker-Compose instalado. La base de datos la he creado en una instancia de PostgreSQL que tengo en otra máquina, que la utilizo para múltiples entornos de laboratorio.

En cuanto a los servicios de MongoDB y Apache Drill, los he montado en otra máquina que cuenta con Docker instalado.

## 1. Despliegue de Apache Superset
Para este despligue sobre Docker-compose me he basado en los pasos de la [URL oficial](https://superset.apache.org/docs/installation/docker-compose/). Pero con el cambio de asegurarme de descargar una versión stable en concreto (la versión 4.0.2). Para ello, en un directorio sobre el que se quiera trabajar, se lanza:

```bash
git clone https://github.com/apache/superset
git checkout -b 4.0.2
```

### 1.1 Configuración de la Base de datos de Apache Superset
Para crear la base de datos y el usuario con los permisos suficientes, desde un cliente conectado a la instancia de PostgreSQL, se lanza:

```sql
CREATE DATABASE superset_00;
CREATE USER superset WITH PASSWORD 'XXXXXXXXXXX';
GRANT ALL PRIVILEGES ON DATABASE superset_00 TO superset;
-- Con el usuario postgres, nos conectamos a la nueva base de datos y lanzamos lo siguiente para asegurar que el usuario creado tiene los permisos necesarios.
-- Este paso es necesario en versiones de PostgreSQL 15 y superiores.
GRANT ALL ON SCHEMA public TO superset;
```

Si además queremos cargar datos de ejemplo en una base de datos, para ya tener dashboards y datasets de ejemplo, crearemos una base de datos adicional:

```sql
CREATE DATABASE superset_examples;
GRANT ALL PRIVILEGES ON DATABASE superset_examples TO superset;
-- Con el usuario postgres, nos conectamos a la nueva base de datos y lanzamos lo siguiente para asegurar que el usuario creado tiene los permisos necesarios.
-- Este paso es necesario en versiones de PostgreSQL 15 y superiores.
GRANT ALL ON SCHEMA public TO superset;
```

### 1.2 Configuración de Superset
Tras crear la base de datos para Superset y para los ejemplos, hay dos cosas a configurar:
1. se quita la configuración del servicio de PostgreSQL en el archivo **docker-compose-non-dev.yml**, ya que no será necesario desplegarlo. Os he dejado en el directorio **superset** de esta carpeta el archivo ya modificado.
2. Se debe incluir la configuración de acceso a la base de datos en el archivo **./docker/.env-non-dev**. También os he dejado un archivo de ejemplo en el mismo directorio que el archivo de Docker Compose. Si no quereis cargar los ejemplos, Comentad las siguientes líneas:
```properties
EXAMPLES_DB=superset_examples
EXAMPLES_HOST=xxx.xxx.xxx.xxx
EXAMPLES_USER=superset
EXAMPLES_PASSWORD=XXXXXXXXXXXX
EXAMPLES_PORT=5432
```

Y poned el parámetro siguiente a **no**:

```properties
SUPERSET_LOAD_EXAMPLES=no
```

### 1.3 Instalar conector de Apache Drill
El conector de Apache Drill no viene instalado por defecto en la imagen de Apache Superset, para instalar este tipo de dependencias en un despliegue sobre Docker Compose, nos simplifican esta tarea sin necesidade de tener que crear una imagen Custom. Bastará con crear un archivo requirements con el nombre **requirements-local.txt** dentro del directorio **./docker/**, he incluir las librerías a instalar; en el arranque de Superset, instalará estas librerías:

```bash
touch ./docker/requirements-local.txt
echo "sqlalchemy-drill" >> ./docker/requirements-local.txt
```

## 2. Despliegue de MongoDB
Para este despliegue he recurrido a lanzar un contenedor Docker sin complicarme en temas de autenticación:
```bash
docker run -d \
    -p 27017:27017 \
    --name tbl-mongodb \
    -v data-vol:/data/db \
    mongodb/mongodb-community-server:latest
```
Como véis recurro a la versión community de MongoDB y monto un volumen para persistir los datos. Lo siguiente es importar datos de prueba. Para ello:
1. Entro en el contenedor en ejecución
```bash
docker exec -it tbl-mongodb /bin/bash
```
2. Me descargo un set de pruebas que ofrece Mongo:
```bash
wget https://atlas-education.s3.amazonaws.com/sampledata.archive 
```
3. Y lo importo con el comando **mongorestore**:
```bash
mongorestore --archive=sampledata.archive
```

## 3. Despliegue de Apache Drill
Para desplegar Apache Drill también recurro a Docker, pero en este caso, la imagen del hub de Docker no dispone de una configuración que permita persistir las configuraciones que se hagan en cuanto a conexiones a orígenes de datos, los almacena en memoria. Esto provoca que al parar el contenedor o recrearlo, se pierdan las configuraciones realizadas. Drill ofrece varias opciones de gestionar esta persisitencia (Zookeeper, HDFS, S3, ...), pero para esta demo, montaré una persistencia en un directorio en local, que mapearé a un volumen de Docker. 

Para hacer esto se debe crear una imagen custom en donde se sobreescriba un archivo de configuración. En el directorio **drill** os he dejado el archivo **drill-override.conf** con la configuración necesaria:
```properties
drill.exec: {
  cluster-id: "drillbits1",
  zk.connect: "localhost:2181",
  sys.store.provider.local.path = "/data"
}
```
También os he dejado el archivo **Dockerfile** que utilizo para crear la imagen custom, tiene poca cosa, solo la sobreescritura del archivo de configuración por el que trae por defecto la imagen:
```docker
FROM apache/drill:latest
ADD drill-override.conf /opt/drill/conf/drill-override.conf
```

Para construir la imagen custom, se lanza:
```bash
docker build -t custom/drill:latest .
```
Y para lanzar el servicio de Apache Drill:
```bash
docker run -it --name tbl-drill \
    -p 8047:8047 -p 31010:31010 \
    -v big-data-vol:/data \
    -d custom/drill:latest
```



