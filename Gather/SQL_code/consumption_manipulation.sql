/* THE TOP OF THIS SCRIPT IS DEDICATED TO STUFF THAT STILL NEED TO BE DONE.
YOU STILL HAVE TO MAKE PRIMARY KEYS FOR THESE TABLES AND POTENTIALLY ADD CONSTRAINTS

*/
-- Have a look at the data from 2013-2017

SELECT * FROM "AAWCR_CapeTown_April2013to2016_unpivoted";

SELECT * FROM "AAWCR_CapeTown_April2017_unpivoted";

--Combine two table
SELECT 
"File", "Suburb", "Value", "Units", "ReportDate", zoning_category_land_use, amount
INTO new_database.combined_water_consumption
FROM "AAWCR_CapeTown_April2013to2016_unpivoted"

UNION

SELECT 
"File", "Suburb", "Value", "Units", "ReportDate", zoning_category_land_use, amount
FROM "AAWCR_CapeTown_April2017_unpivoted";

-- Remove the brackets 
UPDATE combined_water_consumption SET "Units" = regexp_replace("Units", '[()]', '', 'g');

-- View the table
SELECT * FROM combined_water_consumption;

-- add uudis in env
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the items_measured table
DROP TABLE IF EXISTS new_database.item_measured;
SELECT 
uuid_generate_v4() as item_measured_key,  distc."Value" as item_measured
INTO new_database.item_measured
FROM (SELECT DISTINCT "Value" FROM combined_water_consumption) AS distc;

ALTER TABLE new_database.item_measured 
	ADD CONSTRAINT unique_item_measured_key UNIQUE(item_measured_key)
    ADD PRIMARY KEY (item_measured_key);

SELECT * FROM new_database.item_measured;

--Create the unit_measurement table 
DROP TABLE IF EXISTS new_database.unit_measurement;
SELECT 
uuid_generate_v4() as unit_measurement_key,  distc.units as unit_measurement
INTO new_database.unit_measurement
FROM
(SELECT DISTINCT LOWER("Units") as units FROM combined_water_consumption) AS distc;

ALTER TABLE new_database.unit_measurement 
	ADD CONSTRAINT unique_unit_measurement_key UNIQUE(unit_measurement_key)
    ADD PRIMARY KEY (unit_measurement_key);

SELECT * FROM new_database.unit_measurement;

-- Create the zoning_category_land_use table
SELECT 
uuid_generate_v4() as zoning_category_land_use_key,  distc."zoning_category_land_use" as zoning_category_land_use
INTO new_database.zoning_category_land_use
FROM
(SELECT DISTINCT "zoning_category_land_use" FROM combined_water_consumption) AS distc;

ALTER TABLE new_database.zoning_category_land_use 
	ADD CONSTRAINT unique_zoning_category_land_use_key UNIQUE(zoning_category_land_use_key)
    ADD PRIMARY KEY (zoning_category_land_use_key);

SELECT * FROM new_database.zoning_category_land_use;

-- by this point the suburbs table have had to be created

-- Make the last water stats table

DROP TABLE IF EXISTS new_database.water_statistics;

-- This will include the correct suburb_key and the correct date key

SELECT uuid_generate_v4() as water_statistics_key, 
SB.suburb_key,
IM.item_measured_key , 
UM.unit_measurement_key,
ZC.zoning_category_land_use_key,
TD.date_key,
CW.amount
INTO new_database.water_statistics
FROM combined_water_consumption as CW
LEFT JOIN new_database.suburbs as SB
ON CW."Suburb" = SB.suburb_2013 OR CW."Suburb" = SB.suburb_2017
LEFT JOIN new_database.item_measured as IM
ON CW."Value" = IM.item_measured
LEFT JOIN new_database.unit_measurement as UM
ON LOWER(CW."Units") = UM.unit_measurement
LEFT JOIN new_database.zoning_category_land_use As ZC
ON CW.zoning_category_land_use = ZC.zoning_category_land_use
LEFT JOIN new_database.new_t_date as TD
ON TD.t_date = CW."ReportDate";


-- add indices and foreign keys

--CREATE INDEX idx_suburb_key ON new_database.water_statistics USING btree(suburb_key);

CREATE INDEX idx_item_measured_key ON new_database.water_statistics USING btree(item_measured_key);

CREATE INDEX idx_unit_measurement_key ON new_database.water_statistics USING btree(unit_measurement_key);

CREATE INDEX idx_zoning_category_land_use_key ON new_database.water_statistics USING btree(zoning_category_land_use_key);

CREATE INDEX idx_date_key ON new_database.water_statistics USING btree(date_key);

ALTER TABLE new_database.water_statistics
	ADD CONSTRAINT lnk_item_measured_waterstats FOREIGN KEY(item_measured_key)
    REFERENCES new_database.item_measured (item_measured_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.water_statistics
	ADD CONSTRAINT lnk_suburbs_waterstats FOREIGN KEY(suburb_key)
    REFERENCES new_database.suburbs (suburb_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.water_statistics
	ADD CONSTRAINT lnk_unit_measurement_waterstats FOREIGN KEY(unit_measurement_key)
    REFERENCES new_database.unit_measurement (unit_measurement_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.water_statistics
	ADD CONSTRAINT lnk_zoning_waterstats FOREIGN KEY(zoning_category_land_use_key)
    REFERENCES new_database.zoning_category_land_use (zoning_category_land_use_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.water_statistics
	ADD CONSTRAINT lnk_t_date_waterstats FOREIGN KEY(date_key)
    REFERENCES new_database.new_t_date (date_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
    
    