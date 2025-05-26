SELECT USER FROM DUAL;

SELECT * FROM PALABRAS_IVAN ORDER BY PALABRA COLLATE XSPANISH_AI;

-- Binary compara bytes. Si los bytes son distintos... los datos se ordenan distintos.. y se ordenan por el número del byte.
-- Binary_CI compara bytes, pero no importa si son mayúsculas o minúsculas.
-- Binary_AI compara bytes, pero no importa si son mayúsculas o minúsculas y tampoco importa el acento.
-- XSPANISH_AI Aplica reglas del idioma español.. que tiene sus reglas particulares: Ñ -> N



CREATE TABLE  usuarios_fechas (
    nombre VARCHAR2(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

INSERT INTO usuarios_fechas (nombre, fecha_nacimiento) VALUES ('Juan', TO_DATE('1990-01-01', 'YYYY-MM-DD'));
INSERT INTO usuarios_fechas (nombre, fecha_nacimiento) VALUES ('María', TO_DATE('1995-05-15', 'YYYY-MM-DD'));
INSERT INTO usuarios_fechas (nombre, fecha_nacimiento) VALUES ('Pedro', TO_DATE('1988-08-20', 'YYYY-MM-DD'));

-- Esta sintaxis funciona en Oracle y en cualquiera de los motores de base de datos: ANSI SQL
SELECT 
    p.id, 
    p.duracion, 
    TO_CHAR(p.fecha, 'DD-MM-YYYY') AS fecha, 
    p.edad_minima, 
    p.nombre, 
    d.nombre AS director, 
    t.nombre AS tematica
FROM peliculas p
 LEFT OUTER JOIN directores d ON p.director = d.id
 LEFT OUTER JOIN tematicas t ON p.tematica = t.id;

-- En cambio, esta sintaxis funciona en Oracle, pero no en otros motores de base de datos.
SELECT 
    p.id, 
    p.duracion, 
    TO_CHAR(p.fecha, 'DD-MM-YYYY') AS fecha, 
    p.edad_minima, 
    p.nombre, 
    d.nombre AS director, 
    t.nombre AS tematica
FROM peliculas p, directores d, tematicas t
WHERE 
        p.director = d.id  (+)
    AND p.tematica = t.id  (+);

-- JOINS
-- INNER JOIN
-- OUTER JOIN
--    LEFT OUTER JOIN
--    RIGHT OUTER JOIN
--    FULL OUTER JOIN
-- CROSS JOIN (Producto cartesiano)

--GRANT SELECT_CATALOG_ROLE to curso; -- Requeria reconexión del usuario
ALTER SESSION SET STATISTICS_LEVEL = ALL;

-- En cambio, esta sintaxis funciona en Oracle, pero no en otros motores de base de datos.
--  /*+ GATHER_PLAN_STATISTICS */ 
SELECT
    p.id, 
    p.duracion, 
    TO_CHAR(p.fecha, 'DD-MM-YYYY') AS fecha, 
    p.edad_minima, 
    p.nombre, 
    d.nombre AS director, 
    (SELECT nombre FROM TEMATICAS t WHERE t.id = p.tematica) AS tematica
FROM peliculas p, directores d
WHERE 
        p.director = d.id  (+);



SELECT * FROM TABLE(
    DBMS_XPLAN.DISPLAY_CURSOR(
        NULL, 
        NULL, 
        'ALLSTATS LAST'
    )
);

DROP INDEX usuarios_nombre_idx;
CREATE INDEX usuarios_nombre_idx ON usuarios (nombre); --row_id
CREATE INDEX usuarios_nombre_idx ON usuarios (nombre, id); --row_id


-- hint: Intentamos decirle al optimizador que use un índice en vez de un full table scan
-- /*+ INDEX(usuarios usuarios_nombre_idx) */ 
SELECT 
    nombre, 
    email
FROM usuarios WHERE nombre like 'Aaron%';

--SELECT count(*) FROM (SELECT DISTINCT nombre FROM usuarios);
-- En la tabla usuarios hay 100000 nombres
-- En el índice usuarios hay 71268 nombres.. algunos pondrá 2 o 3 ocurrencias en el índice

DROP INDEX visualizaciones_usuarios_idx;
CREATE INDEX visualizaciones_usuarios_idx ON visualizaciones (usuario, pelicula); --row_id

SELECT 
/*+ INDEX(v visualizaciones_usuarios_idx) */ 
u.nombre , count(distinct v.pelicula)
FROM visualizaciones v INNER JOIN usuarios u ON u.id = v.usuario
WHERE u.nombre LIKE 'Aaron%'
GROUP BY u.nombre;


DESC v$buffer_pool_statistics;

SELECT 
1- (PHYSICAL_READS / (DB_BLOCK_GETS + CONSISTENT_GETS)) * 100 AS "Buffer Cache Hit Ratio"
FROM v$buffer_pool_statistics;

-- RATIO de cache debe estar por encima de un 80% como poco... lo ideal es de un 90%