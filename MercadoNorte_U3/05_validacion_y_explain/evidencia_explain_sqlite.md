# EXPLAIN QUERY PLAN en SQLite 3.45.1 (salidas reales)
Parámetros: {'anio_act': 2026, 'trim_act': 2, 'anio_ant': 2026, 'trim_ant': 1}. Base: copia temporal de mercado_norte.sqlite.

## Antes (PK + índices de FK, equivalente al estado inicial de InnoDB)
```
CO-ROUTINE clasificado
CO-ROUTINE (subquery-4)
CO-ROUTINE agregado
SCAN t
SEARCH f USING INDEX FK_TIEMPO_SK (TIEMPO_SK=?)
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
SEARCH s USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR GROUP BY
SCAN a
USE TEMP B-TREE FOR ORDER BY
SCAN (subquery-4)
SCAN c
USE TEMP B-TREE FOR ORDER BY
```
## Después (IDX_DIM_TIEMPO_ANIO_TRIM + IDX_FACT_COBERTURA)
```
CO-ROUTINE clasificado
CO-ROUTINE (subquery-4)
CO-ROUTINE agregado
MULTI-INDEX OR
INDEX 1
SEARCH t USING COVERING INDEX IDX_DIM_TIEMPO_ANIO_TRIM (ANIO=? AND TRIMESTRE=?)
INDEX 2
SEARCH t USING COVERING INDEX IDX_DIM_TIEMPO_ANIO_TRIM (ANIO=? AND TRIMESTRE=?)
SEARCH f USING COVERING INDEX IDX_FACT_COBERTURA (TIEMPO_SK=?)
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
SEARCH s USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR GROUP BY
SCAN a
USE TEMP B-TREE FOR ORDER BY
SCAN (subquery-4)
SCAN c
USE TEMP B-TREE FOR ORDER BY
```
## Verificación de que la mejora no altera el resultado
Filas antes: 20 · filas después: 20 · resultados idénticos: **True**

> No se reportan tiempos de ejecución. SQLite y MySQL tienen optimizadores distintos: este plan demuestra la lógica de la
> mejora, pero el plan oficial debe obtenerse con EXPLAIN en MySQL 8 (explain_antes.sql / explain_despues.sql).
