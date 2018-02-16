-- CREATE VIEWS THAT REPRESENT THE UNDERLYING DATA IN THE CAPE TOWN WATER CRISIS DATABASE

-- RAINFALL
CREATE VIEW new_database.rain_view_per_area_yearly AS
SELECT rn.region, tm.t_year, ROUND(AVG(rs."temp"), 3) AS temperature, ROUND(SUM(rs.rain), 3) AS rain, ROUND(AVG(rs.wind_speed), 3) AS wind_speed
FROM new_database.rain_stats AS rs
LEFT JOIN new_database.region_name AS rn
ON rs.region_key = rn.region_key
LEFT JOIN new_database.t_date as td
ON rs.date_key = td.date_key
LEFT JOIN new_database.t_month as tm
ON td.month_key = tm.month_key
GROUP BY  region, t_year
ORDER BY region,  t_year;

-- monthly rainfall
CREATE VIEW new_database.rain_view_per_area_monthly AS
SELECT  reg.region, Round(SUM(rain.rain), 3) as rain ,ROUND(AVG(rain.wind_speed), 3) AS wind_speed, ROUND(AVG(RAIN.TEMP), 3) as temp, month.t_month, t_year
FROM new_database.rain_stats as rain
LEFT JOIN new_database.region_name AS reg
ON reg.region_key = rain.region_key
LEFT JOIN new_database.t_date AS date
ON date.date_key = rain.date_key
LEFT JOIN NEW_DATABASE.t_month AS month
ON date.month_key = month.month_key
GROUP BY t_month, t_year, region
ORDER BY REGION, t_year, t_month;

-- rainfall
CREATE VIEW new_database.rain_view_per_area AS
SELECT rain.rain_key, reg.region, month.t_month, month.t_year, date.t_date, rain.rain, rain.wind_speed, rain."temp"
FROM new_database.rain_stats as rain
LEFT JOIN new_database.region_name AS reg
ON reg.region_key = rain.region_key
LEFT JOIN new_database.t_date AS date
ON date.date_key = rain.date_key
LEFT JOIN NEW_DATABASE.t_month AS month
ON date.month_key = month.month_key;

-- DAM LEVELS

CREATE VIEW new_database.view_damlevels as 
SELECT
DS.dam_stats_key,
DT.t_date,
MM.month_year,
MM.t_month,
MM.t_year,
DN.name as dam_name,
DC.class as dam_class,
DN.dam_capacity_ml as max_dam_capacity_ml,
DS.height_m,
DS.storage_ml,

	CASE WHEN DN.dam_capacity_ml is null or dn.dam_capacity_ml <= 0 then 0
		ELSE round( cast(DS.storage_ml / DN.dam_capacity_ml * 100 as numeric) ,2 ) end as percentage_capacity
FROM new_database.dam_stats as DS
LEFT JOIN new_database.t_date as DT on DT.date_key = DS.date_key
LEFT JOIN new_database.t_month as MM on MM.month_key = DT.month_key
LEFT JOIN new_database.dam_name as DN on DN.dam_name_key = DS.dam_name_key
LEFT JOIN new_database.dam_class as DC on DC.dam_class_key = DN.dam_class_key ;




--CONSUMPTION

CREATE VIEW new_database.view_consumption_total as 
SELECT  ws.water_statistics_key, sb.main_suburb, item_measured, unit_measurement, zoning_category_land_use, ty.t_year, ws.amount
FROM new_database.water_statistics AS ws
LEFT JOIN new_database.suburbs AS sb
ON ws.suburb_key = sb.suburb_key
LEFT JOIN new_database.t_date AS td
ON ws.date_key = td.date_key
LEFT JOIN new_database.item_measured AS im
ON ws.item_measured_key = im.item_measured_key
LEFT JOIN new_database.unit_measurement as um
ON ws.unit_measurement_key = um.unit_measurement_key
LEFT JOIN new_database.zoning_category_land_use as zn
ON ws.zoning_category_land_use_key = zn.zoning_category_land_use_key
LEFT JOIN new_database.t_year as ty
ON td.year_key = ty.year_key;

-- create a consumption view with only measured water usage with all the zones
CREATE VIEW new_database.view_consumption_metered as 
SELECT  ws.water_statistics_key, sb.main_suburb, item_measured, unit_measurement, zoning_category_land_use, ty.t_year, ws.amount
FROM new_database.water_statistics AS ws
LEFT JOIN new_database.suburbs AS sb
ON ws.suburb_key = sb.suburb_key
LEFT JOIN new_database.t_date AS td
ON ws.date_key = td.date_key
LEFT JOIN new_database.item_measured AS im
ON ws.item_measured_key = im.item_measured_key
LEFT JOIN new_database.unit_measurement as um
ON ws.unit_measurement_key = um.unit_measurement_key
LEFT JOIN new_database.zoning_category_land_use as zn
ON ws.zoning_category_land_use_key = zn.zoning_category_land_use_key
LEFT JOIN new_database.t_year as ty
ON td.year_key = ty.year_key
WHERE   zoning_category_land_use LIKE 'TOTAL_I%' AND unit_measurement LIKE 'kl/day' AND (item_measured LIKE 'AADD (M%' OR item_measured LIKE 'AADD');



-- POPULATION
CREATE VIEW new_database.total_population AS
SELECT pt.population_key, ty.t_year, dt.demographic, sb.main_suburb, sb.main_area, count
FROM new_database.population_total as pt
LEFT JOIN new_database.demographic_total as dt
ON pt.demographic_key = dt.demographic_key
LEFT JOIN new_database.suburbs as sb
ON pt.suburb_key = sb.suburb_key
LEFT JOIN new_database.t_year as ty
ON pt.year_key = ty.year_key;

-- a view of the population accross years
CREATE VIEW new_database.total_population_suburbs_years AS
SELECT sb.main_area, SUM(p1.count) as Count_2011, SUM(p2.count) as Count_2012, SUM(p3.count) as Count_2013, SUM(p4.count) as Count_2014, 
SUM(p5.count) as Count_2015, SUM(p6.count) as Count_2016, SUM(p7.count) as Count_2017
FROM new_database.suburbs as sb
Right JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2011) as p1
ON sb.suburb_key = p1.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2012) as p2
ON sb.suburb_key = p2.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2013) as p3
ON sb.suburb_key = p3.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2014) as p4
ON sb.suburb_key = p4.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2015) as p5
ON sb.suburb_key = p5.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2016) as p6
ON sb.suburb_key = p6.suburb_key

LEFT JOIN (SELECT p1.count, t_year, ty.year_key, p1.suburb_key
FROM new_database.population_total as p1
LEFT JOIN new_database.t_year as ty
ON p1.year_key = ty.year_key
WHERE t_year = 2017) as p7
ON sb.suburb_key = p7.suburb_key
GROUP BY main_area;

-- SUPPLY - DAM LEVELS AND RAINFALL
CREATE VIEW new_database.supply_view AS

SELECT ROUND(AVG(rs."temp"), 3) AS temperature, ROUND(AVG(rs.rain), 3) AS rain, ROUND(AVG(rs.wind_speed), 3) AS wind_speed,  
	ROUND(SUM(CAST (ds.storage_ml AS NUMERIC))/ SUM(CAST(dn.dam_capacity_ml AS NUMERIC))*100, 3) AS dam_persentages, tm.month_year    
FROM new_database.rain_stats AS rs
LEFT JOIN new_database.region_name AS rn
ON rs.region_key = rn.region_key
LEFT JOIN new_database.t_date as td
ON rs.date_key = td.date_key
LEFT JOIN new_database.t_month as tm
ON td.month_key = tm.month_key
LEFT JOIN new_database.dam_stats ds
ON rs.date_key = ds.date_key
LEFT JOIN new_database.dam_name as dn 
ON ds.dam_name_key = dn.dam_name_key
GROUP BY  tm.month_key
ORDER BY t_year, t_month;


-- DEMAND - CONSUMPTION AND POPULATION
CREATE VIEW new_database.demand_view AS
SELECT ty.t_year, ws.sum_consump, pop.sum_pop 
FROM (SELECT   ws.year_key, SUM(ws.amount) as sum_consump
FROM new_database.water_statistics AS ws
LEFT JOIN new_database.item_measured AS im
ON ws.item_measured_key = im.item_measured_key
LEFT JOIN new_database.unit_measurement as um
ON ws.unit_measurement_key = um.unit_measurement_key
LEFT JOIN new_database.zoning_category_land_use as zn
ON ws.zoning_category_land_use_key = zn.zoning_category_land_use_key
WHERE   zoning_category_land_use LIKE 'TOTAL_I%' AND unit_measurement LIKE 'kl/day' AND (item_measured LIKE 'AADD (M%' OR item_measured LIKE 'AADD')
GROUP BY year_key) as ws
LEFT JOIN 
(SELECT year_key, SUM(count) as sum_pop
FROM new_database.population_total
GROUP BY year_key) as pop
ON ws.year_key = pop.year_key 
LEFT JOIN new_database.t_year as ty
ON ws.year_key = ty.year_key
 
ORDER BY t_year ;

-- DAM LEVELS AND POPULATION
CREATE VIEW new_database.dam_population_view AS
SELECT t.t_year, temp.average_height, temp.average_storage, temp.percent_dam, pt.total_population
FROM ( SELECT ty.year_key, round(avg(ds.height_m)::numeric, 2) AS average_height, round(avg(ds.storage_ml)::numeric, 2) AS average_storage, 
      ROUND(SUM(CAST (ds.storage_ml AS NUMERIC))/ SUM(CAST(dn.dam_capacity_ml AS NUMERIC))*100, 3) as percent_dam
  	FROM new_database.dam_stats ds
       LEFT JOIN new_database.dam_name as dn ON ds.dam_name_key = dn.dam_name_key
       LEFT JOIN new_database.t_date nd ON ds.date_key = nd.date_key
       LEFT JOIN new_database.t_year ty ON nd.year_key = ty.year_key
   	   GROUP BY ty.year_key)  AS temp
LEFT JOIN ( SELECT population_total.year_key, sum(population_total.count) AS total_population
    FROM new_database.population_total
        GROUP BY population_total.year_key) pt ON temp.year_key = pt.year_key
        LEFT JOIN new_database.t_year t ON temp.year_key = t.year_key
        ORDER BY t.t_year;

--SUPPLY AND DEMAND

CREATE VIEW new_database.supply_and_demand AS
SELECT ty.t_year, ws.sum_consump, pop.sum_pop, rain.rain, rain.wind_speed, rain.temp, ROUND(CAST(dam.storage AS NUMERIC)/CAST (dam.capacity AS NUMERIC) * 100, 3) as average_dam
FROM 

(SELECT   ws.year_key, SUM(ws.amount) as sum_consump
FROM new_database.water_statistics AS ws
LEFT JOIN new_database.item_measured AS im
ON ws.item_measured_key = im.item_measured_key
LEFT JOIN new_database.unit_measurement as um
ON ws.unit_measurement_key = um.unit_measurement_key
LEFT JOIN new_database.zoning_category_land_use as zn
ON ws.zoning_category_land_use_key = zn.zoning_category_land_use_key
WHERE   zoning_category_land_use LIKE 'TOTAL_I%' AND unit_measurement LIKE 'kl/day' AND (item_measured LIKE 'AADD (M%' OR item_measured LIKE 'AADD')
GROUP BY year_key) as ws

 LEFT JOIN 
(SELECT year_key, SUM(count) as sum_pop
FROM new_database.population_total
GROUP BY year_key) as pop
ON ws.year_key = pop.year_key 

LEFT JOIN
(SELECT Round(AVG(rain.rain), 3) as rain ,ROUND(AVG(rain.wind_speed), 3) AS wind_speed, ROUND(AVG(RAIN.TEMP), 3) as temp, YEAR.year_key
FROM new_database.rain_stats as rain
LEFT JOIN new_database.region_name AS reg
ON reg.region_key = rain.region_key
LEFT JOIN new_database.t_date AS date
ON date.date_key = rain.date_key
LEFT JOIN NEW_DATABASE.T_YEAR AS YEAR
ON date.year_key = year.year_key
GROUP BY year.year_key) as rain
ON rain.year_key = pop.year_key

LEFT JOIN
(SELECT ty.year_key, SUM(dn.dam_capacity_ml) as capacity, SUM(ds.storage_ml) as storage
FROM new_database.dam_stats ds
LEFT JOIN new_database.dam_name as dn 
ON ds.dam_name_key = dn.dam_name_key
LEFT JOIN new_database.t_date as td
ON ds.date_key = td.date_key
LEFT JOIN new_database.t_year as ty
ON td.year_key = ty.year_key
GROUP BY ty.year_key) as dam
ON dam.year_key = ws.year_key



LEFT JOIN new_database.t_year as ty
ON ws.year_key = ty.year_key
 
ORDER BY t_year ;
