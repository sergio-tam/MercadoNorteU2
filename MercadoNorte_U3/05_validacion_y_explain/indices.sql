/* Reto 3 · Mejora de optimización propuesta (MySQL 8)
   Punto costoso detectado: DIM_TIEMPO se lee completa (escaneo) para localizar los dos trimestres y, por cada
   TIEMPO_SK, se hace un acceso al hecho que además debe leer la fila completa para obtener SUCURSAL_SK, PRODUCTO_SK y el margen.
   Mejora: (1) índice para el filtro ANIO/TRIMESTRE y (2) índice cubriente en el hecho (consulta resuelta solo con el índice). */
CREATE INDEX IDX_DIM_TIEMPO_ANIO_TRIM ON DIM_TIEMPO (ANIO, TRIMESTRE, TIEMPO_SK);
CREATE INDEX IDX_FACT_COBERTURA ON FACT_VENTAS_LINEA (TIEMPO_SK, SUCURSAL_SK, PRODUCTO_SK, MARGEN_BRUTO_MONETARIO);
ANALYZE TABLE DIM_TIEMPO, FACT_VENTAS_LINEA;
/* Para revertir:  DROP INDEX IDX_DIM_TIEMPO_ANIO_TRIM ON DIM_TIEMPO;  DROP INDEX IDX_FACT_COBERTURA ON FACT_VENTAS_LINEA; */
