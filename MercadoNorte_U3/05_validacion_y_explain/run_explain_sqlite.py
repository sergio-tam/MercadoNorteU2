#!/usr/bin/env python3
"""EXPLAIN QUERY PLAN en SQLite antes/después de los índices de indices.sql. Salidas reales -> evidencia_explain_sqlite.md
'Antes' replica lo que InnoDB crea automáticamente (índice por cada FK); SQLite no lo hace solo."""
import sqlite3, re, os, shutil, tempfile
H = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(H, "..")
src = os.path.join(R, "02_ddl_y_datos", "mercado_norte.sqlite")
tmp = os.path.join(tempfile.mkdtemp(), "t.sqlite"); shutil.copy(src, tmp)   # no altera la base original
P = dict(anio_act=2026, trim_act=2, anio_ant=2026, trim_ant=1)
Q = re.sub(r"/\*.*?\*/", "", open(os.path.join(R, "04_consultas_sql", "q_v2_final_validada.sql"), encoding="utf-8").read(), flags=re.S).strip().rstrip(";")
cx = sqlite3.connect(tmp)
for c in ["CLIENTE_SK", "TIEMPO_SK", "PRODUCTO_SK", "SUCURSAL_SK", "CANAL_SK", "PROMOCION_SK"]:
    cx.execute(f"CREATE INDEX FK_{c} ON FACT_VENTAS_LINEA({c})")
cx.execute("ANALYZE")
plan = lambda: "\n".join(r[3] for r in cx.execute("EXPLAIN QUERY PLAN " + Q, P))
antes = plan(); ra = cx.execute(Q, P).fetchall()
cx.execute("CREATE INDEX IDX_DIM_TIEMPO_ANIO_TRIM ON DIM_TIEMPO(ANIO,TRIMESTRE,TIEMPO_SK)")
cx.execute("CREATE INDEX IDX_FACT_COBERTURA ON FACT_VENTAS_LINEA(TIEMPO_SK,SUCURSAL_SK,PRODUCTO_SK,MARGEN_BRUTO_MONETARIO)")
cx.execute("ANALYZE")
despues = plan(); rd = cx.execute(Q, P).fetchall()
out = f"""# EXPLAIN QUERY PLAN en SQLite {sqlite3.sqlite_version} (salidas reales)
Parámetros: {P}. Base: copia temporal de mercado_norte.sqlite.

## Antes (PK + índices de FK, equivalente al estado inicial de InnoDB)
```
{antes}
```
## Después (IDX_DIM_TIEMPO_ANIO_TRIM + IDX_FACT_COBERTURA)
```
{despues}
```
## Verificación de que la mejora no altera el resultado
Filas antes: {len(ra)} · filas después: {len(rd)} · resultados idénticos: **{ra == rd}**

> No se reportan tiempos de ejecución. SQLite y MySQL tienen optimizadores distintos: este plan demuestra la lógica de la
> mejora, pero el plan oficial debe obtenerse con EXPLAIN en MySQL 8 (explain_antes.sql / explain_despues.sql).
"""
open(os.path.join(H, "evidencia_explain_sqlite.md"), "w", encoding="utf-8").write(out); print(out)
