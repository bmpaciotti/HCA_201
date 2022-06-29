-- Assignment 1

--- Pick a database.   This is very important!  When you start, use OMOP_TEST 

-- USE OMOP_PROD;


  USE OMOP_TEST;

-- A few important things to know!
-- limit how many rows are returned.  This will prevent long queries that "bomb" your computer !


SELECT *
FROM visit_occurrence LIMIT 1000 -- HERE WE ONLY SELECT 1,000 ROWS  .. FAST!

-- The Case (lower/upper) of the table name matters!   Be careful!  
SELECT *
FROM PERSON;-- this wont work...

SELECT *
FROM person;-- but this will. 

-- Review Data in Tables 
SELECT *
FROM visit_occurrence;

SELECT *
FROM vocabulary;

SELECT *
FROM provider;

SELECT *
FROM domain;

SELECT *
FROM person;

SELECT *
FROM condition_occurrence;

SELECT *
FROM drug_exposure;

SELECT *
FROM procedure_occurrence;

SELECT *
FROM concept;

SELECT *
FROM concept_relationship;

SELECT *
FROM observation_period;

SELECT *
FROM death;

SELECT *
FROM observation;

SELECT *
FROM measurement;

SELECT *
FROM cost;

SELECT *
FROM condition_era;

SELECT *
FROM drug_era;

-- Get Row Counts from Tables 
SELECT count(*)
FROM visit_occurrence;

SELECT count(*)
FROM vocabulary;

SELECT count(*)
FROM provider;

SELECT count(*)
FROM domain;

SELECT count(*)
FROM person;

SELECT count(*)
FROM condition_occurrence;

SELECT count(*)
FROM drug_exposure;

SELECT count(*)
FROM procedure_occurrence;

SELECT count(*)
FROM concept;

SELECT count(*)
FROM concept_relationship;

SELECT count(*)
FROM observation_period;

SELECT count(*)
FROM death;

SELECT count(*)
FROM observation;

SELECT count(*)
FROM measurement;

SELECT count(*)
FROM cost;

SELECT count(*)
FROM condition_era;

SELECT count(*)
FROM drug_era;

-- Check performance of Indexes using Explain PLAN
EXPLAIN

SELECT v.*
FROM visit_occurrence v
INNER JOIN person p ON v.person_id = p.person_id
WHERE p.person_id = 1;

--- Create Temporary Table 
CREATE TEMPORARY TABLE temp_visits

SELECT v.*
FROM visit_occurrence v
INNER JOIN person p ON v.person_id = p.person_id
WHERE p.person_id = 1;

SELECT *
FROM temp_visits;

DROP TABLE temp_visits;

-- If you want to extract the Year/Month/Day from the current date, the following SQL can be used.
SELECT year(condition_start_date)
FROM condition_occurrence;

SELECT month(condition_start_date)
FROM condition_occurrence;

SELECT day(condition_start_date)
FROM condition_occurrence;
