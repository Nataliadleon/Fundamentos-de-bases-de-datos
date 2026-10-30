# Arquitectura de tres niveles (ANSI/SPARC) y arquitectura funcional del SGBD

> Tarea 1.2, punto 2: describe y esquematiza la arquitectura de tres niveles de una base de datos (físico, conceptual, externo) y la arquitectura funcional interna del SGBD.

## 1. Arquitectura de tres niveles (ANSI/SPARC)

El grupo de estudio ANSI/X3/SPARC (1975) propuso una arquitectura de tres niveles de abstracción cuyo objetivo principal es **separar la vista del usuario de la forma en que los datos se almacenan físicamente**, logrando independencia de los datos (Date, 2004; Tsichritzis & Klug, 1978).

```mermaid
flowchart TB
    subgraph USR["Usuarios y aplicaciones"]
        A1["Usuario final"]
        A2["Aplicación"]
        A3["Analista"]
    end

    subgraph EXT["NIVEL EXTERNO (vistas del usuario)"]
        E1["Vista 1"]
        E2["Vista 2"]
        E3["Vista n"]
    end

    MAP1{{"Correspondencia<br/>externo / conceptual"}}

    subgraph CON["NIVEL CONCEPTUAL (esquema lógico global)"]
        C1["Entidades, atributos,<br/>relaciones y restricciones<br/>de toda la base de datos"]
    end

    MAP2{{"Correspondencia<br/>conceptual / interno"}}

    subgraph INT["NIVEL INTERNO / FÍSICO (almacenamiento)"]
        I1["Archivos, registros,<br/>índices y rutas de acceso"]
    end

    D[("Almacenamiento<br/>físico en disco")]

    A1 --> E1
    A2 --> E2
    A3 --> E3
    E1 --> MAP1
    E2 --> MAP1
    E3 --> MAP1
    MAP1 --> C1
    C1 --> MAP2
    MAP2 --> I1
    I1 --> D

    classDef ext fill:#D5E8D4,stroke:#82B366,color:#000
    classDef con fill:#FFE6CC,stroke:#D79B00,color:#000
    classDef int fill:#E1D5E7,stroke:#9673A6,color:#000
    classDef map fill:#fff,stroke:#666,stroke-dasharray:4 3,color:#000
    class E1,E2,E3 ext
    class C1 con
    class I1,D int
    class MAP1,MAP2 map
```

**Fuente editable:** [`diagramas/arquitectura-tres-niveles.mmd`](diagramas/arquitectura-tres-niveles.mmd)

| Nivel | Qué describe | Quién lo utiliza |
|---|---|---|
| **Externo (vistas)** | La parte de la base de datos que interesa a cada grupo de usuarios o aplicación, ocultando el resto. | Usuarios finales y aplicaciones |
| **Conceptual (lógico)** | La estructura lógica de toda la base de datos: entidades, atributos, relaciones y restricciones, sin detalles de almacenamiento. | Administrador de la base de datos (DBA) |
| **Interno (físico)** | Cómo se almacenan los datos: archivos, formatos de registro, índices y rutas de acceso. | SGBD y personal de sistemas |

### Correspondencias (mapeos) e independencia de los datos

Cada par de niveles se conecta mediante una transformación: la **externo/conceptual** y la **conceptual/interna**. Gracias a ellas se obtienen dos tipos de independencia:

- **Independencia lógica:** se puede cambiar el esquema conceptual (por ejemplo, agregar un atributo) sin modificar las vistas ni las aplicaciones.
- **Independencia física:** se puede cambiar el almacenamiento (por ejemplo, un nuevo índice o un nuevo disco) sin alterar el esquema conceptual.

## 2. Arquitectura funcional del SGBD

Un SGBD se organiza en módulos que cooperan para atender las solicitudes de los usuarios. Se agrupan principalmente en el **procesador de consultas** y el **gestor de almacenamiento** (Silberschatz et al., 2010).

```mermaid
flowchart TB
    subgraph US["Usuarios"]
        U1["Usuarios ingenuos<br/>(aplicaciones)"]
        U2["Programadores<br/>de aplicaciones"]
        U3["Usuarios sofisticados<br/>(consultas)"]
        U4["Administrador<br/>de BD (DBA)"]
    end

    subgraph IF["Interfaces"]
        F1["Interfaz de<br/>aplicación"]
        F2["Precompilador y<br/>compilador DML"]
        F3["Intérprete<br/>de consultas"]
        F4["Intérprete DDL"]
    end

    subgraph QP["PROCESADOR DE CONSULTAS"]
        Q1["Compilador y<br/>analizador de consultas"]
        Q2["Optimizador<br/>de consultas"]
        Q3["Motor de evaluación<br/>de consultas"]
    end

    subgraph SM["GESTOR DE ALMACENAMIENTO"]
        S1["Gestor de autorización<br/>e integridad"]
        S2["Gestor de<br/>transacciones"]
        S3["Gestor de<br/>archivos"]
        S4["Gestor de<br/>memoria intermedia (buffer)"]
    end

    subgraph DK["ALMACENAMIENTO EN DISCO"]
        K1[("Archivos<br/>de datos")]
        K2[("Índices")]
        K3[("Diccionario de datos<br/>(catálogo)")]
        K4[("Estadísticas")]
    end

    U1 --> F1
    U2 --> F2
    U3 --> F3
    U4 --> F4
    F1 --> Q1
    F2 --> Q1
    F3 --> Q1
    F4 --> K3
    Q1 --> Q2
    Q2 --> Q3
    Q3 --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    S4 --> K1
    S4 --> K2
    S3 --> K3
    Q2 -.consulta.-> K4

    classDef qp fill:#DAE8FC,stroke:#6C8EBF,color:#000
    classDef sm fill:#FFE6CC,stroke:#D79B00,color:#000
    classDef dk fill:#E1D5E7,stroke:#9673A6,color:#000
    class Q1,Q2,Q3 qp
    class S1,S2,S3,S4 sm
    class K1,K2,K3,K4 dk
```

**Fuente editable:** [`diagramas/arquitectura-sgbd.mmd`](diagramas/arquitectura-sgbd.mmd)

| Módulo | Función |
|---|---|
| **Compilador / analizador de consultas** | Traduce las consultas a una forma interna y verifica su sintaxis. |
| **Optimizador de consultas** | Elige el plan de ejecución más eficiente apoyándose en las estadísticas. |
| **Motor de evaluación de consultas** | Ejecuta el plan y obtiene el resultado. |
| **Gestor de autorización e integridad** | Comprueba permisos y restricciones de integridad. |
| **Gestor de transacciones** | Garantiza que las operaciones sean atómicas, consistentes y recuperables ante fallos, y controla la concurrencia. |
| **Gestor de archivos** | Administra la asignación del espacio en disco y las estructuras de datos. |
| **Gestor de memoria intermedia (buffer)** | Trae bloques de disco a memoria principal y decide qué conservar. |
| **Intérprete DDL** | Procesa las definiciones del esquema y las guarda en el diccionario de datos. |
| **Diccionario de datos (catálogo)** | Almacena los metadatos: esquemas, restricciones y permisos. |

## 3. Flujo de datos entre los niveles de abstracción y los módulos del SGBD

```mermaid
sequenceDiagram
    actor Usuario
    participant Ext as Nivel externo (vista)
    participant Con as Nivel conceptual
    participant QP as Procesador de consultas
    participant SM as Gestor de almacenamiento
    participant Disco as Almacenamiento físico

    Usuario->>Ext: Consulta sobre una vista
    Ext->>Con: Transformación externo/conceptual
    Con->>QP: Consulta sobre el esquema lógico
    QP->>QP: Analiza, optimiza y genera el plan de ejecución
    QP->>SM: Solicita datos (transformación conceptual/interno)
    SM->>SM: Verifica autorización y controla la transacción
    SM->>Disco: Lee bloques mediante buffer, archivos e índices
    Disco-->>SM: Bloques de datos
    SM-->>QP: Registros recuperados
    QP-->>Con: Resultado
    Con-->>Ext: Formato de la vista
    Ext-->>Usuario: Resultado final
```

**Fuente editable:** [`diagramas/flujo-de-datos.mmd`](diagramas/flujo-de-datos.mmd)

Una consulta formulada sobre una vista (nivel externo) se transforma al esquema conceptual y llega al procesador de consultas, que la analiza y optimiza. El gestor de almacenamiento verifica permisos, controla la transacción y lee los bloques necesarios del disco mediante el buffer. Los datos recuperados regresan por el mismo camino: se organizan según el esquema conceptual y se presentan con el formato de la vista del usuario.

## Referencias

ANSI/X3/SPARC Study Group on Data Base Management Systems. (1975). Interim report. *FDT – Bulletin of ACM SIGMOD, 7*(2).

Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson/Addison-Wesley.

Silberschatz, A., Korth, H. F., & Sudarshan, S. (2010). *Database system concepts* (6.ª ed.). McGraw-Hill.

Tsichritzis, D., & Klug, A. (1978). The ANSI/X3/SPARC DBMS framework report of the study group on database management systems. *Information Systems, 3*(3), 173-191.
