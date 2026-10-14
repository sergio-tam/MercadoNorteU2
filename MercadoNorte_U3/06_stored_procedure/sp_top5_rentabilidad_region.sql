/* Reto 4 · Stored procedure · Mercado Norte · MySQL 8
   Generado por build_sp.py desde q_v2_final_validada.sql (misma lógica validada).
   Uso:  CALL sp_top5_rentabilidad_region(2026, 2);   -- Q2-2026 vs Q1-2026 */
USE mercado_norte;
DROP PROCEDURE IF EXISTS sp_top5_rentabilidad_region;
DELIMITER $$
CREATE PROCEDURE sp_top5_rentabilidad_region(IN p_anio INT, IN p_trimestre INT)
COMMENT 'Top 5 productos por rentabilidad (margen bruto) en cada region: trimestre p_anio/p_trimestre vs trimestre anterior'
BEGIN
    DECLARE v_anio_act INT;
    DECLARE v_trim_act INT;
    DECLARE v_anio_ant INT;
    DECLARE v_trim_ant INT;

    IF p_anio IS NULL OR p_trimestre IS NULL OR p_trimestre NOT BETWEEN 1 AND 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parametros invalidos: p_anio no puede ser NULL y p_trimestre debe estar entre 1 y 4';
    END IF;

    SET v_anio_act = p_anio;
    SET v_trim_act = p_trimestre;
    IF p_trimestre = 1 THEN                   -- el trimestre anterior de Q1 es Q4 del año previo
        SET v_anio_ant = p_anio - 1;
        SET v_trim_ant = 4;
    ELSE
        SET v_anio_ant = p_anio;
        SET v_trim_ant = p_trimestre - 1;
    END IF;

    WITH agregado AS (                       -- 1) una sola lectura del hecho para ambos periodos
        SELECT s.REGION                                   AS region,
               p.PRODUCTO_ID                              AS producto_id,
               p.NOMBRE_PRODUCTO                          AS nombre_producto,
               ROUND(SUM(CASE WHEN t.ANIO = v_anio_act AND t.TRIMESTRE = v_trim_act
                              THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_act,
               ROUND(SUM(CASE WHEN t.ANIO = v_anio_ant AND t.TRIMESTRE = v_trim_ant
                              THEN f.MARGEN_BRUTO_MONETARIO END), 2) AS rentabilidad_ant
        FROM FACT_VENTAS_LINEA f
        JOIN DIM_TIEMPO   t ON t.TIEMPO_SK   = f.TIEMPO_SK
        JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK = f.PRODUCTO_SK
        JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK = f.SUCURSAL_SK
        WHERE (t.ANIO = v_anio_act AND t.TRIMESTRE = v_trim_act)
           OR (t.ANIO = v_anio_ant AND t.TRIMESTRE = v_trim_ant)
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
END$$
DELIMITER ;
