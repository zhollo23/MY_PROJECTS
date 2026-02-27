--Create the database
CREATE DATABASE CovidDB;
GO

--Evaluate the table before any changes are made
USE CovidDB;

SELECT * FROM Covid_nums
ORDER BY country; --desc;



--PHASE 1: Data Cleaning

--Remove Leading/Trailing Spaces
UPDATE Covid_nums
SET country = LTRIM(RTRIM(country)),
continent = LTRIM(RTRIM(continent));

--DELETE the row where continent = 'All'
DELETE FROM Covid_nums
where continent = 'All';


--Replace Abbreviated Countries with their full name

--First we must see which ones are abbreviated. Let's narrow it down
SELECT DISTINCT country, continent
FROM Covid_nums
WHERE LEN(country)<=6;

--CAR (Africa), DRC (Africa), UAE (Asia), UK (Europe), 
--USA (North-America), and DPRK (Korea) are the abbreviated countries.
--Let's make the proper changes.
UPDATE Covid_nums
SET country = 
   REPLACE( 
   REPLACE(
   REPLACE(
   REPLACE(
   REPLACE(
   REPLACE(country, 'USA', 'United States'),
   'UK', 'United Kingdom'),
   'UAE', 'United Arab Emirates'),
   'DRC', 'Democratic Republic of Congo'),
   'CAR', 'Central African Republic'), 
   'DPRK', 'North Korea');




--Total cases by continent
SELECT continent, SUM(total_cases) AS cases
FROM Covid_nums
GROUP BY continent
ORDER BY cases DESC;

--PHASE 2: Mkae appropriate changes to the Covid_nums table

--Add a column that ranks cases by country
--1
ALTER TABLE Covid_nums
ADD case_rank INT;
--2
UPDATE Covid_nums
SET case_rank = t.total_case_rank
FROM(
    SELECT country, total_cases, 
    Rank() OVER (ORDER BY total_cases DESC) AS total_case_rank
    FROM Covid_nums
) AS t
WHERE Covid_nums.country = t.country


--Add as Risk  catrgory column

ALTER TABLE Covid_nums
ADD Risk_category VARCHAR(20);

--Enter the values for the Risk category column
UPDATE Covid_nums
SET Risk_category = CASE 
    WHEN total_cases > 1000000 THEN 'High'
    WHEN total_cases > 100000 THEN 'Medium'
    ELSE 'Low'
END;


-- Turn both rate columns into whole numbers


UPDATE Covid_nums
    SET 
        case_fatality_rate = ROUND(total_deaths/total_cases, 2),
        active_case_rate = ROUND(active_cases/total_cases, 2);

UPDATE Covid_nums
    SET 
        case_fatality_rate = ROUND(case_fatality_rate * 100, 0),
        active_case_rate = ROUND(active_case_rate * 100, 0);

