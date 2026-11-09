# 🗄️ Fundamentos de Bases de Datos

Repositorio de evidencias, tareas y proyectos de la materia **Fundamentos de Bases de Datos**.

---

## 🎓 Información Académica

- **Institución:** Tecnológico Nacional de México
- **Carrera:** Ingeniería Informática
- **Materia:** Fundamentos de Base de Datos
- **Alumna:** Gabriela Natalia De León Alvarez
- **Matrícula:** I24050006

---

## 📂 Contenido del Repositorio

### [Unidad 1](Unidad%201/)

* **[Tarea 1.1: Fundamentos, objetivos y modelos de bases de datos](Unidad%201/Tarea1.1/)**
  * Mapa conceptual analítico (conceptos fundamentales, objetivos y aplicaciones).
  * Tabla comparativa de modelos de bases de datos (jerárquico, red, relacional, OO, NoSQL, etc.).
  * Documento formal en formato PDF: `Tarea1.1BasesDeDatos.pdf`.
  * Documentación detallada en Markdown y diagramas.

* **[Tarea 1.2: Arquitectura ANSI/SPARC y SGBD](Unidad%201/Tarea1.2/)**
  * Arquitectura de tres niveles (físico, conceptual, externo) y arquitectura funcional interna de un SGBD.
  * Cuadro sinóptico y diagramas en Mermaid (`CuadroSinoptico.mmd`).
  * Documento formal en formato PDF: `Tarea1.2.pdf`.
  * Documentación teórica y explicaciones.

### [Unidad 2](Unidad%202/)

* **[Tarea 2.1: Modelado conceptual E-R y E-R Extendido de un caso real](Unidad%202/Tarea2.1/)**
  * Modelado conceptual de una tienda de abarrotes con el modelo Entidad-Relación y sus extensiones.
  * Descripción del caso, reglas de negocio, entidades, atributos, relaciones y diagrama formal en notación Chen.
  * Conceptos del E-R extendido: especialización/generalización, jerarquías y agregación.
  * Documento formal en formato PDF: `Tarea2.1.pdf`.
  * Documentación detallada en Markdown y diagramas.

* **[Tarea 2.2: Transición de diagrama E-R a notación UML](Unidad%202/Tarea2.2/)**
  * Conversión del diagrama E-R extendido de la tienda de abarrotes a un diagrama de clases UML.
  * Comparativa detallada E-R vs. UML: entidades ↔ clases, atributos ↔ propiedades, relaciones ↔ asociaciones.
  * Análisis de coincidencias para el desarrollo orientado a objetos.
  * Documento formal en formato PDF: `Tarea2.2.pdf`.
  * Documentación detallada en Markdown y diagramas.

### [Unidad 3](Unidad%203/)

* **[Tarea 3.1: Transformación de Modelo E-R a Esquema Relacional y Reglas de Integridad](Unidad%203/Tarea%203.1/)**
  * Transformación del modelo E-R y UML al esquema físico relacional de la tienda de abarrotes.
  * Definición de tablas, tipos de datos, claves primarias y foráneas.
  * Resolución de herencia, atributos multivalorados y tablas intermedias para relaciones M:N.
  * Documento formal en formato PDF: `Tarea3.1.pdf`.
  * Diagrama en Mermaid: `Esquema Fisico.mmd`.

* **[Tarea 3.2: Generación del esquema físico en SGBD y script LDD](Unidad%203/Tarea%203.2/)**
  * Implementación del esquema físico relacional de la tienda de abarrotes en SQL Server.
  * Definición de tablas, tipos de datos, claves primarias y foráneas.
  * Resolución de herencia, atributos multivalorados y tablas intermedias para relaciones M:N.
  * Documento formal en formato PDF: `Tarea3.2.pdf`.

### [Unidad 4](Unidad%204/)

* **[Tarea 4.1: Lenguaje SQL DML y Restricciones](Unidad%204/Tarea%204.1/)**
  * Consultas formales de normalización, las dependencias funcionales (completas y parciales), dependencias transitivas y las anomalías clásicas (inserción, borrado, modificación).
  * Mapa Conceptual de normalización.
  * Documento formal en formato PDF: `Tarea4.1.pdf`.
  * Documentación detallada en Markdown y diagramas.

* **[Tarea 4.2: Normalización de Bases de Datos (De 0FN a 3FN/FNBC y Script SQL)](Unidad%204/Tarea%204.2/)**
  * Transición metodológica paso a paso de una estructura desnormalizada del proyecto (registro universal de ventas) a 1FN, 2FN, 3FN y validación FNBC.
  * Eliminación sistemática de grupos repetitivos, dependencias parciales y dependencias transitivas.
  * Diagramas de flujo en Mermaid y análisis comparativo de anomalías.
  * Nuevo script DDL/DML corregido en SQL Server: `schema_normalizado.sql`.
  * Documentación técnica detallada: `transicion-normalizacion.md`.

### [Unidad 5](Unidad%205/)

* **[Tarea 5.1: Mapa conceptual de operadores del álgebra relacional](Unidad%205/Tarea5.1/)**
  * Notación formal y significado de los operadores unarios (selección, proyección, renombrado), binarios (unión, intersección, diferencia, producto cartesiano, join, división) y extendidos (agregación, proyecciones generalizadas, outer joins).
  * Mapa conceptual en formato gráfico y vectorial.
  * Documento formal en formato PDF: `Tarea5.1.pdf`.
  * Marco teórico detallado en Markdown: `algebra-relacional.md`.

* **[Tarea 5.2: Resolución de consultas sobre el esquema relacional con álgebra formal](Unidad%205/Tarea5.2/)**
  * Catálogo formal de 12 consultas relacionales de complejidad progresiva (básicas, intermedias y avanzadas) aplicadas sobre el esquema normalizado de la tienda de abarrotes.
  * Formulación matemática en álgebra relacional con operadores canónicos y extendidos ($\sigma, \pi, \rho, \bowtie, -, \cup, \div, \mathcal{G}, ⟕$).
  * Desglose procedimental de relaciones y esquemas intermedios con datos de prueba evaluados paso a paso.
  * Equivalencias declarativas en lenguaje SQL Server (T-SQL).
  * Documento analítico en Markdown: `consultas-algebra-relacional.md`.
  * Script SQL ejecutable en SQL Server: `consultas_algebra_relacional.sql`.

---

## 🛠️ Herramientas Utilizadas

- **Documentación:** Markdown, KaTeX
- **Diagramas:** Mermaid.js, draw.io
- **SGBD:** Microsoft SQL Server (T-SQL)
- **Control de versiones:** Git y GitHub
