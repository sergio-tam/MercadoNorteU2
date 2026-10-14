/* =========================================================
   DIMENSION: CLIENTE
   ========================================================= */
CREATE TABLE DMI_CLIENTE (
    CLIENTE_SK       BIGINT GENERATED ALWAYS AS IDENTITY,
    CLIENTE_ID       VARCHAR(50),
    NOMBRE           VARCHAR(150),
    TIPO_CLIENTE     VARCHAR(50),
    SEGMENTO         VARCHAR(50),
    CIUDAD           VARCHAR(100),
    ESTADO           VARCHAR(100),
    PAIS             VARCHAR(100),

    CONSTRAINT PK_DMI_CLIENTE
        PRIMARY KEY (CLIENTE_SK)
);


/* =========================================================
   DIMENSION: TIEMPO
   ========================================================= */
CREATE TABLE DIM_TIEMPO (
    TIEMPO_SK        INT GENERATED ALWAYS AS IDENTITY,
    FECHA            DATE NOT NULL,
    DIA              INT,
    MES              INT,
    NOMBRE_MES       VARCHAR(20),
    TRIMESTRE        INT,
    ANIO             INT,
    SEMANA_ANIO      INT,
    DIA_SEMANA       INT,
    NOMBRE_DIA       VARCHAR(20),

    CONSTRAINT PK_DIM_TIEMPO
        PRIMARY KEY (TIEMPO_SK)
);


/* =========================================================
   DIMENSION: PRODUCTO
   ========================================================= */
CREATE TABLE DIM_PRODUCTO (
    PRODUCTO_SK      BIGINT GENERATED ALWAYS AS IDENTITY,
    PRODUCTO_ID      VARCHAR(50),
    NOMBRE_PRODUCTO  VARCHAR(150),
    CATEGORIA        VARCHAR(100),
    SUBCATEGORIA     VARCHAR(100),
    MARCA            VARCHAR(100),

    CONSTRAINT PK_DIM_PRODUCTO
        PRIMARY KEY (PRODUCTO_SK)
);


/* =========================================================
   DIMENSION: SUCURSAL
   ========================================================= */
CREATE TABLE DIM_SUCURSAL (
    SUCURSAL_SK      BIGINT GENERATED ALWAYS AS IDENTITY,
    SUCURSAL_ID      VARCHAR(50),
    NOMBRE_SUCURSAL  VARCHAR(150),
    CIUDAD           VARCHAR(100),
    ESTADO           VARCHAR(100),
    REGION           VARCHAR(100),

    CONSTRAINT PK_DIM_SUCURSAL
        PRIMARY KEY (SUCURSAL_SK)
);


/* =========================================================
   DIMENSION: CANAL
   ========================================================= */
CREATE TABLE DIM_CANAL (
    CANAL_SK         INT GENERATED ALWAYS AS IDENTITY,
    CANAL_ID         VARCHAR(50),
    NOMBRE_CANAL     VARCHAR(100),
    TIPO_CANAL       VARCHAR(50),

    CONSTRAINT PK_DIM_CANAL
        PRIMARY KEY (CANAL_SK)
);


/* =========================================================
   DIMENSION: PROMOCION
   ========================================================= */
CREATE TABLE DIM_PROMOCION (
    PROMOCION_SK     BIGINT GENERATED ALWAYS AS IDENTITY,
    PROMOCION_ID     VARCHAR(50),
    NOMBRE_PROMOCION VARCHAR(150),
    TIPO_PROMOCION   VARCHAR(100),
    PORCENTAJE_DESC  DECIMAL(5,2),
    FECHA_INICIO     DATE,
    FECHA_FIN        DATE,

    CONSTRAINT PK_DIM_PROMOCION
        PRIMARY KEY (PROMOCION_SK)
);


/* =========================================================
   FACT TABLE
   Grano: una línea de venta
   ========================================================= */
CREATE TABLE FACT_VENTAS_LINEA (
    VENTA_LINEA_SK       BIGINT GENERATED ALWAYS AS IDENTITY,

    CLIENTE_SK           BIGINT NOT NULL,
    TIEMPO_SK            INT NOT NULL,
    PRODUCTO_SK          BIGINT NOT NULL,
    SUCURSAL_SK          BIGINT NOT NULL,
    CANAL_SK             INT NOT NULL,
    PROMOCION_SK         BIGINT,

    ORDEN_ID              VARCHAR(50) NOT NULL,
    LINEA_ORDEN           INT NOT NULL,

    UNIDADES              DECIMAL(18,3) NOT NULL,

    VENTA_BRUTA           DECIMAL(18,2) NOT NULL,
    MONTO_DESCUENTO       DECIMAL(18,2) NOT NULL,
    MONTO_IMPUESTO        DECIMAL(18,2) NOT NULL,
    MONTO_DEVOLUCION      DECIMAL(18,2) NOT NULL,
    COSTO_TOTAL           DECIMAL(18,2) NOT NULL,
    VENTA_NETA            DECIMAL(18,2) NOT NULL,
    MARGEN_BRUTO_MONETARIO DECIMAL(18,2) NOT NULL,
    MARGEN_PORCENTUAL     DECIMAL(9,4),

    TICKET_PROMEDIO       DECIMAL(18,2),
    UNIDADES_POR_ORDEN    DECIMAL(18,3),

    CONSTRAINT PK_FACT_VENTAS_LINEA
        PRIMARY KEY (VENTA_LINEA_SK),

    CONSTRAINT FK_FACT_CLIENTE
        FOREIGN KEY (CLIENTE_SK)
        REFERENCES DMI_CLIENTE(CLIENTE_SK),

    CONSTRAINT FK_FACT_TIEMPO
        FOREIGN KEY (TIEMPO_SK)
        REFERENCES DIM_TIEMPO(TIEMPO_SK),

    CONSTRAINT FK_FACT_PRODUCTO
        FOREIGN KEY (PRODUCTO_SK)
        REFERENCES DIM_PRODUCTO(PRODUCTO_SK),

    CONSTRAINT FK_FACT_SUCURSAL
        FOREIGN KEY (SUCURSAL_SK)
        REFERENCES DIM_SUCURSAL(SUCURSAL_SK),

    CONSTRAINT FK_FACT_CANAL
        FOREIGN KEY (CANAL_SK)
        REFERENCES DIM_CANAL(CANAL_SK),

    CONSTRAINT FK_FACT_PROMOCION
        FOREIGN KEY (PROMOCION_SK)
        REFERENCES DIM_PROMOCION(PROMOCION_SK)
);
