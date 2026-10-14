# Evidencia que SOLO puede obtenerse ejecutando en MySQL 8


## 1. Base creada y cargada
`SELECT COUNT(*) FROM FACT_VENTAS_LINEA;`  → esperado: 26944

Salida real:
```
26944
```
## 2. Consulta final (q_v2_final_validada.sql con SET @anio_act=2026, @trim_act=2, @anio_ant=2026, @trim_ant=1)
Esperado: 20 filas (4 regiones × 5). Debe coincidir con la tabla de `evidencia_sqlite.md`.
```
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| region                  | posicion | producto_id | nombre_producto                                  | rentabilidad_act | rentabilidad_ant | variacion_abs | variacion_pct | sin_datos_periodo_ant | nota_variacion                |
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| Laguna                  |        1 | P065        | Cafetera de goteo 12 tazas (lanzamiento)         |         84365.37 |             NULL |          NULL |          NULL |                     1 | SIN DATOS EN PERIODO ANTERIOR |
| Laguna                  |        2 | P060        | Ventilador de mesa                               |          6041.73 |          5490.41 |        551.32 |         10.04 |                     0 | COMPARABLE                    |
| Laguna                  |        3 | P063        | Sombrilla de playa                               |          5875.34 |          6287.50 |       -412.16 |         -6.56 |                     0 | COMPARABLE                    |
| Laguna                  |        4 | P064        | Hielera 24 L                                     |          4919.48 |          6049.15 |      -1129.67 |        -18.67 |                     0 | COMPARABLE                    |
| Laguna                  |        5 | P038        | Queso panela kg                                  |          4468.50 |          3025.29 |       1443.21 |         47.70 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        1 | P060        | Ventilador de mesa                               |         13615.43 |         19805.69 |      -6190.26 |        -31.25 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        2 | P012        | Cerveza lager 12 pzas                            |          9580.64 |          7177.05 |       2403.59 |         33.49 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        3 | P038        | Queso panela kg                                  |          8133.34 |          5944.19 |       2189.15 |         36.83 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        4 | P054        | Pañales etapa 3 (40 pzas)                        |          6453.65 |          3365.95 |       3087.70 |         91.73 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        5 | P064        | Hielera 24 L                                     |          6060.68 |          8086.29 |      -2025.61 |        -25.05 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        1 | P060        | Ventilador de mesa                               |          9857.99 |          7038.03 |       2819.96 |         40.07 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        2 | P038        | Queso panela kg                                  |          5337.77 |          4050.64 |       1287.13 |         31.78 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        3 | P064        | Hielera 24 L                                     |          5045.57 |          4673.60 |        371.97 |          7.96 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        4 | P041        | Detergente en polvo 3 kg                         |          2954.02 |          1995.21 |        958.81 |         48.06 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        5 | P012        | Cerveza lager 12 pzas                            |          2164.95 |          1088.72 |       1076.23 |         98.85 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        1 | P060        | Ventilador de mesa                               |          4606.74 |          2610.20 |       1996.54 |         76.49 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        2 | P054        | Pañales etapa 3 (40 pzas)                        |          4599.65 |          2429.88 |       2169.77 |         89.30 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        3 | P025        | Bistec de res kg                                 |          3614.83 |          3677.64 |        -62.81 |         -1.71 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        4 | P066        | Tortillas de harina 1 kg (promoción de entrada)  |          3520.32 |             0.00 |       3520.32 |          NULL |                     0 | BASE CERO: % NO DEFINIDO      |
| Sureste Coahuila        |        5 | P038        | Queso panela kg                                  |          2729.48 |          2369.39 |        360.09 |         15.20 |                     0 | COMPARABLE                    |
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+

```
## 3. Error 1055 (error_1055.sql, consulta (a))
```
+-----------------------------------------------------------------------------------------------------------------------+
| @@SESSION.sql_mode                                                                                                    |
+-----------------------------------------------------------------------------------------------------------------------+
| ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION |
+-----------------------------------------------------------------------------------------------------------------------+
ERROR 1055 (42000) at line 6: Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'mercado_norte.p.NOMBRE_PRODUCTO' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
+-------------------------+-------------+--------------------------------------------------+--------------+
| REGION                  | PRODUCTO_ID | NOMBRE_PRODUCTO                                  | rentabilidad |
+-------------------------+-------------+--------------------------------------------------+--------------+
| Laguna                  | P065        | Cafetera de goteo 12 tazas (lanzamiento)         |     84365.37 |
| Laguna                  | P063        | Sombrilla de playa                               |     15714.68 |
| Laguna                  | P064        | Hielera 24 L                                     |     15251.06 |
| Laguna                  | P060        | Ventilador de mesa                               |     14773.68 |
| Laguna                  | P038        | Queso panela kg                                  |      8883.99 |
| Laguna                  | P054        | Pañales etapa 3 (40 pzas)                        |      8255.26 |
| Laguna                  | P028        | Chuleta de cerdo kg                              |      6385.28 |
| Laguna                  | P034        | Queso Oaxaca kg                                  |      5972.09 |
| Laguna                  | P025        | Bistec de res kg                                 |      5799.03 |
| Laguna                  | P019        | Aguacate kg                                      |      5020.15 |
| Laguna                  | P026        | Pechuga de pollo kg                              |      4910.05 |
| Laguna                  | P012        | Cerveza lager 12 pzas                            |      4597.61 |
| Laguna                  | P059        | Bloqueador solar 120 ml                          |      4323.00 |
| Laguna                  | P032        | Tocino 250 g                                     |      3748.75 |
| Laguna                  | P030        | Arrachera marinada kg                            |      3182.75 |
| Laguna                  | P002        | Frijol negro 900 g                               |      2989.47 |
| Laguna                  | P008        | Café soluble 200 g                               |      2939.47 |
| Laguna                  | P031        | Salchicha de pavo 500 g                          |      2918.58 |
| Laguna                  | P015        | Té helado 500 ml                                 |      2689.03 |
| Laguna                  | P003        | Aceite vegetal 1 L                               |      2584.23 |
| Laguna                  | P052        | Desodorante 150 ml                               |      2543.78 |
| Laguna                  | P062        | Mango kg                                         |      2528.00 |
| Laguna                  | P010        | Agua purificada 20 L                             |      2404.03 |
| Laguna                  | P016        | Leche de soya 1 L                                |      2277.27 |
| Laguna                  | P045        | Papel higiénico 12 rollos                        |      2265.39 |
| Laguna                  | P050        | Jabón de tocador 3 pzas                          |      2234.89 |
| Laguna                  | P020        | Jitomate kg                                      |      2041.41 |
| Laguna                  | P022        | Limón kg                                         |      2021.09 |
| Laguna                  | P024        | Chile serrano kg                                 |      1868.46 |
| Laguna                  | P046        | Lavatrastes 750 ml                               |      1847.79 |
| Laguna                  | P039        | Leche deslactosada 1 L                           |      1795.60 |
| Laguna                  | P004        | Azúcar 2 kg                                      |      1617.13 |
| Laguna                  | P055        | Rastrillos 4 pzas                                |      1527.27 |
| Laguna                  | P042        | Cloro 1 L                                        |      1515.15 |
| Laguna                  | P051        | Pasta dental 100 ml                              |      1488.02 |
| Laguna                  | P041        | Detergente en polvo 3 kg                         |      1460.77 |
| Laguna                  | P006        | Pasta spaghetti 200 g                            |      1404.60 |
| Laguna                  | P044        | Suavizante de telas 2 L                          |      1387.19 |
| Laguna                  | P049        | Shampoo 750 ml                                   |      1378.64 |
| Laguna                  | P040        | Huevo blanco 18 pzas                             |      1320.66 |
| Laguna                  | P027        | Molida de res kg                                 |      1276.04 |
| Laguna                  | P001        | Arroz 1 kg                                       |      1269.16 |
| Laguna                  | P061        | Sandía kg                                        |      1251.63 |
| Laguna                  | P014        | Bebida isotónica 600 ml                          |      1236.90 |
| Laguna                  | P047        | Bolsas para basura 20 pzas                       |      1215.81 |
| Laguna                  | P058        | Carbón vegetal 4 kg                              |      1190.28 |
| Laguna                  | P056        | Crema corporal 400 ml                            |      1182.78 |
| Laguna                  | P005        | Harina de trigo 1 kg                             |      1172.17 |
| Laguna                  | P011        | Jugo de naranja 1 L                              |      1078.45 |
| Laguna                  | P035        | Yogurt natural 1 kg                              |      1073.88 |
| Laguna                  | P053        | Toallas femeninas 10 pzas                        |       997.37 |
| Laguna                  | P036        | Crema ácida 450 ml                               |       889.83 |
| Laguna                  | P029        | Pierna de pollo kg                               |       783.03 |
| Laguna                  | P021        | Cebolla blanca kg                                |       770.81 |
| Laguna                  | P043        | Limpiador multiusos 900 ml                       |       745.55 |
| Laguna                  | P018        | Plátano kg                                       |       725.71 |
| Laguna                  | P009        | Refresco cola 2.5 L                              |       702.07 |
| Laguna                  | P017        | Manzana roja kg                                  |       639.45 |
| Laguna                  | P013        | Agua mineral 600 ml                              |       593.68 |
| Laguna                  | P037        | Mantequilla 90 g                                 |       540.02 |
| Laguna                  | P007        | Atún en agua 140 g                               |       442.86 |
| Laguna                  | P057        | Hielo 5 kg                                       |       332.84 |
| Laguna                  | P048        | Servilletas 500 pzas                             |       287.98 |
| Laguna                  | P033        | Leche entera 1 L                                 |       270.15 |
| Laguna                  | P023        | Papa blanca kg                                   |       204.92 |
| Metropolitana Monterrey | P060        | Ventilador de mesa                               |     43564.89 |
| Metropolitana Monterrey | P012        | Cerveza lager 12 pzas                            |     20463.13 |
| Metropolitana Monterrey | P064        | Hielera 24 L                                     |     19391.50 |
| Metropolitana Monterrey | P038        | Queso panela kg                                  |     19090.19 |
| Metropolitana Monterrey | P063        | Sombrilla de playa                               |     16942.24 |
| Metropolitana Monterrey | P054        | Pañales etapa 3 (40 pzas)                        |     13419.83 |
| Metropolitana Monterrey | P045        | Papel higiénico 12 rollos                        |     13053.12 |
| Metropolitana Monterrey | P026        | Pechuga de pollo kg                              |     11417.03 |
| Metropolitana Monterrey | P058        | Carbón vegetal 4 kg                              |      9539.83 |
| Metropolitana Monterrey | P049        | Shampoo 750 ml                                   |      9216.33 |
| Metropolitana Monterrey | P019        | Aguacate kg                                      |      8827.21 |
| Metropolitana Monterrey | P031        | Salchicha de pavo 500 g                          |      6804.62 |
| Metropolitana Monterrey | P008        | Café soluble 200 g                               |      6538.17 |
| Metropolitana Monterrey | P025        | Bistec de res kg                                 |      6165.76 |
| Metropolitana Monterrey | P032        | Tocino 250 g                                     |      5546.41 |
| Metropolitana Monterrey | P052        | Desodorante 150 ml                               |      5529.47 |
| Metropolitana Monterrey | P041        | Detergente en polvo 3 kg                         |      5424.24 |
| Metropolitana Monterrey | P010        | Agua purificada 20 L                             |      5322.59 |
| Metropolitana Monterrey | P028        | Chuleta de cerdo kg                              |      5292.31 |
| Metropolitana Monterrey | P039        | Leche deslactosada 1 L                           |      5073.66 |
| Metropolitana Monterrey | P027        | Molida de res kg                                 |      4822.66 |
| Metropolitana Monterrey | P059        | Bloqueador solar 120 ml                          |      4726.06 |
| Metropolitana Monterrey | P016        | Leche de soya 1 L                                |      4495.65 |
| Metropolitana Monterrey | P044        | Suavizante de telas 2 L                          |      4195.19 |
| Metropolitana Monterrey | P051        | Pasta dental 100 ml                              |      4080.44 |
| Metropolitana Monterrey | P056        | Crema corporal 400 ml                            |      3654.59 |
| Metropolitana Monterrey | P043        | Limpiador multiusos 900 ml                       |      3461.17 |
| Metropolitana Monterrey | P042        | Cloro 1 L                                        |      3342.65 |
| Metropolitana Monterrey | P048        | Servilletas 500 pzas                             |      3213.05 |
| Metropolitana Monterrey | P035        | Yogurt natural 1 kg                              |      3139.62 |
| Metropolitana Monterrey | P034        | Queso Oaxaca kg                                  |      3038.64 |
| Metropolitana Monterrey | P024        | Chile serrano kg                                 |      2741.49 |
| Metropolitana Monterrey | P002        | Frijol negro 900 g                               |      2677.26 |
| Metropolitana Monterrey | P029        | Pierna de pollo kg                               |      2592.49 |
| Metropolitana Monterrey | P030        | Arrachera marinada kg                            |      2506.88 |
| Metropolitana Monterrey | P013        | Agua mineral 600 ml                              |      2437.78 |
| Metropolitana Monterrey | P057        | Hielo 5 kg                                       |      2294.64 |
| Metropolitana Monterrey | P003        | Aceite vegetal 1 L                               |      2250.64 |
| Metropolitana Monterrey | P036        | Crema ácida 450 ml                               |      2145.58 |
| Metropolitana Monterrey | P009        | Refresco cola 2.5 L                              |      2132.74 |
| Metropolitana Monterrey | P022        | Limón kg                                         |      2070.45 |
| Metropolitana Monterrey | P055        | Rastrillos 4 pzas                                |      2065.85 |
| Metropolitana Monterrey | P015        | Té helado 500 ml                                 |      2026.20 |
| Metropolitana Monterrey | P006        | Pasta spaghetti 200 g                            |      1888.24 |
| Metropolitana Monterrey | P040        | Huevo blanco 18 pzas                             |      1820.84 |
| Metropolitana Monterrey | P047        | Bolsas para basura 20 pzas                       |      1735.10 |
| Metropolitana Monterrey | P062        | Mango kg                                         |      1619.50 |
| Metropolitana Monterrey | P017        | Manzana roja kg                                  |      1563.33 |
| Metropolitana Monterrey | P011        | Jugo de naranja 1 L                              |      1544.23 |
| Metropolitana Monterrey | P018        | Plátano kg                                       |      1495.03 |
| Metropolitana Monterrey | P023        | Papa blanca kg                                   |      1443.09 |
| Metropolitana Monterrey | P050        | Jabón de tocador 3 pzas                          |      1402.89 |
| Metropolitana Monterrey | P021        | Cebolla blanca kg                                |      1366.65 |
| Metropolitana Monterrey | P014        | Bebida isotónica 600 ml                          |      1364.81 |
| Metropolitana Monterrey | P004        | Azúcar 2 kg                                      |      1318.43 |
| Metropolitana Monterrey | P020        | Jitomate kg                                      |      1315.06 |
| Metropolitana Monterrey | P001        | Arroz 1 kg                                       |      1269.86 |
| Metropolitana Monterrey | P005        | Harina de trigo 1 kg                             |      1249.45 |
| Metropolitana Monterrey | P046        | Lavatrastes 750 ml                               |       943.83 |
| Metropolitana Monterrey | P053        | Toallas femeninas 10 pzas                        |       835.67 |
| Metropolitana Monterrey | P061        | Sandía kg                                        |       662.54 |
| Metropolitana Monterrey | P037        | Mantequilla 90 g                                 |       331.71 |
| Metropolitana Monterrey | P007        | Atún en agua 140 g                               |       322.67 |
| Metropolitana Monterrey | P033        | Leche entera 1 L                                 |       304.03 |
| Sur Nuevo León          | P060        | Ventilador de mesa                               |     21382.52 |
| Sur Nuevo León          | P038        | Queso panela kg                                  |     11711.78 |
| Sur Nuevo León          | P064        | Hielera 24 L                                     |     11524.26 |
| Sur Nuevo León          | P041        | Detergente en polvo 3 kg                         |      6040.18 |
| Sur Nuevo León          | P054        | Pañales etapa 3 (40 pzas)                        |      4991.43 |
| Sur Nuevo León          | P059        | Bloqueador solar 120 ml                          |      4982.21 |
| Sur Nuevo León          | P030        | Arrachera marinada kg                            |      4029.38 |
| Sur Nuevo León          | P049        | Shampoo 750 ml                                   |      3998.16 |
| Sur Nuevo León          | P052        | Desodorante 150 ml                               |      3795.09 |
| Sur Nuevo León          | P012        | Cerveza lager 12 pzas                            |      3759.36 |
| Sur Nuevo León          | P058        | Carbón vegetal 4 kg                              |      3588.45 |
| Sur Nuevo León          | P008        | Café soluble 200 g                               |      2981.91 |
| Sur Nuevo León          | P032        | Tocino 250 g                                     |      2756.51 |
| Sur Nuevo León          | P063        | Sombrilla de playa                               |      2739.61 |
| Sur Nuevo León          | P034        | Queso Oaxaca kg                                  |      2733.43 |
| Sur Nuevo León          | P050        | Jabón de tocador 3 pzas                          |      2594.38 |
| Sur Nuevo León          | P025        | Bistec de res kg                                 |      2507.50 |
| Sur Nuevo León          | P005        | Harina de trigo 1 kg                             |      2481.45 |
| Sur Nuevo León          | P019        | Aguacate kg                                      |      2468.76 |
| Sur Nuevo León          | P003        | Aceite vegetal 1 L                               |      2191.62 |
| Sur Nuevo León          | P004        | Azúcar 2 kg                                      |      2130.42 |
| Sur Nuevo León          | P051        | Pasta dental 100 ml                              |      1815.87 |
| Sur Nuevo León          | P010        | Agua purificada 20 L                             |      1814.66 |
| Sur Nuevo León          | P026        | Pechuga de pollo kg                              |      1814.37 |
| Sur Nuevo León          | P031        | Salchicha de pavo 500 g                          |      1790.43 |
| Sur Nuevo León          | P039        | Leche deslactosada 1 L                           |      1782.34 |
| Sur Nuevo León          | P047        | Bolsas para basura 20 pzas                       |      1657.70 |
| Sur Nuevo León          | P002        | Frijol negro 900 g                               |      1636.18 |
| Sur Nuevo León          | P029        | Pierna de pollo kg                               |      1619.69 |
| Sur Nuevo León          | P035        | Yogurt natural 1 kg                              |      1570.15 |
| Sur Nuevo León          | P044        | Suavizante de telas 2 L                          |      1528.45 |
| Sur Nuevo León          | P057        | Hielo 5 kg                                       |      1492.54 |
| Sur Nuevo León          | P027        | Molida de res kg                                 |      1472.50 |
| Sur Nuevo León          | P013        | Agua mineral 600 ml                              |      1468.82 |
| Sur Nuevo León          | P045        | Papel higiénico 12 rollos                        |      1443.50 |
| Sur Nuevo León          | P024        | Chile serrano kg                                 |      1405.58 |
| Sur Nuevo León          | P028        | Chuleta de cerdo kg                              |      1091.45 |
| Sur Nuevo León          | P042        | Cloro 1 L                                        |      1073.67 |
| Sur Nuevo León          | P043        | Limpiador multiusos 900 ml                       |      1022.95 |
| Sur Nuevo León          | P022        | Limón kg                                         |       997.89 |
| Sur Nuevo León          | P046        | Lavatrastes 750 ml                               |       983.10 |
| Sur Nuevo León          | P017        | Manzana roja kg                                  |       966.54 |
| Sur Nuevo León          | P009        | Refresco cola 2.5 L                              |       870.05 |
| Sur Nuevo León          | P023        | Papa blanca kg                                   |       860.92 |
| Sur Nuevo León          | P056        | Crema corporal 400 ml                            |       847.82 |
| Sur Nuevo León          | P055        | Rastrillos 4 pzas                                |       841.59 |
| Sur Nuevo León          | P033        | Leche entera 1 L                                 |       820.87 |
| Sur Nuevo León          | P037        | Mantequilla 90 g                                 |       797.29 |
| Sur Nuevo León          | P016        | Leche de soya 1 L                                |       707.09 |
| Sur Nuevo León          | P006        | Pasta spaghetti 200 g                            |       674.12 |
| Sur Nuevo León          | P021        | Cebolla blanca kg                                |       661.11 |
| Sur Nuevo León          | P040        | Huevo blanco 18 pzas                             |       654.63 |
| Sur Nuevo León          | P020        | Jitomate kg                                      |       627.71 |
| Sur Nuevo León          | P011        | Jugo de naranja 1 L                              |       565.62 |
| Sur Nuevo León          | P053        | Toallas femeninas 10 pzas                        |       559.23 |
| Sur Nuevo León          | P062        | Mango kg                                         |       541.31 |
| Sur Nuevo León          | P061        | Sandía kg                                        |       522.33 |
| Sur Nuevo León          | P014        | Bebida isotónica 600 ml                          |       516.94 |
| Sur Nuevo León          | P036        | Crema ácida 450 ml                               |       486.06 |
| Sur Nuevo León          | P048        | Servilletas 500 pzas                             |       414.58 |
| Sur Nuevo León          | P015        | Té helado 500 ml                                 |       381.09 |
| Sur Nuevo León          | P018        | Plátano kg                                       |       369.54 |
| Sur Nuevo León          | P007        | Atún en agua 140 g                               |       349.90 |
| Sur Nuevo León          | P001        | Arroz 1 kg                                       |       336.64 |
| Sureste Coahuila        | P060        | Ventilador de mesa                               |     11225.31 |
| Sureste Coahuila        | P025        | Bistec de res kg                                 |      9409.52 |
| Sureste Coahuila        | P054        | Pañales etapa 3 (40 pzas)                        |      8005.71 |
| Sureste Coahuila        | P032        | Tocino 250 g                                     |      7747.33 |
| Sureste Coahuila        | P012        | Cerveza lager 12 pzas                            |      7231.67 |
| Sureste Coahuila        | P038        | Queso panela kg                                  |      6917.43 |
| Sureste Coahuila        | P059        | Bloqueador solar 120 ml                          |      6816.50 |
| Sureste Coahuila        | P063        | Sombrilla de playa                               |      6631.55 |
| Sureste Coahuila        | P064        | Hielera 24 L                                     |      5135.49 |
| Sureste Coahuila        | P041        | Detergente en polvo 3 kg                         |      4952.00 |
| Sureste Coahuila        | P010        | Agua purificada 20 L                             |      4392.17 |
| Sureste Coahuila        | P027        | Molida de res kg                                 |      4149.76 |
| Sureste Coahuila        | P030        | Arrachera marinada kg                            |      4021.00 |
| Sureste Coahuila        | P019        | Aguacate kg                                      |      3943.71 |
| Sureste Coahuila        | P049        | Shampoo 750 ml                                   |      3914.58 |
| Sureste Coahuila        | P058        | Carbón vegetal 4 kg                              |      3576.58 |
| Sureste Coahuila        | P028        | Chuleta de cerdo kg                              |      3530.62 |
| Sureste Coahuila        | P066        | Tortillas de harina 1 kg (promoción de entrada)  |      3520.32 |
| Sureste Coahuila        | P045        | Papel higiénico 12 rollos                        |      3297.04 |
| Sureste Coahuila        | P056        | Crema corporal 400 ml                            |      2787.62 |
| Sureste Coahuila        | P046        | Lavatrastes 750 ml                               |      2785.77 |
| Sureste Coahuila        | P055        | Rastrillos 4 pzas                                |      2779.44 |
| Sureste Coahuila        | P044        | Suavizante de telas 2 L                          |      2758.26 |
| Sureste Coahuila        | P016        | Leche de soya 1 L                                |      2647.32 |
| Sureste Coahuila        | P003        | Aceite vegetal 1 L                               |      2518.67 |
| Sureste Coahuila        | P008        | Café soluble 200 g                               |      2473.81 |
| Sureste Coahuila        | P051        | Pasta dental 100 ml                              |      2301.14 |
| Sureste Coahuila        | P050        | Jabón de tocador 3 pzas                          |      2228.12 |
| Sureste Coahuila        | P053        | Toallas femeninas 10 pzas                        |      2080.26 |
| Sureste Coahuila        | P005        | Harina de trigo 1 kg                             |      2061.51 |
| Sureste Coahuila        | P052        | Desodorante 150 ml                               |      2051.56 |
| Sureste Coahuila        | P031        | Salchicha de pavo 500 g                          |      2044.92 |
| Sureste Coahuila        | P009        | Refresco cola 2.5 L                              |      1979.55 |
| Sureste Coahuila        | P011        | Jugo de naranja 1 L                              |      1949.43 |
| Sureste Coahuila        | P020        | Jitomate kg                                      |      1929.21 |
| Sureste Coahuila        | P004        | Azúcar 2 kg                                      |      1885.89 |
| Sureste Coahuila        | P043        | Limpiador multiusos 900 ml                       |      1743.01 |
| Sureste Coahuila        | P002        | Frijol negro 900 g                               |      1742.61 |
| Sureste Coahuila        | P006        | Pasta spaghetti 200 g                            |      1635.70 |
| Sureste Coahuila        | P047        | Bolsas para basura 20 pzas                       |      1556.20 |
| Sureste Coahuila        | P035        | Yogurt natural 1 kg                              |      1507.93 |
| Sureste Coahuila        | P039        | Leche deslactosada 1 L                           |      1467.93 |
| Sureste Coahuila        | P040        | Huevo blanco 18 pzas                             |      1467.26 |
| Sureste Coahuila        | P024        | Chile serrano kg                                 |      1383.34 |
| Sureste Coahuila        | P026        | Pechuga de pollo kg                              |      1337.52 |
| Sureste Coahuila        | P014        | Bebida isotónica 600 ml                          |      1269.06 |
| Sureste Coahuila        | P042        | Cloro 1 L                                        |      1206.19 |
| Sureste Coahuila        | P029        | Pierna de pollo kg                               |      1200.59 |
| Sureste Coahuila        | P013        | Agua mineral 600 ml                              |      1182.04 |
| Sureste Coahuila        | P021        | Cebolla blanca kg                                |      1180.12 |
| Sureste Coahuila        | P022        | Limón kg                                         |      1139.12 |
| Sureste Coahuila        | P048        | Servilletas 500 pzas                             |      1038.66 |
| Sureste Coahuila        | P062        | Mango kg                                         |       923.01 |
| Sureste Coahuila        | P001        | Arroz 1 kg                                       |       894.61 |
| Sureste Coahuila        | P036        | Crema ácida 450 ml                               |       867.71 |
| Sureste Coahuila        | P034        | Queso Oaxaca kg                                  |       826.31 |
| Sureste Coahuila        | P061        | Sandía kg                                        |       677.23 |
| Sureste Coahuila        | P018        | Plátano kg                                       |       670.36 |
| Sureste Coahuila        | P007        | Atún en agua 140 g                               |       611.84 |
| Sureste Coahuila        | P015        | Té helado 500 ml                                 |       561.80 |
| Sureste Coahuila        | P037        | Mantequilla 90 g                                 |       545.05 |
| Sureste Coahuila        | P023        | Papa blanca kg                                   |       533.36 |
| Sureste Coahuila        | P033        | Leche entera 1 L                                 |       511.58 |
| Sureste Coahuila        | P057        | Hielo 5 kg                                       |       495.11 |
| Sureste Coahuila        | P017        | Manzana roja kg                                  |       310.42 |
+-------------------------+-------------+--------------------------------------------------+--------------+

```
## 4. EXPLAIN antes / después (explain_antes.sql, indices.sql, explain_despues.sql)
```
+---------------------------------+---------+----------+----------+
| Table                           | Op      | Msg_type | Msg_text |
+---------------------------------+---------+----------+----------+
| mercado_norte.dim_tiempo        | analyze | status   | OK       |
| mercado_norte.fact_ventas_linea | analyze | status   | OK       |
+---------------------------------+---------+----------+----------+
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Sort: c.region, c.posicion  (cost=2.6..2.6 rows=0)
    -> Filter: (c.posicion <= 5)  (cost=2.5..2.5 rows=0)
        -> Table scan on c  (cost=2.5..2.5 rows=0)
            -> Materialize CTE clasificado  (cost=0..0 rows=0)
                -> Window aggregate: row_number() OVER (PARTITION BY a.region ORDER BY a.rentabilidad_act desc,a.producto_id ) 
                    -> Sort: a.region, a.rentabilidad_act DESC, a.producto_id  (cost=2.6..2.6 rows=0)
                        -> Table scan on a  (cost=2.5..2.5 rows=0)
                            -> Materialize CTE agregado  (cost=0..0 rows=0)
                                -> Filter: (round(sum((case when ((t.ANIO = <cache>((@anio_act))) and (t.TRIMESTRE = <cache>((@trim_act)))) then f.MARGEN_BRUTO_MONETARIO end)),2) is not null)
                                    -> Table scan on <temporary>
                                        -> Aggregate using temporary table
                                            -> Nested loop inner join  (cost=569 rows=518)
                                                -> Nested loop inner join  (cost=388 rows=518)
                                                    -> Nested loop inner join  (cost=206 rows=518)
                                                        -> Filter: (((t.TRIMESTRE = <cache>((@trim_act))) and (t.ANIO = <cache>((@anio_act)))) or ((t.TRIMESTRE = <cache>((@trim_ant))) and (t.ANIO = <cache>((@anio_ant)))))  (cost=25.1 rows=4.84)
                                                            -> Table scan on t  (cost=25.1 rows=243)
                                                        -> Index lookup on f using FK_FACT_TIEMPO (TIEMPO_SK=t.TIEMPO_SK)  (cost=29 rows=107)
                                                    -> Single-row index lookup on s using PRIMARY (SUCURSAL_SK=f.SUCURSAL_SK)  (cost=0.25 rows=1)
                                                -> Single-row index lookup on p using PRIMARY (PRODUCTO_SK=f.PRODUCTO_SK)  (cost=0.25 rows=1)
 |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
+----+-------------+------------+------------+--------+--------------------------------------------------+----------------+---------+-----------------------------+------+----------+------------------------------+
| id | select_type | table      | partitions | type   | possible_keys                                    | key            | key_len | ref                         | rows | filtered | Extra                        |
+----+-------------+------------+------------+--------+--------------------------------------------------+----------------+---------+-----------------------------+------+----------+------------------------------+
|  1 | PRIMARY     | <derived2> | NULL       | ALL    | NULL                                             | NULL           | NULL    | NULL                        |  517 |    33.33 | Using where; Using filesort  |
|  2 | DERIVED     | <derived3> | NULL       | ALL    | NULL                                             | NULL           | NULL    | NULL                        |  517 |   100.00 | Using filesort               |
|  3 | DERIVED     | t          | NULL       | ALL    | PRIMARY                                          | NULL           | NULL    | NULL                        |  243 |     1.99 | Using where; Using temporary |
|  3 | DERIVED     | f          | NULL       | ref    | FK_FACT_TIEMPO,FK_FACT_PRODUCTO,FK_FACT_SUCURSAL | FK_FACT_TIEMPO | 4       | mercado_norte.t.TIEMPO_SK   |  107 |   100.00 | NULL                         |
|  3 | DERIVED     | s          | NULL       | eq_ref | PRIMARY                                          | PRIMARY        | 8       | mercado_norte.f.SUCURSAL_SK |    1 |   100.00 | NULL                         |
|  3 | DERIVED     | p          | NULL       | eq_ref | PRIMARY                                          | PRIMARY        | 8       | mercado_norte.f.PRODUCTO_SK |    1 |   100.00 | NULL                         |
+----+-------------+------------+------------+--------+--------------------------------------------------+----------------+---------+-----------------------------+------+----------+------------------------------+


```
```
+---------------------------------+---------+----------+----------+
| Table                           | Op      | Msg_type | Msg_text |
+---------------------------------+---------+----------+----------+
| mercado_norte.dim_tiempo        | analyze | status   | OK       |
| mercado_norte.fact_ventas_linea | analyze | status   | OK       |
+---------------------------------+---------+----------+----------+
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Sort: c.region, c.posicion  (cost=2.6..2.6 rows=0)
    -> Filter: (c.posicion <= 5)  (cost=2.5..2.5 rows=0)
        -> Table scan on c  (cost=2.5..2.5 rows=0)
            -> Materialize CTE clasificado  (cost=0..0 rows=0)
                -> Window aggregate: row_number() OVER (PARTITION BY a.region ORDER BY a.rentabilidad_act desc,a.producto_id ) 
                    -> Sort: a.region, a.rentabilidad_act DESC, a.producto_id  (cost=2.6..2.6 rows=0)
                        -> Table scan on a  (cost=2.5..2.5 rows=0)
                            -> Materialize CTE agregado  (cost=0..0 rows=0)
                                -> Filter: (round(sum((case when ((t.ANIO = <cache>((@anio_act))) and (t.TRIMESTRE = <cache>((@trim_act)))) then f.MARGEN_BRUTO_MONETARIO end)),2) is not null)
                                    -> Table scan on <temporary>
                                        -> Aggregate using temporary table
                                            -> Nested loop inner join  (cost=14165 rows=23309)
                                                -> Nested loop inner join  (cost=6006 rows=23309)
                                                    -> Inner hash join (no condition)  (cost=363 rows=3258)
                                                        -> Table scan on s  (cost=0.0113 rows=18)
                                                        -> Hash
                                                            -> Filter: (((t.TRIMESTRE = <cache>((@trim_act))) and (t.ANIO = <cache>((@anio_act)))) or ((t.TRIMESTRE = <cache>((@trim_ant))) and (t.ANIO = <cache>((@anio_ant)))))  (cost=36.6 rows=181)
                                                                -> Covering index range scan on t using IDX_DIM_TIEMPO_ANIO_TRIM over (ANIO = 2026 AND TRIMESTRE = 1) OR (ANIO = 2026 AND TRIMESTRE = 2)  (cost=36.6 rows=181)
                                                    -> Covering index lookup on f using IDX_FACT_COBERTURA (TIEMPO_SK=t.TIEMPO_SK, SUCURSAL_SK=s.SUCURSAL_SK)  (cost=1.02 rows=7.15)
                                                -> Single-row index lookup on p using PRIMARY (PRODUCTO_SK=f.PRODUCTO_SK)  (cost=0.25 rows=1)
 |
+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
+----+-------------+------------+------------+--------+------------------------------------------------------+--------------------------+---------+-------------------------------------------------------+-------+----------+-------------------------------------------+
| id | select_type | table      | partitions | type   | possible_keys                                        | key                      | key_len | ref                                                   | rows  | filtered | Extra                                     |
+----+-------------+------------+------------+--------+------------------------------------------------------+--------------------------+---------+-------------------------------------------------------+-------+----------+-------------------------------------------+
|  1 | PRIMARY     | <derived2> | NULL       | ALL    | NULL                                                 | NULL                     | NULL    | NULL                                                  | 23308 |    33.33 | Using where; Using filesort               |
|  2 | DERIVED     | <derived3> | NULL       | ALL    | NULL                                                 | NULL                     | NULL    | NULL                                                  | 23308 |   100.00 | Using filesort                            |
|  3 | DERIVED     | t          | NULL       | range  | PRIMARY,IDX_DIM_TIEMPO_ANIO_TRIM                     | IDX_DIM_TIEMPO_ANIO_TRIM | 10      | NULL                                                  |   181 |   100.00 | Using where; Using index; Using temporary |
|  3 | DERIVED     | s          | NULL       | ALL    | PRIMARY                                              | NULL                     | NULL    | NULL                                                  |    18 |   100.00 | Using join buffer (hash join)             |
|  3 | DERIVED     | f          | NULL       | ref    | FK_FACT_PRODUCTO,FK_FACT_SUCURSAL,IDX_FACT_COBERTURA | IDX_FACT_COBERTURA       | 12      | mercado_norte.t.TIEMPO_SK,mercado_norte.s.SUCURSAL_SK |     7 |   100.00 | Using index                               |
|  3 | DERIVED     | p          | NULL       | eq_ref | PRIMARY                                              | PRIMARY                  | 8       | mercado_norte.f.PRODUCTO_SK                           |     1 |   100.00 | NULL                                      |
+----+-------------+------------+------------+--------+------------------------------------------------------+--------------------------+---------+-------------------------------------------------------+-------+----------+-------------------------------------------+

```
## 5. Stored procedure (sp_top5_rentabilidad_region.sql + llamada_prueba.sql)
```
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| region                  | posicion | producto_id | nombre_producto                                  | rentabilidad_act | rentabilidad_ant | variacion_abs | variacion_pct | sin_datos_periodo_ant | nota_variacion                |
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| Laguna                  |        1 | P065        | Cafetera de goteo 12 tazas (lanzamiento)         |         84365.37 |             NULL |          NULL |          NULL |                     1 | SIN DATOS EN PERIODO ANTERIOR |
| Laguna                  |        2 | P060        | Ventilador de mesa                               |          6041.73 |          5490.41 |        551.32 |         10.04 |                     0 | COMPARABLE                    |
| Laguna                  |        3 | P063        | Sombrilla de playa                               |          5875.34 |          6287.50 |       -412.16 |         -6.56 |                     0 | COMPARABLE                    |
| Laguna                  |        4 | P064        | Hielera 24 L                                     |          4919.48 |          6049.15 |      -1129.67 |        -18.67 |                     0 | COMPARABLE                    |
| Laguna                  |        5 | P038        | Queso panela kg                                  |          4468.50 |          3025.29 |       1443.21 |         47.70 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        1 | P060        | Ventilador de mesa                               |         13615.43 |         19805.69 |      -6190.26 |        -31.25 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        2 | P012        | Cerveza lager 12 pzas                            |          9580.64 |          7177.05 |       2403.59 |         33.49 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        3 | P038        | Queso panela kg                                  |          8133.34 |          5944.19 |       2189.15 |         36.83 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        4 | P054        | Pañales etapa 3 (40 pzas)                        |          6453.65 |          3365.95 |       3087.70 |         91.73 |                     0 | COMPARABLE                    |
| Metropolitana Monterrey |        5 | P064        | Hielera 24 L                                     |          6060.68 |          8086.29 |      -2025.61 |        -25.05 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        1 | P060        | Ventilador de mesa                               |          9857.99 |          7038.03 |       2819.96 |         40.07 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        2 | P038        | Queso panela kg                                  |          5337.77 |          4050.64 |       1287.13 |         31.78 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        3 | P064        | Hielera 24 L                                     |          5045.57 |          4673.60 |        371.97 |          7.96 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        4 | P041        | Detergente en polvo 3 kg                         |          2954.02 |          1995.21 |        958.81 |         48.06 |                     0 | COMPARABLE                    |
| Sur Nuevo León          |        5 | P012        | Cerveza lager 12 pzas                            |          2164.95 |          1088.72 |       1076.23 |         98.85 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        1 | P060        | Ventilador de mesa                               |          4606.74 |          2610.20 |       1996.54 |         76.49 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        2 | P054        | Pañales etapa 3 (40 pzas)                        |          4599.65 |          2429.88 |       2169.77 |         89.30 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        3 | P025        | Bistec de res kg                                 |          3614.83 |          3677.64 |        -62.81 |         -1.71 |                     0 | COMPARABLE                    |
| Sureste Coahuila        |        4 | P066        | Tortillas de harina 1 kg (promoción de entrada)  |          3520.32 |             0.00 |       3520.32 |          NULL |                     0 | BASE CERO: % NO DEFINIDO      |
| Sureste Coahuila        |        5 | P038        | Queso panela kg                                  |          2729.48 |          2369.39 |        360.09 |         15.20 |                     0 | COMPARABLE                    |
+-------------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
ERROR 1644 (45000) at line 4: Parametros invalidos: p_anio no puede ser NULL y p_trimestre debe estar entre 1 y 4

```

## 6. Validaciones V01–V15 (validacion_mysql.sql)
Criterio: cada bloque debe cumplir el criterio indicado en validacion.sql
```
+-------------------+-------+
| tabla             | filas |
+-------------------+-------+
| FACT_VENTAS_LINEA | 26944 |
| DIM_TIEMPO        |   243 |
| DIM_PRODUCTO      |    66 |
| DIM_SUCURSAL      |    18 |
| DMI_CLIENTE       |   421 |
| DIM_CANAL         |     5 |
| DIM_PROMOCION     |     6 |
+-------------------+-------+
+----------------------+-----------+
| fk                   | huerfanos |
+----------------------+-----------+
| CLIENTE              |         0 |
| TIEMPO               |         0 |
| PRODUCTO             |         0 |
| SUCURSAL             |         0 |
| CANAL                |         0 |
| PROMOCION (no nulos) |         0 |
+----------------------+-----------+
+-----------------+
| pares_repetidos |
+-----------------+
|               0 |
+-----------------+
+---------------------------+
| lineas_con_monto_negativo |
+---------------------------+
|                         0 |
+---------------------------+
+----------------------+------------------+----------------------------------+
| inconsist_venta_neta | inconsist_margen | descuento_o_devolucion_excesivos |
+----------------------+------------------+----------------------------------+
|                    0 |                0 |                                0 |
+----------------------+------------------+----------------------------------+
+-----------------------+------------------+
| trimestre_incoherente | fechas_repetidas |
+-----------------------+------------------+
|                     0 |                0 |
+-----------------------+------------------+
+------+-----------+---------------+--------------+--------+
| ANIO | TRIMESTRE | primera_fecha | ultima_fecha | lineas |
+------+-----------+---------------+--------------+--------+
| 2026 |         1 | 2026-01-01    | 2026-03-31   |   9921 |
| 2026 |         2 | 2026-04-01    | 2026-06-30   |  10303 |
+------+-----------+---------------+--------------+--------+
+-------------------------+------------+---------------------+--------+
| region                  | sucursales | productos_con_venta | lineas |
+-------------------------+------------+---------------------+--------+
| Laguna                  |          4 |                  65 |   2340 |
| Metropolitana Monterrey |          7 |                  64 |   3886 |
| Sur Nuevo León          |          3 |                  64 |   1697 |
| Sureste Coahuila        |          4 |                  65 |   2380 |
+-------------------------+------------+---------------------+--------+
+----------+------------------------+------------------+------------+
| periodo  | margen_hecho_sin_joins | margen_con_joins | diferencia |
+----------+------------------------+------------------+------------+
| actual   |              408441.53 |        408441.53 |       0.00 |
| anterior |              305940.86 |        305940.86 |       0.00 |
+----------+------------------------+------------------+------------+
+-------------------------+----------------------+
| region                  | margen_region_actual |
+-------------------------+----------------------+
| Laguna                  |            151433.53 |
| Metropolitana Monterrey |            124815.37 |
| Sur Nuevo León          |             62530.05 |
| Sureste Coahuila        |             69662.58 |
+-------------------------+----------------------+
+-------------------------+-------+---------+---------+----------------------+
| region                  | filas | min_pos | max_pos | posiciones_distintas |
+-------------------------+-------+---------+---------+----------------------+
| Laguna                  |     5 |       1 |       5 |                    5 |
| Metropolitana Monterrey |     5 |       1 |       5 |                    5 |
| Sur Nuevo León          |     5 |       1 |       5 |                    5 |
| Sureste Coahuila        |     5 |       1 |       5 |                    5 |
+-------------------------+-------+---------+---------+----------------------+
+-----------------+------------------+------------------+
| fuente          | rentabilidad_act | rentabilidad_ant |
+-----------------+------------------+------------------+
| cálculo manual  |          9857.99 |          7038.03 |
+-----------------+------------------+------------------+
+------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| region           | posicion | producto_id | nombre_producto                                  | rentabilidad_act | rentabilidad_ant | variacion_abs | variacion_pct | sin_datos_periodo_ant | nota_variacion                |
+------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
| Laguna           |        1 | P065        | Cafetera de goteo 12 tazas (lanzamiento)         |         84365.37 |             NULL |          NULL |          NULL |                     1 | SIN DATOS EN PERIODO ANTERIOR |
| Sureste Coahuila |        4 | P066        | Tortillas de harina 1 kg (promoción de entrada)  |          3520.32 |             0.00 |       3520.32 |          NULL |                     0 | BASE CERO: % NO DEFINIDO      |
+------------------+----------+-------------+--------------------------------------------------+------------------+------------------+---------------+---------------+-----------------------+-------------------------------+
+---------+-------------------------+-------+
| version | REGION                  | filas |
+---------+-------------------------+-------+
| V1      | Laguna                  |     5 |
| V2      | Laguna                  |     5 |
| V1      | Metropolitana Monterrey |     5 |
| V2      | Metropolitana Monterrey |     5 |
| V1      | Sur Nuevo León          |     6 |
| V2      | Sur Nuevo León          |     5 |
| V1      | Sureste Coahuila        |     5 |
| V2      | Sureste Coahuila        |     5 |
+---------+-------------------------+-------+
+-------------------------+------------------------------------+----------------+
| region                  | promedio_incorrecto_de_porcentajes | razon_correcta |
+-------------------------+------------------------------------+----------------+
| Laguna                  |                            25.0628 |        26.0509 |
| Metropolitana Monterrey |                            24.2579 |        21.1735 |
| Sur Nuevo León          |                            26.1205 |        23.6191 |
| Sureste Coahuila        |                            24.2686 |        21.6672 |
+-------------------------+------------------------------------+----------------+

```
