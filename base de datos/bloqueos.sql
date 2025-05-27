
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


SELECT * FROM bloqueos WHERE NOMBRE = 'dato_01613' FOR UPDATE;
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