# Walmart-Python_SQL_Project
In this project, I utilized the Kaggle API to extract data directly into a Python virtual environment. After setting up the environment and importing essential libraries, I conducted thorough data cleaning and formatting using Python to ensure data quality and consistency. I then established a seamless connection between Python and PostgreSQL to integrate the refined data. By leveraging SQL queries, I effectively analyzed the data within the PostgreSQL database, addressing key business problems with actionable insights. This project demonstrates my ability to work with data extraction, transformation, and database management, showcasing strong skills in both Python and SQL for data analysis.

## Project Steps
1. Set Up the Environment
  Tools Used: Visual Studio Code (VS Code), Python, SQL (MySQL and PostgreSQL)
  Goal: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

2. Set Up Kaggle API
  API Setup: Obtain your Kaggle API token from <a href="https://www.kaggle.com/"> Kaggle </a> by navigating to your profile settings and downloading the JSON file.
  Configure Kaggle:
	  Place the downloaded kaggle.json file in your local .kaggle folder.
	  Use the command kaggle datasets download -d <dataset-path> to pull datasets directly into your project.

3. Download Walmart Sales Data
  Data Source: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
  Dataset Link: - <a href="https://github.com/ridumjeetsingh/Walmart-Python_SQL_Project/blob/main/Walmart.csv"> Walmart Data Set 1 </a> 
  Storage: Save the data in the data/ folder for easy reference and access.

4. Install Required Libraries and Load Data
  Libraries: Install necessary Python libraries using:
  ```
  pip install pandas numpy sqlalchemy mysql-connector-python psycopg2
  ```
  Loading Data: Read the data into a Pandas DataFrame for initial analysis and transformations.

6. Explore the Data
  Goal: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
  Analysis: Use functions like .info(), .describe(), and .head() to get a quick overview of the data structure and statistics.

7. Data Cleaning
  Remove Duplicates: Identify and remove duplicate entries to avoid skewed results.
  Handle Missing Values: Drop rows or columns with missing values if they are insignificant; fill values where essential.
  Fix Data Types: Ensure all columns have consistent data types (e.g., dates as datetime, prices as float).
  Currency Formatting: Use .replace() to handle and format currency values for analysis.
  Validation: Check for any remaining inconsistencies and verify the cleaned data.

8. Feature Engineering
  Create New Columns: Calculate the Total Amount for each transaction by multiplying unit_price by quantity and adding this as a new column.
  Enhance Dataset: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

9. Load Data into MySQL and PostgreSQL
  Set Up Connections: Connect to MySQL and PostgreSQL using sqlalchemy and load the cleaned data into each database.
  Table Creation: Set up tables in both MySQL and PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.  
  Verification: Run initial SQL queries to confirm that the data has been loaded accurately.

10. SQL Analysis: Complex Queries and Business Problem Solving
  Business Problem-Solving: Write and execute complex SQL queries to answer critical business questions, such as:
    Revenue trends across branches and categories.
    Identifying best-selling product categories.
    Sales performance by time, city, and payment method.
    Analyzing peak sales periods and customer buying patterns.  
    Profit margin analysis by branch and category.
  Documentation: Keep clear notes of each query's objective, approach, and results.

11. Project Publishing and Documentation
  Documentation: Maintain well-structured documentation of the entire process in Markdown or a Jupyter Notebook.
  Project Publishing: Publish the completed project on GitHub or any other version control platform, including:
    The README.md file (this document).
    Jupyter Notebooks (if applicable).
    SQL query scripts.
    Data files (if possible) or steps to access them.


## Requirements
  Python 3.8+
  SQL Databases: MySQL, PostgreSQL
  Python Libraries:
  pandas, numpy, sqlalchemy, mysql-connector-python, psycopg2
  Kaggle API Key (for data downloading)

## Getting Started
 Clone the repository:
```python
git clone <repo-url>
```
 Install Python libraries:
```
pip install -r requirements.txt
```
 Set up your Kaggle API, download the data, and follow the steps to load and analyze.



## Starting the SQL Analysis
To kick off the SQL portion, I began by understanding the dataset structure, identifying key columns like payment_method, category, branch, date, time, and total. I ensured data integrity by addressing inconsistencies in date formats and data types. This foundational step allowed for accurate insights throughout the analysis.

### Key Insights and Solutions

1. Payment Method Analysis:

    -Identified distinct payment methods and calculated total transactions and quantity sold for each.

2. Highest-Rated Category:

    -Determined the top-rated product category in each branch based on average ratings.

3. Busiest Day Identification:

    -Found the busiest day for each branch by analyzing transaction counts.

4. Total Quantity by Payment Method:

    -Calculated total item quantity sold per payment method.

5. Category Ratings Analysis:

    -Evaluated average, minimum, and maximum ratings for each category across cities.

6. Profit Analysis:

    -Computed total profit by multiplying unit price, quantity, and profit margin, listing categories by highest profit.

7. Most Common Payment Method by Branch:

    -Identified the preferred payment method in each branch based on transaction counts.

8. Sales Shift Analysis:

    -Categorized sales data into Morning, Afternoon, and Evening shifts and calculated invoice counts for each period.

9. Revenue Decrease Analysis:

    -Identified the top 5 branches with the highest revenue decrease ratio by comparing sales data from 2022 to 2023.
```sql
  

--Business Insight Problems--

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


-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)



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

```


### Project Structure
```
  |-- data/                     # Raw data and transformed data
  |-- sql_queries/              # SQL scripts for analysis and queries
  |-- notebooks/                # Jupyter notebooks for Python analysis
  |-- README.md                 # Project documentation
  |-- requirements.txt          # List of required Python libraries
  |-- main.py                   # Main script for loading, cleaning, and processing data
```

##  Results and Insights
This section will include your analysis findings:
  Sales Insights: Key categories, branches with highest sales, and preferred payment methods.
  Profitability: Insights into the most profitable product categories and locations.
  Customer Behavior: Trends in ratings, payment preferences, and peak shopping hours.
  
## Future Enhancements
### Possible extensions to this project:
  Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
  Additional data sources to enhance analysis depth.
  Automation of the data pipeline for real-time data ingestion and analysis.

## Acknowledgments
  Data Source: Kaggle’s Walmart Sales Dataset
  Inspiration: Walmart’s business case studies on sales and supply chain optimization.
