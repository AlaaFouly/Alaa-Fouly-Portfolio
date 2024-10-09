-- Answering Business Questions 

-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name,
ROUND((population * 0.25) / 1000000 ,2) AS coffee_cosumers,
city_rank
FROM city
ORDER BY 2 DESC;


-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT ci.city_name,
SUM(s.total) AS Revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
WHERE sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY 1
ORDER BY 2 DESC
;

--- you can extraact year and quarter and add it to the WHERE clause 
-- EXTRACT(YEAR FROM sale_date) = 2023
-- AND
-- EXTRACT (QUARTER FROM sale_date) = 4


-- How many units of each coffee product have been sold?

SELECT p.product_name,
COUNT(s.sale_id) as Total_orders
FROM products p
JOIN sales s
ON p.product_id = s.product_id
GROUP BY 1
ORDER BY 2 DESC;



-- What is the average sales amount per customer in each city?

SELECT
	ci.city_name,
	SUM(s.total) AS Total_revenue,
	COUNT(DISTINCT c.customer_iD) AS Total_customers,
	ROUND(
		SUM(s.total)::numeric / COUNT(DISTINCT c.customer_iD)::numeric
	,2) AS Average_sales_per_customer
FROM customers c
JOIN sales s
ON c.customer_id = s.customer_id
JOIN city ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 4 DESC;


--Provide a list of cities along with their populations and estimated coffee consumers.

SELECT 
	ci.city_name,
	ci.population,
	ROUND((ci.population * 0.25) / 1000000 , 2) AS estimated_coffee_consumers,
	COUNT(DISTINCT c.customer_id) AS Uinque_ccustomers
FROM city ci 
JOIN customers c
ON ci.city_id = c.city_id
GROUP BY 1 ,2
ORDER BY 4 DESC; 


-- or you can use Common Table Expressions (CTEs) 


WITH city_table as 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name;


-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
		--assigns a unique rank to each product within each city based on the 
		--total sales volume, using dense ranking to avoid gaps for tied sales counts
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3;



-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id <= 14
	-- or BETWEEN 1 AND 14
GROUP BY 1
ORDER BY 2 DESC;




-- Find each city and their average sale per customer and avg rent per customer


SELECT
	ci.city_name,
	SUM(s.total) AS Total_revenue,
	COUNT(DISTINCT c.customer_iD) AS Total_customers,
	ROUND(
		SUM(s.total)::numeric / COUNT(DISTINCT c.customer_iD)::numeric
	,2) AS Average_sales_per_customer,
	ROUND(
		ci.estimated_rent::numeric / COUNT(DISTINCT c.customer_iD)::numeric
	,2) AS Average_Rent_per_customer
FROM customers c
JOIN sales s
ON c.customer_id = s.customer_id
JOIN city ci
ON ci.city_id = c.city_id
GROUP BY 1, ci.estimated_rent
ORDER BY 4 DESC;

 -- OR you could use Common Table Expressions (CTEs)

 
WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales  s
	JOIN customers  c
	ON s.customer_id = c.customer_id
	JOIN city  ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent  cr
JOIN city_table  ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC;



-- Identify top 3 city based on highest sales, return city name, 
-- total sale, total rent, total customers, estimated coffee consumer

SELECT 
	ci.city_name,
	SUM(s.total) AS Total_sales,
	SUM(ci.estimated_rent) AS Total_rent,
	COUNT(DISTINCT c.customer_id) AS Total_customer,
	ROUND((ci.population * 0.25)/1000000 , 2) AS estimated_coffee_consumers_in_Millions,
	ROUND(
		SUM(s.total)::numeric / COUNT(DISTINCT c.customer_iD)::numeric
	,2) AS Average_sales_per_customer,
	ROUND(
		ci.estimated_rent::numeric / COUNT(DISTINCT c.customer_iD)::numeric
	,2) AS Average_Rent_per_customer
FROM customers c
JOIN sales s
ON c.customer_id = s.customer_id
JOIN city ci
ON ci.city_id = c.city_id
GROUP BY 1,ci.population, ci.estimated_rent
ORDER BY SUM(s.total) DESC;

 -- OR you could use Common Table Expressions (CTEs)

WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC



-- Recomendation
--City 1: Pune
	-- 1.Average rent per customer is very low.
	-- 2.Highest total revenue.
	-- 3.Average sales per customer is also high.

-- City 2: Delhi
	-- 1.Highest estimated coffee consumers at 7.7 million.
	-- 2.second Highest total number of customers, which is 68.
	-- 3.Average rent per customer is 330 (still under 500).

-- City 3: Jaipur
	-- 1.Highest number of customers, which is 69.
	-- 2.Average rent per customer is very low at 156.
	-- 3.Average sales per customer is better at 11k.