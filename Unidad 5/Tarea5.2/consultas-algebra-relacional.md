# Tarea 5.2: Resolución de Consultas sobre el Esquema Relacional con Álgebra Formal

📍 [Fundamentos de Bases de Datos](../../README.md) › [Unidad 5](../../README.md#unidad-5) › [Tarea 5.2](README.md) › **Consultas en Álgebra Relacional**

**Tecnológico Nacional de México**  
**Carrera:** Ingeniería Informática  
**Materia:** Fundamentos de Base de Datos  
**Unidad:** 5 — Álgebra Relacional y Lenguajes Formales de Consulta  
**Alumna:** Gabriela Natalia De León Alvarez  
**Matrícula:** I24050006  

---

## 📌 1. Introducción y Marco de Trabajo

El **álgebra relacional** es un lenguaje procedimental formal donde las consultas se expresan aplicando operadores sobre relaciones (tablas) para producir nuevas relaciones, cumpliendo con la **propiedad de cierre** (Codd, 1970; Elmasri & Navathe, 2016).

En este documento se formula y resuelve formalmente un catálogo de **12 consultas de complejidad progresiva** (básicas, intermedias y avanzadas) aplicadas sobre el **esquema físico totalmente normalizado (3FN / FNBC)** de la **Tienda de Abarrotes de Barrio** (definido en la Tarea 4.2).

### Esquema Relacional de Referencia (Tarea 4.2)

1. $\text{PERSONA}(\underline{\text{id\_persona}}, \text{nombre\_pila}, \text{apellido\_paterno}, \text{apellido\_materno}, \text{fecha\_nacimiento})$
2. $\text{TELEFONO\_PERSONA}(\underline{\text{id\_persona}}, \underline{\text{telefono}})$
3. $\text{CLIENTE}(\underline{\text{id\_persona}}, \text{limite\_credito}, \text{fecha\_registro})$
4. $\text{EMPLEADO}(\underline{\text{id\_persona}}, \text{fecha\_contratacion}, \text{salario}, \text{puesto})$
5. $\text{CAJERO}(\underline{\text{id\_persona}}, \text{turno})$
6. $\text{REPARTIDOR}(\underline{\text{id\_persona}}, \text{licencia}, \text{vehiculo})$
7. $\text{CATEGORIA}(\underline{\text{id\_categoria}}, \text{nombre\_cat})$
8. $\text{PRODUCTO}(\underline{\text{codigo\_barras}}, \text{nombre}, \text{costo\_compra}, \text{precio\_venta}, \text{stock\_actual}, \text{stock\_minimo}, \text{id\_categoria})$
9. $\text{PROVEEDOR}(\underline{\text{id\_proveedor}}, \text{razon\_social}, \text{calle}, \text{numero}, \text{colonia}, \text{codigo\_postal})$
10. $\text{TELEFONO\_PROVEEDOR}(\underline{\text{id\_proveedor}}, \underline{\text{telefono}})$
11. $\text{ABASTECIMIENTO}(\underline{\text{id\_proveedor}}, \underline{\text{codigo\_barras}}, \text{costo\_unitario})$
12. $\text{PEDIDO\_REABASTECIMIENTO}(\underline{\text{id\_pedido}}, \text{id\_proveedor}, \text{codigo\_barras}, \text{id\_empleado}, \text{fecha\_pedido}, \text{cantidad\_pedida})$
13. $\text{VENTA}(\underline{\text{folio}}, \text{fecha\_hora}, \text{metodo\_pago}, \text{id\_cajero}, \text{id\_cliente}, \text{id\_repartidor})$
14. $\text{DETALLE\_VENTA}(\underline{\text{folio}}, \underline{\text{codigo\_barras}}, \text{cantidad}, \text{precio\_unitario})$

### Datos de Instancia Base para Evaluación

* **CATEGORIA:**
  - $(1, \text{'Lácteos'})$
  - $(2, \text{'Abarrotes'})$
  - $(3, \text{'Granos y Semillas'})$

* **PRODUCTO:**
  - $(\text{'PROD01'}, \text{'Leche Entera 1L'}, 18.00, 24.50, 45, 10, 1)$
  - $(\text{'PROD02'}, \text{'Pan Integral 680g'}, 22.00, 32.00, 30, 8, 2)$
  - $(\text{'PROD03'}, \text{'Frijol Negro 1kg'}, 28.00, 38.00, 50, 15, 3)$
  - $(\text{'PROD04'}, \text{'Aceite Vegetal 1L'}, 32.00, 44.00, 5, 10, 2)$ *(Bajo stock)*

* **PERSONA:**
  - $(1, \text{'Mario'}, \text{'Casas'}, \text{'Cruz'}, \text{'1995-04-12'})$
  - $(2, \text{'Roberto'}, \text{'Gómez'}, \text{'Luna'}, \text{'1998-08-23'})$
  - $(3, \text{'Laura Elena'}, \text{'Méndez'}, \text{'Silva'}, \text{'2001-01-30'})$
  - $(4, \text{'Juan Carlos'}, \text{'Pérez'}, \text{'López'}, \text{'1988-11-05'})$
  - $(5, \text{'Ana Luisa'}, \text{'Silva'}, \text{'Romero'}, \text{'1992-07-19'})$

* **CLIENTE:** $(4, 1500.00, \text{'2026-01-10'}), (5, 2000.00, \text{'2026-02-15'})$
* **EMPLEADO:** $(1, \text{'2023-01-15'}, 8500.00, \text{'CAJERO'}), (2, \text{'2023-05-10'}, 8000.00, \text{'REPARTIDOR'}), (3, \text{'2024-02-01'}, 8500.00, \text{'CAJERO'})$
* **CAJERO:** $(1, \text{'MATUTINO'}), (3, \text{'VESPERTINO'})$
* **REPARTIDOR:** $(2, \text{'LIC-CDMX-998877'}, \text{'Motocicleta Honda 125'})$
* **VENTA:**
  - $(1, \text{'2026-10-30 09:15:00'}, \text{'EFECTIVO'}, 1, 4, \text{NULL})$
  - $(2, \text{'2026-10-30 10:30:00'}, \text{'CREDITO'}, 1, 5, 2)$
  - $(3, \text{'2026-10-30 16:45:00'}, \text{'TARJETA'}, 3, \text{NULL}, \text{NULL})$
* **DETALLE_VENTA:**
  - $(1, \text{'PROD01'}, 2, 24.50)$
  - $(1, \text{'PROD02'}, 1, 32.00)$
  - $(2, \text{'PROD01'}, 4, 24.50)$
  - $(3, \text{'PROD03'}, 2, 38.00)$

---

## 🗂️ 2. Catálogo de Consultas Formales

```
Nivel 1: Consultas Básicas (Unarias: Selección, Proyección, Renombrado)
├── Consulta 1: Productos con stock crítico para reabastecimiento
└── Consulta 2: Margen de utilidad unitario de productos (Proyección extendida)

Nivel 2: Consultas Intermedias (Reuniones Theta y Natural Join)
├── Consulta 3: Catálogo de productos con el nombre de su categoría
├── Consulta 4: Cajeros asignados al turno vespertino (Herencia Persona-Cajero)
├── Consulta 5: Detalle de productos y cantidades de una venta específica
└── Consulta 6: Ventas a crédito con entrega a domicilio y datos del repartidor

Nivel 3: Consultas Avanzadas (Conjuntos, Agregación, División y Outer Join)
├── Consulta 7: Productos del catálogo que nunca han sido vendidos (Diferencia -)
├── Consulta 8: Directorio unificado de teléfonos de personas y proveedores (Unión ∪)
├── Consulta 9: Total de ventas y artículos vendidos por método de pago (Agregación 𝒢)
├── Consulta 10: Categorías con más de un producto en inventario (Having relacional)
├── Consulta 11: Proveedores que surten todos los productos de abarrotes (División ÷)
└── Consulta 12: Estado de crédito de todos los clientes con sus ventas (Left Outer Join ⟕)
```

---

### Consulta 1: Productos con Stock Crítico para Reabastecimiento
**Nivel de Complejidad:** Básica (Operadores Unarios: Selección y Proyección)

#### A. Equivalencia en Lenguaje Natural
> *"Obtener el código de barras, nombre, stock actual y stock mínimo de todos los productos cuyo inventario actual sea menor o igual al stock mínimo de seguridad."*

#### B. Expresión Formal en Álgebra Relacional

$$\pi_{codigo\_barras, nombre, stock\_actual, stock\_minimo}(\sigma_{stock\_actual \le stock\_minimo}(PRODUCTO))$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Selección ($\sigma$) de tuplas con inventario comprometido:**
   $$R_1 \leftarrow \sigma_{stock\_actual \le stock\_minimo}(PRODUCTO)$$
   *Esquema:* $R_1(codigo\_barras, nombre, costo\_compra, precio\_venta, stock\_actual, stock\_minimo, id\_categoria)$

   | codigo_barras | nombre | costo_compra | precio_venta | stock_actual | stock_minimo | id_categoria |
   | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
   | PROD04 | Aceite Vegetal 1L | 32.00 | 44.00 | 5 | 10 | 2 |

2. **Paso 2: Proyección ($\pi$) de las columnas requeridas:**
   $$R_{final} \leftarrow \pi_{codigo\_barras, nombre, stock\_actual, stock\_minimo}(R_1)$$

#### D. Tabla Resultante

| codigo_barras | nombre | stock_actual | stock_minimo |
| :--- | :--- | :---: | :---: |
| PROD04 | Aceite Vegetal 1L | 5 | 10 |

#### E. Equivalente en SQL
```sql
SELECT codigo_barras, nombre, stock_actual, stock_minimo
FROM dbo.producto
WHERE stock_actual <= stock_minimo;
```

---

### Consulta 2: Margen de Ganancia Unitario Mayor a \$10.00
**Nivel de Complejidad:** Básica-Intermedia (Proyección Generalizada Aritmética y Selección)

#### A. Equivalencia en Lenguaje Natural
> *"Calcular el margen de ganancia unitario bruto ($precio\_venta - costo\_compra$) de cada producto y mostrar el código, nombre, precio de venta y margen únicamente de aquellos productos cuyo margen supere los \$10.00 pesos."*

#### B. Expresión Formal en Álgebra Relacional

$$\pi_{codigo\_barras, nombre, precio\_venta, margen}(\sigma_{margen > 10.00}(\pi_{codigo\_barras, nombre, precio\_venta, (precio\_venta - costo\_compra) \to margen}(PRODUCTO)))$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Proyección generalizada calculando el atributo derivado `margen`:**
   $$R_1 \leftarrow \pi_{codigo\_barras, nombre, precio\_venta, (precio\_venta - costo\_compra) \to margen}(PRODUCTO)$$

   | codigo_barras | nombre | precio_venta | margen |
   | :--- | :--- | :---: | :---: |
   | PROD01 | Leche Entera 1L | 24.50 | 6.50 |
   | PROD02 | Pan Integral 680g | 32.00 | 10.00 |
   | PROD03 | Frijol Negro 1kg | 38.00 | 10.00 |
   | PROD04 | Aceite Vegetal 1L | 44.00 | 12.00 |

2. **Paso 2: Filtrado por margen estricto ($margen > 10.00$):**
   $$R_2 \leftarrow \sigma_{margen > 10.00}(R_1)$$

3. **Paso 3: Proyección final:**
   $$R_{final} \leftarrow \pi_{codigo\_barras, nombre, precio\_venta, margen}(R_2)$$

#### D. Tabla Resultante

| codigo_barras | nombre | precio_venta | margen |
| :--- | :--- | :---: | :---: |
| PROD04 | Aceite Vegetal 1L | 44.00 | 12.00 |

#### E. Equivalente en SQL
```sql
SELECT codigo_barras, nombre, precio_venta, (precio_venta - costo_compra) AS margen
FROM dbo.producto
WHERE (precio_venta - costo_compra) > 10.00;
```

---

### Consulta 3: Catálogo de Productos con Nombre de Categoría
**Nivel de Complejidad:** Intermedia (Reunión Natural / Theta Join de 2 Relaciones)

#### A. Equivalencia en Lenguaje Natural
> *"Listar el código de barras, nombre del producto, precio de venta y el nombre descriptivo de su categoría para todos los productos de la categoría 'Abarrotes'."*

#### B. Expresión Formal en Álgebra Relacional

$$\pi_{PRODUCTO.codigo\_barras, PRODUCTO.nombre, PRODUCTO.precio\_venta, CATEGORIA.nombre\_cat}(\sigma_{CATEGORIA.nombre\_cat = 'Abarrotes'}(PRODUCTO \bowtie_{PRODUCTO.id\_categoria = CATEGORIA.id\_categoria} CATEGORIA))$$

*Forma optimizada (empujar selecciones antes del join):*
$$\pi_{codigo\_barras, nombre, precio\_venta, nombre\_cat}(PRODUCTO \bowtie_{PRODUCTO.id\_categoria = CATEGORIA.id\_categoria} (\sigma_{nombre\_cat = 'Abarrotes'}(CATEGORIA)))$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Filtrar la categoría requerida:**
   $$R_1 \leftarrow \sigma_{nombre\_cat = 'Abarrotes'}(CATEGORIA)$$
   *Resultado:* $\{(2, \text{'Abarrotes'})\}$

2. **Paso 2: Reunión ($\bowtie$) con la relación `PRODUCTO` por clave foránea:**
   $$R_2 \leftarrow PRODUCTO \bowtie_{PRODUCTO.id\_categoria = R_1.id\_categoria} R_1$$

   | codigo_barras | nombre | costo_compra | precio_venta | stock_actual | stock_minimo | id_categoria | nombre_cat |
   | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
   | PROD02 | Pan Integral 680g | 22.00 | 32.00 | 30 | 8 | 2 | Abarrotes |
   | PROD04 | Aceite Vegetal 1L | 32.00 | 44.00 | 5 | 10 | 2 | Abarrotes |

3. **Paso 3: Proyección final de atributos solicitados:**
   $$R_{final} \leftarrow \pi_{codigo\_barras, nombre, precio\_venta, nombre\_cat}(R_2)$$

#### D. Tabla Resultante

| codigo_barras | nombre | precio_venta | nombre_cat |
| :--- | :--- | :---: | :--- |
| PROD02 | Pan Integral 680g | 32.00 | Abarrotes |
| PROD04 | Aceite Vegetal 1L | 44.00 | Abarrotes |

#### E. Equivalente en SQL
```sql
SELECT p.codigo_barras, p.nombre, p.precio_venta, c.nombre_cat
FROM dbo.producto p
INNER JOIN dbo.categoria c ON p.id_categoria = c.id_categoria
WHERE c.nombre_cat = N'Abarrotes';
```

---

### Consulta 4: Cajeros Asignados al Turno Vespertino (Especialización)
**Nivel de Complejidad:** Intermedia (Reconstrucción de Jerarquía de Herencia)

#### A. Equivalencia en Lenguaje Natural
> *"Obtener el ID, nombre completo (pila, apellido paterno y materno), fecha de contratación y salario de todos los cajeros que tienen asignado el turno 'VESPERTINO'."*

#### B. Expresión Formal en Álgebra Relacional

$$\pi_{PERSONA.id\_persona, nombre\_pila, apellido\_paterno, apellido\_materno, fecha\_contratacion, salario, turno}(PERSONA \bowtie EMPLEADO \bowtie (\sigma_{turno = 'VESPERTINO'}(CAJERO)))$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Filtrar la especialización `CAJERO`:**
   $$R_1 \leftarrow \sigma_{turno = 'VESPERTINO'}(CAJERO)$$
   *Resultado:* $\{(3, \text{'VESPERTINO'})\}$

2. **Paso 2: Reunir con la superclase `EMPLEADO`:**
   $$R_2 \leftarrow EMPLEADO \bowtie_{EMPLEADO.id\_persona = R_1.id\_persona} R_1$$
   *Resultado:* $\{(3, \text{'2024-02-01'}, 8500.00, \text{'CAJERO'}, \text{'VESPERTINO'})\}$

3. **Paso 3: Reunir con la superclase base `PERSONA` para rescatar los datos personales:**
   $$R_3 \leftarrow PERSONA \bowtie_{PERSONA.id\_persona = R_2.id\_persona} R_2$$

4. **Paso 4: Proyección final:**
   $$R_{final} \leftarrow \pi_{id\_persona, nombre\_pila, apellido\_paterno, apellido\_materno, fecha\_contratacion, salario, turno}(R_3)$$

#### D. Tabla Resultante

| id_persona | nombre_pila | apellido_paterno | apellido_materno | fecha_contratacion | salario | turno |
| :---: | :--- | :--- | :--- | :---: | :---: | :--- |
| 3 | Laura Elena | Méndez | Silva | 2024-02-01 | 8500.00 | VESPERTINO |

#### E. Equivalente en SQL
```sql
SELECT p.id_persona, p.nombre_pila, p.apellido_paterno, p.apellido_materno, 
       e.fecha_contratacion, e.salario, c.turno
FROM dbo.persona p
INNER JOIN dbo.empleado e ON p.id_persona = e.id_persona
INNER JOIN dbo.cajero c ON e.id_persona = c.id_persona
WHERE c.turno = 'VESPERTINO';
```

---

### Consulta 5: Detalle de Artículos y Subtotales de una Venta
**Nivel de Complejidad:** Intermedia (Reunión de 3 Tablas M:N y Cálculo de Renglones)

#### A. Equivalencia en Lenguaje Natural
> *"Para la venta con folio 1, mostrar el folio, la fecha y hora, el método de pago, el código de barras, nombre del producto, precio unitario de venta, cantidad adquirida y el subtotal calculado por renglón."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
R_{final} \leftarrow \pi_{folio, fecha\_hora, metodo\_pago, codigo\_barras, nombre, precio\_unitario, cantidad, (cantidad \times precio\_unitario) \to subtotal} \\
& ((\sigma_{folio = 1}(VENTA)) \bowtie DETALLE\_VENTA \bowtie PRODUCTO)
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Seleccionar la venta requerida:**
   $$R_1 \leftarrow \sigma_{folio = 1}(VENTA)$$
   *Resultado:* $\{(1, \text{'2026-10-30 09:15:00'}, \text{'EFECTIVO'}, 1, 4, \text{NULL})\}$

2. **Paso 2: Reunir con las líneas de detalle (`DETALLE_VENTA`):**
   $$R_2 \leftarrow R_1 \bowtie_{R_1.folio = DETALLE\_VENTA.folio} DETALLE\_VENTA$$

   | folio | fecha_hora | metodo_pago | codigo_barras | cantidad | precio_unitario |
   | :---: | :--- | :--- | :--- | :---: | :---: |
   | 1 | 2026-10-30 09:15 | EFECTIVO | PROD01 | 2 | 24.50 |
   | 1 | 2026-10-30 09:15 | EFECTIVO | PROD02 | 1 | 32.00 |

3. **Paso 3: Reunir con `PRODUCTO` para obtener la descripción:**
   $$R_3 \leftarrow R_2 \bowtie_{R_2.codigo\_barras = PRODUCTO.codigo\_barras} PRODUCTO$$

4. **Paso 4: Proyección generalizada incorporando $subtotal = cantidad \times precio\_unitario$:**
   $$R_{final} \leftarrow \pi_{folio, fecha\_hora, metodo\_pago, codigo\_barras, nombre, precio\_unitario, cantidad, (cantidad \times precio\_unitario) \to subtotal}(R_3)$$

#### D. Tabla Resultante

| folio | fecha_hora | metodo_pago | codigo_barras | nombre | precio_unitario | cantidad | subtotal |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| 1 | 2026-10-30 09:15 | EFECTIVO | PROD01 | Leche Entera 1L | 24.50 | 2 | 49.00 |
| 1 | 2026-10-30 09:15 | EFECTIVO | PROD02 | Pan Integral 680g | 32.00 | 1 | 32.00 |

#### E. Equivalente en SQL
```sql
SELECT v.folio, v.fecha_hora, v.metodo_pago, p.codigo_barras, p.nombre, 
       d.precio_unitario, d.cantidad, (d.cantidad * d.precio_unitario) AS subtotal
FROM dbo.venta v
INNER JOIN dbo.detalle_venta d ON v.folio = d.folio
INNER JOIN dbo.producto p ON d.codigo_barras = p.codigo_barras
WHERE v.folio = 1;
```

---

### Consulta 6: Ventas a Crédito con Entrega a Domicilio (Renombrado de Roles)
**Nivel de Complejidad:** Avanzada (Múltiples Joins hacia la misma relación con Operador de Renombrado $\rho$)

#### A. Equivalencia en Lenguaje Natural
> *"Obtener el folio, fecha, nombre completo del cliente, nombre completo del repartidor asignado, licencia de conducir y vehículo utilizado, para aquellas ventas realizadas bajo método de pago 'CREDITO' que cuentan con servicio de entrega a domicilio."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
P_{cli} & \leftarrow \rho_{P_{cli}(id\_cli, nom\_cli, pat\_cli, mat\_cli, fn\_cli)}(PERSONA) \\
P_{rep} & \leftarrow \rho_{P_{rep}(id\_rep, nom\_rep, pat\_rep, mat\_rep, fn\_rep)}(PERSONA) \\
V_{cred} & \leftarrow \sigma_{metodo\_pago = 'CREDITO' \land id\_repartidor \ne NULL}(VENTA) \\
R_{final} & \leftarrow \pi_{folio, fecha\_hora, nom\_cli, pat\_cli, nom\_rep, pat\_rep, licencia, vehiculo} \\
& (V_{cred} \bowtie_{V_{cred}.id\_cliente = P_{cli}.id\_cli} P_{cli} \bowtie_{V_{cred}.id\_repartidor = REPARTIDOR.id\_persona} REPARTIDOR \bowtie_{REPARTIDOR.id\_persona = P_{rep}.id\_rep} P_{rep})
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Renombrar `PERSONA` para diferenciar el rol de Cliente del rol de Repartidor:**
   $$P_{cli} \leftarrow \rho_{P_{cli}(\dots)}(PERSONA), \quad P_{rep} \leftarrow \rho_{P_{rep}(\dots)}(PERSONA)$$
2. **Paso 2: Filtrar ventas a crédito con repartidor asignado:**
   $$V_{cred} \leftarrow \sigma_{metodo\_pago = 'CREDITO' \land id\_repartidor \ne NULL}(VENTA)$$
   *Resultado:* Folio 2 ($id\_cliente = 5, id\_repartidor = 2$).
3. **Paso 3: Reunir con $P_{cli}$ para datos del cliente:**
   $$R_1 \leftarrow V_{cred} \bowtie_{id\_cliente = id\_cli} P_{cli}$$
   *(Cliente 5: Ana Luisa Silva)*.
4. **Paso 4: Reunir con `REPARTIDOR` y $P_{rep}$ para datos del repartidor:**
   $$R_2 \leftarrow R_1 \bowtie_{id\_repartidor = REPARTIDOR.id\_persona} REPARTIDOR \bowtie_{REPARTIDOR.id\_persona = id\_rep} P_{rep}$$
   *(Repartidor 2: Roberto Gómez, Licencia: LIC-CDMX-998877, Moto Honda 125)*.
5. **Paso 5: Proyección final de atributos.**

#### D. Tabla Resultante

| folio | fecha_hora | nom_cli | pat_cli | nom_rep | pat_rep | licencia | vehiculo |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 2 | 2026-10-30 10:30 | Ana Luisa | Silva | Roberto | Gómez | LIC-CDMX-998877 | Motocicleta Honda 125 |

#### E. Equivalente en SQL
```sql
SELECT v.folio, v.fecha_hora,
       p_cli.nombre_pila AS nom_cli, p_cli.apellido_paterno AS pat_cli,
       p_rep.nombre_pila AS nom_rep, p_rep.apellido_paterno AS pat_rep,
       r.licencia, r.vehiculo
FROM dbo.venta v
INNER JOIN dbo.persona p_cli ON v.id_cliente = p_cli.id_persona
INNER JOIN dbo.repartidor r ON v.id_repartidor = r.id_persona
INNER JOIN dbo.persona p_rep ON r.id_persona = p_rep.id_persona
WHERE v.metodo_pago = 'CREDITO' AND v.id_repartidor IS NOT NULL;
```

---

### Consulta 7: Productos del Catálogo Nunca Vendidos (Diferencia de Conjuntos)
**Nivel de Complejidad:** Avanzada (Operador Diferencia Relacional $-$ y Antijoin)

#### A. Equivalencia en Lenguaje Natural
> *"Identificar aquellos productos registrados en el inventario de la tienda que jamás han formado parte de ninguna venta (productos sin movimiento en detalle_venta)."*

#### B. Expresión Formal en Álgebra Relacional

$$R_{final} \leftarrow \pi_{codigo\_barras, nombre}(PRODUCTO) - \pi_{PRODUCTO.codigo\_barras, PRODUCTO.nombre}(PRODUCTO \bowtie DETALLE\_VENTA)$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Proyección de todos los productos del catálogo (Universo de productos):**
   $$U_{prod} \leftarrow \pi_{codigo\_barras, nombre}(PRODUCTO)$$

   | codigo_barras | nombre |
   | :--- | :--- |
   | PROD01 | Leche Entera 1L |
   | PROD02 | Pan Integral 680g |
   | PROD03 | Frijol Negro 1kg |
   | PROD04 | Aceite Vegetal 1L |

2. **Paso 2: Proyección de los productos que sí se han vendido al menos una vez:**
   $$V_{prod} \leftarrow \pi_{codigo\_barras, nombre}(PRODUCTO \bowtie DETALLE\_VENTA)$$

   | codigo_barras | nombre |
   | :--- | :--- |
   | PROD01 | Leche Entera 1L |
   | PROD02 | Pan Integral 680g |
   | PROD03 | Frijol Negro 1kg |

3. **Paso 3: Aplicación de la diferencia de conjuntos (resta de relaciones compatibles en esquema):**
   $$R_{final} \leftarrow U_{prod} - V_{prod}$$

#### D. Tabla Resultante

| codigo_barras | nombre |
| :--- | :--- |
| PROD04 | Aceite Vegetal 1L |

#### E. Equivalente en SQL
```sql
SELECT codigo_barras, nombre
FROM dbo.producto
EXCEPT
SELECT p.codigo_barras, p.nombre
FROM dbo.producto p
INNER JOIN dbo.detalle_venta d ON p.codigo_barras = d.codigo_barras;
```

---

### Consulta 8: Directorio Unificado de Teléfonos (Unión de Conjuntos)
**Nivel de Complejidad:** Intermedia-Avanzada (Operador Unión $\cup$ y Compatibilidad de Esquemas)

#### A. Equivalencia en Lenguaje Natural
> *"Generar una libreta unificada de contactos telefónicos que incluya tanto a las personas (clientes y empleados) como a los proveedores registrados, indicando el tipo de contacto, nombre o razón social y el número telefónico."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
T_{per} & \leftarrow \pi_{('PERSONA') \to tipo, (nombre\_pila \ || \ ' \ ' \ || \ apellido\_paterno) \to contacto, telefono}(PERSONA \bowtie TELEFONO\_PERSONA) \\
T_{prov} & \leftarrow \pi_{('PROVEEDOR') \to tipo, razon\_social \to contacto, telefono}(PROVEEDOR \bowtie TELEFONO\_PROVEEDOR) \\
R_{final} & \leftarrow T_{per} \cup T_{prov}
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Construir la relación homogénea de teléfonos de personas:**
   $$T_{per} \leftarrow \pi_{tipo, contacto, telefono}(PERSONA \bowtie TELEFONO\_PERSONA)$$

   | tipo | contacto | telefono |
   | :--- | :--- | :--- |
   | PERSONA | Juan Carlos Pérez | 5512345678 |
   | PERSONA | Juan Carlos Pérez | 5587654321 |
   | PERSONA | Ana Luisa Silva | 5544332211 |

2. **Paso 2: Construir la relación homogénea de teléfonos de proveedores:**
   $$T_{prov} \leftarrow \pi_{tipo, contacto, telefono}(PROVEEDOR \bowtie TELEFONO\_PROVEEDOR)$$

   | tipo | contacto | telefono |
   | :--- | :--- | :--- |
   | PROVEEDOR | Lácteos del Centro S.A. | 5599887766 |

3. **Paso 3: Unión relacional ($T_{per} \cup T_{prov}$):**
   Ambas relaciones tienen el mismo número de atributos e idéntico dominio en sus columnas correspondientes.

#### D. Tabla Resultante

| tipo | contacto | telefono |
| :--- | :--- | :--- |
| PERSONA | Juan Carlos Pérez | 5512345678 |
| PERSONA | Juan Carlos Pérez | 5587654321 |
| PERSONA | Ana Luisa Silva | 5544332211 |
| PROVEEDOR | Lácteos del Centro S.A. | 5599887766 |

#### E. Equivalente en SQL
```sql
SELECT 'PERSONA' AS tipo, 
       CONCAT(p.nombre_pila, ' ', p.apellido_paterno) AS contacto, 
       tp.telefono
FROM dbo.persona p
INNER JOIN dbo.telefono_persona tp ON p.id_persona = tp.id_persona

UNION ALL

SELECT 'PROVEEDOR' AS tipo, 
       pr.razon_social AS contacto, 
       tpr.telefono
FROM dbo.proveedor pr
INNER JOIN dbo.telefono_proveedor tpr ON pr.id_proveedor = tpr.id_proveedor;
```

---

### Consulta 9: Total Vendido y Artículos por Método de Pago (Agregación)
**Nivel de Complejidad:** Avanzada (Álgebra Extendida: Operador de Agrupamiento y Agregación $\mathcal{G}$)

#### A. Equivalencia en Lenguaje Natural
> *"Calcular el monto acumulado total recaudado (\$ pesos) y el número total de unidades vendidas agrupadas por cada método de pago ('EFECTIVO', 'CREDITO', 'TARJETA', etc.)."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
R_1 & \leftarrow \pi_{folio, metodo\_pago}(VENTA) \bowtie \pi_{folio, cantidad, (cantidad \times precio\_unitario) \to subtotal}(DETALLE\_VENTA) \\
R_{final} & \leftarrow {}_{metodo\_pago}\mathcal{G}_{SUM(subtotal) \to total\_recaudado, \ SUM(cantidad) \to unidades\_vendidas}(R_1)
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Pre-calcular subtotales y vincularlos con el método de pago:**
   $$R_1 \leftarrow VENTA \bowtie \pi_{folio, cantidad, (cantidad \times precio\_unitario) \to subtotal}(DETALLE\_VENTA)$$

   | folio | metodo_pago | cantidad | subtotal |
   | :---: | :--- | :---: | :---: |
   | 1 | EFECTIVO | 2 | 49.00 |
   | 1 | EFECTIVO | 1 | 32.00 |
   | 2 | CREDITO | 4 | 98.00 |
   | 3 | TARJETA | 2 | 76.00 |

2. **Paso 2: Aplicar agregación agrupada (${}_{metodo\_pago}\mathcal{G}$):**
   - Agrupa filas por valor único de `metodo_pago`.
   - Aplica $SUM(subtotal)$ y $SUM(cantidad)$ por cada partición.

#### D. Tabla Resultante

| metodo_pago | total_recaudado | unidades_vendidas |
| :--- | :---: | :---: |
| EFECTIVO | 81.00 | 3 |
| CREDITO | 98.00 | 4 |
| TARJETA | 76.00 | 2 |

#### E. Equivalente en SQL
```sql
SELECT v.metodo_pago,
       SUM(d.cantidad * d.precio_unitario) AS total_recaudado,
       SUM(d.cantidad) AS unidades_vendidas
FROM dbo.venta v
INNER JOIN dbo.detalle_venta d ON v.folio = d.folio
GROUP BY v.metodo_pago;
```

---

### Consulta 10: Categorías con Más de un Producto (Filtro Agregado)
**Nivel de Complejidad:** Avanzada (Agregación con Selección posterior — emulación de HAVING)

#### A. Equivalencia en Lenguaje Natural
> *"Obtener el ID, nombre de la categoría y la cantidad total de artículos registrados, únicamente para aquellas categorías que contengan más de un producto en el catálogo."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
A & \leftarrow {}_{id\_categoria}\mathcal{G}_{COUNT(codigo\_barras) \to total\_productos}(PRODUCTO) \\
F & \leftarrow \sigma_{total\_productos > 1}(A) \\
R_{final} & \leftarrow \pi_{CATEGORIA.id\_categoria, CATEGORIA.nombre\_cat, total\_productos}(F \bowtie_{F.id\_categoria = CATEGORIA.id\_categoria} CATEGORIA)
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Conteo agrupado por categoría en `PRODUCTO`:**
   $$A \leftarrow {}_{id\_categoria}\mathcal{G}_{COUNT(codigo\_barras) \to total\_productos}(PRODUCTO)$$

   | id_categoria | total_productos |
   | :---: | :---: |
   | 1 | 1 |
   | 2 | 2 |
   | 3 | 1 |

2. **Paso 2: Selección sobre la relación agrupada ($total\_productos > 1$):**
   $$F \leftarrow \sigma_{total\_productos > 1}(A)$$

   | id_categoria | total_productos |
   | :---: | :---: |
   | 2 | 2 |

3. **Paso 3: Reunión con `CATEGORIA` y proyección final:**
   $$R_{final} \leftarrow \pi_{id\_categoria, nombre\_cat, total\_productos}(F \bowtie CATEGORIA)$$

#### D. Tabla Resultante

| id_categoria | nombre_cat | total_productos |
| :---: | :--- | :---: |
| 2 | Abarrotes | 2 |

#### E. Equivalente en SQL
```sql
SELECT c.id_categoria, c.nombre_cat, COUNT(p.codigo_barras) AS total_productos
FROM dbo.categoria c
INNER JOIN dbo.producto p ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nombre_cat
HAVING COUNT(p.codigo_barras) > 1;
```

---

### Consulta 11: Proveedores que Surten TODOS los Productos de Abarrotes (División)
**Nivel de Complejidad:** Compleja / Teórica (Operador División Relacional $\div$)

#### A. Equivalencia en Lenguaje Natural
> *"Encontrar la razón social y clave de los proveedores que suministran TODOS y cada uno de los productos que pertenecen a la categoría 'Abarrotes'."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
ProdAbarrotes & \leftarrow \pi_{codigo\_barras}(\sigma_{id\_categoria = 2}(PRODUCTO)) \\
ProvProd & \leftarrow \pi_{id\_proveedor, codigo\_barras}(ABASTECIMIENTO) \\
ProvCumplen & \leftarrow ProvProd \div ProdAbarrotes \\
R_{final} & \leftarrow \pi_{id\_proveedor, razon\_social}(ProvCumplen \bowtie PROVEEDOR)
\end{aligned}$$

*Equivalencia en operadores fundamentales (Codd, 1972):*
$$R \div S = \pi_X(R) - \pi_X((\pi_X(R) \times S) - R)$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Conjunto divisor ($S$): Códigos de barras de la categoría Abarrotes:**
   $$ProdAbarrotes \leftarrow \{\text{'PROD02'}, \text{'PROD04'}\}$$
2. **Paso 2: Conjunto dividendo ($R$): Pares $(id\_proveedor, codigo\_barras)$ en `ABASTECIMIENTO`:**
   Supongamos que el Proveedor 1 surte `PROD01`, `PROD02` y `PROD04`; y el Proveedor 2 surte únicamente `PROD02`.
3. **Paso 3: Operación de división ($R \div S$):**
   Busca los $id\_proveedor$ cuyas tuplas asociadas en $R$ cubren la totalidad de los elementos de $S$.
   *Resultado:* $\{1\}$.
4. **Paso 4: Reunión con `PROVEEDOR`:**
   Recupera el nombre o razón social del proveedor 1.

#### D. Tabla Resultante

| id_proveedor | razon_social |
| :---: | :--- |
| 1 | Distribuidora Central de Abarrotes S.A. de C.V. |

#### E. Equivalente en SQL
```sql
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
```

---

### Consulta 12: Estado de Crédito y Folios de Ventas (Left Outer Join)
**Nivel de Complejidad:** Avanzada (Álgebra Extendida: Reunión Externa Izquierda ⟕)

#### A. Equivalencia en Lenguaje Natural
> *"Obtener una lista con todos los clientes registrados, su nombre de pila, límite de crédito autorizado y el folio de las ventas a crédito que han solicitado; asegurando que aparezcan incluso los clientes que nunca han solicitado ventas a crédito (con folio NULL)."*

#### B. Expresión Formal en Álgebra Relacional

$$\begin{aligned}
CliBase & \leftarrow \pi_{id\_persona, nombre\_pila, apellido\_paterno}(PERSONA) \bowtie \pi_{id\_persona, limite\_credito}(CLIENTE) \\
VentasCred & \leftarrow \pi_{folio, id\_cliente}(\sigma_{metodo\_pago = 'CREDITO'}(VENTA)) \\
R_{final} & \leftarrow \pi_{id\_persona, nombre\_pila, apellido\_paterno, limite\_credito, folio}(CliBase ⟕_{CliBase.id\_persona = VentasCred.id\_cliente} VentasCred)
\end{aligned}$$

#### C. Desglose de Relaciones Intermedias

1. **Paso 1: Reconstrucción de la relación de clientes registrados:**
   $$CliBase \leftarrow \pi_{id\_persona, nombre\_pila, apellido\_paterno, limite\_credito}(PERSONA \bowtie CLIENTE)$$

   | id_persona | nombre_pila | apellido_paterno | limite_credito |
   | :---: | :--- | :--- | :---: |
   | 4 | Juan Carlos | Pérez | 1500.00 |
   | 5 | Ana Luisa | Silva | 2000.00 |

2. **Paso 2: Filtrar folios de ventas a crédito:**
   $$VentasCred \leftarrow \pi_{folio, id\_cliente}(\sigma_{metodo\_pago = 'CREDITO'}(VENTA))$$

   | folio | id_cliente |
   | :---: | :---: |
   | 2 | 5 |

3. **Paso 3: Reunión externa izquierda ($CliBase ⟕ VentasCred$):**
   El cliente 4 no tiene ventas a crédito, pero se preserva rellenando la columna `folio` con $\omega$ (valor nulo).

#### D. Tabla Resultante

| id_persona | nombre_pila | apellido_paterno | limite_credito | folio |
| :---: | :--- | :--- | :---: | :---: |
| 4 | Juan Carlos | Pérez | 1500.00 | NULL |
| 5 | Ana Luisa | Silva | 2000.00 | 2 |

#### E. Equivalente en SQL
```sql
SELECT c.id_persona, p.nombre_pila, p.apellido_paterno, c.limite_credito, v.folio
FROM dbo.cliente c
INNER JOIN dbo.persona p ON c.id_persona = p.id_persona
LEFT OUTER JOIN dbo.venta v ON c.id_persona = v.id_cliente AND v.metodo_pago = 'CREDITO';
```

---

## 📊 3. Matriz Sinóptica de Operadores Utilizados

| N.º Consulta | Tipo / Tema Principal | Operadores Principales | Relaciones Involucradas | Complejidad |
| :---: | :--- | :---: | :--- | :---: |
| **Q1** | Stock crítico para abastecimiento | $\sigma, \pi$ | `PRODUCTO` | Básica |
| **Q2** | Margen bruto unitario | $\pi$ generalizada, $\sigma$ | `PRODUCTO` | Básica-Intermedia |
| **Q3** | Catálogo con categoría | $\bowtie, \sigma, \pi$ | `PRODUCTO`, `CATEGORIA` | Intermedia |
| **Q4** | Especialización cajeros | $\bowtie, \sigma, \pi$ | `PERSONA`, `EMPLEADO`, `CAJERO` | Intermedia |
| **Q5** | Detalle de renglones de venta | $\bowtie, \pi$ generalizada | `VENTA`, `DETALLE_VENTA`, `PRODUCTO` | Intermedia |
| **Q6** | Entrega a domicilio a crédito | $\bowtie, \rho, \sigma, \pi$ | `VENTA`, `PERSONA` (x2), `REPARTIDOR` | Avanzada |
| **Q7** | Productos nunca vendidos | $-, \bowtie, \pi$ | `PRODUCTO`, `DETALLE_VENTA` | Avanzada |
| **Q8** | Libreta telefónica unificada | $\cup, \bowtie, \pi$ | `PERSONA`, `TEL_PER`, `PROV`, `TEL_PROV` | Avanzada |
| **Q9** | Total vendido por método de pago | $\mathcal{G}, \bowtie, \pi$ | `VENTA`, `DETALLE_VENTA` | Avanzada |
| **Q10** | Categorías con >1 producto (Having) | $\mathcal{G}, \sigma, \bowtie, \pi$ | `PRODUCTO`, `CATEGORIA` | Avanzada |
| **Q11** | Proveedores totales de abarrotes | $\div, \bowtie, \sigma, \pi$ | `ABASTECIMIENTO`, `PRODUCTO`, `PROVEEDOR` | Compleja |
| **Q12** | Saldos y folios con preservación | $⟕, \bowtie, \sigma, \pi$ | `CLIENTE`, `PERSONA`, `VENTA` | Avanzada |

---

## 📚 Referencias (APA 7)

* Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377–387. https://doi.org/10.1145/362384.362685
* Codd, E. F. (1972). Relational completeness of data base sublanguages. En R. Rustin (Ed.), *Data base systems* (pp. 65–98). Prentice-Hall.
* Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson/Addison-Wesley.
* Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.
* Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7.ª ed.). McGraw-Hill Education.
