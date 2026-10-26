---
name: powerbi-buenas-practicas
description: Reglas detalladas de DAX, Power Query (M) y modelado semántico en Power BI, trampas conocidas (tablas despivotadas, llaves con FORMAT, relaciones virtuales con TREATAS) y cómo consultar, validar y sincronizar el modelo abierto en Desktop sin el MCP (scripts ADOMD/TOM). Úsala antes de escribir, revisar u optimizar medidas DAX, consultas M, tablas, columnas o relaciones de un modelo.
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

## Antes de escribir medidas: perfilar la tabla

Antes de proponer medidas, perfilar la tabla con consultas `EVALUATE`:

- filas, llaves distintas y combinaciones llave + fecha;
- rango y granularidad de fechas (¿siempre es el día 1 del mes?);
- valores distintos por archivo de origen (`Source.Name`);
- porcentaje de filas que cruzan con cada dimensión, **por mes**.

Las sorpresas aparecen ahí: llaves de otro sistema, meses sin ID, filas repetidas. Validar cada medida nueva contra una cifra de referencia calculada a mano en DAX, sin usar la medida.

## Trampas de DAX y modelado

- **Tablas despivotadas**: cuando se despivotan columnas de detalle (KBD, criterio, mes…), los atributos de cabecera (puntaje, clasificación) se repiten en cada fila nueva y un `SUM` los multiplica. Definir el grano explícito (por ejemplo, `ID` + `DATE`) e iterar sobre él con `SUMMARIZE` + `CALCULATE ( MAX (…) )`. Poner `summarizeBy: none` en esas columnas.
- **`SELECTEDVALUE` dentro de una columna calculada** devuelve `BLANK()`, porque ahí no hay contexto de filtro. En columnas calculadas se usa el valor de la fila: `Tabla[Columna]`.
- **Llaves compuestas con `FORMAT ( fecha, "mmm" )`** dependen de la cultura del modelo ("ene" o "Jan"). Construir la llave exactamente igual en ambos lados y verificar el cruce con datos. Desconfiar de llaves que dependen del nombre del archivo de origen.
- **Fuentes que cambian de sistema de IDs** (por ejemplo, Involves numérico frente a RetailX `001…`): revisar el formato del ID por archivo. Si no hay una llave común, usar un respaldo por *mes + nombre* y medir la cobertura que logra.
- **Relaciones virtuales en lugar de bidireccionales**: si una dimensión (empleado) llega al hecho solo a través de otra tabla de hechos, filtrar en la medida:
  ```dax
  IF (
      ISCROSSFILTERED ( Dim_Empleado ),
      CALCULATE ( [_Medida Base], TREATAS ( VALUES ( Fact_Visitas[Llave] ), Fact_Puntaje[Llave] ) ),
      [_Medida Base]
  )
  ```
  Patrón: medida base oculta (`_X_BASE`) y medida visible que aplica el filtro. Así no se tocan las relaciones existentes.
- **Umbrales de negocio desde los datos**: si una clasificación ya viene en la fuente, derivar el umbral con `CALCULATE ( MIN ( [Puntos] ), REMOVEFILTERS (), [Clase] = "Gold" )` en lugar de escribir el número fijo.
- **Tabla calendario sin marcar como tabla de fechas**: la inteligencia de tiempo necesita `REMOVEFILTERS ( Calendario )` explícito, por ejemplo junto con `DATEADD`.
- **Comparaciones contra el mes anterior**: devolver valor solo con `HASONEVALUE ( Calendario[AnioMes] )`. Con varios meses seleccionados, la comparación desplazada engaña.
- **Miembro "(En blanco)" en filtros del calendario**: aparece cuando hay hechos con fechas fuera del rango. Se oculta con un filtro de visual `NOT IN (null)`.
- **Número → texto en DAX**: la conversión implícita (`&`) y `FORMAT` usan la cultura del modelo (por ejemplo, `es-ES` → coma decimal). En SVG, URL o JSON generados con DAX, usar solo enteros o `FORMAT ( x, "0" )`.

## Trabajar con Power BI Desktop abierto

- **No editar TMDL ni PBIR con Desktop abierto.** Desktop no recarga los archivos, y al guardar o cerrar los sobrescribe con su modelo en memoria y su propio formato. Opciones:
  1. Cerrar Desktop, editar los archivos y volver a abrir.
  2. Editar el TMDL y además sincronizar el modelo vivo por TOM (`scripts/sync_tom.ps1`), de modo que el próximo guardado escriba lo mismo.
- Después de que Desktop guarde, **releer los archivos antes de editarlos**: cambia la indentación, quita espacios finales de las líneas en blanco y agrega `lineageTag`.
- **Sin MCP (o con el EULA sin aceptar)**: el EULA del MCP es un acuerdo legal y lo acepta el usuario, no yo. Mientras tanto, se puede trabajar con las DLL que trae Desktop en `C:\Program Files\Microsoft Power BI Desktop\bin`:
  - `scripts/puerto_desktop.ps1`: puerto del `msmdsrv` hijo del proceso cuya ventana coincide con el título. Los archivos `msmdsrv.port.txt` acumulan sesiones viejas y no sirven para esto.
  - `scripts/dax.ps1`: consultas `EVALUATE` por ADOMD (`Microsoft.PowerBI.AdomdClient.dll`).
  - `scripts/validar_tmdl.ps1`: valida la sintaxis TMDL con `TmdlSerializer` (`Microsoft.PowerBI.Tabular.dll`).
  - `scripts/sync_tom.ps1`: copia medidas y columnas calculadas del TMDL al modelo abierto; tiene `-DryRun`.
- **PowerShell 5.1** lee los `.ps1` sin BOM como ANSI: no poner tildes ni ñ dentro de los scripts. Usar `[char]0xD1` o pasar el texto como parámetro. Los `.dax` con tildes se guardan con `[IO.File]::WriteAllText(ruta, texto, (New-Object Text.UTF8Encoding $false))`.
- Las consultas no deben mostrar datos personales (nombres de empleados): usar ranking o índices (`"#" & RANKX(...)`) en lugar del nombre.
