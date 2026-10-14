#!/usr/bin/env bash
# Ejecuta todo el flujo en MySQL 8 y guarda las salidas reales en salidas_mysql/
set -e
cd "$(dirname "$0")/.."
mkdir -p 05_validacion_y_explain/salidas_mysql
M="mysql -u ${MYSQL_USER:-root} -p --table --force"
$M < 02_ddl_y_datos/01_ddl_mysql.sql
$M < 02_ddl_y_datos/02_carga_datos_mysql.sql
( echo "USE mercado_norte; SET @anio_act=2026,@trim_act=2,@anio_ant=2026,@trim_ant=1;"; cat 04_consultas_sql/q_v2_final_validada.sql ) | $M > 05_validacion_y_explain/salidas_mysql/consulta_final.txt
$M < 05_validacion_y_explain/error_1055.sql      > 05_validacion_y_explain/salidas_mysql/error_1055.txt 2>&1 || true
$M < 05_validacion_y_explain/explain_antes.sql   > 05_validacion_y_explain/salidas_mysql/explain_antes.txt
$M < 05_validacion_y_explain/indices.sql
$M < 05_validacion_y_explain/explain_despues.sql > 05_validacion_y_explain/salidas_mysql/explain_despues.txt
$M < 06_stored_procedure/sp_top5_rentabilidad_region.sql
$M < 06_stored_procedure/llamada_prueba.sql      > 05_validacion_y_explain/salidas_mysql/llamada_sp.txt 2>&1 || true
echo "Listo. Revisa 05_validacion_y_explain/salidas_mysql/"
