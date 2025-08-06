WITH customer_last_purchase AS(
SELECT 
	customerkey,
	full_name,
	orderdate,
	row_number() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS row_number_orderdate,
	first_purchase_date,
	cohort_year 
FROM cohort_analysis
), churned_customers AS(
SELECT
	customerkey,
	full_name,
	first_purchase_date,
	orderdate AS last_purchase_date,
	CASE
		WHEN orderdate < (SELECT MAX(orderdate) FROM sales)::DATE - INTERVAL '6 months' THEN 'Churned'
		ELSE 'Active'
	END AS customer_status,
	cohort_year
FROM customer_last_purchase 
WHERE row_number_orderdate = 1 AND first_purchase_date < (SELECT MAX(orderdate) FROM sales)::DATE - INTERVAL '6 months'
)
SELECT 
	cohort_year,
	customer_status,
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customer,
	ROUND(COUNT(customerkey)/SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year),2) AS status_percentage
FROM churned_customers 
GROUP BY cohort_year, customer_status;
