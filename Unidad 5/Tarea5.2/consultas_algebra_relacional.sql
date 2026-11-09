/* =====================================================================
   consultas_algebra_relacional.sql
   Tarea 5.2 - Resolución de Consultas con Álgebra Formal (Catálogo SQL)
   Alumna: Gabriela Natalia De León Alvarez (I24050006)
   Materia: Fundamentos de Bases de Datos - Unidad 5
   Motor  : Microsoft SQL Server (2016 SP1 o superior / SSMS / Azure Data Studio)
   
   DESCRIPCIÓN:
   Script SQL con las 12 consultas formuladas en Álgebra Relacional sobre
   el esquema normalizado (3FN / FNBC) de la "Tienda de Abarrotes de Barrio".
   
   INSTRUCCIONES DE USO:
   1. Abre este archivo en SQL Server Management Studio (SSMS) o Azure Data Studio.
   2. Ejecuta todo el script con F5.
   3. El script verifica y asegura que la base de datos y los datos de prueba
      estén listos antes de ejecutar cada una de las 12 consultas.
   ===================================================================== */

SET NOCOUNT ON;
GO

-- 1. SELECCIÓN O PREPARACIÓN DE LA BASE DE DATOS
IF DB_ID(N'TiendaAbarrotesNormalizada') IS NULL
BEGIN
    PRINT N'Creando base de datos TiendaAbarrotesNormalizada...';
    CREATE DATABASE TiendaAbarrotesNormalizada;
END
GO

USE TiendaAbarrotesNormalizada;
GO

/* =====================================================================
   2. VERIFICACIÓN Y CREACIÓN DE ESTRUCTURA Y DATOS DE PRUEBA (SI NO EXISTEN)
   Esto permite ejecutar este archivo directamente en cualquier máquina.
   ===================================================================== */
IF OBJECT_ID(N'dbo.detalle_venta', N'U') IS NULL
BEGIN
    PRINT N'Estructurando tablas y cargando datos de prueba base...';

    -- Tablas
    CREATE TABLE dbo.persona (
        id_persona INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_pila NVARCHAR(50) NOT NULL,
        apellido_paterno NVARCHAR(50) NOT NULL,
        apellido_materno NVARCHAR(50) NULL,
        fecha_nacimiento DATE NOT NULL
    );

    CREATE TABLE dbo.telefono_persona (
        id_persona INT NOT NULL FOREIGN KEY REFERENCES dbo.persona(id_persona) ON DELETE CASCADE,
        telefono VARCHAR(15) NOT NULL,
        PRIMARY KEY (id_persona, telefono)
    );

    CREATE TABLE dbo.cliente (
        id_persona INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES dbo.persona(id_persona) ON DELETE CASCADE,
        limite_credito DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        fecha_registro DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
    );

    CREATE TABLE dbo.empleado (
        id_persona INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES dbo.persona(id_persona) ON DELETE CASCADE,
        fecha_contratacion DATE NOT NULL,
        salario DECIMAL(10,2) NOT NULL,
        puesto VARCHAR(10) NOT NULL CHECK (puesto IN ('CAJERO', 'REPARTIDOR'))
    );

    CREATE TABLE dbo.cajero (
        id_persona INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES dbo.empleado(id_persona) ON DELETE CASCADE,
        turno VARCHAR(10) NOT NULL CHECK (turno IN ('MATUTINO', 'VESPERTINO'))
    );

    CREATE TABLE dbo.repartidor (
        id_persona INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES dbo.empleado(id_persona) ON DELETE CASCADE,
        licencia VARCHAR(20) NOT NULL UNIQUE,
        vehiculo NVARCHAR(30) NULL
    );

    CREATE TABLE dbo.categoria (
        id_categoria INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        nombre_cat NVARCHAR(50) NOT NULL UNIQUE
    );

    CREATE TABLE dbo.producto (
        codigo_barras VARCHAR(20) NOT NULL PRIMARY KEY,
        nombre NVARCHAR(80) NOT NULL,
        costo_compra DECIMAL(10,2) NOT NULL,
        precio_venta DECIMAL(10,2) NOT NULL,
        stock_actual INT NOT NULL DEFAULT 0,
        stock_minimo INT NOT NULL DEFAULT 0,
        id_categoria INT NOT NULL FOREIGN KEY REFERENCES dbo.categoria(id_categoria)
    );

    CREATE TABLE dbo.proveedor (
        id_proveedor INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        razon_social NVARCHAR(100) NOT NULL,
        calle NVARCHAR(80) NULL,
        numero NVARCHAR(10) NULL,
        colonia NVARCHAR(60) NULL,
        codigo_postal CHAR(5) NULL
    );

    CREATE TABLE dbo.telefono_proveedor (
        id_proveedor INT NOT NULL FOREIGN KEY REFERENCES dbo.proveedor(id_proveedor) ON DELETE CASCADE,
        telefono VARCHAR(15) NOT NULL,
        PRIMARY KEY (id_proveedor, telefono)
    );

    CREATE TABLE dbo.abastecimiento (
        id_proveedor INT NOT NULL FOREIGN KEY REFERENCES dbo.proveedor(id_proveedor),
        codigo_barras VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES dbo.producto(codigo_barras),
        costo_unitario DECIMAL(10,2) NOT NULL,
        PRIMARY KEY (id_proveedor, codigo_barras)
    );

    CREATE TABLE dbo.venta (
        folio INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        fecha_hora DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        metodo_pago VARCHAR(13) NOT NULL CHECK (metodo_pago IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'CREDITO')),
        id_cajero INT NOT NULL FOREIGN KEY REFERENCES dbo.cajero(id_persona),
        id_cliente INT NULL FOREIGN KEY REFERENCES dbo.cliente(id_persona),
        id_repartidor INT NULL FOREIGN KEY REFERENCES dbo.repartidor(id_persona)
    );

    CREATE TABLE dbo.detalle_venta (
        folio INT NOT NULL FOREIGN KEY REFERENCES dbo.venta(folio) ON DELETE CASCADE,
        codigo_barras VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES dbo.producto(codigo_barras),
        cantidad INT NOT NULL,
        precio_unitario DECIMAL(10,2) NOT NULL,
        PRIMARY KEY (folio, codigo_barras)
    );

    -- Datos de prueba
    INSERT INTO dbo.categoria (nombre_cat) VALUES (N'Lácteos'), (N'Abarrotes'), (N'Granos y Semillas');

    INSERT INTO dbo.persona (nombre_pila, apellido_paterno, apellido_materno, fecha_nacimiento) VALUES 
    (N'Mario', N'Casas', N'Cruz', '1995-04-12'),
    (N'Roberto', N'Gómez', N'Luna', '1998-08-23'),
    (N'Laura Elena', N'Méndez', N'Silva', '2001-01-30'),
    (N'Juan Carlos', N'Pérez', N'López', '1988-11-05'),
    (N'Ana Luisa', N'Silva', N'Romero', '1992-07-19');

    INSERT INTO dbo.telefono_persona (id_persona, telefono) VALUES 
    (4, '5512345678'), (4, '5587654321'), (5, '5544332211');

    INSERT INTO dbo.cliente (id_persona, limite_credito) VALUES 
    (4, 1500.00), (5, 2000.00);

    INSERT INTO dbo.empleado (id_persona, fecha_contratacion, salario, puesto) VALUES 
    (1, '2023-01-15', 8500.00, 'CAJERO'),
    (2, '2023-05-10', 8000.00, 'REPARTIDOR'),
    (3, '2024-02-01', 8500.00, 'CAJERO');

    INSERT INTO dbo.cajero (id_persona, turno) VALUES 
    (1, 'MATUTINO'), (3, 'VESPERTINO');

    INSERT INTO dbo.repartidor (id_persona, licencia, vehiculo) VALUES 
    (2, 'LIC-CDMX-998877', N'Motocicleta Honda 125');

    INSERT INTO dbo.producto (codigo_barras, nombre, costo_compra, precio_venta, stock_actual, stock_minimo, id_categoria) VALUES 
    ('PROD01', N'Leche Entera 1L', 18.00, 24.50, 45, 10, 1),
    ('PROD02', N'Pan Integral 680g', 22.00, 32.00, 30, 8, 2),
    ('PROD03', N'Frijol Negro 1kg', 28.00, 38.00, 50, 15, 3),
    ('PROD04', N'Aceite Vegetal 1L', 32.00, 44.00, 5, 10, 2);

    INSERT INTO dbo.proveedor (razon_social, calle, numero, colonia, codigo_postal) VALUES 
    (N'Distribuidora Central de Abarrotes S.A. de C.V.', N'Av. Industrial', N'450', N'Parque Industrial', '02300'),
    (N'Lácteos del Centro S.A.', N'Carretera Federal', N'Km 12', N'El Fresno', '54000');

    INSERT INTO dbo.telefono_proveedor (id_proveedor, telefono) VALUES 
    (1, '5533221100'), (2, '5599887766');

    INSERT INTO dbo.abastecimiento (id_proveedor, codigo_barras, costo_unitario) VALUES 
    (1, 'PROD01', 17.50),
    (1, 'PROD02', 21.00),
    (1, 'PROD04', 31.00), -- Proveedor 1 surte todos los de Abarrotes (PROD02 y PROD04)
    (2, 'PROD01', 18.00);

    INSERT INTO dbo.venta (fecha_hora, metodo_pago, id_cajero, id_cliente, id_repartidor) VALUES 
    ('2026-10-30T09:15:00', 'EFECTIVO', 1, 4, NULL),
    ('2026-10-30T10:30:00', 'CREDITO', 1, 5, 2),
    ('2026-10-30T16:45:00', 'TARJETA', 3, NULL, NULL);

    INSERT INTO dbo.detalle_venta (folio, codigo_barras, cantidad, precio_unitario) VALUES 
    (1, 'PROD01', 2, 24.50),
    (1, 'PROD02', 1, 32.00),
    (2, 'PROD01', 4, 24.50),
    (3, 'PROD03', 2, 38.00);
END
GO

PRINT N'=====================================================================';
PRINT N'EJECUTANDO CATÁLOGO DE CONSULTAS EN ÁLGEBRA RELACIONAL (TAREA 5.2)';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CONSULTA 1: PRODUCTOS CON STOCK CRÍTICO PARA REABASTECIMIENTO
   Complejidad: Básica (Operadores Unarios: Selección σ y Proyección π)
   
   Lenguaje Natural:
   "Obtener el código de barras, nombre, stock actual y stock mínimo de
   todos los productos cuyo inventario actual sea menor o igual al stock mínimo."
   
   Álgebra Relacional:
   π_{codigo_barras, nombre, stock_actual, stock_minimo}(σ_{stock_actual <= stock_minimo}(PRODUCTO))
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 1: Productos con stock crítico (stock_actual <= stock_minimo) ---';

SELECT 
    codigo_barras, 
    nombre, 
    stock_actual, 
    stock_minimo
FROM dbo.producto
WHERE stock_actual <= stock_minimo;
GO

/* =====================================================================
   CONSULTA 2: MARGEN DE GANANCIA UNITARIO BRUTO MAYOR A $10.00
   Complejidad: Básica-Intermedia (Proyección Generalizada Aritmética y Selección)
   
   Lenguaje Natural:
   "Calcular el margen de ganancia unitario bruto (precio_venta - costo_compra)
   y mostrar código, nombre, precio de venta y margen para aquellos con margen > $10."
   
   Álgebra Relacional:
   π_{codigo_barras, nombre, precio_venta, margen}(
     σ_{margen > 10.00}(
       π_{codigo_barras, nombre, precio_venta, (precio_venta - costo_compra) -> margen}(PRODUCTO)
     )
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 2: Margen de ganancia unitario mayor a $10.00 ---';

SELECT 
    codigo_barras, 
    nombre, 
    precio_venta, 
    (precio_venta - costo_compra) AS margen
FROM dbo.producto
WHERE (precio_venta - costo_compra) > 10.00;
GO

/* =====================================================================
   CONSULTA 3: CATÁLOGO DE PRODUCTOS CON NOMBRE DE CATEGORÍA
   Complejidad: Intermedia (Reunión Natural / Theta Join de 2 Relaciones)
   
   Lenguaje Natural:
   "Listar el código de barras, nombre del producto, precio de venta y el
   nombre descriptivo de la categoría para todos los productos de 'Abarrotes'."
   
   Álgebra Relacional:
   π_{codigo_barras, nombre, precio_venta, nombre_cat}(
     PRODUCTO ⋈_{PRODUCTO.id_categoria = CATEGORIA.id_categoria} (σ_{nombre_cat = 'Abarrotes'}(CATEGORIA))
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 3: Catálogo de productos con categoría ''Abarrotes'' ---';

SELECT 
    p.codigo_barras, 
    p.nombre, 
    p.precio_venta, 
    c.nombre_cat
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat = N'Abarrotes';
GO

/* =====================================================================
   CONSULTA 4: CAJEROS ASIGNADOS AL TURNO VESPERTINO (HERENCIA)
   Complejidad: Intermedia (Reconstrucción de Jerarquía de Especialización)
   
   Lenguaje Natural:
   "Obtener el ID, nombre completo, fecha de contratación, salario y turno
   de todos los cajeros asignados al turno 'VESPERTINO'."
   
   Álgebra Relacional:
   π_{id_persona, nombre_pila, apellido_paterno, apellido_materno, fecha_contratacion, salario, turno}(
     PERSONA ⋈ EMPLEADO ⋈ (σ_{turno = 'VESPERTINO'}(CAJERO))
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 4: Cajeros asignados al turno VESPERTINO ---';

SELECT 
    p.id_persona, 
    p.nombre_pila, 
    p.apellido_paterno, 
    p.apellido_materno, 
    e.fecha_contratacion, 
    e.salario, 
    c.turno
FROM dbo.persona p
INNER JOIN dbo.empleado e ON p.id_persona = e.id_persona
INNER JOIN dbo.cajero c ON e.id_persona = c.id_persona
WHERE c.turno = 'VESPERTINO';
GO

/* =====================================================================
   CONSULTA 5: DETALLE DE ARTÍCULOS Y SUBTOTALES DE UNA VENTA ESPECÍFICA
   Complejidad: Intermedia (Reunión de 3 Tablas M:N y Cálculo de Renglones)
   
   Lenguaje Natural:
   "Para la venta con folio 1, mostrar el folio, fecha/hora, método de pago,
   código, nombre del producto, precio unitario, cantidad y subtotal calculado."
   
   Álgebra Relacional:
   π_{folio, fecha_hora, metodo_pago, codigo_barras, nombre, precio_unitario, cantidad, (cantidad * precio_unitario) -> subtotal}(
     (σ_{folio = 1}(VENTA)) ⋈ DETALLE_VENTA ⋈ PRODUCTO
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 5: Detalle de renglones y subtotales de la venta Folio 1 ---';

SELECT 
    v.folio, 
    v.fecha_hora, 
    v.metodo_pago, 
    p.codigo_barras, 
    p.nombre, 
    d.precio_unitario, 
    d.cantidad, 
    CAST(d.cantidad * d.precio_unitario AS DECIMAL(10,2)) AS subtotal
FROM dbo.venta v
INNER JOIN dbo.detalle_venta d ON v.folio = d.folio
INNER JOIN dbo.producto p ON d.codigo_barras = p.codigo_barras
WHERE v.folio = 1;
GO

/* =====================================================================
   CONSULTA 6: VENTAS A CRÉDITO CON ENTREGA A DOMICILIO (DOBLE ROL)
   Complejidad: Avanzada (Reuniones Múltiples hacia PERSONA con Renombrado ρ)
   
   Lenguaje Natural:
   "Obtener folio, fecha, nombre del cliente, nombre del repartidor,
   licencia y vehículo para ventas a crédito con servicio de entrega a domicilio."
   
   Álgebra Relacional:
   P_cli <- ρ_{P_cli}(PERSONA)
   P_rep <- ρ_{P_rep}(PERSONA)
   V_cred <- σ_{metodo_pago = 'CREDITO' ∧ id_repartidor != NULL}(VENTA)
   π_{folio, fecha_hora, nom_cli, pat_cli, nom_rep, pat_rep, licencia, vehiculo}(
     V_cred ⋈_{id_cliente = id_cli} P_cli ⋈_{id_repartidor = id_persona} REPARTIDOR ⋈_{id_persona = id_rep} P_rep
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 6: Ventas a crédito entregadas a domicilio con repartidor ---';

SELECT 
    v.folio, 
    v.fecha_hora,
    p_cli.nombre_pila AS nom_cli, 
    p_cli.apellido_paterno AS pat_cli,
    p_rep.nombre_pila AS nom_rep, 
    p_rep.apellido_paterno AS pat_rep,
    r.licencia, 
    r.vehiculo
FROM dbo.venta v
INNER JOIN dbo.persona p_cli ON v.id_cliente = p_cli.id_persona
INNER JOIN dbo.repartidor r ON v.id_repartidor = r.id_persona
INNER JOIN dbo.persona p_rep ON r.id_persona = p_rep.id_persona
WHERE v.metodo_pago = 'CREDITO' AND v.id_repartidor IS NOT NULL;
GO

/* =====================================================================
   CONSULTA 7: PRODUCTOS DEL CATÁLOGO QUE NUNCA HAN SIDO VENDIDOS
   Complejidad: Avanzada (Operador Diferencia Relacional - / Antijoin)
   
   Lenguaje Natural:
   "Identificar aquellos productos registrados en el inventario de la tienda
   que jamás han formado parte de ninguna venta."
   
   Álgebra Relacional:
   π_{codigo_barras, nombre}(PRODUCTO) - π_{codigo_barras, nombre}(PRODUCTO ⋈ DETALLE_VENTA)
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 7: Productos del catálogo nunca vendidos (Diferencia -) ---';

SELECT codigo_barras, nombre
FROM dbo.producto
EXCEPT
SELECT p.codigo_barras, p.nombre
FROM dbo.producto p
INNER JOIN dbo.detalle_venta d ON p.codigo_barras = d.codigo_barras;
GO

/* =====================================================================
   CONSULTA 8: DIRECTORIO UNIFICADO DE TELÉFONOS (UNIÓN ∪)
   Complejidad: Intermedia-Avanzada (Operador Unión ∪ y Compatibilidad de Esquemas)
   
   Lenguaje Natural:
   "Generar una libreta unificada de contactos telefónicos que incluya tanto a
   las personas (clientes/empleados) como a los proveedores registrados."
   
   Álgebra Relacional:
   T_per <- π_{'PERSONA' -> tipo, (nombre_pila || ' ' || apellido_paterno) -> contacto, telefono}(PERSONA ⋈ TELEFONO_PERSONA)
   T_prov <- π_{'PROVEEDOR' -> tipo, razon_social -> contacto, telefono}(PROVEEDOR ⋈ TELEFONO_PROVEEDOR)
   T_per ∪ T_prov
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 8: Directorio unificado de teléfonos (Unión ∪) ---';

SELECT 
    'PERSONA' AS tipo, 
    CONCAT(p.nombre_pila, ' ', p.apellido_paterno) AS contacto, 
    tp.telefono
FROM dbo.persona p
INNER JOIN dbo.telefono_persona tp ON p.id_persona = tp.id_persona

UNION ALL

SELECT 
    'PROVEEDOR' AS tipo, 
    pr.razon_social AS contacto, 
    tpr.telefono
FROM dbo.proveedor pr
INNER JOIN dbo.telefono_proveedor tpr ON pr.id_proveedor = tpr.id_proveedor;
GO

/* =====================================================================
   CONSULTA 9: TOTAL RECAUDADO Y UNIDADES VENDIDAS POR MÉTODO DE PAGO
   Complejidad: Avanzada (Álgebra Extendida: Agrupamiento y Agregación 𝒢)
   
   Lenguaje Natural:
   "Calcular el monto acumulado total recaudado ($) y el número total de unidades
   vendidas agrupadas por cada método de pago ('EFECTIVO', 'CREDITO', 'TARJETA')."
   
   Álgebra Relacional:
   _{metodo_pago}𝒢_{SUM(subtotal) -> total_recaudado, SUM(cantidad) -> unidades_vendidas}(
     VENTA ⋈ π_{folio, cantidad, (cantidad * precio_unitario) -> subtotal}(DETALLE_VENTA)
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 9: Total recaudado y unidades vendidas por método de pago (Agregación 𝒢) ---';

SELECT 
    v.metodo_pago,
    SUM(d.cantidad * d.precio_unitario) AS total_recaudado,
    SUM(d.cantidad) AS unidades_vendidas
FROM dbo.venta v
INNER JOIN dbo.detalle_venta d ON v.folio = d.folio
GROUP BY v.metodo_pago;
GO

/* =====================================================================
   CONSULTA 10: CATEGORÍAS CON MÁS DE UN PRODUCTO (FILTRO HAVING)
   Complejidad: Avanzada (Agregación 𝒢 con Selección posterior σ)
   
   Lenguaje Natural:
   "Obtener ID, nombre de categoría y conteo de artículos para aquellas
   categorías que contengan más de un producto en inventario."
   
   Álgebra Relacional:
   A <- _{id_categoria}𝒢_{COUNT(codigo_barras) -> total_productos}(PRODUCTO)
   F <- σ_{total_productos > 1}(A)
   π_{id_categoria, nombre_cat, total_productos}(F ⋈ CATEGORIA)
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 10: Categorías con más de un producto en catálogo (Having relacional) ---';

SELECT 
    c.id_categoria, 
    c.nombre_cat, 
    COUNT(p.codigo_barras) AS total_productos
FROM dbo.categoria c
INNER JOIN dbo.producto p ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nombre_cat
HAVING COUNT(p.codigo_barras) > 1;
GO

/* =====================================================================
   CONSULTA 11: PROVEEDORES QUE SURTEN TODOS LOS PRODUCTOS DE ABARROTES
   Complejidad: Compleja / Teórica (Operador División Relacional ÷)
   
   Lenguaje Natural:
   "Encontrar la razón social y clave de los proveedores que suministran
   TODOS los productos pertenecientes a la categoría 'Abarrotes' (id_categoria = 2)."
   
   Álgebra Relacional:
   ProdAbarrotes <- π_{codigo_barras}(σ_{id_categoria = 2}(PRODUCTO))
   ProvProd <- π_{id_proveedor, codigo_barras}(ABASTECIMIENTO)
   π_{id_proveedor, razon_social}((ProvProd ÷ ProdAbarrotes) ⋈ PROVEEDOR)
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 11: Proveedores que surten TODOS los productos de abarrotes (División ÷) ---';

SELECT pr.id_proveedor, pr.razon_social
FROM dbo.proveedor pr
WHERE NOT EXISTS (
    SELECT p.codigo_barras
    FROM dbo.producto p
    WHERE p.id_categoria = 2
    EXCEPT
    SELECT a.codigo_barras
    FROM dbo.abastecimiento a
    WHERE a.id_proveedor = pr.id_proveedor
);
GO

/* =====================================================================
   CONSULTA 12: ESTADO DE CRÉDITO Y FOLIOS DE VENTAS (LEFT OUTER JOIN ⟕)
   Complejidad: Avanzada (Álgebra Extendida: Reunión Externa Izquierda ⟕)
   
   Lenguaje Natural:
   "Listar todos los clientes registrados con su límite de crédito y los folios
   de ventas a crédito solicitadas, preservando a los clientes que nunca han comprado a crédito (folio NULL)."
   
   Álgebra Relacional:
   CliBase <- π_{id_persona, nombre_pila, apellido_paterno, limite_credito}(PERSONA ⋈ CLIENTE)
   VentasCred <- π_{folio, id_cliente}(σ_{metodo_pago = 'CREDITO'}(VENTA))
   π_{id_persona, nombre_pila, apellido_paterno, limite_credito, folio}(
     CliBase ⟕_{CliBase.id_persona = VentasCred.id_cliente} VentasCred
   )
   ===================================================================== */
PRINT N'';
PRINT N'--- CONSULTA 12: Clientes y folios de compras a crédito (Left Outer Join ⟕) ---';

SELECT 
    c.id_persona, 
    p.nombre_pila, 
    p.apellido_paterno, 
    c.limite_credito, 
    v.folio AS folio_venta_credito
FROM dbo.cliente c
INNER JOIN dbo.persona p ON c.id_persona = p.id_persona
LEFT OUTER JOIN dbo.venta v ON c.id_persona = v.id_cliente AND v.metodo_pago = 'CREDITO';
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'EJECUCIÓN DEL CATÁLOGO DE CONSULTAS FINALIZADA EXITOSAMENTE.';
PRINT N'=====================================================================';
GO

