/* validacion.sql - Consultas al catálogo de SQL Server para validar el esquema físico
   Ejecutar DESPUÉS de schema.sql. Cada resultado sirve como evidencia (captura de pantalla). */
USE TiendaAbarrotes;
GO

-- 1. Resumen de objetos creados (valores esperados entre paréntesis)
SELECT
    (SELECT COUNT(*) FROM sys.tables)                                         AS tablas,             -- (14)
    (SELECT COUNT(*) FROM sys.key_constraints WHERE type = 'PK')              AS llaves_primarias,   -- (14)
    (SELECT COUNT(*) FROM sys.foreign_keys)                                   AS llaves_foraneas,    -- (16)
    (SELECT COUNT(*) FROM sys.key_constraints WHERE type = 'UQ')              AS restricciones_unique, -- (2)
    (SELECT COUNT(*) FROM sys.check_constraints)                              AS restricciones_check,  -- (14)
    (SELECT COUNT(*) FROM sys.default_constraints)                            AS valores_default,    -- (7)
    (SELECT COUNT(*) FROM sys.identity_columns)                               AS columnas_identity,  -- (5)
    (SELECT COUNT(*) FROM sys.views)                                          AS vistas,             -- (6)
    (SELECT COUNT(*) FROM sys.indexes i
        JOIN sys.tables t ON t.object_id = i.object_id
        WHERE i.type > 0 AND i.is_primary_key = 0 AND i.is_unique_constraint = 0) AS indices;        -- (10)
GO

-- 2. Tablas y número de filas
SELECT t.name AS tabla, SUM(p.row_count) AS filas
FROM sys.tables t
JOIN sys.dm_db_partition_stats p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
GO

-- 3. Diccionario de datos: columnas, tipos, nulabilidad y descripción
SELECT t.name AS tabla, c.column_id AS n, c.name AS columna,
       ty.name + CASE
            WHEN ty.name IN ('varchar', 'char') THEN '(' + CAST(c.max_length AS VARCHAR(10)) + ')'
            WHEN ty.name IN ('nvarchar', 'nchar') THEN '(' + CAST(c.max_length / 2 AS VARCHAR(10)) + ')'
            WHEN ty.name IN ('decimal', 'numeric') THEN '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
            WHEN ty.name = 'datetime2' THEN '(' + CAST(c.scale AS VARCHAR(10)) + ')'
            ELSE '' END AS tipo,
       CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END AS nulo,
       CASE WHEN c.is_identity = 1 THEN 'IDENTITY' ELSE '' END AS identidad,
       CAST(ep.value AS NVARCHAR(400)) AS descripcion
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.extended_properties ep
       ON ep.class = 1 AND ep.major_id = c.object_id AND ep.minor_id = c.column_id AND ep.name = 'MS_Description'
ORDER BY t.name, c.column_id;
GO

-- 4. Llaves primarias (una fila por columna)
SELECT t.name AS tabla, kc.name AS restriccion, ic.key_ordinal AS posicion, c.name AS columna
FROM sys.tables t
JOIN sys.key_constraints kc ON kc.parent_object_id = t.object_id AND kc.type = 'PK'
JOIN sys.index_columns ic ON ic.object_id = t.object_id AND ic.index_id = kc.unique_index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
ORDER BY t.name, ic.key_ordinal;
GO

-- 5. Llaves foráneas con sus acciones referenciales (eliminación / actualización)
SELECT fk.name AS llave_foranea,
       OBJECT_NAME(fk.parent_object_id) AS tabla_hija,
       COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS columna_hija,
       OBJECT_NAME(fk.referenced_object_id) AS tabla_padre,
       COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS columna_padre,
       fk.delete_referential_action_desc AS al_eliminar,
       fk.update_referential_action_desc AS al_actualizar
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
ORDER BY tabla_hija, fk.name, fkc.constraint_column_id;
GO

-- 6. Restricciones UNIQUE
SELECT OBJECT_NAME(kc.parent_object_id) AS tabla, kc.name AS restriccion, c.name AS columna
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON ic.object_id = kc.parent_object_id AND ic.index_id = kc.unique_index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE kc.type = 'UQ'
ORDER BY tabla;
GO

-- 7. Restricciones CHECK
SELECT OBJECT_NAME(parent_object_id) AS tabla, name AS restriccion, definition
FROM sys.check_constraints
ORDER BY tabla, name;
GO

-- 8. Valores predeterminados (DEFAULT)
SELECT OBJECT_NAME(dc.parent_object_id) AS tabla, c.name AS columna, dc.name AS restriccion, dc.definition
FROM sys.default_constraints dc
JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
ORDER BY tabla, columna;
GO

-- 9. Índices no asociados a llaves primarias ni UNIQUE
SELECT t.name AS tabla, i.name AS indice, i.type_desc AS tipo, ic.key_ordinal AS posicion, c.name AS columna
FROM sys.tables t
JOIN sys.indexes i ON i.object_id = t.object_id
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.type > 0 AND i.is_primary_key = 0 AND i.is_unique_constraint = 0
ORDER BY t.name, i.name, ic.key_ordinal;
GO

-- 10. Vistas
SELECT name AS vista, create_date FROM sys.views ORDER BY name;
GO
