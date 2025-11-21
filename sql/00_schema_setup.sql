# ==============================================================
# Database Creation and initialisation
# ==============================================================

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

# create database blinkit_db
create database if not exists blinkit_db;

# inspect the databases
show databases;

#use the required database
use blinkit_db;

# ==============================================================
# Table Creation and Population
# ==============================================================
# create table for blinkit customers
create table blinkit_customers(
	customer_id int unsigned,
	customer_name varchar(100) ,
    email varchar(120) ,
    phone varchar(20) ,
    address varchar(250) ,
    area varchar(100) ,
    pincode int ,
    registration_date date ,
    customer_segment varchar(20) ,
    total_orders int ,
    avg_order_value decimal(10 ,2 )
);

# describe the table
describe blinkit_customers;

# load customers' data 
load data local infile 'C:/E-Commerce SQL project/Ecommerce_SQL_Project/data/blinkit_customers.csv'
into table blinkit_customers
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n'
ignore 1 rows; 

# create table for blinkit orders
create table blinkit_orders(
	order_id bigint unsigned ,
    customer_id int unsigned,
    order_date datetime ,
    promised_delivery_time datetime ,
    actual_delivery_time datetime ,
    delivery_status varchar(30) ,
    order_total decimal(10 ,2 ) ,
    payment_method varchar(20) ,
    delivery_partner_id int ,
    store_id int unsigned
);

# describe the table
describe blinkit_orders;

# load orders dataset
load data local infile 'C:/E-Commerce SQL project/Ecommerce_SQL_Project/data/blinkit_orders.csv'
into table blinkit_orders
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n'
ignore 1 rows; 

# create table for order items
create table blinkit_order_items(
	order_id bigint unsigned ,
    product_id int unsigned ,
    quantity int ,
    unit_price decimal(10 ,2 ) 
);

# describe the table
describe  blinkit_order_items;

# load order_items dataset
load data local infile 'C:/E-Commerce SQL project/Ecommerce_SQL_Project/data/blinkit_order_items.csv'
into table blinkit_order_items
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n'
ignore 1 rows; 

# create table for blinkit_products
create table blinkit_products(
	product_id int unsigned ,
    product_name varchar(40) ,
    category varchar(50) ,
    brand varchar(100) ,
    price decimal(10 ,2 ) ,
    mrp decimal(10 ,2 ) ,
    margin_percentage float ,
    shelf_life_days int ,
    min_stock_level int ,
    max_stock_level int
);

# describe the table
describe blinkit_products;

# load data for blinkit_products
load data local infile 'C:/E-Commerce SQL project/Ecommerce_SQL_Project/data/blinkit_products.csv'
into table blinkit_products
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n'
ignore 1 rows; 


# create table for blinkit_customer_feedback
create table blinkit_customer_feedback(
	feedback_id int unsigned ,
    order_id bigint unsigned ,
    customer_id int unsigned ,
    rating int ,
    feedback_text varchar(400) ,
    feedback_category varchar(40) ,
    sentiment varchar(20) ,
    feedback_date date
);

# load data for customer feedback
load data local infile 'C:/E-Commerce SQL project/Ecommerce_SQL_Project/data/blinkit_customer_feedback.csv'
into table blinkit_customer_feedback
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\r\n'
ignore 1 rows; 

show tables;

# ==============================================================
# Adding Primary Keys 
# ==============================================================

# blinkit_customers table 
# adding primary key customer id

alter table blinkit_customers
add constraint primary key(customer_id);

# blinkit_orders table
# adding primary key order id

alter table blinkit_orders
add constraint primary key(order_id);

# blinkit_order_items table
# adding primary key order id and product id

alter table blinkit_order_items
add constraint primary key(order_id ,product_id );

# blinkit_products table
# adding primary key product id

alter table blinkit_products
add constraint primary key(product_id);

# blinkit_customer_feedback table
# adding primary key feedback id

alter table blinkit_customer_feedback
add constraint primary key(feedback_id);

# ==============================================================
# Adding Foreign Keys
# ==============================================================

alter table blinkit_orders
add constraint fk_orders_customer
foreign key(customer_id)
references blinkit_customers(customer_id);

alter table blinkit_order_items
add constraint fk_orderitems_order
foreign key(order_id)
references blinkit_orders(order_id);

alter table blinkit_order_items
add constraint fk_orderitems_product
foreign key(product_id)
references blinkit_products(product_id);

alter table blinkit_customer_feedback
add constraint fk_feedback_order
foreign key(order_id)
references blinkit_orders(order_id);

alter table blinkit_customer_feedback
add constraint fk_feedback_customer
foreign key(customer_id)
references blinkit_customers(customer_id);