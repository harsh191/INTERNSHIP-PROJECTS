-- create table crop_yield(
-- Crop varchar(255),
-- Crop_Year int,
-- Season varchar(255),
-- State varchar(255),
-- Area double,
-- Production double,
-- Annual_Rainfall double,
-- Fertilizer double,
-- Pesticide double,
-- Yield double
-- );

				-- checking for discripition of table-- 
 
desc crop_yield;

				-- checking for total number of rows  
select count(*) AS number_of_rows from crop_yield;

				-- checking for number of crops and number states
select 
	count(distinct(Crop)) As Number_of_crops, 
	count(distinct(State)) As Number_of_states
from crop_yield;


				-- data cleaning  
          
-- Adding column            

-- alter table crop_yield
-- add column Production_In_Metric_Ton double after Production,
-- add column Annual_Rainfall_In_MM double after Annual_Rainfall,
-- add column Fertilizer_In_Ton double after Fertilizer,
-- add column Pesticide_In_Ton double after Pesticide,
-- add column Yield_Per_Unit_Area float after yield;

desc crop_yield;

-- Updating values in new columns
set SQL_SAFE_UPDATES = 0;

update crop_yield
set Area_In_Hectare = area,
 Production_In_Metric_Ton = Production,
 Annual_Rainfall_In_MM =  Annual_Rainfall,
 Fertilizer_In_Ton = Fertilizer / 1000,
 Pesticide_In_Ton = Pesticide / 1000,
 Yield_Per_Unit_Area = yield;
 
 set SQL_SAFE_UPDATES = 1;
 desc crop_yield;

 select * from crop_yield;
 
				-- checking for duplicate values in table
                        
select distinct * from crop_yield;

			-- checking for basic summery of data
SELECT
  COUNT(*) AS Total_Records,
  COUNT(DISTINCT Crop) AS Crop_Varieties,
  COUNT(DISTINCT State) AS States_Covered,
  MIN(Crop_Year) AS Earliest_Year,
  MAX(Crop_Year) AS Latest_Year
FROM crop_yield;       

			-- Annual state wise yield trends
SELECT
  State,
  Crop_Year,
  AVG(Yield) AS avg_yield,
  SUM(Production) AS total_production
FROM crop_yield
GROUP BY State, Crop_Year
ORDER BY State, Crop_Year;

			-- Average rainfall vs average yield by state and season 
SELECT
  State,
  Season,
  AVG(Annual_Rainfall) AS avg_rainfall,
  AVG(Yield) AS avg_yield
FROM crop_yield
GROUP BY State, Season
ORDER BY State, Season;

			 -- Top 10 crops by average yield (national)
SELECT
  Crop,
  AVG(Yield) AS avg_yield
FROM crop_yield
GROUP BY Crop
ORDER BY avg_yield DESC
LIMIT 10;

			 -- Impact of fertilizer on yield state-wise 
SELECT
  State,
  AVG(Fertilizer) AS avg_fertilizer,
  AVG(Yield) AS avg_yield
FROM crop_yield
GROUP BY State order by avg_fertilizer;

			 -- Finding relation between pesticide usage and yield by state 
SELECT State, 
       AVG(Pesticide) AS avg_pesticide,
       AVG(Yield) AS avg_yield,
       AVG(Area) AS avg_area
FROM crop_yield
GROUP BY State
ORDER BY avg_yield DESC;

			 -- Yearly Change in Fertilizer Application and its Effect on Yield
SELECT Crop_Year, 
       AVG(Fertilizer) AS avg_fertilizer,
       AVG(Yield) AS avg_yield
FROM crop_yield
GROUP BY Crop_Year
ORDER BY Crop_Year;
		