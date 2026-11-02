/* =====================================================================
   schema_normalizado.sql - Esquema Físico Totalmente Normalizado (3FN / FNBC)
   Caso de Estudio: Tienda de Abarrotes de Barrio
   Materia : Fundamentos de Bases de Datos - Unidad 4 (Tarea 4.2)
   Alumna  : Gabriela Natalia De León Alvarez (I24050006)
   Motor   : Microsoft SQL Server (T-SQL)
   
   OBJETIVO:
   Implementar el esquema relacional resultante del proceso de normalización
   (de 0FN a 3FN/FNBC), garantizando la eliminación de grupos repetitivos,
   atomicidad, eliminación de dependencias parciales y transitivas, e
   integridad referencial estricta.
   ===================================================================== */

SET NOCOUNT ON;
GO

-- 1. CREACIÓN Y SELECCIÓN DE LA BASE DE DATOS
IF DB_ID(N'TiendaAbarrotesNormalizada') IS NULL
BEGIN
    CREATE DATABASE TiendaAbarrotesNormalizada;
END
GO

USE TiendaAbarrotesNormalizada;
GO

-- 2. LIMPIEZA DE OBJETOS PREVIOS (ORDEN INVERSO DE DEPENDENCIAS)
DROP VIEW IF EXISTS dbo.v_cliente_saldo_pendiente;
DROP VIEW IF EXISTS dbo.v_venta_resumen_total;
DROP VIEW IF EXISTS dbo.v_detalle_venta_subtotal;
DROP VIEW IF EXISTS dbo.v_producto_margen;
DROP VIEW IF EXISTS dbo.v_persona_edad;
DROP VIEW IF EXISTS dbo.v_empleado_antiguedad;
GO

DROP TABLE IF EXISTS dbo.detalle_venta;
DROP TABLE IF EXISTS dbo.venta;
DROP TABLE IF EXISTS dbo.pedido_reabastecimiento;
DROP TABLE IF EXISTS dbo.abastecimiento;
DROP TABLE IF EXISTS dbo.telefono_proveedor;
DROP TABLE IF EXISTS dbo.proveedor;
DROP TABLE IF EXISTS dbo.producto;
DROP TABLE IF EXISTS dbo.categoria;
DROP TABLE IF EXISTS dbo.repartidor;
DROP TABLE IF EXISTS dbo.cajero;
DROP TABLE IF EXISTS dbo.empleado;
DROP TABLE IF EXISTS dbo.cliente;
DROP TABLE IF EXISTS dbo.telefono_persona;
DROP TABLE IF EXISTS dbo.persona;
GO

/* =====================================================================
   3. DEFINICIÓN DE TABLAS NORMALIZADAS (3FN / FNBC)
   ===================================================================== */

-- ---------------------------------------------------------------------
-- TABLA: PERSONA
-- Normalización:
-- 1FN: Nombres atómicos descompuestos (nombre_pila, paterno, materno).
-- 2FN y 3FN: Entidad base con dependencia funcional directa id_persona -> atributos.
-- FNBC: id_persona es superclave determinante.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.persona (
    id_persona INT IDENTITY(1,1) NOT NULL,
    nombre_pila NVARCHAR(50) NOT NULL,
    apellido_paterno NVARCHAR(50) NOT NULL,
    apellido_materno NVARCHAR(50) NULL,
    fecha_nacimiento DATE NOT NULL,
    CONSTRAINT PK_persona PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT CK_persona_fecha_nac CHECK (fecha_nacimiento <= CAST(GETDATE() AS DATE))
);
GO

-- ---------------------------------------------------------------------
-- TABLA: TELEFONO_PERSONA
-- Normalización:
-- 1FN: Desacopla el atributo multivalorado (teléfono) fuera de PERSONA.
-- 2FN y 3FN: Llave compuesta {id_persona, telefono} sin dependencias parciales ni transitivas.
-- FNBC: Cumple FNBC.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.telefono_persona (
    id_persona INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT PK_telefono_persona PRIMARY KEY CLUSTERED (id_persona, telefono),
    CONSTRAINT FK_telefono_persona_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_telefono_persona_formato CHECK (LEN(telefono) >= 10)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: CLIENTE (Subclase de PERSONA)
-- Normalización:
-- 3FN: Elimina transitividad de datos de crédito asociados a ventas directas.
-- FNBC: id_persona es clave primaria y foránea 1:1 hacia PERSONA.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.cliente (
    id_persona INT NOT NULL,
    limite_credito DECIMAL(10,2) NOT NULL CONSTRAINT DF_cliente_limite DEFAULT 0.00,
    fecha_registro DATE NOT NULL CONSTRAINT DF_cliente_fecha DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_cliente PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_cliente_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_cliente_limite_positivo CHECK (limite_credito >= 0.00)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: EMPLEADO (Subclase de PERSONA)
-- Normalización:
-- 3FN: Desacopla salarios y datos contractuales de las transacciones de venta.
-- FNBC: id_persona es superclave determinante.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.empleado (
    id_persona INT NOT NULL,
    fecha_contratacion DATE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    puesto VARCHAR(10) NOT NULL,
    CONSTRAINT PK_empleado PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_empleado_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_empleado_salario CHECK (salario > 0.00),
    CONSTRAINT CK_empleado_puesto CHECK (puesto IN ('CAJERO', 'REPARTIDOR'))
);
GO

-- ---------------------------------------------------------------------
-- TABLA: CAJERO (Especialización disjunta de EMPLEADO)
-- Normalización:
-- 3FN: El turno depende de la asignación del cajero, no de cada venta atendida.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.cajero (
    id_persona INT NOT NULL,
    turno VARCHAR(10) NOT NULL,
    CONSTRAINT PK_cajero PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT FK_cajero_empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_cajero_turno CHECK (turno IN ('MATUTINO', 'VESPERTINO'))
);
GO

-- ---------------------------------------------------------------------
-- TABLA: REPARTIDOR (Especialización disjunta de EMPLEADO)
-- Normalización:
-- FNBC: id_persona es PK; licencia es UNIQUE (ambos determinantes son superclaves).
-- ---------------------------------------------------------------------
CREATE TABLE dbo.repartidor (
    id_persona INT NOT NULL,
    licencia VARCHAR(20) NOT NULL,
    vehiculo NVARCHAR(30) NULL,
    CONSTRAINT PK_repartidor PRIMARY KEY CLUSTERED (id_persona),
    CONSTRAINT UQ_repartidor_licencia UNIQUE (licencia),
    CONSTRAINT FK_repartidor_empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
GO

-- ---------------------------------------------------------------------
-- TABLA: CATEGORIA
-- Normalización:
-- 3FN: Elimina la dependencia transitiva Codigo_Barras -> ID_Categoria -> Nombre_Cat.
-- FNBC: id_categoria es PK; nombre_cat es UNIQUE.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_cat NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_categoria PRIMARY KEY CLUSTERED (id_categoria),
    CONSTRAINT UQ_categoria_nombre UNIQUE (nombre_cat)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: PRODUCTO
-- Normalización:
-- 2FN: Desacoplado de la transacción de venta (dependía parcialmente de la clave de venta).
-- 3FN: Almacena únicamente id_categoria (FK), eliminando redundancia textual.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.producto (
    codigo_barras VARCHAR(20) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    costo_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL CONSTRAINT DF_producto_stock_act DEFAULT 0,
    stock_minimo INT NOT NULL CONSTRAINT DF_producto_stock_min DEFAULT 0,
    id_categoria INT NOT NULL,
    CONSTRAINT PK_producto PRIMARY KEY CLUSTERED (codigo_barras),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES dbo.categoria (id_categoria)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_producto_costo CHECK (costo_compra >= 0.00),
    CONSTRAINT CK_producto_precio CHECK (precio_venta >= costo_compra),
    CONSTRAINT CK_producto_stock_act CHECK (stock_actual >= 0),
    CONSTRAINT CK_producto_stock_min CHECK (stock_minimo >= 0)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: PROVEEDOR
-- Normalización:
-- 1FN: Dirección atómica separada por componentes (calle, numero, colonia, cp).
-- ---------------------------------------------------------------------
CREATE TABLE dbo.proveedor (
    id_proveedor INT IDENTITY(1,1) NOT NULL,
    razon_social NVARCHAR(100) NOT NULL,
    calle NVARCHAR(80) NULL,
    numero NVARCHAR(10) NULL,
    colonia NVARCHAR(60) NULL,
    codigo_postal CHAR(5) NULL,
    CONSTRAINT PK_proveedor PRIMARY KEY CLUSTERED (id_proveedor)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: TELEFONO_PROVEEDOR
-- Normalización:
-- 1FN: Multivalorado desacoplado en entidad dependiente.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.telefono_proveedor (
    id_proveedor INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT PK_telefono_proveedor PRIMARY KEY CLUSTERED (id_proveedor, telefono),
    CONSTRAINT FK_telefono_proveedor_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedor (id_proveedor)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
GO

-- ---------------------------------------------------------------------
-- TABLA: ABASTECIMIENTO (Relación M:N Proveedor - Producto)
-- Normalización:
-- 2FN y 3FN: costo_unitario depende estrictamente del par {id_proveedor, codigo_barras}.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.abastecimiento (
    id_proveedor INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_abastecimiento PRIMARY KEY CLUSTERED (id_proveedor, codigo_barras),
    CONSTRAINT FK_abastecimiento_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedor (id_proveedor)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_abastecimiento_producto FOREIGN KEY (codigo_barras)
        REFERENCES dbo.producto (codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_abastecimiento_costo CHECK (costo_unitario >= 0.00)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: PEDIDO_REABASTECIMIENTO (Agregación Abastecimiento + Empleado)
-- Normalización:
-- 3FN: id_pedido es la PK atómica; dependencias externas modeladas con claves foráneas.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.pedido_reabastecimiento (
    id_pedido INT IDENTITY(1,1) NOT NULL,
    id_proveedor INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    id_empleado INT NOT NULL,
    fecha_pedido DATE NOT NULL CONSTRAINT DF_pedido_fecha DEFAULT CAST(GETDATE() AS DATE),
    cantidad_pedida INT NOT NULL,
    CONSTRAINT PK_pedido_reabastecimiento PRIMARY KEY CLUSTERED (id_pedido),
    CONSTRAINT FK_pedido_abastecimiento FOREIGN KEY (id_proveedor, codigo_barras)
        REFERENCES dbo.abastecimiento (id_proveedor, codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_pedido_empleado FOREIGN KEY (id_empleado)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_pedido_cantidad CHECK (cantidad_pedida > 0)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: VENTA (Encabezado de la transacción)
-- Normalización:
-- 2FN: Aislada de las líneas repetitivas de productos adquiridos.
-- 3FN: Solo guarda claves foráneas a cajero, cliente y repartidor (elimina transitividad de datos personales).
-- ---------------------------------------------------------------------
CREATE TABLE dbo.venta (
    folio INT IDENTITY(1,1) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL CONSTRAINT DF_venta_fecha DEFAULT SYSDATETIME(),
    metodo_pago VARCHAR(13) NOT NULL CONSTRAINT DF_venta_metodo DEFAULT 'EFECTIVO',
    id_cajero INT NOT NULL,
    id_cliente INT NULL,
    id_repartidor INT NULL,
    CONSTRAINT PK_venta PRIMARY KEY CLUSTERED (folio),
    CONSTRAINT FK_venta_cajero FOREIGN KEY (id_cajero)
        REFERENCES dbo.cajero (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES dbo.cliente (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_venta_repartidor FOREIGN KEY (id_repartidor)
        REFERENCES dbo.repartidor (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_venta_metodo CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'CREDITO')),
    CONSTRAINT CK_venta_credito_cliente CHECK (metodo_pago <> 'CREDITO' OR id_cliente IS NOT NULL)
);
GO

-- ---------------------------------------------------------------------
-- TABLA: DETALLE_VENTA (Relación M:N Venta - Producto)
-- Normalización:
-- 1FN: Renglones individuales eliminan grupos repetitivos.
-- 2FN: Dependencia funcional completa {folio, codigo_barras} -> {cantidad, precio_unitario}.
-- 3FN / FNBC: Determinante {folio, codigo_barras} es superclave compuesta.
-- ---------------------------------------------------------------------
CREATE TABLE dbo.detalle_venta (
    folio INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_detalle_venta PRIMARY KEY CLUSTERED (folio, codigo_barras),
    CONSTRAINT FK_detalle_venta_venta FOREIGN KEY (folio)
        REFERENCES dbo.venta (folio)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_detalle_venta_producto FOREIGN KEY (codigo_barras)
        REFERENCES dbo.producto (codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_detalle_venta_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_detalle_venta_precio CHECK (precio_unitario >= 0.00)
);
GO

/* =====================================================================
   4. ÍNDICES PARA OPTIMIZACIÓN (LLAVES FORÁNEAS)
   ===================================================================== */
CREATE NONCLUSTERED INDEX IX_producto_categoria ON dbo.producto (id_categoria);
CREATE NONCLUSTERED INDEX IX_venta_cajero ON dbo.venta (id_cajero);
CREATE NONCLUSTERED INDEX IX_venta_cliente ON dbo.venta (id_cliente);
CREATE NONCLUSTERED INDEX IX_venta_repartidor ON dbo.venta (id_repartidor);
CREATE NONCLUSTERED INDEX IX_detalle_producto ON dbo.detalle_venta (codigo_barras);
CREATE NONCLUSTERED INDEX IX_abastecimiento_producto ON dbo.abastecimiento (codigo_barras);
CREATE NONCLUSTERED INDEX IX_pedido_empleado ON dbo.pedido_reabastecimiento (id_empleado);
GO

/* =====================================================================
   5. VISTAS NORMALIZADAS (CÁLCULO DINÁMICO DE ATRIBUTOS DERIVADOS)
   Eliminan la redundancia física cumpliendo el rigor de 3FN.
   ===================================================================== */

-- Subtotal dinámico por renglón
CREATE OR ALTER VIEW dbo.v_detalle_venta_subtotal AS
SELECT 
    d.folio,
    d.codigo_barras,
    p.nombre AS producto,
    d.cantidad,
    d.precio_unitario,
    CAST(d.cantidad * d.precio_unitario AS DECIMAL(12,2)) AS subtotal
FROM dbo.detalle_venta d
INNER JOIN dbo.producto p ON d.codigo_barras = p.codigo_barras;
GO

-- Total general dinámico de cada venta
CREATE OR ALTER VIEW dbo.v_venta_resumen_total AS
SELECT 
    v.folio,
    v.fecha_hora,
    v.metodo_pago,
    CONCAT(per_caj.nombre_pila, ' ', per_caj.apellido_paterno) AS cajero,
    CONCAT(per_cli.nombre_pila, ' ', per_cli.apellido_paterno) AS cliente,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0.00) AS total_venta
FROM dbo.venta v
INNER JOIN dbo.cajero c ON v.id_cajero = c.id_persona
INNER JOIN dbo.persona per_caj ON c.id_persona = per_caj.id_persona
LEFT JOIN dbo.cliente cli ON v.id_cliente = cli.id_persona
LEFT JOIN dbo.persona per_cli ON cli.id_persona = per_cli.id_persona
LEFT JOIN dbo.detalle_venta d ON v.folio = d.folio
GROUP BY 
    v.folio, v.fecha_hora, v.metodo_pago,
    per_caj.nombre_pila, per_caj.apellido_paterno,
    per_cli.nombre_pila, per_cli.apellido_paterno;
GO

-- Saldo pendiente dinámico de clientes con compras a crédito
CREATE OR ALTER VIEW dbo.v_cliente_saldo_pendiente AS
SELECT 
    c.id_persona AS id_cliente,
    CONCAT(p.nombre_pila, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_cliente,
    c.limite_credito,
    COALESCE(SUM(d.cantidad * d.precio_unitario), 0.00) AS total_comprado_credito,
    c.limite_credito - COALESCE(SUM(d.cantidad * d.precio_unitario), 0.00) AS credito_disponible
FROM dbo.cliente c
INNER JOIN dbo.persona p ON c.id_persona = p.id_persona
LEFT JOIN dbo.venta v ON v.id_cliente = c.id_persona AND v.metodo_pago = 'CREDITO'
LEFT JOIN dbo.detalle_venta d ON v.folio = d.folio
GROUP BY c.id_persona, p.nombre_pila, p.apellido_paterno, p.apellido_materno, c.limite_credito;
GO

/* =====================================================================
   6. CARGA DE DATOS DE PRUEBA Y VALIDACIÓN DE FORMAS NORMALES
   ===================================================================== */
-- Inserción de Categorías (3FN)
INSERT INTO dbo.categoria (nombre_cat) VALUES (N'Lácteos'), (N'Abarrotes'), (N'Granos y Semillas');

-- Inserción de Personas (1FN - nombres atómicos)
INSERT INTO dbo.persona (nombre_pila, apellido_paterno, apellido_materno, fecha_nacimiento)
VALUES 
(N'Mario', N'Casas', N'Cruz', '1995-04-12'),           -- ID 1: Cajero
(N'Roberto', N'Gómez', N'Luna', '1998-08-23'),         -- ID 2: Repartidor
(N'Laura Elena', N'Méndez', N'Silva', '2001-01-30'),   -- ID 3: Cajera
(N'Juan Carlos', N'Pérez', N'López', '1988-11-05'),    -- ID 4: Cliente
(N'Ana Luisa', N'Silva', N'Romero', '1992-07-19');     -- ID 5: Cliente

-- Inserción de Teléfonos (1FN - multivalorado descompuesto)
INSERT INTO dbo.telefono_persona (id_persona, telefono)
VALUES 
(4, '5512345678'),
(4, '5587654321'),
(5, '5544332211');

-- Inserción de Clientes
INSERT INTO dbo.cliente (id_persona, limite_credito)
VALUES 
(4, 1500.00),
(5, 2000.00);

-- Inserción de Empleados
INSERT INTO dbo.empleado (id_persona, fecha_contratacion, salario, puesto)
VALUES 
(1, '2023-01-15', 8500.00, 'CAJERO'),
(2, '2023-05-10', 8000.00, 'REPARTIDOR'),
(3, '2024-02-01', 8500.00, 'CAJERO');

-- Inserción de Cajeros
INSERT INTO dbo.cajero (id_persona, turno)
VALUES 
(1, 'MATUTINO'),
(3, 'VESPERTINO');

-- Inserción de Repartidores
INSERT INTO dbo.repartidor (id_persona, licencia, vehiculo)
VALUES 
(2, 'LIC-CDMX-998877', N'Motocicleta Honda 125');

-- Inserción de Productos (2FN y 3FN)
INSERT INTO dbo.producto (codigo_barras, nombre, costo_compra, precio_venta, stock_actual, stock_minimo, id_categoria)
VALUES 
('PROD01', N'Leche Entera 1L', 18.00, 24.50, 45, 10, 1),
('PROD02', N'Pan Integral 680g', 22.00, 32.00, 30, 8, 2),
('PROD03', N'Frijol Negro 1kg', 28.00, 38.00, 50, 15, 3);

-- Inserción de Ventas (3FN)
INSERT INTO dbo.venta (fecha_hora, metodo_pago, id_cajero, id_cliente, id_repartidor)
VALUES 
('2026-10-30T09:15:00', 'EFECTIVO', 1, 4, NULL),
('2026-10-30T10:30:00', 'CREDITO', 1, 5, 2),
('2026-10-30T16:45:00', 'TARJETA', 3, NULL, NULL);

-- Inserción de Líneas de Detalle de Venta (1FN y 2FN)
INSERT INTO dbo.detalle_venta (folio, codigo_barras, cantidad, precio_unitario)
VALUES 
(1, 'PROD01', 2, 24.50),
(1, 'PROD02', 1, 32.00),
(2, 'PROD01', 4, 24.50),
(3, 'PROD03', 2, 38.00);
GO

/* =====================================================================
   7. CONSULTA DE DEMOSTRACIÓN DEL ESQUEMA NORMALIZADO
   ===================================================================== */
PRINT N'=== COMPROBACIÓN DE VENTA NORMALIZADA (FOLIOS Y TOTALES) ===';
SELECT * FROM dbo.v_venta_resumen_total;

PRINT N'=== COMPROBACIÓN DE DETALLE CON SUBTOTALES CALCULADOS ===';
SELECT * FROM dbo.v_detalle_venta_subtotal;

PRINT N'=== COMPROBACIÓN DE SALDOS PENDIENTES DE CRÉDITO ===';
SELECT * FROM dbo.v_cliente_saldo_pendiente;
GO

