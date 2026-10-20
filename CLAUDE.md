# CLAUDE.md global — Power BI

Reglas que aplican a todos mis proyectos. Lo específico de cada proyecto (fuentes, KPIs, reglas de negocio) va en el `CLAUDE.md` del proyecto.
Las reglas detalladas de DAX, Power Query y modelado están en la skill `powerbi-buenas-practicas`: cárgala antes de escribir o revisar DAX, M o el modelo.
Las reglas de diseño de tableros están en la skill `diseno-tableros`: cárgala antes de crear o modificar páginas y visuales.

## Contexto

- Trabajo con proyectos de Power BI en formato **PBIP**: el modelo en **TMDL** (`*.SemanticModel/definition/`) y el reporte en **PBIR** (`*.Report/definition/`). Los `.pbix` heredados son de solo lectura salvo que diga lo contrario.
- Stack: Power BI Desktop, DAX, Power Query (M), Power BI Service / Microsoft Fabric.
- Herramientas: MCP `powerbi-modeling-mcp`, Tabular Editor, DAX Studio, Best Practice Analyzer.
- Objetivo: modelos semánticos confiables y tableros claros que sirvan para tomar decisiones.

## Principios de arquitectura

- Esquema estrella: `Fact_*` y `Dim_*`, relaciones 1:* unidireccionales. Bidireccional o muchos-a-muchos solo con justificación.
- Tabla calendario dedicada y marcada como tabla de fechas; *Auto Date/Time* desactivado.
- Tabla de medidas dedicada con *display folders*.
- Transformar lo más aguas arriba posible: fuente > Power Query > DAX.
- Si el proyecto ya tiene sus propias convenciones, se respetan las del proyecto.

## Entornos

- Dev / Test / Prod en workspaces separados (o etapas de un Deployment Pipeline).
- Se distinguen por los parámetros de Power Query `pServidor`, `pBaseDatos` y `pEntorno`, nunca por valores fijos en el código.
- **Nunca apuntar Dev a datos de Prod** sin avisarlo de forma explícita.

## No modificar sin aprobación

- Relaciones existentes (cardinalidad y dirección), roles RLS/OLS, parámetros de conexión.
- Medidas oficiales (KPIs) que otros reportes usan.
- Renombrar tablas, columnas o medidas, porque rompe visuales y reportes conectados.

## Forma de trabajar

- Git: ramas por funcionalidad sobre `main` y PR. Commits con Conventional Commits en español, por ejemplo `feat(dax): agregar Ventas YoY`.
- Puedes editar archivos y crear ramas locales. **Commit solo si te lo pido. Nunca push ni publicación sin confirmación.**
- Ante lógica de negocio ambigua o contradictoria, pregunta antes de cambiarla. Los errores técnicos evidentes se corrigen y se explican.

## Seguridad

- Nunca escribir credenciales, tokens ni cadenas de conexión con contraseña en archivos M, TMDL o JSON.
- No versionar `.pbi/cache.abf`, `.pbi/localSettings.json`, `.env` ni datos reales sensibles.
- Requieren confirmación explícita: publicar, sobrescribir o borrar en el Service/Fabric; refrescar en producción; cambiar permisos o RLS; `git push --force` o `git reset --hard`; cualquier `DELETE`, `DROP`, `UPDATE` o `TRUNCATE` contra las fuentes.
- Datos personales: no copiar datos reales en respuestas, documentación ni commits.
- Si aparece un secreto expuesto: detener la tarea, avisar con archivo y línea (sin repetir el valor), recomendar rotarlo y no hacer commit hasta resolverlo.

## Verificación antes de terminar

1. El proyecto abre sin errores (TMDL/PBIR válidos) y el refresh local termina bien.
2. Las medidas nuevas o modificadas están validadas con una consulta DAX (`EVALUATE`) y, si se puede, contra una cifra de referencia.
3. No quedan visuales rotos ni relaciones ambiguas, y BPA no muestra errores graves nuevos.
4. Si se tocó el reporte, captura las páginas modificadas con el Desktop Bridge, revísalas y corrige lo que se vea mal antes de terminar.

## Resumen final

Por secciones (Modelo / DAX / Power Query / Reporte): qué cambió y por qué, objetos o archivos tocados, código nuevo, cómo se verificó y qué queda pendiente o en riesgo.

## Comunicación

- Español siempre. Los términos técnicos y nombres de funciones van en inglés (`CALCULATE`, query folding).
- Explicativo pero directo: código completo y una explicación breve de la lógica, sobre todo del contexto de filtro.
- Ejecuta la solución recomendada y menciona alternativas solo si hay un trade-off real.
- Dudas agrupadas en un solo bloque, con opciones A/B/C y una recomendada.
- Formato de datos por defecto: fechas `dd/mm/yyyy`; separador decimal, de miles y moneda según el `CLAUDE.md` del proyecto. Si el proyecto no los define, pregunta.
