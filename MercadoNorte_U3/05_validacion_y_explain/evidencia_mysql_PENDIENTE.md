# Evidencia que SOLO puede obtenerse ejecutando en MySQL 8 (pendiente)

El entorno donde se preparó este paquete no tenía MySQL ni acceso para instalarlo, y la actividad prohíbe fabricar capturas o resultados.
Ejecuten los pasos y peguen aquí la salida real (texto o captura). Comando único: `bash ejecutar_todo_mysql.sh` (pide la contraseña de MySQL).

## 1. Base creada y cargada
`SELECT COUNT(*) FROM FACT_VENTAS_LINEA;`  → esperado: 26944

Salida real:
```
(pegar)
```
## 2. Consulta final (q_v2_final_validada.sql con SET @anio_act=2026, @trim_act=2, @anio_ant=2026, @trim_ant=1)
Esperado: 20 filas (4 regiones × 5). Debe coincidir con la tabla de `evidencia_sqlite.md`.
```
(pegar)
```
## 3. Error 1055 (error_1055.sql, consulta (a))
```
(pegar el mensaje real)
```
## 4. EXPLAIN antes / después (explain_antes.sql, indices.sql, explain_despues.sql)
```
(pegar plan antes)
```
```
(pegar plan después)
```
## 5. Stored procedure (sp_top5_rentabilidad_region.sql + llamada_prueba.sql)
```
(pegar salida de CALL sp_top5_rentabilidad_region(2026, 2);)
```
