
 -- Assignment 3 


---  Terminologies and Concepts
 
 /*

     Note:  for this course, I have only loaded two tables related to terminologies:  concept and concept_relationship.  
     
     Although you might find queries in various respositories that use the concept_ancestor table, I decided not to use this table. 
     
     It has over 120 million rows, and often causes crashes 

 */
 

   USE OMOP_TEST;


 -- Take look at some of the data in the tables 

   SELECT *
    FROM concept;
   
  
   
  -- search all the concepts that are ICD-9 
  SELECT *
    FROM concept 
    where  vocabulary_id = 'ICD9CM';
   
   
  -- Look at RxNorm codes (drugs)
    SELECT *
    FROM concept 
    where  vocabulary_id = 'RXNORM'
   
   
  
   -- look for hypertension only among ICD 9 and 10 
   select * 
     from concept 
       where concept_name like '%hypertension%'
             and vocabulary_id in ( 'ICD9CM',  'ICD10CM')  ;        
   
     
                   
    -- look at codes by vocabulary for a specific condition 
    select  
       domain_id,
       vocabulary_id,
       count(*)
     from concept 
       where concept_name like '%hypertension%'    
      group by    
       domain_id,
      vocabulary_id;
             
      
            
--- EXPLORE RELATIONSHIPS   
   
   select *
    from concept_relationship ;
   


   SELECT *
    FROM concept_relationship
       WHERE concept_id_1 = 313217;

	
-- CHECK relationship

SELECT
cr.relationship_id,
c.*
FROM concept_relationship  cr
JOIN concept  c
  ON  cr.concept_id_2  =  c.concept_id
   WHERE  cr.concept_id_1  =  313217;   
      
   
----------------------------------------------------------------------------------------------
 
 -- CONCEPT TABLE  Summary of Concepts using a group by query 
 
SELECT 
     DOMAIN_ID,
     VOCABULARY_ID,
     CONCEPT_CLASS_ID,
     COUNT(*) as CNT
     FROM concept
     GROUP BY 
        DOMAIN_ID,
        VOCABULARY_ID,
        CONCEPT_CLASS_ID    
     ORDER BY DOMAIN_ID;
     
    
------------------------------------------------------------------------------------------------------------------------------
                      --- Look at concepts that are actually used in our OMOP tables 
------------------------------------------------------------------------------------------------------------------------------ 
    

  -- conditions
   SELECT c.vocabulary_id ,
          c.concept_code ,
          c.concept_name ,
          count(*)
     FROM condition_occurrence co  
       inner join concept c 
         on co.condition_concept_id  = c.concept_id 
     group by 
          c.vocabulary_id ,
          c.concept_code ,
          c.concept_name ;     
    
         
         
  -- procedures      
       SELECT 
          c.vocabulary_id ,
          c.concept_code ,
          c.concept_name ,
          count(*)
     FROM procedure_occurrence po
        inner join concept c
            on po.procedure_concept_id  = c.concept_id 
     group by 
          c.vocabulary_id ,          
          c.concept_code ,
          c.concept_name ;     
        
         
      -- you can use the pattern above to look at the concepts in measurement and observation?
         
         
       
 ------------------------------------------------------------------------------------------------------------------------------
                      --- OHDSI QUERY LIBRARY 
------------------------------------------------------------------------------------------------------------------------------

/*
G01: Find concept by concept ID
Description
This is the most generic look-up for obtaining concept details associated with a concept identifier.
 The query is intended as a tool for quick reference for the name, class, level and source vocabulary 
 details associated with a concept identifier.

 */


SELECT
  c.concept_id,
  c.concept_name,
  c.concept_code,
  c.concept_class_id,
  c.standard_concept,
  c.vocabulary_id
FROM concept AS c
WHERE c.concept_id = 192671
;
 
 /*
 G02: Find a concept by code from a source vocabulary
This query obtains the concept details associated with a concept code, such as name, class, 
level and source vocabulary.

Only concepts from the Standard Vocabularies can be searched using this query. If you want to
 translate codes from other Source Vocabularies to Standard Vocabularies use G06 query.

The following is a sample run of the query to extract details for concept code of ‘74474003’ 
from concept vocabulary ID of ‘SNOMED’. Note that in contrast to concept ID the concept
 codes are not unique across different vocabularies. If you don’t specify the vocabulary, you might
 get results for the same code in different vocabularies.
 */

    
SELECT
  c.concept_id,
  c.concept_name,
  c.concept_code,
  c.concept_class_id,
  c.vocabulary_id
FROM concept AS c
WHERE 
 c.concept_code = '74474003' AND
  c.vocabulary_id = 'SNOMED' 

;
 

 /*
G05: Translate a code from a source to a standard vocabulary.
Description
This query enables search of all Standard Vocabulary concepts that are mapped to a code
 from a specified source vocabulary. It will return all possible concepts that are mapped
 to it, as well as the target vocabulary. The source code could be obtained using queries
 G02 or G03. Note that to unambiguously identify a source code, the vocabulary id has to 
 be provided, as source codes are not unique identifiers across different vocabularies.
 */

 

SELECT DISTINCT
  c1.domain_id        AS source_domain_id,
  c2.concept_id       AS concept_id,
  c2.concept_name     AS concept_name,
  c2.concept_code     AS concept_code,
  c2.concept_class_id AS concept_class_id,
  c2.vocabulary_id    AS concept_vocabulary_id,
  c2.domain_id        AS concept_domain_id
FROM concept_relationship AS cr
  JOIN concept AS c1 ON c1.concept_id = cr.concept_id_1
  JOIN concept AS c2 ON c2.concept_id = cr.concept_id_2
WHERE
  cr.relationship_id = 'Maps to' AND
  c1.concept_code IN ('070.0') AND
  c1.vocabulary_id = 'ICD9CM' 

;
 
 
-----------------------------------------------------------------------------------------------
            -- Conditions 
-----------------------------------------------------------------------------------------------
 
/*
C01: Find condition by concept ID
Description
Find condition by condition ID is the lookup for obtaining condition or disease concept details 
associated with a concept identifier. This query is a tool for quick reference for the name, class, 
level and source vocabulary details associated with a concept identifier, either SNOMED-CT clinical 
finding or MedDRA. This query is equivalent to G01, but if the concept is not in the condition domain
 the query still returns the concept details with the Is_Disease_Concept_Flag field set to ‘No’.

The following is a sample run of the query to run a search for specific disease concept ID.
*/

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
  c.concept_id = 192671

;
 
 
------------------------------------------------------------------------------------------------------------------------------
                      --- Some additional examples to help you learn how to query the tables 
------------------------------------------------------------------------------------------------------------------------------


SELECT * 
   FROM  concept WHERE concept_id = 313217;



  
-- G15: Statistic about Concepts, Vocabularies, Classes and Levels
-- This query generates the list of all vocabularies in the CONCEPT table (Standard and non-standard), their class, level and frequency.



    SELECT

      voc.vocabulary_id,
      r.vocabulary_name,
      voc.concept_class_id,
      voc.standard_concept,
      voc.cnt

    FROM (

      SELECT

        vocabulary_id,
        concept_class_id,
        standard_concept,
        COUNT(concept_id) cnt

      FROM concept

      GROUP BY
        vocabulary_id,
        concept_class_id,
        standard_concept ) voc

    JOIN vocabulary r ON voc.vocabulary_id=r.vocabulary_ID

    ORDER BY 1,2,4,3; 
   
   
   