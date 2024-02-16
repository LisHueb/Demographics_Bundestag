CREATE TABLE dim_birthplace (
    birthplace_ID SERIAL PRIMARY KEY,
    place_of_birth TEXT,
    country_of_birth TEXT
);


INSERT INTO dim_birthplace (place_of_birth, country_of_birth)
SELECT DISTINCT place_of_birth, country_of_birth
FROM rawdata;


CREATE TABLE dim_elec_periods (
	election_period INTEGER PRIMARY KEY,
	start_mode DATE,
	end_mode DATE
);


INSERT INTO dim_elec_periods (election_period, start_mode, end_mode)
SELECT
	election_period,
	MODE() WITHIN GROUP (ORDER BY mdb_from) AS start_mode,
	MODE() WITHIN GROUP (ORDER BY mdb_until) AS end_mode
FROM
	rawdata
GROUP BY
	election_period;

CREATE TABLE dim_person (
    "id" INT PRIMARY KEY,
    last_name TEXT,
    first_name TEXT,
    adel TEXT,
    prefix TEXT,
    title TEXT,
    academic_title TEXT,
    birthday DATE,
    birthplace_ID INT,
    date_of_death DATE,
    gender TEXT,
    family_status TEXT,
	number_of_children INT,
    profession TEXT,
    party TEXT,
    FOREIGN KEY (birthplace_ID) REFERENCES dim_birthplace(birthplace_ID)
);


INSERT INTO dim_person ("id", last_name, first_name, adel, prefix, title, academic_title, birthday, birthplace_ID, date_of_death, gender, family_status, profession, party)
SELECT
    DISTINCT "id",
    last_name,
    first_name,
    adel,
    prefix,
    title,
    academic_title,
    birthday::DATE,
    (SELECT birthplace_ID FROM dim_birthplace WHERE place_of_birth = rawdata.place_of_birth AND country_of_birth = rawdata.country_of_birth),
    date_of_death::DATE,
    gender,
    family_status,
	number_of_children
    profession,
    party
FROM rawdata;


CREATE TABLE fct_mdb (
	"id" INTEGER,
	election_period INTEGER
);


INSERT INTO fct_mdb ("id", election_period)
SELECT
	"id"::INTEGER AS "id",
	election_period::INTEGER AS election_period
FROM
	rawdata;

