

-- Assignment 2  -- Data Harmonization 


--  Pick a database.   This is very important!  When you start, use OMOP_TEST 
 -- USE OMOP_PROD;


USE OMOP_TEST;

------------------------------------------------------------------------------------------------------------------------------

-- Part I.  Select Columns, Get Counts
/*
 Select the first and last column from the PERSON table
	Select all rows and all columns from the CARE_SITE table
	Count how many rows are in each of the tables within this database
	Count how many distinct patients are in six (6) of the tables of your choosing

*/
SELECT *
FROM person LIMIT 1000;


SELECT person_id
	,year_of_birth
FROM person;


SELECT COUNT(person_id) AS num_persons_count
FROM person p;

-- COUNTS 
SELECT COUNT(person_id) AS num_persons_count
FROM visit_occurrence;

-- COMPARE TO DISTINCT COUNTS 
SELECT COUNT(DISTINCT person_id) AS num_persons_count
FROM visit_occurrence;


-- COUNTS WITH FILTER 

SELECT COUNT(DISTINCT person_id) AS persons_with_condition_count
FROM condition_occurrence
WHERE condition_concept_id = 31967
	AND person_id IS NOT NULL;


SELECT COUNT(DISTINCT person_id) AS persons_with_condition_count
FROM condition_occurrence
WHERE condition_concept_id = 31967
	AND person_id = 1;


------------------------------------------------------------------------------------------------------------------------------
-- Part II.  Filtering Rows (WHERE)


SELECT *
FROM person LIMIT 1000;

-- A "between" statement can help filter the data 

SELECT *
 FROM person where person_id between 1 and 500;

-- example of a Where statment to filter the rows .. but you need to know what these concept codes mean .. see query below and join to concept table 
SELECT *
  FROM person 
    where race_concept_id  = 8527 and gender_concept_id  = 8507;


--  Join the concept_id to the concept table so that you can look at labels/descriptions of the codes

SELECT
      p.gender_concept_id,
      c.concept_name,      
      COUNT(person_id) AS num_persons
FROM person p 
    inner join concept c 
      on p.gender_concept_id  = c.concept_id
  GROUP BY 
      p.gender_concept_id,
      c.concept_name    ;
       
  
-- Example of a "GROUP BY" query, you can change the whhere statement to filter out specific states
 
SELECT STATE AS state_abbr
	,COUNT(*) AS num_persons
FROM person
LEFT JOIN location ON person.location_id = location.location_id
WHERE STATE IN ('AK', 'AR', 'CT', 'FL')
GROUP BY STATE
ORDER BY STATE;


  -- ICD9CM for Condition
 
SELECT concept_id, concept_name, concept_code , domain_id , vocabulary_id 
FROM concept 
WHERE domain_id = 'Condition'
AND vocabulary_id = 'ICD9CM'

ORDER BY concept_name ASC   ;




------------------------------------------------------------------------------------------------------------------------------
-- Part III.  Joins 
/*
    Join the PERSON table with VISIT_OCCURRENCE using an inner join
	Join the PERSON table to the MEASUREMENT table using a left outer join.  
	Create a query that joins the CONDITION_OCCURRENCE table to the CONCEPT table 
	Experiment with left outer joins so that you have columns from two separate tables.  
	Try to see how data can be included from one of the tables but can be missing from another table.  

*/


-- Join person table to the condition table 
 SELECT DISTINCT co.person_id, c.concept_name
FROM condition_occurrence co 
INNER JOIN concept c
   ON co.condition_concept_id = c.concept_id
;


-- Join to concept table to get condition names


SELECT DISTINCT(concept_name) 
FROM condition_occurrence co
  inner join concept c 
    on co.condition_concept_id = c.concept_id;
    


SELECT v.*
FROM visit_occurrence v
INNER JOIN person p 
  ON v.person_id = p.person_id
  WHERE p.person_id = 1;
 
 
 -- try a left join to see if every patient in person table has some visit data 
 
 SELECT p.person_id, v.person_id
  FROM person p   
   LEFT JOIN visit_occurrence v
     ON p.person_id = v.person_id;
   
 

------------------------------------------------------------------------------------------------------------------------------  
-- Part IV.  Sorting (Ordering)  
    
  
SELECT person_id
FROM condition_occurrence
ORDER BY PERSON_ID;



SELECT PERSON_ID, visit_start_date , visit_occurrence_id 
FROM visit_occurrence
ORDER BY PERSON_ID , visit_start_date ;



SELECT PERSON_ID, visit_start_date , visit_occurrence_id 
FROM visit_occurrence
ORDER BY PERSON_ID DESC , visit_start_date ;



-- CE10: Counts of persons with conditions


SELECT ce.condition_concept_id
	,c.concept_name
	,COUNT(DISTINCT person_id) AS num_people
FROM condition_era ce
JOIN concept c ON c.concept_id = ce.condition_concept_id
WHERE ce.condition_concept_id IN /* top five condition concepts by number of people */
	(
		256723
		,372906
		,440377
		,441202
		,435371
		)
GROUP BY ce.condition_concept_id
	,c.concept_name
ORDER BY num_people DESC;




---------------------------------------------------------------------------------------------------------------------------------
  -- Additional Examples 


-- use wildcard query to search hypertension related codes

SELECT DISTINCT(concept_name) FROM condition_occurrence, concept
WHERE condition_occurrence.condition_concept_id = concept.concept_id
AND concept_name LIKE '%hypertension%';




SELECT month_of_birth
	,day_of_birth
	,count(*) AS num_persons
FROM person
GROUP BY month_of_birth
	,day_of_birth
ORDER BY month_of_birth
	,day_of_birth;



SELECT condition_source_value
	,COUNT(*) AS code_count
FROM condition_occurrence
GROUP BY condition_source_value
ORDER BY COUNT(*) DESC;




SELECT cs.place_of_service_concept_id
	,count(*) places_of_service_count
FROM care_site cs
GROUP BY cs.place_of_service_concept_id
ORDER BY 1;



-- perhaps we interested in the average length of an observation period:

SELECT avg(year(observation_period_start_date) - year(observation_period_end_date) / 365.25) AS NUM_YEARS
FROM observation_period;

-- Year funtion to select the year from a date


SELECT year(observation_period_end_date) AS DT_Year
	,observation_period_end_date
FROM observation_period;


-- max age 

SELECT MAX(year(observation_period_end_date) - year_of_birth) AS max_age
FROM person
INNER JOIN observation_period ON person.person_id = observation_period.person_id;



-- look at some averagess 

SELECT 
ROUND(AVG(total_paid),2) as average_total_paid, 
ROUND(AVG(paid_by_patient),2) as average_paid_by_patient, 
ROUND(AVG(total_paid - paid_by_patient),2) AS average_paid_by_other 
FROM cost ;



-- select todays date
SELECT CURDATE();



-- Create an age field base on today's date 
 SELECT 
     year_of_birth ,
    ( year(curdate()) - year_of_birth)  as Age 
  FROM person 



 --  count NULL providers, and % NULL 
  
 SELECT SUM(total_rows.null_row) as null_count, 
         (1.0*SUM(total_rows.null_row)/SUM(total_rows.row_count)) AS percent_null

 FROM
(
  SELECT 1 AS row_count, (CASE WHEN v.provider_id IS NULL THEN 1 ELSE 0 END) AS null_row 
    FROM visit_occurrence v
    
) total_rows ;
  
  
---------------------------------------------------------------------------------------------------------------------------------
  -- More complex examples of SQL



/* ------------------------------------------------------------------------------------------------------------------ */
-- This is an example of a subquery method using the "WITH" statement.  The T query if first run by the computer, then tables from this temporary table are selected below 
WITH T
AS (
	SELECT p.person_id
		,c1.concept_name AS cond
		,c2.concept_name AS gender
		,year(ce.condition_era_start_date) - p.year_of_birth AS age
	FROM condition_era ce
	INNER JOIN person p ON p.person_id = ce.person_id
	INNER JOIN concept c1 ON c1.concept_id = ce.condition_concept_id
	INNER JOIN concept c2 ON c2.concept_id = p.gender_concept_id
	
	)
SELECT person_id
	,cond
	,gender
	,age
FROM T;



/*********
PLAUSIBLE_TEMPORAL_AFTER
get number of records and the proportion to total number of eligible 
records with datetimes that do not occur on or after their corresponding datetimes
Cleaned up by: Kyle P. Rasku RN
**********/


SELECT  violated.visits_before_birth, 
        CASE WHEN denominator.num_rows = 0 THEN 0 
		 ELSE 1.0*violated.visits_before_birth/denominator.num_rows 
		END  AS pct_violated
FROM
(
	SELECT COUNT(visit_start_date) AS visits_before_birth
    FROM visit_occurrence vo 
    JOIN person p 
	ON vo.person_id = p.person_id
	WHERE p.birth_datetime > vo.visit_start_date
) violated,
(
	SELECT COUNT(*) AS num_rows
	FROM visit_occurrence vo2 
) denominator
;




