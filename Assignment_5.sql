
  
  -- Assignment #5
  
   -- Data Quality 
  
  /*
  	Run at least six (6) of the data quality algorithms provided in the Data Qualityexample script.
      Try to create a new query to measure a new aspect of data quality.  
      
      If you cannot figure out the SQL, do your best to summarize in English how the query might be structured.

  
  */
  
  
 	
-- Start with OMOP Test, then use PROD

  USE OMOP_PROD;
	

-- The number and percent of records with a date value in the visit_end_date field of the VISIT_OCCURRENCE table that occurs after death.-- 
 

		SELECT vo.*
		
		from visit_occurrence vo 
		join  death on vo.person_id = death.person_id
		where visit_end_date > death_date
	
 
		
 -- The number and percent of records with a value of 0 in the standard concept field race_concept_id in the PERSON table.  
 

	SELECT p.*		     		        
     FROM person p
	  WHERE race_concept_id = 0;
		
 
 
-- Any extreme or odd year of birth values?

		SELECT year_of_birth ,
		       count(*)
		   FROM person p
		     group by year_of_birth 
		     order by year_of_birth ;
		        
		    
			        
		        
 -- look for odd association between gender and specific types of conditions 


   SELECT  c.concept_name,
           p.gender_concept_id ,
           g.concept_name as gender,
           co.* 
	FROM condition_occurrence co 
      INNER JOIN  person p
		ON co.person_id = p.person_id
	   LEFT JOIN 
	     concept c 
	       on co.condition_concept_id  = c.concept_id
	   LEFT JOIN concept g   
	     on p.gender_concept_id  = g.concept_id 
	      
	 WHERE CONDITION_CONCEPT_ID=192367 
	   AND g.concept_name = 'MALE' ;
  

 -- CONCEPT_ID 436366 (Benign neoplasm of testis), the number and percent of records associated with patients with an implausible gender (correct gender = Male).    
	  
	  
   SELECT  c.concept_name,
           p.gender_concept_id ,
           g.concept_name as gender,
           co.* 
	FROM condition_occurrence co 
      INNER JOIN  person p
		ON co.person_id = p.person_id
	   LEFT JOIN 
	     concept c 
	       on co.condition_concept_id  = c.concept_id
	   LEFT JOIN concept g   
	     on p.gender_concept_id  = g.concept_id 
	      
	 WHERE CONDITION_CONCEPT_ID=436366
	   AND g.concept_name = 'FEMALE' ;	 
	  
	  

	  
	-- For a CONCEPT_ID 201801 (Primary malignant neoplasm of fallopian tube), the number and percent of records associated with patients with an implausible gender (correct gender = Female). 
	  
   SELECT  c.concept_name,
           p.gender_concept_id ,
           g.concept_name as gender,
           co.* 
	FROM condition_occurrence co 
      INNER JOIN  person p
		ON co.person_id = p.person_id
	   LEFT JOIN 
	     concept c 
	       on co.condition_concept_id  = c.concept_id
	   LEFT JOIN concept g   
	     on p.gender_concept_id  = g.concept_id 
	      
	 WHERE CONDITION_CONCEPT_ID=201801
	   AND g.concept_name = 'MALE' ;	 
	  	 
	  
	  
	  
-- For the combination of CONCEPT_ID 3025315 (Body weight) and UNIT_CONCEPT_ID 8739 (pound (US)), 
   -- the number and percent of records that have a value less than 4.	 


		SELECT m.* 
		     FROM measurement m  
		        WHERE m.MEASUREMENT_CONCEPT_ID = 3025315
		      AND m.unit_concept_id = 8739
		      AND m.value_as_number IS NOT NULL
		      AND value_as_number < 4	;
	
	
-- For the combination of CONCEPT_ID 3006923 (Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma) and UNIT_CONCEPT_ID 8554 (percent), the number and percent of records that have a value higher than 2000.     
		     
	
			SELECT m.* 
				FROM measurement   m
				WHERE m.MEASUREMENT_CONCEPT_ID = 3006923
				AND m.unit_concept_id = 8554
				AND m.value_as_number IS NOT NULL
				AND m.value_as_number > 2000	
				  
		     
--  The number and percent of records with a NULL value in the visit_occurrence_id of the MEASUREMENT.		   
		     

   SELECT person_id AS violating_field, m.* 
		FROM measurement m
		WHERE visit_occurrence_id  IS NULL

		     
		     
/*********
FIELD_CDM_DATATYPE

At a minimum, for each field that is supposed to be an integer, verify it is an integer

Parameters used in this template:
cdmDatabaseSchema = cdm_synthea_v897.dbo
cdmTableName = PERSON
cdmFieldName = provider_id
**********/


SELECT num_violated_rows, 
CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows END  
AS pct_violated_rows
FROM
(
	SELECT COUNT(violated_rows.violating_field) AS num_violated_rows
	FROM
	(
		SELECT P.provider_id AS violating_field, 
		       P.* 
		  FROM  person P
		 WHERE provider_id  = 0
		 
		 
	) violated_rows
) violated_row_count,
( 
	SELECT COUNT(*) AS num_rows
	FROM person
) denominator
;
  

/*********
MEASURE_VALUE_COMPLETENESS
Computing number of null values and the proportion to total records per field

Parameters used in this template:
cdmDatabaseSchema = cdm_synthea_v897.dbo
cdmTableName = VISIT_OCCURRENCE
cdmFieldName = provider_id
**********/


SELECT num_violated_rows, 
       CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows 
	     END  AS pct_violated_rows
FROM
(
	SELECT violated_rows.violating_field AS num_violated_rows
	FROM
	(
		SELECT V.provider_id AS violating_field, 
		        V.* 
		FROM VISIT_OCCURRENCE V
		WHERE V.provider_id IS NULL
	) violated_rows
) violated_row_count,
( 
	SELECT COUNT(*) AS num_rows
	FROM VISIT_OCCURRENCE
) denominator
;
  
  
  /*********
PLAUSIBLE_VALUE_LOW
get number of records and the proportion to total number of eligible records that fall below this threshold

Parameters used in this template:
cdmDatabaseSchema = cdm_synthea_v897.dbo
cdmTableName = OBSERVATION
cdmFieldName = observation_datetime
plausibleValueLow = '1950-01-01'
**********/

SELECT num_violated_rows, CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows END  AS pct_violated_rows
FROM
(
	SELECT COUNT(violated_rows.violating_field) AS num_violated_rows
	FROM
	(
		SELECT OBSERVATION.observation_datetime AS violating_field, OBSERVATION.*
		from OBSERVATION
    where observation_datetime < '1940-01-01'
	) violated_rows
) violated_row_count,
(
	SELECT COUNT(*) AS num_rows
	FROM OBSERVATION
	where observation_datetime is not null
) denominator
;
  
  
/*********
PLAUSIBLE_TEMPORAL_AFTER
get number of records and the proportion to total number of eligible records with datetimes that do not occur on or after their corresponding datetimes

Parameters used in this template:
cdmDatabaseSchema = cdm_synthea_v897.dbo
cdmTableName = VISIT_OCCURRENCE
cdmFieldName = visit_start_date
plausibleTemporalAfterTableName = PERSON
plausibleTemporalAfterFieldName = BIRTH_DATETIME
**********/

SELECT num_violated_rows, 
        CASE WHEN denominator.num_rows = 0 THEN 0 
		 ELSE 1.0*num_violated_rows/denominator.num_rows 
		END  AS pct_violated_rows
FROM
(
	SELECT COUNT(violated_rows.violating_field) AS num_violated_rows
	FROM
	(
		SELECT VISIT_OCCURRENCE.visit_start_date AS violating_field, 
		 VISIT_OCCURRENCE.*
    from VISIT_OCCURRENCE
    
		join PERSON
			on VISIT_OCCURRENCE.person_id = PERSON.person_id
		
    where BIRTH_DATETIME > visit_start_date
	) violated_rows
) violated_row_count,
(
	SELECT COUNT(*) AS num_rows
	FROM VISIT_OCCURRENCE
) denominator
;
  

  
  
  