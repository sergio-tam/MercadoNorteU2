/* =====================================================================
   VERSIÓN 1 · PROPUESTA INICIAL DE LA IA (sin modificar)
   Generada a partir del prompt de 03_prompts_ia/prompt_inicial.md.
   Se conserva tal cual para que pueda observarse la evolución.
   Las correcciones del equipo están en q_v2_final_validada.sql.
   ===================================================================== */
WITH q2 AS (
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
ORDER BY r.REGION, r.posicion;
