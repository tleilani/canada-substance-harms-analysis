-- 1.Figuring out value status
SELECT Value, SAFE_CAST(Value as FLOAT64) AS numeric_value,
      CASE
          WHEN Value = 'Suppr.' THEN 'Suppressed'
          WHEN Value = 'n/a'THEN 'not_available'
          ELSE 'Available'
      END AS value_status
FROM `my-project-502900.substance_harms_canada.raw_harms`;        

-- 2.Validate all three statuses
SELECT value, SAFE_CAST(Value AS FLOAT64) AS numeric_value,
      CASE
          WHEN value = 'Suppr.' THEN 'Suppressed'
          WHEN value = 'n/a' THEN 'not_available'
          ELSE 'Available'
      END AS value_status,
      COUNT(*) AS number_of_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`    
GROUP BY value, numeric_value, value_status
ORDER BY number_of_rows DESC;

-- 3.Time period cleaning
SELECT time_period , year_quarter, CAST(SUBSTR(year_quarter, 1, 4) AS INT64) AS year,

    CASE
        WHEN time_period = 'By quarter' THEN CAST(SUBSTR(year_quarter, 7, 1)   AS INT64) 
        ELSE Null
    END AS quarter
FROM `my-project-502900.substance_harms_canada.raw_harms`; 

-- 4. Generating date for the beginning of each quarter and year
WITH time AS (SELECT time_period , year_quarter , CAST (SUBSTR(year_quarter, 1, 4) AS INT64) AS year,
        CASE 
            WHEN time_period= "By quarter"
            THEN CAST(SUBSTR(year_quarter, 7,1) AS INT64) 
            ELSE NULL
        END AS quarter
FROM `my-project-502900.substance_harms_canada.raw_harms`)

SELECT time_period, year_quarter, year, quarter,  
      CASE 
          WHEN time_period = "By year" THEN  DATE(year,1,1)
          WHEN time_period = "By quarter" THEN DATE(year, (quarter-1)*3+1 , 1)
      END AS start_date
FROM time
ORDER BY quarter , year 

-- 5. Null disaggregator
SELECT source, specific_measure, COUNT(*) AS null_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE disaggregator IS NULL
GROUP BY source, Specific_Measure
ORDER BY null_rows DESC;

SELECT *
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE Disaggregator IS NULL
ORDER BY Source, Specific_Measure, Year_Quarter;

-- 6. Check the difference of aggregator and disaggregator
SELECT DISTINCT
    Aggregator,
    Specific_Measure,
    Disaggregator
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Aggregator, Specific_Measure, Disaggregator;

-- 7. aggregator and disaggregator Nulls 
SELECT 
      COUNT(*) AS total_rows,
      COUNTIF (aggregator IS NULL) AS aggregator_nulls,
      COUNTIF (disaggregator IS NULL) AS disaggregator_null,
      COUNTIF (aggregator IS NULL AND disaggregator IS NULL) AS both_null
FROM `my-project-502900.substance_harms_canada.raw_harms`;
-- What we undrestand from the results is Aggregator and Disaggregator NULLs occur together.


-- 8.create a table of the cleaned data
CREATE OR REPLACE TABLE `my-project-502900.substance_harms_canada.clean_harms` AS
WITH cleaned AS (
    SELECT*,
        -- Convert strings to numbers
        SAFE_CAST(Value AS FLOAT64) AS numeric_value,
        
        CASE
            WHEN Value = 'Suppr.' THEN 'Suppressed'
            WHEN Value = 'n/a' THEN 'not_available'
            ELSE 'Available'
        END AS value_status,

        -- Extract year
        CAST(SUBSTR(Year_Quarter, 1, 4) AS INT64) AS year,
        -- Extract quarter
        CASE
            WHEN Time_Period = 'By quarter'
            THEN CAST(SUBSTR(Year_Quarter, 7, 1) AS INT64)
            ELSE NULL
        END AS quarter
    FROM `my-project-502900.substance_harms_canada.raw_harms`)

SELECT *,
    CASE
        WHEN Time_Period = 'By year' THEN DATE(year, 1, 1)
        WHEN Time_Period = 'By quarter' THEN DATE(year, (quarter - 1) * 3 + 1, 1)
    END AS start_date
FROM cleaned;        

-- 9. Validate the cleaned table
SELECT
    COUNT(*) AS total_rows,
    COUNT(numeric_value) AS numeric_values,
    COUNTIF(value_status = 'Suppressed') AS suppressed_values,
    COUNTIF(value_status = 'not_available') AS unavailable_values,
    COUNTIF(year IS NULL) AS missing_year,
    COUNTIF(start_date IS NULL) AS missing_start_date
FROM `my-project-502900.substance_harms_canada.clean_harms`;
