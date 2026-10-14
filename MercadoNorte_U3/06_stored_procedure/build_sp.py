#!/usr/bin/env python3
"""Construye sp_top5_rentabilidad_region.sql a partir de 04_consultas_sql/q_v2_final_validada.sql
(la consulta NO se copia a mano: solo se reemplazan @variables por variables locales v_*)."""
import re, os
H = os.path.dirname(os.path.abspath(__file__))
q = open(os.path.join(H, "..", "04_consultas_sql", "q_v2_final_validada.sql"), encoding="utf-8").read()
q = re.sub(r"/\*.*?\*/", "", q, flags=re.S).strip().rstrip(";")
for v in ["anio_act", "trim_act", "anio_ant", "trim_ant"]:
    q = q.replace("@" + v, "v_" + v)
q = "\n".join("    " + l for l in q.splitlines())
sp = f"""/* Reto 4 · Stored procedure · Mercado Norte · MySQL 8
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

{q};
END$$
DELIMITER ;
"""
open(os.path.join(H, "sp_top5_rentabilidad_region.sql"), "w", encoding="utf-8").write(sp)
