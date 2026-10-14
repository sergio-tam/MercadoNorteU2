# Prompt inicial (Reto 1) · construido con la plantilla de la actividad

> Actúa como analista SQL para **MySQL 8.0**.
>
> Trabajamos con la empresa **Mercado Norte** (cadena regional de supermercados y abarrotes, 18 sucursales en Nuevo León y Coahuila, canal tienda física y e-commerce) y necesitamos **un reporte con los 5 productos más rentables de cada región en el segundo trimestre de 2026, con su variación frente al primer trimestre de 2026**.
>
> **El grano** de la tabla de hechos FACT_VENTAS_LINEA es: *una fila = una línea de venta, es decir, un producto dentro de un ticket/orden, en una sucursal y canal, con promoción (o ninguna) y cliente (o anónimo)*. (ORDEN_ID + LINEA_ORDEN es único.)
>
> **El esquema disponible** (usa SOLO estas tablas y columnas; no inventes ninguna):
> - FACT_VENTAS_LINEA(VENTA_LINEA_SK PK, CLIENTE_SK FK→DMI_CLIENTE, TIEMPO_SK FK→DIM_TIEMPO, PRODUCTO_SK FK→DIM_PRODUCTO, SUCURSAL_SK FK→DIM_SUCURSAL, CANAL_SK FK→DIM_CANAL, PROMOCION_SK FK→DIM_PROMOCION (nulo = sin promoción), ORDEN_ID, LINEA_ORDEN, UNIDADES, VENTA_BRUTA, MONTO_DESCUENTO, MONTO_IMPUESTO, MONTO_DEVOLUCION, COSTO_TOTAL, VENTA_NETA, MARGEN_BRUTO_MONETARIO, MARGEN_PORCENTUAL, TICKET_PROMEDIO, UNIDADES_POR_ORDEN)
> - DIM_TIEMPO(TIEMPO_SK PK, FECHA, DIA, MES, NOMBRE_MES, TRIMESTRE, ANIO, SEMANA_ANIO, DIA_SEMANA, NOMBRE_DIA)
> - DIM_PRODUCTO(PRODUCTO_SK PK, PRODUCTO_ID, NOMBRE_PRODUCTO, CATEGORIA, SUBCATEGORIA, MARCA)
> - DIM_SUCURSAL(SUCURSAL_SK PK, SUCURSAL_ID, NOMBRE_SUCURSAL, CIUDAD, ESTADO, REGION)
> - DMI_CLIENTE, DIM_CANAL, DIM_PROMOCION existen pero no se necesitan para este reporte.
> - Alias permitidos: f, t, p, s. Todas las relaciones son N:1 desde el hecho hacia la dimensión por la llave surrogate (_SK).
>
> **Las reglas para calcular rentabilidad y filtrar registros** son:
> - Rentabilidad = SUM(MARGEN_BRUTO_MONETARIO) donde MARGEN_BRUTO_MONETARIO = VENTA_NETA − COSTO_TOTAL y VENTA_NETA = VENTA_BRUTA − MONTO_DESCUENTO − MONTO_DEVOLUCION. Los descuentos y devoluciones ya están descontados en esa medida.
> - La región es DIM_SUCURSAL.REGION. El periodo se filtra con DIM_TIEMPO.ANIO y DIM_TIEMPO.TRIMESTRE.
> - El modelo NO tiene columna de estado de venta: no existen cancelaciones modeladas; no las inventes.
> - MARGEN_PORCENTUAL, TICKET_PROMEDIO y UNIDADES_POR_ORDEN son no aditivos: no se suman ni se promedian.
> - Variación absoluta = rentabilidad actual − anterior; variación % = variación absoluta / |anterior|. Si el producto no tuvo ventas en el trimestre anterior o la base es 0, debe quedar controlado.
>
> **La salida debe contener** región, posición del producto en su región, PRODUCTO_ID, NOMBRE_PRODUCTO, rentabilidad Q2-2026, rentabilidad Q1-2026, variación absoluta, variación porcentual y un indicador de "sin datos en el periodo anterior"; máximo 5 filas por región, ordenado por región y posición; y comparar **Q2 de 2026** (periodo actual) con **Q1 de 2026** (periodo anterior).
>
> Antes de escribir SQL, enumera tus supuestos. Después explica cada CTE, JOIN y función de ventana, y cómo evitas duplicar importes y la división entre cero.
