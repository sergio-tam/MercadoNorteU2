/* Validaciones listas para MySQL 8 (generado por build_validacion_mysql.py). Ejecutar completo o bloque por bloque. */
USE mercado_norte;
SET @anio_act = 2026, @trim_act = 2, @anio_ant = 2026, @trim_ant = 1;

/* Consultas de validación · Mercado Norte · compatibles con MySQL 8 y SQLite.
   Cada bloque inicia con "-- @check <id> | <descripción> | <criterio de aprobación>".
   Parámetros: @anio_act=2026 @trim_act=2 @anio_ant=2026 @trim_ant=1                 */

-- @check V01 | Conteo de filas por tabla | fact >= 1000
SELECT 'FACT_VENTAS_LINEA' AS tabla, COUNT(*) AS filas FROM FACT_VENTAS_LINEA
UNION ALL SELECT 'DIM_TIEMPO', COUNT(*) FROM DIM_TIEMPO
UNION ALL SELECT 'DIM_PRODUCTO', COUNT(*) FROM DIM_PRODUCTO
UNION ALL SELECT 'DIM_SUCURSAL', COUNT(*) FROM DIM_SUCURSAL
UNION ALL SELECT 'DMI_CLIENTE', COUNT(*) FROM DMI_CLIENTE
UNION ALL SELECT 'DIM_CANAL', COUNT(*) FROM DIM_CANAL
UNION ALL SELECT 'DIM_PROMOCION', COUNT(*) FROM DIM_PROMOCION;

-- @check V02 | Llaves foráneas huérfanas | todas = 0
SELECT 'CLIENTE' AS fk, COUNT(*) AS huerfanos FROM FACT_VENTAS_LINEA f LEFT JOIN DMI_CLIENTE d ON d.CLIENTE_SK=f.CLIENTE_SK WHERE d.CLIENTE_SK IS NULL
UNION ALL SELECT 'TIEMPO', COUNT(*) FROM FACT_VENTAS_LINEA f LEFT JOIN DIM_TIEMPO d ON d.TIEMPO_SK=f.TIEMPO_SK WHERE d.TIEMPO_SK IS NULL
UNION ALL SELECT 'PRODUCTO', COUNT(*) FROM FACT_VENTAS_LINEA f LEFT JOIN DIM_PRODUCTO d ON d.PRODUCTO_SK=f.PRODUCTO_SK WHERE d.PRODUCTO_SK IS NULL
UNION ALL SELECT 'SUCURSAL', COUNT(*) FROM FACT_VENTAS_LINEA f LEFT JOIN DIM_SUCURSAL d ON d.SUCURSAL_SK=f.SUCURSAL_SK WHERE d.SUCURSAL_SK IS NULL
UNION ALL SELECT 'CANAL', COUNT(*) FROM FACT_VENTAS_LINEA f LEFT JOIN DIM_CANAL d ON d.CANAL_SK=f.CANAL_SK WHERE d.CANAL_SK IS NULL
UNION ALL SELECT 'PROMOCION (no nulos)', COUNT(*) FROM FACT_VENTAS_LINEA f LEFT JOIN DIM_PROMOCION d ON d.PROMOCION_SK=f.PROMOCION_SK WHERE f.PROMOCION_SK IS NOT NULL AND d.PROMOCION_SK IS NULL;

-- @check V03 | Grano: pares (ORDEN_ID, LINEA_ORDEN) repetidos | 0
SELECT COUNT(*) AS pares_repetidos FROM (
  SELECT ORDEN_ID, LINEA_ORDEN FROM FACT_VENTAS_LINEA GROUP BY ORDEN_ID, LINEA_ORDEN HAVING COUNT(*) > 1) x;

-- @check V04 | Montos negativos donde no corresponde | 0
SELECT COUNT(*) AS lineas_con_monto_negativo FROM FACT_VENTAS_LINEA
WHERE UNIDADES<=0 OR VENTA_BRUTA<0 OR MONTO_DESCUENTO<0 OR MONTO_IMPUESTO<0 OR MONTO_DEVOLUCION<0 OR COSTO_TOTAL<0 OR VENTA_NETA<0;

-- @check V05 | VENTA_NETA = VENTA_BRUTA - MONTO_DESCUENTO - MONTO_DEVOLUCION y MARGEN = VENTA_NETA - COSTO_TOTAL | 0 inconsistencias
SELECT SUM(CASE WHEN ABS(VENTA_NETA-(VENTA_BRUTA-MONTO_DESCUENTO-MONTO_DEVOLUCION))>0.005 THEN 1 ELSE 0 END) AS inconsist_venta_neta,
       SUM(CASE WHEN ABS(MARGEN_BRUTO_MONETARIO-(VENTA_NETA-COSTO_TOTAL))>0.005 THEN 1 ELSE 0 END)           AS inconsist_margen,
       SUM(CASE WHEN MONTO_DESCUENTO>VENTA_BRUTA+0.005 OR MONTO_DEVOLUCION>VENTA_BRUTA-MONTO_DESCUENTO+0.005 THEN 1 ELSE 0 END) AS descuento_o_devolucion_excesivos
FROM FACT_VENTAS_LINEA;

-- @check V06 | DIM_TIEMPO: trimestre y año coherentes con FECHA y sin fechas repetidas | 0 / 0
SELECT SUM(CASE WHEN TRIMESTRE <> (CASE WHEN MES<=3 THEN 1 WHEN MES<=6 THEN 2 WHEN MES<=9 THEN 3 ELSE 4 END) OR ANIO <> CAST(SUBSTR(FECHA,1,4) AS SIGNED) THEN 1 ELSE 0 END) AS trimestre_incoherente,
       COUNT(*) - COUNT(DISTINCT FECHA) AS fechas_repetidas
FROM DIM_TIEMPO;

-- @check V07 | Fechas realmente incluidas en cada periodo comparado | Q1: 2026-01-01..03-31, Q2: 2026-04-01..06-30
SELECT t.ANIO, t.TRIMESTRE, MIN(t.FECHA) AS primera_fecha, MAX(t.FECHA) AS ultima_fecha, COUNT(*) AS lineas
FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK
WHERE (t.ANIO=@anio_act AND t.TRIMESTRE=@trim_act) OR (t.ANIO=@anio_ant AND t.TRIMESTRE=@trim_ant)
GROUP BY t.ANIO, t.TRIMESTRE ORDER BY t.TRIMESTRE;

-- @check V08 | Cobertura: sucursales y productos con venta en el trimestre actual, por región | >=3 regiones, muchos productos
SELECT s.REGION AS region, COUNT(DISTINCT s.SUCURSAL_SK) AS sucursales, COUNT(DISTINCT f.PRODUCTO_SK) AS productos_con_venta, COUNT(*) AS lineas
FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
WHERE t.ANIO=@anio_act AND t.TRIMESTRE=@trim_act GROUP BY s.REGION ORDER BY s.REGION;

-- @check V09 | Control de totales: margen del hecho SIN joins vs. margen tras los joins de la consulta | diferencia = 0 en ambos periodos
SELECT d.periodo, d.margen_hecho_sin_joins, j.margen_con_joins, ROUND(d.margen_hecho_sin_joins - j.margen_con_joins, 2) AS diferencia
FROM (SELECT 'actual' AS periodo, ROUND(SUM(f.MARGEN_BRUTO_MONETARIO),2) AS margen_hecho_sin_joins
        FROM FACT_VENTAS_LINEA f WHERE f.TIEMPO_SK IN (SELECT TIEMPO_SK FROM DIM_TIEMPO WHERE ANIO=@anio_act AND TRIMESTRE=@trim_act)
      UNION ALL
      SELECT 'anterior', ROUND(SUM(f.MARGEN_BRUTO_MONETARIO),2)
        FROM FACT_VENTAS_LINEA f WHERE f.TIEMPO_SK IN (SELECT TIEMPO_SK FROM DIM_TIEMPO WHERE ANIO=@anio_ant AND TRIMESTRE=@trim_ant)) d
JOIN (SELECT 'actual' AS periodo, ROUND(SUM(f.MARGEN_BRUTO_MONETARIO),2) AS margen_con_joins
        FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK=f.PRODUCTO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
        WHERE t.ANIO=@anio_act AND t.TRIMESTRE=@trim_act
      UNION ALL
      SELECT 'anterior', ROUND(SUM(f.MARGEN_BRUTO_MONETARIO),2)
        FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK=f.PRODUCTO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
        WHERE t.ANIO=@anio_ant AND t.TRIMESTRE=@trim_ant) j ON j.periodo=d.periodo;

-- @check V10 | Totales por región: control independiente (sin CTE ni ventana) | contrastar con la suma de todos los productos de la región
SELECT s.REGION AS region, ROUND(SUM(f.MARGEN_BRUTO_MONETARIO),2) AS margen_region_actual
FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
WHERE t.ANIO=@anio_act AND t.TRIMESTRE=@trim_act GROUP BY s.REGION ORDER BY s.REGION;

-- @check V11 | Máximo de productos por región en la consulta final | <= 5 y posiciones 1..n sin saltos ni repetidos

SELECT region, COUNT(*) AS filas, MIN(posicion) AS min_pos, MAX(posicion) AS max_pos, COUNT(DISTINCT posicion) AS posiciones_distintas
FROM (WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
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
ORDER BY c.region, c.posicion) r GROUP BY region ORDER BY region;

-- @check V12 | Muestra controlada: región "Sur Nuevo León", producto de la posición 1, calculado a mano desde el hecho | coincide con el reporte

SELECT 'cálculo manual' AS fuente, ROUND(SUM(CASE WHEN t.TRIMESTRE=@trim_act AND t.ANIO=@anio_act THEN f.VENTA_BRUTA-f.MONTO_DESCUENTO-f.MONTO_DEVOLUCION-f.COSTO_TOTAL END),2) AS rentabilidad_act,
       ROUND(SUM(CASE WHEN t.TRIMESTRE=@trim_ant AND t.ANIO=@anio_ant THEN f.VENTA_BRUTA-f.MONTO_DESCUENTO-f.MONTO_DEVOLUCION-f.COSTO_TOTAL END),2) AS rentabilidad_ant
FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK
WHERE f.PRODUCTO_SK = (SELECT PRODUCTO_SK FROM DIM_PRODUCTO WHERE PRODUCTO_ID='P060')
  AND f.SUCURSAL_SK IN (SELECT SUCURSAL_SK FROM DIM_SUCURSAL WHERE REGION='Sur Nuevo León');

-- @check V13 | Casos límite del trimestre actual: sin datos previos y base cero | indicador=1 / nota BASE CERO, % NULL

SELECT region, posicion, producto_id, nombre_producto, rentabilidad_act, rentabilidad_ant, variacion_abs, variacion_pct, sin_datos_periodo_ant, nota_variacion
FROM (WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
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
ORDER BY c.region, c.posicion) r WHERE nota_variacion <> 'COMPARABLE' ORDER BY region, posicion;

-- @check V14 | Empate sembrado: V1 (RANK) vs. V2 (ROW_NUMBER) | V1 excede 5 en la región con empate; V2 siempre <= 5

SELECT 'V1' AS version, region, COUNT(*) AS filas FROM (WITH q2 AS (
    SELECT s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO,
           SUM(f.MARGEN_BRUTO_MONETARIO) AS rentabilidad
    FROM FACT_VENTAS_LINEA f
    JOIN DIM_TIEMPO   t ON t.TIEMPO_SK   = f.TIEMPO_SK
    JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
    JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
    WHERE t.ANIO = 2026 AND t.TRIMESTRE = 2
    GROUP BY s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO
),
q1 AS (
    SELECT s.REGION, p.PRODUCTO_ID,
           SUM(f.MARGEN_BRUTO_MONETARIO) AS rentabilidad
    FROM FACT_VENTAS_LINEA f
    JOIN DIM_TIEMPO   t ON t.TIEMPO_SK   = f.TIEMPO_SK
    JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
    JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
    WHERE t.ANIO = 2026 AND t.TRIMESTRE = 1
    GROUP BY s.REGION, p.PRODUCTO_ID
),
ranking AS (
    SELECT q2.*, RANK() OVER (PARTITION BY q2.REGION ORDER BY q2.rentabilidad DESC) AS posicion
    FROM q2
)
SELECT r.REGION, r.posicion, r.PRODUCTO_ID, r.NOMBRE_PRODUCTO,
       r.rentabilidad                                   AS rentabilidad_q2,
       q1.rentabilidad                                  AS rentabilidad_q1,
       r.rentabilidad - q1.rentabilidad                 AS variacion_abs,
       (r.rentabilidad - q1.rentabilidad) / q1.rentabilidad * 100 AS variacion_pct
FROM ranking r
LEFT JOIN q1 ON q1.REGION = r.REGION AND q1.PRODUCTO_ID = r.PRODUCTO_ID
WHERE r.posicion <= 5
) a GROUP BY region
UNION ALL SELECT 'V2', region, COUNT(*) FROM (WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
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
ORDER BY c.region, c.posicion) b GROUP BY region ORDER BY 2, 1;

-- @check V15 | Columnas no aditivas: promedio de MARGEN_PORCENTUAL por línea vs. razón correcta SUM(margen)/SUM(neta) | difieren (por eso no se promedian)
SELECT s.REGION AS region,
       ROUND(AVG(f.MARGEN_PORCENTUAL),4) AS promedio_incorrecto_de_porcentajes,
       ROUND(100*SUM(f.MARGEN_BRUTO_MONETARIO)/SUM(f.VENTA_NETA),4) AS razon_correcta
FROM FACT_VENTAS_LINEA f JOIN DIM_TIEMPO t ON t.TIEMPO_SK=f.TIEMPO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
WHERE t.ANIO=@anio_act AND t.TRIMESTRE=@trim_act GROUP BY s.REGION ORDER BY s.REGION;
