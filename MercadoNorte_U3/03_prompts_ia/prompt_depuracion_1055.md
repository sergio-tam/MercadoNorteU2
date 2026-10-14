# Prompt del Reto 2 (depuración del error 1055)

> Actúa como experto en MySQL 8. Ejecuté esta consulta con `sql_mode` por defecto (ONLY_FULL_GROUP_BY) y obtuve el error 1055 (pegar el mensaje real). Esquema: FACT_VENTAS_LINEA f, DIM_PRODUCTO p (PK PRODUCTO_SK), DIM_SUCURSAL s (PK SUCURSAL_SK).
> ```sql
> SELECT s.REGION, p.NOMBRE_PRODUCTO, SUM(f.MARGEN_BRUTO_MONETARIO) AS rentabilidad
> FROM FACT_VENTAS_LINEA f JOIN DIM_PRODUCTO p ON p.PRODUCTO_SK=f.PRODUCTO_SK JOIN DIM_SUCURSAL s ON s.SUCURSAL_SK=f.SUCURSAL_SK
> GROUP BY s.REGION;
> ```
> Explica el error, corrígelo sin desactivar ONLY_FULL_GROUP_BY y justifica por qué la nueva agrupación mantiene el resultado pedido (rentabilidad por región y producto).

## Explicación de la IA (resumen)
El `SELECT` pide `p.NOMBRE_PRODUCTO` sin agregarla y sin estar en el `GROUP BY`; con `ONLY_FULL_GROUP_BY` MySQL no puede decidir qué nombre mostrar para cada región (hay muchos), así que rechaza la consulta con 1055. La corrección es agrupar por todas las columnas no agregadas: `GROUP BY s.REGION, p.PRODUCTO_ID, p.NOMBRE_PRODUCTO`. El grano del resultado pasa a ser (región, producto), que es el que pide el negocio, y como PRODUCTO_ID es único en DIM_PRODUCTO, agregar el nombre no divide ningún grupo. No debe "resolverse" desactivando el modo estricto ni con `ANY_VALUE`, porque ocultaría el error de grano.
