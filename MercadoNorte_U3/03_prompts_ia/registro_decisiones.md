# Registro de decisiones sobre la respuesta de la IA

Evidencia numerada = identificadores de `05_validacion_y_explain/evidencia_sqlite.md` (V01…V15) y `evidencia_explain_sqlite.md`.

| # | Propuesta de la IA (v1) | Decisión del equipo | Evidencia |
|---|---|---|---|
| 1 | Tablas, columnas, alias y los 3 JOIN N:1 hacia DIM_TIEMPO, DIM_PRODUCTO y DIM_SUCURSAL | **Aceptada.** Todas existen en el DDL; cada JOIN usa una FK definida | V02 (0 huérfanos), V09 (margen con y sin JOIN idéntico en ambos periodos) |
| 2 | Rentabilidad = SUM(MARGEN_BRUTO_MONETARIO) por región (DIM_SUCURSAL) | **Aceptada.** Coincide con la métrica de la Unidad 2 (VENTA_NETA − COSTO_TOTAL) | V05 (0 inconsistencias), V12 (cálculo manual desde VENTA_BRUTA−DESC−DEV−COSTO coincide) |
| 3 | `RANK()` para el Top 5 | **Corregida → `ROW_NUMBER()` con desempate por PRODUCTO_ID.** Con empates RANK devuelve más de 5 filas | V14: la v1 devuelve 6 filas en *Sur Nuevo León* (P012 y P054 empatan en 2,164.95); la v2, 5 |
| 4 | Años y trimestres escritos a mano (2026 / 2 y 1) | **Corregida →** parámetros `@anio_act, @trim_act, @anio_ant, @trim_ant` (en el SP, `p_anio`, `p_trimestre`) | Requisito del Reto 4; SP construido con `build_sp.py` |
| 5 | Dos CTE (q2, q1) que leen el hecho dos veces y se unen con LEFT JOIN | **Corregida →** una sola CTE con agregación condicional (`SUM(CASE…)`); elimina el JOIN entre periodos | V09 (totales iguales); un solo recorrido del hecho en EXPLAIN |
| 6 | Variación % = (act − ant)/ant×100 con la IA afirmando que "MySQL devuelve NULL" | **Corregida →** `CASE` explícito, base `ABS(ant)`, NULL si ant es NULL o 0, y nota textual. No se depende de un comportamiento implícito | V13: P066 (Q1 = 0.00) → % NULL y nota "BASE CERO" |
| 7 | Sin indicador de ausencia de datos previos | **Agregada →** columnas `sin_datos_periodo_ant` (0/1) y `nota_variacion`; `variacion_abs` también NULL si no hay base | V13: P065 en Laguna (producto nuevo) → indicador = 1 |
| 8 | Sin redondeo en SUM | **Corregida →** `ROUND(SUM(...),2)` para que la comparación de empates y la presentación sean estables | V14 |
| 9 | Supuesto 3 de la IA: "no hay cancelaciones" | **Aceptada como limitación.** El modelo no tiene columna de estado; no se inventa. Propuesta de ajuste: agregar `ESTADO_VENTA` al hecho (o DIM_ESTADO) | Ver ficha de decisiones |
| 10 | Columnas MARGEN_PORCENTUAL / TICKET_PROMEDIO / UNIDADES_POR_ORDEN | **No usadas** (no aditivas). El prompt lo prohibió | V15: el promedio de porcentajes difiere de la razón correcta en las 4 regiones |
