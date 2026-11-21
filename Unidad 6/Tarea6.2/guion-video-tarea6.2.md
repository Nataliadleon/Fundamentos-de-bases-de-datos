# GUION DE DEMOSTRACIÓN EN VIVO - TAREA 6.2: SCRIPTS DDL, CARGA DML Y CONSULTAS

- **Alumna:** Gabriela Natalia De León Alvarez
- **Materia:** Fundamentos de Base de Datos (Unidad 6)
- **Requisito visual:** Cámara web visible en la esquina inferior derecha durante toda la demostración.
- **Herramienta en pantalla:** SQL Server Management Studio (SSMS) o Azure Data Studio.
- **Duración estimada:** 7 a 10 minutos.

---

## 1. Introducción y Contexto (0:00 - 1:00)
- "Hola a todos, bienvenidos. Soy Gabriela Natalia De León Alvarez, alumna de Ingeniería Informática en el Tecnológico Nacional de México, matrícula I24050006."
- "En este video demostraremos en vivo la ejecución de los tres scripts de la Tarea 6.2 de Fundamentos de Base de Datos en Microsoft SQL Server."
- "Nuestro caso de estudio es la Tienda de Abarrotes de Barrio, que hemos venido normalizando hasta Tercera Forma Normal y Forma Normal de Boyce-Codd."
- "Mostraremos: 1) Creación de tablas y restricciones DDL; 2) Poblado consistente de datos DML; y 3) Consultas analíticas avanzadas junto con pruebas de integridad referencial."

---

## 2. Fase 1: Creación del Esquema DDL - 01_schema_ddl.sql (1:00 - 3:00)
- Mostrar en pantalla el archivo `01_schema_ddl.sql`.
- Resaltar puntos clave del código:
  - `CREATE DATABASE TiendaAbarrotes_U6`
  - Eliminación ordenada preventiva `DROP TABLE IF EXISTS` en orden inverso de dependencias.
  - Creación de la jerarquía de herencia: `persona` -> `empleado` -> `cajero` / `repartidor`, y `persona` -> `cliente`.
  - Restricciones declarativas: `PRIMARY KEY`, `FOREIGN KEY` con `ON DELETE CASCADE` para subtipos y relaciones padre-hijo; `CHECK` de precios (`precio_venta >= costo_compra`) y de métodos de pago.
  - Índices `NONCLUSTERED INDEX` en claves foráneas.
- **Acción:** Presionar `F5` (Execute) en SSMS y mostrar el mensaje en la consola: *FASE 1 DDL FINALIZADA CON ÉXITO*.
- Refrescar el *Object Explorer* y desplegar la lista de las 14 tablas creadas.

---

## 3. Fase 2: Poblado de Datos - 02_data_inserts.sql (3:00 - 4:30)
- Abrir `02_data_inserts.sql`.
- Explicar la secuencia obligatoria de inserción:
  - Primero las tablas independientes (categorías, personas, proveedores).
  - Luego las especializaciones y catálogos dependientes (empleados, cajeros, repartidores, clientes, teléfonos).
  - Posteriormente los productos y relaciones de abastecimiento.
  - Finalmente las entidades transaccionales: `venta` y `detalle_venta`.
- **Acción:** Presionar `F5` y mostrar los mensajes de filas afectadas: *FASE 2 LMD/DML FINALIZADA CON ÉXITO*.
- Hacer una consulta rápida en vivo: `SELECT COUNT(*) FROM dbo.producto;` (12 filas) y `SELECT COUNT(*) FROM dbo.venta;` (6 folios).

---

## 4. Fase 3: Consultas Analíticas SELECT - 03_queries_dml.sql (4:30 - 7:00)
- Abrir `03_queries_dml.sql` y ejecutar en bloques comentando la salida en la pestaña *Results*:
  - **Consulta 2 (WHERE):** Filtrado de productos con stock crítico para reabastecimiento (`stock_actual <= stock_minimo`).
  - **Consulta 4 (Agregación global):** Métricas globales del inventario (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).
  - **Consulta 5 y 6 (GROUP BY + HAVING):** Agrupación por categoría y filtro `HAVING COUNT(*) >= 3`.
  - **Consulta 7 (INNER JOIN múltiple):** Reconstrucción de la tira completa de venta (Cliente, Cajero, Producto, Cantidad y Subtotal calculado).
  - **Consulta 8 (LEFT JOIN):** Cartera total de clientes con su facturación acumulada, demostrando la conservación de clientes sin compras mediante `COALESCE`.

---

## 5. Fase 4: Operaciones de Mantenimiento e Integridad Referencial (7:00 - 8:45)
- Ejecutar la Parte 2 del script `03_queries_dml.sql`:
  - **UPDATE con JOIN:** Modificación del precio de productos lácteos mediante combinación con la tabla categoría.
  - **Prueba de bloqueo (ON DELETE NO ACTION):** Intentar eliminar la categoría 1 (`DELETE FROM dbo.categoria WHERE id_categoria = 1`). Mostrar en la consola de SSMS cómo el bloque `TRY...CATCH` atrapa el error 547 del motor de base de datos indicando violación de clave foránea activa.
  - **Prueba de eliminación en cascada (ON DELETE CASCADE):** Mostrar los registros del Folio 6 en `detalle_venta`, ejecutar `DELETE FROM dbo.venta WHERE folio = 6`, y verificar inmediatamente que el conteo en `detalle_venta` pasa a 0 automáticamente.

---

## 6. Conclusión y Despedida (8:45 - 9:30)
- "Con esto comprobamos de manera práctica y fehaciente la aplicación de los comandos DDL y DML en Microsoft SQL Server."
- "Validamos cómo el motor protege la integridad de los datos impidiendo borrados huérfanos y automatizando la cascada cuando las reglas de negocio así lo definen."
- "Todo el código fuente y las instrucciones de ejecución se encuentran disponibles en nuestro repositorio de GitHub."
- "Muchas gracias por su atención."
