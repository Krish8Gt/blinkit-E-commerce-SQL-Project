# ==============================================================
# Subqueries and CTEs
# ==============================================================

# Which customers have lifetime revenue greater than the average customer lifetime revenue?

select
	bc.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    coalesce(round(sum(bo.order_total) ,2 ) ,0 ) as Lifetime_Revenue 
from blinkit_customers_cln as bc
left join blinkit_orders_cln as bo
	on bc.customer_id = bo.customer_id
group by Customer_ID ,Customer_Name
having Lifetime_Revenue >(
	select
		sum(order_total)/(select count(distinct customer_id) from blinkit_customers_cln) as Average_Lifetime_Revenue
	from blinkit_orders_cln
    )
order by Lifetime_Revenue desc;

# Products that sell more units than the average units sold per product

select
	bp.product_id as Product_ID ,
    bp.product_name as Product_Name ,
    coalesce(sum(boi.quantity) ,0 ) as Quantity
from blinkit_products_cln as bp
left join blinkit_order_items_cln as boi
	on bp.product_id = boi.product_id
group by bp.product_id ,bp.product_name
having Quantity > (
	select
		sum(quantity)/(select count(distinct product_id) from blinkit_products_cln)
	from blinkit_order_items_cln
    )
order by Quantity desc;

# 3. Orders whose total value is above the average order value

# Simple + clean:

# Subquery = average order_total

# Main query = list orders above that average

select
	distinct order_id as Order_ID 
from blinkit_orders_cln
where order_total > (
	select
		sum(order_total)/count(distinct order_id)
	from blinkit_orders_cln
	);

# 4. Customers who placed MORE orders than the average customer

# Subquery inside HAVING.

select
	bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    count(distinct bo.order_id) as Number_Of_Orders
from blinkit_orders_cln as bo
join blinkit_customers_cln as bc
	on bo.customer_id = bc.customer_id
group by bo.customer_id ,bc.customer_name
having Number_Of_Orders > (
	select
		count(distinct order_id)/count(distinct customer_id)
	from blinkit_orders_cln
	)
order by Number_Of_Orders desc;

# Or alternately

select
	bo.customer_id as Customer_ID ,
    bc.customer_name as Customer_Name ,
    count(distinct bo.order_id) as Number_Of_Orders
from blinkit_orders_cln as bo
join blinkit_customers_cln as bc
	on bo.customer_id = bc.customer_id
group by bo.customer_id ,bc.customer_name
having Number_Of_Orders > (
	select
		avg(order_count) 
	from (
		select
			count(distinct order_id) as order_count ,
			customer_id as Customer_ID
		from blinkit_orders_cln
		group by customer_id
	) as t
)order by Number_Of_Orders desc;

# 5. Highest-selling product BY category (correlated subquery)

# Find the top product in each category
# (using a subquery filtered by category)

select
	p.category 		as Product_Category ,
    p.product_id 	as Product_ID ,
    p.product_name 	as Product_Name ,
    coalesce(round(sum(oi.quantity * oi.unit_price) ,2 ) ,0 ) as Sales
from blinkit_products_cln 			as p
left join blinkit_order_items_cln 	as oi
	on p.product_id = oi.product_id
group by Product_Category ,Product_ID ,Product_Name
having Sales = (
	select
		max(Product_Sales)
	from (
		select
			p2.product_id ,
			coalesce(round(sum(oi2.quantity * oi2.unit_price) ,2 ) ,0 ) as  Product_Sales
		from blinkit_products_cln 		as p2
        left join blinkit_order_items_cln 	as oi2
			on p2.product_id = oi2.product_id
		where p.category = p2.category
		group by p2.product_id
        ) as cat
)
order by Sales desc;

# Baby Food is the highest selling product
# Baby care was the post profitable category

# 1. Monthly revenue trend with categorization (CTE stage → final stage)

# CTE 1: start with monthly totals
# Final query: categorize months as “High”, “Medium”, “Low” based on revenue

with Monthly_Total as (
	select
        date_format(min(order_date) ,'%Y-%M' ) as Month_Year ,
        round(sum(order_total) ,2 ) as Monthly_Revenue 
	from blinkit_orders_cln
    group by year(order_date) ,month(order_date)
    order by year(order_date) ,month(order_date) asc
)

select 
	*,
	case
		when Monthly_Revenue < 100000 
			then 'Low'
		when Monthly_Revenue >= 100000 and Monthly_Revenue < 300000
			then 'Medium'
		else 'High'
	end as Revenue_Category
from Monthly_Total
order by Month_Year asc;
    
# 2. Identify top 10 customers by revenue, then analyze their feedback

# CTE 1: customer_ltv

# CTE 2: top_10_customers

# Final: join with feedback table to inspect satisfaction of best customers

with customer_ltv as (
	select
		bc.customer_id as Customer_ID ,
        bc.customer_name as Customer_Name ,
        coalesce(round(sum(bo.order_total) ,2 ) ,0 ) as Lifetime_Revenue
	from blinkit_customers_cln as bc
    join blinkit_orders_cln as bo
		on bc.customer_id = bo.customer_id
	group by bc.customer_id ,bc.customer_name
),

top_10_customers as (
	select
		*
	from customer_ltv
    order by Lifetime_Revenue desc
    limit 10
)

select
	t.Customer_ID ,
    t.Customer_Name ,
    t.Lifetime_Revenue ,
    count(f.feedback_id) 			as 	Number_Of_Feedbacks ,
    avg(f.rating) 					as 	Average_Rating ,
    sum(f.sentiment = 'Neutral') 	as	Neutral_Reviews ,
    sum(f.sentiment = 'Negative')	as 	Negative_Reviews ,
    sum(f.sentiment = 'Positive')	as 	Positive_Reviews
from top_10_customers as t
left join blinkit_customer_feedback_cln as f
	on t.Customer_ID = f.customer_id
group by t.Customer_ID ,t.Customer_Name
order by t.Lifetime_Revenue desc;

# 3. Product-level sales CTE → apply additional filtering

# CTE: compute product revenue, units, order_count
# Final query: only show products with revenue > 10,000 OR > 50 units

with Product_Sales as (
	select
		p.product_id as Product_ID ,
        p.product_name as Product_Name ,
        sum(oi.quantity) as Units_Sold ,
        count(oi.order_id) as Order_Count ,
        coalesce(round(sum(oi.quantity * oi.unit_price) ,2 ) ,0 ) as Product_Revenue
	from blinkit_products_cln as p
    left join blinkit_order_items_cln as oi
		on p.product_id = oi.product_id
	group by Product_ID ,Product_Name
    order by Product_Revenue desc
)

select *
from Product_Sales
where Product_Revenue > 10000 or Units_Sold > 50
order by Product_Revenue desc;

# 4. Multi-CTE pipeline: customer order frequency + revenue + average order value

# CTE 1: total orders per customer

# CTE 2: revenue per customer

# CTE 3: merge both and compute average order value

# Final: display customer segments by spending behavior

with Orders_Per_Customer as (
	select
		bc.customer_id 		as Customer_ID ,
        bc.customer_name 	as Customer_Name ,
		count(bo.order_id) 	as Order_Count
	from blinkit_customers_cln 		as bc
    left join blinkit_orders_cln 	as bo
		on bc.customer_id = bo.customer_id
	group by Customer_ID ,Customer_Name
),

Revenue_Per_Customer as (
	select
		bc.customer_id 									as Customer_ID ,
        bc.customer_name								as Customer_Name ,
        coalesce(round(sum(bo.order_total) ,2 ) ,0 )	as	Revenue
	from blinkit_customers_cln 		as bc
    left join blinkit_orders_cln 	as bo
		on bc.customer_id = bo.customer_id
	group by Customer_ID ,Customer_Name
),

Customer_Level_Metrics as (
		select
			o.Customer_ID										as Customer_ID ,
            o.Customer_Name 									as Customer_Name ,
            o.Order_Count 										as Order_Count ,
            r.Revenue											as Total_Revenue ,
            coalesce(round((r.Revenue/nullif(o.Order_Count ,0 )) ,2 ) ,0 )	as Avg_Order_Value
		from Revenue_Per_Customer 		as r
        left join Orders_Per_Customer 	as o
			on r.Customer_ID = o.Customer_ID
)

select
	Customer_ID ,
    Customer_Name ,
    Order_Count ,
    Total_Revenue ,
    Avg_Order_Value ,
    case
		when Total_Revenue > 10000 
			then "High Value"
		when Total_Revenue <= 10000 and Total_Revenue > 5000
			then "Medium Value"
		when Total_Revenue <= 5000
			then "Low Value"
	end as Customer_Value ,
    case
		when Order_Count >= 5
			then "Frequent Customer"
		else "Less Active"
	end as Customer_Activity ,
    case
		when Avg_Order_Value > 4000
			then "High AOV"
		when Avg_Order_Value > 2000 and Avg_Order_Value <= 4000
			then "Medium AOV"
		when Avg_Order_Value <= 2000
			then "Low AOV"
	end as Value_Per_Order
from customer_level_metrics
order by 
	Total_Revenue desc ,
    Order_Count desc ,
    Avg_Order_Value desc;