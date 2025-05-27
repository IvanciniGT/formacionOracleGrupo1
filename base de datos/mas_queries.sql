-- Que director es el que más le gusta a cada usuario.

with visualizaciones_por_director AS (
    SELECT
        v.usuario,
        p.director,
        count(*) AS num_peliculas_del_director
    FROM
        VISUALIZACIONES v
        INNER JOIN PELICULAS p ON v.pelicula = p.id
    WHERE v.usuario = 17
    GROUP BY v.usuario, p.director
    ORDER BY num_peliculas_del_director DESC
),
ranking AS (
    SELECT 
        vis.*,
        RANK() OVER (PARTITION BY vis.usuario ORDER BY num_peliculas_del_director DESC) AS puesto
    FROM 
        visualizaciones_por_director vis
    --WHERE vis.num_peliculas_del_director >= 2
)
SELECT 
 u.id,
 u.nombre as usuario,
 d.nombre as director,
 r.num_peliculas_del_director
FROM 
 (usuarios u LEFT OUTER JOIN ranking r ON u.id = r.usuario)
 LEFT OUTER JOIN Directores d ON d.id = r.director
WHERE puesto = 1 or puesto is null ;



--USUARIOS < VISUALIZACIONES > PELICULAS > DIRECTORES
--       LEFT             INNER        INNER
--        ||               ||           ||
--       FULL             LEFT         LEFT

--No me interesan peliculas sin visualizaciones? Esto puede ocurrir? SI. Las quiero NO
--No me interesan directores sin peliculas

--Puede ser que un usuario no tenga visualizaciones? SI.. y quiero sacar a ese usuario?
--El usuario lo quiero en el listado... lo que pasa es que no tendrá un director.. Y ESO ES RELEVANTE! 


-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                 |   100K|  8789K|       |  6462   (2)| 00:00:01 |       |       |
|*  1 |  HASH JOIN RIGHT OUTER        |                 |   100K|  8789K|       |  6462   (2)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS FULL           | DIRECTORES      | 10000 |   175K|       |    11   (0)| 00:00:01 |       |       |
|*  3 |   FILTER                      |                 |       |       |       |            |          |       |       |
|*  4 |    HASH JOIN RIGHT OUTER      |                 |   100K|  7031K|  3112K|  6451   (2)| 00:00:01 |       |       |
|   5 |     VIEW                      |                 | 49706 |  2524K|       |  6030   (2)| 00:00:01 |       |       |
|   6 |      WINDOW SORT              |                 | 49706 |  1019K|  1568K|  6030   (2)| 00:00:01 |       |       |
|   7 |       VIEW                    |                 | 49706 |  1019K|       |  5707   (2)| 00:00:01 |       |       |
|   8 |        SORT ORDER BY          |                 | 49706 |   922K|    26M|  5707   (2)| 00:00:01 |       |       |
|*  9 |         FILTER                |                 |       |       |       |            |          |       |       |
|  10 |          HASH GROUP BY        |                 | 49706 |   922K|    26M|  5707   (2)| 00:00:01 |       |       |
|* 11 |           HASH JOIN           |                 |   994K|    18M|       |  1172   (1)| 00:00:01 |       |       |
|  12 |            TABLE ACCESS FULL  | PELICULAS       | 30000 |   263K|       |    68   (0)| 00:00:01 |       |       |
|  13 |            PARTITION RANGE ALL|                 |  1000K|  9765K|       |  1100   (1)| 00:00:01 |     1 |     2 |
|  14 |             TABLE ACCESS FULL | VISUALIZACIONES |  1000K|  9765K|       |  1100   (1)| 00:00:01 |     1 |     2 |
|  15 |     INDEX FAST FULL SCAN      | IDX_NOMBRE      |   100K|  1953K|       |   117   (1)| 00:00:01 |       |       |
-------------------------------------------------------------------------------------------------------------------------
 
   1 - access("D"."ID"(+)="R"."DIRECTOR")
   3 - filter("R"."PUESTO"=1 OR "R"."PUESTO" IS NULL)
   4 - access("U"."ID"="R"."USUARIO"(+))
   9 - filter(COUNT(*)>=2)
  11 - access("V"."PELICULA"="P"."ID")


------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                 |   986K|    84M|       | 17492   (1)| 00:00:01 |       |       |
|*  1 |  HASH JOIN RIGHT OUTER       |                 |   986K|    84M|       | 17492   (1)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS FULL          | DIRECTORES      | 10000 |   175K|       |    11   (0)| 00:00:01 |       |       |
|*  3 |   FILTER                     |                 |       |       |       |            |          |       |       |
|*  4 |    HASH JOIN OUTER           |                 |   986K|    67M|  3128K| 17478   (1)| 00:00:01 |       |       |
|   5 |     INDEX FAST FULL SCAN     | IDX_NOMBRE      |   100K|  1953K|       |   117   (1)| 00:00:01 |       |       |
|   6 |     VIEW                     |                 |   994K|    49M|       | 14194   (1)| 00:00:01 |       |       |
|   7 |      WINDOW SORT             |                 |   994K|    19M|    30M| 14194   (1)| 00:00:01 |       |       |
|   8 |       VIEW                   |                 |   994K|    19M|       |  7776   (1)| 00:00:01 |       |       |
|   9 |        SORT ORDER BY         |                 |   994K|    20M|    30M|  7776   (1)| 00:00:01 |       |       |
|  10 |         HASH GROUP BY        |                 |   994K|    20M|    30M|  7776   (1)| 00:00:01 |       |       |
|* 11 |          HASH JOIN           |                 |   994K|    20M|       |  1172   (1)| 00:00:01 |       |       |
|  12 |           VIEW               | VW_GBF_8        | 30000 |   351K|       |    68   (0)| 00:00:01 |       |       |
|  13 |            TABLE ACCESS FULL | PELICULAS       | 30000 |   263K|       |    68   (0)| 00:00:01 |       |       |
|  14 |           PARTITION RANGE ALL|                 |  1000K|  9765K|       |  1100   (1)| 00:00:01 |     1 |     2 |
|  15 |            TABLE ACCESS FULL | VISUALIZACIONES |  1000K|  9765K|       |  1100   (1)| 00:00:01 |     1 |     2 |
------------------------------------------------------------------------------------------------------------------------

-- Antes de meterme con los índices, tengo que?
-- Oracle ha calculado un plan de ejecución... basándose en ESTIMACIONES.
-- Y esas estimaciones son buenas? Si no son buenas... a partir de ahí: TODO ES RUINA !

SELECT COUNT(*) FROM USUARIOS;
-- Hay un desmadre con las estadísticas de usuarios... Están fatal. Estima un 10%
-- Lo primero regenerar estadísticas

BEGIN
  DBMS_STATS.GATHER_DATABASE_STATS(
    estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, -- adecua el tamaño de muestra a cada tabla
    method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
    cascade          => TRUE, -- indices incluidos
    degree           => 4  -- paralelismo
  );
END;
/

--- Despues de estadisticas:
------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name            | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                 |  1906K|   163M|       | 20606   (1)| 00:00:01 |       |       |
|*  1 |  HASH JOIN RIGHT OUTER       |                 |  1906K|   163M|       | 20606   (1)| 00:00:01 |       |       |
|   2 |   TABLE ACCESS FULL          | DIRECTORES      | 10000 |   175K|       |    11   (0)| 00:00:01 |       |       |
|*  3 |   FILTER                     |                 |       |       |       |            |          |       |       |
|*  4 |    HASH JOIN OUTER           |                 |  1906K|   130M|    30M| 20589   (1)| 00:00:01 |       |       |
|   5 |     INDEX FAST FULL SCAN     | IDX_NOMBRE      |   999K|    19M|       |  1656   (1)| 00:00:01 |       |       |
|   6 |     VIEW                     |                 |  1006K|    49M|       | 14359   (1)| 00:00:01 |       |       |
|   7 |      WINDOW SORT             |                 |  1006K|    20M|    30M| 14359   (1)| 00:00:01 |       |       |
|   8 |       VIEW                   |                 |  1006K|    20M|       |  7860   (1)| 00:00:01 |       |       |
|   9 |        SORT ORDER BY         |                 |  1006K|    21M|    30M|  7860   (1)| 00:00:01 |       |       |
|  10 |         HASH GROUP BY        |                 |  1006K|    21M|    30M|  7860   (1)| 00:00:01 |       |       |
|* 11 |          HASH JOIN           |                 |  1006K|    21M|       |  1172   (1)| 00:00:01 |       |       |
|  12 |           VIEW               | VW_GBF_8        | 30000 |   351K|       |    68   (0)| 00:00:01 |       |       |
|  13 |            TABLE ACCESS FULL | PELICULAS       | 30000 |   263K|       |    68   (0)| 00:00:01 |       |       |
|  14 |           PARTITION RANGE ALL|                 |  1009K|  9859K|       |  1100   (1)| 00:00:01 |     1 |     2 |
|  15 |            TABLE ACCESS FULL | VISUALIZACIONES |  1009K|  9859K|       |  1100   (1)| 00:00:01 |     1 |     2 |
------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("D"."ID"(+)="R"."DIRECTOR")
   3 - filter("R"."PUESTO"=1 OR "R"."PUESTO" IS NULL)
   4 - access("U"."ID"="R"."USUARIO"(+))
  11 - access("V"."PELICULA"="ITEM_1")

30 filas seleccionadas. 


--- juntar peliculas, con visualizaciones y después el group by

peliculas: ID
 ||
visualizaciones: pelicula

INDICE: Cuál?                   Qué campos?
- peliculas?                    id, director
- visualizaciones?              usuario, pelicula

CREATE INDEX idx_visualizaciones_peliculas ON visualizaciones (pelicula, usuario);
CREATE INDEX idx_visualizaciones_peliculas ON visualizaciones (pelicula);

CREATE INDEX idx_visualizaciones_usuario_pelicula ON visualizaciones (usuario, pelicula);
DROP INDEX idx_visualizaciones_usuario_pelicula;
DROP INDEX idx_visualizaciones_usuario;
DROP INDEX idx_visualizaciones_peliculas;

--- Esos índices no ayudan en NADA
CREATE INDEX idx_peliculas_director ON peliculas (id, director);
DROP INDEX idx_peliculas_director;





/*+ INDEX(p idx_peliculas_director) */
with visualizaciones_por_director AS (
    SELECT 
        p.director,
        count(*) AS num_peliculas_del_director
    FROM
        VISUALIZACIONES v
        INNER JOIN PELICULAS p ON v.pelicula = p.id
    WHERE v.usuario = 17
    GROUP BY p.director
    ORDER BY num_peliculas_del_director DESC
),
ranking AS (
    SELECT 
        vis.*,
        RANK( ) OVER (ORDER BY num_peliculas_del_director DESC)AS puesto
    FROM 
        visualizaciones_por_director vis
    --WHERE vis.num_peliculas_del_director >= 2
)
SELECT /*+ GATHER_PLAN_STATISTICS */ 
 d.nombre as director,
 r.num_peliculas_del_director
FROM 
 ranking r
 INNER JOIN Directores d ON d.id = r.director
WHERE puesto = 1 or puesto is null ;

SELECT * FROM TABLE(
    DBMS_XPLAN.DISPLAY_CURSOR(
        NULL, 
        NULL, 
        'ALLSTATS LAST'
    )
);
----

Entra en IDX_VISUALIZACIONES_USUARIO_PELICULA por usuario... y saca los IDS de la pelis que ha visto
Con esos ID de las pelis entra en el INDICE del PK de Peliculas ->> ROW_ID de la pelicula
Entra a peliculas por ROW_ID y saca el ID director
Cuando tiene el ID del director: Va al índice PK de la tabla directores y saca el ROW_ID
Entra en Directores por ROW_ID y saca el nombre del director

Si tuviera un índice con el ID de la pelicula y el ID del director:

Entra en IDX_VISUALIZACIONES_USUARIO_PELICULA por usuario... y saca los IDS de la pelis que ha visto
Con esos ID de las pelis entra en el INDICE PeliculasxDirector ->> ID del director
Cuando tiene el ID del director: Va al índice PK de la tabla directores y saca el ROW_ID
Entra en Directores por ROW_ID y saca el nombre del director



SELECT  
 num_distinct,
 low_value,
 high_value,
 column_name,
 num_buckets,
 HISTOGRAM
FROM
user_tab_col_statistics
WHERE table_name = 'VISUALIZACIONES';


DESC user_tab_col_statistics;

FECHA
5 años -> 60 meses *4 ? 240 
Cada semana de cada año.. a ver cuántas pelis se vieron.
HORA <- 24 buckets


Un algotirmo de sort tiene un orden de complejidad de O(n log n)
Un full scan es O(n)
Una busqueda binaria sin optimizar es O( log n )


Si tengo 1.000.000 de datos, 

El hacer un full scan implica que necesito hacer 1.000.000 de operaciones
El hacer una búsqueda binaria implica que necesito hacer log2(1.000.000) = 20 operaciones
El hacer un sort implica que necesito hacer 1.000.000 * log2(1.000.000) = 20.000.000 operaciones

Si tengo 100 datos:
El hacer un full scan implica que necesito hacer 100 operaciones
El hacer una búsqueda binaria implica que necesito hacer log2(100) = 7 operaciones
El hacer un sort implica que necesito hacer 100 * log2(100) = 700 operaciones

Si tienes 20 datos:
El hacer un full scan implica que necesito hacer 20 operaciones
El hacer una búsqueda binaria implica que necesito hacer log2(20) = 5 operaciones
El hacer un sort implica que necesito hacer 20 * log2(20) = 80 operaciones

En la BBDD puede haber 10.000 millones de datos.
Lo importante es la cantidad de datos que procesas de esos.

Si entro por id en una tabla de esas:
Aunque tenga 10.000 millones de datos, si entro por un campo del que puedo hacer búsqueda binaria,
la complejidad es O(log n) -> log( 10.000.000.000) = 34 operaciones
la complejidad es O(log n) -> log( 10.000.000) = 23 operaciones