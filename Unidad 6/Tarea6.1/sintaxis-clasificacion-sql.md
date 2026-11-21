# SINTAXIS Y CLASIFICACIÓN DE SENTENCIAS SQL (LDD Y LMD)
## Documentación Técnica y Marco Taxonómico Formal

- **Institución:** Tecnológico Nacional de México
- **Carrera:** Ingeniería Informática
- **Materia:** Fundamentos de Base de Datos
- **Unidad:** 6 — Introducción al Lenguaje SQL
- **Alumna:** Gabriela Natalia De León Alvarez
- **Matrícula:** I24050006
- **Motor SGBD de Referencia:** Microsoft SQL Server (T-SQL)

---

## 1. INTRODUCCIÓN Y CARACTERÍSTICAS GENERALES DEL LENGUAJE SQL

El lenguaje SQL (*Structured Query Language*) es el estándar universal por excelencia para la definición, control, administración y consulta de bases de datos sustentadas en el Modelo Relacional formulado por Edgar F. Codd en 1970. Diseñado inicialmente por IBM bajo el nombre *SEQUEL* (*Structured English Query Language*) a mediados de la década de 1970, fue estandarizado en 1986 por el *American National Standards Institute* (ANSI) y en 1987 por la *International Organization for Standardization* (ISO), evolucionando a través de versiones normativas clave como SQL-92, SQL:1999, SQL:2003, SQL:2008, SQL:2016 y SQL:2023.

### 1.1 Características Fundamentales de SQL
1. **Naturaleza Declarativa vs. Procedimental:**
   A diferencia de los lenguajes de programación imperativos y del álgebra relacional pura (que especifica una secuencia procedimental de operadores de extracción), SQL es primordialmente declarativo. El desarrollador o analista especifica en la sentencia el conjunto resultado deseado (*qué datos recuperar o modificar*), delegando al optimizador de consultas del SGBD (*Query Optimizer*) la responsabilidad de compilar un árbol sintáctico, evaluar planes de ejecución físicos mediante estimación de costos y acceder a las páginas de datos en almacenamiento secundario.
2. **Independencia de Datos (Niveles Lógico y Físico):**
   SQL materializa la arquitectura de tres niveles ANSI/SPARC. Las aplicaciones y usuarios interactúan con esquemas lógicos y vistas sin requerir conocimiento sobre las estructuras internas de almacenamiento (árboles B+, fragmentación de páginas, extensiones de disco o particionamiento físico).
3. **Integridad de Datos Incorporada:**
   SQL provee mecanismos semánticos nativos para definir e imponer de forma obligatoria las reglas de integridad del modelo relacional: integridad de entidad (claves primarias no nulas y únicas), integridad referencial (claves foráneas con acciones cascada o restrictivas) e integridad de dominio (tipos de datos estrictos, restricciones `CHECK` y valores predeterminados `DEFAULT`).
4. **Completitud y Flexibilidad Transaccional:**
   A través de las propiedades ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad), SQL garantiza que secuencias de modificaciones complejas se ejecuten como unidades atómicas indivisibles mediante primitivas de control transaccional (`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`).
5. **Taxonomía de Sublenguajes:**
   El estándar SQL divide funcionalmente sus comandos en cuatro grandes categorías:
   - **LDD / DDL (*Data Definition Language*):** Gobierna el diccionario de datos, creando, modificando o eliminando esquemas, tablas, vistas, índices y restricciones.
   - **LMD / DML (*Data Manipulation Language*):** Permite la inserción, consulta, actualización y eliminación de tuplas almacenadas dentro de las estructuras existentes.
   - **DCL (*Data Control Language*):** Administra permisos, roles y privilegios de seguridad (`GRANT`, `REVOKE`, `DENY`).
   - **TCL (*Transaction Control Language*):** Controla los límites y la persistencia de las transacciones atómicas (`COMMIT`, `ROLLBACK`, `SAVEPOINT`).

---

## 2. TABLA COMPARATIVA Y TAXONÓMICA: LDD vs. LMD

| Criterio Técnico | Lenguaje de Definición de Datos (LDD / DDL) | Lenguaje de Manipulación de Datos (LMD / DML) |
| :--- | :--- | :--- |
| **Objetivo Principal** | Definir, alterar y suprimir la estructura física y lógica de los objetos de la base de datos (metadatos). | Consultar, ingresar, modificar y purgar datos (tuplas) dentro de las tablas existentes. |
| **Comandos Nucleares** | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` | `INSERT`, `UPDATE`, `DELETE`, `SELECT` |
| **Nivel de Acción** | Catálogo del sistema, diccionario de datos y metadatos del SGBD. | Conjunto de tuplas y páginas de datos asignadas a las tablas. |
| **Comportamiento Transaccional** | En muchos motores es implícitamente autocomprometido (*auto-commit*). En SQL Server (T-SQL) admite transaccionalidad dentro de bloques `BEGIN TRAN`. | Plenamente transaccional bajo soporte formal de sentencias `COMMIT` y `ROLLBACK`. |
| **Impacto en Concurrencia y Bloqueos** | Adquiere bloqueos de estabilidad y modificación de esquema exclusivos (`Sch-M`), bloqueando el acceso concurrente a la tabla. | Adquiere bloqueos de lectura compartidos (`S`), exclusivos de fila/página (`X`) y bloqueos de intención (`IS`, `IX`). |
| **Mecanismo de Registro (Log de Transacciones)** | Operaciones registradas a nivel de asignación de extensiones y metadatos. Operaciones como `TRUNCATE` son mínimamente registradas (*minimally logged*). | `INSERT`, `UPDATE` y `DELETE` registran fila por fila en el archivo `.ldf` (*write-ahead logging*). `SELECT` no genera registros de modificación. |
| **Efecto sobre Índices** | Reconstruye, reorganiza, crea o elimina árboles B+ completos en disco. | Mantiene y actualiza automáticamente los nodos de los árboles B+ ante cambios de claves o inserciones. |
| **Disparadores (Triggers)** | Activa *DDL Triggers* a nivel de Base de Datos o Servidor (usados en auditorías de cambios estructurales). | Activa *DML Triggers* a nivel de tabla (`AFTER INSERT`, `INSTEAD OF UPDATE`, etc.). |
| **Permisos Requeridos** | Privilegios administrativos de alto nivel: `CREATE TABLE`, `ALTER`, `CONTROL DATABASE`, o rol `db_ddladmin`. | Privilegios de acceso sobre datos: `SELECT`, `INSERT`, `UPDATE`, `DELETE` sobre esquemas o tablas específicas. |

---

## 3. LENGUAJE DE DEFINICIÓN DE DATOS (LDD / DDL)

### 3.1 Sentencia `CREATE`
- **Definición Técnica:** Asigna y materializa un nuevo objeto relacional en el catálogo del sistema del SGBD, definiendo su tipología de datos, restricciones de integridad física y reglas de almacenamiento.
- **Sintaxis Formal Estándar (BNF Simplificada):**
```sql
CREATE TABLE [esquema.]nombre_tabla (
    nombre_columna tipo_dato [COLLATE collation]
        [CONSTRAINT nombre_restriccion {NOT NULL | NULL}]
        [CONSTRAINT nombre_restriccion DEFAULT expresion_constante]
        [CONSTRAINT nombre_restriccion {PRIMARY KEY | UNIQUE} [CLUSTERED | NONCLUSTERED]]
        [CONSTRAINT nombre_restriccion REFERENCES tabla_padre (columna_padre)
            [ON DELETE {NO ACTION | CASCADE | SET NULL | SET DEFAULT}]
            [ON UPDATE {NO ACTION | CASCADE | SET NULL | SET DEFAULT}]]
        [CONSTRAINT nombre_restriccion CHECK (expresion_logica)],
    ...
    [CONSTRAINT nombre_restriccion PRIMARY KEY (columna_1, ...)],
    [CONSTRAINT nombre_restriccion FOREIGN KEY (columna_fk) REFERENCES tabla_padre (columna_pk)]
) [ON {filegroup | "default"}];
```
- **Parámetros y Cláusulas:**
  - `nombre_columna`: Identificador unívoco del atributo en la tabla.
  - `tipo_dato`: Dominio formal de la columna (`INT`, `VARCHAR(n)`, `DECIMAL(p,s)`, `DATETIME2`, etc.).
  - `PRIMARY KEY`: Establece la clave candidata principal, forzando unicidad y no nulidad (`NOT NULL`). En SQL Server, genera de manera predeterminada un índice clúster (*Clustered Index*).
  - `FOREIGN KEY ... REFERENCES`: Define la relación de dependencia referencial con otra tabla base.
  - `CHECK`: Evalúa una expresión booleana estricta que cada tupla debe satisfacer antes de ser persistida.
- **Opciones Avanzadas en T-SQL:**
  - `IDENTITY(inicio, incremento)`: Generador numérico automático subyacente.
  - `ON filegroup`: Segmentación de tablas en grupos de archivos físicos para optimización de I/O en discos separados.
- **Ejemplo en el Esquema de la Tienda de Abarrotes:**
```sql
CREATE TABLE dbo.producto (
    codigo_barras VARCHAR(20) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    costo_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL CONSTRAINT DF_producto_stock DEFAULT 0,
    stock_minimo INT NOT NULL CONSTRAINT DF_producto_min DEFAULT 0,
    id_categoria INT NOT NULL,
    CONSTRAINT PK_producto PRIMARY KEY CLUSTERED (codigo_barras),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria) 
        REFERENCES dbo.categoria (id_categoria)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_producto_precio CHECK (precio_venta >= costo_compra),
    CONSTRAINT CK_producto_stock CHECK (stock_actual >= 0 AND stock_minimo >= 0)
);
```

---

### 3.2 Sentencia `ALTER`
- **Definición Técnica:** Modifica dinámicamente la definición estructural, atributos o restricciones de un objeto previamente creado en la base de datos sin requerir su destrucción física.
- **Sintaxis Formal Estándar (BNF):**
```sql
ALTER TABLE [esquema.]nombre_tabla
    { 
        ADD nombre_columna tipo_dato [restricciones]
      | DROP COLUMN nombre_columna
      | ALTER COLUMN nombre_columna nuevo_tipo_dato [NULL | NOT NULL]
      | ADD CONSTRAINT nombre_restriccion {PRIMARY KEY | FOREIGN KEY | CHECK | UNIQUE | DEFAULT}
      | DROP CONSTRAINT nombre_restriccion
      | {CHECK | NOCHECK} CONSTRAINT {ALL | nombre_restriccion}
    };
```
- **Parámetros y Restricciones:**
  - `ADD`: Agrega una nueva columna física o regla de restricción al esquema.
  - `DROP COLUMN`: Elimina una columna; falla si la columna participa en índices clúster, claves foráneas o restricciones no eliminadas previamente.
  - `ALTER COLUMN`: Modifica la longitud, precisión o anulabilidad del tipo de dato, condicionado a que los datos existentes sean compatibles con la conversión.
  - `NOCHECK CONSTRAINT`: Deshabilita temporalmente la comprobación de restricciones de integridad (útil en procesos de migración masiva de datos).
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Agregar columna de control fiscal
ALTER TABLE dbo.proveedor ADD rfc VARCHAR(13) NULL;

-- Agregar restricción de validación de formato mediante ALTER TABLE
ALTER TABLE dbo.proveedor 
    ADD CONSTRAINT CK_proveedor_rfc CHECK (LEN(rfc) IN (12, 13));
```

---

### 3.3 Sentencia `DROP`
- **Definición Técnica:** Elimina irreversiblemente la definición estructural de un objeto relacional del catálogo del sistema, liberando de forma permanente las páginas de datos en disco y suprimiendo sus índices asociados, permisos y disparadores.
- **Sintaxis Formal Estándar (BNF):**
```sql
DROP TABLE [IF EXISTS] [esquema.]nombre_tabla [, ...n];
```
- **Parámetros y Restricciones:**
  - `IF EXISTS`: Cláusula condicional disponible a partir de SQL Server 2016 que evita el lanzamiento de excepciones si el objeto no reside en el diccionario de datos.
  - **Restricción de Integridad Referencial:** Un comando `DROP TABLE` fallará catastróficamente si la tabla referenciada es el extremo padre de una restricción `FOREIGN KEY` activa de otra tabla, requiriendo eliminar previamente las restricciones foráneas o las tablas hijas.
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Eliminación segura de tabla dependiente
DROP TABLE IF EXISTS dbo.telefono_persona;
```

---

### 3.4 Sentencia `TRUNCATE`
- **Definición Técnica:** Remueve la totalidad de las tuplas almacenadas en una tabla relacional mediante desasignación directa de extensiones de páginas en disco, manteniendo intacta la estructura y el esquema en el catálogo.
- **Sintaxis Formal Estándar (BNF):**
```sql
TRUNCATE TABLE [esquema.]nombre_tabla;
```
- **Comparativa Crítica `TRUNCATE` vs. `DELETE`:**
  1. **Velocidad y Recursos:** `TRUNCATE` es sustancialmente más rápido porque no recorre ni lee tupla por tupla; únicamente modifica los mapas de asignación global (`GAM`, `SGAM`) del archivo de datos.
  2. **Uso de Registro de Transacciones:** `TRUNCATE` realiza un registro mínimo (*minimally logged*), registrando solo la desasignación de páginas, mientras que `DELETE` escribe cada tupla eliminada en el archivo `.ldf`.
  3. **Reinicio de Contadores `IDENTITY`:** `TRUNCATE` reinicia automáticamente cualquier secuencia o columna autoincrementable al valor de semilla inicial (`seed`). `DELETE` conserva el valor incremental actual.
  4. **Disparadores:** `TRUNCATE` jamás dispara triggers `AFTER DELETE`.
  5. **Restricción Foránea:** `TRUNCATE` no puede ejecutarse sobre una tabla que sea referenciada por una clave foránea (`FOREIGN KEY`), incluso si la tabla hija se encuentra absolutamente vacía.
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Vaciado inmediato de bitácora o detalle transaccional desacoplado
TRUNCATE TABLE dbo.detalle_venta;
```

---

## 4. LENGUAJE DE MANIPULACIÓN DE DATOS (LMD / DML)

### 4.1 Sentencia `INSERT`
- **Definición Técnica:** Añade una o más tuplas de datos a una tabla o vista actualizable, validando estrictamente los dominios, tipos de datos y restricciones de integridad.
- **Sintaxis Formal Estándar (BNF):**
```sql
INSERT INTO [esquema.]nombre_tabla [(columna_1, columna_2, ...)]
    [OUTPUT inserted.columna_1, ...]
    { 
        VALUES (valor_1, valor_2, ...), (valor_3, valor_4, ...) 
      | SELECT consulta_origen 
      | EXECUTE procedimiento_almacenado 
      | DEFAULT VALUES 
    };
```
- **Parámetros y Opciones Avanzadas:**
  - `(columna_1, ...)`: Especificación explícita de atributos destino. Permite omitir columnas que cuenten con cláusula `DEFAULT`, propiedades `IDENTITY` o permitan valores `NULL`.
  - `OUTPUT inserted.*`: Cláusula avanzada de T-SQL que retorna de inmediato los valores insertados o generados por el motor (crucial para recuperar IDs autoincrementables recién creados).
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Inserción multi-tupla con captura de IDs generados
INSERT INTO dbo.categoria (nombre_cat)
OUTPUT inserted.id_categoria, inserted.nombre_cat
VALUES 
    (N'Lácteos y Refrigerados'),
    (N'Abarrotes Secos'),
    (N'Granos y Semillas');
```

---

### 4.2 Sentencia `UPDATE`
- **Definición Técnica:** Modifica el valor de uno o más atributos en tuplas existentes dentro de una tabla, filtradas opcionalmente por un predicado booleano.
- **Sintaxis Formal Estándar (BNF):**
```sql
UPDATE [TOP (expresion)] [esquema.]nombre_tabla
    SET columna_1 = expresion_1, columna_2 = expresion_2, ...
    [OUTPUT deleted.columna_1, inserted.columna_1]
    [FROM tabla_origen INNER JOIN ... ON ...]
    [WHERE predicado_booleano];
```
- **Parámetros y Consideraciones Críticas:**
  - `SET`: Especifica las columnas a mutar y sus nuevas expresiones evaluadas.
  - `WHERE`: Condición lógica indispensable. La omisión involuntaria de la cláusula `WHERE` provocará la mutación masiva e irreversible de todas las tuplas de la relación.
  - `FROM ... JOIN`: Extensión potente de SQL Server que permite calcular el nuevo valor del atributo a partir de coincidencias y reuniones con tablas externas.
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Incrementar 10% el precio de venta de productos de la categoría 'Lácteos' mediante JOIN
UPDATE p
SET p.precio_venta = ROUND(p.precio_venta * 1.10, 2)
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat = N'Lácteos';
```

---

### 4.3 Sentencia `DELETE`
- **Definición Técnica:** Remueve selectivamente una o más tuplas de una tabla de acuerdo a las condiciones estipuladas en un predicado lógico, verificando la integridad referencial activa.
- **Sintaxis Formal Estándar (BNF):**
```sql
DELETE [TOP (expresion)] FROM [esquema.]nombre_tabla
    [OUTPUT deleted.*]
    [FROM tabla_fuente INNER JOIN ...]
    [WHERE condicion_filtro];
```
- **Parámetros e Integridad Referencial:**
  - `WHERE`: Delimita el conjunto de tuplas a suprimir. Si se omite, purga todas las filas una por una en el log de transacciones.
  - **Comportamiento ante Llaves Foráneas:**
    - Si la regla es `ON DELETE NO ACTION` (por defecto): El motor aborta la operación y lanza un error si existen tuplas hijas vinculadas.
    - Si la regla es `ON DELETE CASCADE`: La supresión de la tupla padre desencadena en cascada la eliminación automática de todas sus tuplas secundarias dependientes.
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Eliminación controlada de un cliente y captura de datos eliminados
DELETE FROM dbo.telefono_persona
WHERE id_persona = 5;
```

---

### 4.4 Sentencia `SELECT`
- **Definición Técnica:** Sentencia analítica declarativa fundamental de SQL que recupera, proyecta, agrupa, transforma y reúne conjuntos de datos procedentes de una o múltiples relaciones.
- **Sintaxis Formal y Orden de Procesamiento Lógico:**
Aunque sintácticamente se escribe iniciando por `SELECT`, el motor de base de datos ejecuta las cláusulas en un orden lógico estricto:
```text
1. FROM / JOIN     -> Identifica las fuentes de datos y resuelve productos cartesianos y reuniones.
2. WHERE           -> Filtra las filas individuales aplicando predicados lógicos booleanos.
3. GROUP BY        -> Agrupa las tuplas resultantes en clases de equivalencia por clave de partición.
4. HAVING          -> Aplica filtros sobre las propiedades agregadas de cada grupo.
5. SELECT          -> Evalúa proyecciones, alias, cálculos y expresiones escalares.
6. DISTINCT        -> Elimina duplicados en el conjunto proyectado.
7. ORDER BY        -> Ordena el conjunto resultado físico para su presentación.
8. OFFSET / FETCH  -> Aplica paginación determinística sobre el flujo ordenado.
```
- **Sintaxis Formal Estándar (BNF):**
```sql
SELECT [DISTINCT | ALL] [TOP (n)] lista_proyeccion
FROM tabla_base [[AS] alias]
    [{INNER | LEFT | RIGHT | FULL} [OUTER] JOIN tabla_relacionada ON condicion_union]
[WHERE predicado_filtro]
[GROUP BY columna_agrupacion_1, ...]
[HAVING predicado_agregacion]
[ORDER BY criterio_orden [ASC | DESC]]
[OFFSET n ROWS FETCH NEXT m ROWS ONLY];
```
- **Funciones de Agregación Estándar:** `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`.
- **Ejemplo en la Tienda de Abarrotes:**
```sql
-- Consulta analítica: Total vendido y cantidad de artículos por categoría con facturación > $50.00
SELECT 
    c.nombre_cat AS categoria,
    COUNT(DISTINCT v.folio) AS total_transacciones,
    SUM(d.cantidad) AS unidades_vendidas,
    SUM(d.cantidad * d.precio_unitario) AS ingreso_bruto
FROM dbo.categoria c
INNER JOIN dbo.producto p ON c.id_categoria = p.id_categoria
INNER JOIN dbo.detalle_venta d ON p.codigo_barras = d.codigo_barras
INNER JOIN dbo.venta v ON d.folio = v.folio
WHERE v.fecha_hora >= '2026-10-01'
GROUP BY c.nombre_cat
HAVING SUM(d.cantidad * d.precio_unitario) > 50.00
ORDER BY ingreso_bruto DESC;
```

---

## 5. CONCLUSIONES

1. **Complementariedad Estructural y Operativa:** SQL articula una separación nítida entre la especificación de esquemas (LDD) y el gobierno operativo de la información (LMD), lo que garantiza la observancia del principio de independencia lógica y física de datos concebido en el modelo relacional.
2. **Impacto en el Rendimiento del Motor:** El uso adecuado de sentencias DDL (como la elección consciente entre `DROP`, `DELETE` y `TRUNCATE`, o la colocación estratégica de claves e índices clúster) es determinante para minimizar la saturación del registro de transacciones (*transaction log*) y mitigar la contención de bloqueos (*locking and latching*) en entornos transaccionales concurrentes.
3. **Robustez de la Integridad:** El motor relacional (SQL Server) actúa como garante absoluto de la consistencia de los datos mediante el acoplamiento directo de restricciones declarativas en DDL (`PK`, `FK`, `CHECK`, `UNIQUE`), asegurando que ninguna instrucción DML pueda dejar a la base de datos en un estado de inconsistencia o corrupción relacional.

---

## 6. REFERENCIAS BIBLIOGRÁFICAS (FORMATO APA 7)

- Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377–387. https://doi.org/10.1145/362384.362685
- Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson Education / Addison-Wesley.
- Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.
- Microsoft Corporation. (2024). *Transact-SQL reference (Database Engine)*. Microsoft Learn. https://learn.microsoft.com/sql/t-sql/
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7.ª ed.). McGraw-Hill Education.
