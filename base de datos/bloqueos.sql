
CREATE TABLE bloqueos (
    nombre VARCHAR2(50) NOT NULL,
    numero NUMBER(10) NOT NULL
) PCTFREE 10 INITRANS 1;

BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO bloqueos (nombre, numero) 
        VALUES ('dato_' || TO_CHAR(i,'FM00000'), 0);
    END LOOP;
    COMMIT;
END;
/



SELECT count(*) from bloqueos;

SELECT * FROM bloqueos WHERE ROWNUM <= 10;

--- Ver el segmento(s) de una tabla
SELECT segment_name, SEGMENT_TYPE, TABLESPACE_NAME, HEADER_FILE, HEADER_BLOCK
FROM dba_segments
WHERE segment_name = 'BLOQUEOS';

--  Ver los extents de un segmento

SELECT FILE_ID, BLOCK_ID, BYTES, BLOCKS, EXTENT_ID
FROM dba_extents
WHERE segment_name = 'BLOQUEOS';

-- podríamos ver en qué bloque de datos hay cada fila que tengo en la tabla

SELECT rowid,
       dbms_rowid.rowid_block_number(rowid) AS bloque,
       dbms_rowid.rowid_row_number(rowid) AS fila,
       nombre, numero
FROM bloqueos;

SELECT dbms_rowid.rowid_block_number(rowid), count(*)
FROM bloqueos
GROUP BY dbms_rowid.rowid_block_number(rowid)
ORDER BY dbms_rowid.rowid_block_number(rowid);


SELECT * FROM bloqueos WHERE NOMBRE = 'dato_01616' FOR UPDATE;
commit;

--- 10000 datos entre 25 bloques= 400 filas por bloque
-- Cuanto ocupan los datos? 14 bytes * 402 = 5628 bytes

-- Cual era el tamaño de bloque? 8192 bytes
-- Y libre hemos pedido: 10% = 819 bytes PCTFREE

-- Por lo tanto el máximo teórico de filas por bloque es 8192 - 819 = 7373 bytes
-- Y estamos metiendo unos 5628 bytes por bloque...
-- Tenemos un sobrecoste de 7373 - 5628 = 1745 bytes por bloque

-- Esos 1.7Kbs es lo que se que ocupa la cabecera de bloque,
-- y los metadatos adicionales que se guardan a nivel de cada registro

SELECT * FROM v$lock  where block = 1;
commit;


AAAR5OAAMAAA A5D <--- INFORMACION FICHERO + BLOQUE
               ^
               Número de fila ROW NUMBER DENTRO DEL BLOQUE


SELECT * FROM dba_tables WHERE table_name = 'BLOQUEOS';


---

Cuando creamos esa tabla, solicitamos que el 10% del bloque se reserve para futuras actualizaciones de los datos PCTFREE.
Eso son 8 x 1024 / 10 = 819 bytes. ESTABA LIBRE AL CREAR LA TABLA PARA UPDATES.

---

Si esa tabla BLOQUEOS le empezásemos a hacer updates... cuánto de ese espacio me iría comiendo? Los números pueden subir de 1 a 6 bytes.
--- En 819 bytes que habñia libres podríamos meter registros de ITL: 819/24 = 34 registros de ITL

Al menos 1 (INITRANS está ya ocupando espacio en la cabecera... )
Potencialmente podríamos llegar a tener 35 registros de ITL si no se hace ningún update.
En cuanto empiecen los UPDATES... y baje el espacio libre... No habrá hueco para tanto ITL
De hecho puedo llegar a no tener hueco para ninguno extra (más allá de ese 1, que siempre tendremos reservado por INITRANS)






SELECT * FROM v$lock;

---  Transacciones que generan bloqueo:
SELECT s.sid, s.serial#, s.username, s.status, l.type, l.id1, l.id2 FROM v$session s JOIN v$lock l ON s.sid = l.sid WHERE l.block = 1;

--- El sysdba:
ALTER SYSTEM KILL SESSION '20,28520' IMMEDIATE;