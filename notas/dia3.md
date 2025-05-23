

     USUARIOS < VISUALIZACIONES > PELICULAS > DIRECTOR
                                     V
                                  TEMARICA



Oracle almacena los campos de tipo DATE o TIMESTAMP como un número.
Otra cosa es cómo quiero ver ese número cuando hago una query o como quiero pasarle el dato(la fecha) para que él la entienda y la guarde como un número.

Yo no elijo cómo lo guarda, pero sí cómo lo quiero ver y cómo se lo paso.
```sql
CREATE TABLE USUARIOS (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
);

INSERT INTO USUARIOS (id, nombre, fecha_nacimiento) VALUES (1, 'Juan Pérez', TO_DATE('1990-01-01', 'YYYY-MM-DD'));
INSERT INTO USUARIOS (id, nombre, fecha_nacimiento) VALUES (2, 'Menchu Pérez', TO_DATE('01/01/1990', 'DD/MM/YYYY'));

-- Usuario nacidos desde el año 2000
SELECT * FROM USUARIOS WHERE fecha_nacimiento >= TO_DATE('2000-01-01', 'YYYY-MM-DD');
SELECT * FROM USUARIOS WHERE fecha_nacimiento >= TO_DATE('2000-01-01', 'YYYY-MM-DD');

-- Dame todos los datos de los suaurios, fecha de nac en formato: DD/MM/YYYY
SELECT id, nombre, TO_CHAR(fecha_nacimiento, 'DD/MM/YYYY') AS fecha_nacimiento FROM USUARIOS;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

SELECT * FROM NLS_DATABASE_PARAMETERS WHERE PARAMETER = 'NLS_DATE_FORMAT';
SELECT * FROM NLS_SESSION_PARAMETERS WHERE PARAMETER = 'NLS_TIMESTAMP_FORMAT';

ALTER SYSTEM SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY' SCOPE=SPFILE; -- guarda el dato en la sesion, sino en la base de datos
                                                        ^^^^^^^^^^^^
                                                        Donde quiero que se guarde ese parámetro
ALTER SYSTEM SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS'; -- guarda el dato no en la sesion, sino en la base de datos
```


Hay distintos sitios donde configurar este tipo de parámetros en ORACLE:
- init.ora
     NLS_DATE_FORMAT = 'DD/MM/YYYY'
     NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY HH24:MI:SS'
- spfile
- TABLA NLS_DATABASE_PARAMETERS

BLOB

2 bytes
0000 0000 0000 0000
^
BOOLEANO
 ^^^^^^^^ ^
 NUMERICO : 65535
           ^
           BOOLEAN
            ^^
            NUMERO: 


RAW(2)


1 byte
0000 0000
---- ----
 0-f  0-f
Hexadecimal

int base 10
0000 0000
---------
 0-255

 01001101 -> a
 00000001 -> ?