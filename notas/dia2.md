
TABLESPACE
-  ENTIDAD LOGICA DE ALMACENAMIENTO
-  AGRUPAR DATAFILES (Entidades FISICAS DE ALMACENAMIENTO)



Dentro de un tablespace, guardamos objetos de base de datos, como tablas, índices, etc.

Dentro de un datafile, se almacenan bloques de datos (agrupados en extents).
Un extent es un conjunto de bloques de datos contiguos.

DATAFILE1
|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.........................................
| EXTENT1           | EXTENT2           | extent3           | extent4           |
| b1 | b2 | b3 | b4 | b5 | b6 | b7 | b8 | b9 | b10| b11| b12| b13| b14| b15| b16|

DATAFILE2
|xxxxxxxxxxxxxxxxxxxx........................................xxxxxxxxxxxxxxxxxxxx
| EXTENT1           | extent2           | extent3           | EXTENT4           |
| b1 | b2 | b3 | b4 | b5 | b6 | b7 | b8 | b9 | b10| b11| b12| b13| b14| b15| b16|

Un objeto de la bbdd que precisa de almacenamiento, tiene asociado un segmento.

Tabla Usuarios -> Segmento Usuarios
                         Datafile1(extent1+extent2)
                         Datafile2(extent1+extent4)
Tabla Facturas -> Segmento Facturas
Índice Usuarios_Nombre -> Segmento Usuarios_Nombre

El segmento es TODO SU ALMACENAMIENTO.
El segmento no es sino la agrupación de los extents que contienen todos los bloques de datos que componen el objeto.

Un objeto de BBDD (tabla) puede guardar datos en varios ficheros.

En última instancia, los datos que tiene un objeto están guardados en bloques de datos, que son la unidad mínima de almacenamiento. 
El hecho es que los bloques de datos de un objeto pueden estar en distintos ficheros.

---

Hasta Oracle 11 incluido,
INSTANCIA -     Copia en ejecución del programa de Oracle Database
BASE DE DATOS - Ficheros en HDD con datos y tablas... 

En una instancia, montaba una BBDD.
Solo podíamos tener una BBDD por instancia.

Eso cambió en Oracle 12c.
Se introduce el concepto de CDB y PDB.
CDB: Container Database - INSTANCIA
PDB: Pluggable Database

---

COLLATE: Forma de comparar cadenas de texto de cara a ordenarlas, agruparlas.

Columna:
----------
Camión
camión
CAMION
CAMIÓN
camion
Camion
Avión
avión
avion
avion
Avion
Avion

SELECT Columna FROM Tabla ORDER by Columna COLLATE XSpanish_AI;

Columna:
----------
AVION
Avion
Avión
CAMION
CAMIÓN
Camion
Camión
avion
avión
camion
camión


---

El Collate no tiene que ver con el juego de caracteres.
El juego de caracteres es cómo se transforman a bytes los caracteres para guardar en disco (en los bloques de datos).
El Collate es cómo se comparan los caracteres para ordenarlos, agruparlos, etc.

---

Hay operaciones muy delicadas en una BBDD que me pueden destrozar el rendimiento: ORDER BY!

No podemos estar metiendo order bys indiscriminadamente.

Pero hay muchas otras operaciones que de forma encubierta hacen un ORDER BY:
- GROUP BY: Lo primero que se hace es un ORDER BY del campo del GROUP BY.
- DISTINCT: Lo primero que se hace es un ORDER BY de todos los campos de la query.
- UNION: Hace un distinct después del append
  En su lugar el UNION ALL no hace un distinct.

--- 

Instalación de oracle.

Contenedores? Docker, Podman

Hoy en día, la forma ESTANDAR de instalar CUALQUIER PRODUCTO DE SOFTWARE DEL MUNDO MUNDIAL dentro de una empresa, o en mi portatil... pero software de tipo empresarial, no de usuario final, es a través de un contenedor.

TODO El software empresarial hoy en día se distribuye mediante contenedores.

Software empresarial:
- BBDD
- Servidores web
- Servidores de aplicaciones
- Servidores de mensajería
Esto no sirve para instalar: (NO VALE PARA PROGRAMAS DE ESCRITORIO)
- Office
- Photoshop
---


# Instalaciones de software

## Procedimiento tradicional

                                  PROBLEMAS:
     App 1 + App 2 + App 3           - Imaginad que App1 se vuelve loca (tiene un bug)
------------------------------            App1 (CPU 100%) ----> App1 (OFFLINE)
      Sistema Operativo                                         App2 (OFFLINE)
------------------------------                                  App3 (OFFLINE)
      HIERRO = MAQUINA               - Puede ser que App1 y App2 tengan dependencias/configuraciones 
                                        incompatibles
                                     - Problemas de seguridad

## Máquinas virtuales

   App1     |   App2 + App3         PROBLEMAS:
--------------------------------       - Se complica MUCHO la instalación / mnto del entorno.
   SO1      |       SO2                - Hay una pérdida de recursos
--------------------------------       - Hay una merma en el rendimiento
   VM1      |       VM2
--------------------------------
    Hipervisor:
    VMWare, Hyper-V, KVM
    Citrix, VirtualBox <<< ORACLE
--------------------------------
        Sistema Operativo 
--------------------------------
     HIERRO = MAQUINA FISICA

## Contenedores

   App1    |     App2 + App3
--------------------------------
   C1      |       C2
--------------------------------
    Gestor de contenedores:
    Docker, Podman, Crio
    ContainerD
-------------------------------
    Sistema operativo 
    (que corra un kernel Linux)
-------------------------------
    HIERRO = MAQUINA FISICA

Un contenedor es un entorno aislado dentro del kernel del sistema operativo del host donde ejecutar procesos.

Los contenedores los creamos desde IMAGENES DE CONTENEDOR.
Una Máquina virtual, la creo desde una:
- Imagen ISO: Instalador de un sistema operativo.
- Imagen de máquina virtual: .ova, .vmdk, .vdi, etc.

## Imagen de contenedor:

Es un archivo comprimido (.tar) que contiene un programa YA INSTALADO DE ANTEMANO POR ALGUIEN!
Las imágenes las descomprimimos y ejecutamos el software que viene dentro preinstalado.

Las imagenes de contenedor se encuentran en REGISTROS DE REPOSITORIOS DE IMAGENES DE CONTENEDORES.
- Docker Hub
- Microsoft Container Registry
- Quay.io
- Oracle Container Registry

# Sistema operativo Linux?

## Qué es Linux? Linux no es un sistema operativo. Es un KERNEL de sistema operativo.

De hecho el kernel de SO más usado en el mundo... con diferencia aberrante sobre los demás.
Android lleva dentro el Kernel de Linux.

## Windows 11, que es un sistema operativo, ejecuta el kernel de Linux? SI

YA desde hace versiones. Por defecto, windows en sus distintas versiones ejecuta el kernel de Microsoft: NT.
Pero windows, desde hace 5 años, (DE FORMA ESTANDAR-Característica de windows) Subsistema de Windows para Linux (WSL), ejecuta el kernel de Linux.


GNU/Linux se distribuye mediante compendios de software: DISTROS de GNU/LINUX
- RHEL
- Fedora
- Debian
- Ubuntu
- Suse


# GNU/Linux: Es un sistema operativo

Que tiene dentro el kernel de Linux (30%)... y librerías de la gente de GNU (70%).

Linus Torvalds (creador de Linux) 


# Qué era UNIX?

UNIX era un Sistema Operativo. De los lab bell (AT&T). Dejó de hacerse a principios de los 2000.

# Qué es UNIX?

UNIX no es un Sistema Operativo. Son 2 estándares que nos dicen cómo montar un SO (SUS, POSIX).
- SUS: Single UNIX Specification
- POSIX: Portable Operating System Interface

Sistemas operativo UNIX:
- Solaris: SO Unix® de Oracle (antes Sun Microsystems)
- IBM AIX: SO Unix® de IBM
- HP-UX:   SO Unix® de HP
- MacOS: SO Unix® de Apple

Linux no es un sistema operativo UNIX. Inicialmente se inspiró en esas especificaciones, pero desde entonces, ya ha tomado su propio camino.

# Oracle Database

Principalmente está pensado para su ejecución en:
- Solaris
- Linux  (Oracle tiene su propia distro de GNU/Linux: Oracle Linux - Es una recompilación de la distro RHEL)
----
- Windows



---

Backups, Recuperación ante desastres
---

                                          desastre1
    BBDD    1    2 3         4 5 6     7   v       8           9 10       11
    --------^------^---------------^-------X--------^-------------^-----------------------------> tiempo
            ^     Incremental1   Incremental2             Incremental3
            Completa1                           Completa2

Si hay un problema... alguien se equivoca y hace un TRUNCATE TABLE miTabla. He perdido los datos.
Quizás es más grace.. y se me han roto los discos de la máquina.

Cómo la recupero? Pues más vale que haya definido PREVIAMENTE una estrategia clara de Backup & Recovery.
Como no lo haya hecho,m los datos pailas!!! No los pillo más.


# Tipos de copias de seguridad:

## En base a los datos que contienen:

- Completas             COGEN TODOS LOS DATOS EXISTENTES = TARDA MUCHO
                          Si solo tengo la copia completa 1 y hay desastre 1, pierdo 2,3,4,5,6,7
                          Si tengo completa1 e Incremental1, pierdo 4,5,6,7
                          Si tengo completa1 e Incremental1 e Incremental2, pierdo 7

- Incrementales         COGEN SOLO LOS CAMBIOS DESDE LA ULTIMA COPIA COMPLETA/INCREMENTAL = TARDA MENOS
                        Pero ojo! Si tuviera que restaurar:
                            1. Tengo que restaurar la copia completa de la que partí al hacer el incremental
                            2. Restaurar las incrementales hasta llegar a la que me interesa
- DIFERENCIALES: ARCHIVE LOG / REDO LOG
                       Toda consulta o query que llega a la BBDD y puede provocar cambios, es registrada en un log.
                       Ese archivo es un archivo que trataba en modo SECUENCIAL ( no aleatorio )... se le hace append.
                       (ESTO ES MUY RAPIDO)

                        SELECT .... (Esto se que no provoca cambios)
                        INSERT .... (Esto provoca cambios) > GUARDAR
                        UPDATE .... (Esto provoca cambios) > GUARDAR
                        DELETE .... (Esto provoca cambios) > GUARDAR

Después de guardarlo, ya lo proceso!

## En base a la forma de hacer la copia:

- Lógicas: Copio los datos de la BBDD a algún sitio.
- Físicas: Copio los ficheros de los HDD



---


Una vez instalado Oracle, lo que hacemos es arrancar una instancia de Oracle.
La instancia de Oracle es un proceso que se ejecuta en el sistema operativo y que se encarga de gestionar las bases de datos.
Dentro de la instancia pondremos a funcionar la CDB
Y dentro de esa CDB, crearemos las PDBs.


De cara a conectar con oracle:
- Usuario
- Contraseña
- Hostname
- Puerto
- SID (Service Identifier) - Nombre de la BBDD (CDB o PDB)
- Role (opcional) - DBA, SYSDBA, SYSOPER, etc.

Esa información muchos clientes me permiten meterla a mano en un formulario.

En Oracle es más o menos habitual usar un fichero de configuración que se llama TNSNAMES.ORA.
En ese fichero declaramos esos datos (salvo el usuario/contraseña/role)

```sql

SELECT USER FROM DUAL; -- con que usuario estoy conectado
SHOW con_name; -- Nos muestra en qué BBDD estamos conectados

--- saber las BBDD (PDBs) que tengo disponibles
SELECT name, open_mode FROM v$pdbs;

--- Cambiar de una BBDD a otra
ALTER SESSION SET CONTAINER = ORCLPDB1; -- Cambiar a la PDB
ALTER SESSION SET CONTAINER = CDB$ROOT; -- Cambiar a la CDB

--- Estando en el contenedor padre (CDB)
ALTER PLUGGABLE DATABASE ORCLPDB1 OPEN; -- Abrir la PDB
ALTER PLUGGABLE DATABASE ORCLPDB1 CLOSE; -- Cerrar la PDB
ALTER PLUGGABLE DATABASE ORCLPDB1 CLOSE IMMEDIATE; -- Cerrar la PDB de forma inmediata
ALTER PLUGGABLE DATABASE ALL OPEN; -- Abrir la PDB

CONNECT USUARIO/PASSWORD@//SERVIDOR:PUERTO/SID AS <ROL>;
CONNECT USUARIO/PASSWORD@SID AS <ROL>;

select * FROM dba_users; -- A nivel de una PDB
ALTER USER USUARIO IDENTIFIED BY "<PASSWORD>"; -- Cambiar la contraseña de un usuario

```

Oracle tiene muchas tablas internas donde guarda su propia información de la BBDD.
No nos deja asomarnos mucho por esas tablas, pero lo que si hace es ofrecernos algunas vistas  (VIEWS) 
que trabajas sobre las tablas. Las vistas con información de sistema empiezan en oracle con V$.


---

```sql
-- Crear el usuario dentro del pdb
CREATE USER ivan IDENTIFIED BY "1234";

-- darle privilegios al usuario
GRANT CREATE SESSION TO ivan;
GRANT CREATE TABLE TO ivan;
GRANT CREATE VIEW TO ivan;
GRANT CREATE PROCEDURE TO ivan;
GRANT CREATE SEQUENCE TO ivan;
GRANT CREATE TRIGGER TO ivan;


GRANT CREATE RESOURCE TO ivan; -- Permite crear objetos dentro de la PDB

-- Asignación de tablaspaces a un usuario
ALTER USER ivan DEFAULT TABLESPACE users;
-- Asignar espacio ilimitado al usuario en el tablespace users
ALTER USER ivan QUOTA UNLIMITED ON users; 
-- Podríamos limitarle a 1Gb
-- Asignar espacio ilimitado al usuario en el tablespace users
ALTER USER ivan QUOTA 1G ON users;
```

---

# SEQUENCES en Oracle


Un objeto sequence es un elemento de la bbdd que nos permite generar números secuenciales de forma automática.

CREATE SEQUENCE nombre_sequence
INCREMENT BY 1
START WITH 1;

La secuencia la podemos usar luego para generar los ids primarios de las tablas.

SELECT nombre_sequence.NEXTVAL FROM DUAL; -- Siguiente valor de la secuencia
SELECT nombre_sequence.CURRVAL FROM DUAL; -- Valor actual de la secuencia



```sql

CREATE TABLE usuarios (
    id NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50),
    apellidos VARCHAR2(50)
);

CREATE SEQUENCE usuarios_seq
INCREMENT BY 1
START WITH 1;

CREATE OR REPLACE TRIGGER usuarios_trg
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    :new.id := usuarios_seq.NEXTVAL;
END;

INSERT INTO usuarios (nombre, apellidos) VALUES ('Juan', 'Pérez');
```

```sql

CREATE TABLE usuarios (
    id NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50),
    apellidos VARCHAR2(50)
);

CREATE SEQUENCE usuarios_seq
INCREMENT BY 1
START WITH 1;

INSERT INTO usuarios (id, nombre, apellidos) VALUES (usuarios_seq.NEXTVAL, 'Juan', 'Pérez');

CREATE TABLE PRUEBA_IVAN (
  CAMPO VARCHAR2(50)
);

INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('Camión');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('Camion');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('camión');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('camion');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('CAMION');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('CAMIÓN');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('Avión');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('Avion');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('avion');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('avión');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('AVION');
INSERT INTO PRUEBA_IVAN (CAMPO) VALUES ('AVIÓN');




```