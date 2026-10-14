/* Reto 2 · Error de agrupación 1055 (MySQL 8, sql_mode con ONLY_FULL_GROUP_BY, valor por defecto) */
USE mercado_norte;
SELECT @@SESSION.sql_mode;            -- debe incluir ONLY_FULL_GROUP_BY

-- (a) CONSULTA INCORRECTA: agrupa solo por región, pero SELECT pide también el nombre del producto
SELECT s.REGION, p.NOMBRE_PRODUCTO, SUM(f.MARGEN_BRUTO_MONETARIO) AS rentabilidad
FROM FACT_VENTAS_LINEA f
JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
GROUP BY s.REGION;
-- Resultado esperado: ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains
-- nonaggregated column '...NOMBRE_PRODUCTO' which is not functionally dependent on columns in GROUP BY clause;
-- this is incompatible with sql_mode=only_full_group_by       (texto del manual; pegar aquí el mensaje REAL obtenido)

-- (b) CONSULTA CORREGIDA: toda columna no agregada del SELECT aparece en el GROUP BY
SELECT s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO, SUM(f.MARGEN_BRUTO_MONETARIO) AS rentabilidad
FROM FACT_VENTAS_LINEA f
JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
GROUP BY s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO
ORDER BY s.REGION, rentabilidad DESC;
