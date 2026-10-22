---
name: diseno-tableros
description: Reglas de diseño de tableros de Power BI (paleta, tipografía, distribución, elección de visuales, interactividad y navegación). Úsala antes de crear o modificar páginas, visuales, temas o navegación de un reporte (PBIR/PBIP).
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

## Antes de entregar

- Capturar cada página modificada y revisarla: alineación, solapamientos, textos cortados, etiquetas ilegibles, colores fuera de la paleta.
- Probar los segmentadores, drill-through, tooltips, botones y marcadores.
- Comprobar que los títulos y formatos de número estén en lenguaje de negocio.
