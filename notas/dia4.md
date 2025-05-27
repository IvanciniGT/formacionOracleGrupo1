Tenemos un Oracle montado.
Dentro tenemos un pdb.
Creamos tablas:


      USUARIOS < VISUALIZACIONES > PELICULAS < DIRECTORES
                                      v
                                   TEMATICA
      1M              2M          



Empezamos el otro día a ejecutar algunas queries.
Peculiaridades a tener en cuenta con Oracle y el SQL:
- FECHAS
- JOINS (+)

Planes de ejecución <- Impacto de crear índices, ESTADISTICAS
Analizar la cache de Bloques de datos.

---

Por defecto, cuando Oracle calcula las estadísticas de una tabla, asume que los datos están uniformemente distribuidos. Y eso no siempre es cierto.

Imaginad los DNIs de una personas... 
- Cuantos empiezan por 1? 10%
- Cuantos empiezan por 2? 10%
- Cuantos empiezan por 3? 10%
- Cuantos empiezan por 4? 10%
- Cuantos empiezan por 5? 10%

Distribución uniforme de los datos.

Si miro otro campo, las cosas pueden no se así.

Tabla: nombres de personas
a? 1/27
b? 1/27
c? 1/27
d? 1/27

En el caso de los nombres de personas, la distribución no es uniforme. Hay nombres que se repiten más que otros. Hay más nombres que empiezan por A que por Z.
Oracle, por defecto, no sabe eso. Y por defecto, al calcular las estadísticas, asume que los datos están uniformemente distribuidos.

En estos casos podemos montar una estadísticas un poco más elaboradas, mediante histogramas. Cuando trabajamos con histogramas


HISTOGRAMA me refleja la distribución de unos datos... Lo puedo calcular sobre una tabla o sobre un índice.
La tabla o el Índice son LOS DATOS. Y tendrán estadísticas. Esas estadísticas las puedo calcular asumiendo que los datos están uniformemente distribuidos, o no.


COLUMNA DNI <- Sobre ella calculo estadísticas -> Oracle mira los datos... por ejemplo un 10% de los datos.. Y ve que hay muchos DNIs que empiezan por 1, 2, 3, 4, 5, 6, 7, 8, 9... y asume que la distribución es uniforme.y que para cada número inicial hay un 10% de los datos.
Y esa columna la puedo tener en una tabla o en un índice.

Columna NOMBRE <- Sobre ella calculo estadísticas -> Oracle mira los datos... por ejemplo un 10% de los datos.. Y ve que hay muchos nombres que empiezan por A, B, C, D, E, F, G, H, I, J... y asume que la distribución es uniforme.y que para cada letra inicial hay un 1/27% de los datos.

Ahora, le puedo decir a Oracle... Oye no... los datos no siguen una distribución uniforme. Y le puedo decir que calcule un histograma de la columna NOMBRE, para que sepa que hay más nombres que empiezan por A que por Z.

Ocurrencias
    ^
    |
    |     X      X     X     X     X     X      X     X     X    X
    |     X      X     X     X     X     X      X     X     X    X
    |     X      X     X     X     X     X      X     X     X    X
    +-----1------2-----3-----4-----5-----6------7-----8-----9----10------> DNIs


Ocurrencias
    ^     X
    |     X      X 
    |     X      X     
    |     X      X     X
    |     X      X     X     X     x     x            .     .
    +-----1------2-----3-----4-----5-----6------7-----8-----9----10------> Cantidad Productos vendidos en una venta

Al crear un histograma en las estadísticas, le puedo decir cuántos buckets quiero que cree. Por ejemplo, si le digo que cree 200:

Se hace con el mismo procedimiento que el cálculo de estadísticas normal... pero indicándole que cree un histograma. Y le digo cuántos buckets quiero que cree.

EXEC DBMS_STATS.GATHER_TABLE_STATS(
    ownname => 'USUARIOS',
    tabname => 'PELICULAS',
    estimate_percent => 10,
    method_opt => 'FOR ALL COLUMNS SIZE <BUCKETS>'
);

Si en <buckets> pongo 1, solo calcula min y max... y asume que la distribución es uniforme.
Para los dnis me vale: Mínimo 0, Máximo 99.999.999 y piensa que entre 0-10.000.000 hay un 10% de los datos, entre 10.000.001-20.000.000 hay un 10% de los datos, etc.

Si le pongo en <buckets> 200, ya no calcula solo min y max, sino que calcula los valores de los buckets. Y ya no asume que la distribución es uniforme.

Voy a ver qué valor es el que cierra el bucket 1, el 2, el 3, etc. 
De forma que los buckets tengan el mismo número de datos. O al menos, lo más parecido posible.

Lo que pasa es que estas estadísticas son más costosas de calcular. Pero en columnas con distribuciones no uniformes, es mejor calcularlas.

---

# Bloqueos de registros en Oracle

En cualquier BBDD podemos hacer bloqueos de registros.
Nos ayuda a gestionar la concurrencia de acceso a unos datos, de forma que 2 personas no puedan modificar el mismo dato al mismo tiempo.

SELECT * FROM USUARIOS WHERE ID = 1 FOR UPDATE;
Eso la mantiene bloqueada a nivel de sesión, de mi sesión. 
Se libera el bloqueo cuando hacemos un commit o un rollback.

Esto es lo que llamamos un bloqueo a nivel de transacción... que en este caso aplica a un registro concreto, el de ID = 1.

A veces hacemos bloqueos a nivel de tabla. Esto lo hace Oracle... si ejecuto un DML (INSERT, UPDATE, DELETE) sobre una tabla, Oracle bloquea la tabla a nivel de transacción.

Pero sabemos, que Oracle los datos (registros) los guarda en bloques, que son trozos (cachos) de un fichero. Cuando creo la BBDD le digo a Oracle el tamaño de los bloques, que por defecto es 8KB.

Ya dijimos que el bloque es la unidad mínima de almacenamiento lectura/escritura de datos en Oracle a disco.

# La gran duda a este respecto: En Oracle los bloqueos son a nivel de bloque, o a nivel de registro.

Lo cierto es que bloquea a nivel de REGISTRO... pero a veces, nos ocurre otro problema... es lo que se llama Contención de bloques.

Cuando yo solicito que un registro se bloquee para update, Oracle bloquea el registro... y lo hace añadiendo en la cabecera del bloque en el que está ese registro un indicador de que ese registro está bloqueado.

    ---------BLOQUE DE DATOS----------
    Header
       ITL
    Especie de índice de los registros que hay en el bloque: RowDirectory
    Registro 1
    Registro 2
    Registro 3
    ....
    -----------------------------------

Ese ITL (Interested Transaction List) es una especie de tabla que me dice qué transacciones están interesadas en los registros que hay en ese bloque... y el estado en el que se encuentran. Aquñi es donde se anotaría que un registro está bloqueado por una transacción concreta.


Esto suele funcionar bien... a no ser que:
- Tenga tablas de muy alta concurrencia, con muchas transacciones que acceden a los mismos bloques.
En estos casos se produce CONTENCIÓN A NIVEL DE BLOQUE (concretamente a nivel del ITL del bloque).
Oracle, cuando crea un bloque de datos, genera una tabla ITL en la cabecera... y en esa tabla ITL hay un número limitado de entradas. Esa cantidad de entradas se denomina INITRANS.

Ese dato (INITRANS) se define al crear la tabla.
Es el número de transacciones a las que dejo hueco en el ITL del bloque, para que puedan anotar sus bloqueos de registros SIMULTÁNEOS.
Antiguamente (preOracle 12 u 11) había un parametro que se llamaba MAXTRANS, que era el número máximo de transacciones que podían añadir al ITL del bloque.
Hoy en día, no hay MAXTRANS, sino que el número máximo de transacciones que pueden añadir al ITL del bloque depende del espacio que haya en el bloque (entre otras cosas condicionado por el PCTFREE, que es el espacio libre que dejo en el bloque al crearlo). Por defecto, lo que se me asegura es que al menos voy a tener siempre espacio para lo que haya definido en INITRANS.

El problema es que si tengo el ITL lleno en un momento dado, y llega una transacción que quiere bloquear un registro de ese bloque, no puede hacerlo. No se puede escribir en el ITL, porque no hay espacio. Y entonces, la petición (QUERY) se queda en espera... no del registro, sino a que pueda escribir en el bloque porque hay espacio en el ITL.
En cuanto cualquier transacción de ese bloque acaba, el espacio que estaba ocupado por esa transacción en el ITL se libera, y la transacción que estaba esperando puede continuar.

Entonces: y RESUMIENDO:

- Los bloqueos son a nivel de REGISTRO.                                     <<<BLOQUEO
- El problema es que se anotan a nivel de bloque en el ITL del bloque.      <<<CONTENCIÓN
- Y si no hay espacio en el ITL del bloque, la transacción que quiere bloquear un registro de ese bloque se queda esperando a que haya espacio en el ITL.


Como regla general: 
- Tablas con poca concurrencia: INIT TRANS bajo (1 o 2) y un PCTFREE bajo (10-15%).
- Tablas con mucha concurrencia: INIT TRANS alto (5-10) y un PCTFREE más alto (15-25%).

Lo que marca diferencia es el INITTRANS

El PCTFREE es el espacio libre que dejo en el bloque para que Oracle pueda actualizar los registros que ya hay en el bloque, sin necesidad de tener que mover los datos a otro bloque.

Cuando Oracle modifica un registro, puede ser que tenga hueco para hacerlo en el mismo bloque donde estaba el original o no.


Registro1 (DESCRIPCION= VARCHAR2(4000)) Y tenía solo 3 caracteres ahí guardados.. o ninguno.
Y de repente quieren escribir esos 4000 caracteres en ese registro.
Va a haber hueco en el bloque?
Si: GUAY!
No: Entonces, lo que hace Oracle es mover el registro a otro bloque, y dejar un puntero al nuevo bloque en el bloque original. Y cuando vaya a leer el dato, creo que sigue estando en el bloque original, pero en realidad está en otro bloque. Y eso es lo que se llama MOVIMIENTO DE REGISTROS.
Y empezamos con las dobles lecturas, porque Oracle tiene que leer el bloque original, ver que no está ahí, y seguir el puntero al nuevo bloque donde está el registro. Destroza rendimiento.

El PCT FREE que es un dato que configuramos al crear la tabla, es el espacio que dejamos libre en el bloque para ACTUALIZACIONES (UPDATES) ... de forma que un INSERT que se ejecute no pueda ocupar ese espacio libre AUNQUE HAYA SITIO, pero un UPDATE sí.

Un PCTFREE alto:
- Beneficios: No tenemos cambios de bloques, tengo más concurrencia
- Problemas:  Ocupa más espacio la tabla en DISCO, destroza la RAM (en -SGA-) lo que guardo son bloques. Si los bloques están medio vacíos... estoy tirando RAM a la basura!

En tablas con pocas actualizaciones me interesa un pctfree bajo, porque así aprovecho mejor el espacio en disco y en RAM.
En tablas con muchas actualizaciones me interesa un pctfree más alto, porque así evito los movimientos de registros y las dobles lecturas.... pero con cuidado que destrozo RAM y peto el disco


En esta tabla:

```sql
CREATE TABLE USUARIOS (
    ID NUMBER PRIMARY KEY,
    NOMBRE VARCHAR2(100),
    DNI CHAR(9) NOT NULL,
    FECHA_NACIMIENTO DATE
    HIJOS NUMBER,
) PCTFREE 10 INITRANS 2;
```

Si hago un update del campo DNI, en qué afecta el PCT_FREE? En nada... porque tiene tamaño fijo y es NOT NULL... por lo que desde el principio tiene todos los datos y el tamaño máximo que ocupa prereservado... Cuando llegue un DNI nuevo (si llega) se escribe en el mismo sitio, sobre el original.

La fecha de nacimiento también es de ancho fijo... pero es NULLABLE... Si no me han metido dato al crear el registro, aunque la columna es de ancho fijo, no se preserva espacio para ese dato. Si luego llega un dato, hay que hacerle hueco.. a ver si hay!

Lo mismo me pasaría con HIJOS.

La columna NOMBRE es la más problemática, porque es de ancho variable y da igual que esté nullable o no. En cuanto haya un update, hay riesgo de que ocupe diferente... bien porque estuviera vacío y ahora tenga 100 caracteres, o porque estuviera con 3 caracteres y ahora tenga 50... en ese caso, si no hay hueco, hay que mover el registro a otro bloque = PROBLEMON

PROBLEMON:
1. En el bloque original, se queda el dato... marcado como muerto!
2. Oracle va a necesitar una doble lectura para leer el registro, porque va a leer el bloque original, ver que no está ahí, y seguir el puntero al nuevo bloque donde está el registro.

Por eso de vez en cuando, en este tipo de sistemas, necesitamos reescribir los bloques de datos, para que no haya huecos muertos y evitar las dobles lecturas, etc...

