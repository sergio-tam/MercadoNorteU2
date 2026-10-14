# Prompt del Reto 3 (optimización)

> Actúa como DBA de MySQL 8. Esta es mi consulta validada (adjuntar q_v2_final_validada.sql) y este es el EXPLAIN (adjuntar salida real de `explain_antes.sql`). Tablas: FACT_VENTAS_LINEA (~27 mil filas, índices: PK, UNIQUE(ORDEN_ID,LINEA_ORDEN) y un índice por cada FK), DIM_TIEMPO (243 filas, UNIQUE(FECHA)). El filtro es por DIM_TIEMPO.ANIO y TRIMESTRE. Propón alternativas de índices o reescritura, explica cuál elegirías y qué cambio esperas ver en el plan. No inventes tiempos de ejecución.

## Alternativas planteadas por la IA y decisión
| Alternativa | Decisión |
|---|---|
| A. Índice `DIM_TIEMPO(ANIO, TRIMESTRE, TIEMPO_SK)` para no escanear la dimensión | **Aceptada** (cubriente para el filtro y el JOIN) |
| B. Índice cubriente `FACT_VENTAS_LINEA(TIEMPO_SK, SUCURSAL_SK, PRODUCTO_SK, MARGEN_BRUTO_MONETARIO)` para resolver la lectura del hecho solo con el índice | **Aceptada** |
| C. Particionar el hecho por fecha | Descartada: excesivo para ~27 mil filas |
| D. Reescribir con `UNION ALL` en lugar de `OR` | Descartada: el plan ya usa los dos rangos del índice (en SQLite, `MULTI-INDEX OR`); en MySQL debe confirmarse con EXPLAIN |
