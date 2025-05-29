
DESC movimientos;

SELECT 
    ROWNUM, cliente, fecha, importe, tipo_mov  
FROM movimientos 
WHERE ROWNUM <= 10;
--ORDER BY fecha;

--ROWNUM es un número que se genera secuencialmente en base a los resultados de una query.
-- CUIDADO... Se aplica antes del ORDER BY.

-- 10 movimientos más antiguos
SELECT 
    * 
FROM 
    (SELECT 
        cliente, fecha, importe, tipo_mov  
    FROM 
        movimientos 
    ORDER BY 
        fecha ASC)
WHERE 
    ROWNUM <= 10;

SELECT USER FROM DUAL;
SELECT 1 FROM DUAL;

-- Hora actual/ fecha actual del servidor
SELECT SYSDATE FROM DUAL;
-- Hora actual/ fecha actual del cliente
SELECT CURRENT_DATE FROM DUAL;


-- El importe del primer movimiento de Ana Martínez

SELECT 
    cliente, fecha, importe 
FROM 
    (SELECT * FROM movimientos WHERE cliente = 'Ana Martínez' ORDER BY fecha ASC)
WHERE 
    ROWNUM = 1;

SELECT 
    cliente, fecha, importe 
FROM 
    movimientos 
WHERE 
    cliente = 'Ana Martínez'
    AND fecha = (SELECT min(fecha) FROM movimientos WHERE cliente = 'Ana Martínez');


-- El importe del primer movimiento de cada persona


SELECT 
    m.cliente, m.fecha, m.importe 
FROM 
    movimientos m,
    (SELECT cliente, min(fecha) as inicial, max(fecha) as final FROM movimientos GROUP BY cliente) primeros
WHERE 
    m.cliente = primeros.cliente
    AND (m.fecha = primeros.inicial
    OR m.fecha = primeros.final)
ORDER BY
    m.cliente, m.fecha;

--- Para estas cosas, quien me ayuda son las funciones de ventana.. y hay veces que no hay otra forma
-- Quiero saber en diferencial de saldo de una operación, con respecto a la anterior
-- Cuanta pasta de diferencia entre la operación actual y la anterior

SELECT  cliente, 
        fecha, 
        importe,
        LAG(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS importe_anterior,
        LEAD(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS importe_siguiente,
        SUM(importe) OVER (PARTITION BY cliente ORDER BY fecha ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS saldo_acumulado,
        ROW_NUMBER() OVER (PARTITION BY cliente ORDER BY fecha) AS num_operacion,
        AVG(importe) OVER (PARTITION BY cliente ORDER BY fecha ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS promedio,
        RANK() OVER (PARTITION BY cliente ORDER BY ABS(importe) DESC) AS importancia,
        DENSE_RANK() OVER (PARTITION BY cliente ORDER BY ABS(importe) DESC) AS importancia_densa,
        FIRST_VALUE(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS primer_importe,
        LAST_VALUE(importe) OVER (
            PARTITION BY cliente 
            ORDER BY fecha 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS ultimo_importe
FROM movimientos;


DROP TABLE Importancia;

CREATE TABLE Importancia (
    nombre VARCHAR2(50),
    cantidad NUMBER
);

-- Cargamos 500 datos aleatorios
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO Importancia (nombre, cantidad) 
        VALUES (
            DBMS_RANDOM.STRING('U', TRUNC(DBMS_RANDOM.VALUE(1,2))),
            FLOOR(DBMS_RANDOM.VALUE(1, 5))
        );
    END LOOP;
    COMMIT;
END;
/

SELECT 
    nombre,
    cantidad,
    RANK() OVER ( PARTITION BY nombre ORDER BY cantidad DESC) AS Rango,
    DENSE_RANK() OVER ( PARTITION BY nombre ORDER BY cantidad DESC) AS Rango2
FROM IMPORTANCIA;


--- Peculiaridades y funciones SQL en Oracle

-- Funciones de ventana
-- ROWNUM (que se aplica antes del ORDER BY)
-- DUAL (tabla ficticia de Oracle, cuando no tengo from en una query)
--  '' = NULL Una cadena vacía se trata como null
--  NULL = NULL     FALSE!      "IS NULL"
-- SYSDATE (fecha y hora del servidor)
-- CURRENT_DATE (fecha y hora del cliente)
-- SYSTIMESTAMP (fecha y hora del servidor con fracción de segundos)
-- CURRENT_TIMESTAMP (fecha y hora del cliente con fracción de segundos)
-- CONNECT BY (para jerarquías)... queries anidadas
-- IN() están limitadas a 1000 valores. Para más de 100 valores no funciona
SELECT * FROM tabla WHERE columna IN (valor1, valor2, ...); -- no es que lo s escribamos a mano
SELECT * FROM tabla WHERE columna IN (SELECT valor FROM otra_tabla); 

-- FUNCIONES DE FECHA:

-- Transformar texto a fecha
SELECT TO_DATE('2023-10-01', 'YYYY-MM-DD') FROM DUAL;
-- Transformar fecha a texto
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM DUAL;

-- CUIDADO. Oracle hace conversión automatica de texto a fecha y viceversa...
-- Con los formatos por defecto establecidos a nivel de sesión o de base de datos.
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';

INSERT INTO movimientos (cliente, fecha, importe, tipo_mov)
VALUES ('Ana Martínez','2014-10-01', 100, 'INGRESO'); -- en automático se aplica la conversión

SELECT * FROM v$nls_parameters WHERE parameter LIKE 'NLS_DATE_FORMAT'; -- consultar el valor actual del parámetro.

-- TRUNC, quita la información de hora
SELECT 
SYSDATE, 
TRUNC(SYSDATE) ,
SYSTIMESTAMP,
TRUNC(SYSTIMESTAMP)
FROM DUAL;

-- El campo date guarda información de hora en Oracle? SI... otra cosa es que no la esté viendo por el formato

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';


-- Sacar datos que nos interesen:
SELECT EXTRACT(YEAR FROM SYSDATE) AS anio,
       EXTRACT(MONTH FROM SYSDATE) AS mes,
       EXTRACT(DAY FROM SYSDATE) AS dia,
       TO_CHAR(SYSDATE, 'HH24') AS fecha_formateada
FROM DUAL;

-- Si a una fecha le sumo un número, se suma ese número de días
SELECT SYSDATE + 1.5 AS fecha_mañana,
       SYSDATE + 7 AS fecha_siete_dias,
       SYSDATE + 30 AS fecha_trenta_dias
FROM DUAL;
-- Si quiero sumar meses
SELECT ADD_MONTHS(SYSDATE, 1) AS fecha_mes_siguiente,
       ADD_MONTHS(SYSDATE, 6) AS fecha_seis_meses,
       ADD_MONTHS(SYSDATE, 12) AS fecha_un_año,
       MONTHS_BETWEEN(SYSDATE, ADD_MONTHS(SYSDATE, 1)) AS meses_diferencia
FROM DUAL;

-- Ultimo día de mes
SELECT LAST_DAY(SYSDATE) AS ultimo_dia_mes
FROM DUAL;

-- Si restamos fechas nos da la diferencia en días
SELECT 
    SYSDATE - TO_DATE('2025-05-28', 'YYYY-MM-DD') AS dias_1,
    SYSDATE - TO_DATE('2025-06-01', 'YYYY-MM-DD') AS dias_2
FROM DUAL;

SELECT 
SYSDATE - CURRENT_DATE as intervalo,
NUMTODSINTERVAL(SYSDATE - CURRENT_DATE, 'day') as intervalo
FROM DUAL;




SELECT SYSDATE FROM DUAL;
--- Cadenas de texto

SELECT SUBSTR('Hola Mundo', 5) FROM DUAL WHERE SUBSTR('Hola Mundo', 1,4) = 'Hola';
-- Devuelve 'Hola'

CREATE TABLE textos (
    texto VARCHAR2(1000),
    nombre VARCHAR2(100),
    DNI VARCHAR2(10)
);

-- Insertar un texto de 200 caracteres
INSERT INTO textos (texto, nombre, DNI) VALUES ('En un lugar de la Mancha, de cuyo nombre no quiero acordarme, no ha mucho tiempo que vivía un hidalgo de los de lanza antigua, rocín flaco y galgo corredor.', 'Miguel de Cervantes', '12345678A');
INSERT INTO textos (texto, nombre, DNI) VALUES ('Otro texto de prueba, con más de 200 caracteres, para comprobar el funcionamiento de las funciones de texto en Oracle. Este texto es un poco más largo y debería ser suficiente para probar las funciones de manipulación de cadenas.', 'Anónimo', '87654321B');


-- Quiero sacar la letra del DNI:

SELECT 
    SUBSTR(DNI, -1) AS letra_dni,
    SUBSTR(DNI, 9 , 1) AS letra_dni2,
    SUBSTR(DNI, 9) AS letra_dni3
FROM
    textos;

SELECT 
    nombre,
    INSTR(nombre, ' '),
    substr(nombre, 1, INSTR(nombre, ' ') - 1) AS primer_nombre

FROM
    textos;


-- Expresiones regulares... sintaxis perl

SELECT REGEXP_SUBSTR(texto, '[0-9]+', 1, 1) AS numeros,
         REGEXP_SUBSTR(texto, '[A-Z][a-z]+', 1, 1) AS primera_palabra_mayuscula,
         REGEXP_SUBSTR(texto, '[A-Z][a-z]+', 1, 2) AS segunda_palabra_mayuscula
FROM textos;
-- ARG 1 = Campo o texto a analizar
-- ARG 2 = Expresión regular
-- ARG 3 = Posición inicial (1 por defecto)
-- ARG 4 = Ocurrencia (1 por defecto, la primera)


SELECT LOWER(nombre) AS nombre_minuscula,
       UPPER(nombre) AS nombre_mayuscula,
       INITCAP(nombre) AS nombre_capitalizado,
       REGEXP_SUBSTR(texto, '[0-9]+', 1, 1) AS numero,
       REPLACE(texto, REGEXP_SUBSTR(texto, '[0-9]+', 1, 1), SUBSTR('------------', 1, LENGTH(REGEXP_SUBSTR(texto, '[0-9]+', 1, 1)))) AS texto_sin_numero,
       TRANSLATE(nombre, 'áéíóú', 'aeiou') AS nombre_sin_tildes
FROM textos;

-- Típìcas de espacios en blanco:
-- TRIM(texto1) (elimina espacios al principio y al final)
-- LTRIM(texto1) (elimina espacios al principio)
-- RTRIM(texto1) (elimina espacios al final)
-- LPAD(texto1, longitud, caracter) (rellena con el caracter indicado a la izquierda hasta alcanzar la longitud indicada)
-- RPAD(texto1, longitud, caracter) (rellena con el caracter indicado a la derecha hasta alcanzar la longitud indicada)
-- LENGTH(texto1) (longitud del texto)
-- CONCAT(texto1, texto2)


SELECT * FROM MOVIMIENTOS;

--- Movimientos del mes anterior... mes de calendario

SELECT *
FROM movimientos
WHERE TO_CHAR(fecha, 'YYYY-MM') = TO_CHAR(ADD_MONTHS(CURRENT_DATE,-1), 'YYYY-MM')
ORDER BY FECHA;

--- La función trunc(fecha) devuelve la fecha con hora 00:00:00 del día indicado
--- Pero esa función acepta argumentos adicionales para truncar a mes, año, etc.
SELECT 
    TRUNC(SYSDATE) AS inicio_dia,
    TRUNC(SYSDATE, 'MM') AS inicio_mes,
    TRUNC(SYSDATE, 'YYYY') AS inicio_año,
    TRUNC(SYSDATE, 'IW') AS inicio_semana_iso,
    TRUNC(SYSDATE, 'D') AS inicio_semana_domingo
FROM DUAL;



SELECT 
    cliente, 
    fecha, 
    importe, 
    tipo_mov,
    TRUNC(ADD_MONTHS(CURRENT_DATE, -1), 'MM') ,
    TRUNC(CURRENT_DATE, 'MM')
FROM movimientos
WHERE 
    fecha >= TRUNC(ADD_MONTHS(CURRENT_DATE, -1), 'MM') 
    AND fecha < TRUNC(CURRENT_DATE, 'MM')
ORDER BY FECHA;
--- Hace 2 trunc... sobre parametros... Para todas las comparaciones se aplica lo mismo


SELECT 
    cliente ,
    fecha, 
    importe 
FROM 
    movimientos 
WHERE 
    trunc(fecha, 'MM') = trunc(add_months(current_date, -1), 'MM')
--- Conceptualmente si.
--- El problema es que esto tiene que calcular cada vez que hace la query el valor trunc(fecha, 'MM') para cada fila.BLOQUEOS
--- Si tienes 1M de filas... 1 M de truncs

SELECT 
    cliente,
    CASE
        WHEN importe > 0 THEN 'Ingreso'
        WHEN importe < 0 THEN 'Gasto'
        ELSE 'Sin movimiento'
    END AS tipo_movimiento
FROM
MOVIMIENTOS;

SELECT 
  Tipo_mov,
  DECODE(Tipo_mov, 
         'DEPOSITO', 'Ingreso', 
         'RETIRO', 'Gasto', 
         'Sin movimiento') AS tipo_movimiento,
  CASE 
    WHEN Tipo_mov = 'DEPOSITO' THEN 'Ingreso'
    WHEN Tipo_mov = 'RETIRO' THEN 'Gasto'
    ELSE 'Sin movimiento'
  END AS tipo_movimiento2
FROM MOVIMIENTOS;


-- (+) JOINS DESUSO  -> OUTER JOIN