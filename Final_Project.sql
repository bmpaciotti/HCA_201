
---   Final Project -- Part 1 

/*
Imagine that you have been asked to perform a data integration project that 
transforms the OMOP data so that it can be loaded into a reporting database used by a
 quality improvement organization.  The requirements for the data retrieval and 
 transformation are as follows:  
 
 The organization wants to look at a small sample 
 of patients (for example a few hundred patients).  Thus, you only need to report on
 this sample of patients  
 
 Each patient should have different diseases—select patients
 that vary with respect to diseases as reported in the CONDITION_OCCURRENCE table o

 The organization requires the submission of data from at least 15 columns for the 
 sample of patients.  To meet this requirement, you must choose at least 15 columns 
 that come from at least 3 tables in the OMOP database. 
 
 Finally, the client database 
 has specific requirements that differ from the structure of the current OMOP data. 
 You must transform most the fields that you selected—how you do this is your choice. 
  
 
 For example, as you did in the first two assignments, you can re-code the gender field. 
 In addition, the date fields can be transformed into different formats for displaying 
 the dates or you can simply extract the year.  
 
 In sum, I leave it up to you to imagine
 what requirements have been defined.  
 My objective is to give you more practice transforming data using SQL. 
 
 */
 
 
 
---------------------------------------------------------------------------------
  
  -- Final Project.  Example for Part 1 

---------------------------------------------------------------------------------
-- STEP 1.  Find patients with a variety of conditions .. 

---------------------------------------------------------------------------------

CREATE TABLE PATIENT_CONDITION
   (
      PERSON_ID INTEGER,
	  condition_occurrence_id INTEGER,
	  condition_concept_id INTEGER,
	  condition_start_date DATE
   );
  ------------------------------------------------------------------------------------------

   -- FIRST GET A SAMPLE OF PATIENTS WITH A VARIETY OF DISEASE FROM CONDITION_OCCURRENCE 
     -- WHEN YOU RUN THIS, YOU WILL NOT SEE OUTPUT IN YOUR QUERY BOX... THE OUTPUT GOES INTO TABLE 
    
    INSERT INTO 
     PATIENT_CONDITION
	SELECT person_id ,
	       condition_occurrence_id,
	       condition_concept_id , 
	       condition_start_date
       FROM CONDITION_OCCURRENCE 
	   LIMIT   2000 ;    -- JUST FIND A  SAMPLE.. 
  
  --------------------------------------------------------------------------------------------

     -- TO SEE THE DATA, SELECT THE ROWS 
	 
	  SELECT * FROM PATIENT_CONDITION;
  
   
  -------------------------------------------------------------------------------------------- 
      -- OK, NOW SEE WHAT THESE CONDITIONS ARE BY JOINING IN THE CONCEPT LABELS .
	
	SELECT C.*,  CC.concept_name
	   FROM PATIENT_CONDITION   C
	      LEFT JOIN CONCEPT CC 
		     ON CC.concept_id = C.condition_concept_id
	     
----------------------------------------------------------------------------------------------------------			
  -- STEP 2. LOOK FOR PROCEDURES ... 
-----------------------------------------------------------------------------------------------------------

  -- FIRST TAKE A LOOK AT SOME POSSIBLE PROCEDURES SO YOU KNOW WHAT COLUMNS YOU MIGHT BE INTERESTED IN
  SELECT * FROM procedure_occurrence	 
	    LIMIT 10000

-------------------------------------------------------------------------------------------

--DROP TABLE PATIENT_PROCEDURES 
CREATE TABLE PATIENT_PROCEDURES 
(
   PERSON_ID INTEGER,
   procedure_occurrence_id INTEGER
   
);
---------------------------------------------------------------------------------------------------

INSERT INTO PATIENT_PROCEDURES
SELECT PERSON_ID,
       procedure_occurrence_id
FROM PROCEDURE_occurrence
WHERE PERSON_id IN
(   SELECT DISTINCT person_id
      FROM PATIENT_CONDITION)   -- HERE, WE INCLUDE ALL PATINTS FROM CONDITION COHORT RUN ABOVE

	
----------------------------------------------------------------------------------------------------------			
  -- STEP 3. LOOK FOR DRUGS ... 
-----------------------------------------------------------------------------------------------------------
	

CREATE TABLE PATIENT_DRUGS
(
   PERSON_ID INTEGER,
   drug_exposure_id INTEGER
   
);
---------------------------------------------------------------------------------------------------

INSERT INTO PATIENT_DRUGS
SELECT PERSON_ID,
       drug_exposure_id
FROM drug_exposure
WHERE PERSON_id IN
(   SELECT DISTINCT person_id
      FROM PATIENT_CONDITION)   -- HERE, WE INCLUDE ALL PATINTS FROM CONDITION COHORT RUN ABOVE


  -- SELECT * FROM PATIENT_DRUGS;


 ----------------------------------------------------------------------------------------------------------			
  -- STEP 4.   NOW, BE CREATIVE AND ADD COLUMNS 
-----------------------------------------------------------------------------------------------------------
	
	-- YOU CAN ADD IN MORE FIELDS HERE. 
	
	--  MAYBE ADD IN DRUGS USING SIMILAR FORMAT .. I LEAVE THAT UP TO YOU!
 
	SELECT p.*,
	       Z.concept_name,
	       cc.condition_status_source_value
	  FROM PATIENT_CONDITION P 
	    LEFT JOIN CONDITION_OCCURRENCE CC
		   ON P.condition_occurrence_id = CC.condition_occurrence_id
	    LEFT JOIN CONCEPT Z
		     ON CC.condition_concept_id = Z.concept_id
	     
	
 ----------------------------------------------------------------------------------------------------------			
  -- STEP 5.  ABOVE, THE ALGORITHM INCLUDES DATA.   ADD SOME EXCLUSION RULES  
-----------------------------------------------------------------------------------------------------------
	
    SELECT p.*,
	       PP.gender_concept_id,
	       Z.concept_name,
	       cc.condition_status_source_value
	  FROM PATIENT_CONDITION P 
	     INNER JOIN PERSON PP
		   ON P.PERSON_ID = PP.PERSON_ID 
	    LEFT JOIN CONDITION_OCCURRENCE CC
		   ON P.condition_occurrence_id = CC.condition_occurrence_id
	    LEFT JOIN CONCEPT Z
		     ON CC.condition_concept_id = Z.concept_id
	     
		 
		--RULE 1 
		    WHERE PP.GENDER_CONCEPT_ID = 8507;
	
	      -- YOU COULD ADD MORE STATEMENTS TO WHERE CLAUSE...
 
 
 
 
 
 
 
 