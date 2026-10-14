# Mercado Norte · Unidad 3 · SQL empresarial con IA

Continuación de la Actividad 2 de la Unidad 2 (Equipo 1). Reutiliza el esquema estrella y el DDL del equipo
(github.com/Evielex/Equipo1_MercadoNorte_ActividadFundamental2).

**Autor:** Sergio Chiw Wah Tam Hernández (1990036) · Curso: Analítica e Inteligencia de Negocios · FIME-UANL

Todo el contenido está en la carpeta [`MercadoNorte_U3`](MercadoNorte_U3).

| Carpeta | Contenido |
|---|---|
| `MercadoNorte_U3/01_modelo_unidad_2` | DDL original de la Unidad 2 (sin modificar) |
| `MercadoNorte_U3/02_ddl_y_datos` | `01_ddl_mysql.sql`, `02_carga_datos_mysql.sql`, `generar_datos.py`, `mercado_norte.sqlite` |
| `MercadoNorte_U3/03_prompts_ia` | Prompts, respuesta inicial de la IA y registro de decisiones |
| `MercadoNorte_U3/04_consultas_sql` | `q_v1_inicial_ia.sql` (IA, sin editar) y `q_v2_final_validada.sql` (final) |
| `MercadoNorte_U3/05_validacion_y_explain` | Validaciones, error 1055, índices, EXPLAIN y evidencias (`evidencia_mysql.md`) |
| `MercadoNorte_U3/06_stored_procedure` | `sp_top5_rentabilidad_region.sql` (generado con `build_sp.py`) y llamada de prueba |
| `MercadoNorte_U3/07_conclusion` | Hallazgos, limitaciones y aprendizaje |

## Reproducir
- **MySQL 8 en Windows:** desde la carpeta `MercadoNorte_U3`, ejecutar `05_validacion_y_explain\ejecutar_todo_mysql.bat`
- **MySQL 8 en Linux/macOS/Git Bash:** `bash 05_validacion_y_explain/ejecutar_todo_mysql.sh`
- **SQLite (validación de lógica):** `python3 02_ddl_y_datos/generar_datos.py && python3 05_validacion_y_explain/run_sqlite.py && python3 05_validacion_y_explain/run_explain_sqlite.py`

## Casos límite sembrados en los datos (documentados, no ocultos)
P065 (producto nuevo, sin Q1 en Laguna) · P066 (margen Q1 = 0, base cero) · empate P012/P054 en el lugar 5 de Sur Nuevo León ·
líneas de diciembre 2025 y julio 2026 fuera de los periodos · devoluciones parciales y totales · cliente anónimo (SK −1).

## Transparencia
La propuesta inicial de IA fue generada con Claude durante la preparación de este paquete y está identificada como tal.
Las salidas de `evidencia_sqlite.md` y `evidencia_explain_sqlite.md` son reales (SQLite 3.45). La evidencia de MySQL 8
(error 1055, EXPLAIN antes/después, CALL del stored procedure y validaciones V01–V15) está en `evidencia_mysql.md`.
