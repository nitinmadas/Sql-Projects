/*
Covid 19 Data Exploration Using PSQL

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/ 

SELECT *
FROM coviddeaths 
WHERE continent IS NOT NULL 
ORDER BY location,date 

-- checking for date range
SELECT MIN(date),
       MAX(date)
FROM coviddeaths 
--Conclusion : Date range- 1 Jan 2020 to 30 April 2021 


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, 
                       new_cases, 
                       total_deaths, 
                       new_deaths, 
                       population
FROM coviddeaths 
WHERE continent IS NOT NULL 
ORDER BY 1,
         2 DESC 
         
--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country by day

SELECT location, date, population, 
                       total_cases AS total_cases, 
                       total_deaths AS total_deaths, 
                       (total_deaths/total_cases*100)::NUMERIC(4,2) AS death_percentage
FROM coviddeaths 
WHERE LOWER(location) LIKE '%india%' 
ORDER BY 1,
         2 
         
-- Shows likelihood of dying if you contract covid in your country by months 
SELECT location,
       population, 
       DATE_TRUNC('month',date)::DATE as month, 
       SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       ROUND((SUM(new_deaths)::NUMERIC/SUM(new_cases)*100),2) as death_percent
FROM coviddeaths 
WHERE location = 'India' 
GROUP BY 1,2,3
ORDER BY 1,3 
-- Conclusions : Highest: July 2020(3.04), Lowest: March 2021(0.52)


-- Shows percent of population infected by date

SELECT location, population, date ,total_cases, 
        round((total_cases/population) * 100,4) AS infected_Pop_percent
FROM coviddeaths 
WHERE continent IS NOT NULL 
ORDER BY 1,3 
         
-- Shows total percent of population infected 

SELECT location, 
       population, 
       MAX(total_cases) AS total_infected_count, 
       ROUND((MAX(total_cases)/population) * 100,4) AS infected_Pop_percent
FROM coviddeaths 
WHERE continent IS NOT NULL 
GROUP BY 1,2
ORDER BY 4 DESC

-- Shows list of countries whose total_cases, total_deaths data is not available'
-- METHOD 1:
WITH cte1 AS
        (SELECT location,
                COUNT(*) AS total_rows
        FROM coviddeaths
        WHERE continent IS NOT NULL
        GROUP BY 1 ),

     cte2 AS
        ( SELECT location,
                COUNT(*) AS null_rows
        FROM coviddeaths
        WHERE continent IS NOT NULL
            AND total_deaths IS NULL
            AND total_cases IS NULL
        GROUP BY 1 ),

     no_data_countries AS
        ( SELECT c1.location,
                total_rows,
                null_rows
        FROM cte1 c1
        JOIN cte2 c2 ON c1.location = c2.location
        WHERE total_rows = null_rows )
SELECT location
FROM no_data_countries
ORDER BY 1 

-- METHOD 2:
SELECT location
FROM (
        SELECT location,
                SUM(total_cases) AS tc,
                SUM(total_deaths) AS td
        FROM coviddeaths
        GROUP BY 1
        HAVING SUM(total_cases) IS NULL
        AND SUM(total_deaths) IS NULL 

    ) AS sub
ORDER BY 1 

--Conclusion: There are 20 such countries

-- Countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS total_death_count, 
        ROUND((MAX(total_deaths)::NUMERIC / population) * 100,4) AS DiedPercent
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY 3 DESC




-- Breaking THINGS BY CONTINENT
-- Shows continents with highest death count per population
-- METHOD 1:
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE location IN ( SELECT DISTINCT continent FROM coviddeaths)
GROUP BY 1
ORDER BY 2  

-- METHOD 2:
SELECT continent,
        SUM(total_deaths) AS total_death_count
FROM ( 
        SELECT continent,
                location,
                MAX(total_deaths) AS total_deaths  
        FROM coviddeaths 
        GROUP BY 1,2
    ) AS sub

WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2


--GLOBAL NUMBERS
-- Shows overall death percentage till date globally
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
        SUM(new_deaths)::NUMERIC/ SUM(new_cases) * 100 AS global_death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL


-----------------------------------------------------------------------------------------------
SELECT * FROM covidvaccination

SELECT cv.location,cv.date,cd.population,cv.new_vaccinations
FROM covidvaccinations cv
JOIN coviddeaths cd
ON cd.location = cv.location
	AND cd.date = cv.date AND cd.location = 'Canada'
WHERE cd.continent IS NOT NULL 
ORDER BY 1,2

-- Total Population vs Vaccinations

--Rolling sum of new vaccinations

SELECT  cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.date) AS rolling_people_vaccinated
FROM covidvaccinations AS cv
JOIN coviddeaths AS cd
ON cv.location = cd.location 
    AND cv.date = cd.date 
    AND cd.continent IS NOT NULL


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

-- METHOD 1 : Using CTE
WITH pop_vs_vac AS (
    SELECT  cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.date) AS rolling_people_vaccinated
    FROM covidvaccinations AS cv
    JOIN coviddeaths AS cd
    ON cv.location = cd.location 
        AND cv.date = cd.date 
        AND cd.continent IS NOT NULL
)
SELECT *, rolling_people_vaccinated / population * 100 AS percent_pop_vaccinated
FROM pop_vs_vac



--METHOD 2: Using Temp Tables
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TEMP TABLE percent_population_vaccinated
(
	Continent varchar(255),
	Location varchar(255),
	Date date,
	Population numeric,
	New_vaccinations numeric,
	rolling_people_vaccinated numeric
);

INSERT INTO percent_population_vaccinated (
SELECT  cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.date) AS rolling_people_vaccinated
FROM covidvaccinations AS cv
JOIN coviddeaths AS cd
ON cv.location = cd.location 
	AND cv.date = cd.date 
	AND cd.continent IS NOT NULL
);	
SELECT *, rolling_people_vaccinated / population * 100 AS percent_pop_vaccinated
FROM percent_population_vaccinated


--METHOD 3: Using VIEWS
CREATE VIEW percent_population_vaccinateds AS  (SELECT  cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (PARTITION BY cv.location ORDER BY cv.date) AS rolling_people_vaccinated
    FROM covidvaccinations AS cv
    JOIN coviddeaths AS cd
    ON cv.location = cd.location 
        AND cv.date = cd.date 
        AND cd.continent IS NOT NULL)

SELECT *, rolling_people_vaccinated / population * 100 AS percent_pop_vaccinated
FROM percent_population_vaccinateds