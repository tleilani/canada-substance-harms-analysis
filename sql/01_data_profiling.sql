-- 1.Preview Data
SELECT *
FROM `my-project-502900.substance_harms_canada.raw_harms`
LIMIT 10;

-- 2.Count Rows
SELECT COUNT(*) AS total_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`;

-- 3.Unique Substances
SELECT DISTINCT Substance 
FROM `my-project-502900.substance_harms_canada.raw_harms`;

-- 4.Count Rows of Substances
SELECT Substance, COUNT(*) AS number_of_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY Substance
ORDER BY number_of_rows DESC;

-- 5.Unique Sources
SELECT DISTINCT Source
FROM `my-project-502900.substance_harms_canada.raw_harms`;

-- 6.Count Rows of Sources
SELECT Source, COUNT(*) AS number_of_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY Source
ORDER BY number_of_rows DESC;

-- 7.Count Rows by Substance and Source
SELECT Substance, Source, COUNT(*) AS number_of_rows
From `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY Substance, Source
ORDER BY Substance, number_of_rows DESC;

-- 8.Unique Specific Measures
SELECT DISTINCT Specific_measure
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Specific_Measure;

-- 9.Specific Measures by Source
SELECT Source, Specific_measure
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Source, Specific_Measure;

-- 10.Categories within each Specific Measure
SELECT DISTINCT Specific_Measure, Disaggregator
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Specific_Measure, Disaggregator;

-- 11.Unique Regions and Geografic IDs
SELECT DISTINCT region, PRUID
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Region, PRUID;

-- 12.Time Period
SELECT MIN(Year_Quarter) AS earlier_period, MAX(Year_Quarter) AS latest_period
FROM `my-project-502900.substance_harms_canada.raw_harms`;

-- 13.Unique Time Period
SELECT DISTINCT Time_Period
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Time_Period;

-- 14.Time Period and Year Quarter combination
SELECT DISTINCT Time_Period, Year_Quarter
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Time_Period, Year_Quarter;

-- 15.Check Value Data Type
SELECT DISTINCT VALUE
FROM `my-project-502900.substance_harms_canada.raw_harms`
order by value; 

-- 16.Identify non-numeric Values
SELECT Value, COUNT(*) AS number_of_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE SAFE_CAST(Value AS FLOAT64) IS NULL
GROUP BY Value
ORDER BY number_of_rows DESC;

-- 18.Suppressed Values by Source
SELECT Source, COUNT(*) AS Suppressed_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE Value = 'Suppr.'
GROUP BY Source
ORDER BY Suppressed_rows DESC;

-- 19.Suppressed Values By Region
SELECT Region, COUNT(*) AS Suppressed_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE Value = 'Suppr.'
GROUP BY Region
ORDER BY Suppressed_rows DESC;

-- 20.Suppression Rate by Region
SELECT Region, COUNT(*) AS total_rows, COUNTIF(Value ='Suppr.') AS suppressed_rows, ROUND(100 * COUNTIF(Value ='Suppr.') / COUNT(*) , 2) AS suppressed_percentage
FROM `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY Region
ORDER BY suppressed_percentage DESC; 

-- 21.N/A Rate by Source
SELECT Source, COUNT(*) AS total_rows, COUNTIF(Value ='n/a') AS na_rows, ROUND (100 * COUNTIF(Value ='n/a') / COUNT(*) , 2) AS na_percentage
FROM `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY Source
ORDER BY na_percentage DESC;

-- 22. N/A Values by Source and Specific Measures
SELECT Source, Specific_Measure, COUNT(*) AS na_rows
FROM `my-project-502900.substance_harms_canada.raw_harms`
WHERE Value = 'n/a'
GROUP BY Source, Specific_Measure
ORDER BY Source, na_rows DESC;

-- 23.Unique Units by Source
SELECT DISTINCT Source, Unit
FROM `my-project-502900.substance_harms_canada.raw_harms`
ORDER BY Source,Unit;

-- 24. NULL Check Across Important Columns
SELECT
    COUNT(*) AS total_rows,
    COUNTIF(Substance IS NULL) AS substance_nulls,
    COUNTIF(Source IS NULL) AS source_nulls,
    COUNTIF(Specific_Measure IS NULL) AS specific_measure_nulls,
    COUNTIF(Disaggregator IS NULL) AS disaggregator_nulls,
    COUNTIF(Region IS NULL) AS region_nulls,
    COUNTIF(PRUID IS NULL) AS pruid_nulls,
    COUNTIF(Time_Period IS NULL) AS time_period_nulls,
    COUNTIF(Year_Quarter IS NULL) AS year_quarter_nulls,
    COUNTIF(Unit IS NULL) AS unit_nulls,
    COUNTIF(Value IS NULL) AS value_nulls
FROM `my-project-502900.substance_harms_canada.raw_harms`;

-- 25.ChecK for Exact Duplicates in all Rows
SELECT *, COUNT(*) AS duplicate_row
FROM `my-project-502900.substance_harms_canada.raw_harms`
GROUP BY ALL
HAVING COUNT(*) > 1
ORDER BY duplicate_row DESC;
