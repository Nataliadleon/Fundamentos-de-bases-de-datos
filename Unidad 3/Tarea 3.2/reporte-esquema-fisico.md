# Generación del esquema físico en SQL Server y script LDD

> Tarea 3.2, Unidad 3. Implementación física del esquema relacional de la [Tarea 3.1](../Tarea3.1BDD/reporte-tecnico-relacional.md) (tienda de abarrotes de barrio).

## 1. Objetivo y alcance

Generar de forma manual el **esquema físico** del modelo relacional en **Microsoft SQL Server** y obtener un **script LDD** (`schema.sql`) con sentencias `CREATE TABLE`, restricciones `PRIMARY KEY`, `FOREIGN KEY` con cláusulas de eliminación y actualización, `CHECK` y `NOT NULL`, validado mediante consultas al catálogo del sistema.

## 2. Entorno utilizado

| Elemento | Detalle |
|---|---|
| Gestor de bases de datos | Microsoft SQL Server (2016 SP1 o superior) |
| Versión utilizada | **[COMPLETAR: por ejemplo, SQL Server 2022 Developer]** |
| Herramienta cliente | SQL Server Management Studio (SSMS) |
| Base de datos | `TiendaAbarrotes` |
| Esquema | `dbo` |
| Lenguaje | Transact-SQL (T-SQL) |

## 3. Del esquema lógico al físico: decisiones de implementación

| Aspecto | Esquema lógico (Tarea 3.1) | Esquema físico (SQL Server) | Justificación |
|---|---|---|---|
| Tipos de fecha y hora | `TIMESTAMP` | `DATETIME2(0)` | En SQL Server `TIMESTAMP` es un contador de versión de fila, no una fecha |
| Texto descriptivo | `VARCHAR(n)` | `NVARCHAR(n)` en nombres, apellidos, domicilio, producto y vehículo; `VARCHAR` en códigos | Conserva acentos y la ñ |
| Llaves sustitutas | Enteros | `INT IDENTITY(1,1)` en persona, categoría, proveedor, pedido y venta | Generación automática de la llave. Las llaves de los subtipos **no** son `IDENTITY` porque heredan el valor de `persona` |
| Eliminación referencial | `RESTRICT` / `CASCADE` | `NO ACTION` / `CASCADE` | SQL Server no tiene `RESTRICT`; `NO ACTION` rechaza la operación igualmente |
| Actualización referencial | `CASCADE` | `NO ACTION` | SQL Server rechaza crear llaves con actualización en cascada cuando existen varias rutas hacia una misma tabla (*multiple cascade paths*): `venta` depende de `cliente` y de `cajero`, y ambos descienden de `persona`. Además, las llaves `IDENTITY` no se modifican |
| Valores predeterminados | No definidos | 7 restricciones `DEFAULT` | Facilitan capturar datos (por ejemplo, `stock_actual = 0` o `metodo_pago = 'EFECTIVO'`) |
| Índices | No definidos | 10 índices no agrupados | SQL Server no indexa automáticamente las llaves foráneas; los índices aceleran uniones y filtros |
| Atributos derivados | Se calculan | 6 vistas | No se almacenan, para no duplicar información |
| Nombres de restricciones | — | `PK_`, `FK_`, `UQ_`, `CK_`, `DF_` | Mensajes de error legibles y mantenimiento sencillo |
| Documentación | — | Propiedades extendidas `MS_Description` | El diccionario de datos queda dentro de la propia base |

### Convenciones de nombres
- Tablas y columnas en minúsculas con guiones bajos (`detalle_venta`, `codigo_barras`).
- Restricciones: `PK_tabla`, `FK_hija_padre`, `UQ_tabla_columna`, `CK_tabla_n`, `DF_tabla_columna`.
- Índices: `IX_tabla_columna`. Vistas: `v_nombre`.

### Equivalencia de tipos de datos

| Dominio lógico | Tipo en SQL Server |
|---|---|
| D_ID | `INT` |
| D_CODIGO, D_TELEFONO, D_METODO, D_PUESTO, D_TURNO | `VARCHAR(n)` |
| D_NOMBRE y textos descriptivos | `NVARCHAR(n)` |
| D_CP | `CHAR(5)` |
| D_FECHA | `DATE` |
| D_FECHAHORA | `DATETIME2(0)` |
| D_MONEDA | `DECIMAL(10,2)` |
| D_CANTIDAD | `INT` |

## 4. Diccionario de datos

Resumen: **14 tablas**, 55 columnas. La misma información se puede consultar en la base con la consulta 3 de `validacion.sql`.

### persona

*Entidad PERSONA (superclase)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK | — | IDENTITY(1,1) | Identificador único de la persona (llave sustituta autoincremental) |
| 2 | nombre_pila | NVARCHAR(50) | NOT NULL | — | — | — | Nombre o nombres de pila |
| 3 | apellido_paterno | NVARCHAR(50) | NOT NULL | — | — | — | Apellido paterno |
| 4 | apellido_materno | NVARCHAR(50) | NULL | — | — | — | Apellido materno (opcional) |
| 5 | fecha_nacimiento | DATE | NOT NULL | — | — | — | Fecha de nacimiento; base para calcular la edad |

### telefono_persona

*Atributo multivalorado teléfono de PERSONA*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK, FK | — | — | Persona dueña del teléfono |
| 2 | telefono | VARCHAR(15) | NOT NULL | PK | — | — | Número telefónico de contacto |

### cliente

*Especialización CLIENTE*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK, FK | — | — | Persona que es cliente (PK y FK hacia PERSONA) |
| 2 | limite_credito | DECIMAL(10,2) | NOT NULL | — | 0 | CHECK (limite_credito >= 0) | Monto máximo que el cliente puede deber (fiado) |
| 3 | fecha_registro | DATE | NOT NULL | — | CAST(GETDATE() AS DATE) | — | Fecha de alta como cliente |

### empleado

*Especialización EMPLEADO*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK, FK | — | — | Persona que es empleado (PK y FK hacia PERSONA) |
| 2 | fecha_contratacion | DATE | NOT NULL | — | — | — | Fecha de contratación; base de la antigüedad |
| 3 | salario | DECIMAL(10,2) | NOT NULL | — | — | CHECK (salario > 0) | Salario mensual del empleado |
| 4 | puesto | VARCHAR(10) | NOT NULL | — | — | CHECK (puesto IN ('CAJERO','REPARTIDOR')) | Discriminante de la especialización: CAJERO o REPARTIDOR |

### cajero

*Especialización CAJERO*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK, FK | — | — | Empleado que es cajero (PK y FK hacia EMPLEADO) |
| 2 | turno | VARCHAR(10) | NOT NULL | — | — | CHECK (turno IN ('MATUTINO','VESPERTINO')) | Turno de trabajo: MATUTINO o VESPERTINO |

### repartidor

*Especialización REPARTIDOR*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_persona | INT | NOT NULL | PK, FK | — | — | Empleado que es repartidor (PK y FK hacia EMPLEADO) |
| 2 | licencia | VARCHAR(20) | NOT NULL | — | — | UNIQUE | Número de licencia de conducir (único) |
| 3 | vehiculo | NVARCHAR(30) | NULL | — | — | — | Vehículo usado para las entregas |

### categoria

*Entidad CATEGORIA*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_categoria | INT | NOT NULL | PK | — | IDENTITY(1,1) | Identificador único de la categoría |
| 2 | nombre_cat | NVARCHAR(50) | NOT NULL | — | — | UNIQUE | Nombre de la categoría (único) |

### producto

*Entidad PRODUCTO + relación pertenece a (N:1)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | codigo_barras | VARCHAR(20) | NOT NULL | PK | — | — | Código de barras que identifica al producto |
| 2 | nombre | NVARCHAR(80) | NOT NULL | — | — | — | Nombre o descripción del producto |
| 3 | costo_compra | DECIMAL(10,2) | NOT NULL | — | — | CHECK (costo_compra >= 0) | Costo de adquisición por unidad |
| 4 | precio_venta | DECIMAL(10,2) | NOT NULL | — | — | CHECK (precio_venta >= 0) | Precio de venta al público por unidad |
| 5 | stock_actual | INT | NOT NULL | — | 0 | CHECK (stock_actual >= 0) | Existencia actual en inventario |
| 6 | stock_minimo | INT | NOT NULL | — | 0 | CHECK (stock_minimo >= 0) | Existencia mínima antes de reabastecer |
| 7 | id_categoria | INT | NOT NULL | FK | — | — | Categoría a la que pertenece el producto |

### proveedor

*Entidad PROVEEDOR (dirección compuesta aplanada)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_proveedor | INT | NOT NULL | PK | — | IDENTITY(1,1) | Identificador único del proveedor |
| 2 | razon_social | NVARCHAR(100) | NOT NULL | — | — | — | Razón social o nombre comercial |
| 3 | calle | NVARCHAR(80) | NULL | — | — | — | Calle del domicilio |
| 4 | numero | NVARCHAR(10) | NULL | — | — | — | Número del domicilio |
| 5 | colonia | NVARCHAR(60) | NULL | — | — | — | Colonia del domicilio |
| 6 | codigo_postal | CHAR(5) | NULL | — | — | — | Código postal de 5 dígitos |

### telefono_proveedor

*Atributo multivalorado teléfono de PROVEEDOR*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_proveedor | INT | NOT NULL | PK, FK | — | — | Proveedor dueño del teléfono |
| 2 | telefono | VARCHAR(15) | NOT NULL | PK | — | — | Número telefónico de contacto |

### abastecimiento

*Relación suministra (N:M) = agregación ABASTECIMIENTO*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_proveedor | INT | NOT NULL | PK, FK | — | — | Proveedor que surte el producto |
| 2 | codigo_barras | VARCHAR(20) | NOT NULL | PK, FK | — | — | Producto que el proveedor surte |
| 3 | costo_unitario | DECIMAL(10,2) | NOT NULL | — | — | CHECK (costo_unitario >= 0) | Costo al que el proveedor surte el producto |

### pedido_reabastecimiento

*Relación autoriza (EMPLEADO – agregación ABASTECIMIENTO)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | id_pedido | INT | NOT NULL | PK | — | IDENTITY(1,1) | Identificador único del pedido |
| 2 | id_proveedor | INT | NOT NULL | FK | — | — | Proveedor al que se hace el pedido |
| 3 | codigo_barras | VARCHAR(20) | NOT NULL | FK | — | — | Producto pedido |
| 4 | id_empleado | INT | NOT NULL | FK | — | — | Empleado que autoriza el pedido |
| 5 | fecha_pedido | DATE | NOT NULL | — | CAST(GETDATE() AS DATE) | — | Fecha en que se autoriza el pedido |
| 6 | cantidad_pedida | INT | NOT NULL | — | — | CHECK (cantidad_pedida > 0) | Cantidad de unidades pedidas |

### venta

*Entidad VENTA + relaciones atiende, realiza y entrega (1:N)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | folio | INT | NOT NULL | PK | — | IDENTITY(1,1) | Folio único de la venta |
| 2 | fecha_hora | DATETIME2(0) | NOT NULL | — | SYSDATETIME() | — | Fecha y hora de la venta |
| 3 | metodo_pago | VARCHAR(13) | NOT NULL | — | 'EFECTIVO' | CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA','CREDITO')) | EFECTIVO, TARJETA, TRANSFERENCIA o CREDITO |
| 4 | id_cajero | INT | NOT NULL | FK | — | — | Cajero que atendió la venta |
| 5 | id_cliente | INT | NULL | FK | — | — | Cliente de la venta (NULL si es público general) |
| 6 | id_repartidor | INT | NULL | FK | — | — | Repartidor de la entrega a domicilio (NULL si no hay entrega) |

Restricción de tabla: `CHECK (metodo_pago <> 'CREDITO' OR id_cliente IS NOT NULL)`

### detalle_venta

*Relación incluye (N:M)*

| N.º | Columna | Tipo | Nulo | Llave | Predeterminado | Restricciones | Descripción |
|---|---|---|---|---|---|---|---|
| 1 | folio | INT | NOT NULL | PK, FK | — | — | Venta a la que pertenece el renglón |
| 2 | codigo_barras | VARCHAR(20) | NOT NULL | PK, FK | — | — | Producto vendido |
| 3 | cantidad | INT | NOT NULL | — | — | CHECK (cantidad > 0) | Unidades vendidas |
| 4 | precio_unitario | DECIMAL(10,2) | NOT NULL | — | — | CHECK (precio_unitario >= 0) | Precio de venta al momento de la compra |


## 5. Restricciones

### 5.1 Llaves primarias (14)

| Tabla | Nombre de la restricción | Columnas | Tipo |
|---|---|---|---|
| persona | PK_persona | id_persona | Simple |
| telefono_persona | PK_telefono_persona | id_persona, telefono | Compuesta |
| cliente | PK_cliente | id_persona | Simple |
| empleado | PK_empleado | id_persona | Simple |
| cajero | PK_cajero | id_persona | Simple |
| repartidor | PK_repartidor | id_persona | Simple |
| categoria | PK_categoria | id_categoria | Simple |
| producto | PK_producto | codigo_barras | Simple |
| proveedor | PK_proveedor | id_proveedor | Simple |
| telefono_proveedor | PK_telefono_proveedor | id_proveedor, telefono | Compuesta |
| abastecimiento | PK_abastecimiento | id_proveedor, codigo_barras | Compuesta |
| pedido_reabastecimiento | PK_pedido_reabastecimiento | id_pedido | Simple |
| venta | PK_venta | folio | Simple |
| detalle_venta | PK_detalle_venta | folio, codigo_barras | Compuesta |

### 5.2 Llaves foráneas y acciones referenciales (16)

| N.º | Restricción | Tabla hija (columnas) | Tabla padre (columnas) | ON DELETE | ON UPDATE |
|---|---|---|---|---|---|
| 1 | FK_telefono_persona_persona | telefono_persona (id_persona) | persona (id_persona) | CASCADE | NO ACTION |
| 2 | FK_cliente_persona | cliente (id_persona) | persona (id_persona) | CASCADE | NO ACTION |
| 3 | FK_empleado_persona | empleado (id_persona) | persona (id_persona) | CASCADE | NO ACTION |
| 4 | FK_cajero_empleado | cajero (id_persona) | empleado (id_persona) | CASCADE | NO ACTION |
| 5 | FK_repartidor_empleado | repartidor (id_persona) | empleado (id_persona) | CASCADE | NO ACTION |
| 6 | FK_producto_categoria | producto (id_categoria) | categoria (id_categoria) | NO ACTION | NO ACTION |
| 7 | FK_telefono_proveedor_proveedor | telefono_proveedor (id_proveedor) | proveedor (id_proveedor) | CASCADE | NO ACTION |
| 8 | FK_abastecimiento_proveedor | abastecimiento (id_proveedor) | proveedor (id_proveedor) | NO ACTION | NO ACTION |
| 9 | FK_abastecimiento_producto | abastecimiento (codigo_barras) | producto (codigo_barras) | NO ACTION | NO ACTION |
| 10 | FK_pedido_reabastecimiento_abastecimiento | pedido_reabastecimiento (id_proveedor, codigo_barras) | abastecimiento (id_proveedor, codigo_barras) | NO ACTION | NO ACTION |
| 11 | FK_pedido_reabastecimiento_empleado | pedido_reabastecimiento (id_empleado) | empleado (id_persona) | NO ACTION | NO ACTION |
| 12 | FK_venta_cajero | venta (id_cajero) | cajero (id_persona) | NO ACTION | NO ACTION |
| 13 | FK_venta_cliente | venta (id_cliente) | cliente (id_persona) | NO ACTION | NO ACTION |
| 14 | FK_venta_repartidor | venta (id_repartidor) | repartidor (id_persona) | NO ACTION | NO ACTION |
| 15 | FK_detalle_venta_venta | detalle_venta (folio) | venta (folio) | CASCADE | NO ACTION |
| 16 | FK_detalle_venta_producto | detalle_venta (codigo_barras) | producto (codigo_barras) | NO ACTION | NO ACTION |

Las subtablas (`cliente`, `empleado`, `cajero`, `repartidor`), los teléfonos y `detalle_venta.folio` usan `ON DELETE CASCADE`, porque dependen por completo de su tabla padre. El resto usa `NO ACTION` para impedir borrar datos con movimientos.

### 5.3 Restricciones UNIQUE (2)

- `UQ_repartidor_licencia`: columna `licencia` de `repartidor`
- `UQ_categoria_nombre_cat`: columna `nombre_cat` de `categoria`

### 5.4 Restricciones CHECK (14)

| Tabla | Restricción | Condición |
|---|---|---|
| cliente | CK_cliente_1 | `limite_credito >= 0` |
| empleado | CK_empleado_1 | `salario > 0` |
| empleado | CK_empleado_2 | `puesto IN ('CAJERO','REPARTIDOR')` |
| cajero | CK_cajero_1 | `turno IN ('MATUTINO','VESPERTINO')` |
| producto | CK_producto_1 | `costo_compra >= 0` |
| producto | CK_producto_2 | `precio_venta >= 0` |
| producto | CK_producto_3 | `stock_actual >= 0` |
| producto | CK_producto_4 | `stock_minimo >= 0` |
| abastecimiento | CK_abastecimiento_1 | `costo_unitario >= 0` |
| pedido_reabastecimiento | CK_pedido_reabastecimiento_1 | `cantidad_pedida > 0` |
| venta | CK_venta_1 | `metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA','CREDITO')` |
| venta | CK_venta_2 | `metodo_pago <> 'CREDITO' OR id_cliente IS NOT NULL` |
| detalle_venta | CK_detalle_venta_1 | `cantidad > 0` |
| detalle_venta | CK_detalle_venta_2 | `precio_unitario >= 0` |

### 5.5 Restricciones DEFAULT (7)

| Tabla | Columna | Restricción | Valor |
|---|---|---|---|
| cliente | limite_credito | DF_cliente_limite_credito | `0` |
| cliente | fecha_registro | DF_cliente_fecha_registro | `CAST(GETDATE() AS DATE)` |
| producto | stock_actual | DF_producto_stock_actual | `0` |
| producto | stock_minimo | DF_producto_stock_minimo | `0` |
| venta | fecha_hora | DF_venta_fecha_hora | `SYSDATETIME()` |
| venta | metodo_pago | DF_venta_metodo_pago | `'EFECTIVO'` |
| pedido_reabastecimiento | fecha_pedido | DF_pedido_reabastecimiento_fecha_pedido | `CAST(GETDATE() AS DATE)` |

### 5.6 NOT NULL e IDENTITY
Todas las columnas de llave primaria y las marcadas `NOT NULL` en el diccionario no admiten valores nulos. Las únicas columnas opcionales (`NULL`) son `apellido_materno`, `vehiculo`, `calle`, `numero`, `colonia`, `codigo_postal`, `id_cliente` e `id_repartidor`. Las columnas `IDENTITY` son 5.

## 6. Índices (10)

| Índice | Tabla | Columnas | Motivo |
|---|---|---|---|
| IX_persona_nombre | persona | apellido_paterno, nombre_pila | Búsqueda de personas por apellido y nombre |
| IX_producto_id_categoria | producto | id_categoria | FK hacia CATEGORIA |
| IX_abastecimiento_codigo_barras | abastecimiento | codigo_barras | FK hacia PRODUCTO |
| IX_pedido_abastecimiento | pedido_reabastecimiento | id_proveedor, codigo_barras | FK compuesta hacia ABASTECIMIENTO |
| IX_pedido_id_empleado | pedido_reabastecimiento | id_empleado | FK hacia EMPLEADO |
| IX_venta_id_cajero | venta | id_cajero | FK hacia CAJERO |
| IX_venta_id_cliente | venta | id_cliente | FK hacia CLIENTE |
| IX_venta_id_repartidor | venta | id_repartidor | FK hacia REPARTIDOR |
| IX_venta_fecha_hora | venta | fecha_hora | Consultas de ventas por fecha |
| IX_detalle_venta_codigo_barras | detalle_venta | codigo_barras | FK hacia PRODUCTO |

## 7. Vistas (6)

| Vista | Atributo derivado que implementa |
|---|---|
| v_detalle_subtotal | subtotal |
| v_venta_total | total |
| v_producto_margen | margen |
| v_cliente_saldo_pendiente | saldo_pendiente |
| v_persona_edad | edad |
| v_empleado_antiguedad | antigüedad |

## 8. Diagrama del esquema físico

### 8.1 Diagrama generado por el SGBD (entregable)
La tarea pide el diagrama **generado por el SGBD**. Para obtenerlo en SSMS:

1. En el Explorador de objetos, expande `Bases de datos` › `TiendaAbarrotes`.
2. Clic derecho en **Diagramas de base de datos** › **Nuevo diagrama de base de datos** (si SSMS pregunta por los objetos de soporte de diagramas, acepta **Sí**).
3. Selecciona todas las tablas (Ctrl + A) y pulsa **Agregar**, luego **Cerrar**.
4. Acomoda las tablas para que se vean las relaciones y toma una captura de pantalla.
5. Guarda la captura como `evidencias/diagrama-ssms.png`.

### 8.2 Diagrama de referencia
Este diagrama muestra los mismos objetos con los tipos de SQL Server. Sirve como apoyo y no sustituye al diagrama de SSMS.

![Esquema físico de la tienda de abarrotes](diagramas/esquema-fisico.png)

Archivos: [`esquema-fisico.drawio`](diagramas/esquema-fisico.drawio), [`esquema-fisico.svg`](diagramas/esquema-fisico.svg) y [`esquema-fisico.mmd`](diagramas/esquema-fisico.mmd).

## 9. Estructura del script `schema.sql`

| Sección | Contenido |
|---|---|
| Encabezado | Descripción, motor, instrucciones de uso |
| Base de datos | Crea `TiendaAbarrotes` si no existe y la selecciona |
| 1. Limpieza | `DROP VIEW/TABLE IF EXISTS` en orden inverso a las dependencias, para poder ejecutar el script varias veces |
| 2. Tablas | `CREATE TABLE` de las 14 tablas, con `PRIMARY KEY`, `UNIQUE`, `FOREIGN KEY` (con `ON DELETE`/`ON UPDATE`), `CHECK`, `DEFAULT`, `NOT NULL` e `IDENTITY` |
| 3. Índices | `CREATE NONCLUSTERED INDEX` |
| 4. Vistas | `CREATE OR ALTER VIEW` para los atributos derivados |
| 5. Descripciones | `sp_addextendedproperty` para el diccionario de datos |

Los bloques se separan con `GO`. Las tablas se crean en orden: primero las tablas padre y después las hijas.

## 10. Ejecución y evidencias

### 10.1 Procedimiento
1. Abrir SSMS y conectarse a la instancia de SQL Server.
2. Abrir `schema.sql` y ejecutarlo completo (F5). Debe terminar con el mensaje *Esquema TiendaAbarrotes creado correctamente.*
3. Ejecutarlo una segunda vez para comprobar que se crea de forma limpia (no marca errores).
4. Ejecutar `validacion.sql` y revisar cada resultado.
5. Ejecutar `datos-prueba.sql` para cargar datos y probar las restricciones.

### 10.2 Evidencias que se deben capturar

| N.º | Evidencia | Cómo obtenerla | Resultado esperado |
|---|---|---|---|
| 1 | Creación limpia | Ejecutar `schema.sql` | Mensaje de éxito y sin errores en la pestaña *Mensajes* |
| 2 | Re-ejecución | Ejecutar `schema.sql` de nuevo | Termina sin errores |
| 3 | Tablas creadas | Explorador de objetos › `Tablas` (F5) | 14 tablas |
| 4 | Resumen de objetos | Consulta 1 de `validacion.sql` | tablas = 14, llaves primarias = 14, llaves foráneas = 16, UNIQUE = 2, CHECK = 14, DEFAULT = 7, IDENTITY = 5, vistas = 6, índices = 10 |
| 5 | Diccionario de datos | Consulta 3 | Todas las columnas con tipo, nulabilidad y descripción |
| 6 | Llaves foráneas | Consulta 5 | 16 llaves con su acción al eliminar y al actualizar |
| 7 | Restricciones CHECK | Consulta 7 | 14 restricciones |
| 8 | Diagrama de SSMS | Procedimiento de la sección 8.1 | Tablas con sus relaciones |
| 9 | Carga de datos | `datos-prueba.sql` | Filas insertadas sin error |
| 10 | Pruebas de integridad | Final de `datos-prueba.sql` | Cinco mensajes «Rechazado» |

Las capturas se guardan en la carpeta `evidencias/`.

### 10.3 Pruebas de las restricciones de integridad

`datos-prueba.sql` intenta violar cada tipo de restricción con `TRY…CATCH` y muestra el mensaje de error de SQL Server:

| N.º | Intento | Restricción que debe rechazarlo |
|---|---|---|
| 1 | Insertar una categoría con una llave primaria que ya existe | Integridad de entidad (`PK_categoria`) |
| 2 | Insertar una venta con `id_cajero = 99` inexistente | Integridad referencial (`FK_venta_cajero`) |
| 3 | Insertar un cajero que no es empleado | Integridad referencial en la jerarquía (`FK_cajero_empleado`) |
| 4 | Insertar un detalle de venta con `cantidad = 0` | Integridad de dominio (`CK_detalle_venta_1`) |
| 5 | Insertar una venta a crédito sin cliente | Regla de negocio RN7 (`CK_venta_2`) |

## 11. Limitaciones

- Reglas del tipo «todo producto tiene al menos un proveedor» o «todo abastecimiento tiene al menos un pedido» no se pueden expresar solo con llaves foráneas; requerirían disparadores o validación en la aplicación.
- Que el valor de `empleado.puesto` coincida con la subtabla en la que aparece el empleado (`cajero` o `repartidor`) tampoco lo verifica un `CHECK`.
- El saldo del cliente se calcula con todas sus ventas a crédito porque el modelo no incluye abonos.

## Referencias

Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson/Addison-Wesley.

Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.

Microsoft. (s. f.). *CREATE TABLE (Transact-SQL)*. Microsoft Learn. Recuperado el 30 de octubre de 2026, de https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql

Microsoft. (s. f.). *Primary and foreign key constraints*. Microsoft Learn. Recuperado el 30 de octubre de 2026, de https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints

Silberschatz, A., Korth, H. F., & Sudarshan, S. (2010). *Database system concepts* (6.ª ed.). McGraw-Hill.
