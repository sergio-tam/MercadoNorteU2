@echo off
rem Ejecuta todo el flujo en MySQL 8 (Windows). Guarda las salidas reales en salidas_mysql\
chcp 65001 >nul
cd /d "%~dp0.."
if not exist 05_validacion_y_explain\salidas_mysql mkdir 05_validacion_y_explain\salidas_mysql

rem --- ubicar mysql.exe (si no esta en el PATH, intenta la ruta tipica de instalacion)
where mysql >nul 2>nul
if errorlevel 1 (
  if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
    set "PATH=%PATH%;C:\Program Files\MySQL\MySQL Server 8.0\bin"
  ) else (
    echo No se encontro mysql.exe. Agrega la carpeta bin de MySQL al PATH o edita este archivo.
    pause & exit /b 1
  )
)

set /p MYSQL_USER=Usuario de MySQL [root]: 
if "%MYSQL_USER%"=="" set MYSQL_USER=root
set /p MYSQL_PWD=Contrasena de MySQL (se escribe visible): 
set "M=mysql -u %MYSQL_USER% --table --force --default-character-set=utf8mb4"
set "S=05_validacion_y_explain\salidas_mysql"

echo [1/8] Creando base y tablas...
%M% < 02_ddl_y_datos\01_ddl_mysql.sql || goto :err
echo [2/8] Cargando datos (puede tardar unos segundos)...
%M% < 02_ddl_y_datos\02_carga_datos_mysql.sql || goto :err
echo [3/8] Consulta final...
(echo USE mercado_norte; SET @anio_act=2026,@trim_act=2,@anio_ant=2026,@trim_ant=1; & type 04_consultas_sql\q_v2_final_validada.sql) | %M% > %S%\consulta_final.txt 2>&1
echo [4/8] Validaciones...
%M% < 05_validacion_y_explain\validacion_mysql.sql > %S%\validaciones.txt 2>&1
echo [5/8] Error 1055 (el error en la consulta (a) es lo esperado)...
%M% < 05_validacion_y_explain\error_1055.sql > %S%\error_1055.txt 2>&1
echo [6/8] EXPLAIN antes, indices y EXPLAIN despues...
%M% < 05_validacion_y_explain\explain_antes.sql > %S%\explain_antes.txt 2>&1
%M% < 05_validacion_y_explain\indices.sql > %S%\indices.txt 2>&1
%M% < 05_validacion_y_explain\explain_despues.sql > %S%\explain_despues.txt 2>&1
echo [7/8] Creando stored procedure...
%M% < 06_stored_procedure\sp_top5_rentabilidad_region.sql || goto :err
echo [8/8] Llamadas de prueba (la 2a debe fallar a proposito)...
%M% < 06_stored_procedure\llamada_prueba.sql > %S%\llamada_sp.txt 2>&1

echo.
echo Listo. Revisa la carpeta 05_validacion_y_explain\salidas_mysql\
pause
exit /b 0
:err
echo Hubo un error. Revisa el mensaje de arriba.
pause
exit /b 1
