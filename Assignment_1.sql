-- Assignment 1

--- Pick a database.   This is very important!  When you start to test queries, please use OMOP_TEST 

 -- USE OMOP_PROD;  -- you can use OMOP_PROD once you are sure that the query will is correct and will run without errors, or that will take many hours to produce output


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

-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


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


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


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


-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------



-- Check performance of Indexes using Explain PLAN
EXPLAIN
SELECT v.*
FROM visit_occurrence v
INNER JOIN person p ON v.person_id = p.person_id
WHERE p.person_id = 1;



--- Create Temporary Table.   Once you start to get into more complex queries, it will help you to be able to store temporary tables.  It is important to truncate and drop them when you are done
CREATE TEMPORARY TABLE temp_visits

SELECT v.*
FROM visit_occurrence v
INNER JOIN person p ON v.person_id = p.person_id
WHERE p.person_id = 1;

SELECT *
FROM temp_visits;

 TRUNCATE TABLE temp_visits;
     DROP TABLE temp_visits;

    
    
-- If you want to extract the Year/Month/Day from the current date, the following SQL can be used.
SELECT year(condition_start_date)
FROM condition_occurrence;

SELECT month(condition_start_date)
FROM condition_occurrence;

SELECT day(condition_start_date)
FROM condition_occurrence;



--- Here is an example of what I call a "group by query" -- this allows you to count, sum, average rows by other fields 


SELECT race_concept_id , 
       count(*)
   from person n  
   group by race_concept_id 

 
   
  -- Here is an example of using CASE/When statements to recode the data into groups  
     -- Thansk to Kylie for these examples!      https://github.com/krashr-ds/healthcare-sql      
   
SELECT 
	CASE 
		WHEN TRIM(state) IN ('CT','ME','MA','NH','RI','VT') THEN 'New England'
		WHEN TRIM(state) IN ('NJ','NY','PA') THEN 'Mid-Atlantic'
		WHEN TRIM(state) IN ('IL','IN','MI','OH','WI') THEN 'East North Central'
		WHEN TRIM(state) IN ('IA','KS','MN','MO','NE','ND','SD') THEN 'West North Central'
		WHEN TRIM(state) IN ('DE','FL','GA','MD','NC','SC','VA','DC','WV') THEN 'South Atlantic'
		WHEN TRIM(state) IN ('AL','KY','MS','TN') THEN 'East South Central'
		WHEN TRIM(state) IN ('AR','LA','OK','TX') THEN 'West South Central'
		WHEN TRIM(state) IN ('AZ','CO','ID','MT','NV','NM','UT','WY') THEN 'Mountain'
		WHEN TRIM(state) IN ('AK','CA','HI','OR','WA') THEN 'Pacific'
	END Region,
	count(*)
FROM person, location 
WHERE person.location_id = location.location_id
GROUP BY Region  ;
   
 


SELECT 
 CASE WHEN TRIM(gender_source_value) = '1' THEN 'Male'
      WHEN TRIM(gender_source_value) = '2' THEN 'Female'
	  ELSE 'Other' END gender, count(*) 
FROM person GROUP BY gender;




--- Example of selecting 1 patient, join in labels using WHERE command 


SELECT C.Concept_Name, P.*, CC.Concept_Name, CCC.Concept_name, L.location_source_value 
FROM person P, concept C, concept CC, concept CCC, location L 
WHERE Person_ID = 1
AND P.gender_concept_id = C.concept_id
AND P.race_concept_id = CC.concept_id
AND P.ethnicity_concept_id = CCC.concept_id
AND P.location_id = L.location_id




