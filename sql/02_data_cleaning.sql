# ==============================================================
# Data Cleaning
# ==============================================================

show databases;

use blinkit_db;

show tables;


# Safe Copy

create table if not exists blinkit_customers_cln      		as select * from blinkit_customers;
create table if not exists blinkit_orders_cln         		as select * from blinkit_orders;
create table if not exists blinkit_order_items_cln    		as select * from blinkit_order_items;
create table if not exists blinkit_products_cln       		as select * from blinkit_products;
create table if not exists blinkit_customer_feedback_cln 	as select * from blinkit_customer_feedback;

# Write queries to identify and handle missing or inconsistent data.
# all null counts check
select
	sum(customer_id			is null) 			as null_customer_id ,
    sum(customer_name		is null)			as null_customer_name ,
    sum(email				is null)			as null_email ,
    sum(phone				is null)			as null_phone ,
	sum(address				is null)			as null_address ,
    sum(area				is null)			as null_area ,
    sum(pincode				is null)			as null_pincode ,
    sum(registration_date	is null)			as null_registration_date ,
    sum(customer_segment	is null)			as null_customer_segment ,
    sum(total_orders		is null)			as null_total_orders ,
    sum(avg_order_value		is null)			as null_avg_order_value
from blinkit_customers_cln;

select
	sum(order_id					is null)			as null_order_id ,
    sum(customer_id					is null)			as null_customer_id ,
    sum(order_date					is null)			as null_order_date ,
    sum(promised_delivery_time		is null)			as null_promised_delivery_time ,
    sum(actual_delivery_time		is null)			as null_actual_delivery_time ,
    sum(delivery_status				is null)			as null_delivery_status ,
    sum(order_total					is null)			as null_order_total ,
    sum(payment_method				is null)			as null_payment_method ,
    sum(delivery_partner_id			is null)			as null_delivery_partner_id ,
    sum(store_id					is null)			as null_store_id
from blinkit_orders_cln;

select
	sum(feedback_id					is null)			as null_feedback_id	 ,
    sum(order_id					is null)			as null_order_id ,
    sum(customer_id					is null)			as null_customer_id ,
    sum(rating						is null)			as null_rating ,
    sum(feedback_text				is null)			as null_feedback_text ,
    sum(feedback_category			is null)			as null_feedback_category ,
    sum(sentiment					is null)			as null_sentiment ,
    sum(feedback_date				is null)			as null_feedback_date 
from blinkit_customer_feedback_cln;

select
	sum(order_id					is null)			as null_order_id ,
    sum(product_id					is null)			as null_product_id ,
    sum(quantity					is null)			as null_quantity ,
    sum(unit_price					is null)			as null_unit_price
from blinkit_order_items_cln;

select
	sum(product_id					is null)			as null_product_id	 ,
    sum(product_name				is null)			as null_product_name ,
    sum(category					is null)			as null_category ,
    sum(brand						is null)			as null_brand ,
    sum(price						is null)			as null_price ,
    sum(mrp							is null)			as null_mrp ,
    sum(margin_percentage			is null)			as null_margin_percentage ,
    sum(shelf_life_days				is null)			as null_shelf_life_days ,
    sum(min_stock_level				is null)			as null_min_stock_level
from blinkit_products_cln;


# 0 Null Counts across all tables

# Duplicate entries
# Customers table
select customer_id ,count(*) as dup_count
from blinkit_customers_cln
group by customer_id
having count(*) > 1;

select email ,count(*) as dup_count
from blinkit_customers_cln
group by email
having count(*) > 1;

select phone ,count(*) as dup_count
from blinkit_customers_cln
group by phone
having count(*) > 1;

# Orders Table
select order_id ,count(*) as dup_count
from blinkit_orders_cln
group by order_id
having count(*) > 1;

# Orders Items Table
select order_id ,product_id ,count(*) as dup_count
from blinkit_order_items_cln
group by order_id ,product_id
having count(*) > 1;

# Products Table
select product_id ,count(*) as dup_count
from blinkit_products_cln
group by product_id 
having count(*) > 1;

# Duplicate Products by Names ,Brand and Category
select product_name ,brand ,category ,count(*) as dup_count
from blinkit_products_cln
group by product_name ,brand ,category
having count(*) > 1;

# Duplicate Customer feedback
select feedback_id ,count(*) as dup_count
from blinkit_customer_feedback_cln
group by feedback_id
having count(*) > 1;

# Duplicate email entries in customers table
# No other duplicate entries in other tables

select *
from blinkit_customers_cln
where email in (
	select email
	from blinkit_customers_cln
	group by email
	having count(*) > 1
);

# Standardize email field to get real duplicates

update blinkit_customers_cln
set email = lower(trim(email))
where email is not null;

# Recheck the real duplicates
select email ,count(*) as dup_count
from blinkit_customers_cln
group by email
having count(*) > 1;

# There are 8 records with same email records

# Duplicate Emails				Email Counts
# yashoda79@example.net			2
# ydevan@example.net			2
# ilad@example.net				2
# wvora@example.org				2