CREATE DATABASE PROJECT ;

-- Upon importing CSV File data type of attributes were in text so changing data types according to attributes
-- also converting Date in DATETIME Format

-- Step 1: Create a new column with DATETIME data type
ALTER TABLE sales
ADD COLUMN NewDate DATETIME ;

-- Step 2: Convert the text dates to DATETIME and store them in the new column
-- For this to work turn off safe mode for update
UPDATE sales
SET NewDate= STR_TO_DATE(Date, '%m/%d/%Y')
;
-- Step 3: Drop the old column
ALTER TABLE sales
DROP COLUMN Date;

-- Step 4: Rename the new column to the old column's name
ALTER TABLE sales
CHANGE COLUMN NewDate Date DATETIME;

-- Modifying Data Types and Constraints
ALTER TABLE sales
MODIFY  `Invoice ID` VARCHAR(30) NOT NULL PRIMARY KEY  ;

ALTER TABLE sales
MODIFY Branch VARCHAR(5) NOT NULL,
MODIFY City VARCHAR(30) NOT NULL,
MODIFY `Customer type` VARCHAR(30) NOT NULL,
MODIFY Gender VARCHAR(10) NOT NULL,
MODIFY `Product line` VARCHAR(100) NOT NULL,
MODIFY `Unit price` DECIMAL(10,2) NOT NULL,
MODIFY Quantity INT NOT NULL ,
MODIFY `Tax 5%` FLOAT (6) NOT NULL,
MODIFY Total DECIMAL(12,4) NOT NULL,
MODIFY Date  DATETIME NOT NULL,
MODIFY Time  TIME NOT NULL,
MODIFY Payment VARCHAR(15) NOT NULL,
MODIFY cogs DECIMAL(10,2) NOT NULL,
MODIFY `gross margin percentage` FLOAT (11),
MODIFY `gross income` DECIMAL(12,4) NOT NULL,
MODIFY Rating FLOAT(2) ;


-- Feature Engineering 
SELECT
	*
FROM sales;


-- Add the time_of_day column
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- Insert data into time_of_day column
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add day_name column

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


SELECT
	date,
	month_name
FROM sales;


-- EDA ----------------------------------------------------------------------------------------------

-- How many unique cities does the data have?

SELECT 
	COUNT(DISTINCT city)
FROM sales;


-- In which city is each branch?
SELECT 
	DISTINCT city AS unique_Citiy_name,
    branch
FROM sales
GROUP BY unique_Citiy_name , branch;


-- How many unique product lines does the data have?
SELECT
	COUNT(DISTINCT `Product line`)
FROM sales;

-- What ARE the most common payment method?

SELECT 
	Payment ,COUNT(Payment) AS common_pament_methods
FROM sales 
GROUP BY payment
ORDER BY common_pament_methods DESC;

-- What are the most selling product line
SELECT
	SUM(Quantity) as qty,
    `Product line`
FROM sales
GROUP BY `Product line`
ORDER BY qty DESC;

-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(Total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue DESC;

-- What product line had the largest revenue?
SELECT
	`Product line`,
	SUM(Total) as total_revenue
FROM sales
GROUP BY `Product line`
ORDER BY total_revenue DESC;

-- What product line had the largest Tax?
SELECT
	`Product line`,
	AVG(`Tax 5%`) as avg_tax
FROM sales
GROUP BY `Product line`
ORDER BY avg_tax DESC;

-- -- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(Quantity) AS avg_qnty
FROM sales;

SELECT
	`Product line`,
	CASE
		WHEN AVG(Quantity) > 5.5 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY `Product line`;


-- Which branch sold more products than average product sold?
SELECT 
	Branch, 
    SUM(Quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(Quantity) FROM sales);

-- What is the average rating of each product line
SELECT
	ROUND(AVG(Rating), 2) as avg_rating,
    `Product line`
FROM sales
GROUP BY `Product line`
ORDER BY avg_rating DESC;


-- What are the most common customer type?
SELECT
	`Customer type`,
	count(*) as count
FROM sales
GROUP BY `Customer type`
ORDER BY count DESC;

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	COUNT(Rating) AS cnt_rating
FROM sales
GROUP BY time_of_day
ORDER BY cnt_rating DESC;
-- At evening customers give most ratings

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
	AVG(Rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings

-- Which cities has the largest tax percent?
SELECT
	City,
    ROUND(AVG(`Tax 5%`), 2) AS avg_tax
FROM sales
GROUP BY City 
ORDER BY avg_tax DESC;