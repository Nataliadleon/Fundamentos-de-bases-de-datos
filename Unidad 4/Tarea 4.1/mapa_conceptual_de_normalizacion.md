# Mapa conceptual: Reglas y formas normales en el diseño de bases de datos

![DiagramaNormalizacion.png](DiagramaNormalizacion.png)

**Fuente vectorial o de referencia:** Diagrama estructural de las Formas Normales (1FN a 5FN).

## Estructura del mapa

El concepto central es el **Diseño de Base de Datos**, del cual se desprenden de manera secuencial las distintas formas normales y sus reglas correspondientes:

| Rama / Nivel | Frase de enlace | Contenido |
|---|---|---|
| Primera Forma Normal (1FN) | *se fundamenta en* | Atributos atómicos y sin grupos repetitivos |
| Segunda Forma Normal (2FN) | *requiere* | Estar en 1FN y eliminar dependencias parciales de la clave primaria |
| Tercera Forma Normal (3FN) | *requiere* | Estar en 2FN y eliminar dependencias transitivas entre atributos no clave |
| Forma Normal de Boyce-Codd (FNBC) | *requiere* | Estar en 3FN y asegurar que todo determinante $X$ sea superclave |
| Cuarta Forma Normal (4FN) | *requiere* | Estar en FNBC y eliminar dependencias multivaluadas independientes |
| Quinta Forma Normal (5FN) | *requiere* | Estar en 4FN y eliminar dependencias de unión |

## Relaciones entre las Formas Normales

Las formas normales siguen una progresión estricta de cumplimiento jerárquico: para alcanzar una forma normal superior, la estructura de la base de datos **debe cumplir obligatoriamente con la forma normal previa**, aplicando reglas específicas en cada nivel para eliminar anomalías de redundancia y dependencia funcional.

## Referencias

* Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of Database Systems* (7th ed.). Pearson.
* Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database System Concepts* (7th ed.). McGraw-Hill Education.