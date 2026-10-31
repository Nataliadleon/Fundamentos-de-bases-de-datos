# Tarea 3.1: Diseño del esquema físico relacional de la tienda de abarrotes

📍 [Fundamentos de Bases de Datos](../../README.md) › [Unidad 3](../../README.md#unidad-3) › **Tarea 3.1**

**Tecnológico Nacional de México**
**Carrera:** Ingeniería Informática
**Materia:** Fundamentos de Base de Datos
**Unidad:** 3
**Alumna:** Gabriela Natalia De León Alvarez
**Matrícula:** I24050006


---

## 📌 Descripción

Transformación del modelo conceptual E-R y del diagrama de clases UML (Unidades 2.1 y 2.2) al **esquema físico relacional** de la base de datos para la **tienda de abarrotes de barrio**, definiendo:

1. **Tablas** con sus columnas, tipos de datos específicos (int, nvarchar, decimal, date, datetime2, char, varchar) y restricciones.
2. **Claves primarias (PK)** simples y compuestas.
3. **Claves foráneas (FK)** que implementan las relaciones del modelo conceptual.
4. **Resolución de herencia** (PERSONA → CLIENTE / EMPLEADO → CAJERO / REPARTIDOR) y de atributos multivalorados (TELEFONO_PERSONA, TELEFONO_PROVEEDOR).
5. **Tablas intermedias** para relaciones M:N (ABASTECIMIENTO, DETALLE_VENTA) y entidades derivadas de la agregación (PEDIDO_REABASTECIMIENTO).

## 📂 Contenido de la carpeta

| Archivo | Descripción |
|---|---|
| [Tarea3.1.pdf](Tarea3.1.pdf) | Documento formal con el esquema físico, justificaciones y referencias APA |
| [Esquema Fisico.mmd](Esquema%20Fisico.mmd) | Código Mermaid del diagrama entidad-relación físico |

## 🗺️ Vista previa del diagrama

![Esquema físico relacional de la tienda de abarrotes](Esquema%20Fisico.png)

## 🛠️ Herramientas utilizadas

- [draw.io (diagrams.net)](https://app.diagrams.net/) para el diseño y exportación del esquema
- [Mermaid](https://mermaid.js.org/) para la versión en código del diagrama
- GitHub para el alojamiento

## 📚 Referencias (APA 7)

Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.

Silberschatz, A., Korth, H. F., & Sudarshan, S. (2010). *Database system concepts* (6.ª ed.). McGraw-Hill.

