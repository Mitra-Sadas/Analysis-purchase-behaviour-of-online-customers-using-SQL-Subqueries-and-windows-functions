create database sql2_mini_project;
use sql2_mini_project;
# Join all the tables and create a new table called combined_table.
#(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

Create table Combined_table as
select m.ord_id,m.Prod_id,m.ship_id,sales,Discount,Order_quantity,Profit,Shipping_cost,Product_base_Margin,
Customer_Name,Province,Region,Customer_Segment,o.Order_ID,Order_Date,Order_Priority,Product_Category,Product_sub_Category,
ship_mode,ship_date
from market_fact m
join cust_dimen c 
on c.cust_id=m.cust_id
join orders_dimen o
on o.ord_id=m.ord_id
join prod_dimen p 
on p.prod_id=m.prod_id
join shipping_dimen s 
on s.ship_id=m.ship_id ;


# Finding the top 3 customers who have the maximum number of orders

select customer_name,count(ord_id) No_of_orders from combined_table
group by customer_name
order by No_of_orders desc limit 3;

select customer_name,cust_id from cust_dimen
where cust_id in 
(select cust_id 
from (select cust_id,count(ord_id) No_of_orders from market_fact
group by cust_id 
order by no_of_orders desc limit 3)t) ;

#	Creating a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

select *, datediff(str_to_date(Ship_Date,'%d-%m-%Y'),str_to_date(Order_Date,'%d-%m-%Y')) DaysTakenForDelivery from combined_table;
alter table combined_table add column  DaysTakenForDelivery int default (datediff(str_to_date(Ship_Date,'%d-%m-%Y'),str_to_date(Order_Date,'%d-%m-%Y')));

select * from combined_table;

#	Finding the customer whose order took the maximum time to get delivered.
select customer_name,DaysTakenForDelivery from combined_table
order by DaysTakenForDelivery desc limit 1;

#using subquery
select customer_name from combined_table
where DaysTakenForDelivery=(select max(DaysTakenForDelivery) from combined_table );

#	Retrieving total sales made by each product from the data (use Windows function)

select  distinct prod_id,round(sum(sales) over (partition by prod_id),2) Total_Sales from market_fact;

#	Retrieving total profit made from each product from the data (use windows function)

select  distinct prod_id,round(sum(profit) over (partition by prod_id),2) Total_Sales from market_fact;

#	Counting the total number of unique customers in January and how many of them came back every month over the entire year in 2011

#No of unique customers in January
select count(distinct cust_id) No_of_Unique_customers from
(select cust_id, o.ord_id,order_date from market_fact m
join orders_dimen o
on o.ord_id=m.ord_id
where monthname(str_to_date(order_date,'%d-%m-%Y'))='January' and year(str_to_date(order_date,'%d-%m-%Y'))=2011)t;

#No of unique customers in january that came back in later months
select count(distinct cust_id) No_of_customers_came_back from market_fact m
join orders_dimen o
on o.ord_id=m.ord_id
where cust_id in (
select distinct cust_id from
(select cust_id, o.ord_id,order_date from market_fact m
join orders_dimen o
on o.ord_id=m.ord_id
where monthname(str_to_date(order_date,'%d-%m-%Y'))='January' and year(str_to_date(order_date,'%d-%m-%Y'))=2011)t)
and monthname(str_to_date(order_date,'%d-%m-%Y'))in('February','March','April','May','June','July','August','September','October','November','December') 
and year(str_to_date(order_date,'%d-%m-%Y'))=2011;


#	Retrieving month-by-month customer retention rate since the start of the business.(using views)
### creating view for cust_retention
create view cust_retention as
select cust_id, o.ord_id,order_date,month(str_to_date(order_date,'%d-%m-%Y')) Monthh
from market_fact m
join orders_dimen o
on o.ord_id=m.ord_id;

### Categorising customers
select *,abs(Next_visit-Monthh) Time_gap,
case
when abs(Next_visit-Monthh)<=1 then 'retained'
when abs(Next_visit-Monthh)>1 then 'irregular'
else 'churned'
end as cust_category
from (select cust_id,ord_id,order_date,Monthh,
lead(Monthh) over(partition by cust_id order by str_to_date(order_date,'%d-%m-%Y')) Next_visit
from cust_retention)t;

#### Monthly customer retention rate 
select monthname(str_to_date(Monthh,'%m')) monthNam,No_of_Customers, 
round(No_of_customers/first_value(No_of_Customers)over()*100,2) 'Monthly_retention_rate'
from(select  count(distinct cust_id) No_of_Customers,month(str_to_date(order_date,'%d-%m-%Y')) Monthh,
row_number() over(partition by cust_id order by  month(str_to_date(order_date,'%d-%m-%Y'))) 
from market_fact m
join orders_dimen o
on o.ord_id=m.ord_id
group by Monthh)t
order by Monthh;


