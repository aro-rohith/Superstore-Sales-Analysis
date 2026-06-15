create database superstore_project;
use superstore_project;

-- ==========================================
-- Overall Business Performance
-- ==========================================

select * from sales_management;

select
	sum(sales) as total_sales,
	sum(profit) as total_profit,
    sum(quantity) as total_quantity
from sales_management;

-- ==========================================
-- Yearly Sales Analysis
-- ==========================================

select
	year(order_date) as yearly,
	sum(sales) as total_sales
from sales_management
group by year(order_date)
order by year(order_date) asc;

-- ==========================================
-- Yearly Sales, Profit and Profit Margin Analysis
-- ==========================================

select
	year(order_date) as yearly,
	round(sum(sales),2) as total_sales,
	round(sum(profit),2) as total_profit,
	round((sum(profit) / sum(sales)) * 100,2) as profit_margin_percentage
from sales_management
group by year(order_date)
order by year(order_date) asc;

-- ==========================================
-- Segment Performance Analysis
-- ==========================================

select
	year(order_date) as yearly,
	segment,
	round(sum(sales),2) as total_sales,
	round(sum(profit),2) as total_profit,
	round((sum(profit) / sum(sales)) * 100,2) as profit_margin_percentage
from sales_management
group by yearly,segment
order by yearly;

-- ==========================================
-- Highest Revenue Generating Segment
-- ==========================================

select
	segment,
	round(sum(sales),2) as total_sales
from sales_management
group by segment
having sum(sales) = (
	select
	max(total)
	from (
		select sum(sales) as total
		from sales_management
		group by segment
	)t
);

-- ==========================================
-- Regional Performance Analysis
-- ==========================================

select
	region,
	round(sum(sales),2) as total_sales,
    round(sum(profit),2) as total_profit
from sales_management
group by region
order by total_profit desc;

-- ==========================================
-- Regional Profit Margin Analysis
-- ==========================================

select
	region,
	round(sum(sales),2) as total_sales,
    round(sum(profit),2) as total_profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by region
order by total_profit desc;

-- ==========================================
-- Regional Performance by Year
-- ==========================================

select
	region,
    year(order_date) as yearly,
	round(sum(sales),2) as total_sales,
    round(sum(profit),2) as total_profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by year(order_date),region
order by yearly asc, profit_margin desc;

-- ==========================================
-- Identify Regions with Highest and Lowest Profit Margin
-- Window Function Approach
-- ==========================================

with yearly_region_profit as (

	select
	region,
    year(order_date) as yearly,
	round(sum(sales),2) as total_sales,
    round(sum(profit),2) as total_profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin,

	rank() over (
    order by (sum(profit) / sum(sales)) * 100 desc
    ) as max_margin_rank,

    rank() over (
    order by (sum(profit) / sum(sales)) * 100 asc
    ) as min_margin_rank

    from sales_management
    group by year(order_date),region
)

select *
from yearly_region_profit
where max_margin_rank = 1
or min_margin_rank = 1;

-- ==========================================
-- Category Performance Analysis
-- ==========================================

select
	category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit
from sales_management
group by category
order by profit desc;

-- ==========================================
-- Yearly Category Performance Analysis
-- ==========================================

select
	year(order_date) as yearly,
    category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by year(order_date),category
order by yearly asc, profit desc;

-- ==========================================
-- Overall Sub-Category Performance
-- ==========================================

select
	sub_category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit
from sales_management
group by sub_category;

-- ==========================================
-- Sub-Category Profit Margin Analysis
-- ==========================================

select
	sub_category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by sub_category;

-- ==========================================
-- Yearly Sub-Category Performance
-- ==========================================

select
	year(order_date) as year,
	sub_category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by year(order_date),sub_category
order by year asc, profit desc;

-- ==========================================
-- Top 5 Sub-Categories by Profit Margin
-- for Each Year
-- ==========================================

with yearly_subcategory as (

	select
	year(order_date) as yearly,
	sub_category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin,

	rank() over (
    partition by year(order_date)
    order by sum(profit) / sum(sales) * 100 desc
    ) as profit_rank

    from sales_management
    group by year(order_date),sub_category
)

select *
from yearly_subcategory
where profit_rank <= 5;

-- ==========================================
-- Category and Sub-Category Sales Analysis
-- ==========================================

select
	category,
    sub_category,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit
from sales_management
group by category,sub_category
order by sales desc, profit asc;

-- ==========================================
-- Top 10 Products by Sales
-- ==========================================

select
	product_name,
    round(sum(sales),2) as sales
from sales_management
group by product_name
order by sum(sales) desc
limit 10;

-- ==========================================
-- Top 10 Products by Profit
-- ==========================================

select
	product_name,
    round(sum(profit),2) as profit
from sales_management
group by product_name
order by sum(profit) desc
limit 10;

-- ==========================================
-- High Sales but Low Profit Margin Products
-- ==========================================

select
	product_name,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
	round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by product_name
order by sum(sales) desc,
         (sum(profit) / sum(sales) * 100) asc
limit 10;

-- ==========================================
-- Low Sales but High Profit Margin Products
-- ==========================================

with product_analysis as (

    select
        product_name,
        round(sum(sales),2) as sales,
        round(sum(profit),2) as profit,
        round((sum(profit) / sum(sales)) * 100,2) as profit_margin
    from sales_management
    group by product_name
)

select *
from product_analysis
where sales < (
    select avg(sales)
    from product_analysis
)
and profit_margin > (
    select avg(profit_margin)
    from product_analysis
)
order by sales asc;

-- ==========================================
-- Top Customers by Spending
-- ==========================================

select
	customer_name,
    round(sum(sales),2) as total_spending
from sales_management
group by customer_name
order by total_spending desc
limit 10;

-- ==========================================
-- Customers with Repeated Orders
-- ==========================================

select
	customer_name,
    count(distinct order_id) as repeated_order
from sales_management
group by customer_name
order by count(distinct order_id) desc;

-- ==========================================
-- Frequently Purchased Products
-- by Repeat Customers
-- ==========================================

select
	customer_name,
    product_name,
    count(*) as purchase_frequency
from sales_management
group by customer_name, product_name
order by purchase_frequency desc;

-- ==========================================
-- Sales and Profit Performance
-- by Shipping Mode
-- ==========================================

select
	ship_mode,
	round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by ship_mode
order by profit_margin desc;

-- ==========================================
-- Identify Heavily Discounted but
-- Weakly Profitable Categories
-- ==========================================

select
	category,
    sub_category,
    round(avg(discount),2) as average_discount,
    round(sum(sales),2) as sales,
    round(sum(profit),2) as profit,
    round((sum(profit) / sum(sales)) * 100,2) as profit_margin
from sales_management
group by category, sub_category
order by average_discount desc,
         profit_margin asc;