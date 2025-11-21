# ==============================================================
# Aggregation and Grouping:
# ==============================================================

# drop original tables
drop table blinkit_customers;
drop table blinkit_orders;
drop table blinkit_order_items;
drop table blinkit_products;
drop table blinkit_customer_feedback ;

# First defining relations for the cleaned tables

alter table blinkit_customers_cln
add constraint primary key(customer_id);

# blinkit_orders table
# adding primary key order id

alter table blinkit_orders_cln
add constraint primary key(order_id);

# blinkit_order_items table
# adding primary key order id and product id

alter table blinkit_order_items_cln
add constraint primary key(order_id ,product_id );

# blinkit_products table
# adding primary key product id

alter table blinkit_products_cln
add constraint primary key(product_id);

# blinkit_customer_feedback table
# adding primary key feedback id

alter table blinkit_customer_feedback_cln
add constraint primary key(feedback_id);

# ==============================================================
# Adding Foreign Keys
# ==============================================================

alter table blinkit_orders_cln
add constraint fk_orders_customer
foreign key(customer_id)
references blinkit_customers_cln(customer_id);

alter table blinkit_order_items_cln
add constraint fk_orderitems_order
foreign key(order_id)
references blinkit_orders_cln(order_id);

alter table blinkit_order_items_cln
add constraint fk_orderitems_product
foreign key(product_id)
references blinkit_products_cln(product_id);

alter table blinkit_customer_feedback_cln
add constraint fk_feedback_order
foreign key(order_id)
references blinkit_orders_cln(order_id);

alter table blinkit_customer_feedback_cln
add constraint fk_feedback_customer
foreign key(customer_id)
references blinkit_customers_cln(customer_id);

# Use GROUP BY to aggregate data by different dimensions.

# 1) Revenue & orders by day / month

select
	date(order_date) as Order_Day ,
	round(sum(order_total) ,2 ) as Daily_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Day      # or u can use count(*) as well
from blinkit_orders_cln
group by date(order_date)
order by Order_Day;

# Number of orders per day is usually below 10 for most days 
# With the number going to double digits occasionally on some days

select
	date(order_date) as Order_Day ,
	round(sum(order_total) ,2 ) as Daily_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Day      # or u can use count(*) as well
from blinkit_orders_cln
group by date(order_date)
order by Daily_Revenue desc;

# The Maximum daily revenue Rs. 46926.32 was on 31st March 2024 and there were 17 orders that day

select
	date(order_date) as Order_Day ,
	round(sum(order_total) ,2 ) as Daily_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Day      # or u can use count(*) as well
from blinkit_orders_cln
group by date(order_date)
order by Number_Of_Orders_Per_Day desc;

# number of orders per day varies from 1 order per day to 17 per day 

select
	date_format(order_date ,'%Y-%M') as Order_Year_Month ,
    round(sum(order_total) ,2 ) as Monthly_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Month	# or u can use count(*) as well
from blinkit_orders_cln
group by date_format(order_date ,'%Y-%M')
order by Order_Year_Month;							# sorts it alphabetically

# Or if you want months sorted numerically

select
	date_format(order_date ,'%Y-%m') as Order_Year_Month ,
    round(sum(order_total) ,2 ) as Monthly_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Month	# or u can use count(*) as well
from blinkit_orders_cln
group by date_format(order_date ,'%Y-%m')
order by Order_Year_Month;

# or if you want to sort them numerically without losing the month name
select
	date_format(min(order_date) ,'%Y-%M' ) as Order_Year_Month ,
    round(sum(order_total) ,2 ) as Monthly_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Month
from blinkit_orders_cln
group by year(order_date) ,month(order_date)
order by year(order_date) ,month(order_date);

select
	date_format(order_date ,'%Y-%M' ) as Order_Year_Month ,
    round(sum(order_total) ,2 ) as Monthly_Revenue ,
    count(order_id) as Number_Of_Orders_Per_Month
from blinkit_orders_cln
group by Order_Year_Month
order by Monthly_Revenue desc;

# August 2023 had the Highest Monthly Revenue at Rs. 623472.35 with 285 orders

# 2) Orders & revenue by status / payment method

# By Payment method

select
    payment_method as Payment_Type ,
    count(order_id) as Number_Of_Orders ,
    round(sum(order_total) ,2 ) as Revenue
from blinkit_orders_cln
group by payment_method
order by Revenue desc;

# Card Payment Method has seen the most revenue at Rs. 2865557.53
# Followed by Cash ,Wallet and UPI

# by Delivery Status

select
	delivery_status as Delivery_Status ,
    count(order_id) as Number_Of_Orders ,
    round(sum(order_total) ,2 ) as Revenue
from blinkit_orders_cln
group by delivery_status
order by Revenue desc;

# 3470 orders were on time
# Indicating that most of the deliveries were "On Time"
# On Time deliveries also generated the highest revenue

# 1037 deliveries were slighlty delayed
# These type of deliveries generated the second highest revenue

# 493 of the deliveries were significantly delayed
# These types of deliveries also generated the least amount of revenue

# Indicating Orders Delivered on time were more lucrative compared to their delayed counterparts

# 3) Customer-level metrics (lifetime)

# Customer Value

# blinkit_orders table because the order counts and other details are not consistent across tables in this database
# only using customer names from blinkit_customers table to get names via joins

select
	bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    count(bo.order_id) as Total_Number_Of_Orders ,
    round(sum(bo.order_total) ,2 ) as Total_Lifetime_Revenue ,
    round(sum(bo.order_total)/count(bo.order_id) ,2 ) as Average_Revenue_Per_Order
from blinkit_orders_cln as bo
join blinkit_customers_cln as bc
	on bo.customer_id = bc.customer_id
group by bo.customer_id
order by Total_Lifetime_Revenue desc;

# Customer Number 22210238 Rayaaan Krishna is the most valuable customer
# Has 6 orders to his name and a
# Total Lifetime Revenue of Rs. 21686.80 and 
# He spends Rs. 3614.47 per order

# 4) Items sold & revenue by product

# using blinkit_order_items table because the order counts and other details are not consistent across tables in this database
# only using product names from blinkit_products table to get names via joins

select
	boi.product_id as Product_ID ,
    bp.product_name as Product_Name ,
    sum(boi.quantity) as Quantity_Sold ,
    round(sum(boi.unit_price*boi.quantity) ,2 ) as Revenue_Per_Item
from blinkit_order_items_cln as boi
join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
group by product_id
order by Revenue_Per_Item desc;

# use this query if you want the unit price per item also to be displayed
# using max and min are suitable workarounds when the unit price entries for the same product id are consistent
# So using Max or Min doesnt make a difference when all those entries are same 

select
	boi.product_id as Product_ID ,
    bp.product_name as Product_Name ,
    sum(boi.quantity) as Quantity_Sold ,
    round(max(boi.unit_price) ,2 ) as Price_Per_Item ,
    round(sum(boi.unit_price*boi.quantity) ,2 ) as Revenue_Per_Item
from blinkit_order_items_cln as boi
join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
group by product_id 
order by Revenue_Per_Item desc;

# Baby Food generated the most revenue with Rs. 65212.70

# 5) Sales by category / brand

# By Category

select
	bp.category as Product_Category ,
    sum(boi.quantity) as Number_Of_Units_Sold ,
    round(sum(boi.quantity * boi.unit_price) ,2 ) as Sales_Revenue
from blinkit_products_cln as bp
join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
group by bp.category
order by Sales_Revenue desc;

# Dairy & Breakfast had the highest sales revenue at Rs. 6,39,222.19
# It sold over 1114 units

# By Brand

select
	bp.brand as Product_Brand ,
    sum(boi.quantity) as Number_Of_Units_Sold ,
    round(sum(boi.quantity * boi.unit_price) ,2 ) as Sales_Revenue
from blinkit_products_cln as bp
join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
group by bp.brand
order by Sales_Revenue desc;

# Karnik PLC brand generated the highest sales revenue at Rs. 65212.70
# It sold over 70 units

# 6) City-level performance

select
	bc.area as Cities ,
    count(distinct bo.order_id) as Number_Of_Orders ,
	round(sum(bo.order_total) ,2 ) as Revenue 
from blinkit_customers_cln as bc
join blinkit_orders_cln as bo
	on bc.customer_id = bo.customer_id
group by bc.area
order by Revenue desc;

# Orai has the highest amount of revenue with 44 orders

# 7) Store / Delivery partner performance

# By Store Performance
select
	store_id as Store_ID ,
    round(sum(order_total) ,2 ) as Revenue
from blinkit_orders_cln
group by store_id
order by Revenue desc;

# By Delivery Partner 
select
	delivery_partner_id as Delivery_Partner_ID ,
    round(sum(order_total) ,2 ) as Revenue
from blinkit_orders_cln
group by delivery_partner_id
order by Revenue desc;

# 8) Items per order (distribution buckets)


select
	order_id as Order_ID ,
	sum(quantity) as Number_Of_Items
from blinkit_order_items_cln
group by order_id
order by Number_Of_Items desc;

#or 
# joining with orders table 
select
	bo.order_id as Order_ID ,
    sum(boi.quantity) as Number_Of_Items
from blinkit_order_items_cln as boi
join blinkit_orders_cln as bo
	on boi.order_id = bo.order_id
group by bo.order_id
order by Number_Of_Items desc;

# An order had 3 items at the maximum

# 9) Feedback aggregation

# Overall Average Feedback Rating

select round(avg(rating) ,2 ) as Average_Feedback_Rating
from blinkit_customer_feedback_cln;

# Overall Average Feedback Rating is 3.34

# Average Feedback Rating by Category

select
	feedback_category as Feedback_Type ,
    round(avg(rating) ,2 ) as Average_Rating 
from blinkit_customer_feedback_cln
group by feedback_category
order by Average_Rating desc;

# Customer service has the highest average rating 

# 10) New customers per month

select 
	date_format(min(registration_date) ,'%Y-%M' ) as Registered_Month ,
    count(customer_id) as Number_of_Customers_Registered
from blinkit_customers_cln
group by year(registration_date) ,month(registration_date)
order by year(registration_date) ,month(registration_date);

select
	date_format(min(registration_date) ,'%Y-%M' ) as Registered_Month ,
    count(customer_id) as Number_Of_Customers_Registered
from blinkit_customers_cln
group by year(registration_date) ,month(registration_date)
order by Number_Of_Customers_Registered desc;
    
# March 2024 saw the highest number of registrations by customers
# There were 178 registrations in March 2024

# 11) High-value customers (example threshold)

# List of all high value customers
# High value customers
select
	bc.customer_id as Customer_ID ,
	bc.customer_name as Customer_Name ,
	round(sum(bo.order_total) ,2 ) as Lifetime_Revenue
from blinkit_customers_cln as bc
join blinkit_orders_cln as bo
	on bc.customer_id = bo.customer_id
group by bc.customer_id
having Lifetime_Revenue > 5000
order by Lifetime_Revenue desc;
		
# Count of high value customers
select count(*)
from (
	select
		bc.customer_id as Customer_ID ,
		bc.customer_name as Customer_Name ,
		round(sum(bo.order_total) ,2 ) as Lifetime_Revenue
	from blinkit_customers_cln as bc
	join blinkit_orders_cln as bo
		on bc.customer_id = bo.customer_id
	group by bc.customer_id
	having Lifetime_Revenue > 5000
	order by Lifetime_Revenue desc
)as derived;

# There are 958 high value customers

# 12) Margin estimate by category (if margin_percentage is in products)

select
	bp.category as Product_Category ,
    round(sum(boi.quantity * boi.unit_price * (bp.margin_percentage/100.0)) ,2 ) as Estimated_Margin
from blinkit_order_items_cln as boi
join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
group by bp.category
order by Estimated_Margin desc;

# Pet care had the highest profit margin