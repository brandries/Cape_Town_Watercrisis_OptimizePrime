/* Some of the things you still have to do here:

*/

SELECT * FROM population;

-- add columns to the table which add the demographic of each of the races 
ALTER TABLE population ADD COLUMN total_id VARCHAR(20);
ALTER TABLE population ADD COLUMN coloured_id VARCHAR(20);
ALTER TABLE population ADD COLUMN black_african_id VARCHAR(20);
ALTER TABLE population ADD COLUMN white_id VARCHAR(20);
ALTER TABLE population ADD COLUMN other_dem_id VARCHAR(20);
ALTER TABLE population ADD COLUMN indian_or_asian_id VARCHAR(20);
ALTER TABLE population ADD COLUMN afrikaans_id VARCHAR(20);
ALTER TABLE population ADD COLUMN isixhosa_id VARCHAR(20);
ALTER TABLE population ADD COLUMN english_id VARCHAR(20);
ALTER TABLE population ADD COLUMN other_lan_id VARCHAR(20);
ALTER TABLE population ADD COLUMN seshoto_id VARCHAR(20);
ALTER TABLE population ADD COLUMN isizulu_id VARCHAR(20);
ALTER TABLE population ADD COLUMN sign_id VARCHAR(20);
ALTER TABLE population ADD COLUMN setswana_id VARCHAR(20);
ALTER TABLE population ADD COLUMN isindebele_id VARCHAR(20);
ALTER TABLE population ADD COLUMN xitsonga_id VARCHAR(20);
ALTER TABLE population ADD COLUMN sepedi_id VARCHAR(20);
ALTER TABLE population ADD COLUMN tshivenda_id VARCHAR(20);
ALTER TABLE population ADD COLUMN "n/a_id" VARCHAR(20);
ALTER TABLE population ADD COLUMN siswati_id VARCHAR(20);

-- update the values of these columns
UPDATE population SET total_id = 'total', coloured_id = 'coloured', black_african_id = 'black_african', white_id = 'white', other_dem_id = 'other_dem', 
indian_or_asian_id = 'indian_or_asian', afrikaans_id = 'afrikaans', isixhosa_id = 'isixhosa', english_id = 'english', other_lan_id = 'other_lan', seshoto_id = 'seshoto', 
isizulu_id = 'isizulu', sign_id = 'sign', setswana_id = 'setswana', isindebele_id = 'isindebele', xitsonga_id = 'xitsonga', sepedi_id = 'sepedi', tshivenda_id = 'tshivenda',
"n/a_id" = 'n/a', siswati_id = 'siswati_id';


--Using a union, make the indivdual tables for each of races
DROP TABLE IF EXISTS new_database.population_unpivoted

SELECT 
uuid_generate_v4() as population_key, year, suburb, coloured AS "count", coloured_id as demographic
INTO new_database.population_unpivoted
FROM population
UNION ALL
SELECT uuid_generate_v4() as population_key, year, suburb, black_african, black_african_id
FROM population
UNION ALL
SELECT uuid_generate_v4() as population_key, year, suburb, white, white_id
FROM population
UNION ALL
SELECT uuid_generate_v4() as population_key, year, suburb, other_dem, other_dem_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, indian_or_asian, indian_or_asian_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, afrikaans, afrikaans_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, isixhosa, isixhosa_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, english, english_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, other_lan, other_lan_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, seshoto, seshoto_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, isizulu, isizulu_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, sign, sign_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, setswana, setswana_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, isindebele, isindebele_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, xitsonga, xitsonga_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, sepedi, sepedi_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, tshivenda, tshivenda_id
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, "n/a", "n/a_id"
FROM population
UNION ALL 
SELECT uuid_generate_v4() as population_key, year, suburb, siswati, siswati_id
FROM population;

SELECT * FROM new_database.population_unpivoted

-- make demographic table 
DROP TABLE IF EXISTS new_database.demographic

SELECT uuid_generate_v4() as demographic_key,
demographic 
INTO new_database.demographic
FROM (SELECT DISTINCT demographic FROM new_database.population_unpivoted) as subtable

ALTER TABLE new_database.demographic ADD CONSTRAINT unique_demographic_key UNIQUE(demographic_key);

SELECT * FROM new_database.demographic

-- make a combined table for the popualtion stats

SELECT PO.population_key, YR.year_key, SB.suburb_key, DM.demographic_key, PO.count
INTO new_database.population_stats
FROM new_database.population_unpivoted as PO
LEFT JOIN new_database.t_year as YR
ON PO.year = YR.t_year
LEFT JOIN new_database.suburbs as SB
ON PO.suburb = SB.suburb_pop
LEFT JOIN new_database.demographic as DM
ON PO.demographic = DM.demographic;

SELECT * FROM new_database.population_stats

ALTER TABLE new_database.population_stats ADD CONSTRAINT unique_population_key UNIQUE(population_key);

ALTER TABLE new_database.population_stats
	ADD CONSTRAINT lnk_t_year_population_stats FOREIGN KEY(year_key)
    REFERENCES new_database.t_year (year_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.population_stats
	ADD CONSTRAINT lnk_suburb_population_stats FOREIGN KEY(suburb_key)
    REFERENCES new_database.suburbs (suburb_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.population_stats
	ADD CONSTRAINT lnk_demographic_population_stats FOREIGN KEY(demographic_key)
    REFERENCES new_database.demographic (demographic_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    