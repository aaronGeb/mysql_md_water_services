SET SQL_SAFE_UPDATES = 0;

USE md_water_services;
/*
1. Get to know our data:
Start by retrieving the first few records from each table.
 * How many tables are there in our database? 
 * What are the names of these tables? Once you've identified the tables, 
 write a SELECT statement to retrieve the first five records from each table. 
 As you look at the data, take note of the columns and their respective data types in each table. 
 What information does each table contain?
*/
SHOW TABLES;
SELECT * FROM  employee LIMIT 5;
SELECT * FROM  global_water_access LIMIT 5;
SELECT * FROM  location  LIMIT 5;
SELECT * FROM  visits LIMIT 5;
SELECT * FROM  water_quality LIMIT 5;
SELECT * FROM  water_source LIMIT 5; 
SELECT * FROM  well_pollution LIMIT 5;
-- SELECT * FROM  data_dictionary;

/*
2. Dive into the water sources:
 Now that you're familiar with the structure of the tables, let's dive deeper.
 We need to understand the types of water sources we're dealing with.
 Can you figure out which table contains this information?
*/
SELECT DISTINCT type_of_water_source  FROM  water_source ;
/*
3. Unpack the visits to water sources:
   We have a table in our database that logs the visits made to different water sources.
   Can you identify this table?
*/
SELECT * FROM visits WHERE time_in_queue >500;
SELECT source_id, type_of_water_source,number_of_people_served
FROM water_source
GROUP BY source_id,number_of_people_served,type_of_water_source;    
/*
4. Assess the quality of water sources:
The quality of our water sources is the whole point of this survey.
We have a table that contains a quality score for each visit made about a water source that was assigned by a Field surveyor.
They assigned a score to each source from 1, being terrible, to 10 for a good, clean water source in a home.
Shared taps are not rated as high, and the score also depends on how long the queue times are.
Look through the table record to find the table.
*/
SELECT  subjective_quality_score,visit_count FROM  water_quality
WHERE subjective_quality_score =10 AND visit_count =1

/*
5. Investigate pollution issues:
Did you notice that we recorded contamination/pollution data for all of the well sources?
 Find the right table and print the first few rows.
*/;
 
 
SELECT * FROM well_pollution
LIMIT 5;
SELECT DISTINCT description FROM well_pollution
ORDER BY description;
/*
Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
*/
UPDATE  well_pollution
SET description = "Bacteria: E. coli"
WHERE description = "Clean Bacteria: E. coli";
/*
Update the descriptions that mistakenly mention
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
*/
UPDATE  well_pollution
SET description = "Bacteria: Giardia Lamblia"
WHERE description = "Clean Bacteria: Giardia Lamblia";
/*
Update the `result` to `Contaminated: Biological` where
`biological`  is greater than 0.01 plus current results is `Clean`
*/
UPDATE  well_pollution
SET results = "Contaminated: Biological"
WHERE  biological >0.01 AND results = "clean";
-- Check if our errors are fixed using a SELECT query on the well_pollution_copy table:
SELECT
*
FROM
    well_pollution
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

-- Q1.
SELECT address FROM employee 
WHERE employee_name =  "Bello Azibo";
-- Q2.
SELECT * FROM employee 
WHERE position = "Micro biologist";
-- Q3.
SELECT source_id,number_of_people_served FROM water_source
ORDER BY number_of_people_served DESC
limit 3;
-- Q4.
SELECT * FROM global_water_access
WHERE name = "Maji Ndogo";
-- Q5.
SELECT *
FROM employee
WHERE position = 'Civil Engineer' AND (province_name = 'Dahabu' OR
address LIKE '%Avenue%');
			  
-- Q6.
SELECT *
FROM employee
Where position = "Field Surveyor"
        AND (phone_number LIKE '%86%' OR "%11%")
	    AND (employee_name LIKE "%A%" OR "%M%");

-- Q7
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean %' OR results = 'Clean' AND biological < 0.01;

-- Q10.
SELECT *
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);


WITH town_totals AS (

SELECT 
    province_name,
    town_name,
    SUM(number_of_people_served) AS total_ppl_serv
FROM 
    combined_analysis_table
GROUP BY 
    province_name,
    town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(CASE WHEN type_of_water_source = 'river' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
    ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(CASE WHEN type_of_water_source = 'well' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN 
    town_totals tt ON ct.province_name = tt.province_name
    AND ct.town_name = tt.town_name
WHERE ct.province_name = 'Amanzi'
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;



WITH town_totals AS (

SELECT
    province_name,
    town_name,
    SUM(number_of_people_served) AS total_ppl_serv
FROM
    combined_analysis_table
GROUP BY
    province_name,
    town_name
)
SELECT
    ct.province_name,
    ct.town_name,
    ROUND((SUM(IF(type_of_water_source = 'river', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0)  AS river,
    ROUND((SUM(IF(type_of_water_source = 'shared_tap', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
    ROUND((SUM(IF(type_of_water_source = 'tap_in_home', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
    ROUND((SUM(IF(type_of_water_source = 'tap_in_home_broken', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
    ROUND((SUM(IF(type_of_water_source = 'well', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0) AS well,
    (ROUND((SUM(IF(type_of_water_source = 'tap_in_home', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0) + ROUND((SUM(IF(type_of_water_source = 'tap_in_home_broken', number_of_people_served, 0)) * 100.0 / tt.total_ppl_serv), 0)) as my_sum
FROM
    combined_analysis_table ct
JOIN
    town_totals tt ON ct.province_name = tt.province_name
    AND ct.town_name = tt.town_name
GROUP BY
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;