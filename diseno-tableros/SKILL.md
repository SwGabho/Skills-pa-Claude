---
name: diseno-tableros
description: Reglas de diseño de tableros de Power BI (paleta, tipografía, distribución, elección de visuales, interactividad y navegación), cómo adaptar un mockup, recetas de autoría PBIR que funcionan, tarjetas personalizadas con SVG generado en DAX y cómo capturar y revisar páginas sin Desktop Bridge. Úsala antes de crear o modificar páginas, visuales, temas o navegación de un reporte (PBIR/PBIP).
---

# Diseño de tableros en Power BI

Si el `CLAUDE.md` del proyecto define una paleta, un tema o una plantilla corporativa, esos valores reemplazan a los de esta skill.

## 1. Diseño visual y estética

### Paleta por defecto

| Uso | Color |
|---|---|
| Primario (serie principal, títulos destacados) | `#1F4E79` |
| Secundario | `#2E86AB` |
| Acento (resaltar un solo dato) | `#F18F01` |
| Positivo | `#2E7D32` |
| Negativo | `#C62828` |
| Texto principal | `#252423` |
| Texto secundario / ejes | `#605E5C` |
| Bordes y líneas de cuadrícula | `#E1DFDD` |
| Fondo del lienzo | `#F3F2F1` |
| Fondo de tarjetas y visuales | `#FFFFFF` |

- Aplicar la paleta mediante un **tema JSON** del reporte, no color por color en cada visual.
- El color debe significar algo: una serie destacada y el resto en gris o en tonos del primario. Verde y rojo se reservan para desempeño (bueno/malo).
- Máximo 5–6 colores categóricos por gráfico; si hay más categorías, agrupar en "Otros".
- Contraste de texto mínimo de 4.5:1 (WCAG AA).

### Tipografía

- Segoe UI para todo; Segoe UI Semibold para títulos y valores KPI.
- Tamaños: título de página 20 pt · título de visual 12 pt · valor KPI 28–32 pt · etiqueta KPI 10 pt · ejes y etiquetas de datos 9–10 pt.
- Títulos de visual que digan qué se ve, en lenguaje de negocio: "Ventas por región", no "Suma de Importe por Region".
- Opcional: subtítulo con el periodo o la unidad ("en miles de USD").

### Espaciado e iconos

- Márgenes del lienzo de 16 px y separación entre visuales de 16 px, siempre igual.
- Alinear todo a una cuadrícula de 8 px; mismos altos para visuales en una misma fila.
- Bordes redondeados (4–8 px) y sombra suave o ninguna; nada de bordes gruesos.
- Iconos simples, monocromos y de un mismo estilo (SVG), nunca decorativos sin función.
- Quitar todo lo que no aporte: líneas de cuadrícula fuertes, ejes duplicados, leyendas innecesarias (mejor etiquetar la serie directamente).

### Jerarquía visual

- Lo más importante arriba a la izquierda (lectura en Z) y en mayor tamaño.
- Los KPIs principales van primero, en tarjetas, con su comparación (vs. año anterior o vs. meta).
- Un solo acento de color por página para el dato que se quiere destacar.

## 2. Selección de visualizaciones

| Objetivo | Visual recomendado | Evitar |
|---|---|---|
| Un número clave | Tarjeta KPI (valor + variación + tendencia) | Medidor sin meta |
| Tendencia en el tiempo | Línea (o columnas si son pocos periodos) | Circular, área apilada con muchas series |
| Comparar categorías | Barras horizontales ordenadas | Circular con más de 3–4 partes |
| Composición | Barras apiladas al 100 %, treemap (pocas partes) | Anillo con muchas categorías |
| Real vs. meta | Barras con línea de meta, bullet chart | Dos medidores |
| Variación entre periodos | Cascada (waterfall) | Tabla sin formato |
| Relación entre dos medidas | Dispersión | — |
| Distribución geográfica | Mapa coroplético o de burbujas, solo si la ubicación importa | Mapa como decoración |
| Detalle exacto | Tabla o matriz con formato condicional moderado | Tablas gigantes en la vista ejecutiva |

- Ordenar barras por valor, no alfabéticamente, salvo que el orden sea natural (meses, rangos).
- No repetir el mismo dato en dos visuales de la misma página.
- Sin 3D, sin ejes que no empiecen en cero en barras y sin doble eje salvo que sea imprescindible.
- Formato de números corto en visuales (`12,3 M`), completo en tablas y tooltips.

## 3. Arquitectura y distribución

### Estructura del reporte

1. **Resumen ejecutivo**: 4–6 KPIs y 2–3 gráficos que responden "¿cómo vamos?".
2. **Páginas de análisis** por tema (ventas, clientes, productos…): "¿por qué?".
3. **Páginas de detalle / drill-through**: tablas y ficha de un elemento.
4. **Tooltips** personalizados (páginas ocultas).

### Distribución de una página (lienzo 1280 × 720, 16:9)

```
┌──────────────────────────────────────────────────────────────┐
│ Encabezado (64 px): título · periodo · logo · navegación     │
├──────────────────────────────────────────────────────────────┤
│ [KPI] [KPI] [KPI] [KPI] [KPI]          fila de KPIs (~110 px)│
├──────────────────────────────────┬───────────────────────────┤
│ Gráfico principal (tendencia)    │ Gráfico secundario        │
│ ~2/3 del ancho                   │ (ranking / composición)   │
├──────────────────────────────────┴───────────────────────────┤
│ Detalle o gráficos de apoyo                                  │
└──────────────────────────────────────────────────────────────┘
```

- Segmentadores en una franja superior o en un panel lateral plegable, siempre en el mismo lugar en todas las páginas.
- Máximo 6–8 visuales por página; si se necesitan más, dividir en otra página.
- Mantener el mismo encabezado, posición de filtros y navegación en todas las páginas.
- Lienzo 16:9 (1280 × 720) por defecto. Configurar el diseño móvil para las páginas que se consulten desde el teléfono.

## 4. Experiencia de usuario e interactividad

- **Segmentadores**: solo los necesarios (fecha y 2–4 dimensiones clave). Sincronizarlos entre páginas cuando aplique. Usar el panel de filtros para filtros secundarios.
- **Interacciones**: revisar "Editar interacciones"; desactivar las que confunden (por ejemplo, que un filtro cruzado vacíe las tarjetas KPI).
- **Drill-through**: página de detalle con botón "Volver" y título dinámico que indique el elemento filtrado.
- **Tooltips**: páginas de tooltip para dar contexto (tendencia, desglose), sin repetir lo que ya se ve.
- **Navegación**: barra de botones o navegador de páginas en el encabezado; página activa resaltada.
- **Marcadores**: para alternar vistas (gráfico/tabla) y para un botón "Restablecer filtros".
- **Títulos dinámicos** con el periodo o la selección actual cuando ayuden a entender el contexto.
- Pensar en dos públicos: la vista ejecutiva se entiende sin hacer clic; la exploración queda para quien la necesita.
- Texto alternativo (alt text) en los visuales principales y orden de tabulación lógico.

## 5. Partir de un diseño de referencia (mockup)

- Un mockup muestra **la forma**, no los datos. Antes de construir, mapear cada bloque a un dato real y preguntar en un solo bloque lo que no exista en el modelo: metas, nivel de agregación (¿por PDV o por mercaderista?) y logos.
- No inventar metas ni umbrales. Si no hay meta, el "objetivo" se calcula con los umbrales que ya están en los datos (por ejemplo, la siguiente categoría).
- Si el usuario pide un estilo propio (paleta del mockup), su paleta reemplaza la de esta skill, pero solo en esa página. No se agrega un tema al reporte que cambie las otras páginas.

## 6. Autoría PBIR: lo que funciona

Copiar las versiones de `$schema` de los visuales que ya existen en el reporte (por ejemplo, `visualContainer/2.12.0`, `page/2.1.0`). Validar todos los JSON con `ConvertFrom-Json` antes de abrir Desktop.

| Necesidad | Cómo |
|---|---|
| Color de una línea (`lineChart`) | `dataPoint.fill` **con** `"selector": { "metadata": "Tabla.Medida" }`; sin selector se ignora |
| Color condicional por medida | `{"solid":{"color":{"expr":{"Measure":{…,"Property":"_Color"}}}}}`; en tablas, con el selector `{"data":[{"dataViewWildcard":{"matchingOption":1}}],"metadata":"Tabla.Medida"}` |
| Que un filtro no afecte a un visual | `page.json` → `"visualInteractions": [{"source":"slicer","target":"visual","type":"NoFilter"}]` |
| Filtro que solo muestre valores con datos | `filterConfig` del slicer, tipo `Advanced`, condición `Comparison` (`ComparisonKind: 1`, `> 0`) sobre una medida. Funciona |
| Selección por defecto del slicer | `objects.general[0].properties.filter.filter` (QueryFilter Version 2 con `In`) |
| "Último mes" que no se desactualiza | Columna calculada en el calendario que etiqueta el último mes con datos como "Último mes cargado" (ordenada por `AnioMesNum`) y slicer preseleccionado en ese valor: después de cada refresh apunta al mes nuevo |
| Ocultar "(En blanco)" en un slicer | `filterConfig` con `Not In [null]` sobre la columna |
| Tarjeta clásica sin "(En blanco)" | Medida de texto (`"Elige un mes"`) solo para la tarjeta; la medida numérica sigue devolviendo `BLANK()` |
| Ancho de columnas en una tabla | `objects.columnWidth` con `selector.metadata` por columna |
| Texto del título de página | `textbox` con `paragraphs[].textRuns[].textStyle` y `horizontalTextAlignment` |

- **Formato de números**: los visuales formatean según la configuración regional de **quien mira el reporte** (Desktop: Opciones > Configuración regional; Service: idioma del navegador). `FORMAT` en DAX usa la cultura del modelo. Si se mezclan ambos en una misma página, se ven separadores distintos: avisarlo.
- **Orden z**: un contenedor invisible tapa lo que esté debajo, por ejemplo el encabezado de una tabla con el mismo color que el fondo. Si algo aparece recortado, revisar los solapamientos y el `z` antes de cambiar tamaños.

## 7. Tarjetas personalizadas con SVG generado en DAX

Para tarjetas con iconos, barras de progreso o distintivos, sin visuales de terceros:

- Una medida devuelve `"data:image/svg+xml;utf8," & SVG` con `dataCategory: ImageUrl` en el TMDL, y se muestra en una `tableEx` de una sola columna.
- **Codificación obligatoria**, en este orden: `SUBSTITUTE ( SUBSTITUTE ( svg, "%", "%25" ), "#", "%23" )`. Si un `%` (como "96%") queda sin codificar, la imagen entera no se dibuja y no aparece ningún error.
- Tildes con entidades numéricas: `&#243;` (ó), `&#211;` (Ó), `&#237;` (í), `&#161;` (¡), `&#191;` (¿). El `#` de la entidad también se codifica, y funciona igual.
- En los atributos del SVG solo van números enteros (ver la trampa número → texto en `powerbi-buenas-practicas`).
- Arquitectura recomendada:
  - Una medida oculta por tarjeta, que devuelve un `<svg x='…' y='0' width='…' height='…'>` sin `xmlns`.
  - Una medida "fila" que las concatena dentro de un `<svg xmlns=… viewBox=… font-family='Segoe UI, sans-serif'>` y codifica. Una sola imagen por fila alinea mejor que varias tablas.
- Tabla contenedora:
  - `grid.imageWidth` / `imageHeight` con el tamaño real (probado hasta 1248 × 236).
  - `rowPadding 0` y sin líneas de cuadrícula.
  - Encabezado y celdas del mismo color que el fondo de la página.
  - `visualHeader`, título y fondo ocultos.
  - El encabezado invisible ocupa unos 28 px: el contenedor empieza 28 px antes que la imagen.
  - Dejar unos 6 px de margen inferior dentro del SVG.
- Ancho del texto en SVG: estimar unos 0,55 em por carácter y dejar margen. Revisar los textos largos (nombres de KBD) en la captura.
- Para revisar fuera de Power BI: exportar el resultado de la medida con ADOMD y `[Uri]::UnescapeDataString` a un `.svg`.

## Antes de entregar

- Capturar cada página modificada y revisarla: alineación, solapamientos, textos cortados, etiquetas ilegibles, colores fuera de la paleta.
- Probar los segmentadores, drill-through, tooltips, botones y marcadores.
- Comprobar que los títulos y formatos de número estén en lenguaje de negocio.

### Capturas sin Desktop Bridge

- `scripts/desktop.ps1 -Accion Abrir|Cerrar`: abre o cierra el `.pbip` y espera. Abrir tarda 2–4 min. Al cerrar, Desktop vuelve a guardar los archivos y puede tardar 1–3 min o ignorar el primer cierre.
- `scripts/captura_ventana.ps1`: captura con `PrintWindow`. `SetForegroundWindow` + `CopyFromScreen` termina capturando la terminal. Para revisar un detalle, recortar y ampliar la imagen.
- **Probar estados sin poder hacer clic**: agregar a `page.json` un filtro de página temporal (`filterConfig`, por ejemplo `tmpPrueba…` con un mes o un PDV), capturar y **quitarlo** antes de entregar. Lo que solo se prueba con clics (desplegables, filtros cruzados) se declara como no verificado.
