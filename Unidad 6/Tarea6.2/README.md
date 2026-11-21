# Tarea 6.2: Implementación de Script DDL, Carga de Datos y Consultas DML

📍 [Fundamentos de Bases de Datos](../../README.md) › Unidad 6 › **Tarea 6.2**

**Tecnológico Nacional de México**  
**Carrera:** Ingeniería Informática  
**Materia:** Fundamentos de Base de Datos  
**Unidad:** 6 — Introducción al Lenguaje SQL  
**Alumna:** Gabriela Natalia De León Alvarez  
**Matrícula:** I24050006  
**Motor SGBD:** Microsoft SQL Server (T-SQL)  

---

## 📌 Descripción

Implementación integral y modular del esquema relacional del caso de estudio de la **Tienda de Abarrotes de Barrio**, ejecutado en tres fases operativas rigurosas:

1. **Fase LDD (`01_schema_ddl.sql`):** Creación de la base de datos `TiendaAbarrotes_U6`, 14 tablas físicas relacionales normalizadas, restricciones de clave primaria (`PRIMARY KEY`), integridad referencial (`FOREIGN KEY` con `CASCADE` y `NO ACTION`), reglas de dominio (`CHECK`, `DEFAULT`, `UNIQUE`) e índices no agrupados (`NONCLUSTERED INDEX`).
2. **Fase LMD de Poblado (`02_data_inserts.sql`):** Inserción ordenada de tuplas representativas en cada tabla respetando estrictamente el grafo de dependencias de claves foráneas.
3. **Fase LMD Analítica y Mantenimiento (`03_queries_dml.sql`):**
   - **Consultas SELECT:** Proyecciones básicas, filtros con operadores relacionales (`WHERE`), ordenamientos compuestos (`ORDER BY`), agrupaciones (`GROUP BY`, `HAVING`), funciones de agregación (`COUNT`, `SUM`, `AVG`, `MAX`, `MIN`), y reuniones relacionales (`INNER JOIN`, `LEFT JOIN`).
   - **Mantenimiento e Integridad Referencial:** Actualizaciones controladas (`UPDATE` simple y con `JOIN`), prueba de rechazo de borrado por restricción activa (`ON DELETE NO ACTION`), y pruebas de eliminación en cascada (`ON DELETE CASCADE`) a nivel transaccional y multi-nivel.

---

## 📂 Estructura de Scripts y Archivos

| Archivo | Fase Técnica | Descripción |
|---|:---:|---|
| [01_schema_ddl.sql](01_schema_ddl.sql) | **LDD / DDL** | Creación de base de datos, tablas, restricciones e índices |
| [02_data_inserts.sql](02_data_inserts.sql) | **LMD / DML** | Carga masiva y representativa de datos de prueba |
| [03_queries_dml.sql](03_queries_dml.sql) | **LMD / DML** | Catálogo de 8 consultas analíticas + 5 pruebas de integridad |
| [Tarea6.2_Reporte_Tecnico_SQL.docx](Tarea6.2_Reporte_Tecnico_SQL.docx) | **Reporte** | Documento Word editable con el reporte técnico y espacios para capturas |
| [guion-video-tarea6.2.md](guion-video-tarea6.2.md) | **Video** | Guion paso a paso para la demostración en vivo en YouTube |

---

## 🚀 Instrucciones de Clonación y Ejecución en SQL Server

### Prerrequisitos
- Microsoft SQL Server 2017, 2019, 2022 o SQL Server Express.
- SQL Server Management Studio (SSMS), Azure Data Studio o la utilidad de línea de comandos `sqlcmd`.

### Opción A: Ejecución desde SQL Server Management Studio (SSMS)
1. Abrir **SSMS** y conectarse a la instancia local de SQL Server.
2. Abrir y ejecutar los scripts **en el siguiente orden estricto** utilizando la combinación de teclas `F5`:
   - `01_schema_ddl.sql` (Verificar que se hayan creado las 14 tablas en el Explorador de Objetos).
   - `02_data_inserts.sql` (Verificar los mensajes de confirmación de tuplas insertadas).
   - `03_queries_dml.sql` (Revisar los resultados en la pestaña *Results* y los mensajes en *Messages*).

### Opción B: Ejecución por Línea de Comandos (`sqlcmd`)
Abrir PowerShell o la consola de Windows en el directorio de la carpeta `Unidad 6/Tarea6.2/`:

```powershell
# 1. Ejecutar LDD (Estructura)
sqlcmd -S localhost -E -i 01_schema_ddl.sql

# 2. Ejecutar Poblado de Datos
sqlcmd -S localhost -E -i 02_data_inserts.sql

# 3. Ejecutar Consultas y Pruebas DML
sqlcmd -S localhost -E -i 03_queries_dml.sql
```

---

## 🎥 Video Demostrativo en Vivo (YouTube)

> ⚠️ *El enlace se integrará una vez realizada la grabación en vivo con la ejecución de los scripts en SSMS y cámara web en la esquina inferior derecha.*

▶️ **[Ver demostración en vivo en YouTube: Tarea 6.2 - Ejecución DDL y DML](https://www.youtube.com/)**
