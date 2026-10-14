# Respuesta inicial de la IA (Reto 1) — sin editar

> **Transparencia:** esta respuesta fue generada con Claude (asistente de IA de Anthropic) durante la elaboración de este paquete, a partir de `prompt_inicial.md`. Si el equipo repite el prompt con su propia IA, debe conservar esa respuesta original junto a esta y registrar las diferencias.

## Supuestos declarados por la IA
1. La región es la de la sucursal donde se registró la línea (DIM_SUCURSAL.REGION); las ventas de e-commerce se atribuyen a la sucursal que surte.
2. "Rentabilidad" = suma de MARGEN_BRUTO_MONETARIO, que ya incluye descuentos y devoluciones.
3. No hay cancelaciones en el modelo, por lo que no se filtra ningún estado.
4. Un producto se identifica por PRODUCTO_ID (clave de negocio) y su nombre por NOMBRE_PRODUCTO.
5. El periodo se filtra por ANIO y TRIMESTRE de DIM_TIEMPO (2026-Q2 y 2026-Q1).
6. Los productos sin ventas en Q1 conservan su fila del Top 5 con rentabilidad Q1 nula.

## Explicación de la IA
- **CTE q2 y q1:** cada una agrega MARGEN_BRUTO_MONETARIO por región y producto para un trimestre. Hacen 3 JOIN N:1 (tiempo, producto, sucursal), por lo que no multiplican filas del hecho.
- **CTE ranking:** `RANK() OVER (PARTITION BY REGION ORDER BY rentabilidad DESC)` reinicia la posición por región.
- **SELECT final:** `LEFT JOIN` a q1 para conservar productos sin Q1; variación absoluta y porcentual; filtra `posicion <= 5`.
- **División entre cero:** MySQL devuelve NULL al dividir entre 0, por lo que no genera error.

## Consulta propuesta
Ver `../04_consultas_sql/q_v1_inicial_ia.sql` (se conserva sin cambios).
