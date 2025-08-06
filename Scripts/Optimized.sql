-- Using LIMIT for Large Datasets
EXPLAIN ANALYZE
SELECT *
FROM sales
LIMIT 10;

-- Avoid SELECT * for Large Datasets
EXPLAIN ANALYZE
SELECT customerkey
FROM sales;

-- Using WHERE instead of HAVING
EXPLAIN ANALYZE
SELECT
	customerkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
WHERE customerkey < 100
GROUP BY customerkey;

-- Minimize GROUP BY Usage

EXPLAIN ANALYZE
SELECT
	customerkey,
	orderdate,
	orderkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY
	customerkey,
	orderdate,
	orderkey;

-- Reduce JOIN's when possible

EXPLAIN ANALYZE
SELECT
	c.customerkey,
	c.givenname,
	c.surname,
	p.productname,
	s.orderdate,
	s.orderkey,
	EXTRACT(YEAR FROM s.orderdate) AS year
FROM sales s JOIN customer c ON s.customerkey = c.customerkey
JOIN product p ON p.productkey = s.productkey;

-- Optimize ORDER BY

EXPLAIN ANALYZE
SELECT
	customerkey,
	orderdate,
	orderkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY
	customerkey,
	orderdate,
	orderkey
ORDER BY 
	customerkey;

-- Optimizing Cohort Analysis

EXPLAIN ANALYZE
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.quantity::double PRECISION * s.netprice * s.exchangerate) AS net_revenue,
		count(s.orderkey) AS num_orders,
		MAX(c.countryfull) AS countryfull,
		MAX(c.age) AS age,
		MAX(c.givenname) AS givenname,
		MAX(c.surname) AS surname
	FROM
		sales s
	JOIN customer c ON
		s.customerkey = c.customerkey
	GROUP BY
		s.customerkey,
		s.orderdate
)
 SELECT
	customerkey,
	orderdate,
	net_revenue,
	num_orders,
	countryfull,
	age,
	concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS full_name,
	min(orderdate) OVER (
		PARTITION BY customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;

