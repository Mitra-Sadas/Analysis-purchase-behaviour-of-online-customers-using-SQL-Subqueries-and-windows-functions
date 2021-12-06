# Analysis-purchase-behaviour-of-online-customers-using-SQL-Subqueries-and-windows-functions
To learn and understand the purchasing behavior of online customers.
The data is confined to ‘Sales and Delivery’ and is provided for the period of last decade.
This will be useful in 
  · Analyzing seasonality & business patterns 
  · Product analysis 
  · User analysis 
  . order placed 
  . orders delivered

Instructions:

1. Join all the tables and create a new table called combined_table.
   (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

2.	Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

Tips:
1. Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple  years since whenever business started operations
2. Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
3. Calculate the time gaps between visits
4. categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned
5. calculate the retention month wise

