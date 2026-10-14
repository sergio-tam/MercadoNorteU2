/* Reto 3 · EXPLAIN ANTES de crear índices nuevos (solo PK, UNIQUE y FK de InnoDB). Ejecutar en MySQL 8. */
USE mercado_norte;
ANALYZE TABLE DIM_TIEMPO, FACT_VENTAS_LINEA;   -- estadísticas actualizadas: comparación justa con 'después'
SET @anio_act = 2026, @trim_act = 2, @anio_ant = 2026, @trim_ant = 1;

EXPLAIN FORMAT=TREE
WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
    SELECT s.REGION                                   AS region,
           p.PRODUCTO_ID                              AS producto_id,
           p.NOMBRE_PRODUCTO                          AS nombre_producto,
           ROUND(SUM(CASE WHEN t.ANIO = @anio_act AND t.TRIMESTRE = @trim_act
                          THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_act,
           ROUND(SUM(CASE WHEN t.ANIO = @anio_ant AND t.TRIMESTRE = @trim_ant
                          THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_ant
    FROM FACT_VENTAS_LINEA f
    JOIN DIM_TIEMPO   t ON t.TIEMPO_SK   = f.TIEMPO_SK
    JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
    JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
    WHERE (t.ANIO = @anio_act AND t.TRIMESTRE = @trim_act)
       OR (t.ANIO = @anio_ant AND t.TRIMESTRE = @trim_ant)
    GROUP BY s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO
),
clasificado AS (                         -- 2) ranking reiniciado por región
    SELECT a.*,
           ROW_NUMBER() OVER (PARTITION BY a.region
                              ORDER BY a.rentabilidad_act DESC, a.producto_id) AS posicion
    FROM agregado a
    WHERE a.rentabilidad_act IS NOT NULL            -- solo productos con ventas en el periodo actual
)
SELECT c.region,
       c.posicion,
       c.producto_id,
       c.nombre_producto,
       c.rentabilidad_act,
       c.rentabilidad_ant,
       CASE WHEN c.rentabilidad_ant IS NULL THEN NULL
            ELSE ROUND(c.rentabilidad_act - c.rentabilidad_ant, 2) END                 AS variacion_abs,
       CASE WHEN c.rentabilidad_ant IS NULL OR c.rentabilidad_ant = 0 THEN NULL
            ELSE ROUND(100 * (c.rentabilidad_act - c.rentabilidad_ant)
                           / ABS(c.rentabilidad_ant), 2) END                           AS variacion_pct,
       CASE WHEN c.rentabilidad_ant IS NULL THEN 1 ELSE 0 END                          AS sin_datos_periodo_ant,
       CASE WHEN c.rentabilidad_ant IS NULL THEN 'SIN DATOS EN PERIODO ANTERIOR'
            WHEN c.rentabilidad_ant = 0     THEN 'BASE CERO: % NO DEFINIDO'
            ELSE 'COMPARABLE' END                                                      AS nota_variacion
FROM clasificado c
WHERE c.posicion <= 5                                -- 3) Top 5 por región
ORDER BY c.region, c.posicion;

EXPLAIN
WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
    SELECT s.REGION                                   AS region,
           p.PRODUCTO_ID                              AS producto_id,
           p.NOMBRE_PRODUCTO                          AS nombre_producto,
           ROUND(SUM(CASE WHEN t.ANIO = @anio_act AND t.TRIMESTRE = @trim_act
                          THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_act,
           ROUND(SUM(CASE WHEN t.ANIO = @anio_ant AND t.TRIMESTRE = @trim_ant
                          THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_ant
    FROM FACT_VENTAS_LINEA f
    JOIN DIM_TIEMPO   t ON t.TIEMPO_SK   = f.TIEMPO_SK
    JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
    JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
    WHERE (t.ANIO = @anio_act AND t.TRIMESTRE = @trim_act)
       OR (t.ANIO = @anio_ant AND t.TRIMESTRE = @trim_ant)
    GROUP BY s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO
),
clasificado AS (                         -- 2) ranking reiniciado por región
    SELECT a.*,
           ROW_NUMBER() OVER (PARTITION BY a.region
                              ORDER BY a.rentabilidad_act DESC, a.producto_id) AS posicion
    FROM agregado a
    WHERE a.rentabilidad_act IS NOT NULL            -- solo productos con ventas en el periodo actual
)
SELECT c.region,
       c.posicion,
       c.producto_id,
       c.nombre_producto,
       c.rentabilidad_act,
       c.rentabilidad_ant,
       CASE WHEN c.rentabilidad_ant IS NULL THEN NULL
            ELSE ROUND(c.rentabilidad_act - c.rentabilidad_ant, 2) END                 AS variacion_abs,
       CASE WHEN c.rentabilidad_ant IS NULL OR c.rentabilidad_ant = 0 THEN NULL
            ELSE ROUND(100 * (c.rentabilidad_act - c.rentabilidad_ant)
                           / ABS(c.rentabilidad_ant), 2) END                           AS variacion_pct,
       CASE WHEN c.rentabilidad_ant IS NULL THEN 1 ELSE 0 END                          AS sin_datos_periodo_ant,
       CASE WHEN c.rentabilidad_ant IS NULL THEN 'SIN DATOS EN PERIODO ANTERIOR'
            WHEN c.rentabilidad_ant = 0     THEN 'BASE CERO: % NO DEFINIDO'
            ELSE 'COMPARABLE' END                                                      AS nota_variacion
FROM clasificado c
WHERE c.posicion <= 5                                -- 3) Top 5 por región
ORDER BY c.region, c.posicion;
