/* =====================================================================
   03_queries_dml.sql - Consultas Analíticas y Operaciones de Mantenimiento
   Caso de Estudio: Tienda de Abarrotes de Barrio
   Materia : Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
   Alumna  : Gabriela Natalia De León Alvarez (I24050006)
   Motor   : Microsoft SQL Server (Transact-SQL)
   
   CONTENIDO:
   Parte 1: Consultas LMD (SELECT básicas, WHERE, ORDER BY, GROUP BY, HAVING,
            Funciones de Agregación, INNER JOIN, LEFT JOIN).
   Parte 2: Operaciones de Mantenimiento (UPDATE y DELETE con comprobación
            de Integridad Referencial estricta).
   ===================================================================== */

SET NOCOUNT ON;
GO

USE TiendaAbarrotes_U6;
GO

PRINT '=====================================================================';
PRINT ' PARTE 1: CONSULTAS LMD / DML (ANÁLISIS DE DATOS)';
PRINT '=====================================================================';
GO

-- ---------------------------------------------------------------------
-- CONSULTA 1: SELECT básica con proyección de catálogo de productos
-- Proyecta código, nombre, categoría y precio de venta.
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 1] Catálogo general de productos (Proyección básica):';
SELECT 
    codigo_barras AS Codigo,
    nombre AS Producto,
    costo_compra AS Costo,
    precio_venta AS PrecioVenta,
    stock_actual AS Stock
FROM dbo.producto;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 2: Filtros condicionales con WHERE (Operadores lógicos y de comparación)
-- Productos cuyo stock actual es crítico o igual a su stock mínimo, o con margen > $10.00
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 2] Productos en estado crítico de reabastecimiento (WHERE):';
SELECT 
    codigo_barras AS Codigo,
    nombre AS Producto,
    stock_actual AS StockActual,
    stock_minimo AS StockMinimo,
    (precio_venta - costo_compra) AS MargenUnitario
FROM dbo.producto
WHERE stock_actual <= stock_minimo;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 3: Ordenamiento con ORDER BY (Múltiples criterios ASC / DESC)
-- Lista de productos ordenados por categoría ascendente y por precio descendente
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 3] Catálogo clasificado y ordenado (ORDER BY multi-criterio):';
SELECT 
    id_categoria AS IdCat,
    nombre AS Producto,
    precio_venta AS PrecioVenta,
    stock_actual AS Stock
FROM dbo.producto
ORDER BY id_categoria ASC, precio_venta DESC;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 4: Funciones de Agregación Globales (COUNT, SUM, AVG, MAX, MIN)
-- Métricas consolidadas sobre el inventario de la tienda
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 4] Resumen estadístico del inventario (Funciones de Agregación):';
SELECT 
    COUNT(*) AS TotalProductosRegistrados,
    SUM(stock_actual) AS TotalUnidadesFisicas,
    AVG(precio_venta) AS PrecioPromedioVenta,
    MIN(precio_venta) AS PrecioMasBajo,
    MAX(precio_venta) AS PrecioMasAlto,
    SUM(stock_actual * costo_compra) AS ValorTotalInventarioCosto
FROM dbo.producto;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 5: Agrupamiento con GROUP BY y Funciones de Agregación
-- Conteo de productos, inventario total y precio promedio por categoría
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 5] Métricas de inventario agrupadas por categoría (GROUP BY):';
SELECT 
    c.nombre_cat AS Categoria,
    COUNT(p.codigo_barras) AS CantidadVariedades,
    SUM(p.stock_actual) AS StockTotalCategoria,
    CAST(AVG(p.precio_venta) AS DECIMAL(10,2)) AS PrecioPromedio
FROM dbo.categoria c
INNER JOIN dbo.producto p ON c.id_categoria = p.id_categoria
GROUP BY c.nombre_cat;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 6: Filtrado de grupos con HAVING
-- Categorías que poseen más de 2 productos registrados en inventario
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 6] Categorías con alta variedad de catálogo (GROUP BY + HAVING):';
SELECT 
    c.nombre_cat AS Categoria,
    COUNT(p.codigo_barras) AS Variedades,
    SUM(p.stock_actual) AS UnidadesTotales
FROM dbo.categoria c
INNER JOIN dbo.producto p ON c.id_categoria = p.id_categoria
GROUP BY c.nombre_cat
HAVING COUNT(p.codigo_barras) >= 3;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 7: Reunión Interna (INNER JOIN) entre múltiples tablas
-- Detalle completo de ventas: Folio, Fecha, Cajero, Cliente, Producto y Subtotal
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 7] Tira detallada de ventas con INNER JOIN múltiple:';
SELECT 
    v.folio AS FolioVenta,
    FORMAT(v.fecha_hora, 'yyyy-MM-dd HH:mm') AS FechaHora,
    v.metodo_pago AS MetodoPago,
    CONCAT(per_caj.nombre_pila, ' ', per_caj.apellido_paterno) AS CajeroAtendio,
    p.nombre AS ProductoVendido,
    d.cantidad AS Cantidad,
    d.precio_unitario AS PrecioUnit,
    CAST(d.cantidad * d.precio_unitario AS DECIMAL(10,2)) AS Subtotal
FROM dbo.venta v
INNER JOIN dbo.cajero c ON v.id_cajero = c.id_persona
INNER JOIN dbo.persona per_caj ON c.id_persona = per_caj.id_persona
INNER JOIN dbo.detalle_venta d ON v.folio = d.folio
INNER JOIN dbo.producto p ON d.codigo_barras = p.codigo_barras
ORDER BY v.folio ASC, p.nombre ASC;
GO

-- ---------------------------------------------------------------------
-- CONSULTA 8: Reunión Externa Izquierda (LEFT JOIN)
-- Listado de TODOS los clientes registrados y el monto total que han comprado
-- (identificando clientes sin compras mediante COALESCE/NULL)
-- ---------------------------------------------------------------------
PRINT '>> [CONSULTA 8] Cartera de clientes y facturación acumulada (LEFT JOIN):';
SELECT 
    cli.id_persona AS IdCliente,
    CONCAT(per.nombre_pila, ' ', per.apellido_paterno, ' ', COALESCE(per.apellido_materno, '')) AS Cliente,
    cli.limite_credito AS LimiteCredito,
    COUNT(DISTINCT v.folio) AS TotalComprasRealizadas,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0.00) AS TotalFacturadoHistorico
FROM dbo.cliente cli
INNER JOIN dbo.persona per ON cli.id_persona = per.id_persona
LEFT JOIN dbo.venta v ON cli.id_persona = v.id_cliente
LEFT JOIN dbo.detalle_venta d ON v.folio = d.folio
GROUP BY cli.id_persona, per.nombre_pila, per.apellido_paterno, per.apellido_materno, cli.limite_credito
ORDER BY TotalFacturadoHistorico DESC;
GO

PRINT '=====================================================================';
PRINT ' PARTE 2: OPERACIONES DE MANTENIMIENTO E INTEGRIDAD REFERENCIAL';
PRINT '=====================================================================';
GO

-- ---------------------------------------------------------------------
-- OPERACIÓN 1 (UPDATE BÁSICO): Actualización controlada con WHERE
-- Aumento de límite de crédito a un cliente específico
-- ---------------------------------------------------------------------
PRINT '>> [MANTENIMIENTO 1] UPDATE: Incrementando límite de crédito a cliente 5:';
SELECT id_persona, limite_credito AS LimiteAnterior FROM dbo.cliente WHERE id_persona = 5;

UPDATE dbo.cliente
SET limite_credito = 3500.00
WHERE id_persona = 5;

SELECT id_persona, limite_credito AS LimiteActualizado FROM dbo.cliente WHERE id_persona = 5;
GO

-- ---------------------------------------------------------------------
-- OPERACIÓN 2 (UPDATE RELACIONAL CON JOIN):
-- Aplicación de un descuento del 5% al precio de venta de productos lácteos
-- ---------------------------------------------------------------------
PRINT '>> [MANTENIMIENTO 2] UPDATE con JOIN: Ajuste de precios por categoría:';
SELECT p.codigo_barras, p.nombre, c.nombre_cat, p.precio_venta AS PrecioAntes
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat LIKE N'Lácteos%';

UPDATE p
SET p.precio_venta = ROUND(p.precio_venta * 1.05, 2)
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat LIKE N'Lácteos%';

SELECT p.codigo_barras, p.nombre, c.nombre_cat, p.precio_venta AS PrecioActualizado
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat LIKE N'Lácteos%';
GO

-- ---------------------------------------------------------------------
-- OPERACIÓN 3 (INTEGRIDAD REFERENCIAL - PRUEBA DE BLOQUEO EN DELETE):
-- Intento controlado de eliminar una categoría que posee productos vinculados.
-- Demostración de ON DELETE NO ACTION (Debe capturar el error).
-- ---------------------------------------------------------------------
PRINT '>> [MANTENIMIENTO 3] DELETE RESTRICTIVO (ON DELETE NO ACTION):';
BEGIN TRY
    PRINT 'Intentando eliminar la categoría 1 (Lácteos) con productos asociados...';
    DELETE FROM dbo.categoria WHERE id_categoria = 1;
    PRINT 'ALERTA: La eliminación procedió (Violación inesperada).';
END TRY
BEGIN CATCH
    PRINT '>> COMPROBACIÓN EXITOSA: El motor bloqueó la eliminación por restricción FK.';
    PRINT '>> Mensaje de SQL Server: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ---------------------------------------------------------------------
-- OPERACIÓN 4 (INTEGRIDAD REFERENCIAL - ELIMINACIÓN EN CASCADA):
-- Demostración de ON DELETE CASCADE eliminando una tupla en VENTA
-- y comprobando la remoción automática de sus registros en DETALLE_VENTA.
-- ---------------------------------------------------------------------
PRINT '>> [MANTENIMIENTO 4] DELETE EN CASCADA (ON DELETE CASCADE):';
PRINT 'Líneas de detalle antes de eliminar la venta Folio 6:';
SELECT folio, codigo_barras, cantidad, precio_unitario FROM dbo.detalle_venta WHERE folio = 6;

PRINT 'Eliminando el encabezado de venta Folio 6...';
DELETE FROM dbo.venta WHERE folio = 6;

PRINT 'Comprobando eliminación automática en cascada en DETALLE_VENTA:';
SELECT COUNT(*) AS RegistrosRestantesDetalleFolio6 FROM dbo.detalle_venta WHERE folio = 6;
GO

-- ---------------------------------------------------------------------
-- OPERACIÓN 5 (INTEGRIDAD REFERENCIAL - PERSONA Y TELÉFONO CASCADE):
-- Eliminación de una persona cliente (ID 8) y verificación de borrado en cascada
-- en CLIENTE y TELEFONO_PERSONA.
-- ---------------------------------------------------------------------
PRINT '>> [MANTENIMIENTO 5] DELETE CASCADA MULTI-NIVEL (Persona -> Cliente y Teléfono):';
PRINT 'Estado previo de la Persona 8:';
SELECT * FROM dbo.persona WHERE id_persona = 8;
SELECT * FROM dbo.cliente WHERE id_persona = 8;
SELECT * FROM dbo.telefono_persona WHERE id_persona = 8;

DELETE FROM dbo.persona WHERE id_persona = 8;

PRINT 'Comprobando eliminación en cascada de Persona 8:';
SELECT COUNT(*) AS ConteoPersona FROM dbo.persona WHERE id_persona = 8;
SELECT COUNT(*) AS ConteoCliente FROM dbo.cliente WHERE id_persona = 8;
SELECT COUNT(*) AS ConteoTelefono FROM dbo.telefono_persona WHERE id_persona = 8;
GO

PRINT '=====================================================================';
PRINT '>> FASE 3 DML FINALIZADA CON ÉXITO: Consultas y pruebas concluidas.';
PRINT '=====================================================================';
GO
