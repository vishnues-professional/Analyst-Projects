----------------------------------------------------------------------------------------------------------------------------------------
/*
1. Change over time analysis	
- To track trends, growth, and changes in sales by year and month.
*/
----------------------------------------------------------------------------------------------------------------------------------------

		SELECT
			YEAR(order_date) AS order_year,
			MONTH(order_date) AS order_month,
			SUM(sales_amount) AS total_sales,
			COUNT(DISTINCT customer_key) AS total_customers,
			SUM(quantity) AS total_quantity
		FROM sales
		WHERE order_date IS NOT NULL
		GROUP BY YEAR(order_date), MONTH(order_date)
		ORDER BY YEAR(order_date), MONTH(order_date);


		-- FORMAT()
		SELECT
			FORMAT(order_date, 'yyyy-MMM') AS order_date,
			SUM(sales_amount) AS total_sales,
			COUNT(DISTINCT customer_key) AS total_customers,
			SUM(quantity) AS total_quantity
		FROM sales
		WHERE order_date IS NOT NULL
		GROUP BY FORMAT(order_date, 'yyyy-MMM')
		ORDER BY FORMAT(order_date, 'yyyy-MMM');
  

----------------------------------------------------------------------------------------------------------------------------------------
/*
2. Performance analysis
- Comparing the current value to a target value.
Analyze the yearly performance of products by comparing each product's  sales to both it's average sales performance and the previous year's sales.
*/
----------------------------------------------------------------------------------------------------------------------------------------

		WITH yearly_product_sales AS (
			SELECT
				YEAR(s.order_date) AS order_year,
				p.product_name,
				SUM(s.sales_amount) AS current_sales
			FROM sales s
			LEFT JOIN products p
				ON s.product_key = p.product_key
			WHERE s.order_date IS NOT NULL
			GROUP BY 
				YEAR(s.order_date),
				p.product_name
		)
		SELECT
			order_year,
			product_name,
			current_sales,
			AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
			current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
			CASE 
				WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
				WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
				ELSE 'Avg'
			END AS avg_change,
			LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
			current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
			CASE 
				WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
				WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
				ELSE 'No Change'
			END AS py_change
		FROM yearly_product_sales
		ORDER BY product_name, order_year;
  

----------------------------------------------------------------------------------------------------------------------------------------
/*
3. Part to whole analysis
- Find which categories contribute the most to overall sales.
*/
----------------------------------------------------------------------------------------------------------------------------------------

		WITH category_sales AS (
			SELECT
				p.category,
				SUM(s.sales_amount) AS total_sales
			FROM sales s
			LEFT JOIN products p
				ON p.product_key = s.product_key
			GROUP BY p.category
		)
		SELECT
			category,
			total_sales,
			SUM(total_sales) OVER () AS overall_sales,
			ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
		FROM category_sales
		ORDER BY total_sales DESC;

		data segmentaion
		segament products into cost ranges and count how many products fall into each segment
		WITH product_segments AS (
			SELECT
				product_key,
				product_name,
				cost,
				CASE 
					WHEN cost < 100 THEN 'Below 100'
					WHEN cost BETWEEN 100 AND 500 THEN '100-500'
					WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
					ELSE 'Above 1000'
				END AS cost_range
			FROM products
		)
		SELECT 
			cost_range,
			COUNT(product_key) AS total_products
		FROM product_segments
		GROUP BY cost_range
		ORDER BY total_products DESC;
 

----------------------------------------------------------------------------------------------------------------------------------------
/*
4. Group customers into 3 segments based on their spending  behaviour 
  VIP: at least 12 months of history and spending more than 5000.
  Regular : atleast 12 months of history but spending 5000 or less.
  New : life span less than 12 months. 
  find total number of customers for each group.
*/
----------------------------------------------------------------------------------------------------------------------------------------

		WITH customer_spending AS (
			SELECT
				c.customer_key,
				SUM(s.sales_amount) AS total_spending,
				MIN(order_date) AS first_order,
				MAX(order_date) AS last_order,
				DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
			FROM sales s
			LEFT JOIN customers c
				ON s.customer_key = c.customer_key
			GROUP BY c.customer_key
		)
		SELECT 
			customer_segment,
			COUNT(customer_key) AS total_customers
		FROM (
			SELECT 
				customer_key,
				CASE 
					WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
					WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
					ELSE 'New'
				END AS customer_segment
			FROM customer_spending
		) AS segmented_customers
		GROUP BY customer_segment
		ORDER BY total_customers DESC;
		 

----------------------------------------------------------------------------------------------------------------------------------------
/*
5. Build customer report
   Purpose:
    - This report consolidates key customer metrics and behaviours.

   Highlights:
   1. Gathers essential fields such as names, ages, and transaction details.
   2. Segments customers into categories (VIP, Regular, New) and age groups.
   3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
   4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
*/
----------------------------------------------------------------------------------------------------------------------------------------

		CREATE VIEW report_customers AS

		--Base Query: Retrieves core columns from tables
		WITH base_query AS(
		SELECT
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) age
		FROM sales s
		LEFT JOIN customers c
		ON c.customer_key = s.customer_key
		WHERE order_date IS NOT NULL)

		--Customer Aggregations: Summarizes key metrics at the customer level
		, customer_aggregation AS (
		SELECT 
			customer_key,
			customer_number,
			customer_name,
			age,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity,
			COUNT(DISTINCT product_key) AS total_products,
			MAX(order_date) AS last_order_date,
			DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
		FROM base_query
		GROUP BY 
			customer_key,
			customer_number,
			customer_name,
			age
		)
		SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE 
			 WHEN age < 20 THEN 'Under 20'
			 WHEN age between 20 and 29 THEN '20-29'
			 WHEN age between 30 and 39 THEN '30-39'
			 WHEN age between 40 and 49 THEN '40-49'
			 ELSE '50 and above'
		END AS age_group,
		CASE 
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment,
		last_order_date,
		--recency (months since last order)
		DATEDIFF(month, last_order_date, GETDATE()) AS recency,
		total_orders,
		total_sales,
		total_quantity,
		total_products
		lifespan,
		--average order value
		CASE WHEN total_sales = 0 THEN 0
			 ELSE total_sales / total_orders
		END AS avg_order_value,
		--average monthly spend
		CASE WHEN lifespan = 0 THEN total_sales
			 ELSE total_sales / lifespan
		END AS avg_monthly_spend
		FROM customer_aggregation
 

----------------------------------------------------------------------------------------------------------------------------------------
/*
6. Product report  
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
*/
----------------------------------------------------------------------------------------------------------------------------------------

		CREATE VIEW report_products AS
		--Base Query: Retrieves core columns from tables
		WITH base_query AS (
		SELECT
				s.order_number,
				s.order_date,
				s.customer_key,
				s.sales_amount,
				s.quantity,
				p.product_key,
				p.product_name,
				p.category,
				p.subcategory,
				p.cost
			FROM sales s
			LEFT JOIN products p
				ON s.product_key = p.product_key
			WHERE order_date IS NOT NULL 
		)

		--Product Aggregations: Summarizes key metrics at the product level
		, product_aggregations AS (
		SELECT
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
			MAX(order_date) AS last_sale_date,
			COUNT(DISTINCT order_number) AS total_orders,
			COUNT(DISTINCT customer_key) AS total_customers,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity,
			ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
		FROM base_query
		GROUP BY
			product_key,
			product_name,
			category,
			subcategory,
			cost
		)

		--Final Query: Combines all product results into one output
		SELECT 
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			last_sale_date,
			--recency
			DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
			CASE
				WHEN total_sales > 50000 THEN 'High-Performer'
				WHEN total_sales >= 10000 THEN 'Mid-Range'
				ELSE 'Low-Performer'
			END AS product_segment,
			lifespan,
			total_orders,
			total_sales,
			total_quantity,
			total_customers,
			avg_selling_price,
			-- Average Order Revenue (AOR)
			CASE 
				WHEN total_orders = 0 THEN 0
				ELSE total_sales / total_orders
			END AS avg_order_revenue,
			-- Average Monthly Revenue
			CASE
				WHEN lifespan = 0 THEN total_sales
				ELSE total_sales / lifespan
			END AS avg_monthly_revenue
		FROM product_aggregations 

----------------------------------------------------------------------------------------------------------------------------------------