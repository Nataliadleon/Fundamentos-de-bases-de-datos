/* Datos de prueba y pruebas de restricciones - SQL Server */
USE TiendaAbarrotes;
GO

SET IDENTITY_INSERT dbo.persona ON;
INSERT INTO dbo.persona (id_persona, nombre_pila, apellido_paterno, apellido_materno, fecha_nacimiento) VALUES
    (1, N'María', N'López', N'García', '1990-03-15'),
    (2, N'Luis', N'Pérez', N'Ruiz', '1985-07-20'),
    (3, N'Jorge', N'Ramírez', NULL, '1995-11-02');
SET IDENTITY_INSERT dbo.persona OFF;
GO

INSERT INTO dbo.telefono_persona (id_persona, telefono) VALUES
    (1, '5512345678'),
    (1, '5598765432'),
    (2, '5511112222');
GO

INSERT INTO dbo.cliente (id_persona, limite_credito, fecha_registro) VALUES
    (1, 500.00, '2025-01-10');
GO

INSERT INTO dbo.empleado (id_persona, fecha_contratacion, salario, puesto) VALUES
    (2, '2023-02-01', 8000.00, 'CAJERO'),
    (3, '2024-05-15', 7000.00, 'REPARTIDOR');
GO

INSERT INTO dbo.cajero (id_persona, turno) VALUES
    (2, 'MATUTINO');
GO

INSERT INTO dbo.repartidor (id_persona, licencia, vehiculo) VALUES
    (3, 'LIC-12345', N'Motocicleta');
GO

SET IDENTITY_INSERT dbo.categoria ON;
INSERT INTO dbo.categoria (id_categoria, nombre_cat) VALUES
    (1, N'Bebidas'),
    (2, N'Abarrotes');
SET IDENTITY_INSERT dbo.categoria OFF;
GO

INSERT INTO dbo.producto (codigo_barras, nombre, costo_compra, precio_venta, stock_actual, stock_minimo, id_categoria) VALUES
    ('7501055300150', N'Refresco 600 ml', 10.00, 15.00, 20, 5, 1),
    ('7501000111222', N'Arroz 1 kg', 18.00, 25.00, 8, 10, 2),
    ('7501000333444', N'Frijol 1 kg', 22.00, 30.00, 12, 10, 2);
GO

SET IDENTITY_INSERT dbo.proveedor ON;
INSERT INTO dbo.proveedor (id_proveedor, razon_social, calle, numero, colonia, codigo_postal) VALUES
    (1, N'Distribuidora La Central', N'Av. Juárez', N'120', N'Centro', '06000');
SET IDENTITY_INSERT dbo.proveedor OFF;
GO

INSERT INTO dbo.telefono_proveedor (id_proveedor, telefono) VALUES
    (1, '5555550000');
GO

INSERT INTO dbo.abastecimiento (id_proveedor, codigo_barras, costo_unitario) VALUES
    (1, '7501055300150', 9.00),
    (1, '7501000111222', 16.50),
    (1, '7501000333444', 20.00);
GO

SET IDENTITY_INSERT dbo.pedido_reabastecimiento ON;
INSERT INTO dbo.pedido_reabastecimiento (id_pedido, id_proveedor, codigo_barras, id_empleado, fecha_pedido, cantidad_pedida) VALUES
    (1, 1, '7501000111222', 2, '2026-10-25', 50);
SET IDENTITY_INSERT dbo.pedido_reabastecimiento OFF;
GO

SET IDENTITY_INSERT dbo.venta ON;
INSERT INTO dbo.venta (folio, fecha_hora, metodo_pago, id_cajero, id_cliente, id_repartidor) VALUES
    (1, '2026-10-28 10:30:00', 'EFECTIVO', 2, NULL, NULL),
    (2, '2026-10-29 18:15:00', 'CREDITO', 2, 1, 3);
SET IDENTITY_INSERT dbo.venta OFF;
GO

INSERT INTO dbo.detalle_venta (folio, codigo_barras, cantidad, precio_unitario) VALUES
    (1, '7501055300150', 2, 15.00),
    (1, '7501000111222', 1, 25.00),
    (2, '7501000333444', 3, 30.00);
GO

-- ===== Consultas de verificación (atributos derivados) =====
SELECT * FROM dbo.v_venta_total;
SELECT * FROM dbo.v_detalle_subtotal;
SELECT * FROM dbo.v_producto_margen;
SELECT * FROM dbo.v_cliente_saldo_pendiente;
SELECT * FROM dbo.v_persona_edad;
SELECT * FROM dbo.v_empleado_antiguedad;
GO

-- ===== Pruebas de restricciones de integridad: todas deben ser RECHAZADAS =====
-- 1. Integridad de entidad: llave primaria duplicada
BEGIN TRY
    INSERT INTO dbo.categoria (id_categoria, nombre_cat) VALUES (1, N'Duplicada');
    PRINT 'ERROR: se aceptó una llave primaria duplicada';
END TRY
BEGIN CATCH
    PRINT '1. Rechazado (entidad): ' + ERROR_MESSAGE();
END CATCH;
GO
-- 2. Integridad referencial: cajero inexistente en la venta
BEGIN TRY
    INSERT INTO dbo.venta (fecha_hora, metodo_pago, id_cajero) VALUES ('2026-10-30 09:00:00', 'EFECTIVO', 99);
    PRINT 'ERROR: se aceptó una llave foránea inexistente';
END TRY
BEGIN CATCH
    PRINT '2. Rechazado (referencial): ' + ERROR_MESSAGE();
END CATCH;
GO
-- 3. Integridad referencial en jerarquía: cajero que no es empleado
BEGIN TRY
    INSERT INTO dbo.cajero (id_persona, turno) VALUES (1, 'MATUTINO');
    PRINT 'ERROR: se aceptó un cajero que no es empleado';
END TRY
BEGIN CATCH
    PRINT '3. Rechazado (jerarquía): ' + ERROR_MESSAGE();
END CATCH;
GO
-- 4. Integridad de dominio: cantidad igual a cero
BEGIN TRY
    INSERT INTO dbo.detalle_venta (folio, codigo_barras, cantidad, precio_unitario) VALUES (1, '7501000333444', 0, 30.00);
    PRINT 'ERROR: se aceptó una cantidad igual a cero';
END TRY
BEGIN CATCH
    PRINT '4. Rechazado (dominio): ' + ERROR_MESSAGE();
END CATCH;
GO
-- 5. Regla de negocio RN7: venta a crédito sin cliente
BEGIN TRY
    INSERT INTO dbo.venta (fecha_hora, metodo_pago, id_cajero) VALUES ('2026-10-30 09:00:00', 'CREDITO', 2);
    PRINT 'ERROR: se aceptó una venta a crédito sin cliente';
END TRY
BEGIN CATCH
    PRINT '5. Rechazado (regla de negocio): ' + ERROR_MESSAGE();
END CATCH;
GO