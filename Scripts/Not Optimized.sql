EXPLAIN
SELECT *
FROM sales;

EXPLAIN ANALYZE
SELECT *
FROM sales;

EXPLAIN ANALYZE
SELECT
	customerkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
WHERE orderdate >= '2024-01-01'
GROUP BY customerkey;

EXPLAIN ANALYZE
SELECT
	customerkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY customerkey
HAVING SUM(quantity * netprice * exchangerate) > 1000;

EXPLAIN ANALYZE
SELECT
	customerkey,
	orderdate,
	orderkey,
	linenumber,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY
	customerkey,
	orderdate,
	orderkey,
	linenumber;

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

EXPLAIN ANALYZE
SELECT
	c.customerkey,
	c.givenname,
	c.surname,
	p.productname,
	s.orderdate,
	s.orderkey,
	d.year
FROM sales s JOIN customer c ON s.customerkey = c.customerkey
JOIN product p ON p.productkey = s.productkey
JOIN date d ON d.date = s.orderdate;

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
	net_revenue DESC,
	customerkey,
	orderdate,
	orderkey;

EXPLAIN ANALYZE
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.quantity::double PRECISION * s.netprice * s.exchangerate) AS net_revenue,
		count(s.orderkey) AS num_orders,
		c.countryfull,
		c.age,
		concat(TRIM(BOTH FROM c.givenname), ' ', TRIM(BOTH FROM c.surname)) AS full_name
	FROM
		sales s
	LEFT JOIN customer c ON
		s.customerkey = c.customerkey
	GROUP BY
		s.customerkey,
		s.orderdate,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
)
 SELECT
	customerkey,
	orderdate,
	net_revenue,
	num_orders,
	countryfull,
	age,
	full_name,
	min(orderdate) OVER (
		PARTITION BY customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;