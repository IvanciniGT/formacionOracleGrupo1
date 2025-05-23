
# Acceso a datos en ficheros mediante un Sistema Operativo.

- Acceso secuencial: Se accede a los datos de forma secuencial, es decir, se lee/escribe el fichero desde el principio hasta el final.
- Acceso aleatorio: Se accede a los datos de forma aleatoria, es decir, se puede leer/escribir cualquier parte del fichero sin necesidad de hacerlo de principio a fin.
  Ventajas:
  - Se puede acceder a los datos de forma más rápida.
  - Se puede modificar cualquier parte del fichero sin necesidad de leerlo entero.
  Inconvenientes
  - Esto es MUCHÍSIMO MAS COMPLEJO de gestionar 
  El problema gordo es saber en qué posición del fichero debo colocarme para leer o escribir información.

  Las BBDD no son sino programas que nos ayudan a lidiar con acceso aleatorio a ficheros.

## Ejemplo: Fichero de texto JSON

```json
{
  "nombre": "Menchu",
  "edad": 101,
  "ciudad": "Madrid"
}
```

Quiero modificar solamente la edad. Dónde pongo la aguja del HDD? En qué byte? NPI

## Ejemplo de fichero que permita acceso aleatorio

```txt
Menchu      101   Madrid      
Pepe         99   Barcelona   
Felix       100   Valencia    
```

Si conozco que Felix es el tercero. Y que cada linea ocupa 30 caracteres y que el nombre ocupa 12 y que la edad ocupa 3...
Puedo calcula matemáticamente la posición del byte en el que debo colocarme para leer o escribir... y cuánto tengo que leer o escribir:
- Me salto 2 filas completas: 2 * 30 = 60 caracteres
- ME salto el nombre de Felix: 12 caracteres
- En total, me tengo que saltar: 72 caracteres... y tengo que leer 3 (el tamaño que he reservado para la edad)

Un inconveniente de trabajar de esta forma es... la pérdida de espacio que tenemos. De los 90 huequitos que tenemos en ese fichero reservados, solamente hemos escrito en: 14+15+16 = 55 caracteres. El resto (50%) está vacío.

Hemos de buscar técnicas que nos permitan reducir la perdida de espacio. (*Ver nota 1)
Además había otro problema... dónde está Felix en el fichero (Si conozco que Felix es el tercero)... necesito buscar/plantearme técnicas que me permitan saber dónde está Felix en el fichero...

Y todo esto se va volviendo más y más complejo. Y por eso existen las BBDD. Para ayudarme a lidiar con el acceso aleatorio a ficheros.

# Qué guardo en esos ficheros? Cómo lo guardo?

Al final en un HDD, lo que guardamos son bits (0,1). En un bit puedo representar 2 valores diferentes. (solo uno a la vez.. pero potencialmente 2 valores diferentes):
- Puedo guardar un 1 o un 0
Una cosa es lo que guardo.. y otra el significado que le doy a aquello.
- 0-> No llueve, Tiene deuda,   , Tiene dinero en la cuenta,    Tiene tarjeta de crédito
- 1-> Llueve   , No tiene deuda , No tiene dinero en la cuenta, No tiene tarjeta de crédito

Habitualmente trabajamos con bytes (8 bits). En un byte puedo guardar 256 valores diferentes.
  
                  ¿Qué significado le doy a eso?
                    Número entero    Número entero con signo    Letra
    0000 0000           0                -128                    A
    0000 0001           1                -127                    B
    0000 0010           2                -126                    C
    0000 0011           3                -125                    D  
    ...
    1111 1111         255                 127                    .

Una cosa es lo que guardo y otra el significado que le doy a aquello. Ahí es donde entran los TIPOS DE DATOS.
Antes de hablar de tipos de datos... cuando trabajamos con ficheros... al final lo que guardo son BYTES.
Lo que pasa es que los SO me permiten trabajar:
- con los bytes (a nivel de byte)                       Ficheros binarios
- traduciendo en automático esos bytes a texto          Ficheros de texto (csv, json, xml, etc)

En un fichero binario, tengo que saber cómo interpretar cada byte:
- El primer byte puede ser le NUMERO de datos que hay en el fichero
- El segundo byte puede ser ... npi

El fichero binario creado por un programa, sólo ese programa u otro programa que sepa cómo interpretarlo (qué significa cada byte), podrá leerlo.

Mucho más sencillo es trabajar con archivos de TEXTO... todo el mundo sabe cómo leerlos. Cualquier programa lo puede abrir.
El problema de nuevo es el desperdicio de espacio.

Tengo un DNI! De 1 a 8 números y una letra.

Cómo lo guardo en una BBDD?
- Como texto: reservo 9 caracteres:         12345678Z ---> 9 bytes
  Un carácter, cuánto ocupa en disco? Depende del juego de caracteres (la forma en la que mapeamos cada secuencia de bytes a un carácter)
  - ASCII: 1 byte por carácter (256 caracteres)
  - ISO-8859-1: 1 byte por carácter (256 caracteres)
  - UTF-8: 1-4 byte por carácter (256, 65536, 4294967296 caracteres) (ASCII)
  - UTF-16: 2-4 bytes por carácter (65536, 4294967296 caracteres)
  - UTF-32: 4 bytes por carácter (4294967296 caracteres)
- Pero puedo guardarlo de otras formas:
  - Por un lado el número como número y por otro la letra como texto:   5 bytes
    - 1 bytes: 0-255
    - 2 bytes: 0-65535
    - 4 bytes: 0-4294967295 <<< Para el número
    - Para la letra: 1 byte (ASCII, UTF-8)
  - Si guardo sólo el número... y no la letra... 4 bytes
    Al fin y al cabo, la letra se genera desde el número.
    Esta es otra opción... ahorro más espacio...es sí, cuando necesite la letra... tengo que calcularla (tiempo)
  Y tengo que empezar a tomar decisiones: Priorizo el espacio o la velocidad?   


El ahorro... no va solo en pasta a nivel de HDDs... si mis datos (que no son un DNI... son millones de DNIs) ocupan menos espacio... tardo la mitad de tiempo en leerlos y escribirlos, en transmitirlos por red... en subirlos a memoria RAM, en procesarlos, etc.

UNICODE: Un estándar que permite representar todos los caracteres de todos los idiomas del mundo: +150.000 caracteres.

Si estoy guardando 4 datos (lo que guardamos en un WORD, EXCEL...) trabajamos con ficheros de texto.
Si estoy guardando millones de datos, lo que guardamos en una BBDD, trabajamos con ficheros binarios.

Las BBDD además de permitirme trabajar con ficheros de acceso aleatorio, me permiten trabajar con ficheros en formato binario.

Una cosa que necesitan las BBDD es saber cada dato que guardo, qué tipo es (su naturaleza) para determina la forma más optima de guardarlo en disco y la forma más óptima de acceder a él. Y además para saber qué operaciones puedo hacer con él.
A nivel de HDD todo son bytes... pero le tengo que dar pistas de COMO INTERPRETAR ESOS BYTES.. al menos a alto nivel.
- No le voy a explicar lo que es un DNI... pero si que lo puede guardar como un número y una letra.

Toda Base de datos me permite trabajar con un conjunto de TIPOS de datos predefinidos. Además Algunas (la mayoría) me permiten crear tipos de datos personalizados.

# El uso que los programas hacen de la memoria RAM

+ Evitar acceso al HDD: Cache
+ Guardar datos que van generando temporalmente
+ Buffers de escritura: No vamos a ir guardando datos en el HDD uno a uno... los voy acumulando.. y cuando tengo un paquetito de datos, lo guardo en el HDD.... Intento hacer la menor cantidad de accesos al HDD. La operación de vaciar un buffer, aplicándolo la HDD: FLUSH del buffer.
- Poner el propio código del programa

Nuestra BBDD, como programa que es... necesitará usar la RAM para:
- Cachear datos de los ficheros y poder acceder a ellos más rápido
- Guardar datos que va generando temporalmente (columnas calculadas, resultado de consultas, etc)
- Guardar los buffers de escritura.

Pregunta: Cuando quiero conectarme con una BBDD abrimos una conexión a la misma... A través de esa conexión puedo ir ejecutando is consultas. Pero solo tengo una abierta? NO... habitualmente tengo decenas/cientos.

Y... si quiero poder estar haciendo muchas operaciones en paralelo en mi servidor.... qué existe en los SO que me permite hacer varias operaciones simultaneas? Los HILOS (THREADs). Un hilo de ejecución es quien va recorriendo el código de un programa y los va ejecutando (quien lleva el código a un CORE de la CPU). Los hilos se abren dentro de lo que llamamos un proceso. Un proceso es una copia en ejecución de un programa. Un programa puede tener múltiples copias de si mismo en ejecución.. Y cada copia puede tener muchos hilos que van ejecutando el código de esa copia del programa (que tengo en RAM).

Cuando abro una conexión a BBDD desde un cliente, lo que se abre a nivel del servidor es un hilo o un proceso? En la mayor parte de las BBDD lo que se abre es un PROCESO a nivel de SO para cada conexión. En Oracle podemos decidir, si queremos abrir un proceso (MODO DEDICADO) o si queremos dentro de un proceso que atiende conexiones, abrir un hilo para cada conexión (MODO COMPARTIDO). 

Ya entraremos en el detalle de esto. Aunque como recomendación general, lo que abrimos siempre es un proceso.

Un problema que tenemos cuando abrimos varios procesos, es el hecho de comunicarlos entre si.
Tengo problemas para comunicar 2 hilos de un proceso entre si? En general esto es sencillo... ya que los hilos de un proceso comparten la misma memoria RAM. Puedo hacer fácilmente que un hilo escriba un dato en RAM y que otro hilo (u otros) lean ese dato de RAM.
Es una funcionalidad muy estándar que nos ofrece cualquier SO.

El problema viene cuando tengo 2 hilos de distintos procesos. Cada proceso tiene su propia memoria RAM (ESO ES OBLIGADO POR CUALQUIER SO). A priori no podemos hacer que un hilo de un proceso escriba en la RAM de otro proceso. Para eso tenemos que recurrir a mecanismos de comunicación entre procesos (IPC). Hay varios tipos de IPC:
- Pipes
- Sockets
- Memoria compartida (Shared memory)*** ESTE ES DE ESPECIAL RELEVANCIA PARA LAS BBDD... ya que cuál es un uso muy importante que las BBDD hacen de la RAM? CACHE. Las bbdd leen datos de sus ficheros... y los ponen en RAM.

Después habrá 20 clientes conectados a la BBDD... cada uno haciendo sus queries... pero todos ellos deben poder tener acceso a los datos que están en RAM. Eso lo hacen mediante un procedimiento de memoria compartida.

Cuando trabajamos con una BBDD tendremos un proceso principal... con su memoria RAM. Ahí se guardan los datos que se van leyendo de disco (CACHE). Cada conexión tendrá su propio proceso (con su propio hilo) para atender las peticiones que se realicen desde un cliente. Y en algunos casos  (en la mayoría) necesitarán tener acceso a esos datos que están en RAM. Eso se hace generando una zona de memoria RAM que está compartida entre el proceso principal y los procesos de las conexiones. En oracle Esa zona de memoria RAM se llama SGA (System Global Area). En otras BBDD recibe otro nombre. El nombre es lo de menos.. a no ser que tenga que configurarlo.. y entonces necesito saber el nombre... para buscar el parámetro que tengo que modificar.

En esa zona, no se guarda solamente la cache... hay otros datos, que los procesos necesitan compartir:
- diccionario de datos: Qué tablas tengo, qué columnas tiene cada tabla, qué tipos de datos tiene cada columna, qué índices tengo, qué restricciones tengo, etc.

Además, cada proceso (conexión) va a tener su propia memoria RAM. Cuando un cliente se conecta a la BBDD, ejecuta una query... y tiene sus propios datos como resultado de esa query. Esos datos sólo aplican a esa conexión... y se guardan en su propia memoria RAM:
- PGA (Program Global Area). En otras BBDD recibe otro nombre. Esa memoria RAM se usa para:
  - Guardar temporalmente los datos que se van generando desde esa conexión (columnas calculadas, resultados de consultas, etc)
  - Ordenar los datos que se van a devolver al cliente (ordenar, agrupar, etc)

Si el tamaño de esas zonas de memoria RAM (SGA y PGA) no es suficiente, cuando la BBDD quiera / necesite más espacio, el SO le dará más espacio... pero no de la RAM... sino del HDD (el SO decide usar el HDD como RAM: paginación-swapping). Y eso es un desastre en el rendimiento.

SGA hay uno por instancia de BBDD... mientras que PGA hay uno por cada conexión a la BBDD (o por cada tarea interna de la BBDD: mantenimientos, estadísticas, backups, etc).

> Ejemplo: Tengo un documento WORD... y en él hay datos que me quiero llevar a un EXCEL... cómo lo hago? Qué mecanismo me ofrece WINDOWS para comunicar esos procesos? PORTAPAPELES.

# Las operaciones típicas que necesito hacer en una BBDD y cómo una BBDD puede realizar esas operaciones.

Las operaciones típicas son las que llamamos CRUD:
- Create: Crear datos
- Read: Leer datos
- Update: Modificar datos
- Delete: Borrar datos

Hay que entender cómo las BBDD hacen esas operaciones.

## CREATE. Qué ocurre cuando en una BBDD creamos un dato nuevo en una tabla.

> INSERT INTO USUARIOS (id, nombre, edad, ciudad) VALUES (127,'Menchu', 101, 'Madrid');

Qué hace Oracle?
- Asignar a ese registro un Identificador interno.
- Elegir el bloque donde va a guardar ese registro. Para ello, busca un bloque que tenga espacio suficiente para guardar el nuevo registro.
- Se carga el bloque en RAM, si es que no lo tiene ya.
- En ese bloque, se modifica el INDICE DE DATOS (Row Directory) para incluir el identificador del nuevo registro y la posición dentro del bloque donde se va a guardar.
- Se añaden los datos del nuevo registro al final del bloque.
- Se guarda el bloque en el HDD (esta operación se suele encolar en un buffer de escritura, para no tener que hacer un acceso al HDD cada vez que se inserta un registro).
En general esto es bastante rápido. El bloque ya estará en RAM.

## DELETE 

El delete no borra los datos... lo que hace simplemente es marcar el registro como muerto.
Al final.. es necesario reescribir en HDD el bloque entero...

El problema no va a ser escribir eso... el problema viene de saber en qué bloque está ese dato?
Eso mismo es lo que me pasará con los UPDATE.

## UPDATE

Lo primero es saber en qué bloque está el dato que quiero modificar.

Oracle lleva un registro de todos los bloques que tiene un SEGMENTO (una tabla, un índice, etc).... y de los rangos de registros que tiene cada bloque.

Lo siguiente es mirar si en ese bloque hay espacio suficiente para guardar el nuevo registro:
- Si lo hay, lo guarda.
- Si no lo hay, lo marca como muerto en ese bloque
- Y se busca otro bloque que tenga espacio suficiente.
- En ocasiones excepcionales, puede ser que Oracle decida que parte de los datos los deja en un bloque y parte en otro bloque. Eso es lo que se llama CHAINING. Eso.. no suele dar muy buen rendimiento. Para acceder a un registro, necesito acceder a 2 bloques.
- Pero es que en ocasiones lo va a quedar más remedio... Puede ser que haya un registro que ocupe más que el tamaño de un bloque ( en general esto tratamos de evitarlo)

## READ (SELECT)

TABLA RECETAS DE COCINA
| ID | NOMBRE                       | TIEMPO | DIFICULTAD | INGREDIENTES        | TIPO DE PLATO | 
| 1  | Tortilla de patatas          | 20     | 1          | Huevo, patata       | Plato único   |
| 2  | Ensalada de pasta            | 10     | 1          | Pasta, lechuga      | Ensalada      |
| 3  | Espaguetis a la carbonara    | 30     | 2          | Espaguetis, huevo   | Pasta         |
| 4  | Pizza de jamón y queso       | 40     | 2          | Harina, jamón, queso| Pizza         |
| 5  | Escalivada de verduras       | 25     | 1          | Verduras            | Primero       |
| 6  | Cordero asado                | 60     | 3          | Cordero, patatas    | Segundo       |
| 7  | Bacalao a la vizcaína        | 45     | 2          | Bacalao, pimientos  | Segundo       |


Quiero buscar los Segundos.

SELECT * FROM RECETAS WHERE TIPO_DE_PLATO = 'Segundo';

Lo que va a mirar es bloque a bloque (todos los bloques) y dentro de cada bloque TODOS LOS DATOS que hay en ese bloque.
Si en un registro pone: Segundo, lo va añadiendo a una lista de resultados temporales en RAM... para devolverlos al cliente.

BÁSICAMENTE NECESITA LEER UNO A UNO TODOS LOS DATOS QUE HAY EN LA TABLA: FullScan
Esto os parece muy eficiente? Si tengo pocos datos datos... da igual...
El problema es que según tenga más datos y más datos, el rendimiento va a caer en picado.
El tiempo que tardo en hacer una búsqueda es proporcional al número de registros que tengo en la tabla.

Las BBDD relaciones tienen el concepto de INDICE... que me ayuda con estas cosas...

# INDICE?

Es una copia ORDENADA de ciertos datos de una tabla... junto con las ubicaciones de esos datos en el sistema.

| TIPO DE PLATO  | Ubicación      |
|----------------|----------------|
| Ensalada       | 1              |
| Pizza          | 4              |
| Plato único    | 1              |
| Primero        | 5              |
| Segundo        | 6,7            |
|----------------|----------------|

Porqué un índice me ayuda al hacer una búsqueda? Los índices me permiten cambiar el algoritmo de búsqueda.
Cuando tengo un índice, en lugar de aplicar un FullScan, puedo aplicar un algoritmo de búsqueda binaria.

1.000.000 
  500.000
  250.000
  125.000
   62.500
   31.250
   15.625
    7.812
    3.906
    1.953
      976
      488
      244
      122
       61
       30
       15
        7
        3
        1

Sobre 1 millón de datos, tardo 20 pasos en encontrar el dato que busco.

Hacer esto, solo tiene una pega... NECESITO LOS DATOS ORDENADOS. Como lo están un un diccionario.
El problema es que según meto los datos a una tabla, van a estar los datos ordenados? NO...

Puedo calcular el orden bajo demanda... ORDENAR LOS DATOS BAJO DEMANDA!

A los ordenadores se les da fatal ordenar datos... es lo peor (computacionalmente hablando) que se le puede pedir a un ordenador.

De hecho tardaría MUCHO MUCHO MUCHO MAS en ordenar los datos, que en leer los datos secuencialmente de uno en uno: FULLSCAN!


Una BBDD no parte a la mitad los datos, igual que yo abro un diccionario a la mitad si me piden que busque ALCACHOFA.
Las BBDD optimizan el primer, segundo y hasta tercer corte, gracias a que conocen la distribución de los datos.
Igual que los seres humanos conocemos como se distribuyen las palabras en un diccionario.
Primero la A, la última la Z.
De la A hay muchas... de la Z hay pocas., de la Ñ hay menos aún.
Conozco más o menos como se distribuyen los datos... en el diccionario... y eso me permite optimizar el primer, segundo... hasta el tercer corte.
Las bases de datos generan ESTADISTICAS de los datos que tienen en sus tablas.
Usan esas estadísticas para optimizar el acceso a los datos, para determinar mejor el primer, segundo (hasta el tercer) corte.

Esas estadísticas, hay que calcularlas... y en algunos casos, hay que irlas regenerando!
REPITO: EN ALGUNOS CASOS !

Imagina la tabla Usuarios.... La columna DNI. Tengo 25.000 datos cargados de clientes que he tenido a lo largo de 2 años.En los siguientes 4 años, me llegan 5 millones de clientes nuevos. 
Necesito regenerar las estadísticas de la columna DNI? PARA NADA !
La distribución de los datos es, fué y será la misma.
Siempre habrá un 10% de datos que empiecen por 1 un 10% que empiecen por 2, un 10% que empiecen por 3... y así hasta el 9.

Tengo la tabla Usuarios.... y la columna FECHA DE NACIMIENTO... va a cambiar la distribución de los datos con el tiempo? Necesitaré ir recalculando las estadísticas de esa columna? SI.

Puedo configurar en prácticamente cualquier BBDD que esas estadísticas se regeneren automáticamente.... y eso funciona muy bien...
Hay veces (por ejemplo, si voy a carga una gran cantidad de datos de golpe), que me puede interesas recalcular las estadísticas de una tabla después de cargar los datos.

# PROBLEMATICA AL USAR INDICES:

1. Espacio de almacenamiento: Estoy reescribiendo en otro sitio algunos de los datos de nuevo.
    En general esto es poco. Ya que lo que se guarda son los valores DIFERENTES: 
    Aunque aparezca Primer plato 30.000 veces en la tabla, en el índice sólo se guarda una vez.
2. Espacio de almacenamiento: El problema no es solo que haya que reescribir ciertos datos (que eso no suele ser mucho problema)
   El problema viene con las ACTUALIZACIONES.
   Qué pasa si aparece una palabra nueva... y la tengo que meter al diccionario?
   Lo que no podemos es andar reescribiendo INDICES... al menos no cada vez que se añade un nuevo dato.
   Lo que hacen las BBDD, que es lo mismo que se hacía en las bibliotecas hace 400 años, es dejar espacio en blanco prereservado para que se puedan añadir nuevos datos.
   Las BBDD, en los ficheros de los índices, dejan espacio en blanco para:
   - Nuevos términos que haya que añadir al índice en el orden alfabético.
   - Nuevos registros que haya que añadir a un término.
   Depende del número de insert que se hagan en la tabla, el espacio que se deja en blanco puede ser más o menos grande.
   Hay veces que configuramos las BBDD para que tengan un FILLFACTOR de un 20%... y que haya un 80% de espacio libre.
   AQUI ES DONDE EL ESPACIO EN LOS INDICES SE VUELVE UN PROBLEMA.
   Antes o después FIJO me quedo sin espacio. 
   Cuanto más espacio libre configure, más después será... pero más pasta de almacenamiento me gasto.
   Eso si.. por mucho que dejes, en algún momento tocará REESCRIBIR el índice (Operación típica de mnto de una BBDD)
   En esa reescritura aprovecharé para generar nuevos espacios en blanco dentro del fichero del índice.... para los próximos x (días, meses, años) de vida del índice.
3. Añadir/modificar/eliminar un dato en una tabla, es una operación razonablemente rápida.
   Si empiezo a crearle índices, cada vez que haya que añadir/modificar/eliminar un dato en la tabla, tengo que hacer lo mismo en cada uno de los índices que tenga esa tabla... y para ello, lo primero será buscar en el INDICE la ocurrencia de ese dato (esto previsiblemente es rápido... pero suma!)



## READ (SELECT)

TABLA RECETAS DE COCINA
| ID | NOMBRE                       | TIEMPO | DIFICULTAD | INGREDIENTES        | TIPO DE PLATO | 
| 1  | Tortilla de patatas          | 20     | 1          | Huevo, patata       | Plato único   |
| 2  | Tortilla de jamón            | 20     | 1          | Huevo, patata       | Plato único   |
| 3  | Ensalada de pasta            | 10     | 1          | Pasta, lechuga      | Ensalada      |
| 4  | Espaguetis a la carbonara    | 30     | 2          | Espaguetis, huevo   | Pasta         |
| 5  | Pizza de jamón y queso       | 40     | 2          | Harina, jamón, queso| Pizza         |
| 6  | Escalivada de verduras       | 25     | 1          | Verduras            | Primero       |
| 7  | Cordero asado con patatitas  | 60     | 3          | Cordero, patatas    | Segundo       |
| 8  | Bacalao a la vizcaína        | 45     | 2          | Bacalao, pimientos  | Segundo       |
| 9  | Ensalada de bacalao          | 10     | 1          | Bacalao, lechuga    | Ensalada      |
| 10 | Tortilla de patatas          | 22     | 2          | Huevo, patata       | Plato único   |
| 11 | Tortilla de patatas          | 14     | 3          | Huevo, patata       | Plato único   |
| 12 | Tortilla de patatas          | 60     | 2          | Huevo, patata       | Plato único   |

Quiero hacer una búsqueda por NOMBRE de la receta. Me sirve un índice?
Podría ser si la búsqueda es del tipo:
    SELECT * FROM RECETAS WHERE NOMBRE = 'Tortilla de patatas';
    SELECT * FROM RECETAS WHERE NOMBRE = 'Bacalao a la vizcaína';
Usará la BBDD el INDICE? Dicho de otra forma.. buscará haciendo el FULLSCAN o usando el INDICE?
En lugar de 12 registros.. imaginad que tengo 2.000.000... y que mi búsqueda devuelve 150. POSIBLEMENTE USE EL INDICE
En lugar de 12 registros.. imaginad que tengo 2.000.000... y que mi búsqueda devuelve 1500. POSIBLEMENTE USE EL INDICE
En lugar de 12 registros.. imaginad que tengo 2.000.000... y que mi búsqueda devuelve 15000. POSIBLEMENTE USE EL INDICE

Hay un momento que la BBDD deja de usar el INDICE, por qué? Porque después de encontrar las recetas con ese nombre (IDS) tiene que ir a buscar el resto de los datos a la tabla.

    SELECT * FROM RECETAS WHERE NOMBRE LIKE 'Tortilla%';

    Le interesa usar el INDICE? AQUI POSIBLEMENTE SE HAGA UN FULLSCAN DEL INDICE.
    En el índice los datos no se encuentran repetidos.



    SELECT * FROM RECETAS WHERE NOMBRE LIKE '%Tortilla%';  ESTA QUERY DEBERÍA ESTAR PROHIBIDA !
    Esto es algo que destroza una BBDD... a no ser que tenga una tabla con 200 datos... y que ejecute esa query una vez cada hora.

    SELECT * FROM RECETAS WHERE UPPER(NOMBRE) LIKE UPPER('%Tortilla%'); 
    Esto es puro FULLSCAN DE LA TABLA... y además, para cada registro haciendo cálculos como el UPPER... contains()...
    pero es que además, los resultados pueden no ser muy buenos.

    Quiero buscar las recetas que contengan "patata" en el título?
        RESPUESTA: 1, 10, 11, 12
        RESPUESTA: 1, 7, 10, 11, 12, 13

TABLA RECETAS DE COCINA

| ID | NOMBRE                       | TIEMPO | DIFICULTAD | INGREDIENTES        | TIPO DE PLATO | 
| 1  | Tortilla de patatas          | 20     | 1          | Huevo, patata       | Plato único   |
| 2  | Tortilla de jamón            | 20     | 1          | Huevo, patata       | Plato único   |
| 3  | Ensalada de pasta            | 10     | 1          | Pasta, lechuga      | Ensalada      |
| 4  | Espaguetis a la carbonara    | 30     | 2          | Espaguetis, huevo   | Pasta         |
| 5  | Pizza de jamón y queso       | 40     | 2          | Harina, jamón, queso| Pizza         |
| 6  | Escalivada de verduras       | 25     | 1          | Verduras            | Primero       |
| 7  | Cordero asado con patatitas  | 60     | 3          | Cordero, patatas    | Segundo       |
| 8  | Bacalao a la vizcaína        | 45     | 2          | Bacalao, pimientos  | Segundo       |
| 9  | Ensalada de bacalao          | 10     | 1          | Bacalao, lechuga    | Ensalada      |
| 10 | Tortilla de patatas          | 22     | 2          | Huevo, patata       | Plato único   |
| 11 | Tortilla de patatas          | 14     | 3          | Huevo, patata       | Plato único   |
| 12 | Tortilla de patatas          | 60     | 2          | Huevo, patata       | Plato único   |
| 13 | Patatas guisadas             | 60     | 2          | Huevo, patata       | Plato único   |

# Alternativa: Usar ÍNDICES INVERTIDOS.

Oracle tiene un subproducto entero (incluido dentro de OracleDatabase... no se paga licencia aparte ni nada... aunque hay que activarlo explícitamente) que se llama Oracle Text.
Ese módulo se especializa en el tratamiento de índices invertidos.

Son índices que se generan de una forma muy especial:
1. Tokenizar un texto: Dividir un texto en (tokens ~normalmente palabras)...
   A la hora de hacer esto se deben tener en cuenta: Espacios, guiones, puntos, comas, paréntesis, etc.
   
    Tortilla-de-patatas
    Tortilla-de-jamón
    Ensalada-de-pasta
    Espaguetis-a-la-carbonara
    Pizza-de-jamón-y-queso
    Escalivada-de-verduras
    Cordero-asado-con-patatitas
    Bacalao-a-la-vizcaína
    Ensalada-de-bacalao
    Tortilla-de-patatas
    Tortilla-de-patatas
    Tortilla-de-patatas
    Patatas-guisadas
2. Normalizar (mayúsculas, acentos) y eliminar Stop Words (palabras carentes de valor semántico en búsquedas)
    tortilla-*-patatas
    tortilla-*-jamon
    ensalada-*-pasta
    espaguetis-*-carbonara
    pizza-*-jamon-*-queso
    escalivada-*-verduras
    cordero-*-asado-*-patatitas
    bacalao-*-vizcaina
    ensalada-*-bacalao
    tortilla-*-patatas
    tortilla-*-patatas
    tortilla-*-patatas
    patatas-*-guisadas
3. Stemming: Reducir las palabras a su raíz (tortilla, tortilla, tortillas, tortillitas... todo es tortilla)
    tort-*-patat
    tort-*-jamon
    ensalad-*-past
    espagueti-*-carbonar
    pizz-*-jamon-*-ques
4. Una vez hecho eso, se genera el índice invertido:

| PALABRA         | Ubicación      |    
    tort            1(1), 2(1), 10(1), 11(1), 13(1)
    patat           1(3), 7(4), 10(3), 11(3), 12(3), 13(1)

Cuando hay que hacer una búsqueda, sobre el término de búsqueda se aplica exactamente el mismo proceso que hemos visto antes.
PATATA->
    patat

El resultado de ese procedimiento es lo que se usa como entrada de búsqueda en el índice invertido.

Los resultados son extraordinarios... y la velocidad de búsqueda es muy rápida.
La penalización en este caso la tenemos en:
- Almacenamiento: El índice ocupa más espacio que un índice normal.
- Velocidad de procesamiento al insertar datos. YA no es sólo guardar una entrada en un índice... es que hay que preprocesar los datos antes de guardarlos en el índice. Un registro dará lugar a montón de entradas en el índice.

Habitualmente este tipo de procesamientos y actualizaciones de índices se hacen de forma ASINCRONA.
Primero se da el COMMIT en cuanto tengo ewl dato en la tabla... y en algún momento se añadirán los datos al índice.


Muchas BBDD ofrecen MUY POCA o NINGUNA POTENCIA para manejar este tipo de índices.
En postgres tenemos algo parecido a lo que hace Oracle Text... pero no es tan potente.
En mariadb  tenemos algo parecido a lo que hace Oracle Text... pero no es tan potente.. ni siquiera como el de postgres.
En SQLServer tenemos algo parecido a lo que hace Oracle Text... y no está nada mal... cerca de lo que hace Oracle Text.

A veces ni siquiera Oracle TEXT es suficiente... y nos vamos a herramientas como ELASTICSEARCH (que son propiamente motores de indexación)... Quiero hacer búsquedas fonéticas... que suene más o menos así.


    ELASTICSEARCH
    ...
    ORACLE TEXT
    SQLSERVER FULLTEXT
    ...
    POSTGRES FULLTEXT
    ...
    MARIADB FULLTEXT
    MYSQL FULLTEXT

En oracle, y ya hablaremos de ello, tenemos muchos tipos de índices:
- Btree
- Bitmap
- Reverse key
- Function based
- Inverted
---

Algoritmos de HASH (HUELLA)
Letra del DNI

---


# Forma que tiene Oracle de almacenar información. Conceptos.

## TABLESPACE

Es una agrupación LOGICA de almacenamiento.En un tablespace guardo tablas... índices...
Pero dónde? Si un Tablespace es algo LÓGICO... yo lo que necesito es algo FISICO donde guardar los datos: DATAFILE

Un DATAFILE es un fichero físico que se guarda en el HDD. En ese fichero guardo los datos de un tablespace.
Un tablespace puede tener varios datafiles.

Dentro de un datafile (un fichero físico) guardamos datos...
Pero... el Oracle luego hay otro concepto diferente: SEGMENTO (SEGMENT)
Un SEGMENT es un almacenamiento LÓGICO para guardar los datos de un objeto (una tabla, un índice, etc). 
Un segmento lo puedo tener repartido en varios datafiles (físicos) y un datafile puede tener varios segmentos (lógicos).

A su vez, está el concepto de EXTENT: Un extent es un grupo de bloques de almacenamiento contiguos en un datafile.

BLOCK: Un bloque es la unidad de almacenamiento más pequeña que maneja Oracle.. en otras BBDD le llamamos PÁGINA.
los bloques tienen un tamaño FIJO, que se configura al crear la BBDD. Por defecto en Oracle es de 8Kb... pero puedo cambiarlo.
Es la cantidad mínima de datos que se lee o escribe de una al HDD.

Los bloques son los que se guardan en CACHE. A veces leo un bloque que tiene 100 registros... y de ese bloque sólo necesitaba un registro... Pero Oracle se trae el bloque entero... Le sale más barato. Del disco no leemos bytes sueltos... leemos bloques enteros.

              BBDD                                      TABLAS / INDICES
               |                                            |        
           TABLESPACE1                                  SEGMENT1
            |       |                                       | 
          DATAFILE1 DATAFILE2                               |
            |       |                                       |
          EXTENT1  EXTENT2<---------------------------------+
            |       |
          BLOCK1   BLOCK2  

Tengo mi BBDD. Dentro de ella creo una tabla: USUARIOS.
Asociada esa tabla, tengo un SEGMENTO (que es un espacio lógico) que se llama SEGMENTO_USUARIOS.
Queremos guardar datos en la tabla ahora... y para ello la BBDD (ORACLE) genera un primer EXTENT (un espacio físico) que se llama EXTENT_USUARIOS_1, compuesto de 8 bloques (8Kb cada bloque), dentro de un DATAFILE (físico) que se llama DATAFILE1, que tengo dentro de un TABLESPACE (lógico) que se llama TABLESPACE1.

La tabla, pido que se guarde en un tablespace (TABLESPACE1)... eso yo... que hablo sobre conceptos lógicos.


DATAFILE1
|extent1_segmento1                                                      | extent_segment2               | extend2_segmento1             |
| block1 | block2 | block3 | block4 | block5 | block6 | block7 | block8 | b1| b2| b3| b4| b5| b6| b7| b8| b1| b2| b3| b4| b5| b6| b7| b8|


# Al final, hemos dicho que la unidad mínima de almacenamiento es el bloque.

Qué hay en un bloque de datos?
- Lo primero: Block Header: Metadatos sobre el bloque: Cuántos datos tiene, ...
- Lo siguiente: Row Directory: Una lista de los registros que hay en el bloque. Con la posición dentro del bloque donde está cada registro.
- Y luego los datos: Los registros que hay en el bloque. 
  - Cada registro tiene su propio header (metadatos) que me dice qué tipo de dato es, cuántos bytes ocupa, etc.. si el registro está vivo o muerto, etc.
  - Y luego los datos en sí.

## Ejemplo de cómo se vería un bloque por dentro:


    TITULO: Soy un bloque de almacenamiento de la tabla USUARIOS         | HEADER

    DATOS QUE CONTENDO:    DONDE?
    - Felipe               linea 15 de esta página
    - Menchu               linea 16 de esta página
    - Pepe                 linea 18 de esta página
    - ROWID 117            Comienza en el byte 128

    DATOS:
    Bytes que ocupa | si está vivo |... |Datos
    24              |NO            |... |Felipe44Madrid
    Menchu56Barcelona
    Pepe99Valencia

Eso si... ese bloque de datos, se almacena en formato binario.

Pregunta... afecta el orden en el que guardo los datos dentro de un bloque al espacio que ocupan esos datos?
Hay escenarios donde si puede haber diferencias notables. 
Si tengo campos nulos  al final de un registro, no se guarda nada de información al respecto... pero si están entre medias... si que se guarda información al respecto.

CASO DE EJEMPLO: EDAD NULA.
EJEMPLO 1: La edad se guarda antes de la población.
    Felipe33Madrid
    Menchu-Barcelona
EJEMPLO 2: La edad se guarda después de la población.
    FelipeMadrid33
    MenchuBarcelona

Campos que habitualmente vayan a estar nulos... o que tengan más probabilidad de estar nulos... guardarlos al final de cada registro (en el orden de las columnas)
---

# Oracle

Es un motor de BBDD relacional.

## Terminología especial de Oracle

- INSTANCIA: Es una copia del programa de BBDD en memoria ejecutándose. La instancia no es la BBDD.
  De hecho puedo tener una instancia arrancada, sin tener BBDD Arrancada.
- BBDD: Es el conjunto de datos que tengo almacenados en disco. La BBDD no es la instancia.

    Una BBDD corre en una instancia. 
    Dependiendo la versión de Oracle, puedo o no tener más de una bbdd corriendo en una instancia.
    Pre Oracle 12c, sólo puedo tener una BBDD por instancia.
    A partir de Oracle 12c, Nos aparece el modelo multitenant, y los conceptos de contenedor de BBDD.
        CDB: Contenedor de BBDD. Es una instancia de BBDD que puede contener varias BBDD.
        PDB: Base de datos pluggable. Es una base de datos que se ejecuta dentro de un CDB.
         Podemos clonar una PDB, crear una nueva PDB, migrar una PDB, etc.


         INSTANCIA 1 de Oracle
            CDB
              PDB1
              PDB2

---

En nuestras BBDD vamos a guardar TEXTOs entre otras cosas. Esos textos los almacenaré en un determinado JUEGO DE CARACTERES.
Eso lo configuro cuando creo la BBDD (UTF-8).
Ahora bien... eso es cómo se guarda el dato.
Otra cosa es cómo se usa el dato!

Recetas:
NOMBRE:
tortilla de camarones
zanahorias con mayonesa
Tortilla de patatas
acelgas con tomate

SELECT * FROM RECETAS ORDER BY NOMBRE;
Tortilla de patatas
acelgas con tomate
tortilla de camarones
zanahorias con mayonesa

Esto se puede complicar más:

Usuarios:
Nombre:             Apellidos
 Iván               Osuna
 iván               Perez
 ivan               Gutierrez
 IVÁN               Sanchez
 IVAN               De Ruiz

Qué pasa con las oprdenaciones ahí?
Cómo se deberían de interpretar/usar esos datos desde el punto de vista de la ordenación?
- Todos esos valores deberían de considerarse IGUALES ENTRE SI, de cara al ordenar
CUIDADO QUE ESTO TIENE UNA SEGUNDA DERIVADA... Qué pasa si hago un group by nombre? Deberían de considerarse iguales?

Estas cosas son las que podemos gestionar con los collates.
En versiones más antiguas, los collates se definían a nivel de BBDD (como valor por defecto) y se podían modificar a nivel de SESION/CONEXION.

Desde Oracle 12c, los collates se pueden definir a nivel de columna, a nivel de tabla y a nivel de BBDD.... y además a nivel de cada QUERY.

Oracle no es la única base de datos que tiene implementado el concepto de collate. Aquñi por ejemplo, POSTGRESQL le pega 20 vueltas a oracle.

---

En las BBDD Relacionales, manejamos TABLAS / INDICES.
Los índices no los consulto directamente... yo trabajo con tablas. Los índices nos ayudan a mejorar el rendimiento de las consultas que hacemos sobre tablas.
Pero la verdad es que tampoco operamos SOLO SOBRE TABLAS! En la mayor parte de BBDD también tenemos el concepto de VISTA: VIEW.
Una gracia en este sentido que nos propone Oracle es el concepto de MATERIALIZED VIEW, que al igual que una tabla se guarda en disco... y que se pueden ir actualizando de forma automática. Nos ofrece una mejora en el rendimiento importante.


Igual que en muchas BBDD, otro concepto que tenemos aqui es el de particionamiento de tablas/índices.
Básicamente nos permite tener los datos de una tabla repartidos en varios ficheros (datafiles) y/o en varios HDDs.
Ofrece un mejor rendimiento cuando necesito traer datos de una tabla. que está repartida en varios HDDs.
O hacer una consulta sobre solo una parte de los datos de una tabla, que scnozco que están en una de las particiones.

---

# Nota 1: El almacenamiento es barato o caro hoy en día?

El almacenamiento es lo más CARO en un entorno de producción empresarial!

Estoy acostumbrado a ir al MediaMarkt y comprar un disco duro de 1TB por 50 euros (Western blue)
En una empresa necesito HDD de más calidad: Western Red PRO. Un disco de clase empresarial puede ser al menos un x3 en el precio.. llegando a ser un x10 en algunos casos.

Cuántas copias se hacen de un dato en un entorno de producción? El estándar en entornos de producción es hacer un x3. Esto no son backups... Los backups ofrecen protección ante desastres. El x3 es para tener Alta Disponibilidad... es decir, si un HDD se rompe, tengo 2 copias más de las que puedo tirar.

Si un usuario hacer un delete de un dato.. se hace en los 3HDD ya que están sincronizados. Aquí entran los backups... y de backups... lo que quiera. Hay empresas que tienen backups de las 2 semanas anteriores. Otras hasta de 1 año atrás. 

1 Tb en producción = 3 HDD de 1Tb x 2/3 backups (cada backup con su copia de seguridad / replicado) = 8 HDD de 1 Tb ... de los caros...

Es decir.. que ese Tb me puede salir por (no 50 € que me sale en casa) sino 2000-20000€

