CREATE DATABASE walmart_db;
use walmart_db;
show tables;

select count(*) from walmart;
select * from walmart;

select payment_method, count(*)
from walmart
group by payment_method;

select count(distinct Branch) as no_of_branches from walmart;

select distinct category, round(total, 2) as Total
from walmart
order by Total desc;

-- Business Problems --

-- Q1 Which payment method is used most frequently and how many products are purchased through it --
SELECT 
    payment_method,
    COUNT(*) AS no_of_payments,
    SUM(quantity) AS no_of_qty
FROM
    walmart
GROUP BY payment_method
ORDER BY no_of_payments DESC;

-- Q2 Identify the highest rated category --
SELECT 
    category, ROUND(AVG(rating), 2) AS avg_rating
FROM
    walmart
GROUP BY category
ORDER BY avg_rating DESC;

-- Q3 Identify the highest rated category in each branch along with average rating column --
SELECT 
    branch, category, AVG(rating) AS avg_rating
FROM
    walmart
GROUP BY 1 , 2
ORDER BY 1 , 3 DESC;

-- Q4 Identify the category that has the highest average transaction value in each city --
SELECT 
    city, category, ROUND(AVG(total), 2) AS total_amount
FROM
    walmart
GROUP BY 1 , 2
ORDER BY 1 , 3 DESC;

-- Q5 Identify the busiest day for each branch based on the number of transactions --
select branch, day_name, no_of_transactions
from(
select branch, 
dayname(str_to_date(date, "%d/%m/%y")) as day_name,
count(*) as no_of_transactions,
rank() over (partition by branch order by count(*) DESC) as ranks
from walmart
group by branch, day_name
) as ranked
where ranks = 1;

-- Q6 Total profit in each city with their category --
SELECT 
    city,
    category,
    ROUND(SUM(unit_price * quantity * profit_margin),
            2) AS total_profit
FROM
    walmart
GROUP BY city , category
ORDER BY total_profit DESC;

-- Q7 Identify the daily sales trends based on date --
select date, round(sum(total), 2) as total_sales
from walmart
group by date
order by date;

-- Q8 Identify yearly sales trend --
select sale_year, category, total_sales
from
(select year(str_to_date(date, "%d/%m/%y")) as sale_year, category, round(sum(total), 2) as total_sales, RANK() OVER (PARTITION BY YEAR(STR_TO_DATE(date, '%d/%m/%Y')) 
                     ORDER BY SUM(total) DESC) AS sales_rank
from walmart
group by sale_year, category) as ranks
where sales_rank = 1;

-- Q9 Identify highest revenue product category in each branch --
select branch, category, total_sales
from
(select branch, category, round(sum(total), 2) as total_sales, row_number() over (partition by branch order by sum(total) DESC) as rn
from walmart
group by branch, category) as ranks
where rn = 1;

-- Q10 Categorize sales into morning, afternoon and evening shifts --
select branch, case
when hour(TIME(time)) < 12 then 'Morning'
when hour(TIME(time)) between 12 and 17 then 'Afternoon'
else 'Evening'
END as shifts,
count(*) as invoices
from walmart
group by branch, shifts
order by branch, invoices DESC;

-- Q11 Identify the most common payment method for each branch --
with payment_methods as (
select branch, payment_method, count(*) as total_trans,
row_number() over (partition by branch order by count(*)) as rn
from walmart
group by branch, payment_method)
select branch, payment_method, total_trans
from payment_methods
where rn = 1;