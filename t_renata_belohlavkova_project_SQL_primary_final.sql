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
