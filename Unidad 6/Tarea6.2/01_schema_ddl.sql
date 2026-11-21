/* =====================================================================
   01_schema_ddl.sql - Definición del Esquema Físico Relacional (LDD / DDL)
   Caso de Estudio: Tienda de Abarrotes de Barrio
   Materia : Fundamentos de Bases de Datos - Unidad 6 (Tarea 6.2)
   Alumna  : Gabriela Natalia De León Alvarez (I24050006)
   Motor   : Microsoft SQL Server (Transact-SQL)
   
   OBJETIVO:
   Crear la base de datos, tablas, claves primarias (PK), claves foráneas (FK),
   restricciones de integridad (CHECK, UNIQUE, DEFAULT) e índices de búsqueda
   para optimización de reuniones y consultas analíticas.
   ===================================================================== */

SET NOCOUNT ON;
GO

-- 1. CREACIÓN Y CONTEXTO DE LA BASE DE DATOS
IF DB_ID(N'TiendaAbarrotes_U6') IS NULL
BEGIN
    CREATE DATABASE TiendaAbarrotes_U6;
    PRINT '>> Base de datos TiendaAbarrotes_U6 creada exitosamente.';
END
ELSE
BEGIN
    PRINT '>> Base de datos TiendaAbarrotes_U6 ya existe.';
END
GO

USE TiendaAbarrotes_U6;
GO

-- 2. LIMPIEZA PREVENTIVA DE OBJETOS PREVIOS (ORDEN ESTRICTO DE INTEGRIDAD REFERENCIAL)
PRINT '>> Limpiando objetos previos si existen...';

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
   3. DEFINICIÓN DDL DE TABLAS Y RESTRICCIONES DE INTEGRIDAD
   ===================================================================== */

-- ---------------------------------------------------------------------
-- TABLA: PERSONA (Entidad Base General)
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
PRINT '>> Tabla [persona] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: TELEFONO_PERSONA (Atributo multivalorado 1FN)
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
PRINT '>> Tabla [telefono_persona] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: CLIENTE (Especialización 1:1 de PERSONA)
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
PRINT '>> Tabla [cliente] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: EMPLEADO (Especialización 1:1 de PERSONA)
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
PRINT '>> Tabla [empleado] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: CAJERO (Subtipo disjunto de EMPLEADO)
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
PRINT '>> Tabla [cajero] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: REPARTIDOR (Subtipo disjunto de EMPLEADO)
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
PRINT '>> Tabla [repartidor] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: CATEGORIA
-- ---------------------------------------------------------------------
CREATE TABLE dbo.categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_cat NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_categoria PRIMARY KEY CLUSTERED (id_categoria),
    CONSTRAINT UQ_categoria_nombre UNIQUE (nombre_cat)
);
PRINT '>> Tabla [categoria] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: PRODUCTO
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
PRINT '>> Tabla [producto] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: PROVEEDOR
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
PRINT '>> Tabla [proveedor] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: TELEFONO_PROVEEDOR
-- ---------------------------------------------------------------------
CREATE TABLE dbo.telefono_proveedor (
    id_proveedor INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT PK_telefono_proveedor PRIMARY KEY CLUSTERED (id_proveedor, telefono),
    CONSTRAINT FK_telefono_proveedor_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedor (id_proveedor)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
PRINT '>> Tabla [telefono_proveedor] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: ABASTECIMIENTO (Relación M:N Proveedor - Producto)
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
PRINT '>> Tabla [abastecimiento] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: PEDIDO_REABASTECIMIENTO
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
PRINT '>> Tabla [pedido_reabastecimiento] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: VENTA (Encabezado Transaccional)
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
PRINT '>> Tabla [venta] creada.';
GO

-- ---------------------------------------------------------------------
-- TABLA: DETALLE_VENTA (Líneas de transacción M:N Venta - Producto)
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
PRINT '>> Tabla [detalle_venta] creada.';
GO

/* =====================================================================
   4. ÍNDICES NO CLUSTERIZADOS PARA RENDIMIENTO DE CLAVES FORÁNEAS
   ===================================================================== */
CREATE NONCLUSTERED INDEX IX_producto_categoria ON dbo.producto (id_categoria);
CREATE NONCLUSTERED INDEX IX_venta_cajero ON dbo.venta (id_cajero);
CREATE NONCLUSTERED INDEX IX_venta_cliente ON dbo.venta (id_cliente);
CREATE NONCLUSTERED INDEX IX_venta_repartidor ON dbo.venta (id_repartidor);
CREATE NONCLUSTERED INDEX IX_detalle_producto ON dbo.detalle_venta (codigo_barras);
CREATE NONCLUSTERED INDEX IX_abastecimiento_producto ON dbo.abastecimiento (codigo_barras);
CREATE NONCLUSTERED INDEX IX_pedido_empleado ON dbo.pedido_reabastecimiento (id_empleado);
PRINT '>> Índices de optimización de claves foráneas creados exitosamente.';
GO

PRINT '=====================================================================';
PRINT '>> FASE 1 DDL FINALIZADA CON ÉXITO: Base de datos y tablas listas.';
PRINT '=====================================================================';
GO
