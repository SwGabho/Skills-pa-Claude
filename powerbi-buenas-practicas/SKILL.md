---
name: powerbi-buenas-practicas
description: Reglas detalladas de DAX, Power Query (M) y modelado semántico en Power BI. Úsala antes de escribir, revisar u optimizar medidas DAX, consultas M, tablas, columnas o relaciones de un modelo.
---

# Buenas prácticas de Power BI

## Convenciones de nombres (si el proyecto no tiene las suyas)

| Objeto | Convención | Ejemplo |
|---|---|---|
| Tablas de hechos | `Fact_` + PascalCase | `Fact_Ventas` |
| Dimensiones | `Dim_` + PascalCase | `Dim_Cliente` |
| Medidas | Nombre de negocio legible | `Ventas Totales`, `Margen %` |
| Medidas auxiliares | Prefijo `_` y ocultas | `_Ventas Base` |
| Claves técnicas | Ocultas en la vista de reporte | `ClienteKey` |
| Consultas M auxiliares | `fx`, `p` o `stg_` | `fxLimpiarTexto`, `pServidor` |
| Variables DAX | Prefijo `_` | `VAR _Total = ...` |
| Tabla calendario | Siempre `Dim_Calendario`, columna de fecha `[Fecha]` | `'Dim_Calendario'[Fecha]` |

Las medidas auxiliares y las variables comparten el prefijo `_`, pero son objetos distintos: una medida `_X` vive en el modelo y está oculta; una variable `_X` solo existe dentro de su expresión.

## DAX

- Usar `VAR` / `RETURN` para que se lea mejor y no se recalcule lo mismo.
- `DIVIDE()` en lugar de `/`.
- Columnas siempre con su tabla (`'Dim_Cliente'[Region]`); medidas sin tabla (`[Ventas Totales]`).
- En `CALCULATE`, filtrar por columnas y no por tablas completas: evitar `FILTER(Tabla, ...)` cuando basta un predicado.
- Evitar columnas calculadas si una medida o Power Query lo resuelve.
- Evitar `IFERROR` e `ISERROR`; usar `DIVIDE`, `COALESCE` o `IF(ISBLANK(...))`.
- Sin dato, devolver `BLANK()` en lugar de 0 o texto, salvo que se pida otra cosa.
- Formato estilo DAX Formatter, con indentación de 4 espacios.
- Toda medida nueva lleva `formatString`, `displayFolder` y `description`.

### Patrones

- Medidas base simples (`SUM`) y medidas derivadas que las reutilizan.
- Inteligencia de tiempo siempre sobre la tabla calendario.
- Grupos de cálculo para variantes de tiempo (YTD, PY, YoY) cuando se repiten en muchas medidas.
- Parámetros de campo para elegir métricas o dimensiones de forma dinámica.

### Plantillas

Replica este formato: variables, `DIVIDE`, una función por línea y la tabla `Dim_Calendario`.

```dax
Ventas Totales =
SUM ( 'Fact_Ventas'[Importe] )
```

```dax
Ventas YoY % =
VAR _Actual = [Ventas Totales]
VAR _AnioAnterior =
    CALCULATE ( [Ventas Totales], SAMEPERIODLASTYEAR ( 'Dim_Calendario'[Fecha] ) )
RETURN
    DIVIDE ( _Actual - _AnioAnterior, _AnioAnterior )
```

```dax
Ventas YTD =
CALCULATE ( [Ventas Totales], DATESYTD ( 'Dim_Calendario'[Fecha] ) )
```

```dax
Ranking Cliente =
IF (
    ISINSCOPE ( 'Dim_Cliente'[Cliente] ),
    RANKX ( ALLSELECTED ( 'Dim_Cliente'[Cliente] ), [Ventas Totales], , DESC, DENSE )
)
```

Tabla calendario estándar (si el proyecto no tiene una propia; ajusta el rango a los datos):

```dax
Dim_Calendario =
VAR _Inicio = DATE ( YEAR ( MIN ( 'Fact_Ventas'[Fecha] ) ), 1, 1 )
VAR _Fin = DATE ( YEAR ( MAX ( 'Fact_Ventas'[Fecha] ) ), 12, 31 )
RETURN
    ADDCOLUMNS (
        CALENDAR ( _Inicio, _Fin ),
        "Anio", YEAR ( [Date] ),
        "Mes Num", MONTH ( [Date] ),
        "Mes", FORMAT ( [Date], "mmm" ),
        "Anio Mes", FORMAT ( [Date], "yyyy-mm" ),
        "Trimestre", "T" & QUARTER ( [Date] ),
        "Dia Semana Num", WEEKDAY ( [Date], 2 )
    )
```

Después, renombra `[Date]` a `[Fecha]`, marca la tabla como tabla de fechas, ordena `Mes` por `Mes Num` y relaciónala con la fecha de cada hecho.

## Power Query (M)

- Mantener el *query folding* el mayor tiempo posible; los pasos que lo rompen van al final.
- Nombres de pasos descriptivos (nunca `Columna personalizada1`).
- Tipos de datos explícitos.
- Quitar las columnas que no se usan lo antes posible.
- Parametrizar servidor, base de datos, rutas y entorno (`pServidor`, `pBaseDatos`, `pEntorno`).
- `try ... otherwise` solo donde se espera el error, nunca para esconder problemas de datos.

## Modelo

- Preferir Import; usar DirectQuery o Direct Lake solo si el volumen o la latencia lo exigen.
- Ocultar claves y columnas técnicas; *Summarize By = None* en columnas no aditivas.
- Reducir cardinalidad: separar fecha y hora, redondear decimales, quitar columnas de alta cardinalidad que no se usan.
- Validar con Best Practice Analyzer cuando esté disponible.

## Rendimiento

- Diagnosticar con Performance Analyzer, DAX Studio (Server Timings) y VertiPaq Analyzer.
- Meta orientativa: visuales principales en menos de 2–3 s.
