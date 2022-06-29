
 
  -- Assignment 6  
 
 
    -- COHORT EXAMPLES 
 
 /*
 
   In this assignment, use some of the SQL query examples provided by the instructor and/or examples shared by other students to create some patient registries.  
  
o	Do your best to create a few registries by combining data from different tables 
o	If you have trouble with the SQL, please write up in English what you tried to accomplish, and the type of algorithms that you worked to create

   You will have an opportunity to expand upon these registries (cohorts) for the final project

*/

USE OMOP_TEST;  -- start with this!   


select  * 
  from person limit 1000;


---------------------------------------------------------------------------------
       -- EXAMPLE 1.   
---------------------------------------------------------------------------------

   -- HINT!   Run separately each "block of code separated by the lines  -----    
  
  
    -- STEP 1.  Find concepts with a disease .. 


CREATE TEMPORARY TABLE condition_concepts 
WITH Q AS
 (
  
SELECT
  c.concept_id       AS condition_concept_id,
  c.concept_name     AS condition_concept_name,
  c.concept_code     AS condition_concept_code,
  c.concept_class_id AS condition_concept_class,
  c.vocabulary_id    AS condition_concept_vocab_id,
  CASE c.vocabulary_id
  WHEN 'SNOMED'
    THEN CASE lower(c.concept_class_id)
         WHEN 'clinical finding'
           THEN 'Yes'
         ELSE 'No' END
  WHEN 'MedDRA'
    THEN 'Yes'
  ELSE 'No'
  END                AS is_disease_concept_flag
FROM concept AS c
WHERE
  c.concept_name like '%Gastrointestinal hemorrhage%'

  )
  
 SELECT condition_concept_id 
 FROM Q
  
;

/* ------------------------------------------------------------------------------------------------------------------------------------------ */

   SELECT * FROM condition_concepts ;

   -- look at the names of concepts 
   
     --- Look at concept names  
	
	  select  cc.condition_concept_id,  
	          c.concept_name  
	      from condition_concepts cc
	       left join concept c
		      on cc.condition_concept_id = c.concept_id
	    ;
     


---------------------------------------------------
   -- TEST IT 
       SELECT *
        FROM condition_concepts;
---------------------------------------------------



-------------------------------------------------------------------------------------------
-- STEP 2.   EXTRACT PATIENTS WHO HAVE CONDITION 


truncate table condition_cohort ;
drop table condition_cohort;



CREATE TEMPORARY TABLE  condition_cohort  
SELECT PERSON_ID,
       condition_concept_id
FROM condition_occurrence
  WHERE condition_concept_id IN 
     (SELECT DISTINCT condition_concept_id 
          FROM condition_concepts);


     select * from condition_cohort;  
         
         
    --- Look at concept names  
	
	  select  cc.condition_concept_id ,  
	           c.concept_name  
	    from condition_cohort    cc
	       left join concept c
		      on cc.condition_concept_id = c.concept_id;
	
	
	  -- exclusion 
	    select *  from person
		  
		  where person_id in (
		     select distinct person_id
		      from CONDITION_COHORT)
			  
			  and year_of_birth  = 1943;
	    
		 
 --how it should be written?
select cc.condition_occurrence_id ,
c.concept_name
from CONDITION_COHORT cc
left join concept c
on cc.condition_concept_id = c.concept_id 

		  
		  
		  
 ---  NOW YOU HAVE A COHORT OF PATIENTS WITH SPECIFIC DISEASE...
    --- WHAT OTHER ATTRIBUTES MIGHT BE OF INTEREST?   ADD SOME!


SELECT *
 FROM drug_exposure
   WHERE PERSON_ID IN
 (SELECT DISTINCT PERSON_ID FROM CONDITION_COHORT)


--- WHAT ELSE CAN YOU ADD?  !!!! 


-------------------------------------------------------------------------------------------------------------------------
       -- Example 2   --- here is how you could select conditions with TERMS database 
-------------------------------------------------------------------------------------------------------------------------

  -- HINT!   Run separately each "block of code separated by the lines  -----    
    -- NOTE:  FOR THIS ONE, YOU NEED TO LINK TO TERMS DATABASE 
   
   
  CREATE TABLE DIAB_CODES 
    (
       DIABETES_CD INTEGER
    );
  
--------------------------------------------------------------------------------------------------------------------------------------
 
WITH snomed_diabetes 
AS (
SELECT ca.descendant_concept_id AS snomed_diabetes_id
  FROM concept c
  JOIN concept_ancestor ca
    ON ca.ancestor_concept_id = c.concept_id
 WHERE c.concept_code = '73211009'
)

 INSERT INTO DIAB_CODES
    SELECT *
     from snomed_diabetes;

	 ------------------------------------------------------------------------------------------------------------------------- 
	 
	 --- RUN THIS TO SEE WHICH CODES ARE FOUND.. 
	 
    SELECT * FROM DIAB_CODES;

	  -- I SEE 125 CODES 

 ------------------------------------------------------------------------------------------------------------------------- 	
	
    -- STEP 2.   EXTRACT PATIENTS WHO HAVE CONDITION 

   CREATE TABLE CONDITION_DIAB 
     (PERSON_ID INTEGER,
      CONDITION_OCCURRENCE_ID INTEGER
        );
--------------------------------------------------------------------------------------------------- 


INSERT INTO CONDITION_DIAB 
SELECT PERSON_ID,
 CONDITION_OCCURRENCE_ID 
FROM condition_occurrence
  WHERE condition_concept_id IN 
     (SELECT DISTINCT DIABETES_CD
        FROM DIAB_CODES)
	  

--------------------------------------------------------------------------------------------------- 

    SELECT * FROM CONDITION_DIAB ;
	  
--------------------------------------------------------------------------------------------------- 


    --- FROM THIS "BASE" COHORT, YOU COULD TRY TO CREATE AN ANALYTICAL FILE ... MERGE IN OTHER DATA ...
	    -- THIS IS JUST A START!
		
		--- YOU DO NOT HAVE TO WRITE COMPLEX SQL IF YOU HAVE TROUBLE.  YOU CAN WRITE OUT SEPARATE INDIVIDUAL QUERIES 
		  -- THEN FILL IN WITH ENGLISH DESCRIPTIONS HOW YOU MIGHT LINK THE DATA
		  
		  -- IN OTHER WORDS, START WITH THE PERSON_ID, AND GO TO OTHER TABLES AND GATHER DATA...
		
		
		
	 -- MAYBE FIRST LOOK AT CONDITIONS ... 
		
		
	SELECT  *
	  FROM condition_occurrence
	    WHERE condition_concept_id IN  
	 
	      ( SELECT DISTINCT person_id
	            FROM CONDITION_DIAB )  ;
		
	
	 --- NEXT LOOK AT DRUGS ...
	 
	 
	 ---- NEXT LOOK AT MEASUREMENTS ... 
	 
	 --- AND SO ON 
	 
	 
	 -- YOU CAN TRY TO CREATE TABLES TO STORE DATA FOR FUTURE QUERIES... OR KEEP IT SIMPLE AND WRITE SEPARATE QUERIES 
	  
-------------------------------------------------------------------------------------------------------------------------
   -- Example 3... 
------------------------------------------------------------------------------------	  
	  
	 -- SELECTING MALE PATIENTS WITH THYROID.

 
 
 CREATE TABLE COND 
   (
   condition_concept_id INTEGER,
   condition_concept_name char ,
   condition_concept_code CHAR,
   condition_concept_class CHAR,
   condition_concept_vocab_id CHAR,
   is_disease_concept_flag CHAR
   );
	 
	 
	INSERT INTO COND 	 
	 SELECT
  c.concept_id       AS condition_concept_id,
  c.concept_name     AS condition_concept_name,
  c.concept_code     AS condition_concept_code,
  c.concept_class_id AS condition_concept_class,
  c.vocabulary_id    AS condition_concept_vocab_id,
  CASE c.vocabulary_id
  WHEN 'SNOMED'
    THEN CASE lower(c.concept_class_id)
         WHEN 'clinical finding'
           THEN 'Yes'
         ELSE 'No' END
  WHEN 'MedDRA'
    THEN 'Yes'
  ELSE 'No'
  END                AS is_disease_concept_flag
FROM concept AS c
WHERE
  c.concept_name like '%thyroid%';
	 
	 
  SELECT * FROM COND;

-------------------------------------------------------------------------------------------------------------------------
   -- Example of string searches 
   
  /*
  I want to be able to add the term '%trauma%' to my WHERE lower(concept_name)
  like ‘%injury%’ but have not been able to correctly come up with the right
  combination. I have tried WHERE any.... and I have tried 'or' after the 
  injury but it has not worked. 
  */

SELECT C.condition_concept_id,
concept.concept_name AS disease_name,
count(condition_concept_id) as num_cond
FROM condition_occurrence C
JOIN concept
on c.condition_concept_id = concept.concept_id
WHERE condition_concept_id in
(

SELECT DISTINCT concept_id
FROM concept
WHERE    lower(concept_name) like '%injury%' 
     and lower(concept_name) like '%trauma%' 

)
group by c.condition_concept_id,
concept.concept_name 

   



 
 




