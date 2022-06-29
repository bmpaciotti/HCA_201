
  
  -- Assignment #5
  
   -- Data Quality 
  
  /*
  	Run at least six (6) of the data quality algorithms provided in the Data Qualityexample script.
      Try to create a new query to measure a new aspect of data quality.  If you cannot figure out the SQL, do your best to summarize in English how the query might be structured.

  
  */
  
  
  -- A yes or no value indicating if the provider_id in the PERSON is the expected data type based on the specification. (Threshold=0%).
  
 	
	
    -- I need to add a few simplier, more general SQL examples  
	
	
	
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
		  FROM  PERSON P
		 WHERE provider_id  = 0
		 
		 
	) violated_rows
) violated_row_count,
( 
	SELECT COUNT(*) AS num_rows
	FROM PERSON
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
  

  
  
  