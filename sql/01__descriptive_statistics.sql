# ==============================================================
# Descriptive Statistics
# ==============================================================

-- Write queries to calculate basic statistics such as count, sum, average, minimum, and maximum for numerical columns.
-- Example: Calculate the total sales, average order value, and total number of transactions.


use blinkit_db;

show tables;

# 1.What is the total number of orders placed?

# simplest way to do 
select count(*)
from blinkit_orders;

# simplest way to do using alias
select count(*) as Total_Number_Of_Orders 
from blinkit_orders;

# Safer way to do incase of duplicates without using alias
select count(distinct order_id)
from blinkit_orders;

# Safer way to do incase of duplicates using an alias
select count(distinct order_id) as Total_Number_Of_Orders
from blinkit_orders;

# 2.What is the total sales revenue generated?

# simplest way to do it
select sum(order_total)
from blinkit_orders;

# simplest way to do it using an alias
select sum(order_total) as Total_Revenue_From_Orders
from blinkit_orders;

# safer way Incase of duplicate entries
select sum(order_total)
from(select distinct *from blinkit_orders) 
as All_Orders;

# safer way Incase of duplicate entries and using an alias
select sum(order_total) as Total_Revenue_From_Orders
from(select distinct *from blinkit_orders) 
as All_Orders;

# 3. What is the average, minimum, and maximum order value?

# average ,simplest way
select avg(order_total)
from blinkit_orders;

# average ,simplest way with alias
select avg(order_total) as Average_Revenue_From_Orders
from blinkit_orders;

# average ,safe way incase of duplicates 
select avg(order_total)
from (select distinct * from blinkit_orders)
as All_Orders;

# average ,safe way incase of duplicates using alias
select avg(order_total) as Average_Revenue_From_Orders
from (select distinct * from blinkit_orders)
as All_Orders;

# min ,simplest way
select min(order_total)
from blinkit_orders;

# min ,simplest way using an alias
select min(order_total) as Minimum_Revenue_From_Orders
from blinkit_orders;

# min ,safe way incase of duplicates
select min(order_total) 
from (select distinct * from blinkit_orders)
as All_Orders;

# min ,safe way incase of duplicates using alias
select min(order_total) as Minimum_Revenue_From_Orders
from (select distinct * from blinkit_orders)
as All_Orders;

# max ,simplest way
select max(order_total)
from blinkit_orders;

# max ,simplest way using alias
select max(order_total) as Maximum_Revenue_From_Orders
from blinkit_orders;

# max ,safe way incase of duplicates
select max(order_total)
from (select distinct * from blinkit_orders)
as All_Orders;

# max ,safe way incase of duplicates using alias
select max(order_total) as Maximum_Revenue_From_Orders
from (select distinct * from blinkit_orders)
as All_Orders;

# 4. What is the average number of orders per customer?

select avg(Number_Of_Orders) as Average_Number_Of_Orders_Per_Customer
from (
	select 
		customer_id ,
		count(order_id) as Number_Of_Orders
	from blinkit_orders
	group by customer_id
)as All_Customers;


# 5. What is the total number of unique customers who placed an order?

# simplest cleanest and best way to do 
select count(distinct customer_id)
from blinkit_orders;

# simplest cleanest and best way to do ,using an alias
select count(distinct customer_id) as Total_Number_Of_Unique_Customers
from blinkit_orders;

# using subquery ,without alias for customer_id
select count(customer_id) as Total_Number_Of_Unique_Customers
from (
	select 
		distinct customer_id 
	from blinkit_orders
)as All_Customers;

# using subquery ,using alias for customer_id
select count(unique_customers) as Total_Number_Of_Unique_Customers
from (
	select 
		distinct customer_id as unique_customers
	from blinkit_orders
)as All_Customers;

# 6. What is the total number of customers in the dataset?

# simplest way to do (no duplicates)
select count(*) 
from blinkit_customers;

# simplest way to do (no duplicates) ,using alias
select count(*) as Total_Number_Of_Customers
from blinkit_customers;

# simplest easiest and safest way incase of duplicates
select count(distinct customer_id) 
from blinkit_customers;

# simplest easiest and safest way incase of duplicates, using alias
select count(distinct customer_id) as Total_Number_Of_Customers
from blinkit_customers;

# 7. What is the average, minimum, and maximum total orders per customer?

# average orders per customer

# simplest way to do
select avg(total_orders)
from blinkit_customers;

# simplest way to do ,using an alias
select avg(total_orders) as Average_Number_Of_Orders_Per_Customer
from blinkit_customers;

# safe way to do incase of duplicates
select avg(Order_Number)
from(
	select
		distinct customer_id ,
        total_orders as Order_Number
	from blinkit_customers
)as All_Customers;

# safe way to do incase of duplicates ,using alias for avg(Order_Number)
select avg(Order_Number) as Average_Orders_Per_Customer
from(
	select
		distinct customer_id ,
        total_orders as Order_Number
	from blinkit_customers
)as All_Customers;

# minimum orders per customer

# simplest way to do
select min(total_orders)
from blinkit_customers;

# simplest way to do using alias
select min(total_orders) as Minimum_Number_Of_Orders
from blinkit_customers;

# Safest way to do incase of duplicates
select min(Order_Number)
from(
	select
		distinct customer_id ,
        total_orders as Order_Number
	from blinkit_customers
) as All_Customers;

# Safest way to do incase of duplicates, using alias for min(Order_Count)
select min(Order_Number) as Minimum_Number_Of_Orders
from(
	select
		distinct customer_id ,
        total_orders as Order_Number
	from blinkit_customers
) as All_Customers;

# max orders per customer

# simplest way 
select max(total_orders) 
from blinkit_customers;

# simplest way using alias
select max(total_orders) as Maximum_Number_Of_Orders
from blinkit_customers;

# safest way to incase of duplicates
select max(Order_Count)
from(
	select
		distinct customer_id ,
        total_orders as Order_Count
	from blinkit_customers
) as All_Customers;

# safest way to incase of duplicates, using an alias for max(Order_Count)
select max(Order_Count) as Maximum_Number_Of_Orders
from(
	select
		distinct customer_id ,
        total_orders as Order_Count
	from blinkit_customers
) as All_Customers;

# shall be ignoring alias and nick name distinctions from henceforth
# for simplicity and to progress faster

# 8. What is the average customer lifetime value (average of `avg_order_value`)?

# simplest way 
select avg(avg_order_value) as Average_Customer_Lifetime_Value
from blinkit_customers;

# safest way incase of duplicates
select avg(Average_Value) as Average_Customer_Lifetime_Value
from(
	select
		distinct customer_id ,
        avg_order_value as Average_Value
	from blinkit_customers
) as All_Customers;

# 9. How many customers belong to each customer segment (`customer_segment`)?

select 
	customer_segment as Customer_Type ,
    count(customer_id) as No_of_Customers_Of_Each_Type
from blinkit_customers
group by customer_segment;

# 10. Which customer segment contributes the most to total revenue?

# simplest way to do 
select
	customer_segment as Customer_Type ,
    sum(total_orders * avg_order_value) as Total_Revenue_By_Type
from blinkit_customers
group by customer_segment
order by Total_Revenue_By_Type desc;

# "New" customer segment type contributes the most to total revenue

# Answering to the point and i directly want the max revenue entry

select
	customer_segment as Customer_Type ,
    sum(total_orders * avg_order_value) as Total_Revenue_Contribution
from blinkit_customers
group by customer_segment
order by Total_Revenue_contribution desc
limit 1;

# 11. What is the total number of products listed?

select count(*) as Total_Number_Of_Products_Listed 
from blinkit_products;

# Total number of unique products

select count(distinct product_name) as Total_Number_Of_Unique_Products
from blinkit_products;

# Total Number of product categories

select count(distinct category) as Number_Of_Product_Catgories
from blinkit_products;

# Total Number of Unique Brands

select count(distinct brand) as Number_Of_Unique_Brands
from blinkit_products;

# 12. What are the average, minimum, and maximum product prices?

# average

select avg(price) as Average_Product_Price
from blinkit_products;

# minimum

select min(price) as Minimum_Product_Price
from blinkit_products;

# maximum

select max(price) as Maximum_Product_Price
from blinkit_products;

# 13. What is the average margin percentage across all products?

select round(avg(margin_percentage) ,2 ) as Average_Margin_Percentage_Across_All_Products
from blinkit_products;

# 14. How many products belong to each category?

select 
	category as Product_Category ,
    count(*) as Number_Of_Products_Per_Category
from blinkit_products
group by category
order by Number_Of_Products_Per_Category desc;

# 15. Which category generates the highest average product price?

select 
	category as Product_Category ,
	round(avg(price) ,2 ) as Average_Product_Price_Per_Category
from blinkit_products
group by category
order by Average_Product_Price_Per_Category desc
limit 1;

# 16. How many orders were placed each month?

# simplest way ,collective monthwise regardless of year
select
	month(order_date) as Month ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by month(order_date);

# more safe way to order it monthwise (wont change much)
select
	month(order_date) as Month ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by month(order_date)
order by month;

# detailed version with year order
select
	year(order_date) as Year ,
    month(order_date) as Month ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by year(order_date) ,month(order_date);

# A more safer way to do the same with order
select
	year(order_date) as Year ,
    month(order_date) as Month ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by year(order_date) ,month(order_date)
order by year ,month ;

# if you want month and years instead of numbers ,more exhaustive way to do
select
	date_format(order_date ,"%Y" ) as Year ,
    date_format(order_date ,"%M" ) as Month ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by Year ,Month 
order by min(order_date) ;

# or

select 
	date_format(order_date ,"%Y-%M" ) as Month_Year ,
    count(distinct order_id) as Number_Of_Orders_Per_Month
from blinkit_orders
group by Month_Year
order by min(order_date) ;

# 17. What is the total and average sales per month?

select 
	date_format(order_date ,"%Y" ) as Year ,
    date_format(order_date ,"%M" ) as Month ,
    sum(order_total) as Total_Sales_Per_Month ,
    round((sum(order_total)/count(distinct order_id)) ,2 ) as Average_Sales_Per_Month
from blinkit_orders
group by Year ,Month
order by min(order_date) ;

# 18. Which month had the highest sales?

select
	date_format(order_date ,"%M" ) as Month ,
    sum(order_total) as Total_Sales_Per_Month
from blinkit_orders
group by month
order by Total_Sales_Per_Month
limit 1 ;

# 19. What is the average delivery delay (difference between promised and actual delivery times)?

# in minutes
select
	avg(Delay_In_Minutes) as Avg_Delay_In_Minutes
from(
	select
		timestampdiff(minute ,promised_delivery_time ,actual_delivery_time ) as Delay_In_Minutes
	from blinkit_orders
)as Delay
where Delay_In_Minutes >= 0;

# in seconds
select
	avg(Delay_In_Seconds) as Avg_Delay_In_Seconds
from(
	select
		timestampdiff(second ,promised_delivery_time ,actual_delivery_time ) as Delay_In_Seconds
	from blinkit_orders
)as Delay
where Delay_In_Seconds >= 0;

# in hours
select
	avg(Delay_In_Hours) as Avg_Delay_In_Hours
from(
	select
		timestampdiff(hour ,promised_delivery_time ,actual_delivery_time ) as Delay_In_Hours
	from blinkit_orders
)as Delay
where Delay_In_Hours >= 0;

# average delay is 7.8292 minutes or 469.75 seconds 

# 20. Which months had the highest average delay in delivery?

select
	Year ,
    Month ,
	avg(Delay_In_Minutes) as Avg_Delay_In_Minutes_Per_Month
from(
	select
		date_format(order_date ,"%Y" ) as Year ,
		date_format(order_date ,"%M" ) as Month ,
		timestampdiff(minute ,promised_delivery_time ,actual_delivery_time ) as Delay_In_Minutes
	from blinkit_orders
)as Delay
where Delay_In_Minutes >= 0
group by Year ,Month
order by Avg_Delay_In_Minutes_Per_Month desc;

# 21. What percentage of orders were delivered on time vs delayed?

# simpler query
SELECT
  ROUND(100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, promised_delivery_time, actual_delivery_time) <= 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Percentage_Of_Deliveries_On_Time,
  ROUND(100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, promised_delivery_time, actual_delivery_time) >  0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Percentage_Of_Deliveries_delayed
FROM blinkit_orders;

# exhaustive query ,not null check not needed
SELECT
  ROUND(100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, promised_delivery_time, actual_delivery_time) <= 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_on_time,
  ROUND(100.0 * SUM(CASE WHEN TIMESTAMPDIFF(SECOND, promised_delivery_time, actual_delivery_time) >  0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_delayed
FROM blinkit_orders
WHERE promised_delivery_time IS NOT NULL
  AND actual_delivery_time   IS NOT NULL;

# 22. What is the average time taken for delivery (in hours or days)?

select
	avg(timestampdiff(minute ,order_date ,actual_delivery_time )/60) as Average_Delivery_Time_In_Hours
from blinkit_orders;

# 23. Which delivery partner (`delivery_partner_id`) handled the most orders?

select
	delivery_partner_id as Delivery_Partner ,
    count(*) as Number_Of_Orders
from blinkit_orders
group by delivery_partner_id
order by Number_Of_Orders desc
limit 1;

# 24. What is the total number of feedback records?

select count(distinct feedback_id) as Total_Number_Of_Feedbacks
from blinkit_customer_feedback;

# 25. What is the average, minimum, and maximum rating?

select
	avg(rating) as Average_Rating ,
    max(rating) as Max_Rating ,
    min(rating) as Min_Rating
from blinkit_customer_feedback;

# 26. How many feedbacks belong to each sentiment (`Positive`, `Negative`, `Neutral`)?

select
	sentiment as Customer_Sentiment ,
    count(*) as Number_Of_Feedbacks
from blinkit_customer_feedback
group by sentiment;

# 27. Which feedback category (`feedback_category`) received the lowest average rating?

select
	feedback_category as Feedback_Type ,
    avg(rating) as Average_Rating_Per_Feedback_Type
from blinkit_customer_feedback
group by feedback_category
order by Average_Rating_Per_Feedback_Type asc
limit 1;

# 28. What percentage of total feedbacks are positive?

select round(100.0 * (sum(case when sentiment = "Positive" then 1 else 0 end)/count(*)) ,2 ) as Percentage_Of_Positive_Feedbacks 
from blinkit_customer_feedback;

-- SELECT 
--   ROUND(100.0 * SUM(CASE WHEN sentiment = 'Positive' THEN 1 ELSE 0 END) / COUNT(*), 2) 
--   AS Percentage_Of_Positive_Feedbacks
-- FROM blinkit_customer_feedback;

# 29. What is the total quantity of each product sold?

select
	product_id as Product_ID ,
    sum(quantity) as Quantity_Of_Each_Product
from blinkit_order_items
group by product_id;

# 30. What is the total revenue generated per product (`quantity × unit_price`)?

select
	product_id as Product_ID ,
    sum(quantity) as Quantity_Of_Each_Product ,
    sum(quantity * unit_price) as Revenue_Per_Product
from blinkit_order_items
group by product_id;

# 31. Which 5 products generated the highest total revenue?

select
	product_id as Product_ID ,
    sum(quantity) as Quantity_Of_Product ,
    sum(quantity * unit_price) as Total_Revenue_Per_Product
from blinkit_order_items
group by product_id
order by Total_Revenue_Per_Product desc
limit 5;

# 32. What is the average quantity of items per order?

select round(sum(quantity)/count(distinct order_id) ,2 ) as Average_Quantity_Of_Items_Per_Order
from blinkit_order_items;

# 33. What is the overall profit margin percentage across all sales?

select
	round(((sum((P.margin_percentage/100) * (OI.quantity * OI.unit_price)) / sum(OI.quantity * OI.unit_price))*100) ,2 ) as Overall_Profit_Margin_Percentage
from blinkit_products P 
join blinkit_order_items OI
on P.product_id = OI.product_id;

# 34. How many customers are from each city /Place?

select
	area as Place ,
    count(customer_id) as Number_Of_Customers
from blinkit_customers
group by Place
order by Number_Of_Customers desc;

# 37. Which area has the highest number of customers?

select
	area as Place ,
    count(customer_id) as Number_Of_Customers
from blinkit_customers 
group by Place
order by Number_Of_Customers desc
limit 1;   

# 38. Which region contributes the most to total sales revenue?

select
	area as Place ,
    sum(total_orders * avg_order_value) as Total_Revenue_Per_Region
from blinkit_customers
group by place
order by Total_Revenue_Per_Region desc
limit 1;