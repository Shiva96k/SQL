-- 1. Classify laptop brands (with at least 10 models) into budget, mid-range, and premium categories using their average price.

WITH avg_price AS ( 
					SELECT company, AVG(price) AS avg_price
					FROM laptop_data
					GROUP BY company
					HAVING COUNT(*) >= 10
					) 
	
SELECT company,
	   avg_price,
       CASE 
			WHEN avg_price < 50000 THEN "Budget"
            WHEN avg_price BETWEEN 50000 AND 80000 THEN "Mid-range"
            ELSE "Premium" END AS Category
FROM avg_price;
					
                



-- 2. What is the distribution of laptop types (typename) across different brands?

SELECT company, typename, COUNT(*) as total_laptops
FROM laptop_data
GROUP BY company, typename
ORDER BY company, total_laptops DESC;




-- How does each company distribute its laptops across different storage types (SSD, HDD, Flash Storage, Hybrid) in percentage terms?

WITH company_contribution_by_storage_type AS (		
											   SELECT company, storage_type, COUNT(*) as total_contribution
											   FROM laptop_data
											   GROUP BY company, Storage_type
											   ),
                           
                           
company_total_laptops AS (
						   SELECT company, COUNT(*) AS total_laptops
						   FROM laptop_data
						   GROUP BY company
						   )


SELECT t1.company, storage_type, ROUND((total_contribution / total_laptops) * 100, 2) AS contribution_percentage
FROM company_contribution_by_storage_type AS t1
JOIN company_total_laptops AS t2
ON t1.company = t2.company
ORDER BY t1.company;




-- 3. How does the laptop price vary with CPU brand and CPU speed?

SELECT cpu_brand, cpu_speed, ROUND(AVG(price)) AS Avg_price
FROM laptop_data
GROUP BY cpu_brand, cpu_Speed
ORDER BY Avg_price DESC, Cpu_Speed DESC;





# Is there a significant difference in price based on RAM size (e.g., 4GB, 8GB, 16GB)?

# Do laptops with dedicated GPU brands (e.g., NVIDIA, AMD) cost more than those with integrated GPUs (e.g., Intel)?

# How does screen resolution (width × height) affect laptop price?

# Is there a relationship between touchscreen capability (TouchScreen) and price?

# Which CPU models (Cpu_name) are most common among laptops under ₹50,000, between ₹50,000–₹80,000, and above ₹80,000?

# How does the combination of primary and secondary memory (SSD + HDD) affect price?

# Does the presence of secondary storage significantly influence laptop price?

# Which brands offer the lightest laptops on average?

# Is there a trade-off between laptop weight and performance (CPU speed, RAM)?

# Which laptop types (typename) are the most lightweight on average?

# What are the top 5 most common GPU models, and what are their average laptop prices?

# Which operating systems (OS) are most common, and how do their prices compare?

# What is the distribution of screen sizes (Inches), and how does it affect weight and price?

# Are high-resolution screens (e.g., higher than 1920×1080) becoming more common in mid-range laptops?

# What specifications define budget, mid-range, and high-end laptops in this dataset?

# Which combination of specs offers the best performance-to-price ratio (value for money)?

# Which brand provides the most powerful laptop under ₹70,000?

# Which features (RAM, SSD, CPU speed, GPU) contribute most to high laptop prices? (correlation analysis)