USE laptop;
-----------------------------------
-- CREATE BACKUP FOR DATASET 
-----------------------------------

CREATE TABLE laptop_backup 
LIKE laptop_data;

INSERT INTO laptop_backup 
SELECT * FROM laptop_data;

SELECT * FROM laptop_backup;                                                -- BACKUP CREATED                      




----------------------------------
-- LOOK INFORMATION OF DATA SET 
----------------------------------

SELECT * FROM information_schema.TABLES                                    -- DATA LENGTH (SIZE) = 272 KB
WHERE TABLE_SCHEMA = 'practice' AND TABLE_NAME = 'laptop_data';  

SELECT COUNT(*)                                                            -- 1303 ROWS LEFT
FROM laptop_data;




-------------------------------------------------------
-- DELETE AND CHANGE COLUMN NAME OF UNDESIRED COLUMNS
--------------------------------------------------------

ALTER TABLE laptop_data 
DROP COLUMN `Unnamed: 0`;

ALTER TABLE laptop_data
RENAME COLUMN `index`TO sr_no ;




-------------------------------------------------------------
-- DELETE ALL ROWS WHERE ALL COLUMNS CONTAINS NULL VALUES
-------------------------------------------------------------

SELECT COUNT(*) FROM laptop_data                                           -- THERE ARE 30 ROWS WHERE ALL COLUMN CONTAINS NULL VALUES
WHERE sr_no IN (
		SELECT sr_no 
		FROM laptop_data
		WHERE Company IS NULL 
			AND TypeName IS NULL
			AND Inches IS NULL
			AND ScreenResolution IS NULL
			AND Cpu IS NULL
			AND Ram IS NULL
			AND Memory IS NULL
			AND Gpu IS NULL
			AND OpSys IS NULL
			AND Weight IS NULL
			AND price IS NULL
                        ) ;


WITH empty_rows AS (
		     SELECT sr_no 
		     FROM laptop_data
		     WHERE Company IS NULL 
				AND TypeName IS NULL
				AND Inches IS NULL
				AND ScreenResolution IS NULL
				AND Cpu IS NULL
				AND Ram IS NULL
				AND Memory IS NULL
				AND Gpu IS NULL
				AND OpSys IS NULL
				AND Weight IS NULL
				AND price IS NULL
                                )

	
DELETE FROM laptop_data                                                   -- DELETE THESE 30 ROWS WHERE ALL COLUMN CONTAINS NULL VALUES   
WHERE sr_no IN (SELECT sr_no FROM empty_rows);


SELECT COUNT(*)                                                            -- 1273 ROWS LEFT
FROM laptop_data;   




-----------------------------------------
-- FIND AND DROP DUPLICATES FROM DATA
-----------------------------------------

WITH duplicate_row AS (
			SELECT MIN(sr_no) AS min_index 
            		FROM laptop_data
			GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price 
            		) 


DELETE FROM laptop_data                                                   -- DELETE DUPLICATE ROWS 
WHERE sr_no NOT IN (SELECT min_index FROM duplicate_row);               


SELECT * FROM laptop_data;                                                -- 1244 ROWS LEFT




------------------------------------------------------------------------------------------
-- CHECK NULL VALUES AS WELL AS GIVE DESIRED CONSTRAINTS AND DATA TYPES TO THE COLUMNS
-------------------------------------------------------------------------------------------

DESCRIBE laptop_data;            					-- CHECKED DATATYPE OF ALL COLUMNS 
									-- WE NEED TO CHANGE DATATYPE OF EACH COLUMNS
                                                                        


-----------------------
-- SR_NO
-----------------------

ALTER TABLE laptop_data                                                  -- SET sr_no TO PRIMARY KEY
MODIFY COLUMN sr_no INT PRIMARY KEY NOT NULL UNIQUE;




---------------------
-- COMPANY
---------------------

SELECT COUNT(*)            						-- ZERO NULL VALUES
FROM laptop_data
WHERE company IS NULL ;
 
 
SELECT DISTINCT(company)    						-- 19 UNIQUE COMPANIES
FROM laptop_data;


ALTER TABLE laptop_data               					-- TEXT TO VARCHAR
MODIFY COLUMN company VARCHAR(255);




-------------------
-- TYPENAME
-------------------

SELECT COUNT(*)           						-- ZERO NULL VALUES
FROM laptop_data 
WHERE typename IS NULL ;
 
 
SELECT DISTINCT(typename)  						-- THERE IS MISTAKE netbooK IN TYPENAME INSTEAD OF notebook
FROM laptop_data ;


UPDATE laptop_data
SET typename = "Notebook"
WHERE typename = "Netbook";


ALTER TABLE laptop_data                 				 -- TEXT TO VARCHAR
MODIFY COLUMN typename VARCHAR(255);
 
 
 
 
--------------------------------------
-- INCHES
--------------------------------------

SELECT COUNT(*) FROM laptop_data   					 -- ZERO NULL VALUES
WHERE inches IS NULL;

 
SELECT DISTINCT(Inches)          					 -- '?' SIGN IN INCHES COLUMN
FROM laptop_data; 


UPDATE laptop_data                 					 -- REPLACE '?' WITH NULL VALUE
SET Inches = NULL
WHERE Inches = '?';


UPDATE laptop_data t1                                                    -- FILL NULL VALUE WITH AVERAGE INCHES BASED ON COMPANY, TYPENAME AND RAM
	JOIN(
	     SELECT company, typename, ram, AVG(Inches) AS inch
	     FROM laptop_data
	     WHERE Inches IS NOT NULL
	     GROUP BY company , typename , ram
           ) AS avg_inches
        
	ON t1.company = avg_inches.company
    	AND t1.typename = avg_inches.typename
    	AND t1.ram = avg_inches.ram
    
SET t1.Inches = avg_inches.inch
WHERE t1.Inches IS NULL;


ALTER TABLE laptop_data                					  -- TEXT TO DECIMAL
MODIFY COLUMN Inches DECIMAL(10,1);
 

 
 
-----------------------------------
-- SCREENRESOLUTION                   
-----------------------------------

 ALTER TABLE laptop_data                                                   -- USE DATA OF SCREENRESOLUTION COLUMN AND CREATE USEFULL COLUMNS
 ADD COLUMN Resolution_width INT,            
 ADD COLUMN Resolution_height INT,
 ADD COLUMN Touchscreen INT ;


UPDATE laptop_data                                                         -- EXTRACT DATA FROM SCREENRESOLUTION AND FILL IN THESE COLUMNS
SET Resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution," ",-1),'x',1),
    Resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(screenresolution," ",-1),'x',-1),
    Touchscreen = CASE
		      WHEN ScreenResolution LIKE '%Touchscreen%' THEN 1
		      ELSE 0
		      END;


ALTER TABLE laptop_data              			                   -- NO NEED OF SCREENRESOLUTION COLUMN, DROP SCREENRESOLUTION COLUMN
DROP COLUMN screenresolution;




------------------------------
-- CPU
------------------------------

ALTER TABLE laptop_data                                                    -- USE DATA OF CPU COLUMN AND CREATE USEFULL COLUMNS
ADD COLUMN Cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN Cpu_name VARCHAR(255) AFTER Cpu_brand,
ADD COLUMN Cpu_Speed DECIMAL(10,1) AFTER Cpu_name;


UPDATE laptop_data t1                                                       -- EXTRACT BRAND NAME FROM CPU COLUMN AND FILL INTO brand_name COLUMN         
JOIN  (
	SELECT sr_no, SUBSTRING_INDEX(Cpu," ",1) AS brand
	FROM laptop_data
	) AS t2
       
ON t1.sr_no = t2.sr_no
SET  Cpu_brand = t2.brand ;


UPDATE laptop_data t1                                                        -- EXTRACT CPU SPEED FROM CPU COLUMN AND FILL INTO cpu_speed COLUMN
JOIN  (
	SELECT sr_no, REPLACE(SUBSTRING_INDEX(Cpu," ",-1),"GHz","") AS speed
	FROM laptop_data
        ) AS t2
      
ON t1.sr_no = t2.sr_no
SET Cpu_speed = t2.speed ;


UPDATE laptop_data t1                                                       -- EXTRACT CPU NAME FROM CPU COLUMN AND FILL INTO cpu_name COLUMN
JOIN (
      SELECT sr_no, REPLACE(REPLACE(Cpu,Cpu_brand,""),SUBSTRING_INDEX(Cpu," ",-1),"") AS name 
      FROM laptop_data
      ) AS t2
      
ON t1.sr_no = t2.sr_no
SET Cpu_name = t2.name ;


ALTER TABLE laptop_data                                                 -- DROP CPU COLUMN
DROP COLUMN Cpu;


------------------------------------------
-- RAM
------------------------------------------

UPDATE laptop_data t1                                                    -- REMOVE GB/TB FROM RAM COLUMN
JOIN (
      SELECT sr_no, REPLACE(ram,"GB", "") as ram 
      FROM laptop_data 
      ) AS t2
      
ON t1.sr_no = t2.sr_no
SET t1.ram = t2.ram ;


ALTER TABLE laptop_data                                                  -- TEXT TO INT
MODIFY COLUMN RAM INT ;



-------------------------------
-- GPU
-------------------------------

ALTER TABLE laptop_data                                                  -- CREATE Gpu_brand AND Gpu_name FROM Gpu COLUMN
ADD COLUMN Gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN Gpu_name VARCHAR(255) AFTER Gpu_brand ;


UPDATE laptop_data                                                       -- EXTRACT Gpu_brand AND Gpu_name FROM Gpu COLUMN AND FILL THE INFO
SET Gpu_brand = SUBSTRING_INDEX(Gpu," ",1) ,
    Gpu_name = REPLACE(Gpu, Gpu_brand, "");


ALTER TABLE laptop_data                                                  -- DROP Gpu COLUMN
DROP COLUMN Gpu;



---------------------------------------
-- opSys
---------------------------------------

ALTER TABLE laptop_data                                                  -- CHANGE NAME FROM opSys TO OS 
RENAME COLUMN opSys TO OS ;


UPDATE laptop_data                                                       -- MAKE ALL VARIENT OF OS TO MAIN OS BRAND NAME
SET OS = CASE                                       
	     WHEN OS LIKE "%Windows%" THEN 'Windows'
	     WHEN OS LIKE "%Mac%" THEN "Mac"
	     WHEN OS LIKE "%Linux%" THEN "Linux"
	     WHEN OS LIKE "%No OS%" THEN "No OS"
	     WHEN OS LIKE "%Chrome OS%" THEN "Chrome OS"
	     WHEN OS LIKE "%Android%" THEN "Android"
	     ELSE NULL
	     END ;


ALTER TABLE laptop_data                                                  -- TEXT TO VARCHAR
MODIFY COLUMN OS VARCHAR(255); 




----------------------------------
-- PRICE
----------------------------------

UPDATE laptop_data                                                      -- ROUND UP THE PRICE 
SET price = ROUND(price) ;


ALTER TABLE laptop_data                                                 -- DECIMAL TO INT
MODIFY COLUMN Price INT;



--------------------------------------
-- WEIGHT
--------------------------------------

UPDATE laptop_data                                                     -- REMOVE KG FROM WEIGHT
SET weight = REPLACE(weight,"kg","");		


SELECT DISTINCT(weight)                                                -- '?' IN WEIGHT COLUMN
FROM laptop_data;


UPDATE laptop_data                   
SET weight = NULL
WHERE weight = '?';

 
UPDATE laptop_data t1                                                  -- FILL AVERAGE WEIGHT BASED ON COMPANY, INCHES AND TYPENAME INPLACE OF NULL VALUE
JOIN  (
	SELECT Company, Inches, Typename,ROUND(AVG(weight),2) AS avg_weight 
        FROM laptop_data
	GROUP BY Company, Inches, Typename
        ) AS  t2
          
	ON t1.Company = t2.Company 
	AND t1.Inches = t2.Inches 
	AND t1.Typename = t2.Typename
SET weight = t2.avg_weight 
WHERE weight IS NULL ;  


ALTER TABLE laptop_data                                                -- TEXT TO DECIMAL
MODIFY COLUMN weight DECIMAL(10,2);



------------------------------
-- MEMORY
------------------------------

ALTER TABLE laptop_data                                                -- CREATE MULTIPLE COLUMNS TO STORE DATA OF MEMORY COLUMN 
ADD COLUMN Storage_type VARCHAR(255) AFTER Memory,
ADD COLUMN Primary_Memory INT AFTER Storage_type,
ADD COLUMN Secondary_memory INT AFTER Primary_memory;


SELECT DISTINCT(Memory)                                                -- NOTE ALL TYPE OF STORAGE
FROM laptop_data;


UPDATE laptop_data                                                     -- FILL VALUES IN STORAGE_TYPE
SET Storage_type = CASE
			WHEN Memory LIKE '%SSD%' AND Memory LIKE "%Hybrid%" THEN "Hybrid"
			WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE "HDD" THEN "Hybrid"
			WHEN Memory LIKE '%SSD%' AND Memory LIKE "%HDD%" THEN "Hybrid"
			WHEN Memory LIKE '%SSD%' THEN "SSD"
			WHEN Memory LIKE '%HDD%' THEN "HDD"
			WHEN Memory LIKE '%Flash Storage%' THEN "Flash Storage"
	                WHEN Memory LIKE '%Hybrid%' THEN "Hybrid"
			ELSE NULL
			END ;
                     

UPDATE laptop_data
SET memory = NULL
WHERE memory = '?';
 
 
UPDATE laptop_data                                                       -- EXTRACT REQUIRED DATA FROM MEMORY COLUMN AND FILL INTO PRIMARY AND SECONDARY COLUMN
SET Primary_memory = REPLACE(REPLACE(SUBSTRING_INDEX(Memory," ",1),"GB",""),"TB",""),
    Secondary_memory = CASE
		           WHEN Memory LIKE "%+%" THEN REPLACE(REPLACE(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(memory,"+",-1))," ",1),"GB",""),"TB","")
                           ELSE 0 
                           END ;
                        

UPDATE laptop_data
SET Primary_memory = CASE                                                              -- CONVERT TB INTO GB 
			WHEN Primary_memory = 1 OR Primary_memory = 2 THEN Primary_memory * 1024
                        ELSE primary_memory
                        END,
                        
    Secondary_memory = CASE
			  WHEN Secondary_memory = 1 OR Secondary_memory = 2 THEN Secondary_memory * 1024 
                          ELSE Secondary_memory
                          END
                        ;


-- THERE WAS NULL VALUE IN MEMORY COLUMN FILL IT WITH THE HELP OF OTHER INFORMATION
WITH Most_freq AS (
		    SELECT Company, OS, Typename, Storage_type
		    FROM (
			   SELECT Company, OS, Typename, Storage_type, COUNT(*) AS freq,
			   RANK() OVER (PARTITION BY Company, OS, Typename ORDER BY COUNT(*) DESC) AS rnk
			   FROM laptop_data
			   GROUP BY Company, OS, Typename, Storage_type
			   ) AS ranked
                            
		    WHERE rnk = 1
		    )

	
UPDATE laptop_data t1
JOIN Most_freq t2
ON t1.Company = t2.Company 
	AND t1.OS = t2.OS 
	AND t1.Typename = t2.Typename
    
SET t1.Storage_type = t2.Storage_type
WHERE t1.Storage_type IS NULL;


WITH Most_freq AS (
		    SELECT Company, OS, Typename, Storage_type, primary_memory
		    FROM (
			   SELECT Company, OS, Typename, Storage_type, Primary_memory, COUNT(*) AS freq,
			   RANK() OVER (PARTITION BY Company, OS, Typename, Storage_type ORDER BY COUNT(*) DESC) AS rnk
			   FROM laptop_data
			   GROUP BY Company, OS, Typename, Storage_type, primary_memory
			   ) AS ranked
        
		    WHERE rnk = 1
						)

UPDATE laptop_data t1                                                        -- FILL NULL VALUE WITH MOST FREQUENT PRIMARY MEMORY BASED ON OS, TYPENAME AND STORAGE_TYPE
JOIN Most_freq t2
ON t1.Company = t2.Company 
	AND t1.OS = t2.OS 
	AND t1.Typename = t2.Typename 
	AND t1.Storage_type = t2.storage_type
    
SET t1.Primary_memory = t2.primary_memory
WHERE t1.Primary_memory IS NULL;


ALTER TABLE laptop_data          									         -- DROP MEMORY COLUMN
DROP COLUMN Memory;


DESCRIBE LAPTOP_DATA;                                                        -- ALL DATATYPES AND CONSTRAINTS ARE RIGHT


-- DATA IS CLEANED AND READY FOR ANALYSIS
