 --a) Vytvoření sekundární tabulky pro ČR 
  
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

-- b) Dodatečná tabulka s HDP, GINI koeficientm a populace za Evropu 

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