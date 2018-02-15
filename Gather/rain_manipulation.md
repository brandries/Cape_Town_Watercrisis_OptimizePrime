-- Insert a column with a uuid and populate with uuids
```
ALTER TABLE rain
ADD rain_key uuid;

UPDATE rain
SET  rain_key = uuid_generate_v4()
WHERE rain_key IS NULL;
```
-- check for complete data
```SELECT *
FROM rain
WHERE rain_key IS NULL;
```

-- Make a unique table with only the regions shown here
-- I think you can try to link this using the suburbs table
```SELECT DISTINCT region
INTO new_database.region_name
FROM rain;

ALTER TABLE new_database.region_name
ADD region_key uuid;

SELECT *
FROM new_database.region_name;

UPDATE new_database.region_name
SET region_key = uuid_generate_v4()
WHERE region_key is null;

SELECT *
FROM new_database.region_name;

ALTER TABLE new_database.region_name
	ADD PRIMARY KEY (region_key);

SELECT *
FROM new_database.region_name;
```
-- Add the unique keys 
```
ALTER TABLE new_database.region_name ADD CONSTRAINT unique_region_key UNIQUE(region_key);

DROP TABLE IF EXISTS new_database.rain_stats;

SELECT RA.rain_key, RN.region_key, TD.date_key, RA.rain, RA.temp, RA.wind_speed
INTO new_database.rain_stats
FROM rain as RA
LEFT JOIN new_database.t_date as TD
ON RA.date = TD.t_date
LEFT JOIN new_database.region_name as RN
ON RA.region = RN.region;

SELECT * 
FROM new_database.rain_stats;
```
-- Add the foreign keys
```
ALTER TABLE new_database.rain_stats
	ADD CONSTRAINT lnk_regions_rainstats FOREIGN KEY(region_key)
    REFERENCES new_database.region_name (region_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade; 
    

ALTER TABLE new_database.rain_stats
	ADD CONSTRAINT lnk_t_date_rainstats FOREIGN KEY(date_key)
    REFERENCES new_database.t_date (date_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade; 

ALTER TABLE new_database.rain_stats
	ADD PRIMARY KEY (rain_key);
	```
