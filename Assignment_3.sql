
 -- Assignment 3 


---  Terminologies and Concepts
 
 /*
  •	First, run the example queries that use the following terminology tables:
o	CONCEPT
o	CONCEPT_RELATIONSHIP
o	CONCEPT_ANCESTOR.  
        Note that this table is very large, and queries can take a long time!   I have added indexes, but even with these, some queries can take time
•	Create at least 3 queries that selects specific types of a domain or vocabulary 
o	You can use some of the queries provided as examples. 
•	Look at the CONCEPT_RELATIONSHIP table. Pick a terminology domain that you are interested in, and explain how the data is structured to map local codes to standard codes  
•	Write a query to look at LOINC codes.  
•	Write a query to look only at RxNorm drug codes 

 */
 
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
  c.vocabulary_id = 'SNOMED' AND
  c.invalid_reason IS NULL
;
 
/*
 G04: Find synonyms for a given concept
Description
This query extracts all synonyms in the vocabulary for a given Concept ID.
*/

SELECT
  c.concept_id,
  s.concept_synonym_name
FROM concept AS c
  JOIN concept_synonym AS s ON c.concept_id = s.concept_id
WHERE c.concept_id = 192671
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

   -- runs way too slooooooooooooooow!
 
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
  c1.vocabulary_id = 'ICD9CM' AND
  cr.invalid_reason IS NULL
;
 
 
/*
G08: Find ancestors for a given concept
Description
For a concept identifier entered as the input parameter, this query lists all ancestors 
in the hierarchy of the domain. Ancestors are concepts that have a relationship to the 
given concept and is defined as hierarchical in the relationship table, and any secondary,
 tertiary etc. concepts going up in the hierarchy. The resulting output provides the ancestor
 concept details and the minimum and maximum level of separation.
*/

SELECT
  c.concept_id               AS ancestor_concept_id,
  c.concept_name             AS ancestor_concept_name,
  c.concept_code             AS ancestor_concept_code,
  c.concept_class_id         AS ancestor_concept_class_id,
  c.vocabulary_id            AS vocabulary_id,
  a.min_levels_of_separation AS min_separation,
  a.max_levels_of_separation AS max_separation
FROM concept_ancestor AS a
  JOIN concept AS c 
  ON a.ancestor_concept_id = c.concept_id
WHERE 
  a.ancestor_concept_id != a.descendant_concept_id AND 
  a.descendant_concept_id = 192671 AND
  c.invalid_reason IS NULL
ORDER BY vocabulary_id, min_separation
;
 

 /*
 G09: Find descendants for a given concept
Description
For a concept identifier entered as the input parameter, this query lists all descendants in the
 hierarchy of the domain. Descendant are concepts have a relationship to the given concept that is
 defined as hierarchical in the relationship table, and any secondary, tertiary etc. concepts going
 down in the hierarchy. The resulting output provides the descendant concept details and the minimum 
 and maximum level of separation.
*/

SELECT
  c.concept_id               AS descendant_concept_id,
  c.concept_name             AS descendant_concept_name,
  c.concept_code             AS descendant_concept_code,
  c.concept_class_id         AS descendant_concept_class_id,
  c.vocabulary_id            AS vocabulary_id,
  a.min_levels_of_separation AS min_separation,
  a.max_levels_of_separation AS max_separation
FROM concept_ancestor AS a
  JOIN concept AS c 
     ON a.descendant_concept_id = c.concept_id
WHERE 
  a.ancestor_concept_id != a.descendant_concept_id AND 
  a.ancestor_concept_id = 192671 AND 
  c.invalid_reason IS NULL
ORDER BY vocabulary_id, min_separation
;
 

 /*
 
 
G10: Find parents for a given concept
This query accepts a concept ID as the input and returns all concepts that are its immediate
 parents of that concept. Parents are concepts that have a hierarchical relationship to the 
 given concepts. Hierarchical relationships are defined in the relationship table. The query 
 returns only the immediate parent concepts that are directly linked to the input concept and 
 not all ancestors.
*/

SELECT
  a.concept_id       AS parent_concept_id,
  a.concept_name     AS parent_concept_name,
  a.concept_code     AS parent_concept_code,
  a.concept_class_id AS parent_concept_class_id,
  a.vocabulary_id    AS parent_concept_vocab_id
FROM concept_ancestor ca
  JOIN concept a 
     ON ca.ancestor_concept_id = a.concept_id
  JOIN concept d 
     ON ca.descendant_concept_id = d.concept_id
WHERE 
  ca.min_levels_of_separation = 1 AND
  ca.descendant_concept_id = 192671 AND
  a.invalid_reason IS NULL
;
 
 /*

G11: Find children for a given concept
Description
This query lists all standard vocabulary concepts that are child concepts of a given concept entered
 as input. The query accepts a concept ID as the input and returns all concepts that are its immediate 
 child concepts.

The query returns only the immediate child concepts that are directly linked to the input concept and not 
all descendants.
*/

SELECT
  d.concept_id       AS child_concept_id,
  d.concept_name     AS child_concept_name,
  d.concept_code     AS child_concept_code,
  d.concept_class_id AS child_concept_class_id,
  d.vocabulary_id    AS child_concept_vocab_id
FROM concept_ancestor AS ca
  JOIN concept AS d ON ca.descendant_concept_id = d.concept_id
WHERE
  ca.min_levels_of_separation = 1 AND
  ca.ancestor_concept_id = 192671 AND
  d.invalid_reason IS NULL
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
  c.concept_id = 192671 AND 
  c.invalid_reason IS NULL
;
 
 
 ----------------------------------------------------------------------------------------------
 
 -- CONCEPT TABLE  Summary of Concepts (Runs slow! took 7 minutes to run!!!!!!!!!!!!!!!!  )
 
SELECT 
     DOMAIN_ID,
     VOCABULARY_ID,
     CONCEPT_CLASS_ID,
     COUNT(*) as CNT
     FROM CONCEPT
     GROUP BY 
        DOMAIN_ID,
        VOCABULARY_ID,
        CONCEPT_CLASS_ID    
     ORDER BY DOMAIN_ID;
     

	 
	
--- Look at concept ancestors 

SELECT max_levels_of_separation, concept.*
FROM concept_ancestor
JOIN concept ON ancestor_concept_id = concept_id
WHERE descendant_concept_id = 313217 /* Atrial fibrillation */
ORDER BY max_levels_of_separation


------------------------------------------------------------------------------------------------------------------------------
                      --- LOOK AT USE CASES FROM OMOP VOCAB GUIDE  
------------------------------------------------------------------------------------------------------------------------------


SELECT * 
   FROM  concept WHERE concept_id = 313217;


--- EXPLORE RELATIONSHIPS

SELECT *
FROM concept_relationship
    WHERE concept_id_1 = 313217;

	
-- CHECK ANCESTORS.

SELECT
cr.relationship_id,
c.*
FROM concept_relationship  cr

JOIN concept  c
  ON  cr.concept_id_2  =  c.concept_id
   WHERE  cr.concept_id_1  =  313217;


SELECT max_levels_of_separation, 
       concept.*
    FROM concept_ancestor
JOIN concept ON ancestor_concept_id = concept_id
WHERE descendant_concept_id = 313217 /* Atrial fibrillation */
ORDER BY max_levels_of_separation


-- EXPLORE DECENDENTS 

SELECT max_levels_of_separation, concept.*
FROM concept_ancestor
JOIN concept ON descendant_concept_id = concept_id
WHERE ancestor_concept_id = 44784217 /* cardiac arrythmia */
ORDER BY max_levels_of_separation


--Going up the hierarchy: Finding the right concept

SELECT
max_levels_of_separation,
concept.*
FROM concept_ancestor
JOIN concept
ON ancestor_concept_id = concept_id
WHERE descendant_concept_id = 4332645
/*
Upper gastrointestinal hemorrhage associated...*/
ORDER
BY
max_levels_of_separation

-- GOING DOWN THE HIERACHY 

SELECT
max_levels_of_separation,
concept.*
FROM concept_ancestor
JOIN concept
    ON descendant_concept_id = concept_id
WHERE ancestor_concept_id = 4291649
/*
Upper gastrointestinal hemorrhage
*/
ORDER BY max_levels_of_separation;

  
 ------------------------------------------------------------------------------------------------------
       -- DRUG QUERIES 
 
 --Find active compound Warfarin by keyword  (runs fast)
SELECT * 
  FROM concept WHERE concept_name = 'Warfarin';
 
--Find drug product containing Clopidogrel by NDC code:   (runs fast)
    -- Bristol Meyer Squibb's Plavix 75mg capsules: NDC 67544050474
	
SELECT * FROM concept 
   WHERE concept_code='67544050474';
   
SELECT * 
  FROM concept_relationship WHERE concept_id_1=45867731 and relationship_id='Maps to';

SELECT * 
  FROM concept WHERE concept_id=1322185;
 
-- Find ingredient Clopidogrel as Ancestor of drug product

SELECT a.max_levels_of_separation, 
       ancestor.*
FROM concept_ancestor a, concept ancestor
WHERE a.descendant_concept_id = 1322185 /* clopidogrel 75 MG Oral Tablet [Plavix] */
AND a.ancestor_concept_id = ancestor.concept_id
ORDER BY max_levels_of_separation;
 
 -- Check Descendants (other drug products containing Warfarin and Dabigatran)
 
 SELECT max_levels_of_separation, descendant.*
FROM concept_ancestor a, concept descendant
WHERE a.ancestor_concept_id = 1310149 /* Warfarin or 1322185 Clopidogrel*/
AND a.descendant_concept_id = descendant.concept_id
ORDER BY max_levels_of_separation;
 
 
 
 
 ------------------------------------------------------------------------------------------------------
       -- OHDSI DRUG QUERIES 

/*	   
D01: Find drug concept by concept ID
Description
This is the lookup for obtaining drug concept details associated with a concept identifier. 
This query is intended as a tool for quick reference for the name, class, level and source 
vocabulary details associated with a concept identifier. This query is equivalent to G01, 
but if the concept is not in the drug domain the query still returns the concept details
 with the Is_Drug_Concept_Flag field set to ‘No’.
*/
	
	  SELECT 
    c.concept_id AS drug_concept_id,
    c.concept_name AS drug_concept_name,
    c.concept_code AS drug_concept_code,
    c.concept_class_id AS drug_concept_class,
    c.standard_concept AS drug_standard_concept,
    c.vocabulary_id AS drug_concept_vocab_id,
    (CASE c.domain_id WHEN 'Drug' THEN 'Yes' ELSE 'No' END) AS is_drug_concept_flag
FROM concept AS c
WHERE date('now') >= c.valid_start_date AND date('now') <= c.valid_end_date 
  AND c.concept_id = 1545999
;

/*
D02: Find drug or class by keyword   (runs very slow!   Edit query )
Description
This query enables search of vocabulary entities in the drug domain by keyword. 
The query does a search of standard concepts names in the DRUG domain including the following:

	RxNorm standard drug concepts
	ETC, ATC therapeutic classes
	NDF-RT mechanism of action, physiological effect, chemical structure concepts
	Synonyms of drug concepts
	Mapped drug codes from NDC, GPI, Multum, Multilex
*/

SELECT c.concept_id Entity_Concept_Id, 
        c.concept_name Entity_Name, 
		c.concept_code Entity_Code, 
		'Concept' Entity_Type, 
		c.concept_class_id Entity_concept_class_id, 
		c.vocabulary_id Entity_vocabulary_id
FROM concept c
WHERE c.concept_class_id IS NOT NULL
AND c.vocabulary_id in ('NDFRT','RxNorm','Indication','ETC','ATC','VA Class','GCN_SEQNO')
AND LOWER(REPLACE(REPLACE(c.concept_name, ' ', ''), '-', '')) LIKE 'lipitor'
AND date('now') >= c.valid_start_date
AND date('now') <= c.valid_end_date

UNION ALL

SELECT c.concept_id Entity_Concept_Id, c.concept_name Entity_Name, c.concept_code Entity_Code, 'Mapped Code' Entity_Type,
c.concept_class_id Entity_concept_class_id, c.vocabulary_id Entity_vocabulary_id
FROM concept_relationship cr 
  JOIN concept c ON c.concept_id = cr.concept_id_1
AND cr.relationship_id = 'Maps to'
AND c.vocabulary_id IN ('NDC', 'GPI', 'Multum', 'Multilex', 'VA Product', 'MeSH', 'SPL')
AND LOWER(REPLACE(REPLACE(c.concept_name, ' ', ''), '-', '')) LIKE 'lipitor'
AND date('now') >= c.valid_start_date
AND date('now') <= c.valid_end_date

UNION ALL

SELECT c.concept_id Entity_Concept_Id, s.concept_synonym_name Entity_Name, c.concept_code Entity_Code, 'Concept Synonym' Entity_Type, c.concept_class_id Entity_concept_class_id, c.vocabulary_id Entity_vocabulary_id
FROM concept c, concept_synonym s
WHERE S.concept_id = c.concept_id
AND c.vocabulary_id in ('NDFRT','RxNorm','Indication','ETC','ATC','VA Class','GCN_SEQNO')
AND c.concept_class_id IS NOT NULL
AND LOWER(REPLACE(REPLACE(s.concept_synonym_name, ' ', ''), '-', '')) LIKE 'lipitor'
AND date('now') >= c.valid_start_date
AND date('now') <= c.valid_end_date;

/*
D04: Find drugs by ingredient
Description
This query is designed to extract all drugs that contain a specified ingredient. 
The query accepts an ingredient concept ID as the input and returns all drugs that have the ingredient. 
It should be noted that the query returns both generics that have a single ingredient
 (i.e. the specified ingredient) and those that are combinations which include the specified ingredient.
 The query requires the ingredient concept ID as the input. A list of these ingredient concepts can be
 extracted by querying the concept table for concept class of ‘Ingredient’, e.g. using query D02.
*/

SELECT
        A.concept_id Ingredient_concept_id,
        A.concept_Name Ingredient_name,
        A.concept_Code Ingredient_concept_code,
        A.concept_Class_id Ingredient_concept_class,
        D.concept_id Drug_concept_id,
        D.concept_Name Drug_name,
        D.concept_Code Drug_concept_code,
        D.concept_Class_id Drug_concept_class
FROM
        concept_ancestor CA,
        concept A,
        concept D
WHERE
        CA.ancestor_concept_id = A.concept_id
        AND CA.descendant_concept_id = D.concept_id
        AND date('now') >= A.valid_start_date
        AND date('now') <= A.valid_end_date
        AND date('now') >= D.valid_start_date
        AND date('now') <= D.valid_end_date
        AND CA.ancestor_concept_id = 966991;

/*
D05: Find generic drugs by ingredient
Description
This query is designed to extract all generic drugs that have a specified ingredient. 
The query accepts an ingredient concept ID as the input and returns all generic (not branded) 
drugs that have the ingredient. It should be noted that the query returns both generics that have a 
single ingredient (i.e. the specified ingredient) and those that are combinations which include the
 specified ingredient. The query requires the ingredient concept ID as the input. A list of these 
 ingredient concepts can be extracted by querying the CONCEPT table for concept class of ‘Ingredient’
	*/	

	SELECT        A.concept_id Ingredient_concept_id,
                A.concept_Name Ingredient_name,
                A.concept_Code Ingredient_concept_code,
                A.concept_Class_id Ingredient_concept_class,
                D.concept_id Generic_concept_id,
                D.concept_Name Generic_name,
                D.concept_Code Generic_concept_code,
                D.concept_class_id Generic_concept_class
FROM        concept_ancestor CA,
                concept A,
                concept D
WHERE
           CA.ancestor_concept_id = 966991
AND        CA.ancestor_concept_id = A.concept_id
AND        CA.descendant_concept_id = D.concept_id
AND        D.concept_class_id = 'Clinical Drug'
AND        (date('now') >= A.valid_start_date)
AND        (date('now') <= A.valid_end_date)
AND        (date('now') >= D.valid_start_date)
AND        (date('now') <= D.valid_end_date)	

/*
D06: Find branded drugs by ingredient
Description
This query is designed to extract all branded drugs that have a specified ingredient. 
The query accepts an ingredient concept ID as the input and returns all branded drugs that have the ingredient.
 It should be noted that the query returns both generics that have a single ingredient 
 (i.e. the specified ingredient) and those that are combinations which include the specified ingredient. 
 The query requires the ingredient concept ID as the input. A list of these ingredient concepts can be 
 extracted by querying the CONCEPT table for concept class of ‘Ingredient’.
*/

SELECT        A.concept_id Ingredient_concept_id,
                A.concept_name Ingredient_concept_name,
                A.concept_code Ingredient_concept_code,
                A.concept_class_id Ingredient_concept_class,
                D.concept_id branded_drug_id,
                D.concept_name branded_drug_name,
                D.concept_code branded_drug_concept_code,
                D.concept_class_id branded_drug_concept_class
FROM           concept_ancestor CA,
               concept A,
               concept D
WHERE
        CA.ancestor_concept_id = 966991
AND        CA.ancestor_concept_id = A.concept_id
AND        CA.descendant_concept_id = D.concept_id
AND        D.concept_class_id = 'Branded Drug'
AND        (date('now') >= A.valid_start_date)
AND        (date('now') <= A.valid_end_date)
AND        (date('now') >= D.valid_start_date)
AND        (date('now') <= D.valid_end_date);


/*
D07: Find single ingredient drugs by ingredient
Description
This query accepts accepts an ingredient concept ID and returns all drugs which contain only one 
ingredient specified in the query. This query is useful when studying drug outcomes for ingredients
 where the outcome or drug-drug interaction effect of other ingredients needs to be avoided.
*/

 -- slow.  takes about 2 min to run

SELECT
      c.concept_id       AS drug_concept_id,
      c.concept_name     AS drug_concept_name,
      c.concept_class_id AS drug_concept_class_id
FROM concept c
INNER JOIN (
  SELECT drug.cid FROM (
    SELECT a.descendant_concept_id cid, count(*) cnt FROM concept_ancestor a
    INNER JOIN (
      SELECT c.concept_id FROM concept c, concept_ancestor a
      WHERE a.ancestor_concept_id = 1000560
      AND a.descendant_concept_id = c.concept_id AND c.domain_id = 'Drug'
    ) cd ON cd.concept_id = a.descendant_concept_id
    INNER JOIN concept c 
	      ON c.concept_id=a.ancestor_concept_id
        WHERE c.concept_class_id = 'Ingredient'
    GROUP BY a.descendant_concept_id
  ) drug WHERE drug.cnt = 1  -- contains only 1 ingredient
) onesie ON onesie.cid = c.concept_id
WHERE (date('now') >= valid_start_date) AND (date('now') <= valid_end_date)
;

/*
D08: Find drug classes for a drug or ingredient
Description
This query is designed to return the therapeutic classes that associated with a drug. 
The query accepts a standard drug concept ID (e.g. as identified from query G03) as the input. 
The drug concept can be a clinical or branded drug or pack (concept_level=1), or an ingredient (concept_level=2).
 The query returns one or more therapeutic classes associated with the drug based on the following classifications.).
 
Enhanced Therapeutic Classification (ETC)
Anatomical Therapeutic Chemical classification (ATC)
NDF-RT Mechanism of Action (MoA)
NDF-RT Physiologic effect
NDF-RT Chemical structure
VA Class
By default, the query returns therapeutic classes based on all the classification systems listed above. 
Additional clauses can be added to restrict the query to a single classification system.
*/

SELECT
 c1.concept_id                 Class_Concept_Id,
 c1.concept_name               Class_Name,
 c1.concept_code               Class_Code,
 c1.concept_class_id              Classification,
 c1.vocabulary_id              Class_vocabulary_id,
 v1.vocabulary_name            Class_vocabulary_name,
 ca.min_levels_of_separation  Levels_of_Separation
FROM concept_ancestor       ca,
     concept                c1,
      vocabulary            v1
WHERE
ca.ancestor_concept_id = c1.concept_id
AND    c1.vocabulary_id IN ('NDFRT', 'ETC', 'ATC', 'VA Class')
AND    c1.concept_class_id IN ('ATC','VA Class','Mechanism of Action','Chemical Structure','ETC','Physiologic Effect')
AND    c1.vocabulary_id = v1.vocabulary_id
AND    ca.descendant_concept_id = 1545999
AND    (date('now') >= c1.valid_start_date) AND (date('now') <= c1.valid_end_date);

/*
D09: Find drugs by drug class
Description
This query is designed to extract all drugs that belong to a therapeutic class. 
The query accepts a therapeutic class concept ID as the input and returns all drugs that are
 included under that class . Therapeutic classes could be obtained using query D02 and are 
 derived from one of the following:

Enhanced Therapeutic Classification (FDB ETC)
Anatomical Therapeutic Chemical classification (WHO ATC)
– NDF-RT Mechanism of Action (MoA), Concept Class = ‘Mechanism of Action’

– NDF-RT Physiologic effect (PE), Concept Class = ‘Physiologic Effect’

– NDF-RT Chemical Structure, Concept Class = ‘Chemical Structure’

VA Class

*/

SELECT  c.concept_id       AS drug_concept_id,
        c.concept_name     AS drug_concept_name,
        c.concept_class_id AS drug_concept_class,
        c.concept_code     AS drug_concept_code
FROM concept AS c
  JOIN concept_ancestor AS ca
    ON c.concept_id = ca.descendant_concept_id
WHERE ca.ancestor_concept_id = 966991
      AND c.domain_id = 'Drug'
      AND c.standard_concept = 'S'
      AND date('now') >= c.valid_start_date
      AND date('now') <= c.valid_end_date
;

/*

D10: Find ingredient by drug class
Description
This query is designed to extract all ingredients that belong to a therapeutic class. 
The query accepts a therapeutic class concept ID as the input and returns all drugs that 
are included under that class. Therapeutic classes could be obtained using query D02 and are
 derived from one of the following:

Enhanced Therapeutic Classification (FDB ETC)
Anatomical Therapeutic Chemical classification (WHO ATC)
– NDF-RT Mechanism of Action (MoA), Concept Class = ‘Mechanism of Action’

– NDF-RT Physiologic effect (PE), Concept Class = ‘Physiologic Effect’

– NDF-RT Chemical Structure, Concept Class = ‘Chemical Structure’

VA Class
*/

SELECT  c.concept_id    ingredient_concept_id,
        c.concept_name  ingredient_concept_name,
        c.concept_class_id ingredient_concept_class,
        c.concept_code  ingredient_concept_code
 FROM   concept          c,
        concept_ancestor ca
 WHERE  ca.ancestor_concept_id = 966991
   AND  c.concept_id           = ca.descendant_concept_id
   AND  c.vocabulary_id        = 'RxNorm'
   AND  c.concept_class_id     = 'Ingredient'
   AND  (date('now') >= c.valid_start_date)
   AND  (date('now') <= c.valid_end_date);


---------------------------------------------------------------------------------------------
      -- Procedures  
---------------------------------------------------------------------------------------------
   
/*
 P02: Find a procedure from a keyword.
Description
This query enables search of procedure domain of the vocabulary by keyword.
 The query does a search of standard concepts names in the PROCEDURE domain (SNOMED-CT, ICD9,
 CPT, SNOMED Veterinary, OPCS4, CDT ICD10PCS and HCPCS procedures) and their synonyms to return 
 all related concepts.

This is a comprehensive query to find relevant terms in the vocabulary. It does not require prior
 knowledge of where in the logic of the vocabularies the entity is situated. To constrain, additional 
 clauses can be added to the query. However, it is recommended to do a filtering after the result set is produced to avoid syntactical mistakes. The query only returns concepts that are part of the Standard Vocabulary, ie. they have concept level that is not 0. If all concepts are needed, including the non-standard ones, the clause in the query restricting the concept level and concept class can be commented out.

The following is a sample run of the query to run a search of the Procedure domain for keyword 
‘Fixation of fracture’.
*/

   --- TAKES A LONG TIME!    NEED TO CHANGE FILTER 

SELECT DISTINCT
  C.concept_id            AS Entity_Concept_Id,
  C.concept_name          AS Entity_Name,
  C.concept_code          AS Entity_Code,
  'Concept'               AS Entity_Type,
  C.concept_class_id      AS Entity_concept_class_id,
  C.vocabulary_id         AS Entity_vocabulary_id
FROM concept C
LEFT JOIN concept_synonym S
ON C.concept_id = S.concept_id
WHERE C.vocabulary_id IN ('SNOMED','ICD9Proc','ICD10PCS','CPT4','CDT','HCPCS','SNOMED Veterinary','OPCS4')
      AND C.domain_id = 'Procedure'
      AND C.standard_concept = 'S'
      -- regular expression containing the input pattern
      AND LOWER(C.concept_name) LIKE LOWER('%Fixation of fracture%')
            OR LOWER(S.concept_synonym_name) LIKE LOWER('%Fixation of fracture%')
      -- Retrieve only valid concepts
      AND  date('now') >= C.valid_start_date AND date('now') <= C.valid_end_date; 
   
   
   
   
   
   