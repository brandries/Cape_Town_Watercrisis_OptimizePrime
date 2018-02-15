-- The code below allows the creation of the dam levels tables within the database - new_database

CREATE SCHEMA new_database
    AUTHORIZATION postgres;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

---create table dam_class---------
DROP TABLE IF EXISTS new_database.dam_class;
CREATE TABLE new_database.dam_class (
    dam_class_key UUid NOT NULL,
    class Character Varying(100) NOT NULL,
    PRIMARY KEY (dam_class_key),
    CONSTRAINT unique_dam_size_key UNIQUE (dam_class_key),
    CONSTRAINT unique_class UNIQUE (class) );
;

--create index index_dam_class_key--

CREATE INDEX idx_dam_class_key ON new_database.dam_class USING btree (dam_class_key);


--insert values into table dam_class--

INSERT INTO new_database."dam_class"
    (dam_class_key, class)
    VALUES
    (uuid_generate_v4(), 'Major Dam')
    ,(uuid_generate_v4(), 'Minor Dam') 
    ,(uuid_generate_v4(), 'Unknown');


SELECT * FROM new_database.dam_class;

DROP TABLE IF EXISTS new_database.month_temp;

CREATE TABLE new_database.month_temp (
	month_id Integer NOT NULL,
    Month Character Varying (50) NOT NULL,
    t_year Integer NOT NULL,
    t_month Integer NOT NULL,
    month_year Character Varying(50) NOT NULL,
    PRIMARY KEY ("month_id"),
    CONSTRAINT unique_month_temp UNIQUE (month_year)
);

SELECT * FROM new_database.month_temp;

COPY new_database.month_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Months.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.month_temp;

---create table t_month---

DROP TABLE IF EXISTS new_database.t_month;

CREATE TABLE new_database.t_month(
	month_key UUid NOT NULL,
    month_year Character Varying(50) NOT NULL,
    t_month Integer NOT NULL,
    t_year Integer NOT NULL,
    PRIMARY KEY (month_key),
    CONSTRAINT unique_month_year_key UNIQUE(month_key),
	CONSTRAINT unique_month UNIQUE(month_year)
);

---create index idx_month1---

CREATE INDEX idx_month1 ON new_database.t_month USING btree (month_year Asc NULLS Last);

---create index idx_month2----

CREATE INDEX idx_month2  ON new_database.t_month USING btree (t_year Asc NULLS Last, t_month Asc NULLS Last);

----insert values into table month-----

INSERT INTO new_database.t_month (month_key, month_year,t_month,t_year)
SELECT
	uuid_generate_v4() AS month_key
    , month_year AS month_year
    , t_month AS t_month
    , t_year AS t_year
FROM new_database.month_temp;

SELECT * FROM new_database.t_month;

DROP TABLE IF EXISTS new_database.date_temp;

CREATE TABLE new_database.date_temp (
    date_id Integer NOT NULL,
    date Character Varying(50) NOT NULL,
    day Integer NOT NULL,
    month Integer NOT NULL,
    year Integer NOT NULL,
    date_text Character Varying(50) NOT NULL,
    PRIMARY KEY (date_id),
    CONSTRAINT unique_date_temp UNIQUE(date_text)
	);
    
SELECT*
FROM new_database.date_temp;

COPY new_database.date_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Dates.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM new_database.date_temp;

----create table new_t_date----

DROP TABLE IF EXISTS new_database.new_t_date;

CREATE TABLE new_database.new_t_date (
	date_key UUid NOT NULL,
    t_date Date NOT NULL,
    month_key UUid NOT NULL,
    PRIMARY KEY (date_key),
    CONSTRAINT unique_date_key UNIQUE(date_key),
	CONSTRAINT unique_date UNIQUE(t_date));
    
-----create index idx_date-----    

CREATE INDEX idx_date ON new_database.new_t_date USING btree(t_date ASC NULLS Last);

----create index idx_monthkey----

CREATE INDEX idx_month_key ON new_database.new_t_date USING btree(month_key ASC NULLS Last);

  
INSERT INTO new_database.new_t_date
(date_key,t_date , month_key)
SELECT
	uuid_generate_v4() AS date_key,
    to_date( date_temp.date , 'dd/mm/yyyy' ) AS t_date,
    t_month.month_key
FROM new_database.date_temp AS date_temp

LEFT JOIN new_database.t_month AS t_month
ON t_month.t_month = date_temp.month
AND t_month.t_year = date_temp.year;

-- make a temp table to get the year column from the month table
SELECT DISTINCT t_year
INTO new_database.year_temp
FROM new_database.t_month
ORDER BY t_year;

-- create a table differentaiting the years t_year
DROP TABLE IF EXISTS new_database.t_year;

CREATE TABLE new_database.t_year (
    year_key UUid NOT NULL, 
    t_year INTEGER NOT NULL,
    PRIMARY KEY (year_key),
    CONSTRAINT unique_year_key UNIQUE(year_key),
    CONSTRAINT unique_t_year UNIQUE(t_year));

SELECT * FROM new_database.t_year;

--Add indices to those tables
CREATE INDEX idx_year ON new_database.t_year USING btree(t_year Asc NULLS Last);

-- insert data into the t_year table
INSERT INTO new_database.t_year
	(year_key, t_year)
    SELECT 
    uuid_generate_v4() as year_key, 
    t_year
    FROM new_database.year_temp;
    
--drop the temp year table    
DROP TABLE IF EXISTS year_temp;

SELECT * FROM new_database.t_year;

-- add the year key to the t_date table
ALTER TABLE new_database.new_t_date ADD COLUMN year_key UUid;
    
-- make a temp table
DROP TABLE IF EXISTS temp_year_key;

SELECT y.year_key, m.month_key, d.date_key
INTO new_database.temp_year_key
FROM new_database.new_t_date as d
LEFT JOIN new_database.t_month as m
ON d.month_key = m.month_key
LEFT JOIN new_database.t_year as y
ON m.t_year = y.t_year;

SELECT * FROM new_database.temp_year_key;
-- make the new t_date table which can be linked to the other tables


SELECT d.date_key, d.t_date, d.month_key, y.year_key
INTO new_database.t_date
FROM new_database.new_t_date as d
LEFT JOIN new_database.temp_year_key as y
ON d.date_key = y.date_key
ORDER BY t_date;
    
DROP TABLE new_database.new_t_date;

ALTER TABLE new_database.t_date  ADD CONSTRAINT unique_t_date_key UNIQUE(date_key);

SELECT * FROM new_database.t_date;  
    
SELECT DISTINCT * FROM new_database.t_date
ORDER BY t_date;

----create link lnk_t_month_t_date---

ALTER TABLE new_database.t_date
	ADD CONSTRAINT lnk_t_month_t_date FOREIGN KEY (month_key)
    REFERENCES new_database.t_month (month_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;

ALTER TABLE new_database.t_date
	ADD CONSTRAINT lnk_t_year_t_date FOREIGN KEY(year_key)
    REFERENCES new_database.t_year (year_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;    
    
---------------------------------------  


DROP TABLE IF EXISTS new_database.date_temp;
---------------------------------------
SELECT *
FROM new_database.t_date;
---create table dam_name-------------

DROP TABLE IF EXISTS new_database.dam_name;
create table new_database.dam_name(
	dam_name_key UUid NOT NULL,
    name Character Varying(2044) not null,
    dam_class_key UUid NOT NULL,
    dam_capacity_ml Double Precision not null,
    primary key (dam_name_key),
    constraint unique_dam_name_key unique(dam_name_key),
    constraint unique_dam_name unique(name)
);
-----create index idx_name-------
CREATE INDEX idx_name ON new_database.dam_name USING btree(name ASC NULLS Last);

insert into new_database.dam_name
(dam_name_key, name, dam_class_key, dam_capacity_ml)
values
(uuid_generate_v4(), 'THEEWATERSKLOOF', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 480180),
(uuid_generate_v4(), 'VOELVLEI', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 164095),
(uuid_generate_v4(), 'BERG RIVER', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 130010),
(uuid_generate_v4(), 'WEMMERSHOEK', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 58644),
(uuid_generate_v4(), 'STEENBRAS LOWER', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 33517),
(uuid_generate_v4(), 'STEENBRAS UPPER', (select dam_class_key from new_database.dam_class where class = 'Major Dam'), 31767),
(uuid_generate_v4(), 'KLEINPLAATS', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 1301),
(uuid_generate_v4(), 'WOODHEAD', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 955),
(uuid_generate_v4(), 'HELY-HUTCHINSON', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 925),
(uuid_generate_v4(), 'LAND-en ZEEZICHT', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 451),
(uuid_generate_v4(), 'DE VILLIERS', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 242),
(uuid_generate_v4(), 'LEWIS GAY', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 168),
(uuid_generate_v4(), 'ALEXANDRA', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 134),
(uuid_generate_v4(), 'VICTORIA', (select dam_class_key from new_database.dam_class where class = 'Minor Dam'), 128);

---create link lnk_dam_class_dam_name---
SELECT * FROM new_database.dam_name;

alter table new_database.dam_name
	add constraint lnk_dam_class_dam_name foreign key (dam_class_key)
    references new_database.dam_class (dam_class_key) match full
    on delete restrict
    on update cascade;
    
---create table dam_stats-------    
DROP TABLE IF EXISTS new_database.dam_stats;

CREATE TABLE new_database.dam_stats (
	dam_stats_key UUid NOT NULL,
   	dam_name_key UUid NOT NULL,
    date_key UUid NOT NULL,
    height_m REAL NULL,
    storage_ml REAL NULL,
    PRIMARY KEY (dam_stats_key),
    CONSTRAINT unique_dam_stats_id UNIQUE(dam_stats_key) ); 
    
---create index index_dam_name_key--- 
CREATE INDEX idx_dam_name_key ON new_database.dam_stats USING btree(dam_name_key);

---create index index_date_key----------
CREATE INDEX idx_date_key ON new_database.dam_stats USING btree(date_key);

---create link lnk_t_date_dam_stats----
ALTER TABLE new_database.dam_stats
	ADD CONSTRAINT lnk_t_date_dam_stats FOREIGN KEY (date_key)
    REFERENCES new_database.t_date (date_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
---create link lnk_dam-name_dam_stats-------    
ALTER TABLE new_database.dam_stats
	ADD CONSTRAINT lnk_dam_name_dam_stats FOREIGN KEY (dam_name_key)
    REFERENCES new_database.dam_name (dam_name_key) MATCH FULL
    ON DELETE Restrict
    ON UPDATE Cascade;
    
---create temporary table for dam level data---    
DROP TABLE IF EXISTS new_database.dam_temp;

CREATE TABLE new_database.dam_temp (
	date Character Varying(50) NOT NULL,
	dam_name Character Varying(50) NOT NULL,
    height_m REAL NULL,
    storage_ml REAL NULL
);


---------Alexandra Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT * FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Alexandra.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Berg River Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Berg River.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------De Villiers Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\De Villiers.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Hely-Hutchinson Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Hely-Hutchinson.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Kleinplaats Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Kleinplaats.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Land-en Zeezicht Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Land-en Zeezicht.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Lewis Gay Dam Data--------
TRUNCATE TABLE new_database.dam_temp;
SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Lewis Gay.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Steenbras Lower Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Steenbras Lower.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Steenbras Upper Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Steenbras Upper.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Theewaterskloof Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Theewaterskloof.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Victoria Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Victoria.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------VoelVlei Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\VoelVlei.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');


---------Wemmershoek Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Wemmershoek.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');

---------Woodhead Dam Data--------
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp FROM 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Woodhead.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_database.dam_temp;

INSERT INTO new_database.dam_stats (dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
SELECT
	uuid_generate_v4() AS dam_stats_key, dam_name.dam_name_key AS dam_name_key, t_date.date_key AS date_key,
    dam_temp.height_m AS height_m, dam_temp.storage_ml AS storage_ml
FROM new_database.dam_temp AS dam_temp
LEFT JOIN new_database.dam_name AS dam_name ON dam_name.name = dam_temp.dam_name
LEFT JOIN new_database.t_date AS t_date ON t_date.t_date = to_date(dam_temp.date, 'dd/mm/yyyy');



----------------------------------------------
--This is where we add the 2018 data
-------------------------------------------------
--update the dam_stats tables

DROP TABLE IF EXISTS new_database.temp;

CREATE TABLE new_database.temp
(
    date character varying(50) COLLATE pg_catalog.default NOT NULL,
    dam_name character varying(50) COLLATE pg_catalog.default NOT NULL,
    height_m real,
    storage_ml real
);

--ALEXANDRA 
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Alexandra.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;

--BERG RIVIER
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Berg River.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;


--De villiers
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\De Villiers.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;

--Hely-Hutchinson
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Hely-Hutchinson.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;

-- Kleinplaats
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Kleinplaats.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;

-- Lewis Gay
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Lewis Gay.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;


-- Steenbras Lower
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Steenbras Lower.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;



-- Steenbras Upper
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Steenbras Upper.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;



-- Theewaterskloof
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Theewaterskloof.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;



-- VoelVlei
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\VoelVlei.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;



-- Wemmershoek
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Wemmershoek.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;

-- Woodhead
TRUNCATE TABLE new_database.dam_temp;

SELECT* FROM new_database.dam_temp;

COPY new_database.dam_temp from 'C:\Users\Andries van der Walt\Documents\Sql\SQL scripts\SQL scripts\dam_levels\Woodhead.csv' DELIMITER ',' CSV HEADER;


INSERT INTO new_database.dam_stats(dam_stats_key, dam_name_key, date_key, height_m, storage_ml)
	SELECT uuid_generate_v4() as dam_stats_key, dam_name.dam_name_key, t_date.date_key as date_key,
			temp.height_m as height_m, temp.storage_ml as storage_ml
	FROM new_database.dam_temp as temp
	LEFT JOIN new_database.dam_name as dam_name on dam_name.name = temp.dam_name
	LEFT JOIN new_database.t_date as t_date on t_date.t_date = to_date(temp.DATE, 'dd/mm/yy');
		
TRUNCATE new_database.temp;


--Have a look at damstats

SELECT DISTINCT * FROM new_database.dam_stats;

-- drop all the temp tables created
DROP TABLE IF EXISTS new_database.dam_temp;
DROP TABLE IF EXISTS new_database.month_temp;
DROP TABLE IF EXISTS new_database.temp;
DROP TABLE IF EXISTS new_database.year_temp;
DROP TABLE IF EXISTS new_database.temp_year_key;


--CREATE a view - REDO THIS

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

SELECT *
FROM new_database.view_damlevels;