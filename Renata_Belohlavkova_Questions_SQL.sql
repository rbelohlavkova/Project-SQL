-- Vytvoření primární tabulky 

CREATE TABLE t_renata_belohlavkova_project_SQL_primary_final AS
SELECT  
 	cpc.name AS goods_category,
    cpc.price_value,
    cpc.price_unit,
    cp.value AS price,
    cpib.name AS industry,
    cpay.value AS wages,
    cpay.payroll_year AS year,
    cpay.value_type_code
FROM czechia_price cp
JOIN czechia_payroll AS cpay
    ON date_part('year', cp.date_from) = cpay.payroll_year
JOIN czechia_price_category AS cpc
    ON cp.category_code = cpc.code
JOIN czechia_payroll_industry_branch AS cpib    
    ON cpay.industry_branch_code = cpib.code
WHERE cp.region_code IS NULL AND cpay.value_type_code = 5958 ;


-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 

SELECT 
	"year",
	industry,
	round(avg(wages)::NUMERIC,0) AS avg_wages,
	LAG (round(avg(wages)::NUMERIC,0)) OVER (PARTITION BY industry ORDER BY year) AS previous_wages,
		CASE 
        WHEN LAG(round(avg(wages)::NUMERIC,0)) OVER (PARTITION BY industry ORDER BY YEAR) IS NULL THEN NULL
        ELSE round(((avg(wages) - LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY year)) / LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY "year"))::NUMERIC,3) * 100
    END AS percentage_growth,
    CASE 
    	WHEN round(((avg(wages) - LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY year)) / LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY "year"))::NUMERIC,3) * 100 > 0 THEN 'increase'
        WHEN round(((avg(wages) - LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY year)) / LAG(avg(wages)) OVER (PARTITION BY industry ORDER BY "year"))::NUMERIC,0) * 100 IS NULL THEN ' '
    	ELSE 'DECREASE or 0'
    	END AS "result" 
FROM t_renata_belohlavkova_project_sql_primary_final
GROUP BY 
	"year" ,
	industry 
ORDER BY industry, "year";


-- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? 

SELECT
	"year",
	goods_category,
	round(avg(price)::NUMERIC,1) AS avg_price,
	round(avg(wages)::NUMERIC ,0) AS avg_wages,
	round(avg(wages)/avg(price)::NUMERIC,0) AS result
FROM t_renata_belohlavkova_project_sql_primary_final 
WHERE goods_category IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované') AND  
 	"year" IN (
  	(SELECT
 	MAX("year")
  	FROM t_renata_belohlavkova_project_sql_primary_final),
 	 (SELECT 
  	MIN("year") 
FROM t_renata_belohlavkova_project_sql_primary_final))
GROUP BY goods_category, "year";



/*
 * 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 */

-- a) Hledám kategorii v určitém roce

WITH avg_prices AS (
    SELECT
       	"year",
        goods_category ,
        AVG(price) AS avg_price 
    FROM t_renata_belohlavkova_project_sql_primary_final 
    GROUP BY "year", goods_category 
),
price_difference AS (
SELECT
   	  "year",
      goods_category ,
      avg_price,
      LAG(avg_price) OVER (PARTITION BY goods_category ORDER BY year) AS previous_price 
FROM avg_prices 
)
SELECT 
	"year",
    goods_category,
    MIN(
        CASE
            WHEN previous_price IS NOT NULL THEN
                ((avg_price - previous_price ) / previous_price ) * 100
            ELSE NULL
        END
    ) AS growth
FROM price_difference 
GROUP BY goods_category,"year"
ORDER BY growth ASC;



-- b) hledám kategorii, která má nejnižší průměr meziročního růstu za sledovaného období 
 

WITH percentage_growth_data AS (
SELECT 
	year , 
	goods_category,
	avg(price) AS avg_price,
	LAG (avg(price)) OVER (PARTITION BY goods_category ORDER BY year) AS previous_price,
	CASE 
        WHEN LAG(avg(price)) OVER (PARTITION BY goods_category ORDER BY year) IS NULL THEN NULL
        ELSE ((avg(price) - LAG(avg(price)) OVER (PARTITION BY goods_category ORDER BY year)) / LAG(avg(price)) OVER (PARTITION BY goods_category ORDER BY "year")) * 100
    END AS percentage_growth
FROM t_renata_belohlavkova_project_sql_primary_final
GROUP BY goods_category, "year"
ORDER BY goods_category, "year"
)
SELECT 
goods_category,
	(EXP(avg(ln(1 + (percentage_growth / 100))) ) - 1)*100 AS geometric_growth 	
FROM percentage_growth_data 
WHERE percentage_growth IS NOT NULL 
GROUP BY goods_category
ORDER BY geometric_growth ASC;


-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? --


SELECT 
 	"year",
 	round(avg(wages)::NUMERIC,0) AS avg_wages ,
 	round(avg(price)::NUMERIC,2) AS avg_price ,
 	round(LAG (avg(wages)) OVER (ORDER BY "year")::NUMERIC,0) AS privios_wages,
 	round(LAG(avg(price)) OVER (ORDER BY "year")::NUMERIC,2) AS privios_price,
 	CASE
        WHEN round(LAG(avg(wages)) OVER (ORDER BY YEAR)::NUMERIC,0) IS NULL THEN NULL
        ELSE round(((avg(wages) - LAG(avg(wages)) OVER (ORDER BY year)) / LAG(avg(wages)) OVER (ORDER BY year))::NUMERIC,3) * 100 
    END AS percentage_growth_wages,
    CASE
        WHEN LAG(avg(price)) OVER (ORDER BY YEAR) IS NULL THEN NULL
        ELSE round(((avg(price) - LAG(avg(price)) OVER (ORDER BY year)) / LAG(avg(price)) OVER (ORDER BY year))::NUMERIC,3) * 100
    END AS percentage_growth_prices,
    CASE
		WHEN round(((avg(price) - LAG(avg(price)) OVER (ORDER BY year)) / LAG(avg(price)) OVER (ORDER BY year))::NUMERIC,3) * 100 >= 10 THEN 'yes'
		ELSE 'ne'
	END AS "result"
FROM t_renata_belohlavkova_project_sql_primary_final 
WHERE NOT goods_category ='Jakostní víno bílé'
GROUP BY "year"
ORDER BY "year";


 -- Vytvoření sekundární tabulky pro ČR 
  
CREATE TABLE t_renata_belohlavkova_project_SQL_secondary_final AS
SELECT 
	ec.year,
	avg(cpay.value) AS avg_wages ,
	avg(cp.value) AS avg_prices,
	avg(gdp)/1000000000 AS gdp_mld
FROM economies ec
JOIN czechia_payroll cpay
	ON cpay.payroll_year = ec.YEAR
JOIN czechia_price cp 
	ON cpay.payroll_year = date_part ('year',cp.date_from)
WHERE cpay.value_type_code = 5958 AND ec.country = 'Czech Republic' AND  cp.region_code IS NULL
GROUP BY ec."year"
ORDER BY year;

/* 
 *5) Má výška HDP vliv na změny ve mzdách a cenách potravin?
 */
 
  SELECT 
	"year",
	round((gdp_mld)::NUMERIC,2) AS hdp_mld,
	round((avg_wages)::NUMERIC,0) AS wages,
	round((avg_prices)::NUMERIC,1) AS prices,
	round(((gdp_mld - LAG(gdp_mld) OVER (ORDER BY "year")) / LAG(gdp_mld) OVER (ORDER BY "year") * 100)::NUMERIC,1) AS percentage_growth_hdp,
	round(((avg_wages - LAG(avg_wages) OVER (ORDER BY "year")) / LAG(avg_wages) OVER (ORDER BY "year") * 100)::NUMERIC,1) AS percentage_growth_wages,
	round(((avg_prices - LAG(avg_prices) OVER (ORDER BY "year")) / LAG(avg_prices) OVER (ORDER BY "year") * 100)::NUMERIC,1) AS percentage_growth_prices 
FROM t_renata_belohlavkova_project_sql_secondary_final;


-- Dodatečná tabulka s HDP, GINI koeficientm a populace za Evropu 

CREATE table t_renata_belohlavkova_project_SQL_other_data AS
SELECT
	e.year, 
	e.country, 
	e.GDP,
	e.gini, 
	e.population,
	e.taxes
FROM economies e 
JOIN countries c 
	ON e.country = c.country 
WHERE "year" BETWEEN 2006 AND 2018 AND continent = 'Europe' AND gini IS NOT NULL 
ORDER BY e.year, e.country;



