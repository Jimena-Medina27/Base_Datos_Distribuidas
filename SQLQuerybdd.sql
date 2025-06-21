-----Fracmentacion de nodos por entidades---------------------------------------------------------
--Nodo A "Norte" Sql Server



--Nodo B "Centro_Norte" Sql Server



--Nodo C "Centro_Sur" Sql Server

Use covidHistorico;
go
--Traspasar y dividir las tablas
SELECT * INTO datoscovid_centro_sur
FROM covidHistorico.dbo.datoscovid
WHERE ENTIDAD_RES IN (09,15,17,21,29,13,16,12);
--Visualizar la fragmentacion
SELECT * FROM datoscovid_centro_sur
    
--Nodo D "Sur" MySQL


--------Consulta 3--------------------------------------------------------
--Porcentaje de casos confirmados de diabetes, obesidad e hipertensión.

SELECT
    'Diabetes' AS morbilidad,
    (COUNT(CASE WHEN DIABETES = 1 AND CLASIFICACION_FINAL = 3 THEN 1 END) * 100.0) / COUNT(CASE WHEN CLASIFICACION_FINAL = 3 THEN 1 END) AS porcentaje
FROM dbo.datoscovid
UNION ALL
SELECT
    'Obesidad' AS morbilidad,
    (COUNT(CASE WHEN OBESIDAD = 1 AND CLASIFICACION_FINAL = 3 THEN 1 END) * 100.0) / COUNT(CASE WHEN CLASIFICACION_FINAL = 3 THEN 1 END) AS porcentaje
FROM dbo.datoscovid
UNION ALL
SELECT
    'Hipertensión' AS morbilidad,
    (COUNT(CASE WHEN HIPERTENSION = 1 AND CLASIFICACION_FINAL = 3 THEN 1 END) * 100.0) / COUNT(CASE WHEN CLASIFICACION_FINAL = 3 THEN 1 END) AS porcentaje
FROM dbo.datoscovid;

-------Consulta 4---------------------------------------------------
--Municipios que no tengan casos confirmados de hipertensión, obesidad, diabetes y tabaquismo.

SELECT DISTINCT MUNICIPIO_RES INTO #temporal_municipios
FROM (
    SELECT MUNICIPIO_RES 
    FROM [YUVIA\ABIGAIL].[covidHistorico].[dbo].[datoscovid_norte]
    WHERE CLASIFICACION_FINAL = 3 AND (DIABETES = 1 OR OBESIDAD = 1 OR TABAQUISMO = 1)
    UNION
    SELECT MUNICIPIO_RES 
    FROM [PC-MONZEE\SQLEXPRESS03].[covidHistorico].[dbo].[datoscovid_centro_norte]
    WHERE CLASIFICACION_FINAL = 3 AND (DIABETES = 1 OR OBESIDAD = 1 OR TABAQUISMO = 1)
    UNION    
    SELECT MUNICIPIO_RES 
    FROM covidHistorico.dbo.[datoscovid_centro_sur]
    WHERE CLASIFICACION_FINAL = 3 AND (DIABETES = 1 OR OBESIDAD = 1 OR TABAQUISMO = 1)    
    UNION    
    SELECT MUNICIPIO_RES 
    FROM OPENQUERY([MYSQLYUVIA], '
        SELECT MUNICIPIO_RES 
        FROM datoscovid 
        WHERE CLASIFICACION_FINAL = 3
        AND (DIABETES = 1 OR OBESIDAD = 1 OR TABAQUISMO = 1)
    ')
) AS datos;

SELECT DISTINCT MUNICIPIO_RES
FROM (
    SELECT MUNICIPIO_RES FROM [YUVIA\ABIGAIL].[covidHistorico].[dbo].[datoscovid_norte]
    UNION
    SELECT MUNICIPIO_RES FROM [PC-MONZEE\SQLEXPRESS03].[covidHistorico].[dbo].[datoscovid_centro_norte]
    UNION
    SELECT MUNICIPIO_RES FROM covidHistorico.dbo.[datoscovid_centro_sur]
    UNION
    SELECT MUNICIPIO_RES FROM OPENQUERY([MYSQLYUVIA], 'SELECT MUNICIPIO_RES FROM datoscovid')
) AS todos_municipios
WHERE MUNICIPIO_RES NOT IN (SELECT MUNICIPIO_RES FROM #temporal_municipios)
ORDER BY MUNICIPIO_RES;

DROP TABLE #temporal_municipios;

-------Consulta 5-----------------------------------------------------
--Estados con más casos recuperados con neumonía.

SELECT 
    ENTIDAD_NAC AS estado,
    COUNT(*) AS total_recuperados_con_neumonia
FROM dbo.datoscovid
WHERE CLASIFICACION_FINAL = 3  -- Casos confirmados
AND NEUMONIA = 1              -- Pacientes con neumonía
AND FECHA_DEF IS NULL         -- Filtramos solo los recuperados (no fallecidos)
GROUP BY ENTIDAD_NAC
ORDER BY total_recuperados_con_neumonia DESC;

SELECT COUNT(*)
FROM dbo.datoscovid
WHERE CLASIFICACION_FINAL = 3 AND NEUMONIA = 1;


----------------------------------------------------------
SELECT 
    ENTIDAD_NAC AS estado,
    COUNT(*) AS total_casos_con_neumonia
FROM dbo.datoscovid
WHERE CLASIFICACION_FINAL = 3  -- Casos confirmados
AND NEUMONIA = 1              -- Pacientes con neumonía
GROUP BY ENTIDAD_NAC
ORDER BY total_casos_con_neumonia DESC;
------------------------------------------------------------

SELECT DISTINCT ENTIDAD_NAC
FROM dbo.datoscovid
WHERE CLASIFICACION_FINAL = 3  
AND NEUMONIA = 1;
