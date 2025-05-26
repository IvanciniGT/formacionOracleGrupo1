# Modelo de mi BBDD

Esta base de datos está diseñada para almacenar información sobre películas, sus directores, temáticas y los usuarios que las visualizan. A continuación se presenta el modelo entidad-relación (ER) que describe la estructura de la base de datos.

## Entidades y Atributos
- **USUARIOS**
  - `id`: Identificador único del usuario (PK)
  - `estado`: Estado del usuario (activo, inactivo, etc.)
  - `alta`: Fecha de alta del usuario
  - `email`: Correo electrónico del usuario
  - `nombre`: Nombre del usuario

```mermaid
erDiagram
    USUARIOS {
        NUMBER id PK
        NUMBER estado
        TIMESTAMP alta
        VARCHAR2 email
        VARCHAR2 nombre
    }
    DIRECTORES {
        NUMBER id PK
        VARCHAR2 nombre
    }
    TEMATICAS {
        NUMBER id PK
        VARCHAR2 nombre
    }
    PELICULAS {
        NUMBER id PK
        NUMBER tematica FK
        NUMBER director FK
        NUMBER duracion
        DATE fecha
        NUMBER edad_minima
        VARCHAR2 nombre
    }
    VISUALIZACIONES {
        NUMBER usuario FK
        NUMBER pelicula FK
        TIMESTAMP fecha
    }

    USUARIOS ||--o{ VISUALIZACIONES : "tiene"
    PELICULAS ||--o{ VISUALIZACIONES : "es vista en"
    DIRECTORES ||--o{ PELICULAS : "dirige"
    TEMATICAS ||--o{ PELICULAS : "clasifica"
```



```cobol
[hello.cbl]
000100 IDENTIFICATION DIVISION.
000200 PROGRAM-ID.  HELLO.
000300 AUTHOR.      JOE PROGRAMMER.
000400 ENVIRONMENT DIVISION.
000500 DATA DIVISION.
000600 PROCEDURE DIVISION.
000700 MAINLINE.
000800     DISPLAY 'Hello World!'.
000900     STOP RUN.
```