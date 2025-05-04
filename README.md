# Analyst-Projects
1. Sales Analytics with SQL

Overview : 
	This project demonstrates advanced SQL techniques to analyze sales data. The goal is to extract business insights through time based trends, customer segmentation, product performance, and category level contributions using complex queries and views.

Objectives : 
	Analyze change in sales over time.
	Compare product performance year over year.
	Segment customers by behavior and spending.
	Measure category contributions to total revenue.
	Build detailed customer and product reports.

Tools & Technologies : 
	SQL Server, 
	SQL Views, CTEs, Window Functions

Data Source : 
	sales database (sales, products, customers). 

Key Analyses & Queries : 
	1. Change Over Time Analysis - 
		Track monthly sales, customer counts, and units sold to detect growth patterns and seasonality. 
  	2. Performance vs Target - 
		Use window functions (LAG, AVG OVER) to compare product performance against past years and average performance. 
  	3. Part to Whole Analysis - 
		Identify top categories contributing to total sales and calculate each one's percentage share. 
  	4. Customer Segmentation - 
		Classify customers as VIP, Regular, or New based on their lifetime value and activity history. 
  	5. Customer Report View - 
		Build a view summarizing customer behavior, including: 
  	Total sales, 
		Recency, 
		Average Order Value (AOV), 
		Average Monthly Spend, 
		Age and segment classification. 
  	6. Product Report View - 
		Comprehensive product performance view with KPIs like : 
  	Revenue segmentation (High/Mid/Low), 
		Total orders and quantity, 
		Recency of last sale, 
		Average monthly revenue.


  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


2. Sales Analysis Dashboard 

Overview : 
	This project is a simple, dynamic and interactive Sales Analysis Dashboard built using Power BI, focused on the year 2023. It brings together data from employees, locations, and sales transactions to uncover trends, performance insights, and regional comparisons. 

Data Sources : 
	Sales – includes transaction level data such as sales amount, quantity and customers, 
	EmployeeData – contains salespeople details and team associations, 
	Locations – maps countries to broader regions (Americas, APAC, Europe).

Key Questions Answered : 
	How much did we sell in 2023?.   
	Which teams and salespeople contributed most to the revenue?.    
	Which products and categories performed best?.   
	How are sales distributed across regions?.  
	How did sales trend over the months?. 

Dashboard Features : 
	Total Sales - 			Card visual showing the total revenue generated in 2023. 
	Total Quantity 	Sold - 		Card visual showing the total number of units sold. 
	Total Profit - 			Card visual displaying the total profit generated during 2023. 
	Top 5 Selling Products - 	Donut chart showcasing the five products with the highest sales volume. 
	Top 5 Salespeople - 		Donut chart highlighting the top five performers by total sales. 
	Sales by Region	- 		Pie chart representing the share of total sales from APAC, Americas, and Europe. 
	Sales by Geography - 		Stacked column chart comparing sales performance across countries. 
	Sales Trend Analysis -		Line chart showing month wise sales trend for 2023. 

Filters/Slicers	Easily filter dashboard by :
	Team, 
	Product Category, 
	Time Period. 

Tools & Technologies
	Power BI Desktop, 
	Power Query – for data transformation, 
	DAX – for calculated columns and KPIs, 
	Custom Visuals – line charts, bar charts, KPIs, slicers.
		
  
