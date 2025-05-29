CREATE TABLE transacciones (
    id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente       VARCHAR2(50),
    fecha         DATE,
    saldo         NUMBER(10, 2),
    tipo_mov      VARCHAR2(10)
);

BEGIN
  FOR i IN 1..1000 LOOP
    INSERT INTO transacciones (cliente, fecha, saldo, tipo_mov)
    VALUES (
      CHR(65 + MOD(TRUNC(DBMS_RANDOM.VALUE(0, 26)), 26)) || CHR(65 + MOD(TRUNC(DBMS_RANDOM.VALUE(0, 26)), 26)), -- Nombre tipo "AB"
      TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 180)),  -- Fechas aleatorias en últimos 6 meses
      ROUND(DBMS_RANDOM.VALUE(10, 5000), 2),        -- Saldos entre 10 y 5000
      CASE WHEN DBMS_RANDOM.VALUE(0,1) < 0.5 THEN 'CREDITO' ELSE 'DEBITO' END
    );
  END LOOP;
  COMMIT;
END;
/

SELECT cliente, fecha, saldo, tipo_mov,
       LAG(saldo) OVER (PARTITION BY cliente ORDER BY fecha) AS saldo_anterior,
       saldo - LAG(saldo) OVER (PARTITION BY cliente ORDER BY fecha) AS variacion
FROM transacciones
WHERE cliente = 'AB'
ORDER BY cliente, fecha;

SELECT cliente, fecha, saldo,
       RANK() OVER (PARTITION BY cliente ORDER BY saldo DESC) AS ranking
FROM transacciones
WHERE cliente IN ('AB', 'CD')
ORDER BY cliente, ranking;

SELECT cliente, fecha, saldo,
       FIRST_VALUE(saldo) OVER (PARTITION BY cliente ORDER BY fecha) AS primer_saldo,
       LAST_VALUE(saldo) OVER (
         PARTITION BY cliente ORDER BY fecha
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS ultimo_saldo
FROM transacciones
WHERE cliente = 'AB'
ORDER BY fecha;


CREATE TABLE movimientos (
    id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente      VARCHAR2(100),
    fecha        DATE,
    importe      NUMBER(10,2),
    tipo_mov     VARCHAR2(20)
);

BEGIN
  FOR i IN 1..1000 LOOP
    DECLARE
      nombres VARCHAR2(100) := 
        CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))
          WHEN 1 THEN 'Juan'
          WHEN 2 THEN 'Ana'
          WHEN 3 THEN 'Carlos'
          WHEN 4 THEN 'Laura'
          WHEN 5 THEN 'Miguel'
        END;
      apellidos VARCHAR2(100) :=
        CASE TRUNC(DBMS_RANDOM.VALUE(1, 6))
          WHEN 1 THEN 'Pérez'
          WHEN 2 THEN 'García'
          WHEN 3 THEN 'López'
          WHEN 4 THEN 'Martínez'
          WHEN 5 THEN 'Rodríguez'
        END;
      tipo VARCHAR2(20);
      monto NUMBER(10,2);
    BEGIN
      tipo := CASE WHEN DBMS_RANDOM.VALUE(0,1) < 0.5 THEN 'DEPOSITO' ELSE 'RETIRO' END;
      monto := ROUND(DBMS_RANDOM.VALUE(10, 1000), 2);
      IF tipo = 'RETIRO' THEN
        monto := monto * -1;
      END IF;

      INSERT INTO movimientos (cliente, fecha, importe, tipo_mov)
      VALUES (
        nombres || ' ' || apellidos,
        TRUNC(SYSDATE - DBMS_RANDOM.VALUE(0, 90)),
        monto,
        tipo
      );
    END;
  END LOOP;
  COMMIT;
END;
/

SELECT cliente, fecha, importe, tipo_mov,
       SUM(importe) OVER (PARTITION BY cliente ORDER BY fecha ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS saldo_acumulado
FROM movimientos
ORDER BY cliente, fecha;

SELECT cliente, fecha, importe,
       LAG(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS importe_anterior,
       importe - LAG(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS variacion
FROM movimientos
WHERE cliente = 'Juan Pérez'
ORDER BY fecha;

SELECT cliente, fecha, importe,
       FIRST_VALUE(importe) OVER (PARTITION BY cliente ORDER BY fecha) AS primer_importe,
       LAST_VALUE(importe) OVER (
         PARTITION BY cliente ORDER BY fecha
         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS ultimo_importe
FROM movimientos
WHERE cliente = 'Laura García'
ORDER BY fecha;

SELECT cliente, fecha, importe, tipo_mov,
       SUM(importe) OVER (
         PARTITION BY cliente 
         ORDER BY fecha 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS saldo_real
FROM movimientos
ORDER BY cliente, fecha;

SELECT *
FROM movimientos
WHERE TRUNC(fecha, 'MM') = TRUNC(SYSDATE, 'MM');

SELECT TO_CHAR(fecha, 'YYYY-MM') AS mes, COUNT(*) AS total
FROM movimientos
GROUP BY TO_CHAR(fecha, 'YYYY-MM')
ORDER BY mes;

SELECT cliente, fecha, ADD_MONTHS(fecha, 1) AS proximo_mes
FROM movimientos
WHERE ROWNUM <= 10;

SELECT cliente, fecha, importe,
       FIRST_VALUE(fecha) OVER (PARTITION BY cliente ORDER BY fecha) AS primer_mov
FROM movimientos;

SELECT cliente, fecha, TO_CHAR(fecha, 'DAY') AS dia_semana
FROM movimientos
WHERE ROWNUM <= 10;

SELECT cliente, fecha, ROUND(MONTHS_BETWEEN(SYSDATE, fecha), 2) AS meses_diferencia
FROM movimientos
WHERE ROWNUM <= 10;

SELECT
  cliente,
  TO_CHAR(fecha, 'YYYY-MM') AS mes,
  COUNT(*) AS total_movimientos,
  SUM(importe) AS total_mes,
  SUM(SUM(importe)) OVER (
    PARTITION BY cliente
    ORDER BY TO_CHAR(fecha, 'YYYY-MM')
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS saldo_acumulado
FROM movimientos
GROUP BY cliente, TO_CHAR(fecha, 'YYYY-MM')
ORDER BY cliente, mes;
