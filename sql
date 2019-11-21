-- For each product in the database, calculate how many more orders where placed in 
-- each month compared to the previous month.

-- IMPORTANT! This is going to be a 2-day warmup! FOR NOW, assume that each product
-- has sales every month. Do the calculations so that you're comparing to the previous 
-- month where there were sales.
-- For example, product_id #1 has no sales for October 1996. So compare November 1996
-- to September 1996 (the previous month where there were sales):
-- So if there were 27 units sold in November and 20 in September, the resulting 
-- difference should be 27-7 = 7.
-- (Later on we will work towards filling in the missing months.)

-- BIG HINT: Look at the expected results, how do you convert the dates to the 
-- correct format (year and month)?

with product_info AS (
    SELECT od.product_id, o.order_date, od.quantity 
    FROM order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY 1, 2, 3
),
units_sold_info AS (
    SELECT product_id,
    EXTRACT(YEAR FROM order_date) AS year, EXTRACT(MONTH FROM order_date) AS month,
    sum(quantity) AS units_sold
    FROM product_info
    GROUP BY 1,2,3
    ORDER BY 2
),
customer_total_lags AS(
   SELECT *,
   LAG(units_sold,1) OVER(PARTITION BY product_id ORDER BY product_id, year, month asc ) as previous 
   FROM units_sold_info
)
SELECT product_id, year, month, units_sold, previous,
units_sold - Coalesce(previous,0) AS difference
FROM customer_total_lags
ORDER BY product_id, year, month;
