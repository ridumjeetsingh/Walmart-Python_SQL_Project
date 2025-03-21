SELECT *
FROM walmart

--Business Problems--

--Q1. Find the diff payment method and no. of transactions, no. of qty sold

SELECT 
	payment_method,
	SUM(quantity) as num_payments,
	COUNT(*) as Total_counts
FROM walmart
GROUP BY 1

--Q2. Identify the highest-rated category in each branch, displaying the branch, category AVG RATING.


SELECT *
FROM(
	SELECT 
		branch,
		category,
		AVG(rating) as AVG_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rnk
	FROM walmart
	GROUP BY 1,2
)x
WHERE x.rnk=1


-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM(
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') as formated_date,
		COUNT(*) as total_no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rnk
	FROM walmart
	GROUP BY 1,2
)x
WHERE x.rnk = 1


 
-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method,
	SUM(quantity) as total_quantity
FROM walmart
GROUP BY 1

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	AVG(rating) as AVG_rating,
	MIN(rating) as MIN_rating,
	MAX(rating) as MAX_rating
FROM walmart
GROUP BY 1,2



-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.


SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as Total_profit
FROM walmart
GROUP BY 1
ORDER BY Total_profit DESC


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH CTE
as(
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rnk
	FROM walmart
	GROUP BY 1,2
)
SELECT * 
FROM CTE
WHERE rnk=1



-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT 
	branch,
CASE
	WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
	WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
END time,
	COUNT(*) as total_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC


-- 
-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100


-- Converting date 'text' datatype to it's orignal formate 'date'
SELECT *,
	EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date	
FROM walmart




-- Now using CTE for Creating and Joining both year Total revenue, At the last calculating 'revenue decrease ratio' with the help of both year revenue
WITH revenue_2022
AS(
	SELECT 
		branch,
		SUM(total) as total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023
AS(
	SELECT 
		branch,
		SUM(total) as total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

-- Now calculating the 'revenue_decrease_ratio' and joining both the revenue table of 2022 and 2023.
SELECT 
	last_year_sale.branch,
	last_year_sale.total_revenue as last_year_revenue,
	curr_year_sale.total_revenue as curr_year_revenue,
	ROUND((last_year_sale.total_revenue - curr_year_sale.total_revenue)
	::numeric / last_year_sale.total_revenue::numeric * 100,2) as revenue_decrease_ratio	
FROM revenue_2022 as last_year_sale
JOIN revenue_2023 as curr_year_sale ON last_year_sale.branch = curr_year_sale.branch
WHERE last_year_sale.total_revenue > curr_year_sale.total_revenue
ORDER BY 4 DESC
LIMIT 5