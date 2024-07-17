# Configuración del entorno
Para este lab he desplegado un motor SQL Server 2022 linux sobre un contenedor Docker con persistencia. Los pasos a seguir para montar el lab en una máquina Linux son:

1. Como la imagen de SQL Server 2022 es algo pesada, se descarga y mientras termina de hacer el pull de la imagen, vamos montando los directorios para persistir los datos.
```bash
docker pull mcr.microsoft.com/mssql/server:2022-latest
```

2. En un directorio sobre el que queramos mantener los directorios de persistencia de la instancia de SQL Server, se crean la siguiente estructura de directorios:
```bash
mkdir sqlserver
cd sqlserver
mkdir {data,log,secrets}
```
Al final tenemos un esquema bajo el directorio **sqlserver** con la siguiente forma:

```bash
$ tree -d
.
├── data
├── log
└── secrets
```

3. La instancia de SQL Server utiliza en el contenedor el usuario con UID 10001, para evitar problemas de permisos debemos hacer que estos directorios estén asociados a un usuario con este UUID como propietario. Para ello, creo un usuario con este UID:
```bash
sudo useradd -u 10001 sqlserver -s /bin/false -d /nonexistent -M -N
```
Y lo asigno como propietario de los directorios

```bash
sudo chown sqlserver -R sqlserver/
```

4. Arranco el servicio de SQL Server, tras la descarga de la imagen Docker, con la siguiente lista de parámetros:
```bash
docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=XXXXXXX' \
-p 1433:1433 \
-v /CONTAINERS/sqlserver/data:/var/opt/mssql/data \
-v /CONTAINERS/sqlserver/log:/var/opt/mssql/log \
-v /CONTAINERS/sqlserver/secrets:/var/opt/mssql/secrets \
-d  --name sqlserver2022 mcr.microsoft.com/mssql/server:2022-latest
```
Con esto ya nos podemos conectar a través de la IP de nuestra máquina en el puerto 1433 utilizando el usuario **sa** y el password que se indique en el comando de ejecución del contenedor con el parámetro **MSSQL_SA_PASSWORD**.

5. Una vez conectado con un cliente al gestor de BBDD, se lanza el primer script **00_create_databse.sql**. Este script crea una base de datos con datos de ejemplo para probar el funcionamiento de la característica de Dynamic Data Masking. Dentro de esta base de datos, se crean tres tablas en las que se han enmascarado una serie de campos. Como usuario sa, al ser el super-admin de SQL Server podremos ver toda la información. Será a posteriori, creando usuarios específicos, con los que solo se podrán ver ciertos datos enmascarados.
6. Después se lanza el script **01_create_users.sql** que creará un par de usuarios con distintos permisos para poder visualizar los datos enmascarados. En el tercer script (**02_queries.sql**), os dejo unas consultas de prueba para validar la visualización del enmascaramiento.
