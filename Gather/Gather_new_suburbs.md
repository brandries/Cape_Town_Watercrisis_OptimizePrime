# Next we create a new suburbs table


Join the three tables into one with full outer joins, after which you manipulate them in google sheets

--make the temp suburb tables
```
SELECT DISTINCT "File", "Suburb"
INTO new_database.temp_2013_2016_suburb
FROM "AAWCR_CapeTown_April2013to2016_unpivoted";

SELECT DISTINCT "File", "Suburb"
INTO new_database.temp_2017_suburb
FROM "AAWCR_CapeTown_April2017_unpivoted";

SELECT DISTINCT area, suburb
INTO new_database.temp_population_suburb
FROM population;
```
-- these entries are good
```SELECT pop.area, pop.suburb, con.area2013, con.suburb2013, con.suburb2017
INTO new_database.complete_suburbs
FROM new_database.temp_population_suburb as pop
FULL OUTER JOIN
(SELECT old."File" as area2013, old."Suburb" as suburb2013, new."Suburb" as suburb2017
FROM new_database.temp_2013_2016_suburb AS old
FULL OUTER JOIN new_database.temp_2017_suburb AS new
ON LOWER(old."Suburb") = LOWER(new."Suburb")) as con
ON LOWER(pop.suburb) = LOWER(con.suburb2017)
WHERE pop.suburb IS NOT NULL AND con.area2013 IS NOT NULL AND con.suburb2017 IS NOT NULL;
```
-- these entries were manually fixed in google sheets
```SELECT pop.area, pop.suburb, con.area2013, con.suburb2013, con.suburb2017
INTO new_database.incomplete_suburbs
FROM new_database.temp_population_suburb as pop
FULL OUTER JOIN
(SELECT old."File" as area2013, old."Suburb" as suburb2013, new."Suburb" as suburb2017
FROM new_database.temp_2013_2016_suburb AS old
FULL OUTER JOIN new_database.temp_2017_suburb AS new
ON LOWER(old."Suburb") = LOWER(new."Suburb")) as con
ON LOWER(pop.suburb) = LOWER(con.suburb2017)
WHERE pop.suburb IS NULL OR con.area2013 IS NULL OR con.suburb2017 IS NULL;
```
-- Export the tables to csv

```COPY new_database.complete_suburbs TO 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels' DELIMITER ',' CSV HEADER;

COPY new_database.incomplete_suburbs TO 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS new_database.complete_suburbs;
DROP TABLE IF EXISTS new_database.incomplete_suburbs;
```
-- manually edit the sheets in google sheet, and join the table to those who had entries in all three datasets, and the four suburbs from the rain table

-- Make the temporary new suburb table containing suburbs from all three tables
```DROP TABLE IF EXISTS new_database.new_suburbs;


CREATE TABLE new_database.new_suburbs(
    main_area VARCHAR(200), 
    main_suburb VARCHAR(200) NOT NULL UNIQUE,
    area_pop  VARCHAR(200), 
    suburb_pop  VARCHAR(200), 
    area_2013 VARCHAR(200), 
    suburb_2013  VARCHAR(200), 
    suburb_2017 VARCHAR(200), 
    region_rain VARCHAR(200)

);


SELECT * FROM new_database.new_suburbs;
```
--Copy the data into the table 
```
COPY new_database.new_suburbs FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\suburbs_organized_with_rain_population_consumption - final_incomplete_suburbs.tsv' DELIMITER E'\t';

DROP TABLE IF EXISTS new_database.suburbs;

SELECT 
uuid_generate_v4() AS suburb_key, main_suburb, main_area, area_pop, suburb_pop, area_2013, suburb_2013, suburb_2017, region_rain
INTO new_database.suburbs
FROM new_database.new_suburbs;

ALTER TABLE new_database.suburbs 
	ADD CONSTRAINT unique_suburbs_key UNIQUE(suburb_key),
    ADD CONSTRAINT unique_suburbs UNIQUE(main_suburb),
    ADD PRIMARY KEY(suburb_key);

CREATE INDEX idx_suburb_key ON new_database.suburbs USING btree(suburb_key);


SELECT * FROM new_database.suburbs;
```
-- lastly remove the temp suburb table
```DROP TABLE IF EXISTS new_database.new_suburbs;
DROP TABLE IF EXISTS new_database.temp_2013_2016_suburb;
DROP TABLE IF EXISTS new_database.temp_2017_suburb;
DROP TABLE IF EXISTS new_database.temp_population_suburb;
```
-- DO NOT PERFORM THE FOLLOWING CODE UNTIL THE POPULATION AND CONSUMPTION TABLES HAVE BEEN CREATED
-- THIS SECTION IS PUT IN PLACE TO CHECK THAT THE MANUAL WORK TO EDIT THE SUBURB TABLE WAS DONE CORRECTLY
-- We found that we lost some of the suburbs when joining the tables. This is the code to identify those suburbs
```SELECT * 
INTO new_database.combined_water_consumption
FROM "AAWCR_CapeTown_April2013to2016_unpivoted"
UNION ALL
SELECT * 
FROM "AAWCR_CapeTown_April2017_unpivoted";

SELECT DISTINCT
CW."Suburb"

FROM new_database.combined_water_consumption as CW
LEFT JOIN new_database.suburbs as SB
ON CW."Suburb" = SB.suburb_2013 OR CW."Suburb" = SB.suburb_2017 OR  CW."Suburb" = SB.main_suburb
LEFT JOIN new_database.item_measured as IM
ON CW."Value" = IM.item_measured
LEFT JOIN new_database.unit_measurement as UM
ON LOWER(CW."Units") = UM.unit_measurement
LEFT JOIN new_database.zoning_category_land_use As ZC
ON CW.zoning_category_land_use = ZC.zoning_category_land_use
LEFT JOIN new_database.t_date as TD
ON TD.t_date = CW."ReportDate"
WHERE suburb_key IS NULL;
```
-- After this, the manually change the ones that are not right
-- Changed racing park, sabata, sir lowrys pass, stellendale, total (adding a space), unknown, vredenzight, adding a ',' to waterkloof

-- do the same as above for the populaoitn table and only find zeekoei vlei
```
SELECT PO.population_key, YR.year_key, SB.suburb_key, DM.demographic_key, PO.count, SB.main_suburb, PO.suburb
FROM new_database.population_unpivoted as PO
LEFT JOIN new_database.t_year as YR
ON PO.year = YR.t_year
LEFT JOIN new_database.suburbs as SB
ON PO.suburb = SB.suburb_pop
LEFT JOIN new_database.demographic as DM
ON PO.demographic = DM.demographic
WHERE suburb_key IS NULL;

```

