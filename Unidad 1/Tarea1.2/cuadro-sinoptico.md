# Cuadro sinóptico: clasificación de las bases de datos

## Vista previa

![Cuadro sinóptico: clasificación de las bases de datos](cuadrosinoptico.png)

**Fuente vectorial:** [`mbddSinoptico.svg`](mbddSinoptico.svg)

## Versión en Mermaid

GitHub muestra este diagrama directamente. Su código fuente está en [`CuadroSinoptico.mmd`](CuadroSinoptico.mmd).

```mermaid
flowchart LR
    R["CLASIFICACIÓN<br/>DE LAS BASES<br/>DE DATOS"]

    R --> U["Según su<br/>ubicación"]
    R --> V["Según la<br/>variabilidad<br/>de los datos"]
    R --> M["Según el<br/>modelo de datos"]
    R --> C["Según su<br/>contenido"]
    R --> P["Según su<br/>propósito de uso"]
    R --> N["Según el número<br/>de usuarios"]

    U --> U1["Centralizadas"]
    U --> U2["Distribuidas"]
    U --> U3["En la nube (DBaaS)"]
    U2 --> U21["Homogéneas"]
    U2 --> U22["Heterogéneas"]

    V --> V1["Estáticas<br/>(históricas, solo lectura)"]
    V --> V2["Dinámicas<br/>(lectura y escritura continua)"]

    M --> M1["Jerárquicas"]
    M --> M2["De red"]
    M --> M3["Relacionales"]
    M --> M4["Orientadas a objetos"]
    M --> M5["Objeto-relacionales"]
    M --> M6["NoSQL"]
    M --> M7["Multidimensionales"]

    C --> C1["Bibliográficas"]
    C --> C2["De texto completo"]
    C --> C3["Directorios"]
    C --> C4["Especializadas<br/>(científicas, geográficas, multimedia)"]

    P --> P1["Transaccionales (OLTP)"]
    P --> P2["Analíticas (OLAP /<br/>almacén de datos)"]
    P --> P3["De propósito general<br/>o específico"]

    N --> N1["Monousuario"]
    N --> N2["Multiusuario"]

    classDef raiz fill:#1B2A41,color:#fff,stroke:#0B1320
    classDef cat fill:#1F6FB2,color:#fff,stroke:#134a78
    classDef hoja fill:#DAE8FC,color:#000,stroke:#6C8EBF
    class R raiz
    class U,V,M,C,P,N cat
    class U1,U2,U3,U21,U22,V1,V2,M1,M2,M3,M4,M5,M6,M7,C1,C2,C3,C4,P1,P2,P3,N1,N2 hoja
```

## Descripción de los criterios

| Criterio | Categorías | Descripción |
|---|---|---|
| **Ubicación** | Centralizadas | Los datos residen en un solo sitio o servidor. |
| | Distribuidas (homogéneas / heterogéneas) | Los datos se reparten en varios sitios conectados por red. Son homogéneas si todos usan el mismo SGBD y heterogéneas si no. |
| | En la nube (DBaaS) | La base de datos se ofrece como servicio por un proveedor externo. |
| **Variabilidad de los datos** | Estáticas | Datos históricos de solo lectura, usados para consulta y análisis. |
| | Dinámicas | Los datos cambian de forma continua (altas, bajas y modificaciones). |
| **Modelo de datos** | Jerárquicas, de red, relacionales, orientadas a objetos, objeto-relacionales, NoSQL y multidimensionales | Según cómo se representan los datos (ver Tarea 1.1). |
| **Contenido** | Bibliográficas, texto completo, directorios y especializadas | Según el tipo de información que almacenan. |
| **Propósito de uso** | Transaccionales (OLTP) y analíticas (OLAP) | OLTP atiende las operaciones diarias; OLAP apoya el análisis y la toma de decisiones. |
| **Número de usuarios** | Monousuario y multiusuario | Si el sistema atiende a un usuario a la vez o a muchos de forma concurrente. |

> Un mismo sistema puede pertenecer a varias categorías a la vez (por ejemplo, relacional, dinámica, distribuida y transaccional).

## Referencias

Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.

Özsu, M. T., & Valduriez, P. (2020). *Principles of distributed database systems* (4.ª ed.). Springer. https://doi.org/10.1007/978-3-030-26253-2

Silberschatz, A., Korth, H. F., & Sudarshan, S. (2010). *Database system concepts* (6.ª ed.). McGraw-Hill.
