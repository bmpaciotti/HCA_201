

-- Introductory SQL Queries


--- Pick a database.   This is very important!  When you start, use OMOP_TEST 

  	
   -- USE OMOP_PROD;

  
    USE OMOP_TEST;
   

 -- A few important things to know!

   -- limit how many rows are returned.  This will prevent long queries that "bomb" your computer !
   
   SELECT *
    FROM visit_occurrence 
	  LIMIT 1000   -- HERE WE ONLY SELECT 1,000 ROWS  .. FAST!
 
	  
 -- The Case (lower/upper) of the table name matters!   Be careful!  
 
	SELECT * FROM PERSON;   -- this wont work...

    SELECT * FROM person;   -- but this will. 
	
    
-- Review Data in Tables 

select * from visit_occurrence;

select * from vocabulary;

select * from provider;

select * from domain;

select * from person;

select * from condition_occurrence;

select * from drug_exposure;

select * from procedure_occurrence;

select * from concept;

select * from concept_relationship;

select * from observation_period;

select * from death;

select * from observation;

select * from measurement;

select * from cost;

select * from condition_era;

select * from drug_era;
    
-- Get Row Counts from Tables 

select count(*) from visit_occurrence;

select count(*) from vocabulary;

select count(*) from provider;

select count(*) from domain;

select count(*) from person;

select count(*) from condition_occurrence;

select count(*) from drug_exposure;

select count(*) from procedure_occurrence;

select count(*) from concept;

select count(*) from concept_relationship;

select count(*) from observation_period;

select count(*) from death;

select count(*) from observation;

select count(*) from measurement;

select count(*) from cost;

select count(*) from condition_era;

select count(*) from drug_era;
    
    	  
 -- Check performance of Indexes using Explain PLAN
 
 EXPLAIN 
   select v.*
   from visit_occurrence  v
     inner join person p 
	  on v.person_id = p.person_id
	where p.person_id = 1;
 
 
--- Create Temporary Table 


CREATE TEMPORARY TABLE temp_visits
  select v.*
   from visit_occurrence  v
     inner join person p 
	  on v.person_id = p.person_id
	where p.person_id = 1;
 

  select * from temp_visits;

  
  DROP TABLE temp_visits;

 
 
 -- If you want to extract the Year/Month/Day from the current date, the following SQL can be used.
 
 
 SELECT year (condition_start_date)
  FROM condition_occurrence ;

  SELECT month (condition_start_date)
  FROM condition_occurrence ;
  
  SELECT day (condition_start_date)
  FROM condition_occurrence ;

-------------------------------------------------------------------------------------------------------------------------------- 
 
-- Part I.  Select Columns, Get Counts

/*
 Select the first and last column from the PERSON table
	Select all rows and all columns from the CARE_SITE table
	Count how many rows are in each of the tables within this database
	Count how many distinct patients are in six (6) of the tables of your choosing

*/

SELECT * 
   FROM person LIMIT 1000;

   
SELECT person_id,
       year_of_birth
	   FROM person;
   

SELECT COUNT(person_id) AS num_persons_count
FROM   person p ;



-- COUNTS 
SELECT COUNT(person_id) AS num_persons_count
FROM   visit_occurrence;


-- COMPARE TO DISTINCT COUNTS 
SELECT COUNT(DISTINCT person_id) AS num_persons_count
FROM   visit_occurrence;


-- COUNTS WITH FILTER 
EXPLAIN  
SELECT
  COUNT(DISTINCT person_id) AS persons_with_condition_count
FROM  condition_occurrence
WHERE condition_concept_id = 31967
      AND person_id IS NOT NULL;
 
 
EXPLAIN 
SELECT
  COUNT(DISTINCT person_id) AS persons_with_condition_count
FROM  condition_occurrence
WHERE condition_concept_id = 31967
      AND person_id = 1;
 
 
-- Part II.  Filtering Rows (WHERE)

 /*
  To view the data, select the first 1,000 rows from one of the large tables 
   Write a query to select only male patients from PERSON table 
	Write a query to select only patients from California in the PERSON table 
	Select all patient records that have a specific category of diseases such as diabetes 
	Select rows from the table where the person was born between 1940 and 1950
	Create a query to select all rows from the CONDITION_OCCURRENCE table with ICD codes 
o	You can choose other codes if you prefer just document what you did and why 
	Select patients in CONDITION_OCCURRENCE with CONDITION_CONCEPT_ID = 134736
*/

SELECT * 
   FROM person LIMIT 1000;


SELECT COUNT(person_id) AS num_persons
  FROM person
    WHERE gender_concept_id = 8532;


-- look at data with "GROUP BY" query 

SELECT
  state    AS state_abbr,
  COUNT(*) AS num_persons
FROM person
  LEFT JOIN location 
      ON person.location_id = location.location_id
GROUP BY state
ORDER BY state;

-- Part III.  Joins 

/*
    Join the PERSON table with VISIT_OCCURRENCE using an inner join
	Join the PERSON table to the MEASUREMENT table using a left outer join.  
	Create a query that joins the CONDITION_OCCURRENCE table to the CONCEPT table 
	Experiment with left outer joins so that you have columns from two separate tables.  
	Try to see how data can be included from one of the tables but can be missing from another table.  

*/

  select v.*
   from visit_occurrence  v
     inner join person p 
	  on v.person_id = p.person_id
	where p.person_id = 1;
 

 --CE10: Counts of persons with conditions
/*
Description: This query is used to count the persons with any number of eras of a 
certain condition (condition_concept_id). The input to the query is a value 
(or a comma-separated list of values) of a condition_concept_id. 
If the input is omitted, all possible values are summarized.
*/

SELECT ce.condition_concept_id, c.concept_name, COUNT(DISTINCT person_id) AS num_people
  FROM condition_era ce
  JOIN concept c
    ON c.concept_id = ce.condition_concept_id
 WHERE ce.condition_concept_id
    IN /* top five condition concepts by number of people */
        ( 256723, 372906, 440377, 441202, 435371 )
 GROUP BY ce.condition_concept_id, c.concept_name
 ORDER BY num_people DESC;
 
 
-- Part IV.  Sorting (Ordering)  


 -- THIS TAKE A LONG TIME TO RUN.. BE CAREFUL.   LIMIT COLUMNS TO MAKE IT FASTER 
 SELECT *
   FROM condition_occurrence
   ORDER BY PERSON_ID;

   
 SELECT PERSON_ID
  FROM visit_occurrence
   ORDER BY PERSON_ID
  
  
  -- OPTIONAL 
  
 /*
  	Select all patients in the PERSON table who less than 80 years old and who have diabetes in the CONDITION_OCCURRENCE table

	Use a join to select specific types of patients based on procedure codes using the PROCEDURE_OCCURRENCE table. Sort the query by PERSON_ID and then VISIT_OCCURRENCE_ID to better understand the output. 
o	What is a problem with joining tables that both have multiple rows per patient?

	Create a query that has patients with at least one of the following drugs as defined by RxNorm vocabulary_id (19024574, 19024591, 19024592, 19024593)

	Evaluate if any of VISIT_OCCURRENCE_IDs on the MEAUREMENT table matches to encounters on the VISIT_OCCURENCE table 

	Create a "region" variable by grouping at least 15 states into US regions (e.g., Northwest, Southwest, Southeast).  
o	You can do this using CASE/WHEN statements. 

   Show how to add the labels for gender based on codes in the PERSON table (join to CONCEPT table)

	Provide two examples of how you can use the wildcard function (e.g., '%DIABETES%) to search for particular diseases in the CONCEPT table

	Illustrate at least one way to evaluate if patients have more than one row in the VISIT_OCCURRENCE table

	Show how to calculate some average costs in the COST table

	Using a GROUP BY statement, count how many rows are associated with different visit types in the VISIT_OCCURRENCE table

*/

SELECT
  month_of_birth,
  day_of_birth,
  count(*) AS num_persons
FROM person
GROUP BY month_of_birth, day_of_birth
ORDER BY month_of_birth, day_of_birth
;
	
	
	
SELECT  condition_source_value,
         COUNT(*) AS code_count
FROM condition_occurrence
GROUP BY condition_source_value
ORDER BY COUNT(*) DESC;
	
	
	
select  cs.place_of_service_concept_id, 
        count(*) places_of_service_count
from care_site cs
group by cs.place_of_service_concept_id
order by 1
;


-- perhaps we interested in the average length of an observation period:


SELECT 
        avg(
	      year(observation_period_start_date) -
		  year(observation_period_end_date)    / 365.25) AS NUM_YEARS

	       FROM observation_period;

	      
	      

		     
select year(observation_period_end_date)  AS DT_Year,
                        observation_period_end_date
 from observation_period;




 select * 
   from person
    WHERE GENDER_CONCEPT_ID = 8507;
 
 

SELECT  MAX(year(observation_period_end_date) - year_of_birth) AS max_age
FROM person
INNER JOIN observation_period
ON person.person_id = observation_period.person_id;
  
  
/* ------------------------------------------------------------------------------------------------------------------ */
 
WITH T AS
(
   select 
   p.person_id,
   c1.concept_name AS cond,
   c2.concept_name AS gender,
   year(ce.condition_era_start_date) - p.year_of_birth as age

FROM condition_era ce
INNER JOIN person p
    ON p.person_id = ce.person_id

INNER JOIN concept c1
    ON c1.concept_id = ce.condition_concept_id

INNER JOIN concept c2
    ON c2.concept_id = p.gender_concept_id
	)

SELECT 
      person_id,
	  cond,
      gender,
      age
FROM T;
  
  
  
  
  
  

