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

SELECT fecha_nacimiento: FECHA FROM usuarios_fechas ;
INSERT INTO otra_tabla (nombre, fecha_nacimiento) VALUES ('Ana', FECHA);
