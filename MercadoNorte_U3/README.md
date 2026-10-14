# Mercado Norte · Unidad 3 · SQL empresarial con IA

Continuación de la Actividad 2 de la Unidad 2 (Equipo 1). Reutiliza el esquema estrella y el DDL del equipo
(github.com/Evielex/Equipo1_MercadoNorte_ActividadFundamental2).

| Carpeta | Contenido |
|---|---|
| 01_modelo_unidad_2 | DDL original de la Unidad 2 (sin modificar) |
| 02_ddl_y_datos | `01_ddl_mysql.sql`, `02_carga_datos_mysql.sql`, `generar_datos.py`, `mercado_norte.sqlite` |
| 03_prompts_ia | Prompts, respuesta inicial de la IA y registro de decisiones |
| 04_consultas_sql | `q_v1_inicial_ia.sql` (IA, sin editar) y `q_v2_final_validada.sql` (final) |
| 05_validacion_y_explain | Validaciones, error 1055, índices, EXPLAIN y evidencias |
| 06_stored_procedure | `sp_top5_rentabilidad_region.sql` (generado con `build_sp.py`) y llamada de prueba |
| 07_conclusion | Hallazgos, limitaciones y aprendizaje |

## Reproducir
- **MySQL 8:** `bash 05_validacion_y_explain/ejecutar_todo_mysql.sh`
- **SQLite (validación de lógica):** `python3 02_ddl_y_datos/generar_datos.py && python3 05_validacion_y_explain/run_sqlite.py && python3 05_validacion_y_explain/run_explain_sqlite.py`

## Casos límite sembrados en los datos (documentados, no ocultos)
P065 (producto nuevo, sin Q1 en Laguna) · P066 (margen Q1 = 0, base cero) · empate P012/P054 en el lugar 5 de Sur Nuevo León ·
líneas de diciembre 2025 y julio 2026 fuera de los periodos · devoluciones parciales y totales · cliente anónimo (SK −1).

## Transparencia
La propuesta inicial de IA fue generada con Claude durante la preparación de este paquete. Las salidas de `evidencia_*_sqlite.md` son reales
(SQLite 3.45). Lo que requiere MySQL 8 (1055, EXPLAIN de MySQL, CALL del SP) está marcado como pendiente en `evidencia_mysql_PENDIENTE.md`.
