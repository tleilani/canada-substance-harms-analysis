-- SECTION 1:
-- Q: How have opioid related toxicity deaths changed in Canada from 2016–2025?
-- 1.Annual opioid death number in Canada
SELECT year , numeric_value AS number_of_death
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
ORDER BY year DESC;

-- 2. Compare opioid-related deaths with the previous year
WITH annual_deaths AS (SELECT year , numeric_value AS number_of_death
            FROM `my-project-502900.substance_harms_canada.clean_harms`
            WHERE Substance = 'Opioids'
                  AND Source = 'Deaths'
                  AND Specific_Measure = 'Overall numbers'
                  AND Region = 'Canada'
                  AND Unit = 'Number'
                  AND Time_Period = 'By year')
SELECT year, number_of_death,
      LAG(number_of_death) OVER (ORDER BY year) AS  previous_year_deaths
FROM annual_deaths
ORDER BY year;                        

-- 3. Year over year change in opioid deaths
--absolute change = current year deaths - previous year deaths
--percentage change = absolute change / previous year deaths × 100
WITH annual_deaths AS (
    SELECT
        year,
        numeric_value AS number_of_deaths

    FROM `my-project-502900.substance_harms_canada.clean_harms`

    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Region = 'Canada'
        AND Unit = 'Number'
        AND Time_Period = 'By year'),

with_previous_year AS (SELECT year, number_of_deaths,
        LAG(number_of_deaths) OVER (ORDER BY year) AS previous_year_deaths
    FROM annual_deaths)

--SAFE_DIVIDE(numerator, denominator)

SELECT year, number_of_deaths, previous_year_deaths,
    number_of_deaths - previous_year_deaths AS annual_change,
    ROUND(
        SAFE_DIVIDE(
            number_of_deaths - previous_year_deaths, previous_year_deaths) * 100,2) AS percent_change
FROM with_previous_year
ORDER BY year; 

-- 4. Overall change in opioid deaths from 2016 to 2025
SELECT
    MAX(CASE WHEN year = 2016 THEN numeric_value END) AS deaths_2016,
    MAX(CASE WHEN year = 2025 THEN numeric_value END) AS deaths_2025,

    MAX(CASE WHEN year = 2025 THEN numeric_value END) - MAX(CASE WHEN year = 2016 THEN numeric_value END) AS total_change,

    ROUND(SAFE_DIVIDE(
            MAX(CASE WHEN year = 2025 THEN numeric_value END)
            - MAX(CASE WHEN year = 2016 THEN numeric_value END),

            MAX(CASE WHEN year = 2016 THEN numeric_value END)) * 100,2) AS percent_change

FROM `my-project-502900.substance_harms_canada.clean_harms`

WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year';


-- SECTION 2
-- Q: How did opioid deaths change quarter by quarter in Canada from 2016–2025?
-- 1: quarterly opiod death in Canada
SELECT start_date, year, quarter, numeric_value AS number_of_deaths
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By quarter'
ORDER BY start_date;


-- SECTION 3
-- Q: How have opioid and stimulant toxicity deaths changed over time in Canada?
-- 1. Annual opioid vs stimulant deaths in Canada
SELECT year, Substance,numeric_value AS number_of_deaths
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'

ORDER BY year, Substance; --18 rows instead of 20. stimulant starts from 2018.



--SECTION 4
-- Q: How do opioid death rates differ across Canadian provinces and territories?
-- 1. Opioid death rates by province/territory in 2025
SELECT Region, numeric_value AS death_rate
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Unit = 'Crude rate'
    AND Time_Period = 'By year'
    AND year = 2025
    AND Region != 'Canada'
ORDER BY death_rate DESC;


--SECTION 5
-- Q: Which age groups have experienced the greatest opioid death?
-- 1.Opiod death number in various age groups in CANADA 2025
SELECT aggregator AS age_group, disaggregator AS sex, numeric_value AS number_of_deaths
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure IN ('Age group', 'Sex and age group')
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
    AND year = 2025
ORDER BY number_of_deaths DESC;

-- SECTION 6
-- Q: What types of opioids are involved in opioid toxicity deaths in Canada?
SELECT Disaggregator AS opioid_type, numeric_value AS percent_of_deaths
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Type of opioids'
    AND Region = 'Canada'
    AND Unit = 'Percent'
    AND Time_Period = 'By year'
    AND year = 2025
ORDER BY percent_of_deaths DESC; --Because opioid type categories can overlap, the percentages should not be summed as parts of a single whole.


--SECTION 7
-- Q: How have opioid hospitalizations changed over time in Canada?
--1. Annual opiod hospitalizaton number in Canada
SELECT year, numeric_value AS number_of_hospitalizations
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Hospitalizations'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
ORDER BY year;


--SECTION 8
-- Q: How have opioid emergency department visits changed over time in Canada?
-- 1. annual ED visits in canada
SELECT year, numeric_value AS number_of_ed_visits , value_status
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Emergency Department (ED) Visits'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
ORDER BY year;


-- SECTION 9
-- Q: How complete is the annual opioid EMS data for Canada?
SELECT year, numeric_value AS number_of_ems_events, value_status
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Emergency Medical Services (EMS)'
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
ORDER BY year;

-- SECTION 10
-- Q: How have the major opioid harm indicators changed over time in Canada?
SELECT year, source, numeric_value
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
      AND source IN ('Deaths',
        'Hospitalizations',
        'Emergency Department (ED) Visits',
        'Emergency Medical Services (EMS)')
      AND Specific_Measure = 'Overall numbers'
      AND Region ='Canada'
      AND Unit = 'Number'
      AND Time_Period = 'By year'
ORDER BY year, Source; 


-- SECTION 11
-- Q: How much did each opioid harm indicator change from 2017 to 2025?
SELECT Source, 
       MAX (CASE WHEN year=2017 THEN numeric_value END) AS value_2017,
       MAX (CASE WHEN year = 2025 THEN numeric_value END) AS value_2025,

    ROUND(SAFE_DIVIDE(
            MAX(CASE WHEN year = 2025 THEN numeric_value END)
            - MAX(CASE WHEN year = 2017 THEN numeric_value END),

            MAX(CASE WHEN year = 2017 THEN numeric_value END)) * 100,2) AS percent_change
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source IN (
        'Deaths',
        'Hospitalizations',
        'Emergency Department (ED) Visits',
        'Emergency Medical Services (EMS)')
    AND Specific_Measure = 'Overall numbers'
    AND Region = 'Canada'
    AND Unit = 'Number'
    AND Time_Period = 'By year'
    AND year IN (2017, 2025)
GROUP BY Source
ORDER BY percent_change DESC;

--Section 12
-- How do opioid death rates differ across provinces over time?
SELECT year, region, numeric_value AS death_rate
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Region != 'Canada'
    AND Unit = 'Crude rate'
    AND Time_Period = 'By year'
ORDER BY year, death_rate DESC;

-- SECTION 13
-- Q: How did opioid toxicity death rates change by region from 2016 to 2025?
SELECT Region,
    MAX(CASE WHEN year = 2016 THEN numeric_value END) AS rate_2016,
    MAX(CASE WHEN year = 2025 THEN numeric_value END) AS rate_2025,

    ROUND(MAX(CASE WHEN year = 2025 THEN numeric_value END)
        - MAX(CASE WHEN year = 2016 THEN numeric_value END), 1) AS rate_change

FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Unit = 'Crude rate'
    AND Time_Period = 'By year'
    AND Region != 'Canada'
    AND year IN (2016, 2025)
GROUP BY Region
ORDER BY rate_change DESC;


-- SECTION 14
-- Q: How have different opioid types changed over time?
SELECT year, Disaggregator AS opioid_type, numeric_value AS percent_of_deaths
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Type of opioids'
    AND Region = 'Canada'
    AND Unit = 'Percent'
    AND Time_Period = 'By year'
ORDER BY year, opioid_type;


-- SECTION 15
-- Q: Which age group had the highest number of opioid deaths in each year, and has the most affected age group changed over time?
--1. investigate the aggregator and disaggregator:
SELECT DISTINCT specific_measure, aggregator, disaggregator
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE substance='Opioids'
      AND Source = 'Deaths'
      AND Specific_Measure = 'Age group'
ORDER BY aggregator, disaggregator; 
--2. highest number of death
SELECT year,Disaggregator AS age_group, numeric_value AS percent_of_deaths,
       RANK() OVER(PARTITION BY year ORDER BY numeric_value DESC) AS age_rank
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Age group'
    AND Region = 'Canada'
    AND Time_Period = 'By year'
    AND Unit = 'Percent'
ORDER BY year, age_rank;


--SECTION 16
-- Joining PHAC with Statistics Canada population data

-- 1.preview the Statistics Canada population table
SELECT *
FROM `my-project-502900.substance_harms_canada.raw_population`
LIMIT 10;

-- 2.columns and data in the StatsCan population table
SELECT column_name, data_type
FROM `my-project-502900.substance_harms_canada.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'raw_population';

-- 3.population records
SELECT _REF_DATE_, GEO, UOM, SCALAR_FACTOR, VALUE, STATUS
FROM `my-project-502900.substance_harms_canada.raw_population`
WHERE _REF_DATE_ >= '2016-01'
ORDER BY _REF_DATE_, GEO
LIMIT 50;

-- 4.create a clean table for population data
CREATE OR REPLACE TABLE `my-project-502900.substance_harms_canada.clean_population` AS 
SELECT PARSE_DATE('%Y-%m', _REF_DATE_) AS start_date, GEO AS region, VALUE AS population
FROM `my-project-502900.substance_harms_canada.raw_population`
WHERE _REF_DATE_ BETWEEN '2016-01' AND '2025-12'
      AND UOM = 'Persons'
      AND SCALAR_FACTOR = 'units'; 

--5.Check whether region + start_date occurs uniquely in clean_population
SELECT start_date, region, COUNT(*) AS number_of_rows
FROM `my-project-502900.substance_harms_canada.clean_population`
GROUP BY start_date, region
HAVING COUNT (*) > 1
ORDER BY number_of_rows;      

--NOTE: WHERE filters individual rows before grouping. HAVING filters groups after GROUP BY.

--6. Join quarterly opioid death counts with population table
SELECT h.start_date, h.Region, h.numeric_value AS number_of_death, p.population
FROM `my-project-502900.substance_harms_canada.clean_harms` AS h
LEFT JOIN `my-project-502900.substance_harms_canada.clean_population` AS p ON h.start_date = p.start_date AND h.Region = p.region
WHERE h.Substance = 'Opioids'
    AND h.Source = 'Deaths'
    AND h.Specific_Measure = 'Overall numbers'
    AND h.Unit = 'Number'
    AND h.Time_Period = 'By quarter'
    AND h.Region != 'Canada'
ORDER BY h.start_date, h.Region;


--7. Calculate quarterly opioid death rate per 100,000 population
--rate per 100,000= (deaths / population) ​×100,000
SELECT h.start_date, h.Region, h.numeric_value AS number_of_deaths, p.population,

    ROUND(SAFE_DIVIDE(h.numeric_value, p.population) * 100000,2) AS calculated_rate_per_100k

FROM `my-project-502900.substance_harms_canada.clean_harms` AS h
LEFT JOIN `my-project-502900.substance_harms_canada.clean_population` AS p
    ON h.start_date = p.start_date
    AND h.Region = p.region
WHERE h.Substance = 'Opioids'
    AND h.Source = 'Deaths'
    AND h.Specific_Measure = 'Overall numbers'
    AND h.Unit = 'Number'
    AND h.Time_Period = 'By quarter'
    AND h.Region != 'Canada'
ORDER BY h.start_date, calculated_rate_per_100k DESC;


--8.Validate our calculated rates with PHAC's crude rates
WITH death_counts AS (
    SELECT start_date, Region, numeric_value AS number_of_deaths
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Number'
        AND Time_Period = 'By quarter'
        AND Region != 'Canada'),

published_rates AS (
    SELECT start_date, Region, numeric_value AS published_rate
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Crude rate'
        AND Time_Period = 'By quarter'
        AND Region != 'Canada')

SELECT d.start_date, d.Region, d.number_of_deaths, p.population,
    ROUND(SAFE_DIVIDE(d.number_of_deaths, p.population) * 100000,2) AS calculated_rate, r.published_rate

FROM death_counts AS d 
LEFT JOIN `my-project-502900.substance_harms_canada.clean_population` AS p
    ON d.start_date = p.start_date
    AND d.Region = p.region

LEFT JOIN published_rates AS r
    ON d.start_date = r.start_date
    AND d.Region = r.Region

ORDER BY d.start_date, d.Region;      


--9. Check how PHAC crude-rate records are reported
SELECT DISTINCT Time_Period, Unit, Year_Quarter
FROM `my-project-502900.substance_harms_canada.clean_harms`
WHERE Substance = 'Opioids'
    AND Source = 'Deaths'
    AND Specific_Measure = 'Overall numbers'
    AND Unit = 'Crude rate'
ORDER BY Time_Period, Year_Quarter;


--10.Compare our calculated annual rate with PHAC's published crude rate
WITH death_counts AS (
    SELECT year, Region, numeric_value AS number_of_deaths
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Number'
        AND Time_Period = 'By year'
        AND Region != 'Canada'),

published_rates AS (
    SELECT year, Region, numeric_value AS published_rate
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Crude rate'
        AND Time_Period = 'By year'
        AND Region != 'Canada'),

annual_population AS (
    SELECT EXTRACT(YEAR FROM start_date) AS year, region,
        AVG(population) AS average_population
    FROM `my-project-502900.substance_harms_canada.clean_population`
    GROUP BY year, region)

SELECT d.year, d.Region, d.number_of_deaths, p.average_population,
    ROUND(SAFE_DIVIDE(d.number_of_deaths, p.average_population) * 100000, 2) AS calculated_rate,

    r.published_rate,
    ROUND(ROUND(SAFE_DIVIDE(d.number_of_deaths, p.average_population) * 100000,2
    ) - r.published_rate, 2) AS rate_difference

FROM death_counts AS d

LEFT JOIN annual_population AS p
    ON d.year = p.year
    AND d.Region = p.region

LEFT JOIN published_rates AS r
    ON d.year = r.year
    AND d.Region = r.Region
ORDER BY d.year, d.Region;


-- SECTION 18
--1. make a table of the previous code
CREATE OR REPLACE TABLE
`my-project-502900.substance_harms_canada.analysis_opioid_deaths` AS
WITH death_counts AS (
    SELECT year, Region, numeric_value AS number_of_deaths
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Number'
        AND Time_Period = 'By year'
        AND Region != 'Canada'),

published_rates AS (
    SELECT year, Region, numeric_value AS published_rate
    FROM `my-project-502900.substance_harms_canada.clean_harms`
    WHERE Substance = 'Opioids'
        AND Source = 'Deaths'
        AND Specific_Measure = 'Overall numbers'
        AND Unit = 'Crude rate'
        AND Time_Period = 'By year'
        AND Region != 'Canada'),

annual_population AS (
    SELECT EXTRACT(YEAR FROM start_date) AS year, region,
        AVG(population) AS average_population
    FROM `my-project-502900.substance_harms_canada.clean_population`
    GROUP BY year, region)

SELECT d.year, d.Region, d.number_of_deaths, p.average_population,
    ROUND(SAFE_DIVIDE(d.number_of_deaths, p.average_population) * 100000, 2) AS calculated_rate,

    r.published_rate,
    ROUND(ROUND(SAFE_DIVIDE(d.number_of_deaths, p.average_population) * 100000,2
    ) - r.published_rate, 2) AS rate_difference

FROM death_counts AS d

LEFT JOIN annual_population AS p
    ON d.year = p.year
    AND d.Region = p.region

LEFT JOIN published_rates AS r
    ON d.year = r.year
    AND d.Region = r.Region
ORDER BY d.year, d.Region;

-- 2. check if we duplicated or lost any data after the left JOIN
SELECT
    COUNT(*) AS total_rows,
--year is an integer, while CONCAT works with strings    
    COUNT(DISTINCT CONCAT(CAST(year AS STRING), '-', Region)) AS unique_year_regions,
    COUNTIF(number_of_deaths IS NULL) AS missing_deaths,
    COUNTIF(average_population IS NULL) AS missing_population,
    COUNTIF(published_rate IS NULL) AS missing_published_rates
FROM `my-project-502900.substance_harms_canada.analysis_opioid_deaths`;

--3. saving the table
SELECT *
FROM `my-project-502900.substance_harms_canada.analysis_opioid_deaths`
ORDER BY year, Region;
