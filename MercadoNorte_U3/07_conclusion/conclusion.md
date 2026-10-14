# Conclusión · Mercado Norte · Rentabilidad por región, Q2-2026 vs Q1-2026

**Hallazgos de negocio** (datos simulados; salidas reales de la consulta final en SQLite)
- **Queso panela (P038) y Ventilador de mesa (P060) aparecen en el Top 5 de las cuatro regiones.** Son productos ancla del margen y deben protegerse en abasto y precio.
- **Metropolitana Monterrey:** el primer lugar (Ventilador de mesa) cayó **−31.25 %** (de 19,805.69 a 13,615.43). Siendo la región con más sucursales, conviene revisar precio, promociones y quiebres de inventario antes de que el efecto crezca.
- **Laguna:** el producto de lanzamiento P065 (Cafetera) lidera con 84,365.37 y **no tiene ventas en Q1**, por lo que el reporte lo marca como "sin datos en periodo anterior" en lugar de inventar una variación. Decisión posible: validar si el desempeño es sostenible y extender el lanzamiento a otras regiones.
- **Sureste Coahuila:** P066 (Tortillas) pasó de margen 0.00 (vendido a costo como promoción de entrada) a 3,520.32; el % no está definido y se señala explícitamente.
- Con empates en el lugar 5 (Sur Nuevo León: P012 y P054 con 2,164.95) el desempate determinista evita mostrar un 6.º producto.

**Limitaciones**
1. El modelo no tiene estado de venta: **las cancelaciones no están modeladas** (ajuste propuesto: `ESTADO_VENTA` en el hecho).
2. El costo de las unidades devueltas no se reintegra (regla del modelo: `COSTO_TOTAL = cantidad × costo`), lo que subestima el margen de líneas devueltas.
3. Las ventas de e-commerce/app se atribuyen a la sucursal que surte; la región no es la del cliente.
4. Los datos son simulados con semilla fija; los hallazgos ilustran el método, no la operación real.
5. Solo Q1 y Q2 de 2026 son trimestres completos; las llamadas con otros trimestres comparan contra periodos parciales.
6. **Evidencia pendiente:** el error 1055, el EXPLAIN de MySQL y la ejecución del stored procedure deben correrse en MySQL 8 (`ejecutar_todo_mysql.sh`); aquí solo se validó la lógica en SQLite.

**Aprendizaje sobre el uso de IA**
La IA entregó una consulta casi correcta, pero tres defectos solo aparecieron al contrastar con el modelo y con datos de borde: el `RANK()` rompe el "máximo 5" con empates, la variación no distinguía "sin datos" de "base cero", y los periodos estaban fijos. Ninguno se ve leyendo el SQL con prisa; se detectaron porque se sembraron casos límite y se compararon totales con consultas de control. La IA acelera el borrador; la validación contra el grano y las reglas del negocio sigue siendo responsabilidad del equipo.
