# ==============================================================
# Joins and Relationships
# ==============================================================

# 1) INNER JOIN — Customer lifetime value (customer + orders)

select
	bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    count(bo.order_id) as Number_Of_Orders ,
    round(sum(bo.order_total) ,2 ) as Lifetime_Revenue 
from blinkit_orders_cln as bo
inner join blinkit_customers_cln as bc
	on bo.customer_id = bc.customer_id
group by customer_id
order by Lifetime_Revenue desc;

# Rayaan Krishna 22210238 has the highest lifetime revenue of Rs. 21686.80

# 2) LEFT JOIN — Items per order including orders with zero items

select
	bo.order_id as Order_ID ,
    date(bo.order_date) as Order_Date ,
    sum(boi.quantity) as Number_Of_Items
from blinkit_orders_cln as bo
left join blinkit_order_items_cln as boi
	on bo.order_id = boi.order_id
group by bo.order_id
order by Number_Of_Items desc;

# Use Coalesce function to avoid NULL shown for orders that have 0 items 
# Wrap sum(quantity) in Coalesce function and give the 2nd argument as 0 (This dataset doesnt contain any orders with 0 items)

select
	bo.order_id as Order_ID ,
    date(bo.order_date) as Order_Date ,
    coalesce(sum(boi.quantity) ,0 ) as Number_Of_Items 
from blinkit_orders_cln as bo
left join blinkit_order_items_cln as boi
	on bo.order_id = boi.order_id
group by bo.order_id
order by Number_Of_Items desc;

# 3) RIGHT JOIN — Ensure we include every order (even if customer row missing)

select
	bo.order_id as Order_ID ,
    bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    round(bo.order_total ,2 ) as Order_Total 
from blinkit_customers_cln as bc
right join blinkit_orders_cln as bo
	on bc.customer_id = bo.customer_id
order by date(bo.order_date) desc;

# visualising this as left join

select
	bo.order_id as Order_ID ,
    bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    round(bo.order_total ,2 ) as Order_Total
from blinkit_orders_cln as bo
left join blinkit_customers_cln as bc
	on bo.customer_id = bc.customer_id
order by date(bo.order_date) desc;

# 4) CROSS JOIN — Hypothetical matrix (small sample)

select
	bp.product_name as Product_Name ,
    bc.area as Area
from blinkit_products_cln as bp
cross join blinkit_customers_cln as bc
limit 10;

# 5) SELF JOIN — Customers in the same city (pairs)

select
	a.customer_name as Customer_A ,
    b.customer_name as Customer_B ,
    a.area
from blinkit_customers_cln as a
join blinkit_customers_cln as b
	on a.area = b.area
order by a.city ,a.customer_id
limit 50;

# 6) FULL OUTER JOIN (simulation) — All product sales + orphan order_item

select
	bp.product_id as Product_ID ,
	bp.product_name as Product_Name ,
    sum(boi.quantity) as Units_Sold ,
    round(sum(boi.quantity * boi.unit_price)) as Sales
from blinkit_products_cln as bp
left join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
group by bp.product_id

union all

select
	boi.product_id as Product_ID ,
    null as Product_Name ,
    sum(boi.quantity) as Units_Sold ,
    round(sum(boi.quantity * boi.unit_price)) as Sales
from blinkit_order_items_cln as boi
left join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
where bp.product_id is null
group by boi.product_id
order by Sales desc;

# 7) All distinct product IDs seen in either table

select
	bp.product_id as Product_ID
from blinkit_products_cln as bp
left join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
group by product_id

union all

select
	boi.product_id as Product_ID
from blinkit_order_items_cln as boi
left join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
where bp.product_id is null
group by product_id
order by product_id;
    
# C. Products with zero sales (unsold) AND orphan items
# Business question: “Which products are unsold, and are there any order_items pointing to missing products?”

select
	bp.product_id as Product_ID ,
    bp.product_name as Product_Name
from blinkit_products_cln as bp
left join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
where boi.product_id is null
group by bp.product_id ,bp.product_name

union all

select
	boi.product_id as Product_ID ,
    null as Product_Name
from blinkit_order_items_cln as boi
left join blinkit_products_cln as bp
	on boi.product_id = bp.product_id
where bp.product_id is null
group by product_id

order by Product_ID;