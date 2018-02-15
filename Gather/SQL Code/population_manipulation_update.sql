
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
ALTER TABLE population ADD COLUMN male_id VARCHAR(20);
ALTER TABLE population ADD COLUMN female_id VARCHAR(20);

-- Add unique UUids to the population table
ALTER TABLE population ADD COLUMN population_key UUid;

-- update the values of these columns
UPDATE population SET total_id = 'total', coloured_id = 'coloured', black_african_id = 'black_african', white_id = 'white', other_dem_id = 'other_dem', 
indian_or_asian_id = 'indian_or_asian', afrikaans_id = 'afrikaans', isixhosa_id = 'isixhosa', english_id = 'english', other_lan_id = 'other_lan', seshoto_id = 'seshoto', 
isizulu_id = 'isizulu', sign_id = 'sign', setswana_id = 'setswana', isindebele_id = 'isindebele', xitsonga_id = 'xitsonga', sepedi_id = 'sepedi', tshivenda_id = 'tshivenda',
"n/a_id" = 'n/a', siswati_id = 'siswati_id', male_id = 'male', female_id = 'female', population_key = uuid_generate_v4();

SELECT * FROM population

--Using a union, make the indivdual tables for each of total, ethnic groups, genders, and languages
--total
DROP TABLE IF EXISTS new_database.population_total;
SELECT 
population_key, ty.year_key, sb.suburb_key, total AS "count", total_id as demographic
INTO new_database.population_total
FROM population as pop
LEFT JOIN new_database.t_year as ty
ON pop."year" = ty.t_year
LEFT JOIN new_database.suburbs as sb
ON pop.suburb = sb.suburb_pop;

SELECT * FROM new_database.population_total;

ALTER TABLE new_database.population_total ADD CONSTRAINT unique_population_total_key UNIQUE(population_key);

-- make demographic table total
DROP TABLE IF EXISTS new_database.demographic_total;

SELECT uuid_generate_v4() as demographic_key,
demographic 
INTO new_database.demographic_total
FROM (SELECT DISTINCT demographic FROM new_database.population_total) as subtable;

ALTER TABLE new_database.demographic_total 
	ADD CONSTRAINT unique_demographic_total_key UNIQUE(demographic_key),
    ADD PRIMARY KEY (demographic_key);

SELECT * FROM new_database.demographic_total;

ALTER TABLE new_database.population_total DROP COLUMN demographic;
ALTER TABLE new_database.population_total ADD COLUMN demographic_key UUid;

UPDATE new_database.population_total SET demographic_key = dt.demographic_key
FROM new_database.demographic_total AS dt;

SELECT * FROM new_database.population_total;

ALTER TABLE new_database.population_total
	ADD CONSTRAINT lnk_t_year_population_total FOREIGN KEY(year_key)
    REFERENCES new_database.t_year (year_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.population_total
	ADD CONSTRAINT lnk_suburb_population_total FOREIGN KEY(suburb_key)
    REFERENCES new_database.suburbs (suburb_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.population_total
	ADD CONSTRAINT lnk_demographic_population_total FOREIGN KEY(demographic_key)
    REFERENCES new_database.demographic_total (demographic_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
ALTER TABLE new_database.population_total
	ADD PRIMARY KEY( population_key);
