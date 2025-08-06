CREATE TABLE data_jobs (
	id INT,
	job_title VARCHAR(30),
	is_real_job VARCHAR(20),
	salary INT
);

INSERT INTO data_jobs VALUES
(1, 'Data Analyst', 'yes', NULL),
(2, 'Data Scientist', NULL, 140000),
(1, 'Data Analyst', 'kinda', 120000);

SELECT *
FROM data_jobs;

SELECT 
	job_title,
	COALESCE(is_real_job, 'no') AS is_real_job,
	salary
FROM data_jobs;

SELECT 
	job_title,
	NULLIF(is_real_job, 'kinda') AS is_real_job,
	salary
FROM data_jobs; 

WITH sales_data AS(
	SELECT 
		customerkey,
		sum(quantity * netprice * exchangerate) AS net_revenue
	FROM sales
	GROUP BY customerkey 
)

SELECT 
	AVG(s.net_revenue) AS spending_customer_avg_revenue,
	AVG(COALESCE(s.net_revenue, 0)) AS all_customers_avg_revenue
FROM customer c LEFT JOIN sales_data s
ON c.customerkey = s.customerkey;

SELECT LOWER('JAMES');

SELECT UPPER('james');

SELECT TRIM(' JAMES '); 

SELECT TRIM(BOTH '@' FROM '@@JAMES@@');

