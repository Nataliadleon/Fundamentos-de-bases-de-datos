# Tarea 5.2: Resolución de Consultas sobre el Esquema Relacional con Álgebra Formal

📍 [Fundamentos de Bases de Datos](../../README.md) › [Unidad 5](../../README.md#unidad-5) › **Tarea 5.2**

**Tecnológico Nacional de México**  
**Carrera:** Ingeniería Informática  
**Materia:** Fundamentos de Base de Datos  
**Unidad:** 5 — Álgebra Relacional y Lenguajes Formales de Consulta  
**Alumna:** Gabriela Natalia De León Alvarez  
**Matrícula:** I24050006  

---

## 📌 Descripción

Esta carpeta contiene la resolución formal de un catálogo de **12 consultas relacionales** de complejidad progresiva formuladas sobre el esquema relacional normalizado (3FN / FNBC) del proyecto de la **tienda de abarrotes de barrio** (Tarea 4.2):

1. **Requerimiento en Lenguaje Natural:** Especificación clara de la necesidad de información del negocio.
2. **Expresión Formal en Álgebra Relacional:** Formulación matemática rigurosa utilizando la notación canónica de operadores unarios ($\sigma$, $\pi$, $\rho$), binarios ($\bowtie$, $\times$, $-$, $\cup$, $\cap$, $\div$) y extendidos ($\mathcal{G}$, $⟕$).
3. **Desglose de Relaciones Intermedias:** Secuencia procedimental paso a paso ($R_1, R_2, \dots, R_{final}$) indicando esquemas intermedios y tablas resultantes con datos de prueba reales.
4. **Equivalencia en SQL:** Implementación declarativa estándar en Transact-SQL (SQL Server) para contrastar el modelo procedimental con el lenguaje comercial.

---

## 📂 Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| [consultas-algebra-relacional.md](consultas-algebra-relacional.md) | Catálogo formal completo con las 12 consultas resueltas, tablas intermedias paso a paso, equivalencias en SQL y matriz sinóptica |
| [consultas_algebra_relacional.sql](consultas_algebra_relacional.sql) | Script ejecutable en Microsoft SQL Server (T-SQL) con las 12 consultas catalogadas y verificación automática de entorno |

---

## 🧭 Resumen del Catálogo de Consultas

| N.º | Requerimiento de Información | Operadores del Álgebra Relacional | Nivel de Complejidad |
| :---: | :--- | :---: | :---: |
| **Q1** | Productos con stock actual crítico para reabastecimiento | $\sigma, \pi$ | Básica |
| **Q2** | Margen de ganancia unitario bruto mayor a \$10.00 | $\pi$ generalizada, $\sigma$ | Básica-Intermedia |
| **Q3** | Catálogo de productos con el nombre descriptivo de su categoría | $\bowtie, \sigma, \pi$ | Intermedia |
| **Q4** | Reconstrucción de la jerarquía de herencia: cajeros del turno vespertino | $\bowtie, \sigma, \pi$ | Intermedia |
| **Q5** | Detalle de artículos, cantidades y subtotales de una venta específica | $\bowtie, \pi$ extendida | Intermedia |
| **Q6** | Ventas a crédito con entrega a domicilio y doble rol de persona | $\bowtie, \rho, \sigma, \pi$ | Avanzada |
| **Q7** | Identificación de productos del inventario nunca vendidos | $-, \bowtie, \pi$ (Diferencia) | Avanzada |
| **Q8** | Directorio unificado de teléfonos de personas y proveedores | $\cup, \bowtie, \pi$ (Unión) | Avanzada |
| **Q9** | Total recaudado y unidades vendidas agrupadas por método de pago | $\mathcal{G}, \bowtie, \pi$ (Agregación) | Avanzada |
| **Q10** | Categorías con más de un producto registrado en el inventario | $\mathcal{G}, \sigma, \bowtie, \pi$ (Having) | Avanzada |
| **Q11** | Proveedores que surten todos los productos de la categoría abarrotes | $\div, \bowtie, \sigma, \pi$ (División) | Compleja |
| **Q12** | Clientes con su límite de crédito y ventas a crédito asociadas | $⟕, \bowtie, \sigma, \pi$ (Left Join) | Avanzada |

---

## 🛠️ Herramientas utilizadas

- **Modelado Formal:** Álgebra Relacional (Notación matemática Codd / Elmasri & Navathe)
- **Documentación:** Markdown, KaTeX
- **Motor SGBD:** Microsoft SQL Server
- **Control de Versiones:** Git y GitHub

---

## 📚 Referencias (APA 7)

Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377–387. https://doi.org/10.1145/362384.362685

Codd, E. F. (1972). Relational completeness of data base sublanguages. En R. Rustin (Ed.), *Data base systems* (pp. 65–98). Prentice-Hall.

Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson/Addison-Wesley.

Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.

Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7.ª ed.). McGraw-Hill Education.

