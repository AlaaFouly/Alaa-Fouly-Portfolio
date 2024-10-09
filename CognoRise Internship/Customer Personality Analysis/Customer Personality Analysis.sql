-- Data Cleaning

ALTER TABLE cognorise.marketing_campaign 
CHANGE COLUMN MntWines Wine DECIMAL(10, 2),
CHANGE COLUMN MntFruits Fruits DECIMAL(10, 2),
CHANGE COLUMN MntMeatProducts Meat DECIMAL(10, 2),
CHANGE COLUMN MntFishProducts Fish DECIMAL(10, 2),
CHANGE COLUMN MntSweetProducts Sweets DECIMAL(10, 2),
CHANGE COLUMN MntGoldProds Gold DECIMAL(10, 2),
CHANGE COLUMN Year_Birth Birth_Year INT,
CHANGE COLUMN Dt_Customer Enrollment_Date DATE,
CHANGE COLUMN Recency Days_Since_Last_Purchase INT,
CHANGE COLUMN NumDealsPurchases Deals_Purchases INT,
CHANGE COLUMN NumWebPurchases Web_Purchases INT,
CHANGE COLUMN NumCatalogPurchases Catalog_Purchases INT,
CHANGE COLUMN NumStorePurchases Store_Purchases INT,
CHANGE COLUMN NumWebVisitsMonth Web_Visits INT,
CHANGE COLUMN AcceptedCmp1 First_Campaign INT,
CHANGE COLUMN AcceptedCmp2 Second_Campaign INT,
CHANGE COLUMN AcceptedCmp3 Third_Campaign INT,
CHANGE COLUMN AcceptedCmp4 Fourth_Campaign INT,
CHANGE COLUMN AcceptedCmp5 Fifth_Campaign INT,
CHANGE COLUMN Response Last_Campaign INT;

-- Add Age Column
ALTER TABLE cognorise.marketing_campaign
ADD COLUMN Age INT;

UPDATE cognorise.marketing_campaign
SET Age = 2024 - Birth_Year;


-- Add Age Group Column

ALTER TABLE cognorise.marketing_campaign
ADD COLUMN Age_Group text;

UPDATE cognorise.marketing_campaign
SET Age_Group = 
CASE 
        WHEN Age < 34 THEN '18-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35 To 44'
        WHEN Age BETWEEN 45 AND 54 THEN '45 To 54'
        WHEN Age BETWEEN 55 AND 64 THEN '55 To 64'
		WHEN Age BETWEEN 65 AND 74 THEN '65 To 74'
        ELSE '75+' 
    END;

-- Add Income Level
ALTER TABLE cognorise.marketing_campaign
ADD COLUMN Income_Level text;

UPDATE cognorise.marketing_campaign
SET Income_Level = 
CASE
	WHEN Income < 20000 THEN 'Low Income'
	WHEN Income BETWEEN 20000 AND 50000 THEN 'Medium Income'
	WHEN Income > 50000 THEN 'High Income'
END;


-- Add Customer Type
ALTER TABLE cognorise.marketing_campaign
ADD COLUMN Customer_Type text;

UPDATE cognorise.marketing_campaign
SET customer_type = 
	CASE
    WHEN Deals_Purchases > 0 THEN 'Discount User'
    ELSE 'Non-Discount User'
    END;

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

-- Basic Data Exploration

SELECT 
* 
FROM cognorise.marketing_campaign;

-- How many unique customers are in the dataset?
SELECT 
COUNT(DISTINCT ID) As Unique_customers
FROM cognorise.marketing_campaign;

-- What is the distribution of customers by marital status?
SELECT marital_status,
COUNT(DISTINCT ID) As Unique_customers
FROM cognorise.marketing_campaign
GROUP BY Marital_Status
ORDER BY COUNT(DISTINCT ID) DESC;

-- What are the average income and age of customers?
SELECT 
ROUND(AVG(Income),2) AS Average_income,
ROUND(AVG(Age),2) AS Average_Age
FROM cognorise.marketing_campaign;

-- Questions to Answer Using the 4 Ps Framework

-- Product

-- What are the most popular product categories among different customer segments (e.g., age, marital status)?
SELECT 
    Age_Group,
    CASE 
        WHEN Total_Fruit_Spending >= GREATEST(Total_Wine_Spending, Total_Meat_Spending, Total_Fish_Spending, Total_Sweet_Spending, Total_Gold_Spending) THEN 'Fruits'
        WHEN Total_Wine_Spending >= GREATEST(Total_Fruit_Spending, Total_Meat_Spending, Total_Fish_Spending, Total_Sweet_Spending, Total_Gold_Spending) THEN 'Wines'
        WHEN Total_Meat_Spending >= GREATEST(Total_Wine_Spending, Total_Fruit_Spending, Total_Fish_Spending, Total_Sweet_Spending, Total_Gold_Spending) THEN 'Meat'
        WHEN Total_Fish_Spending >= GREATEST(Total_Wine_Spending, Total_Fruit_Spending, Total_Meat_Spending, Total_Sweet_Spending, Total_Gold_Spending) THEN 'Fish'
        WHEN Total_Sweet_Spending >= GREATEST(Total_Wine_Spending, Total_Fruit_Spending, Total_Meat_Spending, Total_Fish_Spending, Total_Gold_Spending) THEN 'Sweets'
        ELSE 'Gold'
    END AS Most_Popular_Product,
    GREATEST(Total_Wine_Spending, Total_Fruit_Spending, Total_Meat_Spending, Total_Fish_Spending, Total_Sweet_Spending, Total_Gold_Spending) AS Highest_Spending
FROM (
    SELECT 
        Age_Group,
        SUM(wine) AS Total_Wine_Spending,
		SUM(Fruits) AS Total_Fruit_Spending,
		SUM(Meat) AS Total_Meat_Spending,
		SUM(Fish) AS Total_Fish_Spending,
		SUM(Sweets) AS Total_Sweet_Spending,
		SUM(Gold) AS Total_Gold_Spending
    FROM 
        cognorise.marketing_campaign
    GROUP BY 
        Age_Group
) AS SpendingByCategory;

-- How can we modify existing products or develop new ones based on customer preferences and spending patterns?
-- This query provides insights into how education level affects spending on various product categories

SELECT 
	Education,
	SUM(wine) AS Total_Wine_Spending,
	SUM(Fruits) AS Total_Fruit_Spending,
	SUM(Meat) AS Total_Meat_Spending,
	SUM(Fish) AS Total_Fish_Spending,
	SUM(Sweets) AS Total_Sweet_Spending,
	SUM(Gold) AS Total_Gold_Spending
FROM cognorise.marketing_campaign
GROUP BY Education; 


-- Are there specific demographics that tend to spend more on premium products versus budget options?
-- This helps identify which demographic groups (could include Age, Income Level, Marital Status or education) 
-- are willing to spend more on high-end products (usually meat , wine, fruits)

SELECT
	income_level,
	SUM(wine) AS Total_Wine_Spending,
	SUM(Meat) AS Total_Meat_Spending,
    SUM(Fruits) AS Total_Fruit_Spending,
    (SUM(wine) + SUM(Meat) + SUM(Fruits)) AS Total_High_End_Spending
FROM cognorise.marketing_campaign
GROUP BY Income_level
ORDER BY Total_High_End_Spending;


-- Price
-- How does the average spending on products vary with different income levels and education backgrounds?
SELECT 
	income_level,
    Education,
    ROUND(AVG(wine),2) AS Average_Wine_Spending,
	ROUND(AVG(Fruits),2) AS Average_Fruit_Spending,
	ROUND(AVG(Meat),2) AS Average_Meat_Spending,
	ROUND(AVG(Fish),2) AS Average_Fish_Spending,
	ROUND(AVG(Sweets),2) AS Average_Sweet_Spending,
	ROUND(AVG(Gold),2) AS Average_Gold_Spending
FROM cognorise.marketing_campaign
GROUP BY income_level, Education
ORDER BY income_level, Education;


-- What percentage of customers respond positively to promotional discounts, and how does this affect their overall spending?
-- percentage of customers respond positively to promotional discounts

SELECT 
(COUNT(DISTINCT CASE WHEN Customer_type = 'Discount User' THEN ID END)) 
/ (COUNT(DISTINCT ID))*100 AS Percent_Discount_Responders
FROM cognorise.marketing_campaign;

-- how does this affect their overall spending
SELECT 
	Customer_type,
    COUNT(DISTINCT ID) AS Total_Customers,
    ROUND(AVG(wine),2) AS Average_Wine_Spending,
	ROUND(AVG(Fruits),2) AS Average_Fruit_Spending,
	ROUND(AVG(Meat),2) AS Average_Meat_Spending,
	ROUND(AVG(Fish),2) AS Average_Fish_Spending,
	ROUND(AVG(Sweets),2) AS Average_Sweet_Spending,
	ROUND(AVG(Gold),2) AS Average_Gold_Spending,
    ROUND(AVG(wine + Fruits + Meat + Fish + Sweets + Gold),2) AS Average_Purchases
FROM cognorise.marketing_campaign
GROUP BY customer_type;
 
-- While discounts attract a lot of customers, the spending per customer is lower. This could indicate that discount users are more interested in smaller or lower-cost items.
-- You might want to adjust your discount strategy to focus on items with higher margins, or target specific products to increase spending from these customers.



-- How can we adjust our pricing strategies to better align with customer price sensitivity and willingness to pay?

ALTER TABLE cognorise.marketing_campaign
ADD COLUMN Recency_category text;

UPDATE cognorise.marketing_campaign
SET recency_category = 
	CASE
    WHEN Days_Since_Last_Purchase BETWEEN 0 AND 30 THEN 'Recent Buyer'
    WHEN Days_Since_Last_Purchase BETWEEN 31 AND 60 THEN 'Moderately Recent Buyer'
    WHEN Days_Since_Last_Purchase BETWEEN 61 AND 90 THEN 'Less Recent Buyer'
    WHEN Days_Since_Last_Purchase BETWEEN 90 AND 120 THEN 'Inactive Customer'
	END;


SELECT 
	Recency_category,
    COUNT(DISTINCT ID) AS Total_cusomers, 
    ROUND(AVG(wine + Fruits + Meat + Fish + Sweets + Gold),2) AS Average_Purchases,
    ROUND(AVG(income),2) AS Average_Income
FROM cognorise.marketing_campaign
GROUP BY recency_category;


SELECT 
*
FROM cognorise.marketing_campaign;


-- Place

-- Which sales channels (online, catalog, in-store) are most frequently used by different customer segments?

SELECT 
	age_group,
    SUM(web_purchases) AS Total_Online_purchases,
    SUM(catalog_purchases) AS Total_Catalog_purchases,
    SUM(store_purchases) AS Total_Store_purchases
FROM cognorise.marketing_campaign
GROUP BY age_group;

-- How do the number of web visits correlate with online purchases, and what does this indicate about our website's effectiveness?
SELECT 
	Income_level,
    SUM(web_purchases) AS Total_Online_purchases,
    SUM(web_visits) AS Total_web_visits,
    ROUND((SUM(web_purchases) / SUM(web_visits) * 100),2) AS Conversion_Rate
FROM cognorise.marketing_campaign
GROUP BY Income_level;

-- Promotion
-- What are the acceptance rates for our marketing campaigns, and which campaigns are most effective for specific customer segments?
SELECT 
	age_group,
    COUNT(*) AS Total_customers,
    SUM(first_campaign) AS First_Campaign,
    SUM(Second_campaign) AS Second_campaign,
    SUM(Third_campaign) AS Third_campaign,
    SUM(Fourth_campaign) AS Fourth_campaign,
    SUM(Fifth_campaign) AS Fifth_campaign,
    SUM(Last_campaign) AS Last_campaign,
    SUM(first_campaign) / COUNT(*) * 100 AS First_Campaign_Rate,
    SUM(Second_campaign) / COUNT(*) * 100 AS Second_Campaign_Rate,
    SUM(Third_campaign) / COUNT(*) * 100 AS Third_Campaign_Rate,
    SUM(Fourth_campaign) / COUNT(*) * 100 AS Fourth_Campaign_Rate,
    SUM(Fifth_campaign) / COUNT(*) * 100 AS Fifth_Campaign_Rate,
    SUM(Last_campaign) / COUNT(*) * 100 AS Last_Campaign_Rate    
FROM cognorise.marketing_campaign
GROUP BY age_group;



-- How do complaints and purchase recency impact customer engagement with our promotional efforts?

SELECT 
	recency_category,
    complain,
    COUNT(*) AS Total_customers,
    SUM(first_campaign) AS First_Campaign,
    SUM(Second_campaign) AS Second_campaign,
    SUM(Third_campaign) AS Third_campaign,
    SUM(Fourth_campaign) AS Fourth_campaign,
    SUM(Fifth_campaign) AS Fifth_campaign,
    SUM(Last_campaign) AS Last_campaign
    FROM cognorise.marketing_campaign
    GROUP BY recency_category, complain;
    -- HAVING complain > 0;
    
    
    
-- What types of promotions yield the highest conversion rates among different demographics, and how can we leverage this information for future campaigns?
SELECT 
    Education,
    Marital_Status,
    AVG(first_campaign) * 100 AS Conversion_Rate_Campaign1,
    AVG(Second_campaign) * 100 AS Conversion_Rate_Campaign2,
    AVG(Third_campaign) * 100 AS Conversion_Rate_Campaign3,
    AVG(Fourth_campaign) * 100 AS Conversion_Rate_Campaign4,
    AVG(Fifth_campaign) * 100 AS Conversion_Rate_Campaign5,
    AVG(Last_campaign) * 100 AS Conversion_Rate_Last_Campaign
FROM 
    cognorise.marketing_campaign
GROUP BY 
    Education, Marital_Status;
