#!/usr/bin/env python3
"""Ejecuta en SQLite (3.45) las validaciones, la consulta v1/v2 y los EXPLAIN QUERY PLAN.
Genera evidencia_sqlite.md con salidas REALES. Uso: python3 run_sqlite.py"""
import sqlite3, re, os, sys, datetime
H = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(H, "..")
DB = os.path.join(R, "02_ddl_y_datos", "mercado_norte.sqlite")
P = dict(anio_act=2026, trim_act=2, anio_ant=2026, trim_ant=1)
rd = lambda *a: open(os.path.join(R, *a), encoding="utf-8").read()
def strip_comments(sql): return re.sub(r"/\*.*?\*/", "", sql, flags=re.S)
FINAL = strip_comments(rd("04_consultas_sql", "q_v2_final_validada.sql")).strip().rstrip(";")
V1 = strip_comments(rd("04_consultas_sql", "q_v1_inicial_ia.sql")).strip().rstrip(";")
cx = sqlite3.connect(DB); cx.row_factory = None
def run(sql, params=None):
    cur = cx.execute(sql, params or {}); cols = [d[0] for d in cur.description]; return cols, cur.fetchall()
def md(cols, rows, maxrows=60):
    f = lambda v: "NULL" if v is None else (f"{v:,.2f}" if isinstance(v, float) else str(v))
    out = ["| " + " | ".join(cols) + " |", "|" + "|".join("---" for _ in cols) + "|"]
    out += ["| " + " | ".join(f(v) for v in r) + " |" for r in rows[:maxrows]]
    if len(rows) > maxrows: out.append(f"| … {len(rows)-maxrows} filas más |")
    return "\n".join(out)
# --- validaciones
blocks = re.split(r"(?m)^-- @check ", rd("05_validacion_y_explain", "validacion.sql"))[1:]
ev = [f"# Evidencia de ejecución (SQLite {sqlite3.sqlite_version})\n",
      f"Generado por `run_sqlite.py` el {datetime.datetime.now():%Y-%m-%d %H:%M}. Base: `02_ddl_y_datos/mercado_norte.sqlite`. "
      "Parámetros: " + ", ".join(f"{k}={v}" for k, v in P.items()) + ".\n\n"
      "> Salidas reales del motor SQLite, que comparte con MySQL 8 la sintaxis de CTE y funciones de ventana. "
      "**No sustituyen** la ejecución en MySQL 8 (ver `evidencia_mysql_PENDIENTE.md`).\n"]
cx2 = None
top = run(FINAL, P)  # resultado de la consulta final
rank1_sur = [r for r in top[1] if r[0] == "Sur Nuevo León" and r[1] == 1][0]
for b in blocks:
    head, body = b.split("\n", 1)
    cid, desc, crit = [x.strip() for x in head.split("|")]
    sql = body
    sql = re.sub(r"(?m)^-- @.*$", "", sql).strip().rstrip(";")
    sql = sql.replace("__FINAL__", FINAL).replace("__V1__", V1.replace("ORDER BY r.REGION, r.posicion", "")).replace("__PID__", rank1_sur[2])
    cols, rows = run(sql, P if "@" in sql else None)
    ev.append(f"\n## {cid} · {desc}\n**Criterio de aprobación:** {crit}\n\n" + md(cols, rows) + "\n")
    if cid == "V12":
        rep = [rank1_sur[4], rank1_sur[5]]
        ok = [round(rows[0][1], 2), round(rows[0][2], 2) if rows[0][2] is not None else None] == [round(rep[0], 2), round(rep[1], 2) if rep[1] is not None else None]
        ev.append(f"Reporte (producto {rank1_sur[2]}): actual={rep[0]}, anterior={rep[1]} → **{'COINCIDE' if ok else 'NO COINCIDE'}**\n")
# --- resultado final
ev.append("\n## Resultado de la consulta final (Top 5 por región, Q2-2026 vs Q1-2026)\n" + md(*top, maxrows=100) + "\n")
v1 = run(V1)
ev.append("\n## Resultado de la versión 1 (propuesta inicial de IA, sin corregir)\n" + md(*v1, maxrows=100) + "\n")
open(os.path.join(H, "evidencia_sqlite.md"), "w", encoding="utf-8").write("".join(ev))
print("ok", len(top[1]), "filas v2;", len(v1[1]), "filas v1")
