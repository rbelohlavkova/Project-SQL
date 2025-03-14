# Projekt : Projekt z SQL

## 1)	Úvod do projektu
  
Na našem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jsme se dohodli, že se pokusíme odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.
Potřebují k tomu od nás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.
Jako dodatečný materiál máme připravit i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

## 2) Datové sady, které je možné požít pro získání vhodného datového podkladu
### Primární tabulky:

<li>czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
<li>czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
<li>czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
<li>czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
<li>czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
<li>czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
<li>czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

### Číselníky sdílených informací o ČR:
<li>czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
<li>czechia_district – Číselník okresů České republiky dle normy LAU.

### Dodatečné tabulky:
<li>countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
<li>economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

## 	3) Výzkumné otázky

1)	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2)	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3)	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4)	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5)	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## 4) Výstupy z projektu jsou obsaženy v přiložených souborech

<li>Renata_Belohlavkova_projekt_SQL_2024_11_04 – zadání a odpovědi na otázky
<li>t_Renata_Belohlavkova_project_SQL_primary_final – vytvoření primární tabulky v SQL
<li>t_Renata_Belohlavkova_project_SQL_secondary_final – vytvoření sekundární tabulky v SQL
<li>Renata_Belohlavkova_Questions_SQL – dotazy v SQL

