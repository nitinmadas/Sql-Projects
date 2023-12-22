-- 2011 census data
-- DATA 1 columns: District, State, Growth, Sex_Ratio, Literacy
-- DATA 2 columns: District, State, Area_km2, Population 

SELECT * FROM data1;
SELECT * FROM data2;

-- numbers of rows in dataset
SELECT COUNT(*) FROM data1;
SELECT COUNT(*) FROM data2;
--Conclusion: 640 rows each

-- data from maharashtra and karnataka
SELECT * FROM data1
WHERE state IN ('Maharashtra','Karnataka');

-- total population of India as of 2011 census
SELECT SUM(population) AS total_population
FROM data2
-- Conclustion: 1210854977 ( ~ 1.2 billion)

-- Average growth in population of India
SELECT ROUND(AVG(growth)*100,4) AS avg_growth
FROM data1
-- Conclusion: 19.2459 %

-- Average growth in population by state
SELECT state,ROUND(AVG(growth)*100,4) AS avg_growth
FROM data1
GROUP BY 1
ORDER BY 2 DESC

-- States with minimum and maximum avg growth using CTE's
WITH cte AS (   SELECT state,ROUND(AVG(growth)*100,4) AS avg_growth
                FROM data1
                GROUP BY 1
            ),
    min_avg_growth AS ( SELECT MIN(avg_growth) FROM cte),
    max_avg_growth AS (SELECT MAX(avg_growth) FROM cte)
SELECT * FROM cte
WHERE avg_growth IN  (
                        (SELECT * FROM min_avg_growth),
                        (SELECT * FROM max_avg_growth)
                    )

-- Conclusion : Andaman And Nicobar Islands - 0.5967
--              Nagaland - 82.2809


-- Average sex ratio by state
SELECT state,ROUND(AVG(sex_ratio)) AS avg_sex_atio
FROM data1
GROUP BY 1
ORDER BY 2 DESC


-- Average literacy rate by state
SELECT state,ROUND(AVG(literacy),3) AS avg_literacy
FROM data1
GROUP BY 1
ORDER BY 2 DESC 

-- top 3 state showing highest growth ratio
SELECT state,ROUND(AVG(growth)*100,4) AS avg_growth
FROM data1
GROUP BY 1
ORDER BY 2 DESC LIMIT 3


--bottom 3 state showing lowest sex ratio
SELECT state,ROUND(AVG(sex_ratio)) AS avg_sex_ratio
FROM data1
GROUP BY 1
ORDER BY 2 LIMIT 3


-- top and bottom 3 states in literacy state
--METHOD 1: Using CTE's
WITH cte AS (   SELECT state,ROUND(AVG(literacy),3) AS avg_literacy
                FROM data1
                GROUP BY 1
            ),
    min3_avg_literacy AS ( SELECT avg_literacy FROM cte ORDER BY 1 LIMIT 3 ),
    max3_avg_literacy AS (SELECT avg_literacy FROM cte ORDER BY 1 DESC LIMIT 3)
SELECT * FROM cte
WHERE avg_literacy IN  (SELECT * FROM min3_avg_literacy)
        OR avg_literacy IN (SELECT * FROM max3_avg_literacy)
ORDER BY avg_literacy DESC

-- Method 2: Using Temp Table
DROP TABLE IF EXISTS top3state;
CREATE TABLE top3state(
    state VARCHAR(255),
    avg_literacy NUMERIC
);
INSERT INTO top3state(
    SELECT state,ROUND(AVG(literacy),3) AS avg_literacy
    FROM data1
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 3
);
DROP TABLE IF EXISTS bottom3state;
CREATE TABLE bottom3state(
    state VARCHAR(255),
    avg_literacy NUMERIC
);
INSERT INTO bottom3state(
    SELECT state,ROUND(AVG(literacy),3) AS avg_literacy
    FROM data1
    GROUP BY 1
    ORDER BY 2
    LIMIT 3
);
SELECT * FROM top3state 
UNION 
SELECT * FROM bottom3state                


-- states starting with letter a and b
SELECT DISTINCT state FROM data1
WHERE state ~* '^[ab].*'

/*  No. of Males and Females 
    sex_ratio = females * 1000 / males ( formula of sex_ratio )

    population = females + males

    Males = [ population / ((sex_ratio/ 1000) + 1) ]
    Females =  population - Males
*/
-- No. of Males and Females by district 
DROP VIEW IF EXISTS gender_count_district;
CREATE VIEW gender_count_district AS (
SELECT  d2.district, d2.state, d1.sex_ratio, d2.population, 
        ROUND( population/ ((d1.sex_ratio::numeric/ 1000) + 1)) AS males,
		population - ROUND( population/ ((d1.sex_ratio::numeric/ 1000) + 1))  AS females
FROM data2 d2 
JOIN data1 d1 
ON d2.district = d1.district 
);

SELECT * FROM gender_count_district;

-- No. of Males and Females by state using above created view
SELECT state, SUM(males), SUM(females)
FROM gender_count_district
GROUP BY 1
ORDER BY 1

-- Total Literate and Illiterat population by district
SELECT d1.district, d1.state, d1.literacy, d2.population, 
        ROUND((d1.literacy/100)*d2.population,0) AS literate_popuation,
        d2.population - ROUND((d1.literacy/100)*d2.population,0) AS illiterate_popuation
        
FROM data1 d1 
JOIN data2 d2 
ON d1.district = d2.district


-- Total Literate and Illiterat population by state using subqueries

SELECT state,SUM(literate_popuation),SUM(illiterate_popuation)
FROM (
    SELECT d1.district, d1.state, d1.literacy, d2.population, 
            ROUND((d1.literacy/100)*d2.population,0) AS literate_popuation,
            d2.population - ROUND((d1.literacy/100)*d2.population,0) AS illiterate_popuation
            
    FROM data1 d1 
    JOIN data2 d2 
    ON d1.district = d2.district
) AS sub
GROUP BY 1


-- population in previous census by district 

SELECT d1.district, d1.state, d1.growth, d2.population, 
         ROUND(d2.population/(1 + d1.growth) ) AS old_population
FROM data1 d1 
JOIN data2 d2 
ON d1.district = d2.district


-- population of India in previous census and current census
SELECT SUM(population) curr_census_pop,
        SUM(old_population) old_census_pop
FROM (
        SELECT d1.district, d1.state, d1.growth, d2.population, 
                ROUND(d2.population/(1 + d1.growth) ) AS old_population
        FROM data1 d1 
        JOIN data2 d2 
        ON d1.district = d2.district
    ) as sub 

-- population vs area_km2
WITH tot_area as ( SELECT sum(area_km2) from data2 ),
    tot_pop as (

            SELECT SUM(population) curr_census_pop,
                    SUM(old_population) old_census_pop
            FROM (
                    SELECT d1.district, d1.state, d1.growth, d2.population, 
                            ROUND(d2.population/(1 + d1.growth) ) AS old_population
                    FROM data1 d1 
                    JOIN data2 d2 
                    ON d1.district = d2.district
                ) as sub
        ),
    
    tot_curr_pop as (SELECT curr_census_pop from tot_pop),
    tot_prev_pop as (SELECT old_census_pop from tot_pop)

SELECT (SELECT * FROM tot_area)/(SELECT * FROM tot_curr_pop),
        (SELECT * FROM tot_area)/(SELECT * FROM tot_prev_pop)



-- Top 3 districts of states with highest literacy
SELECT state,literacy,rank
FROM (
        SELECT state,district, literacy, 
                RANK() OVER (PARTITION BY state ORDER BY literacy DESC) as rank
        FROM data1 
    ) as sub
WHERE rank <=3









