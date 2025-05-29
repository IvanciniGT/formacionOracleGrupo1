##  Operaciones de mantenimiento típicas en Oracle

| Categoría       | Operación              | Ejemplo real de query SQL                                                                                              |
| --------------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 📊 Estadísticas | Recolectar de tabla    | `EXEC DBMS_STATS.GATHER_TABLE_STATS('CURSO', 'USUARIOS');`                                                             |
|                 | Recolectar de esquema  | `EXEC DBMS_STATS.GATHER_SCHEMA_STATS('CURSO');`                                                                        |
| 🧱 Índices      | Rebuild índice         | `ALTER INDEX IDX_USUARIOS_NOMBRE REBUILD;`                                                                             |
|                 | Validar estructura     | `ANALYZE INDEX IDX_USUARIOS_NOMBRE VALIDATE STRUCTURE;`                                                                |
| 📦 Espacio      | Ver uso de bloques     | `SELECT blocks, num_rows FROM dba_tables WHERE table_name = 'USUARIOS';`                                               |
|                 | Liberar espacio        | `ALTER TABLE CURSO.USUARIOS SHRINK SPACE;`                                                                             |
| 🧹 Limpieza     | Vaciar papelera        | `PURGE DBA_RECYCLEBIN;`                                                                                                |
|                 | Limpiar auditoría      | `EXEC DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, DBMS_AUDIT_MGMT.LAST_ARCHIVE_TIMESTAMP);` |
| 🔒 Seguridad    | Ver usuarios y bloqueo | `SELECT username, account_status FROM dba_users;`                                                                      |
| 🚀 Rendimiento  | Consultar SQL lentas   | `SELECT sql_id, elapsed_time, sql_text FROM v$sql WHERE elapsed_time > 1000000;`                                       |
| 🔁 Jobs         | Ver jobs activos       | `SELECT job_name, state FROM dba_scheduler_jobs WHERE enabled = 'TRUE';`                                               |

---

## Auditoría moderna (`Unified Auditing`) 

| Acción                | Ejemplo SQL completo                                                                                                               |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Crear política        | `CREATE AUDIT POLICY aud_usuarios_mods ACTIONS UPDATE, DELETE ON curso.usuarios;`                                                  |
| Activar política      | `AUDIT POLICY aud_usuarios_mods;`                                                                                                  |
| Activar para usuario  | `AUDIT POLICY aud_usuarios_mods WHEN 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''CURSO''' EVALUATE PER SESSION;`               |
| Consultar políticas   | `SELECT * FROM audit_unified_enabled_policies;`                                                                                    |
| Ver eventos auditados | `SELECT dbusername, object_name, action_name, event_timestamp FROM unified_audit_trail WHERE object_name = 'USUARIOS';`            |
| Limpiar logs antiguos | `sql BEGIN DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, DBMS_AUDIT_MGMT.LAST_ARCHIVE_TIMESTAMP); END; /` |

---

## Funciones de fecha en Oracle

| Función                      | Qué hace                           | Ejemplo SQL completo                                                             |
| ---------------------------- | ---------------------------------- | -------------------------------------------------------------------------------- |
| `SYSDATE`                    | Fecha/hora actual (servidor)       | `SELECT SYSDATE FROM DUAL;`                                                      |
| `CURRENT_DATE`               | Fecha/hora con zona de sesión      | `SELECT CURRENT_DATE FROM DUAL;`                                                 |
| `SYSTIMESTAMP`               | Fecha con fracción y TZ (servidor) | `SELECT SYSTIMESTAMP FROM DUAL;`                                                 |
| `TRUNC(fecha)`               | Quita hora                         | `SELECT TRUNC(SYSDATE) FROM DUAL;`                                               |
| `ADD_MONTHS(fecha, n)`       | Suma o resta meses                 | `SELECT ADD_MONTHS(SYSDATE, -1) FROM DUAL;`                                      |
| `LAST_DAY(fecha)`            | Último día del mes                 | `SELECT LAST_DAY(SYSDATE) FROM DUAL;`                                            |
| `NEXT_DAY(fecha, 'VIERNES')` | Próximo viernes                    | `SELECT NEXT_DAY(SYSDATE, 'VIERNES') FROM DUAL;`                                 |
| `MONTHS_BETWEEN(f1, f2)`     | Diferencia en meses                | `SELECT MONTHS_BETWEEN(SYSDATE, TO_DATE('2024-01-01', 'YYYY-MM-DD')) FROM DUAL;` |
| `EXTRACT(YEAR FROM fecha)`   | Extraer año                        | `SELECT EXTRACT(YEAR FROM SYSDATE) FROM DUAL;`                                   |
| `TO_CHAR(fecha, 'YYYY-MM')`  | Convertir a texto                  | `SELECT TO_CHAR(SYSDATE, 'YYYY-MM') FROM DUAL;`                                  |


---

## Consultas de mantenimiento y diagnóstico en Oracle

| Categoría         | Qué quieres ver                         | Consulta SQL / ejemplo completo                                                                                                                                              |
| ----------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🧱 Segmentos      | Tamaño, tipo y ubicación de un objeto   | `SELECT segment_name, segment_type, tablespace_name, bytes/1024/1024 AS size_mb, blocks, extents FROM dba_segments WHERE segment_name = 'USUARIOS' AND owner = 'CURSO';` |
| 🔍 Extents        | Lista de extents usados por un objeto   | `SELECT segment_name, extent_id, file_id, block_id, blocks FROM dba_extents WHERE segment_name = 'USUARIOS' AND owner = 'CURSO' ORDER BY extent_id;`                     |
| 📊 Tamaño lógico  | Filas, bloques, promedio por fila       | `SELECT table_name, num_rows, blocks, empty_blocks, avg_row_len FROM dba_tables WHERE table_name = 'USUARIOS' AND owner = 'CURSO';`                                      |
| 🧩 Índices        | Estadísticas similares para un índice   | `SELECT index_name, num_rows, leaf_blocks, blevel FROM dba_indexes WHERE table_name = 'USUARIOS' AND owner = 'CURSO';`                                                   |
| 🧠 Cabecera       | Bloque y archivo de cabecera del objeto | `SELECT segment_name, header_file, header_block FROM dba_segments WHERE segment_name = 'USUARIOS' AND owner = 'CURSO';`                                                  |
| 🧨 Dump de bloque | Ver contenido bajo nivel de un bloque   | `ALTER SYSTEM DUMP DATAFILE <file_id> BLOCK <block_id>;`<br>🔒 Requiere privilegios y acceso al `alert.log` o trace                                                      |

---

## Gestión de **usuarios, roles y permisos** 

| Acción                        | Qué hace / para qué sirve                 | Comando SQL / Ejemplo real                                                   |
| ----------------------------- | ----------------------------------------- | ---------------------------------------------------------------------------- |
| 👤 Crear usuario              | Crear un nuevo usuario                    | `CREATE USER curso IDENTIFIED BY password DEFAULT TABLESPACE users;`         |
| 👮 Dar permisos mínimos       | Permitir login y crear objetos            | `GRANT CREATE SESSION, CREATE TABLE TO curso;`                               |
| 🧑‍🤝‍🧑 Asignar roles        | Aplicar permisos agrupados                | `GRANT CONNECT, RESOURCE TO curso;`                                          |
| 🔑 Dar permiso sobre objeto   | Permitir usar tabla/objeto específico     | `GRANT SELECT, INSERT ON empleados TO curso;`                                |
| 🔍 Ver permisos por usuario   | Consultar privilegios explícitos          | `SELECT * FROM dba_sys_privs WHERE grantee = 'CURSO';`                       |
| 🎯 Ver permisos sobre objetos | Ver privilegios de objetos otorgados      | `SELECT * FROM dba_tab_privs WHERE grantee = 'CURSO';`                       |
| 🛡️ Ver roles de usuario      | Qué roles tiene cada usuario              | `SELECT * FROM dba_role_privs WHERE grantee = 'CURSO';`                      |
| 🧾 Crear rol personalizado    | Definir conjunto de permisos reutilizable | `CREATE ROLE gestor_rrhh; GRANT SELECT, UPDATE ON empleados TO gestor_rrhh;` |
| 🔒 Revocar permisos           | Quitar permisos o roles                   | `REVOKE CREATE TABLE FROM curso;` <br>`REVOKE gestor_rrhh FROM curso;`       |
| 🧹 Borrar usuario             | Eliminar usuario y sus objetos            | `DROP USER curso CASCADE;`                                                   |

---

##  gestión de **PDBs (Pluggable Databases)** 


| Acción                    | Qué hace / para qué sirve                   | Comando SQL / Ejemplo real                                                                         |
| ------------------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 🔍 Ver PDBs existentes    | Lista de pluggable databases                | `SELECT pdb_name, status FROM dba_pdbs;`                                                           |
| 🚪 Conectarse a una PDB   | Cambia de contenedor (CDB → PDB)            | `ALTER SESSION SET CONTAINER = mi_pdb;`                                                            |
| 🆕 Crear nueva PDB        | Clonar desde plantilla                      | `CREATE PLUGGABLE DATABASE nueva_pdb ADMIN USER admin IDENTIFIED BY pass FILE_NAME_CONVERT = ...;` |
| ▶️ Abrir PDB              | Habilita el acceso                          | `ALTER PLUGGABLE DATABASE nueva_pdb OPEN;`                                                         |
| ⛔ Cerrar PDB              | Cierra la base                              | `ALTER PLUGGABLE DATABASE nueva_pdb CLOSE;`                                                        |
| 🛡️ Ver usuarios en PDB   | Lista usuarios desde dentro de una PDB      | `SELECT username FROM dba_users;`  *(una vez conectado a la PDB)*                                  |
| 🚦 Ver estado de cada PDB | Ver cuáles están abiertas/cerradas          | `SELECT name, open_mode FROM v$pdbs;`                                                              |
| Volver a CDB           | Cambia de vuelta a la raíz                  | `ALTER SESSION SET CONTAINER = CDB$ROOT;`                                                          |
| Eliminar una PDB       | Borrar una PDB (opcionalmente, y sus datos) | `DROP PLUGGABLE DATABASE nueva_pdb INCLUDING DATAFILES;`                                           |

# Gestión de TABLESPACES en Oracle

| Acción                             | Qué hace / para qué sirve                       | Comando SQL / Ejemplo completo                                                                                     |
| ---------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Ver tablespaces existentes         | Lista todos los tablespaces                     | `SELECT tablespace_name, contents, status FROM dba_tablespaces;`                                                   |
| Ver espacio usado/libre            | Tamaño y uso por tablespace                     | `sql SELECT tablespace_name, ROUND(SUM(bytes)/1024/1024) AS size_mb FROM dba_data_files GROUP BY tablespace_name;` |
| Ver espacio libre                  | Espacio disponible dentro del tablespace        | `sql SELECT tablespace_name, ROUND(SUM(bytes)/1024/1024) AS free_mb FROM dba_free_space GROUP BY tablespace_name;` |
| Crear nuevo tablespace             | Crear uno para datos normales                   | `sql CREATE TABLESPACE datos_user DATAFILE '/u01/app/oracle/oradata/datos01.dbf' SIZE 100M AUTOEXTEND ON;`         |
| Crear tablespace para UNDO         | Tablespace especial para UNDO                   | `sql CREATE UNDO TABLESPACE undotbs1 DATAFILE '/u01/undo01.dbf' SIZE 200M AUTOEXTEND ON;`                          |
| Crear tablespace temporal          | Usado para ordenaciones, joins, etc.            | `sql CREATE TEMPORARY TABLESPACE temp_user TEMPFILE '/u01/temp01.dbf' SIZE 200M AUTOEXTEND ON;`                    |
| Mover objetos entre tablespaces    | Mover una tabla o índice                        | `ALTER TABLE empleados MOVE TABLESPACE datos_user;`                                                                |
| Ver objetos por tablespace         | Ver qué objetos están en cuál                   | `sql SELECT segment_name, segment_type FROM dba_segments WHERE tablespace_name = 'DATOS_USER';`                    |
| Cambiar tamaño de datafile         | Aumentar espacio de un archivo                  | `ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/datos01.dbf' RESIZE 500M;`                                       |
| Autoextend de datafiles            | Habilitar crecimiento automático                | `ALTER DATABASE DATAFILE '/u01/undo01.dbf' AUTOEXTEND ON NEXT 50M MAXSIZE 1G;`                                     |
| Eliminar tablespace                | Borrar tablespace (opcionalmente datos físicos) | `DROP TABLESPACE datos_user INCLUDING CONTENTS AND DATAFILES;`                                                     |
