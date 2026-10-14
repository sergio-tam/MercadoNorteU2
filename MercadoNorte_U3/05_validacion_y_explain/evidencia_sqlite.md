# Evidencia de ejecución (SQLite 3.45.1)
Generado por `run_sqlite.py` el 2026-10-13 20:02. Base: `02_ddl_y_datos/mercado_norte.sqlite`. Parámetros: anio_act=2026, trim_act=2, anio_ant=2026, trim_ant=1.

> Salidas reales del motor SQLite, que comparte con MySQL 8 la sintaxis de CTE y funciones de ventana. **No sustituyen** la ejecución en MySQL 8 (ver `evidencia_mysql_PENDIENTE.md`).

## V01 · Conteo de filas por tabla
**Criterio de aprobación:** fact >= 1000

| tabla | filas |
|---|---|
| FACT_VENTAS_LINEA | 26944 |
| DIM_TIEMPO | 243 |
| DIM_PRODUCTO | 66 |
| DIM_SUCURSAL | 18 |
| DMI_CLIENTE | 421 |
| DIM_CANAL | 5 |
| DIM_PROMOCION | 6 |

## V02 · Llaves foráneas huérfanas
**Criterio de aprobación:** todas = 0

| fk | huerfanos |
|---|---|
| CLIENTE | 0 |
| TIEMPO | 0 |
| PRODUCTO | 0 |
| SUCURSAL | 0 |
| CANAL | 0 |
| PROMOCION (no nulos) | 0 |

## V03 · Grano: pares (ORDEN_ID, LINEA_ORDEN) repetidos
**Criterio de aprobación:** 0

| pares_repetidos |
|---|
| 0 |

## V04 · Montos negativos donde no corresponde
**Criterio de aprobación:** 0

| lineas_con_monto_negativo |
|---|
| 0 |

## V05 · VENTA_NETA = VENTA_BRUTA - MONTO_DESCUENTO - MONTO_DEVOLUCION y MARGEN = VENTA_NETA - COSTO_TOTAL
**Criterio de aprobación:** 0 inconsistencias

| inconsist_venta_neta | inconsist_margen | descuento_o_devolucion_excesivos |
|---|---|---|
| 0 | 0 | 0 |

## V06 · DIM_TIEMPO: trimestre y año coherentes con FECHA y sin fechas repetidas
**Criterio de aprobación:** 0 / 0

| trimestre_incoherente | fechas_repetidas |
|---|---|
| 0 | 0 |

## V07 · Fechas realmente incluidas en cada periodo comparado
**Criterio de aprobación:** Q1: 2026-01-01..03-31, Q2: 2026-04-01..06-30

| ANIO | TRIMESTRE | primera_fecha | ultima_fecha | lineas |
|---|---|---|---|---|
| 2026 | 1 | 2026-01-01 | 2026-03-31 | 9921 |
| 2026 | 2 | 2026-04-01 | 2026-06-30 | 10303 |

## V08 · Cobertura: sucursales y productos con venta en el trimestre actual, por región
**Criterio de aprobación:** >=3 regiones, muchos productos

| region | sucursales | productos_con_venta | lineas |
|---|---|---|---|
| Laguna | 4 | 65 | 2340 |
| Metropolitana Monterrey | 7 | 64 | 3886 |
| Sur Nuevo León | 3 | 64 | 1697 |
| Sureste Coahuila | 4 | 65 | 2380 |

## V09 · Control de totales: margen del hecho SIN joins vs. margen tras los joins de la consulta
**Criterio de aprobación:** diferencia = 0 en ambos periodos

| periodo | margen_hecho_sin_joins | margen_con_joins | diferencia |
|---|---|---|---|
| actual | 408,441.53 | 408,441.53 | 0.00 |
| anterior | 305,940.86 | 305,940.86 | 0.00 |

## V10 · Totales por región: control independiente (sin CTE ni ventana)
**Criterio de aprobación:** contrastar con la suma de todos los productos de la región

| region | margen_region_actual |
|---|---|
| Laguna | 151,433.53 |
| Metropolitana Monterrey | 124,815.37 |
| Sur Nuevo León | 62,530.05 |
| Sureste Coahuila | 69,662.58 |

## V11 · Máximo de productos por región en la consulta final
**Criterio de aprobación:** <= 5 y posiciones 1..n sin saltos ni repetidos

| region | filas | min_pos | max_pos | posiciones_distintas |
|---|---|---|---|---|
| Laguna | 5 | 1 | 5 | 5 |
| Metropolitana Monterrey | 5 | 1 | 5 | 5 |
| Sur Nuevo León | 5 | 1 | 5 | 5 |
| Sureste Coahuila | 5 | 1 | 5 | 5 |

## V12 · Muestra controlada: región "Sur Nuevo León", producto de la posición 1, calculado a mano desde el hecho
**Criterio de aprobación:** coincide con el reporte

| fuente | rentabilidad_act | rentabilidad_ant |
|---|---|---|
| cálculo manual | 9,857.99 | 7,038.03 |
Reporte (producto P060): actual=9857.99, anterior=7038.03 → **COINCIDE**

## V13 · Casos límite del trimestre actual: sin datos previos y base cero
**Criterio de aprobación:** indicador=1 / nota BASE CERO, % NULL

| region | posicion | producto_id | nombre_producto | rentabilidad_act | rentabilidad_ant | variacion_abs | variacion_pct | sin_datos_periodo_ant | nota_variacion |
|---|---|---|---|---|---|---|---|---|---|
| Laguna | 1 | P065 | Cafetera de goteo 12 tazas (lanzamiento) | 84,365.37 | NULL | NULL | NULL | 1 | SIN DATOS EN PERIODO ANTERIOR |
| Sureste Coahuila | 4 | P066 | Tortillas de harina 1 kg (promoción de entrada) | 3,520.32 | 0.00 | 3,520.32 | NULL | 0 | BASE CERO: % NO DEFINIDO |

## V14 · Empate sembrado: V1 (RANK) vs. V2 (ROW_NUMBER)
**Criterio de aprobación:** V1 excede 5 en la región con empate; V2 siempre <= 5

| version | REGION | filas |
|---|---|---|
| V1 | Laguna | 5 |
| V2 | Laguna | 5 |
| V1 | Metropolitana Monterrey | 5 |
| V2 | Metropolitana Monterrey | 5 |
| V1 | Sur Nuevo León | 6 |
| V2 | Sur Nuevo León | 5 |
| V1 | Sureste Coahuila | 5 |
| V2 | Sureste Coahuila | 5 |

## V15 · Columnas no aditivas: promedio de MARGEN_PORCENTUAL por línea vs. razón correcta SUM(margen)/SUM(neta)
**Criterio de aprobación:** difieren (por eso no se promedian)

| region | promedio_incorrecto_de_porcentajes | razon_correcta |
|---|---|---|
| Laguna | 25.06 | 26.05 |
| Metropolitana Monterrey | 24.26 | 21.17 |
| Sur Nuevo León | 26.12 | 23.62 |
| Sureste Coahuila | 24.27 | 21.67 |

## Resultado de la consulta final (Top 5 por región, Q2-2026 vs Q1-2026)
| region | posicion | producto_id | nombre_producto | rentabilidad_act | rentabilidad_ant | variacion_abs | variacion_pct | sin_datos_periodo_ant | nota_variacion |
|---|---|---|---|---|---|---|---|---|---|
| Laguna | 1 | P065 | Cafetera de goteo 12 tazas (lanzamiento) | 84,365.37 | NULL | NULL | NULL | 1 | SIN DATOS EN PERIODO ANTERIOR |
| Laguna | 2 | P060 | Ventilador de mesa | 6,041.73 | 5,490.41 | 551.32 | 10.04 | 0 | COMPARABLE |
| Laguna | 3 | P063 | Sombrilla de playa | 5,875.34 | 6,287.50 | -412.16 | -6.56 | 0 | COMPARABLE |
| Laguna | 4 | P064 | Hielera 24 L | 4,919.48 | 6,049.15 | -1,129.67 | -18.67 | 0 | COMPARABLE |
| Laguna | 5 | P038 | Queso panela kg | 4,468.50 | 3,025.29 | 1,443.21 | 47.70 | 0 | COMPARABLE |
| Metropolitana Monterrey | 1 | P060 | Ventilador de mesa | 13,615.43 | 19,805.69 | -6,190.26 | -31.25 | 0 | COMPARABLE |
| Metropolitana Monterrey | 2 | P012 | Cerveza lager 12 pzas | 9,580.64 | 7,177.05 | 2,403.59 | 33.49 | 0 | COMPARABLE |
| Metropolitana Monterrey | 3 | P038 | Queso panela kg | 8,133.34 | 5,944.19 | 2,189.15 | 36.83 | 0 | COMPARABLE |
| Metropolitana Monterrey | 4 | P054 | Pañales etapa 3 (40 pzas) | 6,453.65 | 3,365.95 | 3,087.70 | 91.73 | 0 | COMPARABLE |
| Metropolitana Monterrey | 5 | P064 | Hielera 24 L | 6,060.68 | 8,086.29 | -2,025.61 | -25.05 | 0 | COMPARABLE |
| Sur Nuevo León | 1 | P060 | Ventilador de mesa | 9,857.99 | 7,038.03 | 2,819.96 | 40.07 | 0 | COMPARABLE |
| Sur Nuevo León | 2 | P038 | Queso panela kg | 5,337.77 | 4,050.64 | 1,287.13 | 31.78 | 0 | COMPARABLE |
| Sur Nuevo León | 3 | P064 | Hielera 24 L | 5,045.57 | 4,673.60 | 371.97 | 7.96 | 0 | COMPARABLE |
| Sur Nuevo León | 4 | P041 | Detergente en polvo 3 kg | 2,954.02 | 1,995.21 | 958.81 | 48.06 | 0 | COMPARABLE |
| Sur Nuevo León | 5 | P012 | Cerveza lager 12 pzas | 2,164.95 | 1,088.72 | 1,076.23 | 98.85 | 0 | COMPARABLE |
| Sureste Coahuila | 1 | P060 | Ventilador de mesa | 4,606.74 | 2,610.20 | 1,996.54 | 76.49 | 0 | COMPARABLE |
| Sureste Coahuila | 2 | P054 | Pañales etapa 3 (40 pzas) | 4,599.65 | 2,429.88 | 2,169.77 | 89.30 | 0 | COMPARABLE |
| Sureste Coahuila | 3 | P025 | Bistec de res kg | 3,614.83 | 3,677.64 | -62.81 | -1.71 | 0 | COMPARABLE |
| Sureste Coahuila | 4 | P066 | Tortillas de harina 1 kg (promoción de entrada) | 3,520.32 | 0.00 | 3,520.32 | NULL | 0 | BASE CERO: % NO DEFINIDO |
| Sureste Coahuila | 5 | P038 | Queso panela kg | 2,729.48 | 2,369.39 | 360.09 | 15.20 | 0 | COMPARABLE |

## Resultado de la versión 1 (propuesta inicial de IA, sin corregir)
| REGION | posicion | PRODUCTO_ID | NOMBRE_PRODUCTO | rentabilidad_q2 | rentabilidad_q1 | variacion_abs | variacion_pct |
|---|---|---|---|---|---|---|---|
| Laguna | 1 | P065 | Cafetera de goteo 12 tazas (lanzamiento) | 84,365.37 | NULL | NULL | NULL |
| Laguna | 2 | P060 | Ventilador de mesa | 6,041.73 | 5,490.41 | 551.32 | 10.04 |
| Laguna | 3 | P063 | Sombrilla de playa | 5,875.34 | 6,287.50 | -412.16 | -6.56 |
| Laguna | 4 | P064 | Hielera 24 L | 4,919.48 | 6,049.15 | -1,129.67 | -18.67 |
| Laguna | 5 | P038 | Queso panela kg | 4,468.50 | 3,025.29 | 1,443.21 | 47.70 |
| Metropolitana Monterrey | 1 | P060 | Ventilador de mesa | 13,615.43 | 19,805.69 | -6,190.26 | -31.25 |
| Metropolitana Monterrey | 2 | P012 | Cerveza lager 12 pzas | 9,580.64 | 7,177.05 | 2,403.59 | 33.49 |
| Metropolitana Monterrey | 3 | P038 | Queso panela kg | 8,133.34 | 5,944.19 | 2,189.15 | 36.83 |
| Metropolitana Monterrey | 4 | P054 | Pañales etapa 3 (40 pzas) | 6,453.65 | 3,365.95 | 3,087.70 | 91.73 |
| Metropolitana Monterrey | 5 | P064 | Hielera 24 L | 6,060.68 | 8,086.29 | -2,025.61 | -25.05 |
| Sur Nuevo León | 1 | P060 | Ventilador de mesa | 9,857.99 | 7,038.03 | 2,819.96 | 40.07 |
| Sur Nuevo León | 2 | P038 | Queso panela kg | 5,337.77 | 4,050.64 | 1,287.13 | 31.78 |
| Sur Nuevo León | 3 | P064 | Hielera 24 L | 5,045.57 | 4,673.60 | 371.97 | 7.96 |
| Sur Nuevo León | 4 | P041 | Detergente en polvo 3 kg | 2,954.02 | 1,995.21 | 958.81 | 48.06 |
| Sur Nuevo León | 5 | P012 | Cerveza lager 12 pzas | 2,164.95 | 1,088.72 | 1,076.23 | 98.85 |
| Sur Nuevo León | 5 | P054 | Pañales etapa 3 (40 pzas) | 2,164.95 | 1,698.21 | 466.74 | 27.48 |
| Sureste Coahuila | 1 | P060 | Ventilador de mesa | 4,606.74 | 2,610.20 | 1,996.54 | 76.49 |
| Sureste Coahuila | 2 | P054 | Pañales etapa 3 (40 pzas) | 4,599.65 | 2,429.88 | 2,169.77 | 89.30 |
| Sureste Coahuila | 3 | P025 | Bistec de res kg | 3,614.83 | 3,677.64 | -62.81 | -1.71 |
| Sureste Coahuila | 4 | P066 | Tortillas de harina 1 kg (promoción de entrada) | 3,520.32 | 0.00 | 3,520.32 | NULL |
| Sureste Coahuila | 5 | P038 | Queso panela kg | 2,729.48 | 2,369.39 | 360.09 | 15.20 |
