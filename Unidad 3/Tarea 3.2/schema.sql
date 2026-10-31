/* =====================================================================
   schema.sql - Esquema físico: tienda de abarrotes de barrio
   Tarea 3.2 - Generación del esquema físico en SGBD (script LDD)
   Alumna: Gabriela Natalia De León Alvarez (I24050006)
   Motor : Microsoft SQL Server 2016 SP1 o superior (T-SQL)
   Uso   : ejecutar completo en SSMS o Azure Data Studio.
           Es re-ejecutable: borra y vuelve a crear los objetos (sección 1).
   Contenido: 1 Limpieza | 2 Tablas | 3 Índices | 4 Vistas | 5 Descripciones
   ===================================================================== */
SET NOCOUNT ON;
GO

IF DB_ID(N'TiendaAbarrotes') IS NULL CREATE DATABASE TiendaAbarrotes;
GO
USE TiendaAbarrotes;
GO

/* ---------- 1. LIMPIEZA (permite ejecutar el script varias veces) ---------- */
DROP VIEW IF EXISTS dbo.v_empleado_antiguedad;
DROP VIEW IF EXISTS dbo.v_persona_edad;
DROP VIEW IF EXISTS dbo.v_cliente_saldo_pendiente;
DROP VIEW IF EXISTS dbo.v_producto_margen;
DROP VIEW IF EXISTS dbo.v_venta_total;
DROP VIEW IF EXISTS dbo.v_detalle_subtotal;
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

/* ---------- 2. TABLAS (orden: primero las tablas padre) ---------- */

-- PERSONA: Entidad PERSONA (superclase)
CREATE TABLE dbo.persona (
    id_persona INT IDENTITY(1,1) NOT NULL,
    nombre_pila NVARCHAR(50) NOT NULL,
    apellido_paterno NVARCHAR(50) NOT NULL,
    apellido_materno NVARCHAR(50) NULL,
    fecha_nacimiento DATE NOT NULL,
    CONSTRAINT PK_persona PRIMARY KEY (id_persona)
);
GO

-- TELEFONO_PERSONA: Atributo multivalorado teléfono de PERSONA
CREATE TABLE dbo.telefono_persona (
    id_persona INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT PK_telefono_persona PRIMARY KEY (id_persona, telefono),
    CONSTRAINT FK_telefono_persona_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
GO

-- CLIENTE: Especialización CLIENTE
CREATE TABLE dbo.cliente (
    id_persona INT NOT NULL,
    limite_credito DECIMAL(10,2) NOT NULL CONSTRAINT DF_cliente_limite_credito DEFAULT 0,
    fecha_registro DATE NOT NULL CONSTRAINT DF_cliente_fecha_registro DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_cliente PRIMARY KEY (id_persona),
    CONSTRAINT FK_cliente_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_cliente_1 CHECK (limite_credito >= 0)
);
GO

-- EMPLEADO: Especialización EMPLEADO
CREATE TABLE dbo.empleado (
    id_persona INT NOT NULL,
    fecha_contratacion DATE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    puesto VARCHAR(10) NOT NULL,
    CONSTRAINT PK_empleado PRIMARY KEY (id_persona),
    CONSTRAINT FK_empleado_persona FOREIGN KEY (id_persona)
        REFERENCES dbo.persona (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_empleado_1 CHECK (salario > 0),
    CONSTRAINT CK_empleado_2 CHECK (puesto IN ('CAJERO','REPARTIDOR'))
);
GO

-- CAJERO: Especialización CAJERO
CREATE TABLE dbo.cajero (
    id_persona INT NOT NULL,
    turno VARCHAR(10) NOT NULL,
    CONSTRAINT PK_cajero PRIMARY KEY (id_persona),
    CONSTRAINT FK_cajero_empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT CK_cajero_1 CHECK (turno IN ('MATUTINO','VESPERTINO'))
);
GO

-- REPARTIDOR: Especialización REPARTIDOR
CREATE TABLE dbo.repartidor (
    id_persona INT NOT NULL,
    licencia VARCHAR(20) NOT NULL,
    vehiculo NVARCHAR(30) NULL,
    CONSTRAINT PK_repartidor PRIMARY KEY (id_persona),
    CONSTRAINT UQ_repartidor_licencia UNIQUE (licencia),
    CONSTRAINT FK_repartidor_empleado FOREIGN KEY (id_persona)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
GO

-- CATEGORIA: Entidad CATEGORIA
CREATE TABLE dbo.categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_cat NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_categoria_nombre_cat UNIQUE (nombre_cat)
);
GO

-- PRODUCTO: Entidad PRODUCTO + relación pertenece a (N:1)
CREATE TABLE dbo.producto (
    codigo_barras VARCHAR(20) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    costo_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL CONSTRAINT DF_producto_stock_actual DEFAULT 0,
    stock_minimo INT NOT NULL CONSTRAINT DF_producto_stock_minimo DEFAULT 0,
    id_categoria INT NOT NULL,
    CONSTRAINT PK_producto PRIMARY KEY (codigo_barras),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES dbo.categoria (id_categoria)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_producto_1 CHECK (costo_compra >= 0),
    CONSTRAINT CK_producto_2 CHECK (precio_venta >= 0),
    CONSTRAINT CK_producto_3 CHECK (stock_actual >= 0),
    CONSTRAINT CK_producto_4 CHECK (stock_minimo >= 0)
);
GO

-- PROVEEDOR: Entidad PROVEEDOR (dirección compuesta aplanada)
CREATE TABLE dbo.proveedor (
    id_proveedor INT IDENTITY(1,1) NOT NULL,
    razon_social NVARCHAR(100) NOT NULL,
    calle NVARCHAR(80) NULL,
    numero NVARCHAR(10) NULL,
    colonia NVARCHAR(60) NULL,
    codigo_postal CHAR(5) NULL,
    CONSTRAINT PK_proveedor PRIMARY KEY (id_proveedor)
);
GO

-- TELEFONO_PROVEEDOR: Atributo multivalorado teléfono de PROVEEDOR
CREATE TABLE dbo.telefono_proveedor (
    id_proveedor INT NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT PK_telefono_proveedor PRIMARY KEY (id_proveedor, telefono),
    CONSTRAINT FK_telefono_proveedor_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedor (id_proveedor)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
GO

-- ABASTECIMIENTO: Relación suministra (N:M) = agregación ABASTECIMIENTO
CREATE TABLE dbo.abastecimiento (
    id_proveedor INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_abastecimiento PRIMARY KEY (id_proveedor, codigo_barras),
    CONSTRAINT FK_abastecimiento_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedor (id_proveedor)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_abastecimiento_producto FOREIGN KEY (codigo_barras)
        REFERENCES dbo.producto (codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_abastecimiento_1 CHECK (costo_unitario >= 0)
);
GO

-- PEDIDO_REABASTECIMIENTO: Relación autoriza (EMPLEADO – agregación ABASTECIMIENTO)
CREATE TABLE dbo.pedido_reabastecimiento (
    id_pedido INT IDENTITY(1,1) NOT NULL,
    id_proveedor INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    id_empleado INT NOT NULL,
    fecha_pedido DATE NOT NULL CONSTRAINT DF_pedido_reabastecimiento_fecha_pedido DEFAULT CAST(GETDATE() AS DATE),
    cantidad_pedida INT NOT NULL,
    CONSTRAINT PK_pedido_reabastecimiento PRIMARY KEY (id_pedido),
    CONSTRAINT FK_pedido_reabastecimiento_abastecimiento FOREIGN KEY (id_proveedor, codigo_barras)
        REFERENCES dbo.abastecimiento (id_proveedor, codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_pedido_reabastecimiento_empleado FOREIGN KEY (id_empleado)
        REFERENCES dbo.empleado (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_pedido_reabastecimiento_1 CHECK (cantidad_pedida > 0)
);
GO

-- VENTA: Entidad VENTA + relaciones atiende, realiza y entrega (1:N)
CREATE TABLE dbo.venta (
    folio INT IDENTITY(1,1) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL CONSTRAINT DF_venta_fecha_hora DEFAULT SYSDATETIME(),
    metodo_pago VARCHAR(13) NOT NULL CONSTRAINT DF_venta_metodo_pago DEFAULT 'EFECTIVO',
    id_cajero INT NOT NULL,
    id_cliente INT NULL,
    id_repartidor INT NULL,
    CONSTRAINT PK_venta PRIMARY KEY (folio),
    CONSTRAINT FK_venta_cajero FOREIGN KEY (id_cajero)
        REFERENCES dbo.cajero (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES dbo.cliente (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_venta_repartidor FOREIGN KEY (id_repartidor)
        REFERENCES dbo.repartidor (id_persona)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_venta_1 CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA','CREDITO')),
    CONSTRAINT CK_venta_2 CHECK (metodo_pago <> 'CREDITO' OR id_cliente IS NOT NULL)
);
GO

-- DETALLE_VENTA: Relación incluye (N:M)
CREATE TABLE dbo.detalle_venta (
    folio INT NOT NULL,
    codigo_barras VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_detalle_venta PRIMARY KEY (folio, codigo_barras),
    CONSTRAINT FK_detalle_venta_venta FOREIGN KEY (folio)
        REFERENCES dbo.venta (folio)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT FK_detalle_venta_producto FOREIGN KEY (codigo_barras)
        REFERENCES dbo.producto (codigo_barras)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CK_detalle_venta_1 CHECK (cantidad > 0),
    CONSTRAINT CK_detalle_venta_2 CHECK (precio_unitario >= 0)
);
GO

/* ---------- 3. ÍNDICES (SQL Server no indexa las llaves foráneas automáticamente) ---------- */
CREATE NONCLUSTERED INDEX IX_persona_nombre ON dbo.persona (apellido_paterno, nombre_pila);
CREATE NONCLUSTERED INDEX IX_producto_id_categoria ON dbo.producto (id_categoria);
CREATE NONCLUSTERED INDEX IX_abastecimiento_codigo_barras ON dbo.abastecimiento (codigo_barras);
CREATE NONCLUSTERED INDEX IX_pedido_abastecimiento ON dbo.pedido_reabastecimiento (id_proveedor, codigo_barras);
CREATE NONCLUSTERED INDEX IX_pedido_id_empleado ON dbo.pedido_reabastecimiento (id_empleado);
CREATE NONCLUSTERED INDEX IX_venta_id_cajero ON dbo.venta (id_cajero);
CREATE NONCLUSTERED INDEX IX_venta_id_cliente ON dbo.venta (id_cliente);
CREATE NONCLUSTERED INDEX IX_venta_id_repartidor ON dbo.venta (id_repartidor);
CREATE NONCLUSTERED INDEX IX_venta_fecha_hora ON dbo.venta (fecha_hora);
CREATE NONCLUSTERED INDEX IX_detalle_venta_codigo_barras ON dbo.detalle_venta (codigo_barras);
GO

/* ---------- 4. VISTAS (atributos derivados) ---------- */
CREATE OR ALTER VIEW dbo.v_detalle_subtotal AS
SELECT folio, codigo_barras, cantidad * precio_unitario AS subtotal
FROM dbo.detalle_venta;
GO

CREATE OR ALTER VIEW dbo.v_venta_total AS
SELECT v.folio, COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total
FROM dbo.venta v
LEFT JOIN dbo.detalle_venta d ON d.folio = v.folio
GROUP BY v.folio;
GO

CREATE OR ALTER VIEW dbo.v_producto_margen AS
SELECT codigo_barras, precio_venta - costo_compra AS margen
FROM dbo.producto;
GO

CREATE OR ALTER VIEW dbo.v_cliente_saldo_pendiente AS
SELECT c.id_persona,
       COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS saldo_pendiente
FROM dbo.cliente c
LEFT JOIN dbo.venta v ON v.id_cliente = c.id_persona AND v.metodo_pago = 'CREDITO'
LEFT JOIN dbo.detalle_venta d ON d.folio = v.folio
GROUP BY c.id_persona;
GO

CREATE OR ALTER VIEW dbo.v_persona_edad AS
SELECT id_persona,
       DATEDIFF(YEAR, fecha_nacimiento, GETDATE())
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, fecha_nacimiento, GETDATE()), fecha_nacimiento) > CAST(GETDATE() AS DATE)
              THEN 1 ELSE 0 END AS edad
FROM dbo.persona;
GO

CREATE OR ALTER VIEW dbo.v_empleado_antiguedad AS
SELECT id_persona,
       DATEDIFF(YEAR, fecha_contratacion, GETDATE())
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, fecha_contratacion, GETDATE()), fecha_contratacion) > CAST(GETDATE() AS DATE)
              THEN 1 ELSE 0 END AS antiguedad
FROM dbo.empleado;
GO

/* ---------- 5. DESCRIPCIONES (diccionario de datos dentro de la base) ---------- */
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Entidad PERSONA (superclase)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la persona (llave sustituta autoincremental)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre o nombres de pila',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'nombre_pila';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Apellido paterno',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'apellido_paterno';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Apellido materno (opcional)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'apellido_materno';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de nacimiento; base para calcular la edad',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'persona', @level2type = N'COLUMN', @level2name = N'fecha_nacimiento';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Atributo multivalorado teléfono de PERSONA',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Persona dueña del teléfono',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_persona', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Número telefónico de contacto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_persona', @level2type = N'COLUMN', @level2name = N'telefono';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Especialización CLIENTE',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cliente';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Persona que es cliente (PK y FK hacia PERSONA)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cliente', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Monto máximo que el cliente puede deber (fiado)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cliente', @level2type = N'COLUMN', @level2name = N'limite_credito';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de alta como cliente',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cliente', @level2type = N'COLUMN', @level2name = N'fecha_registro';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Especialización EMPLEADO',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'empleado';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Persona que es empleado (PK y FK hacia PERSONA)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'empleado', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de contratación; base de la antigüedad',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'empleado', @level2type = N'COLUMN', @level2name = N'fecha_contratacion';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Salario mensual del empleado',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'empleado', @level2type = N'COLUMN', @level2name = N'salario';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Discriminante de la especialización: CAJERO o REPARTIDOR',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'empleado', @level2type = N'COLUMN', @level2name = N'puesto';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Especialización CAJERO',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cajero';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Empleado que es cajero (PK y FK hacia EMPLEADO)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cajero', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Turno de trabajo: MATUTINO o VESPERTINO',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'cajero', @level2type = N'COLUMN', @level2name = N'turno';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Especialización REPARTIDOR',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'repartidor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Empleado que es repartidor (PK y FK hacia EMPLEADO)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'repartidor', @level2type = N'COLUMN', @level2name = N'id_persona';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Número de licencia de conducir (único)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'repartidor', @level2type = N'COLUMN', @level2name = N'licencia';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Vehículo usado para las entregas',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'repartidor', @level2type = N'COLUMN', @level2name = N'vehiculo';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Entidad CATEGORIA',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'categoria';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la categoría',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'categoria', @level2type = N'COLUMN', @level2name = N'id_categoria';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la categoría (único)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'categoria', @level2type = N'COLUMN', @level2name = N'nombre_cat';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Entidad PRODUCTO + relación pertenece a (N:1)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Código de barras que identifica al producto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'codigo_barras';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre o descripción del producto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'nombre';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Costo de adquisición por unidad',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'costo_compra';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de venta al público por unidad',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'precio_venta';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Existencia actual en inventario',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'stock_actual';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Existencia mínima antes de reabastecer',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'stock_minimo';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Categoría a la que pertenece el producto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'producto', @level2type = N'COLUMN', @level2name = N'id_categoria';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Entidad PROVEEDOR (dirección compuesta aplanada)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del proveedor',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'id_proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Razón social o nombre comercial',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'razon_social';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Calle del domicilio',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'calle';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Número del domicilio',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'numero';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Colonia del domicilio',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'colonia';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Código postal de 5 dígitos',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'proveedor', @level2type = N'COLUMN', @level2name = N'codigo_postal';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Atributo multivalorado teléfono de PROVEEDOR',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedor dueño del teléfono',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_proveedor', @level2type = N'COLUMN', @level2name = N'id_proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Número telefónico de contacto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'telefono_proveedor', @level2type = N'COLUMN', @level2name = N'telefono';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Relación suministra (N:M) = agregación ABASTECIMIENTO',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'abastecimiento';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedor que surte el producto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'abastecimiento', @level2type = N'COLUMN', @level2name = N'id_proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Producto que el proveedor surte',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'abastecimiento', @level2type = N'COLUMN', @level2name = N'codigo_barras';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Costo al que el proveedor surte el producto',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'abastecimiento', @level2type = N'COLUMN', @level2name = N'costo_unitario';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Relación autoriza (EMPLEADO – agregación ABASTECIMIENTO)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del pedido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'id_pedido';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedor al que se hace el pedido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'id_proveedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Producto pedido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'codigo_barras';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Empleado que autoriza el pedido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'id_empleado';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se autoriza el pedido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'fecha_pedido';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de unidades pedidas',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pedido_reabastecimiento', @level2type = N'COLUMN', @level2name = N'cantidad_pedida';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Entidad VENTA + relaciones atiende, realiza y entrega (1:N)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Folio único de la venta',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'folio';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de la venta',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'fecha_hora';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'EFECTIVO, TARJETA, TRANSFERENCIA o CREDITO',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'metodo_pago';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Cajero que atendió la venta',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'id_cajero';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Cliente de la venta (NULL si es público general)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'id_cliente';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Repartidor de la entrega a domicilio (NULL si no hay entrega)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'venta', @level2type = N'COLUMN', @level2name = N'id_repartidor';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Relación incluye (N:M)',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'detalle_venta';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Venta a la que pertenece el renglón',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'detalle_venta', @level2type = N'COLUMN', @level2name = N'folio';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Producto vendido',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'detalle_venta', @level2type = N'COLUMN', @level2name = N'codigo_barras';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Unidades vendidas',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'detalle_venta', @level2type = N'COLUMN', @level2name = N'cantidad';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de venta al momento de la compra',
    @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'detalle_venta', @level2type = N'COLUMN', @level2name = N'precio_unitario';
GO

PRINT N'Esquema TiendaAbarrotes creado correctamente.';
GO
