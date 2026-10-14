/* Reto 4 · Llamadas de prueba (MySQL 8). Pegar la salida real en evidencia_mysql_PENDIENTE.md */
USE mercado_norte;
CALL sp_top5_rentabilidad_region(2026, 2);   -- caso solicitado: Q2-2026 vs Q1-2026 (debe devolver 20 filas = 4 regiones x 5)
CALL sp_top5_rentabilidad_region(2026, 5);   -- caso inválido: debe terminar con ERROR 1644 (SQLSTATE 45000)
