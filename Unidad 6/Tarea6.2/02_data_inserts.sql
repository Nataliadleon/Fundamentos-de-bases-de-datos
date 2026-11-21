/* =====================================================================
   02_data_inserts.sql - Poblado de Datos de Prueba (LMD / DML)
   Caso de Estudio: Tienda de Abarrotes de Barrio
   Materia : Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
   Alumna  : Gabriela Natalia De León Alvarez (I24050006)
   Motor   : Microsoft SQL Server (Transact-SQL)
   
   OBJETIVO:
   Insertar un conjunto de datos consistente y representativo en cada una
   de las tablas, respetando la secuencia estricta de integridad referencial.
   ===================================================================== */

SET NOCOUNT ON;
GO

USE TiendaAbarrotes_U6;
GO

PRINT '>> Iniciando poblado de datos de prueba en TiendaAbarrotes_U6...';
GO

-- 1. POBLADO DE CATEGORÍAS
INSERT INTO dbo.categoria (nombre_cat)
VALUES 
    (N'Lácteos y Derivados'),       -- ID 1
    (N'Abarrotes y Enlatados'),     -- ID 2
    (N'Granos, Semillas y Pastas'), -- ID 3
    (N'Bebidas y Refrescos'),       -- ID 4
    (N'Panadería y Dulces');        -- ID 5
PRINT '>> Categorías insertadas (5 registros).';
GO

-- 2. POBLADO DE PERSONAS
INSERT INTO dbo.persona (nombre_pila, apellido_paterno, apellido_materno, fecha_nacimiento)
VALUES
    (N'Mario', N'Casas', N'Cruz', '1995-04-12'),           -- ID 1: Cajero Matutino
    (N'Laura Elena', N'Méndez', N'Silva', '2001-01-30'),   -- ID 2: Cajera Vespertina
    (N'Roberto', N'Gómez', N'Luna', '1998-08-23'),         -- ID 3: Repartidor Motocicleta
    (N'Fernando', N'Ríos', N'Rosas', '1992-12-14'),        -- ID 4: Repartidor Camioneta
    (N'Juan Carlos', N'Pérez', N'López', '1988-11-05'),    -- ID 5: Cliente Habitual
    (N'Ana Luisa', N'Silva', N'Romero', '1992-07-19'),     -- ID 6: Cliente Crédito
    (N'Guillermo', N'Torres', N'Navarro', '1980-03-25'),   -- ID 7: Cliente Crédito
    (N'Beatriz', N'Morales', N'Cervantes', '1999-09-08');  -- ID 8: Cliente Contado
PRINT '>> Personas insertadas (8 registros).';
GO

-- 3. POBLADO DE TELÉFONOS DE PERSONAS (Atributo Multivalorado)
INSERT INTO dbo.telefono_persona (id_persona, telefono)
VALUES
    (1, '5511223344'),
    (2, '5522334455'),
    (3, '5533445566'),
    (5, '5544556677'),
    (5, '5599887766'), -- Cliente 5 cuenta con 2 líneas telefónicas
    (6, '5555667788'),
    (7, '5566778899'),
    (8, '5577889900');
PRINT '>> Teléfonos de personas insertados (8 registros).';
GO

-- 4. POBLADO DE EMPLEADOS
INSERT INTO dbo.empleado (id_persona, fecha_contratacion, salario, puesto)
VALUES
    (1, '2023-01-15', 9200.00, 'CAJERO'),
    (2, '2024-02-01', 9200.00, 'CAJERO'),
    (3, '2023-05-10', 8800.00, 'REPARTIDOR'),
    (4, '2024-06-15', 8800.00, 'REPARTIDOR');
PRINT '>> Empleados insertados (4 registros).';
GO

-- 5. POBLADO DE CAJEROS (Subtipo de Empleado)
INSERT INTO dbo.cajero (id_persona, turno)
VALUES
    (1, 'MATUTINO'),
    (2, 'VESPERTINO');
PRINT '>> Cajeros insertados (2 registros).';
GO

-- 6. POBLADO DE REPARTIDORES (Subtipo de Empleado)
INSERT INTO dbo.repartidor (id_persona, licencia, vehiculo)
VALUES
    (3, 'LIC-CDMX-998877', N'Motocicleta Honda 125cc'),
    (4, 'LIC-MEX-445566', N'Camioneta Nissan NP300');
PRINT '>> Repartidores insertados (2 registros).';
GO

-- 7. POBLADO DE CLIENTES
INSERT INTO dbo.cliente (id_persona, limite_credito, fecha_registro)
VALUES
    (5, 2500.00, '2024-01-10'),
    (6, 3000.00, '2024-03-22'),
    (7, 1800.00, '2024-07-05'),
    (8, 0.00,    '2024-09-18'); -- Cliente de contado con límite $0.00
PRINT '>> Clientes insertados (4 registros).';
GO

-- 8. POBLADO DE PROVEEDORES
INSERT INTO dbo.proveedor (razon_social, calle, numero, colonia, codigo_postal)
VALUES
    (N'Distribuidora Láctea del Centro S.A.', N'Av. Insurgentes Sur', N'1240', N'Del Valle', '03100'),
    (N'Comercializadora de Granos La Espiga', N'Calz. de la Viga', N'850', N'Iztacalco', '08800'),
    (N'Abarrotes y Alimentos Mayoristas MX', N'Eje Central Lázaro Cárdenas', N'345', N'Doctores', '06720'),
    (N'Embotelladora Bebidas Frescas S.A.P.I.', N'Av. Ferrocarril', N'112', N'Industrial Vallejo', '02300');
PRINT '>> Proveedores insertados (4 registros).';
GO

-- 9. POBLADO DE TELÉFONOS DE PROVEEDORES
INSERT INTO dbo.telefono_proveedor (id_proveedor, telefono)
VALUES
    (1, '5556781234'),
    (1, '5556784321'),
    (2, '5578901234'),
    (3, '5589012345'),
    (4, '5590123456');
PRINT '>> Teléfonos de proveedores insertados (5 registros).';
GO

-- 10. POBLADO DE PRODUCTOS (Inventario)
INSERT INTO dbo.producto (codigo_barras, nombre, costo_compra, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES
    ('PROD01', N'Leche Entera UltraPasteurizada 1L', 19.50, 26.50, 48, 15, 1),
    ('PROD02', N'Queso Panela Artesanal 400g',        38.00, 52.00, 25, 10, 1),
    ('PROD03', N'Yogurt Natural Bebible 1kg',         24.00, 34.00, 18,  8, 1),
    ('PROD04', N'Atún en Agua Aleta Amarilla 140g',   14.00, 21.50, 80, 20, 2),
    ('PROD05', N'Aceite Vegetal Comestible 900ml',    32.00, 44.50, 35, 12, 2),
    ('PROD06', N'Frijol Negro Seleccionado 1kg',      27.50, 38.00, 60, 25, 3),
    ('PROD07', N'Arroz Blanco Grano Largo 1kg',       18.00, 26.00, 75, 20, 3),
    ('PROD08', N'Refresco Cola Familiar 2.5L',        25.00, 36.00, 40, 15, 4),
    ('PROD09', N'Agua Mineral Purificada 1.5L',       12.00, 18.00, 50, 15, 4),
    ('PROD10', N'Pan Blanco Caja 680g',               28.00, 41.00, 20, 10, 5),
    ('PROD11', N'Galletas de Chocolate 120g',         11.00, 17.50, 90, 30, 5),
    ('PROD12', N'Mermelada de Fresa 270g',            26.00, 37.00,  6, 12, 5); -- Stock crítico < stock_minimo
PRINT '>> Catálogo de productos insertado (12 registros).';
GO

-- 11. POBLADO DE ABASTECIMIENTO (Relación M:N Proveedor - Producto)
INSERT INTO dbo.abastecimiento (id_proveedor, codigo_barras, costo_unitario)
VALUES
    (1, 'PROD01', 19.50),
    (1, 'PROD02', 38.00),
    (1, 'PROD03', 24.00),
    (2, 'PROD06', 27.50),
    (2, 'PROD07', 18.00),
    (3, 'PROD04', 14.00),
    (3, 'PROD05', 32.00),
    (3, 'PROD10', 28.00),
    (3, 'PROD11', 11.00),
    (3, 'PROD12', 26.00),
    (4, 'PROD08', 25.00),
    (4, 'PROD09', 12.00);
PRINT '>> Relaciones de abastecimiento insertadas (12 registros).';
GO

-- 12. POBLADO DE PEDIDOS DE REABASTECIMIENTO
INSERT INTO dbo.pedido_reabastecimiento (id_proveedor, codigo_barras, id_empleado, fecha_pedido, cantidad_pedida)
VALUES
    (1, 'PROD01', 1, '2026-10-15', 50),
    (2, 'PROD06', 1, '2026-10-18', 40),
    (3, 'PROD12', 2, '2026-10-25', 30);
PRINT '>> Pedidos de reabastecimiento insertados (3 registros).';
GO

-- 13. POBLADO DE VENTAS (Encabezados de Transacción)
INSERT INTO dbo.venta (fecha_hora, metodo_pago, id_cajero, id_cliente, id_repartidor)
VALUES
    ('2026-10-28 09:15:00', 'EFECTIVO',      1, 5, NULL),  -- Folio 1: Mostrador contado
    ('2026-10-28 11:30:00', 'TARJETA',       1, 8, NULL),  -- Folio 2: Mostrador con tarjeta
    ('2026-10-28 14:20:00', 'CREDITO',       1, 6, 3),     -- Folio 3: Crédito con entrega a domicilio (Repartidor 3)
    ('2026-10-29 16:05:00', 'TRANSFERENCIA', 2, 7, NULL),  -- Folio 4: Turno vespertino
    ('2026-10-29 18:40:00', 'CREDITO',       2, 5, 4),     -- Folio 5: Crédito con reparto camioneta (Repartidor 4)
    ('2026-10-30 10:10:00', 'EFECTIVO',      1, NULL, NULL); -- Folio 6: Cliente anónimo mostrador
PRINT '>> Ventas transaccionales insertadas (6 registros).';
GO

-- 14. POBLADO DE DETALLE DE VENTA (Renglones)
INSERT INTO dbo.detalle_venta (folio, codigo_barras, cantidad, precio_unitario)
VALUES
    (1, 'PROD01', 2, 26.50),
    (1, 'PROD05', 1, 44.50),
    (1, 'PROD10', 1, 41.00),
    (2, 'PROD02', 1, 52.00),
    (2, 'PROD08', 2, 36.00),
    (3, 'PROD01', 4, 26.50),
    (3, 'PROD06', 3, 38.00),
    (3, 'PROD07', 2, 26.00),
    (4, 'PROD03', 2, 34.00),
    (4, 'PROD04', 4, 21.50),
    (5, 'PROD05', 2, 44.50),
    (5, 'PROD08', 3, 36.00),
    (5, 'PROD11', 5, 17.50),
    (6, 'PROD01', 1, 26.50),
    (6, 'PROD09', 2, 18.00);
PRINT '>> Líneas de detalle de venta insertadas (15 registros).';
GO

PRINT '=====================================================================';
PRINT '>> FASE 2 LMD/DML FINALIZADA CON ÉXITO: Base de datos poblada.';
PRINT '=====================================================================';
GO
