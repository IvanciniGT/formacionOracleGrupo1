# BLOQUEOS DE REGISTROS

Oracle no bloquea bloques de datos (páginas) sino que bloque registros. El concepto de bloque de bloque no existe en Oracle.
Existe una tabla a nivel de la cabecera de cada bloque que contiene información sobre las transacciones que están bloqueando registros (y cuales). Esa tabla se llama ITL (ITL - Interested Transaction List). 
En esa tabla podemos tener un número determinado de entradas.. no es infinita: Cada bloque ocupa 8Kbs.

Una entrada del ITL ocupa 24 bytes. Potencialmente hablando podríamos guardar 8*1024/24 = 341 entradas por bloque. 
Eso no tendría sentido... si lleno todo el bloque con ITLs, significa que no hay hueco para datos. Si no hay hueco para datos.. que Transacciones bloquean datos?

Dependiendo del tamaño de registro, en un bloque entran pocos registros.

```sql 
CREATE TABLE usuarios (
    id NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50),
    email VARCHAR2(100),
    fecha_nacimiento DATE,
    poblacion NUMBER(10),
    oto_dato VARCHAR2(100),
);
```

Cada registro de esa tabla me ocupa: 
ID-> 4 bytes
NOMBRE -> 30 bytes
EMAIL -> 40 bytes
FECHA_NACIMIENTO -> 7 bytes
POBLACION -> 4 bytes
OTO_DATO -> 30 bytes
Total: 115 bytes.

En total en el bloque podemos guardar 8*1024 = 8192 bytes.
Cabecera... esa cabecera ocupa espacio... Entre otras cosas en la cabecera tenemos la ITL.
Si los datos mínimos de la cabecera ocupan 100 bytes, nos quedan 8192 - 100 = 8092 bytes para datos.
Realmente entre la cabecera y los datos, está el rowDir, que ocupa 4 bytes por registro. Ignorando esto y haciendo una cuenta optimista, podríamos guardar 8092/115 = 70 registros por bloque.
Eso sería sin contar el PCTFREE, que es el porcentaje de espacio libre que dejamos en cada bloque para futuras inserciones.
Si lo tengo al 10%, me quedan 8092 * 0.9 = 7282 bytes para datos.
Si cada registro ocupa 115 bytes, me quedan 7282/115 = 63 registros por bloque.

La pregunta es cuántas entradas necesito en la tabla ITL.
Lo que ponemos ahí (en la ITL) son las transacciones que están bloqueando registros de ese bloque.
Si solo hay 63 registros por bloque.
Qué probabilidad hay que 2 transacciones traten de modificar el mismo registro al mismo esos 2 de esos 63 registros al mismo tiempo?

10 Entradas de ITL garantizadas (INITRANS)... Cada entrada de ITL ocupa 24 bytes. -> 240 bytes. (Son 2 registros menos por bloque)
2/63 = 0.0317 = 3.17% de espacio adicional que necesito en HDD y RAM... 



0111 0100 

64 hex --> binario 1000000 -> caracter d


---

BLOQUE:
   CABECERA
      ITL
   ROW DIRECTORY (en que byte del fichero empieza cada registro)
   0
   11
   22
   33
   44
   Tantas entradas como filas tenga el bloque
   ROWS (registros)
    BYTES seguiditos
64 61 74 6f 5f 30 31 36 31 33 80 64 61 74 6f 5f 30 31 36 31 34 80 64 61 74 6f 5f 30 31 36 31 35 80 64 61 74 6f 5f 30 31 36 31 36 80...

ROW_ID es un id único de cada registro en la tabla.
Pero ese ROW_ID realmente no se guarda en el bloque, ni en ningún sitio.
El ROW_ID es un concepto lógico que se construye a partir de la dirección del bloque (FILE_ID, #BLOQUE) y la posición del registro dentro de ese bloque.

ROW_ID = FILE_ID + BLOCK_ID + NUM_REGISTRO BLOQUE