# GUION DE GRABACIÓN - TAREA 6.1: SINTAXIS Y CLASIFICACIÓN DE SENTENCIAS SQL (LDD vs. LMD)

- **Alumna:** Gabriela Natalia De León Alvarez
- **Materia:** Fundamentos de Base de Datos (Unidad 6)
- **Requisito visual:** Cámara web visible en la esquina inferior derecha durante toda la grabación.
- **Duración estimada:** 5 a 7 minutos.

---

## 1. Introducción y Presentación (0:00 - 0:45)
- "Hola a todos, mi nombre es Gabriela Natalia De León Alvarez, estudiante de Ingeniería Informática en el Tecnológico Nacional de México, matrícula I24050006."
- "El día de hoy presentaré la Tarea 6.1 de la Unidad 6 de Fundamentos de Base de Datos: *Sintaxis y clasificación de sentencias SQL*, analizando a profundidad el Lenguaje de Definición de Datos (LDD) y el Lenguaje de Manipulación de Datos (LMD)."
- "Mostraremos sus fundamentos teóricos, tabla comparativa, sintaxis formal y cláusulas avanzadas aplicadas a nuestro caso de estudio: la Tienda de Abarrotes en Microsoft SQL Server."

---

## 2. Características Generales del Lenguaje SQL (0:45 - 1:45)
- **Concepto:** SQL (*Structured Query Language*) es un lenguaje estándar declarativo para la administración y consulta de bases de datos relacionales, originado por IBM en los años 70 y formalizado por ANSI e ISO.
- **Carácter declarativo:** Como vimos en la Unidad 5 con el álgebra relacional (que es procedimental), en SQL el usuario especifica *qué* datos desea obtener, dejando al optimizador de consultas del SGBD la decisión algorítmica de *cómo* procesarlos.
- **Sublenguajes:** SQL se segmenta en LDD (estructura/metadatos), LMD (tuplas/contenido), DCL (control de acceso) y TCL (control transaccional). En esta sesión nos concentraremos en LDD y LMD.

---

## 3. Tabla Taxonómica y Comparativa LDD vs. LMD (1:45 - 3:00)
- Explicar las diferencias clave en pantalla:
  1. **Objetivo:** LDD modifica el catálogo del sistema y metadatos; LMD manipula los registros dentro de dichas estructuras.
  2. **Transaccionalidad:** En SQL Server, LMD es 100% transaccional (`ROLLBACK` / `COMMIT`). LDD también puede ser transaccional en T-SQL, pero altera el diccionario de datos.
  3. **Disparadores (Triggers):** LMD activa disparadores a nivel de fila/tabla (`AFTER INSERT, UPDATE, DELETE`); LDD activa disparadores DDL a nivel de servidor o base de datos.
  4. **Impacto en Bloqueos:** LDD usa bloqueos exclusivos de esquema (`Sch-M`), mientras que LMD usa bloqueos compartidos (`S`), exclusivos de datos (`X`) o de intención (`IX`).

---

## 4. Lenguaje de Definición de Datos - LDD (3:00 - 4:15)
- **CREATE:** Creación de objetos. Explicar sintaxis básica y avanzada: tipos de datos, llaves primarias (`PK`), foráneas (`FK`), restricciones `CHECK`, `UNIQUE` y tablas de particionamiento.
- **ALTER:** Modificación estructural en caliente. Agregar (`ADD`), modificar (`ALTER COLUMN`) o descartar (`DROP CONSTRAINT / COLUMN`) sin destruir la tabla existente.
- **DROP:** Eliminación destructiva completa de la definición del objeto y sus datos en disco. Se bloquea si existen dependencias foráneas activas (`RESTRICT` / reglas relacionales).
- **TRUNCATE:** Vaciado ultrarrápido y de mínimo registro de log (*minimally logged*). Diferencia crucial con `DELETE`: reinicia contadores `IDENTITY`, no activa triggers de fila y desasigna extensiones de páginas de datos (`GAM/SGAM`).

---

## 5. Lenguaje de Manipulación de Datos - LMD (4:15 - 5:45)
- **INSERT:** Inserción de tuplas individuales, múltiples o mediante subconsultas `INSERT INTO ... SELECT`. Cláusula avanzada: `OUTPUT` para auditoría.
- **UPDATE:** Actualización de atributos. Resaltar la importancia crítica de la cláusula `WHERE` para evitar modificaciones accidentales en toda la tabla. Opciones como `FROM` para actualización cruzada con `JOIN`.
- **DELETE:** Eliminación selectiva de filas respetando la integridad referencial. Explica el comportamiento frente a `ON DELETE CASCADE` vs `ON DELETE NO ACTION`.
- **SELECT:** La sentencia analítica fundamental. Arquitectura formal de procesamiento: `FROM` → `JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY` → `OFFSET/FETCH`.

---

## 6. Conclusión y Cierre (5:45 - 6:30)
- "Comprender la frontera técnica entre LDD y LMD es indispensable para diseñar arquitecturas de software robustas, evitar bloqueos de concurrencia y garantizar la integridad referencial de los datos."
- "Todos los diagramas, sintaxis y el documento formal se encuentran disponibles en nuestro repositorio de GitHub."
- "Agradezco mucho su atención y nos vemos en la siguiente entrega de la Tarea 6.2 con la ejecución práctica de scripts en vivo."
