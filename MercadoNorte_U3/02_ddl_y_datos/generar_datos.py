#!/usr/bin/env python3
"""
Generador de datos simulados · Mercado Norte (caso académico ficticio).

Produce, de forma determinista (semilla fija):
  - 02_carga_datos_mysql.sql : INSERTs para MySQL 8 (se ejecuta después de 01_ddl_mysql.sql)
  - mercado_norte.sqlite     : misma información en SQLite, usada para validar la lógica
                               cuando no se dispone de MySQL.

Uso:  python3 generar_datos.py
Solo usa la biblioteca estándar. No contiene datos personales reales.
"""
import random, sqlite3, os, datetime as dt
from decimal import Decimal, ROUND_HALF_UP

SEED = 20260413
random.seed(SEED)
HERE = os.path.dirname(os.path.abspath(__file__))
D = lambda x: Decimal(str(x))
def r2(x): return D(x).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
def r3(x): return D(x).quantize(Decimal("0.001"), rounding=ROUND_HALF_UP)

# ------------------------------------------------------------------ dimensiones
REGIONES = {
    "Metropolitana Monterrey": ("Nuevo León", ["Monterrey Centro", "San Pedro", "Guadalupe", "Apodaca",
                                              "San Nicolás", "Santa Catarina", "Escobedo"]),
    "Sur Nuevo León":          ("Nuevo León", ["Linares", "Montemorelos", "Allende"]),
    "Sureste Coahuila":        ("Coahuila",   ["Saltillo Centro", "Saltillo Norte", "Ramos Arizpe", "Arteaga"]),
    "Laguna":                  ("Coahuila",   ["Torreón Centro", "Torreón Sur", "Matamoros", "Francisco I. Madero"]),
}
sucursales = []   # (sk, id, nombre, ciudad, estado, region)
sk = 0
for reg, (est, lst) in REGIONES.items():
    for n in lst:
        sk += 1
        ciudad = n.split(" Centro")[0].split(" Sur")[0].split(" Norte")[0]
        sucursales.append((sk, f"S{sk:02d}", f"Mercado Norte {n}", ciudad, est, reg))

canales = [(1, "CAJA", "Caja en tienda", "Tienda física"), (2, "AUTOCOBRO", "Autocobro", "Tienda física"),
           (3, "ECOMMERCE", "E-commerce", "E-commerce"), (4, "APP", "App móvil", "E-commerce"),
           (5, "PEDIDO_CORP", "Pedido telefónico corporativo", "Corporativo")]
canal_w = [50, 18, 14, 12, 6]

# categoria: (subcategoria, [(nombre, marca, precio, costo, por_kg)])
CAT = {
 "Abarrotes": ("Básicos", [("Arroz 1 kg","Verde Valle",28,21,0),("Frijol negro 900 g","Verde Valle",36,27,0),("Aceite vegetal 1 L","Dorado",52,42,0),
     ("Azúcar 2 kg","Dulce Norte",44,35,0),("Harina de trigo 1 kg","Molinos del Norte",24,18,0),("Pasta spaghetti 200 g","Don Pastino",12,8.5,0),
     ("Atún en agua 140 g","Marea",19,14,0),("Café soluble 200 g","Altiplano",96,74,0)]),
 "Bebidas": ("Refrescos y agua", [("Refresco cola 2.5 L","Cola Real",39,29,0),("Agua purificada 20 L","Cristal",42,30,0),("Jugo de naranja 1 L","Naranjal",34,25,0),
     ("Cerveza lager 12 pzas","Cerveza Norteña",215,170,0),("Agua mineral 600 ml","Burbuja",14,9.5,0),("Bebida isotónica 600 ml","Vitalix",20,14,0),
     ("Té helado 500 ml","Hojas",17,12,0),("Leche de soya 1 L","Soyal",35,26,0)]),
 "Frutas y verduras": ("Frescos", [("Manzana roja kg","Campo Fresco",48,34,1),("Plátano kg","Campo Fresco",22,15,1),("Aguacate kg","Campo Fresco",78,58,1),
     ("Jitomate kg","Campo Fresco",26,17,1),("Cebolla blanca kg","Campo Fresco",21,14,1),("Limón kg","Campo Fresco",30,20,1),
     ("Papa blanca kg","Campo Fresco",25,17,1),("Chile serrano kg","Campo Fresco",44,30,1)]),
 "Carnes": ("Res, pollo y cerdo", [("Bistec de res kg","Carnes del Norte",189,150,1),("Pechuga de pollo kg","Granja Sol",109,86,1),("Molida de res kg","Carnes del Norte",148,118,1),
     ("Chuleta de cerdo kg","Porcino",112,88,1),("Pierna de pollo kg","Granja Sol",64,49,1),("Arrachera marinada kg","Carnes del Norte",235,188,1),
     ("Salchicha de pavo 500 g","Fríos Norte",58,43,0),("Tocino 250 g","Porcino",72,55,0)]),
 "Lácteos": ("Leche, queso y yogurt", [("Leche entera 1 L","Lácteos Sierra",26,20,0),("Queso Oaxaca kg","Lácteos Sierra",165,130,1),("Yogurt natural 1 kg","Lácteos Sierra",42,31,0),
     ("Crema ácida 450 ml","Lácteos Sierra",33,24,0),("Mantequilla 90 g","Vaquita",27,20,0),("Queso panela kg","Lácteos Sierra",150,118,1),
     ("Leche deslactosada 1 L","Lácteos Sierra",29,22,0),("Huevo blanco 18 pzas","Granja Sol",58,46,0)]),
 "Limpieza": ("Hogar", [("Detergente en polvo 3 kg","Blanquex",88,66,0),("Cloro 1 L","Blanquex",16,10,0),("Limpiador multiusos 900 ml","Brillo",29,19,0),
     ("Suavizante de telas 2 L","Aroma",54,38,0),("Papel higiénico 12 rollos","Suave",76,55,0),("Lavatrastes 750 ml","Brillo",33,22,0),
     ("Bolsas para basura 20 pzas","Resistol Bags",31,21,0),("Servilletas 500 pzas","Suave",28,19,0)]),
 "Higiene personal": ("Cuidado personal", [("Shampoo 750 ml","Cabello Sano",69,47,0),("Jabón de tocador 3 pzas","Piel Suave",36,24,0),("Pasta dental 100 ml","Sonrisa",31,21,0),
     ("Desodorante 150 ml","Fresh",48,32,0),("Toallas femeninas 10 pzas","Confort",38,26,0),("Pañales etapa 3 (40 pzas)","Bebé Feliz",189,150,0),
     ("Rastrillos 4 pzas","Filo",62,42,0),("Crema corporal 400 ml","Piel Suave",58,39,0)]),
 "Productos de temporada": ("Temporada", [("Hielo 5 kg","Polar",35,22,0),("Carbón vegetal 4 kg","Brasas",69,50,0),("Bloqueador solar 120 ml","Sol Seguro",129,92,0),
     ("Ventilador de mesa","Brisa",349,270,0),("Sandía kg","Campo Fresco",16,10,1),("Mango kg","Campo Fresco",38,26,1),
     ("Sombrilla de playa","Brisa",199,150,0),("Hielera 24 L","Polar",289,215,0)]),
}
IVA = {"Limpieza": .16, "Higiene personal": .16, "Productos de temporada": .16, "Bebidas": .08}  # ilustrativo
productos = []    # (sk, id, nombre, cat, subcat, marca)
pinfo = {}        # sk -> dict
sk = 0
for cat, (sub, items) in CAT.items():
    for nombre, marca, precio, costo, kg in items:
        sk += 1
        productos.append((sk, f"P{sk:03d}", nombre, cat, sub, marca))
        pinfo[sk] = dict(cat=cat, precio=D(precio), costo=D(costo), kg=kg,
                         pop=random.choice([0.6, 0.8, 1, 1, 1.2, 1.5, 2.0]),
                         q2=round(random.uniform(0.75, 1.35), 3))
# Productos de prueba (casos límite deliberados, ver README)
sk += 1; P_NUEVO = sk
productos.append((sk, f"P{sk:03d}", "Cafetera de goteo 12 tazas (lanzamiento)", "Productos de temporada", "Temporada", "Brisa"))
pinfo[sk] = dict(cat="Productos de temporada", precio=D(799), costo=D(520), kg=0, pop=0, q2=1)
sk += 1; P_CERO = sk
productos.append((sk, f"P{sk:03d}", "Tortillas de harina 1 kg (promoción de entrada)", "Abarrotes", "Básicos", "Molinos del Norte"))
pinfo[sk] = dict(cat="Abarrotes", precio=D(40), costo=D(40), kg=0, pop=0, q2=1)

R_NUEVO, R_CERO = "Laguna", "Sureste Coahuila"
# popularidad por región-producto
rp = {(reg, p[0]): random.choice([0.4, 0.7, 1, 1, 1.3, 1.8]) for reg in REGIONES for p in productos}

# clientes
clientes = [(-1, "ANON", "Cliente anónimo", "Público general", "General", None, None, "México")]
ciudades = [("Monterrey","Nuevo León"),("Guadalupe","Nuevo León"),("Saltillo","Coahuila"),("Torreón","Coahuila"),("Linares","Nuevo León")]
for i in range(1, 421):
    c, e = random.choice(ciudades)
    t = random.choices([("Lealtad", "Programa de lealtad"), ("Mayoreo", "Pequeño negocio"), ("General", "Público general")], [55, 10, 35])[0]
    clientes.append((i, f"C{i:05d}", f"Cliente simulado {i:03d}", t[1], t[0], c, e, "México"))
cli_pesos = [1 if c[0] > 0 else 40 for c in clientes]

# promociones
promos = [(1,"PR01","Ahorro en lácteos","Categoría",10,"2026-01-05","2026-02-28"),
          (2,"PR02","Limpieza del hogar 3x2","Cantidad",15,"2026-03-01","2026-04-30"),
          (3,"PR03","Fin de semana de carnes","Categoría",8,"2026-04-01","2026-06-30"),
          (4,"PR04","Temporada de calor","Periodo",12,"2026-04-15","2026-07-31"),
          (5,"PR05","Lealtad Norte 5%","Producto",5,"2025-12-01","2026-07-31"),
          (6,"PR06","Regreso a clases abarrotes","Categoría",7,"2026-06-01","2026-07-15")]
PROMO_CAT = {1: "Lácteos", 2: "Limpieza", 3: "Carnes", 4: "Productos de temporada", 6: "Abarrotes", 5: None}

# tiempo
MESES = ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"]
DIAS = ["lunes","martes","miércoles","jueves","viernes","sábado","domingo"]
d0, d1 = dt.date(2025, 12, 1), dt.date(2026, 7, 31)
tiempo, fecha_sk = [], {}
d = d0
while d <= d1:
    sk = len(tiempo) + 1
    tiempo.append((sk, d.isoformat(), d.day, d.month, MESES[d.month-1], (d.month-1)//3+1, d.year,
                   d.isocalendar()[1], d.weekday()+1, DIAS[d.weekday()]))
    fecha_sk[d] = sk; d += dt.timedelta(days=1)

# ------------------------------------------------------------------ hechos
suc_reg = {s[0]: s[5] for s in sucursales}
suc_price = {s[0]: round(random.uniform(0.97, 1.04), 3) for s in sucursales}
fact, orden_n = [], 0
def tri(day): return (day.month-1)//3+1 if day.year == 2026 else 0

def make_line(order_id, linea, day, suc, pk, canal, cli, force_cost=False, extra=None):
    p = pinfo[pk]
    uni = r3(random.uniform(0.3, 3.0)) if p["kg"] else D(random.choices([1,2,3,4,6],[45,28,13,9,5])[0])
    drift = D(1 + 0.012 * ((day.year - 2025) * 12 + day.month - 12) / 1)   # inflación suave
    precio = (p["precio"] * D(suc_price[suc]) * drift).quantize(Decimal("0.01"))
    costo_u = (p["costo"] * drift).quantize(Decimal("0.01"))
    if force_cost: precio = costo_u = p["costo"]
    bruta = r2(uni * precio)
    promo_sk, desc = None, D(0)
    if not force_cost and random.random() < 0.22:
        elig = [pr for pr in promos if pr[5] <= day.isoformat() <= pr[6]
                and (PROMO_CAT[pr[0]] in (None, p["cat"]))]
        if elig:
            pr = random.choice(elig); promo_sk = pr[0]; desc = r2(bruta * D(pr[4]) / 100)
    dev = D(0)
    if not force_cost and random.random() < 0.035:
        dev = r2((bruta - desc) * D(random.choice([0.25, 0.5, 1.0])))
    costo = r2(uni * costo_u)
    neta = bruta - desc - dev
    margen = neta - costo
    imp = r2(neta * D(IVA.get(p["cat"], 0)))
    mp = (margen / neta * 100).quantize(Decimal("0.0001")) if neta > 0 else None
    return [None, cli, fecha_sk[day], pk, suc, canal, promo_sk, order_id, linea, uni, bruta, desc, imp, dev, costo, neta, margen, mp, None, None]

pk_list = [p[0] for p in productos if p[0] not in (P_NUEVO, P_CERO)]
cur = d0
while cur <= d1:
    q = tri(cur)
    for s in sucursales:
        suc, reg = s[0], s[5]
        for _ in range(random.choices([0, 1, 2, 3], [20, 35, 30, 15])[0] + (1 if cur.weekday() >= 5 else 0)):
            orden_n += 1
            oid = f"T{orden_n:06d}"
            canal = random.choices([c[0] for c in canales], canal_w)[0]
            cli = random.choices([c[0] for c in clientes], cli_pesos)[0]
            if canal == 5: cli = random.choice([c[0] for c in clientes if c[3] == "Pequeño negocio"])
            nl = random.choices([1,2,3,4,5,6,7],[10,18,22,20,14,10,6])[0]
            pesos = [rp[(reg, pk)] * pinfo[pk]["pop"] * (pinfo[pk]["q2"] if q == 2 else 1) for pk in pk_list]
            elegidos = set()
            while len(elegidos) < nl: elegidos.add(random.choices(pk_list, pesos)[0])
            lineas = []
            for i, pk in enumerate(sorted(elegidos), 1):
                lineas.append(make_line(oid, i, cur, suc, pk, canal, cli))
            # productos de prueba
            if reg == R_NUEVO and dt.date(2026,4,15) <= cur <= dt.date(2026,6,30) and random.random() < 0.35:
                lineas.append(make_line(oid, len(lineas)+1, cur, suc, P_NUEVO, canal, cli))
            if reg == R_CERO and dt.date(2026,1,1) <= cur <= dt.date(2026,3,31) and random.random() < 0.25:
                lineas.append(make_line(oid, len(lineas)+1, cur, suc, P_CERO, canal, cli, force_cost=True))
            if reg == R_CERO and dt.date(2026,4,1) <= cur <= dt.date(2026,6,30) and random.random() < 0.40:
                ln = make_line(oid, len(lineas)+1, cur, suc, P_CERO, canal, cli)
                # en Q2 vuelve a precio regular (+22% sobre costo) y sin descuento ni devolución
                ln[10] = r2(ln[9] * D(49)); ln[11] = D(0); ln[13] = D(0)
                ln[12] = r2(ln[10]*D(IVA.get("Abarrotes",0)))
                ln[15] = ln[10]; ln[16] = ln[15]-ln[14]; ln[17] = (ln[16]/ln[15]*100).quantize(Decimal("0.0001")); ln[6] = None
                lineas.append(ln)
            tot_n = sum(l[15] for l in lineas); tot_u = sum(l[9] for l in lineas)
            for l in lineas:
                l[18] = r2(tot_n); l[19] = r3(tot_u)
            fact.extend(lineas)
    cur += dt.timedelta(days=1)

# Caso de prueba: EMPATE en el lugar 5 (Sur Nuevo León, Q2) -> obliga a desempatar
def q2_margen_region(reg):
    m = {}
    for f in fact:
        day = dt.date.fromisoformat(tiempo[f[2]-1][1])
        if suc_reg[f[4]] == reg and day.year == 2026 and tri(day) == 2:
            m[f[3]] = m.get(f[3], D(0)) + f[16]
    return sorted(m.items(), key=lambda x: (-x[1], x[0]))
rk = q2_margen_region("Sur Nuevo León")
(p5, m5), (p6, m6) = rk[4], rk[5]
suc_sur = [s[0] for s in sucursales if s[5] == "Sur Nuevo León"][0]
costo_extra = D(pinfo[p6]["costo"]); diff = m5 - m6
ln = [None, -1, fecha_sk[dt.date(2026, 5, 20)], p6, suc_sur, 1, None, "TEMPATE01", 1, D(1), r2(costo_extra + diff), D(0), D(0), D(0),
      r2(costo_extra), r2(costo_extra + diff), r2(diff), None, r2(costo_extra + diff), D(1)]
ln[17] = (ln[16] / ln[15] * 100).quantize(Decimal("0.0001"))
fact.append(ln)
for i, f in enumerate(fact, 1): f[0] = i

# ------------------------------------------------------------------ salida MySQL
def lit(v):
    if v is None: return "NULL"
    if isinstance(v, (int, Decimal)): return str(v)
    return "'" + str(v).replace("'", "''") + "'"
def inserts(tab, cols, rows, chunk=400):
    out = []
    for i in range(0, len(rows), chunk):
        vals = ",\n".join("(" + ",".join(lit(v) for v in r) + ")" for r in rows[i:i+chunk])
        out.append(f"INSERT INTO {tab} ({','.join(cols)}) VALUES\n{vals};")
    return "\n".join(out)

COLS = {
 "DMI_CLIENTE": ["CLIENTE_SK","CLIENTE_ID","NOMBRE","TIPO_CLIENTE","SEGMENTO","CIUDAD","ESTADO","PAIS"],
 "DIM_TIEMPO": ["TIEMPO_SK","FECHA","DIA","MES","NOMBRE_MES","TRIMESTRE","ANIO","SEMANA_ANIO","DIA_SEMANA","NOMBRE_DIA"],
 "DIM_PRODUCTO": ["PRODUCTO_SK","PRODUCTO_ID","NOMBRE_PRODUCTO","CATEGORIA","SUBCATEGORIA","MARCA"],
 "DIM_SUCURSAL": ["SUCURSAL_SK","SUCURSAL_ID","NOMBRE_SUCURSAL","CIUDAD","ESTADO","REGION"],
 "DIM_CANAL": ["CANAL_SK","CANAL_ID","NOMBRE_CANAL","TIPO_CANAL"],
 "DIM_PROMOCION": ["PROMOCION_SK","PROMOCION_ID","NOMBRE_PROMOCION","TIPO_PROMOCION","PORCENTAJE_DESC","FECHA_INICIO","FECHA_FIN"],
 "FACT_VENTAS_LINEA": ["VENTA_LINEA_SK","CLIENTE_SK","TIEMPO_SK","PRODUCTO_SK","SUCURSAL_SK","CANAL_SK","PROMOCION_SK","ORDEN_ID","LINEA_ORDEN",
    "UNIDADES","VENTA_BRUTA","MONTO_DESCUENTO","MONTO_IMPUESTO","MONTO_DEVOLUCION","COSTO_TOTAL","VENTA_NETA","MARGEN_BRUTO_MONETARIO",
    "MARGEN_PORCENTUAL","TICKET_PROMEDIO","UNIDADES_POR_ORDEN"],
}
DATA = {"DMI_CLIENTE": clientes, "DIM_TIEMPO": tiempo, "DIM_PRODUCTO": productos, "DIM_SUCURSAL": sucursales,
        "DIM_CANAL": canales, "DIM_PROMOCION": promos, "FACT_VENTAS_LINEA": fact}

with open(os.path.join(HERE, "02_carga_datos_mysql.sql"), "w", encoding="utf-8") as fh:
    fh.write("/* Carga de datos simulados · generada por generar_datos.py (semilla %d) */\nUSE mercado_norte;\nSET NAMES utf8mb4;\n" % SEED)
    for t in ["DMI_CLIENTE","DIM_TIEMPO","DIM_PRODUCTO","DIM_SUCURSAL","DIM_CANAL","DIM_PROMOCION","FACT_VENTAS_LINEA"]:
        fh.write(f"\n-- {t}: {len(DATA[t])} filas\n" + inserts(t, COLS[t], DATA[t]) + "\n")

# ------------------------------------------------------------------ salida SQLite (espejo)
path = os.path.join(HERE, "mercado_norte.sqlite")
if os.path.exists(path): os.remove(path)
cx = sqlite3.connect(path)
cx.executescript("""
PRAGMA foreign_keys=ON;
CREATE TABLE DMI_CLIENTE (CLIENTE_SK INTEGER PRIMARY KEY, CLIENTE_ID TEXT, NOMBRE TEXT, TIPO_CLIENTE TEXT, SEGMENTO TEXT, CIUDAD TEXT, ESTADO TEXT, PAIS TEXT);
CREATE TABLE DIM_TIEMPO (TIEMPO_SK INTEGER PRIMARY KEY, FECHA DATE NOT NULL UNIQUE, DIA INT, MES INT, NOMBRE_MES TEXT, TRIMESTRE INT, ANIO INT, SEMANA_ANIO INT, DIA_SEMANA INT, NOMBRE_DIA TEXT);
CREATE TABLE DIM_PRODUCTO (PRODUCTO_SK INTEGER PRIMARY KEY, PRODUCTO_ID TEXT UNIQUE, NOMBRE_PRODUCTO TEXT, CATEGORIA TEXT, SUBCATEGORIA TEXT, MARCA TEXT);
CREATE TABLE DIM_SUCURSAL (SUCURSAL_SK INTEGER PRIMARY KEY, SUCURSAL_ID TEXT UNIQUE, NOMBRE_SUCURSAL TEXT, CIUDAD TEXT, ESTADO TEXT, REGION TEXT);
CREATE TABLE DIM_CANAL (CANAL_SK INTEGER PRIMARY KEY, CANAL_ID TEXT, NOMBRE_CANAL TEXT, TIPO_CANAL TEXT);
CREATE TABLE DIM_PROMOCION (PROMOCION_SK INTEGER PRIMARY KEY, PROMOCION_ID TEXT, NOMBRE_PROMOCION TEXT, TIPO_PROMOCION TEXT, PORCENTAJE_DESC REAL, FECHA_INICIO DATE, FECHA_FIN DATE);
CREATE TABLE FACT_VENTAS_LINEA (
 VENTA_LINEA_SK INTEGER PRIMARY KEY, CLIENTE_SK INT NOT NULL REFERENCES DMI_CLIENTE(CLIENTE_SK), TIEMPO_SK INT NOT NULL REFERENCES DIM_TIEMPO(TIEMPO_SK),
 PRODUCTO_SK INT NOT NULL REFERENCES DIM_PRODUCTO(PRODUCTO_SK), SUCURSAL_SK INT NOT NULL REFERENCES DIM_SUCURSAL(SUCURSAL_SK),
 CANAL_SK INT NOT NULL REFERENCES DIM_CANAL(CANAL_SK), PROMOCION_SK INT REFERENCES DIM_PROMOCION(PROMOCION_SK),
 ORDEN_ID TEXT NOT NULL, LINEA_ORDEN INT NOT NULL, UNIDADES REAL NOT NULL, VENTA_BRUTA REAL NOT NULL, MONTO_DESCUENTO REAL NOT NULL,
 MONTO_IMPUESTO REAL NOT NULL, MONTO_DEVOLUCION REAL NOT NULL, COSTO_TOTAL REAL NOT NULL, VENTA_NETA REAL NOT NULL,
 MARGEN_BRUTO_MONETARIO REAL NOT NULL, MARGEN_PORCENTUAL REAL, TICKET_PROMEDIO REAL, UNIDADES_POR_ORDEN REAL,
 UNIQUE (ORDEN_ID, LINEA_ORDEN));
""")
for t, rows in DATA.items():
    cols = COLS[t]
    cx.executemany(f"INSERT INTO {t} ({','.join(cols)}) VALUES ({','.join('?'*len(cols))})",
                   [[float(v) if isinstance(v, Decimal) else v for v in r] for r in rows])
cx.commit(); cx.close()
print({t: len(r) for t, r in DATA.items()})
print("empate sembrado: productos", p5, p6, "margen", m5)
print("P_NUEVO", P_NUEVO, "P_CERO", P_CERO)
